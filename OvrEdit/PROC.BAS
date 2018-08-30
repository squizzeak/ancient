OPEN "OVREDIT.DAT" FOR INPUT ACCESS READ AS #1
LINE INPUT #1, Dummy$
DO UNTIL EOF(1)
LINE INPUT #1, Dummy$
Count% = Count% + 1
LOOP
CLOSE

OPEN "LOG.DUP" FOR OUTPUT AS #4
OPEN "OVREDIT.DAT" FOR INPUT ACCESS READ AS #1
OPEN "DUPED.DAT" FOR OUTPUT ACCESS WRITE AS #2
LINE INPUT #1, Dummy$
FOR X = 1 TO Count%
LINE INPUT #1, Temp$
IF INSTR(Duped$, STR$(X + 1)) <> 0 THEN GOTO NextX
IF LEFT$(Temp$, 1) = ";" THEN GOTO NextX
PRINT X + 1; " ";
PRINT #2, Temp$
LENGTH$ = MID$(Temp$, 29, 3)
Default$ = RIGHT$(Temp$, LEN(Temp$) - 31)
OFFSET$ = MID$(Temp$, 23, 6)
OPEN "OVREDIT.DAT" FOR INPUT ACCESS READ AS #3
LINE INPUT #3, Dummy$
FOR Z = 1 TO X
LINE INPUT #3, Dummy$
NEXT Z
FOR J = X + 1 TO Count%
LINE INPUT #3, Temp$
IF RIGHT$(Temp$, LEN(Temp$) - 28) = LENGTH$ + Default$ THEN
PRINT "dupe"; J + 1;
Duped$ = Duped$ + STR$(J + 1)
PRINT #4, X + 1; " "; "dupe"; J + 1;
IF Dupe = 0 THEN PRINT #2, "dupe"; : Dupe = 1
PRINT #2, MID$(Temp$, 23, 6);
END IF
NEXT J
IF Dupe = 1 THEN PRINT #2, : PRINT #4,
CLOSE #3
Dupe = 0
NextX:
PRINT
NEXT X

CLOSE
RESET
