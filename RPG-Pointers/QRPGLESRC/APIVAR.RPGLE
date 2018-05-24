000100000000**free
000200000000       // This source shows an example of calling an API that can return
000300000000       // different amounts of data on each call
000400000000
000500000000       //
000600000000       // Constants
000700000000       //
000800000000
000900000000       dcl-c CURRENT_JOB '*';
001000000000       dcl-c ALL_THREADS 3;
001100000000
001200000000       //
001300000000       // Data structures
001400000000       //
001500000000
001600000000       //
001700000000       // Lock list structure plus basing pointer
001800000000       //
001900000000
002000000000       dcl-s JBLK0100@ pointer;
002100000000       dcl-ds JBLK0100 qualified based(JBLK0100@);
002200000000         bytesReturned    int(10);
002300000000         bytesAvailable   int(10);
002400000000         noOfEntriesAvail int(10);
002500000000         offsetToList     int(10);
002600000000         noOfEntriesRtnd  int(10);
002700000000         lenLockEntry     int(10);
002800000000         //lockList       likeds(lockEntry) dim(???); <== This portion is variable
002900000000       end-ds;
003000000000
003100000000       //
003200000000       // Details of each lock entry and its basing pointer
003300000000       dcl-s lockEntry@ pointer;
003400000000       dcl-ds lockEntry qualified based(lockEntry@);
003500000000         objName       char(10);
003600000000         objLibrary    char(10);
003700000000         objType       char(10);
003800000000         extAttr       char(10);
003900000000         lockState     char(10);
004000000000         *N            char(2);
004100000000         lockStatus    int(10);
004200000000         mbrLocks      int(10);
004300000000         lockCount     int(10);
004400000000         lockScope     char(1);
004500000000         *N            char(3);
004600000000         threadID      char(8);
004700000000         threadHdl     uns(10);
004800000000         lockSpaceID   char(20);
004900000000         objASPName    char(10);
005000000000         objLibASPName char(10);
005100000000         objASPNo      int(10);
005200000000         objLibASPNo   int(10);
005300000000       end-ds;
005400000000
005500000000       //
005600000000       // Structure containing details about the job we're getting locks for
005700000000       //
005800000000
005900000000       dcl-ds JIDF0100 qualified;
006000000000         jobName   char(10) inz(CURRENT_JOB);
006100000000         userName  char(10);
006200000000         jobNumber char(6);
006300000000         intJobID  char(16);
006400000000         *N        char(2) inz(*ALLx'00');
006500000000         threadInd int(10) inz(ALL_THREADS);
006600000000         threadID  char(8);
006700000000       end-ds;
006800000000
006900000000       //
007000000000       // Standard API error structure
007100000000       //
007200000000
007300000000       dcl-ds QUSEC qualified;
007400000000         bytesProvided  int(10) inz(%size(QUSEC));
007500000000         bytesAvailable int(10);
007600000000         exceptionID    char(7);
007700000000         *N             char(1);
007800000000         exceptionData  char(112);
007900000000       end-ds;
008000000000
008100000000       //
008200000000       // Prototypes
008300000000       //
008400000000
008500000000       dcl-pr retrieveJobLocks extpgm('QWCRJBLK');
008600000000         *N char(16773104)   options(*VARSIZE);  // o-Receiver variable - note large size
008700000000         *N int(10)          const;              // i-Receiver size
008800000000         *N char(8)          const;              // i-Format name
008900000000         *N likeds(JIDF0100) const;              // i-Job ID
009000000000         *N char(8)          const;              // i-Format of job ID
009100000000         *N likeds(QUSEC);                       // i/o-API error structure
009200000000       end-pr;
009300000000
009400000000       //
009500000000       // Workfield(s)
009600000000       //
009700000000
009800000000       dcl-s ix like(JBLK0100.noOfEntriesRtnd);
009900000000
010000000000       //.......................................................................
010100000000
010200000000       // Set the receiver size for first call...
010300000000       JBLK0100@ = %alloc(8);       // <== the '8' here...
010400000000
010500000000       //...call the API
010600000000       retrieveJobLocks( JBLK0100
010700000000                       : 8          // <==...is the same '8' here
010800000000                       : 'JBLK0100'
010900000000                       : JIDF0100
011000000000                       : 'JIDF0100'
011100000000                       : QUSEC );
011200000000
011300000000       // Now re-size receiver for size required for all information available...
011400000000       JBLK0100@ = %realloc( JBLK0100@ : JBLK0100.bytesAvailable );
011500000000
011600000000       //...and re-call the API
011700000000       retrieveJobLocks( JBLK0100
011800000000                       : JBLK0100.bytesAvailable
011900000000                       : 'JBLK0100'
012000000000                       : JIDF0100
012100000000                       : 'JIDF0100'
012200000000                       : QUSEC );
012300000000
012400000000       // Position list entry pointer
012500000000       lockEntry@ = JBLK0100@ + JBLK0100.offsetToList;
012600000000
012700000000       // Loop through the entries...
012800000000       for ix = 1 to JBLK0100.noOfEntriesRtnd;
012900000000
013000000000         // Nudge list pointer to next entry
013100000000         lockEntry@ += JBLK0100.lenLockEntry;
013200000000       endfor;
013300000000
013400000000       // Return storage allocated to receiver variable
013500000000       dealloc(N) JBLK0100@;
013600000000
013700000000       // Didn't allocate any storage for the list entry structure so no 'dealloc' needed
013800000000
013900000000       *INLR = *ON;
014000000000       return;
