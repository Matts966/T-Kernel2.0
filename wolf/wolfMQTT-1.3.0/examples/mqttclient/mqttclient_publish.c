#include "wolfmqtt/mqtt_client.h"

#include "mqttclient.h"
#include "examples/mqttnet.h"

#define TEST_MESSAGE    "test"

int mqttclient_publish(MQTTCtx *mqttCtx) {
    int rc = MQTT_CODE_SUCCESS, i;

    PRINTF("Publishing...(timeout=%dms)", mqttCtx->cmd_timeout_ms);

    /* Publish Topic */
    XMEMSET(&mqttCtx->publish, 0, sizeof(MqttPublish));
    mqttCtx->publish.retain = 0;
    mqttCtx->publish.qos = mqttCtx->qos;
    mqttCtx->publish.duplicate = 0;
    mqttCtx->publish.topic_name = mqttCtx->topic_name;
    mqttCtx->publish.packet_id = mqtt_get_packetid();
    if (mqttCtx->publish.buffer == NULL) mqttCtx->publish.buffer = (byte*)TEST_MESSAGE;
    mqttCtx->publish.total_len = (word16)XSTRLEN(mqttCtx->publish.buffer);

    rc = MqttClient_Publish(&mqttCtx->client, &mqttCtx->publish);

    PRINTF("MQTT Publish: Topic %s, %s (%d)",
        mqttCtx->publish.topic_name,
        MqttClient_ReturnCodeToString(rc), rc);
    if (rc != MQTT_CODE_SUCCESS) {
        return rc;
    }

    return rc;
}