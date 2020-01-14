#include <tk/tkernel.h>
#include <tm/tmonitor.h>
#include <libstr.h>
#include "wolfmqtt/mqtt_client.h"
#include "examples/mqttnet.h"
#include "examples/mqttclient/mqttclient.h"

#define NET_CONF_EMULATOR (1)
#define NET_CONF_DHCP   (1)

typedef enum { TASK_MQTT_SHELL, OBJ_KIND_NUM } OBJ_KIND;
EXPORT ID ObjID[OBJ_KIND_NUM];

ID parent_id;

char line[16];

EXPORT void task_mqtt_shell(INT stacd, VP exinf);
EXPORT void task_mqtt_shell(INT stacd, VP exinf) {
	MQTTCtx mqttCtx;
	mqtt_init_ctx(&mqttCtx);
	mqttCtx.app_name = "mqtt_client";
	mqttCtx.host = "test.mosquitto.org";
	mqttCtx.port = 1883;
	mqttCtx.qos = 1;
	int rc;

	while ( 1 ) {
		tm_putstring("- Push c to connect.\n");
		tm_putstring("- Push p to publish a message.\n");
		tm_putstring("- Push w to wait messages.\n");
		tm_putstring("- Push s to subscribe to a topic.\n");
		tm_putstring("- Push k to keep connection.");
		char c = tm_getchar(-1);
		tm_putstring("\n");
		if (c == 'p') {
			tm_putstring("topic: ");
			tm_getline(line);
			mqttCtx.topic_name = line;
			tm_putstring("message: ");
			tm_getline(line);
			mqttCtx.publish.buffer = line;
			rc = mqttclient_publish(&mqttCtx);
		} else if (c == 's') {
			tm_putstring("topic: ");
			tm_getline(line);
			mqttCtx.topic_name = line;
			rc = mqttclient_subscribe(&mqttCtx);
		} else if (c == 'w') {
			rc = mqttclient_wait(&mqttCtx);
		} else if (c == 'k') {
			rc = mqttclient_ping(&mqttCtx);
		} else if (c == 'c') {
			rc = mqttclient_connect(&mqttCtx);
		}
		
		if (rc != MQTT_CODE_SUCCESS) {
			break;
		}
	}
	tm_putstring(" *** MQTT shell: error occured.\n");
	tk_wup_tsk(parent_id);
	tk_ext_tsk();
}

EXPORT INT usermain( void ) {
	T_CTSK t_ctsk;
	ID objid;
	t_ctsk.tskatr = TA_HLNG | TA_DSNAME;

	t_ctsk.stksz = 1024;
	t_ctsk.itskpri = 0;
	parent_id = tk_get_tid();

	// Network initialization
	NetDrv(0, NULL);
	so_main(0, NULL);
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
		tm_putstring(" *** MQTT shell disconnected... Reseted context.\n");
	}
}
