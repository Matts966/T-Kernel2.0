#include "wolfmqtt/mqtt_client.h"

#include "mqttclient.h"
#include "examples/mqttnet.h"

#define MAX_BUFFER_SIZE 1024

int mqtt_message_cb(MqttClient *client, MqttMessage *msg,
    byte msg_new, byte msg_done);

int mqtt_disconnect_cb(MqttClient* client, int error_code, void* ctx);

int mqttclient_connect(MQTTCtx *mqttCtx) {
    int rc = MQTT_CODE_SUCCESS, i;

    PRINTF("MQTT Client: QoS %d, Use TLS %d", mqttCtx->qos,
            mqttCtx->use_tls);

    /* Initialize Network */
    do {
        rc = MqttClientNet_Init(&mqttCtx->net, mqttCtx);
        PRINTF("MQTT Net Init: %s (%d)",
            MqttClient_ReturnCodeToString(rc), rc);
    } while(rc == MQTT_CODE_CONTINUE);

    if (rc != MQTT_CODE_SUCCESS) {
        goto exit;
    }

    /* setup tx/rx buffers */
    mqttCtx->tx_buf = (byte*)WOLFMQTT_MALLOC(MAX_BUFFER_SIZE);
    mqttCtx->rx_buf = (byte*)WOLFMQTT_MALLOC(MAX_BUFFER_SIZE);

    /* Initialize MqttClient structure */
    do {
        rc = MqttClient_Init(&mqttCtx->client, &mqttCtx->net,
            mqtt_message_cb,
            mqttCtx->tx_buf, MAX_BUFFER_SIZE,
            mqttCtx->rx_buf, MAX_BUFFER_SIZE,
            mqttCtx->cmd_timeout_ms);
    } while(rc == MQTT_CODE_CONTINUE);

    PRINTF("MQTT Init: %s (%d)",
        MqttClient_ReturnCodeToString(rc), rc);
    if (rc != MQTT_CODE_SUCCESS) {
        goto exit;
    }
    /* The client.ctx will be stored in the cert callback ctx during
       MqttSocket_Connect for use by mqtt_tls_verify_cb */
    mqttCtx->client.ctx = mqttCtx;

    /* setup disconnect callback */
    do {
        rc = MqttClient_SetDisconnectCallback(&mqttCtx->client,
            mqtt_disconnect_cb, NULL);
    } while(rc == MQTT_CODE_CONTINUE);
    if (rc != MQTT_CODE_SUCCESS) {
        goto exit;
    }

    /* Connect to broker */
    do {
        rc = MqttClient_NetConnect(&mqttCtx->client, mqttCtx->host,
            mqttCtx->port,
            DEFAULT_CON_TIMEOUT_MS, mqttCtx->use_tls, mqtt_tls_cb);
    } while(rc == MQTT_CODE_CONTINUE);

    PRINTF("MQTT Socket Connect: %s (%d)",
        MqttClient_ReturnCodeToString(rc), rc);
    if (rc != MQTT_CODE_SUCCESS) {
        goto exit;
    }

    /* Build connect packet */
    XMEMSET(&mqttCtx->connect, 0, sizeof(MqttConnect));
    mqttCtx->connect.keep_alive_sec = mqttCtx->keep_alive_sec;
    mqttCtx->connect.clean_session = mqttCtx->clean_session;
    mqttCtx->connect.client_id = mqttCtx->client_id;

    /* Last will and testament sent by broker to subscribers
        of topic when broker connection is lost */
    XMEMSET(&mqttCtx->lwt_msg, 0, sizeof(mqttCtx->lwt_msg));
    mqttCtx->connect.lwt_msg = &mqttCtx->lwt_msg;
    mqttCtx->connect.enable_lwt = mqttCtx->enable_lwt;
    if (mqttCtx->enable_lwt) {
        /* Send client id in LWT payload */
        mqttCtx->lwt_msg.qos = mqttCtx->qos;
        mqttCtx->lwt_msg.retain = 0;
        mqttCtx->lwt_msg.topic_name = WOLFMQTT_TOPIC_NAME"lwttopic";
        mqttCtx->lwt_msg.buffer = (byte*)mqttCtx->client_id;
        mqttCtx->lwt_msg.total_len =
          (word16)XSTRLEN(mqttCtx->client_id);
    }
    /* Optional authentication */
    mqttCtx->connect.username = mqttCtx->username;
    mqttCtx->connect.password = mqttCtx->password;

    /* Send Connect and wait for Connect Ack */
    do {
        rc = MqttClient_Connect(&mqttCtx->client, &mqttCtx->connect);
    } while(rc == MQTT_CODE_CONTINUE);

    PRINTF("MQTT Connect: %s (%d)",
        MqttClient_ReturnCodeToString(rc), rc);
    if (rc != MQTT_CODE_SUCCESS) {
        goto disconn;
    }

    /* Validate Connect Ack info */
    PRINTF("MQTT Connect Ack: Return Code %u, Session Present %d",
        mqttCtx->connect.ack.return_code,
        (mqttCtx->connect.ack.flags &
            MQTT_CONNECT_ACK_FLAG_SESSION_PRESENT) ?
            1 : 0
    );

    if (rc == MQTT_CODE_SUCCESS) return rc;

disconn:
    /* Disconnect */
    do {
        rc = MqttClient_Disconnect_ex(&mqttCtx->client,
           &mqttCtx->disconnect);
    } while(rc == MQTT_CODE_CONTINUE);
    PRINTF("MQTT Disconnect: %s (%d)",
        MqttClient_ReturnCodeToString(rc), rc);
    if (rc < 0) {
        goto exit;
    }
    do {
        rc = MqttClient_NetDisconnect(&mqttCtx->client);
    } while(rc == MQTT_CODE_CONTINUE);
    PRINTF("MQTT Socket Disconnect: %s (%d)",
        MqttClient_ReturnCodeToString(rc), rc);

exit:
    /* Free resources */
    if (mqttCtx->tx_buf) WOLFMQTT_FREE(mqttCtx->tx_buf);
    if (mqttCtx->rx_buf) WOLFMQTT_FREE(mqttCtx->rx_buf);

    /* Cleanup network */
    MqttClientNet_DeInit(&mqttCtx->net);

    MqttClient_DeInit(&mqttCtx->client);

    return rc;
}
