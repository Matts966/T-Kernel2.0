#include <tk/tkernel.h>
#include <tm/tmonitor.h>
#include <libstr.h>

typedef enum { TASK_A, TASK_B, OBJ_KIND_NUM } OBJ_KIND;
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
	while ( 1 ) {
		tm_putstring((UB*)"Push any key to start task_a. ");
		tm_getchar(-1);
		tm_putstring("\n");
		tk_sta_tsk( ObjID[TASK_A], 0 );
	}
}
