#include "wolfmqtt/mqtt_client.h"

#include "mqttclient.h"
#include "examples/mqttnet.h"

int mqttclient_free(MQTTCtx *mqttCtx) {
    int rc = MqttClient_Disconnect_ex(&mqttCtx->client,
           &mqttCtx->disconnect);

    PRINTF("MQTT Disconnect: %s (%d)",
        MqttClient_ReturnCodeToString(rc), rc);
    if (rc < 0) {
        goto exit;
    }

    rc = MqttClient_NetDisconnect(&mqttCtx->client);

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
