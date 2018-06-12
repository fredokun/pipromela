
/*******************************************
** PiPromela                              **
**                                        **
** Copyright (C) 2018 Frederic Peschanski **
**               MIT License              **
*******************************************/

/**************************************************
 * This is an example of a name generator process *
 * In a pi-calculus syntax it would be a process  *
 * P of the following form:                       *
 *                                                *
 *  P = new(a) { c!a.tau.P }                      *
 *                                                *
 **************************************************/

// We need at most 2 active names
#define MAX_NAMES 2

/* The pipromela header */
#include "../pipromela/header.pml"

// static names
#define c_name 1

// private names
#define nu_a_name 2

/* The pipromela observer */
#include "../pipromela/observer.pml"

proctype P() {
loop:
  // c!a    (with a restricted)
  SEND(c_name, nu_a_name);

  // silent action
  TAU();

  // no need for the name a anymore
  GC(nu_a_name);

  goto loop
}


init {

/* The initialization of the name registry */
#include "../pipromela/init.pml"
  
  // static names
  names[c_name].kind = STATIC;

  // private names
  names[nu_a_name].kind = PRIVATE;

  // run processes
  atomic {
    run P();
    run Observer();
  }
}

// to run the process (never ends):
// spin generator.pml

// deadlock detection:
// spin -run -safety -n generator.pml

// example of ltl property
ltl always_send {
  []<>(SendingChan == c_name)
}
// check with:
// spin -run -ltl always_send -n generator.pml

