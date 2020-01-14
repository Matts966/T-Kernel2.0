#include "wolfmqtt/mqtt_client.h"

#include "mqttclient.h"
#include "examples/mqttnet.h"

int mqttclient_subscribe(MQTTCtx *mqttCtx) {
    int rc = MQTT_CODE_SUCCESS, i;

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

    do {
        rc = MqttClient_Subscribe(&mqttCtx->client, &mqttCtx->subscribe);
    } while (rc == MQTT_CODE_CONTINUE);

    PRINTF("MQTT Subscribe: %s (%d)",
        MqttClient_ReturnCodeToString(rc), rc);

    if (rc != MQTT_CODE_SUCCESS) {
        return rc;
    }

    /* show subscribe results */
    for (i = 0; i < mqttCtx->subscribe.topic_count; i++) {
        mqttCtx->topic = &mqttCtx->subscribe.topics[i];
        PRINTF("  Topic %s, Qos %u, Return Code %u",
            mqttCtx->topic->topic_filter,
            mqttCtx->topic->qos, mqttCtx->topic->return_code);
    }

    return rc;
}