#include <tk/tkernel.h>
#include <tm/tmonitor.h>
#include <libstr.h>

EXPORT void tsk_a(INT stacd, VP exinf);
EXPORT void tsk_b(INT stacd, VP exinf);
typedef enum { TSK_A, TSK_B, OBJ_KIND_NUM } OBJ_KIND;
EXPORT ID ObjID[OBJ_KIND_NUM];
EXPORT void tsk_a(INT stacd, VP exinf) {
	int i;
	for ( i = 0; i < 3; i++ ) {
		tm_putstring("*** tk_wup_tsk to tsk_b.\n");
		if ( tk_wup_tsk( ObjID[TSK_B] ) != E_OK )
			tm_putstring(" *** Failed in tk_wup_tsk to tsk_b\n");
	}
	tk_ext_tsk();
}
EXPORT void tsk_b(INT stacd, VP exinf) {
	tm_putstring("*** tsk_b started.\n");
	while ( 1 ) {
		tm_putstring("*** tsk_b is Waiting\n");
		tk_slp_tsk( TMO_FEVR );
		tm_putstring("*** tsk_b was Triggered\n");
	}
}

EXPORT	INT	usermain( void ) {
	T_CTSK t_ctsk;
	ID objid;
	t_ctsk.tskatr = TA_HLNG | TA_DSNAME;
	t_ctsk.stksz = 1024;

	t_ctsk.task = tsk_a;
	t_ctsk.itskpri = 1;
	STRCPY( (char *)t_ctsk.dsname, "tsk_a");
	if ( (objid = tk_cre_tsk( &t_ctsk )) <= E_OK ) {
		tm_putstring(" *** Failed in the creation of tsk_a.\n");
		return 1;
	}
	ObjID[TSK_A] = objid;
	tm_putstring("*** tsk_a created.\n");

	t_ctsk.task = tsk_b;
	t_ctsk.itskpri = 2;
	STRCPY( (char *)t_ctsk.dsname, "tsk_b");
	if ( (objid = tk_cre_tsk( &t_ctsk )) <= E_OK ) {
		tm_putstring(" *** Failed in the creation of tsk_b.\n");
		return 1;
	}
	ObjID[TSK_B] = objid;
	tm_putstring("*** tsk_b created.\n");

	if ( tk_sta_tsk( ObjID[TSK_B], 0 ) != E_OK ) {
		tm_putstring(" *** Failed in start of tsk_b.\n");
		return 1;
	}
	tm_putstring("*** tsk_b started.\n");

	while(1) {
		tm_putstring((UB*)"Push any key to start tsk_a. ");
		tm_getchar(-1);
		tm_putstring("\n");
		tk_sta_tsk( ObjID[TSK_A], 0 );
	}
}
