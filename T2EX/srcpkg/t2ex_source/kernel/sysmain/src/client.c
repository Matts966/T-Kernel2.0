#include <tk/tkernel.h>
#include <t2ex/socket.h>
#include <t2ex/errno.h>

#include "network_sample/util.h"

LOCAL ID client_tskid;


LOCAL void test_tcp_client(void) {
	int sd;
	int re;
	struct sockaddr_in sa;

	printf("[tcp(client)] start\n");

	sd = so_socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
	DEBUG_PRINT(("so_socket = %d(%d, %d)\n", sd, MERCD(sd), SERCD(sd)));
	if ( sd < 0 ) {
		goto error2;
	}

	bzero(&sa, sizeof sa);
	sa.sin_family = AF_INET;
	sa.sin_addr.s_addr = htonl(INADDR_LOOPBACK);
	sa.sin_port = htons(12345);
	re = so_connect(sd, (struct sockaddr*)&sa, sizeof sa);
	printf("so_connect = %d(%d, %d)\n", re, MERCD(re), SERCD(re));
	if ( re < 0 ) {
		goto error2;
	}

	re = so_write(sd, "1234", 4);
	DEBUG_PRINT(("so_write = %d(%d, %d)\n", re, MERCD(re), SERCD(re)));
	if ( re < 0 ) {
		goto error2;
	}

	re = so_send(sd, "a", 1, MSG_OOB);
	DEBUG_PRINT(("so_send = %d(%d, %d)\n", re, MERCD(re), SERCD(re)));
	if ( re < 0 ) {
		goto error2;
	}

	so_close(sd);

	printf("[tcp(client)] OK\n");
	return;

error2:
	if ( sd > 0 ) {
		so_close(sd);
	}
	printf("[tcp(client)] FAILED\n");
}

LOCAL void client_task(INT stacd, VP exinf) {
	DEBUG_PRINT(("client task started\n"));

	test_tcp_client();

	tk_exd_tsk();
}

EXPORT void client(void) {
	T_CTSK ctsk;
	ctsk.tskatr = TA_HLNG | TA_RNG0;
	ctsk.task = client_task;
	ctsk.itskpri = 101;
	ctsk.stksz = 4 * 1024 * 2;
	client_tskid = tk_cre_tsk(&ctsk);
	DEBUG_PRINT(("start client task %d\n", client_tskid));
	tk_sta_tsk(client_tskid, 0);
}
