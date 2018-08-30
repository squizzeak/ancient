
SUB Direct (Text$, Fcolor%, BColor%)
DEF SEG = &HB800
XRow% = POS(0)
YRow% = CSRLIN
Pointer% = ((YRow% - 1) * 80 + (XRow% - 1)) * 2
Col% = BColor% * 16 + Fcolor%
FOR X = 0 TO LEN(Text$) - 1
POKE Pointer% + (X * 2), ASC(MID$(Text$, X + 1, 1))
POKE Pointer% + (X * 2) + 1, Col%
NEXT X
END SUB
