#include <tk/tkernel.h>
#include <tm/tmonitor.h>
#include <libstr.h>

EXPORT void tsk_a(INT stacd, VP exinf);
EXPORT void tsk_b(INT stacd, VP exinf);
typedef enum { TASK_A, MBUF_A, TASK_B, MBUF_B, OBJ_KIND_NUM } OBJ_KIND;
EXPORT ID ObjID[OBJ_KIND_NUM];
EXPORT void task_a(INT stacd, VP exinf) {
    UB line;
	while ( 1 ) {
        tm_putstring("task_a send message: ");
        int l = tm_getline(&line);
        tk_snd_mbf(ObjID[MBUF_B], &line, l, TMO_FEVR);
        tk_rcv_mbf(ObjID[MBUF_A], &line, TMO_FEVR);
        tm_putstring("task_a receive message: ");
        tm_putstring(&line);
        tm_putstring("\n");
    }
	tk_ext_tsk();
}
EXPORT void task_b(INT stacd, VP exinf) {
    UB line;
	while ( 1 ) {
        tk_rcv_mbf(ObjID[MBUF_B], &line, TMO_FEVR);
        tm_putstring("task_b receive message: ");
        tm_putstring(&line);
        tm_putstring("\n");
        tm_putstring("task_b send message: ");
        int l = tm_getline(&line);
        tk_snd_mbf(ObjID[MBUF_A], &line, l, TMO_FEVR);
	}
    tk_ext_tsk();
}

EXPORT	INT	usermain( void ) {
	T_CTSK t_ctsk;
	ID objid;
	t_ctsk.tskatr = TA_HLNG | TA_DSNAME;
	t_ctsk.stksz = 1024;

	t_ctsk.task = task_a;
	t_ctsk.itskpri = 5;
	STRCPY( (char *)t_ctsk.dsname, "task_a");
	if ( (objid = tk_cre_tsk( &t_ctsk )) <= E_OK ) {
		tm_putstring(" *** Failed in the creation of tsak_a.\n");
		return 1;
	}
	ObjID[TASK_A] = objid;
	tm_putstring("*** task_a created.\n");

    T_CMBF cmbf = { NULL, TA_TFIFO, 256, 4 };
	if ( (objid = tk_cre_mbf( &cmbf )) <= E_OK ) {
		tm_putstring(" *** Failed in the creation of message box a.\n");
		return 1;
	}
	ObjID[MBUF_A] = objid;
	tm_putstring("*** message box a created.\n");

	t_ctsk.task = task_b;
	STRCPY( (char *)t_ctsk.dsname, "task_b");
	if ( (objid = tk_cre_tsk( &t_ctsk )) <= E_OK ) {
		tm_putstring(" *** Failed in the creation of task_b.\n");
		return 1;
	}
	ObjID[TASK_B] = objid;
	tm_putstring("*** task_b created.\n");

	if ( (objid = tk_cre_mbf( &cmbf )) <= E_OK ) {
		tm_putstring(" *** Failed in the creation of message box b.\n");
		return 1;
	}
	ObjID[MBUF_B] = objid;
	tm_putstring("*** message box b created.\n");

	if ( tk_sta_tsk( ObjID[TASK_A], 0 ) != E_OK ) {
		tm_putstring(" *** Failed in start of tsk_a.\n");
		return 1;
	}
	if ( tk_sta_tsk( ObjID[TASK_B], 0 ) != E_OK ) {
		tm_putstring(" *** Failed in start of tsk_b.\n");
		return 1;
	}

    tk_slp_tsk(TMO_FEVR);
}
