DECLARE FUNCTION Register$ (Name$, Serial$)
PRINT "Name: ";
LINE INPUT Name$
PRINT "Machine ID: ";
LINE INPUT Machine$
PRINT
PRINT Register$(Name$, UCASE$(Machine$))
PRINT "Output to file?"
A$ = UCASE$(INPUT$(1))
IF A$ = "Y" THEN
OPEN "REGISTER.DAT" FOR OUTPUT AS #1
PRINT #1, Name$
PRINT #1, Register$(Name$, UCASE$(Machine$))
CLOSE #1
END IF
END

FUNCTION Register$ (Name$, Serial$)
FOR x = 1 TO LEN(Name$)
Value1& = ASC(MID$(Name$, x, 1)) + Value1&
NEXT x
Value1& = (LEN(Name$) + Value1&) * LEN(Name$)
Value1& = ASC(LEFT$(Name$, 1)) + ASC(RIGHT$(Name$, 1)) + Value1&
KeyCode$ = LTRIM$(RTRIM$(STR$(LEN(LTRIM$(RTRIM$(STR$(Value1&))))))) + LTRIM$(RTRIM$(STR$(Value1&)))
Value2& = ASC(LEFT$(Name$, 1)) * LEN(Name$)
Value2& = Value2& + (ASC(RIGHT$(Name$, 1)) * LEN(Name$))
KeyCode$ = KeyCode$ + LTRIM$(RTRIM$(STR$(LEN(LTRIM$(RTRIM$(STR$(Value2&))))))) + LTRIM$(RTRIM$(STR$(Value2&)))
KeyCode$ = KeyCode$ + LTRIM$(RTRIM$(STR$(LEN(LTRIM$(RTRIM$(STR$((Value1& + Value2&) * LEN(Name$)))))))) + LTRIM$(RTRIM$(STR$((Value1& + Value2&) * LEN(Name$))))

FOR x = 1 TO LEN(Serial$) STEP 2
IF INSTR("ABCDEF", MID$(Serial$, x, 1)) THEN
 Number% = 16 * (ASC(MID$(Serial$, x, 1)) - 55)
ELSE
 Number% = 16 * VAL(MID$(Serial$, x, 1))
END IF
IF INSTR("ABCDEF", MID$(Serial$, x + 1, 1)) THEN
 Number% = Number% + (ASC(MID$(Serial$, x + 1)) - 55)
ELSE
 Number% = Number% + VAL(MID$(Serial$, x + 1, 1))
END IF
TotalVal% = Number% + TotalVal%
NEXT x
GetSer% = TotalVal% + TotalVal% / 2 + 1
KeyCode$ = KeyCode$ + LTRIM$(RTRIM$(STR$(GetSer%)))
Register$ = KeyCode$
END FUNCTION
