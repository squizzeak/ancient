DECLARE FUNCTION GetSer$ ()
PRINT GetSer$

FUNCTION GetSer$
SHELL "DIR *. >TEMP.$$$"
File% = FREEFILE
OPEN "TEMP.$$$" FOR INPUT AS #File%
DO UNTIL EOF(1)
LINE INPUT #File%, Temp$
IF INSTR(Temp$, "Serial") THEN Serial$ = RIGHT$(Temp$, 9): EXIT DO
LOOP
CLOSE #File%
OPEN "TEMP.$$$" FOR OUTPUT AS #File%
PRINT #File%, SPACE$(1024)
CLOSE #File%
KILL "TEMP.$$$"
IF Serial$ = "" THEN GOTO Abort
Serial$ = LEFT$(Serial$, 4) + RIGHT$(Serial$, 4)

Abort:
GetSer$ = Serial$
END FUNCTION
