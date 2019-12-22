#include "wolfmqtt/mqtt_client.h"

#include "mqttclient.h"
#include "examples/mqttnet.h"

int mqttclient_wait(MQTTCtx *mqttCtx) {
    int rc = MQTT_CODE_SUCCESS, i;

    /* Read Loop */
    PRINTF("MQTT Waiting for message...");

    do {
        /* Try and read packet */
        rc = MqttClient_WaitMessage(&mqttCtx->client,
            mqttCtx->cmd_timeout_ms);

        if (rc == MQTT_CODE_ERROR_TIMEOUT) {
            /* Keep Alive */
            PRINTF("Keep-alive timeout, sending ping");

            rc = MqttClient_Ping(&mqttCtx->client);
            if (rc != MQTT_CODE_SUCCESS) {
                PRINTF("MQTT Ping Keep Alive Error: %s (%d)",
                    MqttClient_ReturnCodeToString(rc), rc);
                break;
            }
        }
        else if (rc == MQTT_CODE_SUCCESS) {
            return rc;
        }
        else {
            /* There was an error */
            PRINTF("MQTT Message Wait: %s (%d)",
                MqttClient_ReturnCodeToString(rc), rc);
            break;
        }
    } while (1);

disconn:
    /* Disconnect */
    rc = MqttClient_Disconnect_ex(&mqttCtx->client,
           &mqttCtx->disconnect);

    PRINTF("MQTT Disconnect: %s (%d)",
        MqttClient_ReturnCodeToString(rc), rc);
#ifdef TKERNEL
    if (rc < 0) {
        goto exit;
    }
#endif
    if (rc != MQTT_CODE_SUCCESS) {
        goto disconn;
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
