#include <tk/tkernel.h>
#include <tm/tmonitor.h>
#include <libstr.h>
#include "wolfmqtt/mqtt_client.h"
#include "examples/mqttnet.h"
#include "examples/mqttclient/mqttclient.h"

char line[16];

typedef enum { TASK_MQTT_SHELL, OBJ_KIND_NUM } OBJ_KIND;
EXPORT ID ObjID[OBJ_KIND_NUM];

EXPORT void task_mqtt_shell(INT stacd, VP exinf);
EXPORT void task_mqtt_shell(INT stacd, VP exinf) {
	MQTTCtx client;
	mqtt_init_ctx(&client);
	client.host = "test.mosquitto.org";
	client.port = 1883;
	client.qos = 1;
	int result = MQTT_CODE_SUCCESS;
	while ( 1 ) {
		tm_putstring("- Push c to connect.\n");
		tm_putstring("- Push p to publish a message.\n");
		tm_putstring("- Push s to subscribe to a topic.\n");
		tm_putstring("- Push w to wait messages.\n");
		tm_putstring("- Push k to keep connection.");
		char c = tm_getchar(TMO_FEVR);
		tm_putstring("\n");
		if ( c == 'c' ) {
			result = mqttclient_connect(&client);
		}
		if ( c == 'p' ) {
			tm_putstring("topic: ");
			tm_getline(line);
			char topic[sizeof line];
			strncpy(topic, line, sizeof line);
			topic[sizeof line - 1] = '\0';
			client.topic_name = topic;
			tm_putstring("message: ");
			tm_getline(line);
			char message[sizeof line];
			strncpy(message, line, sizeof line);
			message[sizeof line - 1] = '\0';
			client.publish.buffer = message;
			result = mqttclient_publish(&client);
		}
		if ( c == 's' ) {
			tm_putstring("topic: ");
			tm_getline(line);
			char topic[sizeof line];
			strncpy(topic, line, sizeof line);
			topic[sizeof line - 1] = '\0';
			client.topic_name = topic;
			result = mqttclient_subscribe(&client);
		}
		if ( c == 'w' ) {
			result = mqttclient_wait(&client);
		}
		if ( c == 'k' ) {
			result = mqttclient_ping(&client);
		}
		if ( result != MQTT_CODE_SUCCESS ) {
			break;
		}
	}
	tm_putstring(" *** MQTT shell: error occured.\n");
	tk_wup_tsk( 1 );
	tk_ext_tsk();
}

EXPORT INT usermain( void ) {
	T_CTSK t_ctsk;
	ID objid;
	t_ctsk.tskatr = TA_HLNG | TA_DSNAME;

	// Network initialization
	#define NET_CONF_EMULATOR (1)
	#define NET_CONF_DHCP   (1)
	NetDrv(0, NULL);
	so_main(0, NULL);
	net_conf(NET_CONF_EMULATOR, NET_CONF_DHCP);

	t_ctsk.stksz = 1024;
	t_ctsk.itskpri = 1;
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
