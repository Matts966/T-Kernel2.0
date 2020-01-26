#include "wolfmqtt/mqtt_client.h"

#include "mqttclient.h"
#include "examples/mqttnet.h"

int mqttclient_wait(MQTTCtx *mqttCtx) {
    int rc = MQTT_CODE_SUCCESS, i;

    /* Read Loop */
    PRINTF("MQTT Waiting for message...");

    /* Try and read packet */
    rc = MqttClient_WaitMessage(&mqttCtx->client,
        mqttCtx->cmd_timeout_ms);

    if (rc == MQTT_CODE_SUCCESS) {
        return rc;
    }

    if (rc == MQTT_CODE_ERROR_TIMEOUT) {
        /* Keep Alive */
        PRINTF("Keep-alive timeout, sending ping");

        rc = MqttClient_Ping(&mqttCtx->client);
        if (rc = MQTT_CODE_SUCCESS) {
            return rc;
        }
        PRINTF("MQTT Ping Keep Alive Error: %s (%d)",
            MqttClient_ReturnCodeToString(rc), rc);
    }

    /* There was an error */
    PRINTF("MQTT Message Wait: %s (%d)",
        MqttClient_ReturnCodeToString(rc), rc);
    return rc;
}
