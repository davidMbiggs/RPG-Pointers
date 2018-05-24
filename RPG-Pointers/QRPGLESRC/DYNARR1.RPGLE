000100000000**free
000200000000       //?**********************************************************************
000300000000       //?Load array of unique Organisation Detail Codes
000400000000       //?**********************************************************************
000500000000
000600000000       ctl-opt option(*NODEBUGIO:*SRCSTMT:*NOUNREF);
000700000000
000800000000       //?Some file we're going to read
000900000000       dcl-f TORGINF disk(*EXT) usage(*INPUT) keyed;
001000000000
001100000000       //?Array defn - 'based' keyword tells compiler not to reserve any storage
001200000000       //?The maximum *size* for an array is 16,773,104 bytes so the maximum
001300000000       //?*number* of elements is therefore 16,773,104 / size of each element
001400000000       //?In our case each element 6 bytes long so the max number is 2,795,517
001500000000       dcl-s dynArr like(T41OGDCDE) dim(2795517) based(dynArr@);
001600000000
001700000000       dcl-s dynArr@ pointer; // ----------------------^^^^^^^
001800000000                              //?Here's the pointer defn for the array
001900000000
002000000000       //?'maxElem' holds the number of elements currently in the array
002100000000       dcl-s maxElem uns(10);
002200000000
002300000000       //?Some work field(s)
002400000000       dcl-s ix like(maxElem);
002500000000
002600000000       // ----------------------------------------------------------------------
002700000000
002800000000       maxElem = 0;
002900000000
003000000000       //?Grab a pointer to some bit of memory
003100000000       dynArr@ = %alloc(1);
003200000000
003300000000       //?Read through the file or other
003400000000       setll *LOVAL TORGINF;
003500000000       dou %eof(TORGINF);
003600000000           read TORGINF;
003700000000           if %eof(TORGINF);
003800000000              leave;
003900000000           endif;
004000000000
004100000000           //?Lookup the CURRENTLY FILLED bit of the array to see if the ODGCDE
004200000000           //?already exists - Note you MUST use the 'maximum element' argument
004300000000           //?(arg no.4) on the lookup to stop it looking into memory that
004400000000           //?hasn't yet been allocated. If you forget the 'max element' bit
004500000000           //?expect bad things to happen!
004600000000           ix = %lookup(T41OGDCDE : dynArr : 1 : maxElem);
004700000000
004800000000           //?If code not found in the array then add it...
004900000000           if ix = 0;
005000000000
005100000000               //?Crank on the number of populated elements in the array...
005200000000               maxElem += 1;
005300000000
005400000000               //?Make some space for the new element...note the second
005500000000               //?argument on the %realloc - this tells the system how
005600000000               //?much memory is needed. In our case we need a space that
005700000000               //?can hold the new number of elements * the size of each
005800000000               //?element. The %realloc may return the same pointer or a
005900000000               //?a different one if the space originally pointed to wasn't
006000000000               //?big enough
006100000000               dynArr@ = %realloc(dynArr@ : maxElem * %size(dynArr));
006200000000
006300000000               //?Populate the new element...
006400000000               dynArr(maxElem) = T41OGDCDE;
006500000000
006600000000           endif;
006700000000
006800000000       enddo;
006900000000
007000000000       //?Before we quit make sure we return the allocated storage back to the
007100000000       //?system. If we DON'T do this we'll have a nasty memory leak.
007200000000       //?The (N) on the dealloc makes sure the pointer is reset to *NULL
007300000000       if dynArr@ <> *NULL;
007400000000           dealloc(N) dynArr@;
007500000000       endif;
007600000000
007700000000       *INLR = *ON;
007800000000       return;
