/*
 *----------------------------------------------------------------------
 *    T-Kernel 2.0 Software Package
 *
 *    Copyright 2011 by Ken Sakamura.
 *    This software is distributed under the latest version of T-License 2.x.
 *----------------------------------------------------------------------
 *
 *    Released by T-Engine Forum(http://www.t-engine.org/) at 2011/05/17.
 *    Modified by TRON Forum(http://www.tron.org/) at 2015/06/01.
 *
 *----------------------------------------------------------------------
 */

/*
 *	T-Kernel SVC interface library (em1d)
 *
 *	   (generated automatically)
 */

#include <machine.h>
#include <tk/sysdef.h>
#include <sys/svc/tdfncd.h>

	.text
	.balign	4
	.globl	Csym(td_get_tim_u)
	.type	Csym(td_get_tim_u), %function
Csym(td_get_tim_u):
	stmfd	sp!, {lr}
	ldr	ip, =TDFN_GET_TIM_U
	swi	SWI_DEBUG
	ldmfd	sp!, {lr}
	bx	lr

