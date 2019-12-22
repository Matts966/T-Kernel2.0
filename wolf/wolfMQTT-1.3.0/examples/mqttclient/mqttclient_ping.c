#include "wolfmqtt/mqtt_client.h"

#include "mqttclient.h"
#include "examples/mqttnet.h"

int mqttclient_ping(MQTTCtx *mqttCtx) {
    int rc = MQTT_CODE_SUCCESS, i;

    /* Keep Alive */
    PRINTF("Sending ping");

    rc = MqttClient_Ping(&mqttCtx->client);
    if (rc != MQTT_CODE_SUCCESS) {
        PRINTF("MQTT Ping Keep Alive Error: %s (%d)",
            MqttClient_ReturnCodeToString(rc), rc);
    }
}
