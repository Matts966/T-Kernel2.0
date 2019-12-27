#include "wolfmqtt/mqtt_client.h"

#include "nbclient.h"
#include "examples/mqttnet.h"

int mqttclient_ping(MQTTCtx *mqttCtx) {
    int rc = MQTT_CODE_SUCCESS, i;

    /* Keep Alive */
    PRINTF("Sending ping");

    do {
        rc = MqttClient_Ping(&mqttCtx->client);
    } while (rc == MQTT_CODE_CONTINUE);

    if (rc != MQTT_CODE_SUCCESS) {
        PRINTF("MQTT Ping Keep Alive Error: %s (%d)",
            MqttClient_ReturnCodeToString(rc), rc);
    }

    return rc;
}
