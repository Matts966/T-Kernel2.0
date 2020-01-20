#include "wolfmqtt/mqtt_client.h"

#include "nbclient.h"
#include "examples/mqttnet.h"

#define TEST_MESSAGE    "test"

int mqttclient_publish(MQTTCtx *mqttCtx) {
    int rc = MQTT_CODE_SUCCESS;

    PRINTF("Publishing...(timeout=%dms)", mqttCtx->cmd_timeout_ms);

    /* Publish Topic */
    mqttCtx->publish.retain = 0;
    mqttCtx->publish.qos = mqttCtx->qos;
    mqttCtx->publish.duplicate = 0;
    mqttCtx->publish.topic_name = mqttCtx->topic_name;
    mqttCtx->publish.packet_id = mqtt_get_packetid();
    if (mqttCtx->publish.buffer == NULL) {
        mqttCtx->publish.buffer = (byte*)TEST_MESSAGE;
    }
    mqttCtx->publish.total_len = (word16)XSTRLEN(mqttCtx->publish.buffer);
    do {
        rc = MqttClient_Publish(&mqttCtx->client, &mqttCtx->publish);
    } while (rc == MQTT_CODE_CONTINUE);

    PRINTF("MQTT Publish: Topic %s, %s (%d)",
        mqttCtx->publish.topic_name,
        MqttClient_ReturnCodeToString(rc), rc);
    if (rc != MQTT_CODE_SUCCESS) {
        goto disconn;
    }

    return rc;

disconn:
    /* Disconnect */
    rc = MqttClient_Disconnect_ex(&mqttCtx->client,
           &mqttCtx->disconnect);
    PRINTF("MQTT Disconnect: %s (%d)",
        MqttClient_ReturnCodeToString(rc), rc);
    if (rc < 0) {
        return rc;
    }
    rc = MqttClient_NetDisconnect(&mqttCtx->client);
    PRINTF("MQTT Socket Disconnect: %s (%d)",
        MqttClient_ReturnCodeToString(rc), rc);

exit:
    /* Cleanup network */
    MqttClientNet_DeInit(&mqttCtx->net);

    MqttClient_DeInit(&mqttCtx->client);

    return rc;
}
