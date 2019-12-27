#include "wolfmqtt/mqtt_client.h"

#include "nbclient.h"
#include "examples/mqttnet.h"

#define MAX_BUFFER_SIZE 1024

int mqtt_message_cb(MqttClient *client, MqttMessage *msg,
    byte msg_new, byte msg_done);

int mqtt_disconnect_cb(MqttClient* client, int error_code, void* ctx);

int mqttclient_connect(MQTTCtx *mqttCtx)
{
    int rc = MQTT_CODE_SUCCESS, i;

    switch (mqttCtx->stat) {
        case WMQ_BEGIN:
        {
            PRINTF("MQTT Client: QoS %d, Use TLS %d", mqttCtx->qos,
                    mqttCtx->use_tls);

            FALL_THROUGH;
        }

        case WMQ_NET_INIT:
        {
            mqttCtx->stat = WMQ_NET_INIT;

            /* Initialize Network */
            rc = MqttClientNet_Init(&mqttCtx->net, mqttCtx);
            if (rc == MQTT_CODE_CONTINUE) {
                return rc;
            }
            PRINTF("MQTT Net Init: %s (%d)",
                MqttClient_ReturnCodeToString(rc), rc);
            if (rc != MQTT_CODE_SUCCESS) {
                goto exit;
            }

            /* setup tx/rx buffers */
            mqttCtx->tx_buf = (byte*)WOLFMQTT_MALLOC(MAX_BUFFER_SIZE);
            mqttCtx->rx_buf = (byte*)WOLFMQTT_MALLOC(MAX_BUFFER_SIZE);

            FALL_THROUGH;
        }

        case WMQ_INIT:
        {
            mqttCtx->stat = WMQ_INIT;

            /* Initialize MqttClient structure */
            rc = MqttClient_Init(&mqttCtx->client, &mqttCtx->net,
                mqtt_message_cb,
                mqttCtx->tx_buf, MAX_BUFFER_SIZE,
                mqttCtx->rx_buf, MAX_BUFFER_SIZE,
                mqttCtx->cmd_timeout_ms);
            if (rc == MQTT_CODE_CONTINUE) {
                return rc;
            }
            PRINTF("MQTT Init: %s (%d)",
                MqttClient_ReturnCodeToString(rc), rc);
            if (rc != MQTT_CODE_SUCCESS) {
                goto exit;
            }
            mqttCtx->client.ctx = mqttCtx;

        #ifdef WOLFMQTT_DISCONNECT_CB
            /* setup disconnect callback */
            rc = MqttClient_SetDisconnectCallback(&mqttCtx->client,
                mqtt_disconnect_cb, NULL);
            if (rc != MQTT_CODE_SUCCESS) {
                goto exit;
            }
        #endif
            FALL_THROUGH;
        }

        case WMQ_TCP_CONN:
        {
            mqttCtx->stat = WMQ_TCP_CONN;

            /* Connect to broker */
            rc = MqttClient_NetConnect(&mqttCtx->client, mqttCtx->host,
                   mqttCtx->port,
                DEFAULT_CON_TIMEOUT_MS, mqttCtx->use_tls, mqtt_tls_cb);
            if (rc == MQTT_CODE_CONTINUE) {
                return rc;
            }
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
            FALL_THROUGH;
        }

        case WMQ_MQTT_CONN:
        {
            mqttCtx->stat = WMQ_MQTT_CONN;

            /* Send Connect and wait for Connect Ack */
            rc = MqttClient_Connect(&mqttCtx->client, &mqttCtx->connect);
            if (rc == MQTT_CODE_CONTINUE) {
                return rc;
            }
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

            /* Build list of topics */
            XMEMSET(&mqttCtx->subscribe, 0, sizeof(MqttSubscribe));

            i = 0;
            mqttCtx->topics[i].topic_filter = mqttCtx->topic_name;
            mqttCtx->topics[i].qos = mqttCtx->qos;

            /* Subscribe Topic */
            mqttCtx->subscribe.stat = MQTT_MSG_BEGIN;
            mqttCtx->subscribe.packet_id = mqtt_get_packetid();
            mqttCtx->subscribe.topic_count =
                    sizeof(mqttCtx->topics) / sizeof(MqttTopic);
            mqttCtx->subscribe.topics = mqttCtx->topics;

            goto connected;
        }
    }

disconn:
    mqttCtx->stat = WMQ_NET_DISCONNECT;
    mqttCtx->return_code = rc;

exit:
    if (rc != MQTT_CODE_CONTINUE) {
        /* Free resources */
        if (mqttCtx->tx_buf) WOLFMQTT_FREE(mqttCtx->tx_buf);
        if (mqttCtx->rx_buf) WOLFMQTT_FREE(mqttCtx->rx_buf);

        /* Cleanup network */
        MqttClientNet_DeInit(&mqttCtx->net);

        MqttClient_DeInit(&mqttCtx->client);
    }

    return rc;

connected:
    return MQTT_CODE_SUCCESS;
}

