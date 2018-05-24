000100000000       //?Some definitions
000200000000       dcl-s someText    char(10)    inz('abcdefghij');
000300000000       dcl-s someNumbers packed(3:0) dim(10) CTDATA;
000400000000
000500000000       dcl-s percyPointer@ pointer     inz(*NULL);
000600000000       dcl-s oneChar       char(1)     based(percyPointer@);
000700000000       dcl-s oneNumber     packed(3:0) based(percyPointer@);
000800000000
000900000000       //?General index field
001000000000       dcl-s ix uns(5);
001100000000
001200000000       //?Point the pointer to the memory address of character 1 of "someText"
001300000000       percyPointer@ = %addr(someText);
001400000000
001500000000       //?This section will work fine...
001600000000
001700000000       //?Process the string, displaying each character in turn...
001800000000       for ix = 1 to %size(someText);
001900000000
002000000000           dsply oneChar '*EXT';
002100000000           percyPointer@ += 1;
002200000000
002300000000       endfor;
002400000000
002500000000       //?This section will crash with a decimal data error
002600000000
002700000000       //?Re-point the pointer to the memory address of element 1 of "someNumbers"
002800000000       percyPointer@ = %addr(someNumbers);
002900000000
003000000000       //?Loop through the array displaying each number in turn...
003100000000       for ix = 1 to %elem(someNumbers);
003200000000
003300000000           dsply %char(oneNumber) '*EXT';
003400000000           percyPointer@ += 1;
003500000000
003600000000       endfor;
003700000000
003800000000       *INLR = *ON;
003900000000       return;
004000000000
004100000000**CTDATA someNumbers
004200000000001
004300000000002
004400000000003
004500000000004
004600000000005
004700000000006
004800000000007
004900000000008
005000000000009
005100000000010
