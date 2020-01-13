#include <tk/tkernel.h>
#include <tm/tmonitor.h>
#include <libstr.h>
#include "wolfmqtt/mqtt_client.h"
#include "examples/mqttnet.h"
#include "examples/nbclient/nbclient.h"

#define NET_CONF_EMULATOR (1)
#define NET_CONF_DHCP   (1)

typedef enum { TASK_MQTT_SHELL, OBJ_KIND_NUM } OBJ_KIND;
EXPORT ID ObjID[OBJ_KIND_NUM];

EXPORT void task_mqtt_shell(INT stacd, VP exinf);
EXPORT void task_mqtt_shell(INT stacd, VP exinf) {
	MQTTCtx mqttCtx;
	mqtt_init_ctx(&mqttCtx);
	mqttCtx.app_name = "mqtt_client";
	mqttCtx.host = "test.mosquitto.org";
	mqttCtx.port = 1883;
	mqttCtx.qos = (MqttQoS)(1);
	mqttCtx.test_mode = 1;
	mqttCtx.topic_name = "test";
	int rc;

	while ( 1 ) {
		tm_putstring((UB*)"- Push p to publish a test message.\n");
		tm_putstring((UB*)"- Push w to wait messages.\n");
		tm_putstring((UB*)"- Push s to subscribe to a test topic.\n");
		tm_putstring((UB*)"- Push k to keep connection.\n");
		tm_putstring((UB*)"- Push c to connect.\n");
		char c = tm_getchar(-1);
		tm_putstring("\n");
		if (c == 'p') {
			mqttclient_publish(&mqttCtx);
		} else if (c == 'w') {
			mqttclient_wait(&mqttCtx);
		} else if (c == 's') {
			mqttclient_subscribe(&mqttCtx);
		} else if (c == 'k') {
			mqttclient_ping(&mqttCtx);
		} else if (c == 'c') {
			int rc;
			mqttCtx.stat = WMQ_BEGIN;
			do {
				rc = mqttclient_connect(&mqttCtx);
			} while (rc == MQTT_CODE_CONTINUE);
		}
	}

	tk_ext_tsk();
}

EXPORT INT usermain( void ) {
	T_CTSK t_ctsk;
	ID objid;
	t_ctsk.tskatr = TA_HLNG | TA_DSNAME;

	t_ctsk.stksz = 1024;
	t_ctsk.itskpri = 1;

	// Network initialization
	ER err = NetDrv(0, NULL);
	err = so_main(0, NULL);
	net_conf(NET_CONF_EMULATOR, NET_CONF_DHCP);

	t_ctsk.itskpri = 1;
	t_ctsk.stksz = 1024;
	STRCPY( (char *)t_ctsk.dsname, "task_mqtt_shell");
	t_ctsk.task = task_mqtt_shell;
	if ( (objid = tk_cre_tsk( &t_ctsk )) <= E_OK ) {
		tm_putstring(" *** Failed in the creation of task_mqtt_shell.\n");
		return 1;
	}
	ObjID[TASK_MQTT_SHELL] = objid;
	tm_putstring("*** task_mqtt_shell created.\n");

	while ( 1 ) {
		tk_sta_tsk( ObjID[TASK_MQTT_SHELL], 0 );
		tk_slp_tsk( TMO_FEVR );
	}
}
