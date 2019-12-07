#include <tk/tkernel.h>
#include <tm/tmonitor.h>
#include <libstr.h>
#include "wolfmqtt/mqtt_client.h"
#include "examples/mqttnet.h"
#include "examples/nbclient/nbclient.h"
#include "network_sample/net_test.h"

typedef enum { TASK_A, TASK_B, TASK_MQTT, OBJ_KIND_NUM } OBJ_KIND;
EXPORT ID ObjID[OBJ_KIND_NUM];

EXPORT void task_a(INT stacd, VP exinf);
EXPORT void task_a(INT stacd, VP exinf) {
	for ( int i = 0; i < 3; i++ ) {
		tm_putstring("*** tk_wup_tsk to task_b.\n");
		if ( tk_wup_tsk( ObjID[TASK_B] ) != E_OK )
			tm_putstring(" *** Failed in tk_wup_tsk to task_b\n");
	}
	tk_ext_tsk();
}

EXPORT void task_b(INT stacd, VP exinf);
EXPORT void task_b(INT stacd, VP exinf) {
	tm_putstring("*** task_b started.\n");
	while ( 1 ) {
		tm_putstring("*** task_b is Waiting\n");
		tk_slp_tsk( TMO_FEVR );
		tm_putstring("*** task_b was Triggered\n");
	}
	tk_ext_tsk();
}

EXPORT void task_mqtt(INT stacd, VP exinf) {
	MQTTCtx mqttCtx;
	mqtt_init_ctx(&mqttCtx);
	mqttCtx.app_name = "nbclient";
	mqttCtx.host = "test.mosquitto.org";
	mqttCtx.port = (word16)XATOI("1883");
	mqttCtx.cmd_timeout_ms = XATOI("1000");
	mqttCtx.qos = (MqttQoS)((byte)XATOI("0"));
	mqttCtx.test_mode = 1;
	int rc;
	tm_putstring("runMQTT\n");
	do {
		tm_putstring("mqttclient_test\n");
		rc = mqttclient_test(&mqttCtx);
		tm_printf("client: %d, net: %d, connect: %d\n",
			&mqttCtx.client == NULL, (&mqttCtx.client)->net == NULL,
			(&mqttCtx.client)->net->connect == NULL);
	} while (rc == MQTT_CODE_CONTINUE);
	tm_putstring("exit task_mqtt, cause: %s\n",
		MqttClient_ReturnCodeToString(rc))
	tk_ext_tsk();
}

EXPORT INT usermain( void ) {
	T_CTSK t_ctsk;
	ID objid;
	t_ctsk.tskatr = TA_HLNG | TA_DSNAME;

	t_ctsk.stksz = 1024;
	t_ctsk.itskpri = 1;
	STRCPY( (char *)t_ctsk.dsname, "task_a");
	t_ctsk.task = task_a;
	if ( (objid = tk_cre_tsk( &t_ctsk )) <= E_OK ) {
		tm_putstring(" *** Failed in the creation of task_a.\n");
		return 1;
	}
	ObjID[TASK_A] = objid;
	tm_putstring("*** task_a created.\n");

	t_ctsk.itskpri = 2;
	t_ctsk.stksz = 1024;
	STRCPY( (char *)t_ctsk.dsname, "task_b");
	t_ctsk.task = task_b;
	if ( (objid = tk_cre_tsk( &t_ctsk )) <= E_OK ) {
		tm_putstring(" *** Failed in the creation of task_b.\n");
		return 1;
	}
	ObjID[TASK_B] = objid;
	tm_putstring("*** task_b created.\n");
	if ( tk_sta_tsk( ObjID[TASK_B], 0 ) != E_OK ) {
		tm_putstring(" *** Failed in start of task_b.\n");
		return 1;
	}
	tm_putstring("*** task_b started.\n");

	/* Start the device drivers */
	ER	err;
#ifdef DRV_CONSOLE
	err = ConsoleIO(0, NULL);
	tm_putstring(err >= E_OK ? "ConsoleIO - OK\n" : "ConsoleIO - ERR\n");
#endif
#ifdef DRV_CLOCK
	err = ClockDrv(0, NULL);
	tm_putstring(err >= E_OK ? "ClockDrv - OK\n" : "ClockDrv - ERR\n");
#endif
#ifdef DRV_SYSDISK
	err = SysDiskDrv(0, NULL);
	tm_putstring(err >= E_OK ? "SysDiskDrv - OK\n" : "SysDiskDrv - ERR\n");
#endif
#ifdef DRV_SCREEN
	err = ScreenDrv(0, NULL);
	tm_putstring(err >= E_OK ? "ScreenDrv - OK\n" : "ScreenDrv - ERR\n");
#endif
#ifdef DRV_KBPD
	err = KbPdDrv(0, NULL);
	tm_putstring(err >= E_OK ? "KbPdDrv - OK\n" : "KbPdDrv - ERR\n");
#endif
#ifdef DRV_LOWKBPD
	err = LowKbPdDrv(0, NULL);
	tm_putstring(err >= E_OK ? "LowKbPdDrv - OK\n" : "LowKbPdDrv - ERR\n");
#endif
#ifdef DRV_NET
	err = NetDrv(0, NULL);
	tm_putstring(err >= E_OK ? "NetDrv - OK\n" : "NetDrv - ERR\n");
#endif
	/* Start the T2EX extension modules */
#ifdef	USE_T2EX_DT
	err = dt_main(0, NULL);
	tm_putstring(err >= E_OK ? "dt_main(0) - OK\n":"dt_main(0) - ERR\n");
#endif
#ifdef	USE_T2EX_PM
	err = pm_main(0, NULL);
	tm_putstring(err >= E_OK ? "pm_main(0) - OK\n":"pm_main(0) - ERR\n");
#endif
#ifdef	USE_T2EX_FS
	err = fs_main(0, NULL);
	tm_putstring(err >= E_OK ? "fs_main(0) - OK\n":"fs_main(0) - ERR\n");
#endif
#ifdef	USE_T2EX_NET
	err = so_main(0, NULL);
	tm_putstring(err >= E_OK ? "so_main(0) - OK\n":"so_main(0) - ERR\n");
#endif
	libc_stdio_init();
	// Network initialization and test
	net_test();

	t_ctsk.itskpri = 1;
	t_ctsk.stksz = 1024;
	STRCPY( (char *)t_ctsk.dsname, "task_mqtt");
	t_ctsk.task = task_mqtt;
	if ( (objid = tk_cre_tsk( &t_ctsk )) <= E_OK ) {
		tm_putstring(" *** Failed in the creation of task_mqtt.\n");
		return 1;
	}
	ObjID[TASK_MQTT] = objid;
	tm_putstring("*** task_mqtt created.\n");

	while ( 1 ) {
		tm_putstring((UB*)"Push a to start task_a, m to start task_mqtt. ");
		char c = tm_getchar(-1);
		tm_putstring("\n");
		if (c == 'a') {
			tk_sta_tsk( ObjID[TASK_A], 0 );
		} else if (c == 'm') {
			tk_sta_tsk( ObjID[TASK_MQTT], 0 );
		}
	}
}
