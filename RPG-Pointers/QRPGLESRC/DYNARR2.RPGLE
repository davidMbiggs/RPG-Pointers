000100000000**free
000200180406       //?**********************************************************************
000300000000       //?'Warm load' of TGENB[OC] codes.
000400000000       //?Accept an occupation code, return its description
000500180406       //?**********************************************************************
000600000000
000700000000       ctl-opt option(*NODEBUGIO:*SRCSTMT:*NOUNREF)
000800000000               main(occupCache);
000900000000
001000000000       //?Let's give it up for our file TGENB!!!
001100000000       dcl-f TGENB disk(*EXT) usage(*INPUT) keyed;
001200180406
001300180406       //?Number of array elements to make space for on each allocation
001400180406       dcl-c ALLOC_INCREMENT 10;
001500000000
001600180406       //?Occupation codes & description cache - note the large dimension.
001700180406       //?Doesn't need to be this big but there's no harm in making it way
001800180406       //?bigger than needed
001900000000       dcl-ds occupList dim(250000) qualified based(occupList@);
002000000000         code like(TBCDE);
002100000000         desc like(TBDES);
002200000000       end-ds;
002300000000
002400180406       dcl-s occupList@ pointer; // The array's basing pointer
002500000000
002600000000       //?'maxElem' holds the number of elements currently in the array
002700180406       dcl-s maxElem uns(10);
002800180406
002900180406       //?'upperBound' holds the highest available allocated element
003000180406       dcl-s upperBound like(maxElem);
003100000000
003200000000       dcl-proc occupCache;
003300000000         dcl-pi occupCache extpgm('DYNARR1');
003400000000           lpi_code        like(TBCDE) const options(*NOPASS);
003500000000           lpo_description like(TBDES)       options(*NOPASS);
003600000000         end-pi;
003700000000
003800180406         //?Some work fields
003900180406         dcl-s ix like(maxElem);
004000000000         dcl-s isAbnormalEnd ind;
004100000000
004200000000         // --------------------------------------------------------------------
004300000000
004400180406         //?If called with no parms, deallocate storage and quit
004500000000         if %parms() = 0;
004600000000           if occupList@ <> *NULL;
004700000000             dealloc(N) occupList@;
004800000000           endif;
004900180406           return;
005000000000         endif;
005100000000
005200180406         //?First check if we've put anything in the array. Without this
005300180406         //?check the lookup will blow as the array exists as a name but
005400180406         //?there's no storage associated with it
005500180406         if occupList@ <> *NULL;
005600180406           ix = %lookup( lpi_code : occupList(*).code : 1 : maxElem );
005700180406         endif;
005800000000
005900180406         //?If we already have a match in the array return the description
006000180406         if ix > 0;
006100180406           lpo_description = occupList(ix).desc;
006200180406           return;
006300180406         endif;
006400000000
006500180406         //?No match in array so footle off to TGENB to get the record
006600000000         chain ( 'EN' : 'OC' : lpi_code ) TGENB;
006700000000         if NOT %found(TGENB);
006800180406           lpo_description = '*** CODE ' + lpi_code + ' NOT FOUND ***';
006900000000           return;
007000000000         endif;
007100000000
007200180406         //?Instead of allocating one element at a time, we're going to go up
007300180406         //?in steps of 10 to avoid too-frequent allocations
007400000000         if occupList@ = *NULL;
007500180406
007600180406           maxElem    = 1;
007700180406           upperBound = ALLOC_INCREMENT;
007800180406           occupList@ = %alloc( %size(occupList) * upperBound);
007900180406
008000000000         else;
008100180406
008200000000           maxElem += 1;
008300180406           if maxElem > upperBound;
008400180406             upperBound += ALLOC_INCREMENT;
008500180406             occupList@ = %realloc(occupList@ : upperBound * %size(occupList) );
008600180406           endif;
008700180406
008800000000         endif;
008900000000
009000180406         //?Store details to cache
009100000000         occupList(maxElem).code = TBCDE;
009200000000         occupList(maxElem).desc = TBDES;
009300000000
009400000000         lpo_description = occupList(maxElem).desc;
009500000000         return;
009600000000
009700000000       on-exit isAbnormalEnd;
009800000000
009900000000         if isAbnormalEnd;
010000180406
010100000000           if occupList@ <> *NULL;
010200000000             dealloc(N) occupList@;
010300000000           endif;
010400000000
010500000000           close TGENB;
010600000000
010700000000         endif;
010800000000
010900000000       end-proc;
