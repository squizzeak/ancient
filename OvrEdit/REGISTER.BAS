DECLARE FUNCTION RegCheck% (Name$, Key$)

FUNCTION RegCheck% (Name$, Key$)
FOR X = 1 TO LEN(Name$)
Value1% = ASC(MID$(Name$, X, 1)) + Value1%
NEXT X
Value1% = (LEN(Name$) + Value1%) * LEN(Name$)
Value1% = ASC(LEFT$(Name$, 1)) + ASC(RIGHT$(Name$, 1)) + Value1%
KeyCode$ = LTRIM$(RTRIM$(STR$(LEN(LTRIM$(RTRIM$(STR$(Value1%))))))) + LTRIM$(RTRIM$(STR$(Value1%)))
Value2% = ASC(LEFT$(Name$, 1)) * LEN(Name$)
Value2% = Value2% + (ASC(RIGHT$(Name$, 1)) * LEN(Name$))
KeyCode$ = KeyCode$ + LTRIM$(RTRIM$(STR$(LEN(LTRIM$(RTRIM$(STR$(Value2%))))))) + LTRIM$(RTRIM$(STR$(Value2%)))
KeyCode$ = KeyCode$ + LTRIM$(RTRIM$(STR$(LEN(LTRIM$(RTRIM$(STR$((Value1% + Value2%) * LEN(Name$)))))))) + LTRIM$(RTRIM$(STR$((Value1% + Value2%) * LEN(Name$))))
IF KeyCode$ = Key$ THEN RegCheck% = 1 ELSE RegCheck% = 0
END FUNCTION
