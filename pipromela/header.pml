/*******************************************
** PiPromela                              **
**                                        **
** Copyright (C) 2018 Frederic Peschanski **
**               MIT License              **
*******************************************/

/* The header part of the PiPromela library
 * This file must be included at the beginning
 * of the model.
 *
 * Important: the MAX_NAMES constant must be fixed first
 */

#define NameId byte

mtype { STATIC, PRIVATE, OUTPUT, INPUT, UNUSED };

#define NameKind mtype

typedef Name {
  NameKind kind;  // the kind of the name
  byte clock;     // for read/write causality
  NameId eqid;    // an id of an equivalent name (singleton if eqid=id)
}

Name names[MAX_NAMES+1];

#define NO_NAME 0  // the id of the "not a name"

byte SenderPid = 0;
NameId SendingChan = NO_NAME;
NameId SendingData = NO_NAME;
byte ReceiverPid = 0;
NameId ReceivingChan = NO_NAME;
NameId ReceivingData = NO_NAME;
bool Tau = false;
byte TauPid  = 0;

NameId MatchNameLeft = NO_NAME;
NameId MatchNameRight = NO_NAME;
bool Match = false;
byte MatchPid = 0;

byte Clock = 1;


inline synchronize_clock() {
  Clock = 1;
  NameId id;
  for(id:  1 .. MAX_NAMES) {
  if
  :: names[id].clock >= Clock -> Clock = names[id].clock + 1
  :: else ->
  fi
  }
}

inline GC(name) {
atomic {
  // first, cleanup all refeferences to this name
  NameId id_gc;
  for(id_gc: 1 .. MAX_NAMES) {
    if
    ::names[id_gc].eqid == name && names[name].eqid != name -> names[id_gc].eqid = names[name].eqid
    ::names[id_gc].eqid == name && names[name].eqid == name -> names[id_gc].eqid = id_gc
    :: else -> // do nothing
    fi
  }
  // second, "remove" the name
  if
  :: names[name].kind == OUTPUT -> names[name].kind = PRIVATE;
                                   names[name].clock = 0;
				   names[name].eqid = name;
  :: names[name].kind == INPUT -> names[name].kind = UNUSED;
                                  names[name].clock = 0;
				  names[name].eqid = name;
  fi
  synchronize_clock();
}
}

inline find_input() {
  NameId id;
  for(id:  1 .. MAX_NAMES) {
    if
    ::(ReceivingData == NO_NAME && names[id].kind == UNUSED)
       -> ReceivingData = id;
    ::else ->
    fi
  }
}

inline bound_output(priv_name) {
  names[priv_name].kind = OUTPUT;
  names[priv_name].clock = Clock;
  Clock++;
}


// follow a name until its cannonical representant
inline canonical_name(canon, name) {
  canon = name;
  do
  ::names[canon].eqid == canon -> break;
  ::else -> canon = names[canon].eqid
  od
}

// check if the two (canonical) names can be matched
#define MATCHABLE(a,b) \
   (a == b) \
|| (names[a].kind == STATIC && (names[b].kind == STATIC || names[b].kind == INPUT)) \
|| (names[a].kind == INPUT && (names[b].kind == STATIC || names[b].kind == INPUT \
                               || (names[b].kind == OUTPUT && names[b].clock <= names[a].clock))) \
|| (names[a].kind == OUTPUT && (names[b].kind == INPUT && names[a].clock <= names[b].clock))

inline perform_match(a,b) {
  if
  :: a == b -> // nothing to do
  :: names[a].kind == STATIC && names[b].kind == STATIC
     -> if
        :: a <= b -> names[b].eqid = a
	:: else -> names[a].eqid = b
	fi
  :: names[a].kind == STATIC && names[b].kind == INPUT
     -> names[b].eqid = a ; names[b].clock = 0
  :: names[a].kind == INPUT && names[b].kind == STATIC
     -> names[a].eqid = b ; names[a].clock = 0
  :: names[a].kind == INPUT && names[b].kind == INPUT
     -> if // we must keep the smallest clock  (to ensure causality)
        :: names[a].clock <= names[b].clock -> names[b].eqid = a ; names[b].clock = names[a].clock
	:: else ->names[a].eqid = b ; names[a].clock = names[b].clock
        fi
  :: names[a].kind == INPUT && names[b].kind == OUTPUT
     -> names[a].eqid = b ; names[a].clock = names[b].clock
  :: names[a].kind == OUTPUT && names[b].kind == INPUT
     -> names[b].eqid = a ; names[b].clock = names[a].clock
  fi
  synchronize_clock(); // we potentially modified the clock
}

inline RECEIVE(channel, var) {
  atomic {
   ReceivingChan == NO_NAME && ReceivingData == NO_NAME;
   ReceiverPid = _pid;
   canonical_name(ReceivingChan, channel);
   ReceivingData != NO_NAME;
   var = ReceivingData;
   names[var].kind = INPUT;
   names[var].clock = Clock - 1;
   ReceivingData = NO_NAME;
   ReceivingChan == NO_NAME;
  }
}

inline SEND(channel, data) {
  atomic {
    SendingChan == NO_NAME && SendingData == NO_NAME;
    SenderPid = _pid;
    canonical_name(SendingChan, channel);
    SendingData = data;
    SendingChan == NO_NAME;
  }
}

inline TAU() {
  atomic {
    Tau == false;
    TauPid = _pid;
    Tau = true;
    Tau == false;
  }
}

inline MATCH(a, b) {
  atomic {
    Match == false && MatchNameLeft == NO_NAME && MatchNameRight == NO_NAME;
    MatchPid = _pid;
    canonical_name(MatchNameLeft, a);
    canonical_name(MatchNameRight, b);
    Match = true;
    Match == false;
  }
}
