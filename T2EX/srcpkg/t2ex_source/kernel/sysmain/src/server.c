#include <tk/tkernel.h>
#include <t2ex/socket.h>
#include <t2ex/errno.h>

#include "network_sample/util.h"

LOCAL ID server_tskid;

LOCAL void wait_data(int sd) {
	int re;
	fd_set fdset;

	FD_ZERO(&fdset);
	FD_SET(sd, &fdset);

	re = so_select(sd+1, &fdset, NULL, NULL, NULL);
	DEBUG_PRINT(("wait_data: so_select = %d(%d, %d)\n", re, MERCD(re), SERCD(re)));
}

LOCAL void test_tcp_server(void) {
	int re;
	int sd;
	int reader = 0;
	char buf[5];
	struct sockaddr_in sa;
	struct sockaddr_in sa2;
	socklen_t sa_len;

	printf("[tcp(server)] start\n");

	sd = so_socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
	if ( sd < 0 ) {
		goto error;
	}
	DEBUG_PRINT(("server_task: so_socket = %d(%d, %d)\n", sd, MERCD(sd), SERCD(sd)));

	bzero(&sa, sizeof sa);
	sa.sin_family = AF_INET;
	sa.sin_addr.s_addr = htonl(INADDR_ANY);
	sa.sin_port = htons(12345);
	re = so_bind(sd, (struct sockaddr*)&sa, sizeof sa);
	DEBUG_PRINT(("server_task: so_bind = %d(%d, %d)\n", re, MERCD(re), SERCD(re)));
	if ( re < 0 ) {
		goto error;
	}

	re = so_listen(sd, 5);
	DEBUG_PRINT(("server_task: so_listen = %d(%d, %d)\n", re, MERCD(re), SERCD(re)));
	if ( re < 0 ) {
		goto error;
	}

	DEBUG_PRINT(("server_task: server semaphore signaled 1\n"));

	reader = so_accept(sd, (struct sockaddr*)&sa2, &sa_len);
	DEBUG_PRINT(("server_task: so_accept = %d(%d, %d)\n", reader, MERCD(reader), SERCD(reader)));
	if ( reader < 0 ) {
		goto error;
	}

	wait_data(reader);

	bzero(buf, sizeof buf);
	re = so_sockatmark(reader);
	DEBUG_PRINT(("server_task: so_sockatmark = %d(%d, %d)\n", re, MERCD(re), SERCD(re)));
	if ( re < 0 ) {
		goto error;
	}
	re = so_read(reader, buf, 4);
	DEBUG_PRINT(("server_task: so_read = %d(%d, %d), buf = %s\n", re, MERCD(re), SERCD(re), buf));
	if ( re < 0 || memcmp(buf, "1234", 4) != 0 ) {
		goto error;
	}

	wait_data(reader);

	bzero(buf, sizeof buf);
	re = so_sockatmark(reader);
	DEBUG_PRINT(("server_task: so_sockatmark = %d(%d, %d)\n", re, MERCD(re), SERCD(re)));
	if ( re < 0 ) {
		goto error;
	}
	re = so_recv(reader, buf, 4, MSG_OOB);
	DEBUG_PRINT(("server_task: so_recv = %d(%d, %d), buf = %s\n", re, MERCD(re), SERCD(re), buf));
	if ( re < 0 || buf[0] != 'a' ) {
		goto error;
	}

	DEBUG_PRINT(("server_task: pre-accept for break\n"));
	re = so_accept(sd, (struct sockaddr*)&sa2, &sa_len);
	DEBUG_PRINT(("server_task: so_accept = %d(%d, %d)\n", re, MERCD(re), SERCD(re)));
	if ( re != EX_INTR ) {
		goto error;
	}

	so_close(reader);
	so_close(sd);

	printf("[tcp(server)] OK\n");
	return;

error:
	printf("[tcp(server)] FAILED\n");
	if ( sd > 0 ) {
		so_close(sd);
	}
	if ( reader > 0 ) {
		so_close(reader);
	}
	return;
}

LOCAL void server_task(INT stacd, VP exinf) {
	DEBUG_PRINT(("server task started\n"));

	test_tcp_server();
    
	tk_exd_tsk();
}

EXPORT void server(void) {
    net_conf(NET_CONF_EMULATOR, NET_CONF_DHCP);
	net_show();
	T_CTSK ctsk;
	ctsk.tskatr = TA_HLNG | TA_RNG0;
	ctsk.task = server_task;
	ctsk.itskpri = 100;
	ctsk.stksz = 32 * 1024 * 2;
	server_tskid = tk_cre_tsk(&ctsk);
	DEBUG_PRINT(("start server task %d\n", server_tskid));
	tk_sta_tsk(server_tskid, 0);
}