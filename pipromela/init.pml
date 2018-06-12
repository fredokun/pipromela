
/*******************************************
** PiPromela                              **
**                                        **
** Copyright (C) 2018 Frederic Peschanski **
**               MIT License              **
*******************************************/

/* This is the initialization of the name registry.
 * This file must be included somewhere in the
 * `init` definition.
 */

// initialization of name registry
NameId i;
for(i : 0 .. MAX_NAMES) {
    names[i].kind =  UNUSED;
    names[i].eqid = i;
    names[i].clock = 0;
}

