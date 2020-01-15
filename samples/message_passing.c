#include <tk/tkernel.h>
#include <tm/tmonitor.h>
#include <libstr.h>

EXPORT void tsk_a(INT stacd, VP exinf);
EXPORT void tsk_b(INT stacd, VP exinf);
typedef enum { TSK_A, TSK_B, MBUF_A, MBUF_B, OBJ_KIND_NUM } OBJ_KIND;
EXPORT ID ObjID[OBJ_KIND_NUM];
EXPORT void tsk_a(INT stacd, VP exinf) {
    UB line;
	while ( 1 ) {
        tm_putstring("task a send message: ");
        int l = tm_getline(&line);
        tk_snd_mbf(ObjID[MBUF_B], &line, l, TMO_FEVR);
        tk_rcv_mbf(ObjID[MBUF_A], &line, TMO_FEVR);
        tm_putstring("task a receive message: ");
        tm_putstring(&line);
        tm_putstring("\n");
    }
	tk_ext_tsk();
}
EXPORT void tsk_b(INT stacd, VP exinf) {
    UB line;
	while ( 1 ) {
        tk_rcv_mbf(ObjID[MBUF_B], &line, TMO_FEVR);
        tm_putstring("task b receive message: ");
        tm_putstring(&line);
        tm_putstring("\n");
        tm_putstring("task b send message: ");
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

	t_ctsk.task = tsk_a;
	t_ctsk.itskpri = 5;
	STRCPY( (char *)t_ctsk.dsname, "tsk_a");
	if ( (objid = tk_cre_tsk( &t_ctsk )) <= E_OK ) {
		tm_putstring(" *** Failed in the creation of tsk_a.\n");
		return 1;
	}
	ObjID[TSK_A] = objid;
	tm_putstring("*** tsk_a created.\n");

	t_ctsk.task = tsk_b;
	STRCPY( (char *)t_ctsk.dsname, "tsk_b");
	if ( (objid = tk_cre_tsk( &t_ctsk )) <= E_OK ) {
		tm_putstring(" *** Failed in the creation of tsk_b.\n");
		return 1;
	}
	ObjID[TSK_B] = objid;
	tm_putstring("*** tsk_b created.\n");

    T_CMBF cmbf = { NULL, TA_TFIFO, 256, 4, "global message queue" };
	if ( (objid = tk_cre_mbf( &cmbf )) <= E_OK ) {
		tm_putstring(" *** Failed in the creation of message box a.\n");
		return 1;
	}
	ObjID[MBUF_A] = objid;
	tm_putstring("*** message box a created.\n");
	if ( (objid = tk_cre_mbf( &cmbf )) <= E_OK ) {
		tm_putstring(" *** Failed in the creation of message box b.\n");
		return 1;
	}
	ObjID[MBUF_B] = objid;
	tm_putstring("*** message box b created.\n");

	tk_chg_pri(tk_get_tid(), 1);

	if ( tk_sta_tsk( ObjID[TSK_A], 0 ) != E_OK ) {
		tm_putstring(" *** Failed in start of tsk_a.\n");
		return 1;
	}
	if ( tk_sta_tsk( ObjID[TSK_B], 0 ) != E_OK ) {
		tm_putstring(" *** Failed in start of tsk_b.\n");
		return 1;
	}

    tk_slp_tsk(TMO_FEVR);
}
