/*******************************************
** PiPromela                              **
**                                        **
** Copyright (C) 2018 Frederic Peschanski **
**               MIT License              **
*******************************************/

/* This is the definition of the pi-calculus
 * observer process.
 * This file must be included somewhere in the
 * process definitions part, before the initialization.
 */

proctype Observer() {
endOk:
  do
  // silent step
  :: atomic{ (Tau == true) -> printf("[%d] tau\n", TauPid); Tau = false }
  // public output
  :: atomic { (SendingChan != NO_NAME
         && SendingData != NO_NAME
         && names[SendingChan].kind != PRIVATE
         && names[SendingData].kind != PRIVATE)
	     -> 
	          printf("[%d] output: %d!%d\n", SenderPid, SendingChan, SendingData);	        
		  SendingChan = NO_NAME;
		  SendingData = NO_NAME;
		}
  // bound (private) output
  :: atomic { (SendingChan != NO_NAME
         && SendingData != NO_NAME
         && names[SendingChan].kind != PRIVATE
         && names[SendingData].kind == PRIVATE)
	     ->  bound_output(SendingData);
	         printf("[%d] bound output: %d!(%d)\n", SenderPid, SendingChan, SendingData);	        
		 SendingChan = NO_NAME;
		 SendingData = NO_NAME;
	     }
  // public input
  :: atomic { (ReceivingChan != NO_NAME
       && names[ReceivingChan].kind != PRIVATE)
       ->
            find_input();
	    assert(ReceivingData != NO_NAME);
            printf("[%d] input: %d?%d\n", ReceiverPid, ReceivingChan, ReceivingData);	 
	    ReceivingData == NO_NAME;
	    ReceivingChan = NO_NAME;
	  }
  // synchro
  :: atomic {(SendingChan != NO_NAME
              && ReceivingChan != NO_NAME
              && MATCHABLE(SendingChan, ReceivingChan))
      -> perform_match(SendingChan, ReceivingChan);
         printf("[%d->%d] sync: chan %d data %d\n", SenderPid, ReceiverPid, SendingChan, SendingData);
         ReceivingData = SendingData;
         SendingChan = NO_NAME;
         SendingData = NO_NAME;
         ReceivingChan = NO_NAME;
     }
  // match
  :: atomic {(Match == true && MatchNameLeft != NO_NAME && MatchNameRight != NO_NAME
             && MATCHABLE(MatchNameLeft, MatchNameRight))
       -> // printf("[%d] left kind = %e clock = %d\n", MatchPid, names[MatchNameLeft].kind, names[MatchNameLeft].clock);
          // printf("[%d] right kind = %e clock = %d\n", MatchPid, names[MatchNameRight].kind, names[MatchNameRight].clock);
          perform_match(MatchNameLeft, MatchNameRight);
          printf("[%d] match [%d = %d]\n", MatchPid, MatchNameLeft, MatchNameRight);
          MatchNameLeft = NO_NAME;
          MatchNameRight = NO_NAME;
          Match = false
      }
  od
}
