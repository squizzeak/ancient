'$DYNAMIC
DECLARE FUNCTION GetNum% (MaxVal%, Hotkey%)
DECLARE FUNCTION XMSError% ()
DECLARE FUNCTION WhichXError% ()
DECLARE FUNCTION GetXMS% (Handle%)
DECLARE FUNCTION FileCRC# (FileName$)
DECLARE FUNCTION QBCRC# (Segment%, Offset&, Length%, CRC#)
DECLARE FUNCTION RegCheck% (Name$, Key$)
DECLARE FUNCTION GetSer% ()
DECLARE SUB StartScreen ()
DECLARE SUB CRC32Init ()
DECLARE SUB Passedupd (Temp$, More$)
DECLARE SUB Help ()
DECLARE SUB SaveOvr ()
DECLARE SUB ExitMsg ()
DECLARE SUB Colorupd (Temp$)
DECLARE SUB StringEdit (RecLoc%)
DECLARE SUB LineUpd (RecLoc%, Dir%)
DECLARE SUB LoadOvr ()
DECLARE SUB ScrnUpd ()
DECLARE SUB LoadCfg ()

TYPE mydata
  Desc AS STRING * 22
  Default AS STRING * 120
  Curr AS STRING * 120
  Dupe AS STRING * 100
  Offset AS LONG
  Stringlen AS INTEGER
  Length AS INTEGER
  Changed AS INTEGER
END TYPE

COMMON SHARED MaxPage%, Page%, MaxRecord%, Version$, Alphinfo$, Include$
COMMON SHARED NoImport$, SaveChange$, NoDoc$, ReDefault$, CustSave$, CustLoad$
COMMON SHARED NoSav$, HelpFooter$, ReOvr$, HelpLoad%, Backup$, VersRG$, MemStat$
COMMON SHARED NoOfRecs%, UnRegMax%, REG, Serial%, RegOnlyFeature$, Statline%
COMMON SHARED EditLine%, ThanksForReg$, HexSer$, MaxDim%, Handle%, EnterLine$
COMMON SHARED Done$, CRCCalculate$, LoadingDat$, LoadingOvr$, Pressakey$, Name$
COMMON SHARED CheckReg$, GenInclude$, Saving$, PleaseWait$, PageModRec%, Abort%
COMMON SHARED CurrDir$

DIM SHARED OvrEdit AS mydata
DIM SHARED CRCTable#(255)
DIM SHARED Header$(2)
DIM SHARED HelpText$(20)

Version$ = "10-05"
Alphinfo$ = ".3a"
EditLine% = 22
NoOfRecs% = 14
UnRegMax% = 42
Statline% = 20
REG = 0

CONST LoadBuffer = 20000 'size of disk buffer in FileCRC

StartScreen
COLOR 15, 0
LOCATE 10, 62
PRINT "v" + Version$ + Alphinfo$
VIEW PRINT 16 TO 23
CALL InitXMS(There%, MemSize%)

IF There% THEN
 PRINT "There are"; MemSize% * 1024&; "bytes of XMS memory available this session."
ELSE
XMSError:
 PRINT "XMS Error!  This program requires a LIM XMS compatible driver (such as"
 PRINT "HIMEM.SYS)."
END
END IF

IF MemSize% < 2048 THEN
 PRINT "I'm sorry, but you must have at least 2 megabytes of extended memory"
 PRINT "available."
END
END IF

Handle% = GetXMS%(MemSize%)
IF Handle% = 0 THEN GOTO XMSError

Backup$ = "■ Renaming current RENEGADE.OVR to RGOVR.BAK"
Saving$ = "■ Saving current setup to RENEGADE.OVR -"
Header$(1) = "OvrEdit v" + Version$ + Alphinfo$ + " - OVREDIT.DAT for version: "
Header$(2) = "Press ESC to quit or F1 for Help."
NoImport$ = "OVREDIT.DAT CRC does not match value stored in OVREDIT.SAV.  Function Aborted."
SaveChange$ = "Changes made.  Save?  (Y/n/c)"
NoDoc$ = "File OVREDIT.DOC not found.  Press Any Key to continue."
ReDefault$ = "Defaults Reloaded.  Press any key."
CustSave$ = "Custom Strings Saved.  Press any key."
CustLoad$ = "Custom Strings Loaded.  Press any key."
NoSav$ = "OVREDIT.SAV not found.  Press any key to continue."
HelpFooter$ = "Press Up and down arrows to scroll, Escape to exit help."
ReOvr$ = "RENEGADE.OVR Re-loaded.  Press any key."
RegOnlyFeature$ = "This feature is enabled when you register.  Only 15$!"
ThanksForReg$ = "This program is licensed to "
Done$ = "Done."
CheckReg$ = "Checking registration code... "
CRCCalculate$ = "Calculating the CRC-32 of OVREDIT.DAT: "
GenInclude$ = "Generating typable key list... "
LoadingDat$ = "Loading configuration file OVREDIT.DAT... "
Unregistered$ = "This program is UNREGISTERED!  Send in your $15 today!"
LoadingOvr$ = "Loading current configuration from RENEGADE.OVR..."
PleaseWait$ = "Please wait... "
Pressakey$ = "Press any key."
EnterLine$ = "Enter line number to jump to:"
InvalidValue$ = "That is an invalid value.  Please enter it again.  "

GenInclude:
PRINT GenInclude$;
FOR X = 32 TO 255
Include$ = Include$ + CHR$(X)
NEXT X
PRINT Done$

ON ERROR GOTO FileNotFound
Miss$ = "RENEGADE.OVR"
OPEN "RENEGADE.OVR" FOR INPUT AS #1
RESET
ON ERROR GOTO FileNotFound
Miss$ = "OVREDIT.DAT"
OPEN "OVREDIT.DAT" FOR INPUT AS 1
IF LOF(1) < 50000 THEN
CLOSE 1
KILL "OVREDIT.DAT"
SHELL "COPY INDIVID.DAT OVREDIT.DAT >NUL"
END IF
RESET
ON ERROR GOTO Generr

Serial% = GetSer%
ON ERROR GOTO SkipRegCheck
OPEN "REGISTER.DAT" FOR INPUT AS #1
ON ERROR GOTO Generr
PRINT CheckReg$;
LINE INPUT #1, Name$
LINE INPUT #1, Key$
CLOSE #1
REG = RegCheck%(Name$, Key$)
IF REG = 1 THEN
PRINT "Valid registration information."
ELSE
PRINT "Invalid registration information."
END IF
SkipRegCheck:

IF REG = 1 THEN
PRINT CRCCalculate$; PleaseWait$;
LOCATE , LEN(CRCCalculate$) + 1
CRC32Init
CRC# = FileCRC#("OVREDIT.DAT")
IF CRC# = -1 THEN GOTO AbortLoad
ON ERROR GOTO Generr
PRINT Done$; SPACE$(LEN(PleaseWait$) - LEN(Done$))
END IF

PRINT LoadingDat$;
LoadCfg
IF Abort% = 1 THEN GOTO AbortLoad
PRINT Done$
Header$(1) = Header$(1) + VersRG$
PRINT LoadingOvr$;
LoadOvr
IF Abort% = 1 THEN GOTO AbortLoad
PRINT Done$
MaxPage% = INT(MaxRecord% / NoOfRecs%) + 1
IF MaxRecord% MOD NoOfRecs% = 0 THEN MaxPage% = MaxPage% - 1
Page% = 1
RecLoc% = 1
OldRecLoc% = 0

PRINT
IF REG = 1 THEN PRINT ThanksForReg$ + Name$ + ".  " + Pressakey$;
IF REG = 0 THEN PRINT Unregistered$ + "  " + Pressakey$;
A$ = INPUT$(1)
VIEW PRINT
CLS

PageModRec% = MaxRecord% MOD NoOfRecs%
IF PageModRec% = 0 THEN PageModRec% = NoOfRecs%

START:
ScrnUpd
LineUpd RecLoc%, 0

GetKey:
COLOR 7, 0
LOCATE 24, 40
PRINT (RecLoc% + ((Page% - 1) * NoOfRecs%)); "of"; MaxRecord%; "     ";
DO
Char$ = INKEY$
IF Char$ <> "" THEN EXIT DO
LOOP

SELECT CASE Char$
 CASE CHR$(0) + "Q": GOTO PageDown
 CASE CHR$(0) + "I": GOTO PageUp
 CASE CHR$(0) + "H": GOTO ArrowUp
 CASE CHR$(0) + "P": GOTO ArrowDown
 CASE CHR$(0) + "D": GOTO F10                'Quit
 CASE CHR$(0) + ";": GOTO F1                 'Help
 CASE CHR$(0) + "?": GOTO F5                 'Restore Defaults
 CASE CHR$(0) + "@": GOTO F6                 'Restore overlay setup
 CASE CHR$(0) + "B": GOTO F8                 'Write custom file
 CASE CHR$(0) + "C": GOTO F9                 'Read in custom file
 CASE CHR$(0) + CHR$(34): GOTO GotoLine      'Go to line #
 CASE "G": GOTO GotoLine
 CASE "g": GOTO GotoLine
 CASE CHR$(0) + "G": GOTO HomeKey            'Top Record
 CASE CHR$(0) + "w": Home = 1: GOTO HomeKey  'Top Page
 CASE CHR$(0) + "O": GOTO EndKey             'End Record
 CASE CHR$(0) + "u": Endr = 1: GOTO EndKey   'End Page
 CASE CHR$(0) + "2"                          'Machine Information
      COLOR 15, 0
      LOCATE Statline%, 1
      PRINT "Your machine identification number is: "; HexSer$
      A$ = INPUT$(1)
      LineUpd RecLoc%, OldRecLoc%
      GOTO GetKey
 CASE CHR$(0) + CHR$(31)           'Shell to DOS
      COLOR 15, 0
      CLS
      PRINT "Free Memory: "; FRE(-1)
      PRINT
      PRINT "Type EXIT to Return to OvrEdit."
      SHELL
      SHELL LEFT$(CurrDir$, 2)
      CHDIR CurrDir$
      CLS
      GOTO START
 CASE CHR$(13): GOTO Enter
 CASE CHR$(27): GOTO ESCAPE
 CASE ELSE: GOTO GetKey
END SELECT

PageDown:
IF Page% = MaxPage% THEN GOTO GetKey
Page% = Page% + 1
RecLoc% = 1
VIEW PRINT 4 TO Statline% - 2
CLS
VIEW PRINT
ScrnUpd
LineUpd RecLoc%, 0
COLOR 7, 0
LOCATE 24, 40
PRINT (RecLoc% + ((Page% - 1) * NoOfRecs%)); "of"; MaxRecord%; "     ";
GOTO GetKey

PageUp:
IF Page% = 1 THEN LineUpd RecLoc%, OldRecLoc%: GOTO GetKey
RecLoc% = NoOfRecs%
Page% = Page% - 1
VIEW PRINT 4 TO Statline% - 2
CLS
VIEW PRINT
ScrnUpd
LineUpd RecLoc%, 0
COLOR 7, 0
LOCATE 24, 40
PRINT (RecLoc% + ((Page% - 1) * NoOfRecs%)); "of"; MaxRecord%; "     ";
GOTO GetKey

HomeKey:
IF Home = 0 AND RecLoc% = 1 THEN GOTO GetKey
IF Page% = 1 AND RecLoc% = 1 THEN GOTO GetKey
OldRecLoc% = RecLoc%
IF OldRecLoc% = 1 THEN OldRecLoc% = NoOfRecs%
IF Home = 1 THEN VIEW PRINT 4 TO Statline% - 2: CLS : VIEW PRINT
IF Home = 1 THEN Page% = 1: Home = 0
RecLoc% = 1
ScrnUpd
LineUpd RecLoc%, OldRecLoc%
COLOR 7, 0
LOCATE 24, 40
PRINT (RecLoc% + ((Page% - 1) * NoOfRecs%)); "of"; MaxRecord%; "     ";
GOTO GetKey

EndKey:
TempRec% = NoOfRecs%
IF Page% = MaxPage% OR Endr = 1 THEN TempRec% = PageModRec%
IF Endr = 1 AND Page% = MaxPage% AND RecLoc% = TempRec% THEN GOTO GetKey
IF Endr = 0 AND RecLoc% = NoOfRecs% THEN GOTO GetKey
OldRecLoc% = RecLoc%
IF OldRecLoc% = TempRec% THEN OldRecLoc% = 0
IF Endr = 1 THEN VIEW PRINT 4 TO Statline% - 2: CLS : VIEW PRINT
IF Endr = 1 THEN Page% = MaxPage%: Endr = 0
RecLoc% = TempRec%
ScrnUpd
LineUpd RecLoc%, OldRecLoc%
COLOR 7, 0
LOCATE 24, 40
PRINT (RecLoc% + ((Page% - 1) * NoOfRecs%)); "of"; MaxRecord%; "     ";
GOTO GetKey

GotoLine:
LOCATE Statline%, 1
COLOR 15, 0
PRINT EnterLine$; SPACE$(80 - LEN(EnterLine$))
LOCATE EditLine%, 1
LineNum% = GetNum%(MaxRecord%, 1)
IF LineNum% = -1 THEN GOTO Abortjump
Page% = LineNum% \ NoOfRecs% + 1
RecLoc% = LineNum% MOD NoOfRecs%
IF RecLoc% = 0 THEN RecLoc% = NoOfRecs%: Page% = Page% - 1
IF Page% > MaxPage% THEN Page% = MaxPage%: RecLoc% = NoOfRecs%

Abortjump:
ScrnUpd
LineUpd RecLoc%, 0
GOTO GetKey

ArrowUp:
IF RecLoc% = 1 AND Page% = 1 THEN GOTO PageUp
IF RecLoc% = 1 THEN OldRecLoc% = 1: RecLoc% = NoOfRecs%: GOTO PageUp

OldRecLoc% = RecLoc%
RecLoc% = RecLoc% - 1
LineUpd RecLoc%, OldRecLoc%
COLOR 7, 0
LOCATE 24, 40
PRINT (RecLoc% + ((Page% - 1) * NoOfRecs%)); "of"; MaxRecord%; "     ";
GOTO GetKey

ArrowDown:
IF RecLoc% = NoOfRecs% THEN GOTO PageDown
IF RecLoc% + ((Page% - 1) * NoOfRecs%) = MaxRecord% THEN GOTO GetKey
OldRecLoc% = RecLoc%
RecLoc% = RecLoc% + 1
LineUpd RecLoc%, OldRecLoc%
COLOR 7, 0
LOCATE 24, 40
PRINT (RecLoc% + ((Page% - 1) * NoOfRecs%)); "of"; MaxRecord%; "     ";
GOTO GetKey

Enter:
StringEdit (RecLoc%)
ScrnUpd
LineUpd RecLoc%, 0
IF OvrEdit.Changed = 1 THEN Change = 1
GOTO GetKey

ESCAPE:
COLOR 7, 0
CLS
IF Change = 1 THEN
PRINT SaveChange$
PRINT
A$ = UCASE$(INPUT$(1))
SELECT CASE A$
 CASE "Y", CHR$(13)
  PRINT Backup$
  SHELL "COPY RENEGADE.OVR RGOVR.BAK > NUL"
  PRINT Saving$;
  SaveOvr
 CASE "C"
  GOTO START
END SELECT
END IF
ExitMsg
END

F1:
ON ERROR GOTO NoDoc
OPEN "OVREDIT.DOC" FOR INPUT AS #1
CLOSE
ON ERROR GOTO Generr
Help
GOTO START

NoDoc:
COLOR 15, 0
LOCATE Statline%, 1
PRINT NoDoc$; SPACE$(80 - LEN(NoDoc$));
A$ = INPUT$(1)
LOCATE Statline%, 1
PRINT SPACE$(80);
LineUpd RecLoc%, 0
RESUME GetKey

F5:
LOCATE Statline%, 1
COLOR 15, 0
PRINT PleaseWait$; SPACE$(80 - LEN(PleaseWait$));
FOR Count% = 1 TO MaxRecord%
CALL XGetElement(Handle%, OvrEdit, LEN(OvrEdit), Count%)
OvrEdit.Stringlen = OvrEdit.Length
OvrEdit.Curr = OvrEdit.Default$
OvrEdit.Changed = 1
CALL XSetElement(Handle%, OvrEdit, LEN(OvrEdit), Count%)
NEXT Count%
LOCATE Statline%, 1
COLOR 15, 0
PRINT ReDefault$; SPACE$(80 - LEN(ReDefault$));
A$ = INPUT$(1)
ScrnUpd
LineUpd RecLoc%, 0
Change = 1
GOTO GetKey

F6:
LOCATE Statline%, 1
COLOR 15, 0
PRINT PleaseWait$; SPACE$(80 - LEN(PleaseWait$));
LoadOvr
LOCATE Statline%, 1
COLOR 15, 0
PRINT ReOvr$; SPACE$(80 - LEN(ReOvr$));
A$ = INPUT$(1)
ScrnUpd
LineUpd RecLoc%, 0
Change = 0
GOTO GetKey

F8:
IF REG = 0 THEN
LOCATE Statline%, 1
COLOR 15, 0
PRINT RegOnlyFeature$
ELSE
LOCATE Statline%, 1
COLOR 15, 0
PRINT PleaseWait$; SPACE$(80 - LEN(PleaseWait$));
File% = FREEFILE
OPEN "OVREDIT.SAV" FOR OUTPUT AS File%
PRINT #1, HEX$(CRC#)
FOR Count% = 1 TO MaxRecord%
CALL XGetElement(Handle%, OvrEdit, LEN(OvrEdit), Count%)
PRINT #1, LEFT$(OvrEdit.Curr, OvrEdit.Stringlen)
NEXT Count%
LOCATE Statline%, 1
COLOR 15, 0
PRINT CustSave$; SPACE$(80 - LEN(CustSave$));
CLOSE File%
END IF
A$ = INPUT$(1)
'ScrnUpd
LineUpd RecLoc%, 0
GOTO GetKey

F9:
IF REG = 0 THEN
LOCATE Statline%, 1
COLOR 15, 0
PRINT RegOnlyFeature$
ELSE
ON ERROR GOTO NoSav
File% = FREEFILE
OPEN "OVREDIT.SAV" FOR INPUT AS File%
LOCATE Statline%, 1
COLOR 15, 0
PRINT PleaseWait$; SPACE$(80 - LEN(PleaseWait$));
LINE INPUT #1, Crcval$
IF Crcval$ <> HEX$(CRC#) THEN
VIEW PRINT
LOCATE Statline%, 1
COLOR 15, 0
PRINT NoImport$; SPACE$(80 - LEN(NoImport$));
A$ = UCASE$(INPUT$(1))
LineUpd RecLoc%, 0
GOTO GetKey
ELSE
Change = 1
  FOR Count% = 1 TO MaxRecord%
  IF EOF(File%) THEN EXIT FOR
  CALL XGetElement(Handle%, OvrEdit, LEN(OvrEdit), Count%)
  LINE INPUT #1, Temp$
  OvrEdit.Stringlen = LEN(Temp$)
  OvrEdit.Curr = Temp$
  IF OvrEdit.Stringlen > OvrEdit.Length THEN OvrEdit.Curr = LEFT$(OvrEdit.Curr, OvrEdit.Length): OvrEdit.Stringlen = OvrEdit.Length
  OvrEdit.Changed = 1
  CALL XSetElement(Handle%, OvrEdit, LEN(OvrEdit), Count%)
  NEXT Count%
  CLOSE File%
LOCATE Statline%, 1
COLOR 15, 0
PRINT CustLoad$; SPACE$(80 - LEN(CustLoad$));
END IF
END IF
A$ = INPUT$(1)
ScrnUpd
LineUpd RecLoc%, 0
GOTO GetKey

NoSav:
LOCATE Statline%, 1
COLOR 15, 0
PRINT NoSav$; SPACE$(80 - LEN(NoSav$));
A$ = INPUT$(1)
LOCATE Statline%, 1
PRINT SPACE$(80);
LineUpd RecLoc%, 0
RESUME GetKey

F10:
COLOR 7, 0
CLS
RESET
ExitMsg

FileNotFound:
COLOR 12, 0
LOCATE 25, 1
PRINT
RESET
PRINT "File "; Miss$; " not found.  Halting"
CALL FreeXMS(Handle%)
END

Generr:
COLOR 12, 0
LOCATE 25, 1
PRINT
RESET
PRINT "General Error #"; ERR; ".  Halting"
CALL FreeXMS(Handle%)
END

AbortLoad:
PRINT "Aborted.      "
PRINT
RESET
CALL FreeXMS(Handle%)
END

DATA &H000000000,&H077073096,&H0EE0E612C,&H0990951BA,&H0076DC419
DATA &H0706AF48F,&H0E963A535,&H09E6495A3,&H00EDB8832,&H079DCB8A4
DATA &H0E0D5E91E,&H097D2D988,&H009B64C2B,&H07EB17CBD,&H0E7B82D07
DATA &H090BF1D91,&H01DB71064,&H06AB020F2,&H0F3B97148,&H084BE41DE
DATA &H01ADAD47D,&H06DDDE4EB,&H0F4D4B551,&H083D385C7,&H0136C9856
DATA &H0646BA8C0,&H0FD62F97A,&H08A65C9EC,&H014015C4F,&H063066CD9
DATA &H0FA0F3D63,&H08D080DF5,&H03B6E20C8,&H04C69105E,&H0D56041E4
DATA &H0A2677172,&H03C03E4D1,&H04B04D447,&H0D20D85FD,&H0A50AB56B
DATA &H035B5A8FA,&H042B2986C,&H0DBBBC9D6,&H0ACBCF940,&H032D86CE3
DATA &H045DF5C75,&H0DCD60DCF,&H0ABD13D59,&H026D930AC,&H051DE003A
DATA &H0C8D75180,&H0BFD06116,&H021B4F4B5,&H056B3C423,&H0CFBA9599
DATA &H0B8BDA50F,&H02802B89E,&H05F058808,&H0C60CD9B2,&H0B10BE924
DATA &H02F6F7C87,&H058684C11,&H0C1611DAB,&H0B6662D3D,&H076DC4190
DATA &H001DB7106,&H098D220BC,&H0EFD5102A,&H071B18589,&H006B6B51F
DATA &H09FBFE4A5,&H0E8B8D433,&H07807C9A2,&H00F00F934,&H09609A88E
DATA &H0E10E9818,&H07F6A0DBB,&H0086D3D2D,&H091646C97,&H0E6635C01
DATA &H06B6B51F4,&H01C6C6162,&H0856530D8,&H0F262004E,&H06C0695ED
DATA &H01B01A57B,&H08208F4C1,&H0F50FC457,&H065B0D9C6,&H012B7E950
DATA &H08BBEB8EA,&H0FCB9887C,&H062DD1DDF,&H015DA2D49,&H08CD37CF3
DATA &H0FBD44C65,&H04DB26158,&H03AB551CE,&H0A3BC0074,&H0D4BB30E2
DATA &H04ADFA541,&H03DD895D7,&H0A4D1C46D,&H0D3D6F4FB,&H04369E96A
DATA &H0346ED9FC,&H0AD678846,&H0DA60B8D0,&H044042D73,&H033031DE5
DATA &H0AA0A4C5F,&H0DD0D7CC9,&H05005713C,&H0270241AA,&H0BE0B1010
DATA &H0C90C2086,&H05768B525,&H0206F85B3,&H0B966D409,&H0CE61E49F
DATA &H05EDEF90E,&H029D9C998,&H0B0D09822,&H0C7D7A8B4,&H059B33D17
DATA &H02EB40D81,&H0B7BD5C3B,&H0C0BA6CAD,&H0EDB88320,&H09ABFB3B6
DATA &H003B6E20C,&H074B1D29A,&H0EAD54739,&H09DD277AF,&H004DB2615
DATA &H073DC1683,&H0E3630B12,&H094643B84,&H00D6D6A3E,&H07A6A5AA8
DATA &H0E40ECF0B,&H09309FF9D,&H00A00AE27,&H07D079EB1,&H0F00F9344
DATA &H08708A3D2,&H01E01F268,&H06906C2FE,&H0F762575D,&H0806567CB
DATA &H0196C3671,&H06E6B06E7,&H0FED41B76,&H089D32BE0,&H010DA7A5A
DATA &H067DD4ACC,&H0F9B9DF6F,&H08EBEEFF9,&H017B7BE43,&H060B08ED5
DATA &H0D6D6A3E8,&H0A1D1937E,&H038D8C2C4,&H04FDFF252,&H0D1BB67F1
DATA &H0A6BC5767,&H03FB506DD,&H048B2364B,&H0D80D2BDA,&H0AF0A1B4C
DATA &H036034AF6,&H041047A60,&H0DF60EFC3,&H0A867DF55,&H0316E8EEF
DATA &H04669BE79,&H0CB61B38C,&H0BC66831A,&H0256FD2A0,&H05268E236
DATA &H0CC0C7795,&H0BB0B4703,&H0220216B9,&H05505262F,&H0C5BA3BBE
DATA &H0B2BD0B28,&H02BB45A92,&H05CB36A04,&H0C2D7FFA7,&H0B5D0CF31
DATA &H02CD99E8B,&H05BDEAE1D,&H09B64C2B0,&H0EC63F226,&H0756AA39C
DATA &H0026D930A,&H09C0906A9,&H0EB0E363F,&H072076785,&H005005713
DATA &H095BF4A82,&H0E2B87A14,&H07BB12BAE,&H00CB61B38,&H092D28E9B
DATA &H0E5D5BE0D,&H07CDCEFB7,&H00BDBDF21,&H086D3D2D4,&H0F1D4E242
DATA &H068DDB3F8,&H01FDA836E,&H081BE16CD,&H0F6B9265B,&H06FB077E1
DATA &H018B74777,&H088085AE6,&H0FF0F6A70,&H066063BCA,&H011010B5C
DATA &H08F659EFF,&H0F862AE69,&H0616BFFD3,&H0166CCF45,&H0A00AE278
DATA &H0D70DD2EE,&H04E048354,&H03903B3C2,&H0A7672661,&H0D06016F7
DATA &H04969474D,&H03E6E77DB,&H0AED16A4A,&H0D9D65ADC,&H040DF0B66
DATA &H037D83BF0,&H0A9BCAE53,&H0DEBB9EC5,&H047B2CF7F,&H030B5FFE9
DATA &H0BDBDF21C,&H0CABAC28A,&H053B39330,&H024B4A3A6,&H0BAD03605
DATA &H0CDD70693,&H054DE5729,&H023D967BF,&H0B3667A2E,&H0C4614AB8
DATA &H05D681B02,&H02A6F2B94,&H0B40BBE37,&H0C30C8EA1,&H05A05DF1B
DATA &H02D02EF8D

SUB Colorupd (Temp$)
  COLOR 15, 0
  Leno% = 1
  LOCATE Statline%, 1
  FOR Count% = 1 TO LEN(Temp$)
  Char$ = MID$(Temp$, Count%, 1)
  IF Char$ = "|" THEN
  IF Count% = LEN(Temp$) THEN PRINT Char$; SPACE$(1); : EXIT SUB
  Clr$ = MID$(Temp$, Count% + 1, 2)
  IF ASC(LEFT$(Clr$, 1)) < 48 OR ASC(LEFT$(Clr$, 1)) > 57 THEN PRINT "|"; : Leno% = Leno% + 1: GOTO Printed ELSE Colr% = VAL(Clr$)
  IF ASC(RIGHT$(Clr$, 1)) < 48 OR ASC(RIGHT$(Clr$, 1)) > 57 THEN PRINT "|"; : Leno% = Leno% + 1: GOTO Printed ELSE Colr% = VAL(Clr$)
  IF Colr% = 0 THEN COLOR , 0: GOTO Skipproc
  IF Colr% > 30 THEN PRINT "|"; : Leno% = Leno% + 1: GOTO Printed
  IF Colr% > 15 THEN Colr% = Colr% - 15: COLOR , Colr%:  ELSE COLOR Colr%
Skipproc:
  Count% = Count% + 2
  ELSE
  Leno% = Leno% + 1
  IF Leno% >= 78 THEN LOCATE Statline%, Leno% - 1: PRINT "..."; : EXIT SUB
  PRINT Char$;
  END IF
Printed:
  NEXT Count%
  IF Leno% >= 78 THEN LOCATE Statline%, Leno% - 1: PRINT "..."; : EXIT SUB
  LOCATE Statline%, Leno%: COLOR 8, 0: PRINT SPACE$(80 - Leno%);
  END SUB

DEFINT A-Z
'Reads in the CRC table
'
SUB CRC32Init
    FOR A = 0 TO 255
        READ CRCTable#(A)
    NEXT
END SUB

DEFSNG A-Z
SUB ExitMsg
CLS
PRINT "Thank you for using OvrEdit v" + Version$ + Alphinfo$ + "!"
IF REG = 0 THEN
PRINT "Many hours of work went into this program.  Please consider registering it"
PRINT "for the low price of only 15 dollars (US only, please)."
ELSE
PRINT "Thank you for registering OvrEdit.  Your support is greatly appreciated."
END IF
PRINT
PRINT
PRINT "Please call my BBS for the latest version and information regarding OvrEdit."
PRINT "Disallusioned Society  (708)653-0376"
PRINT
PRINT
PRINT "I would like to extend a personal thanks to:"
PRINT
PRINT "Richard Geldreich for CRC-32 routines.  (Posted public in the Fido QB echo.)"
PRINT "Robin Duffy for the HIMEM.SYS interface for QB, and also for the personal"
PRINT "   support he gave me on his routines."
PRINT "Andy Avery and John Wallace for their support and enthusiasm."
PRINT "Josh Hunter for all the (constructive) criticism and ideas he gave me."
IF REG = 1 THEN
PRINT Name$ + " for registering this copy of OvrEdit."
END IF
PRINT "All the users of my BBS for their input regarding OvrEdit."
LOCATE 23, 1
PRINT "Programmed completely in Quick Basic v4.5 (c) Microsoft Corporation 1985-1988";
CALL FreeXMS(Handle%)
END
END SUB

DEFINT A-Z
'Finds a PKZIP compatible CRC of any size file.
'There isn't any error checking in this example program- that's up to you.
FUNCTION FileCRC# (FileName$)
    File% = FREEFILE                          'get free file handle
    OPEN FileName$ FOR INPUT AS File%: CLOSE  'check to see if it's there
    OPEN FileName$ FOR BINARY AS File%        'open file in binary mode
    B$ = SPACE$(LoadBuffer)                    'allocate space for buffer
    CRC# = &HFFFFFFFF                          'init CRC
    FOR A = 1 TO LOF(File%) \ LoadBuffer      'do the blocks
        IF INKEY$ = CHR$(27) THEN FileCRC# = -1: GOTO EndCRC
        GET File%, , B$                       'get block
        CRC# = QBCRC(VARSEG(B$), SADD(B$), LoadBuffer, CRC#)
    IF CRC# = -1 THEN FileCRC# = -1: GOTO EndCRC
    NEXT
    whatsleft = LOF(File%) MOD LoadBuffer     'do the oddballs now
    B$ = SPACE$(whatsleft)                     'whatever's left over
    GET File%, , B$                           'get it
    CRC# = QBCRC(VARSEG(B$), SADD(B$), whatsleft, CRC#)
    IF CRC# = -1 THEN FileCRC# = -1: GOTO EndCRC
    FileCRC# = NOT CRC#                        'return CRC to caller
EndCRC:
    CLOSE File%                               'close file
END FUNCTION

REM $STATIC
DEFSNG A-Z
FUNCTION GetNum% (MaxVal%, Hotkey%)
XVal% = CSRLIN
YVal% = POS(0)
DoAgain:
DO UNTIL VAL(Number$) >= MaxVal%
A$ = INKEY$
IF A$ = "" GOTO DoAgain
IF A$ = CHR$(13) AND Number$ <> "" THEN EXIT DO
IF A$ = CHR$(13) AND NOT Number$ <> "" THEN GetNum% = -1: EXIT FUNCTION
IF A$ = CHR$(27) THEN GetNum% = -1: EXIT FUNCTION
IF A$ = CHR$(8) AND NOT Number$ <> "" THEN GOTO DoAgain
IF A$ = CHR$(8) AND Number$ <> "" THEN Number$ = LEFT$(Number$, LEN(Number$) - 1): GOTO Update
IF A$ = "0" AND Number$ = "" THEN GOTO DoAgain
IF VAL(Number$ + A$) > MaxVal% THEN GOTO DoAgain
IF ASC(A$) > 47 AND ASC(A$) < 58 THEN Number$ = Number$ + A$
Update:
LOCATE XVal%, YVal%
PRINT Number$; " ";
IF Hotkey% = 1 AND VAL(Number$ + "0") > MaxVal% THEN EXIT DO
LOOP
GetNum% = VAL(Number$)
END FUNCTION

FUNCTION GetSer%

SHELL "DIR . >TEMP.$$$"
File% = FREEFILE

OPEN "TEMP.$$$" FOR INPUT AS File%
 DO UNTIL EOF(1)
  LINE INPUT #File%, Temp$
  IF INSTR(Temp$, "Serial") THEN Serial$ = RIGHT$(Temp$, 9)
  IF INSTR(Temp$, "Directory of") THEN CurrDir$ = RIGHT$(Temp$, LEN(Temp$) - 14): EXIT DO
 LOOP
CLOSE File%

OPEN "TEMP.$$$" FOR OUTPUT AS File%
 PRINT #File%, SPACE$(1024)
CLOSE File%

KILL "TEMP.$$$"

IF Serial$ = "" THEN GOTO Abort
Serial$ = LEFT$(Serial$, 4) + RIGHT$(Serial$, 4)

ParseHex:
FOR X = 1 TO LEN(Serial$) STEP 2
 IF INSTR("ABCDEF", MID$(Serial$, X, 1)) THEN
  Number% = 16 * (ASC(MID$(Serial$, X, 1)) - 55)
 ELSE
  Number% = 16 * VAL(MID$(Serial$, X, 1))
 END IF
 IF INSTR("ABCDEF", MID$(Serial$, X + 1, 1)) THEN
  Number% = Number% + (ASC(MID$(Serial$, X + 1)) - 55)
 ELSE
  Number% = Number% + VAL(MID$(Serial$, X + 1, 1))
 END IF
 TotalVal% = Number% + TotalVal%
NEXT X

GetSer% = TotalVal% + TotalVal% / 2 + 1
HexSer$ = Serial$
EXIT FUNCTION

Abort:
GetSer% = -1

END FUNCTION

REM $DYNAMIC
SUB Help
StartHelp:
COLOR 8, 0
LOCATE 2, 1: PRINT STRING$(80, 196);
LOCATE 23, 1: PRINT STRING$(80, 196);
COLOR 7, 0
LOCATE 1, 1: PRINT Header$(1); SPACE$(80 - LEN(Header$(1)));
LOCATE 24, 1: PRINT Header$(2); SPACE$(80 - LEN(Header$(2)));
IF HelpLoad% = 0 THEN
File% = FREEFILE
OPEN "OVREDIT.DOC" FOR INPUT AS File%
HelpLoad% = 1
DO UNTIL EOF(File%)
X% = X% + 1
LINE INPUT #1, Dummy$
LOOP
CLOSE File%
REDIM HelpText$(X%)
OPEN "OVREDIT.DOC" FOR INPUT AS File%
FOR X% = 1 TO X%
LINE INPUT #1, Dummy$
HelpText$(X%) = Dummy$
NEXT X%
CLOSE File%
END IF
LOCATE Statline%, 1: PRINT SPACE$(80);
LOCATE 24, 1
COLOR 7, 0
PRINT HelpFooter$; SPACE$(80 - LEN(HelpFooter$));
VIEW PRINT 3 TO 21
CLS
B$ = CHR$(0) + "H"
Redraw:
IF B$ = CHR$(0) + "H" OR B$ = CHR$(0) + "I" OR B$ = CHR$(0) + "G" THEN
Lines$ = "  Line " + LTRIM$(RTRIM$(STR$(HelpLoc% + 1))) + " of " + LTRIM$(RTRIM$(STR$(UBOUND(HelpText$))))
ELSE
Lines$ = "  Line " + LTRIM$(RTRIM$(STR$(HelpLoc% + 18))) + " of " + LTRIM$(RTRIM$(STR$(UBOUND(HelpText$))))
END IF
VIEW PRINT
LOCATE 1, (80 - LEN(Lines$))
COLOR 7, 0
PRINT Lines$;
VIEW PRINT 4 TO 23
FOR Count% = 1 TO 18
COLOR 15, 0
IF Count% = 1 OR Count% = 18 THEN COLOR 8, 0
IF Count% = 2 OR Count% = 17 THEN COLOR 7, 0
LOCATE 3 + Count%, 1
PRINT HelpText$(Count% + HelpLoc%); SPACE$(80 - LEN(HelpText$(Count% + HelpLoc%)));
NEXT Count%
GetIt:

VIEW PRINT
COLOR 7, 0
MemStat$ = "Free Mem: " + LTRIM$(RTRIM$(STR$(FRE(-1))))
LOCATE 24, 77 - LEN(MemStat$)
PRINT MemStat$;
LOCATE 24, 80
IF HelpLoad% = 0 THEN
COLOR 8, 0
PRINT "■";
ELSE
COLOR 10, 0
PRINT "■";
END IF
VIEW PRINT 4 TO 23

DO
B$ = INKEY$
IF B$ <> "" THEN EXIT DO
LOOP
SELECT CASE B$
 CASE CHR$(0) + CHR$(31)
  COLOR 15, 0
  VIEW PRINT
  CLS
  PRINT "Free Memory: "; FRE(-1)
  PRINT
  PRINT "Type EXIT to Return to OvrEdit."
  SHELL
  SHELL LEFT$(CurrDir$, 2)
  CHDIR CurrDir$
  CLS
  GOTO StartHelp
 CASE CHR$(0) + "H"
  IF HelpLoc% = 0 THEN GOTO GetIt
  HelpLoc% = HelpLoc% - 1
 CASE CHR$(0) + "P"
  IF (Count% + HelpLoc%) = UBOUND(HelpText$) + 1 THEN GOTO GetIt
  HelpLoc% = HelpLoc% + 1
 CASE CHR$(0) + "G"
  HelpLoc% = 0
 CASE CHR$(0) + "O"
  HelpLoc% = UBOUND(HelpText$) - 18
 CASE CHR$(27)
  CLS
  VIEW PRINT
  EXIT SUB
 CASE CHR$(0) + "Q"
  IF (Count% + HelpLoc% + 18) > UBOUND(HelpText$) + 1 THEN
  HelpLoc% = UBOUND(HelpText$) - 18
  ELSE
  HelpLoc% = HelpLoc% + 18
  END IF
 CASE CHR$(0) + "I"
  IF (HelpLoc% - 18) < 1 THEN
  HelpLoc% = 0
  ELSE
  HelpLoc% = HelpLoc% - 18
  END IF
END SELECT
GOTO Redraw
LOCATE Statline%, 1
COLOR 15, 0
END SUB

SUB LineUpd (RecLoc%, OldRecLoc%)
  New% = RecLoc% + ((Page% - 1) * NoOfRecs%)
  IF New% > MaxRecord% THEN New% = MaxRecord%
  Old% = OldRecLoc% + ((Page% - 1) * NoOfRecs%)
  IF Old% > MaxRecord% THEN Old% = MaxRecord%: OldRecLoc% = 0
  LOCATE RecLoc% + 3, 1
  COLOR 11, 0
  CALL XGetElement(Handle%, OvrEdit, LEN(OvrEdit), New%)
  PRINT RTRIM$(OvrEdit.Desc)
  LOCATE RecLoc% + 3, 25
  COLOR 7, 0
  IF OvrEdit.Stringlen > 54 THEN
  PRINT LEFT$(OvrEdit.Curr, 51) + "...";
  ELSE
  PRINT RTRIM$(OvrEdit.Curr);
  END IF
  Temp$ = RTRIM$(OvrEdit.Curr)
  Colorupd Temp$
IF LEFT$(OvrEdit.Dupe, 1) <> CHR$(0) THEN
COLOR 9, 0
LOCATE 3 + RecLoc%, 23
PRINT "D";
END IF

 IF OldRecLoc% = 0 THEN EXIT SUB
  LOCATE OldRecLoc% + 3, 1
  COLOR 3, 0
  CALL XGetElement(Handle%, OvrEdit, LEN(OvrEdit), Old%)
  PRINT RTRIM$(OvrEdit.Desc)
  LOCATE OldRecLoc% + 3, 25
  COLOR 8, 0
  IF OvrEdit.Stringlen > 54 THEN
  PRINT LEFT$(OvrEdit.Curr, 51) + "...";
  ELSE
  PRINT RTRIM$(OvrEdit.Curr);
  END IF
IF LEFT$(OvrEdit.Dupe, 1) <> CHR$(0) THEN
COLOR 1, 0
LOCATE 3 + OldRecLoc%, 23
PRINT "D";
END IF

END SUB

SUB LoadCfg
Count% = 0
File% = FREEFILE
OPEN "OVREDIT.DAT" FOR INPUT AS File%
LINE INPUT #1, Temp$
IF LEN(Temp$) > 5 THEN
VersRG$ = "<unknown>"
Inpstr$ = Temp$
Temp$ = ""
GOTO SkipAgain
ELSE
VersRG$ = Temp$
Temp$ = ""
END IF

Again:
DO UNTIL EOF(File%)
IF INKEY$ = CHR$(27) THEN Abort% = 1: GOTO StopIt
LINE INPUT #1, Inpstr$
IF LEFT$(Inpstr$, 1) = ";" THEN GOTO Again
IF LEFT$(Inpstr$, 2) = "/*" THEN GOTO Again
IF LEFT$(Inpstr$, 3) = "REM" THEN GOTO Again
IF LEFT$(Inpstr$, 5) = "Cheap" THEN GOTO Again
IF LEFT$(Inpstr$, 7) = "Quality" THEN GOTO Again
IF LEFT$(Inpstr$, 7) = "Nocrack" THEN GOTO Again
IF LEFT$(Inpstr$, 6) = "Insure" THEN GOTO Again
IF LEFT$(Inpstr$, 8) = "Register" THEN GOTO Again

IF Count% <> 0 AND LEFT$(Inpstr$, 4) = "dupe" THEN
OvrEdit.Dupe = RIGHT$(Inpstr$, LEN(Inpstr$) - 4)
CALL XSetElement(Handle%, OvrEdit, LEN(OvrEdit), Count%)
OvrEdit.Dupe = CHR$(0)
GOTO Again
END IF

SkipAgain:
Count% = Count% + 1
MaxRecord% = Count%
OvrEdit.Desc = RTRIM$(LEFT$(Inpstr$, 22))
OvrEdit.Offset = VAL(MID$(Inpstr$, 23, 6))
OvrEdit.Length = VAL(MID$(Inpstr$, 29, 3))
IF OvrEdit.Length > 119 THEN OvrEdit.Length = 119
OvrEdit.Default = MID$(Inpstr$, 32, OvrEdit.Length)
CALL XSetElement(Handle%, OvrEdit, LEN(OvrEdit), Count%)
OvrEdit.Dupe = CHR$(0)
LOCATE , LEN(LoadingDat$)
PRINT Count%; "- ";
IF REG = 0 AND Count% = UnRegMax% THEN GOTO StopIt
LOOP
StopIt:
CLOSE File%
END SUB

SUB LoadOvr
File% = FREEFILE
OPEN "RENEGADE.OVR" FOR BINARY AS File%
FOR Count% = 1 TO MaxRecord%
IF INKEY$ = CHR$(27) THEN Abort% = 1: GOTO EndLoadOvr
LOCATE , LEN(LoadingOvr$) + 1
PRINT Count%; "of"; MaxRecord%; "- ";
Len$ = " "
CALL XGetElement(Handle%, OvrEdit, LEN(OvrEdit), Count%)
GET File%, OvrEdit.Offset, Len$
'IF ASC(Len$) > 80 THEN Len$ = CHR$(80)
Temp$ = SPACE$(ASC(Len$))
GET File%, OvrEdit.Offset + 1, Temp$
OvrEdit.Curr = Temp$
OvrEdit.Stringlen = LEN(Temp$)
FOR X% = 1 TO OvrEdit.Stringlen
IF INSTR(OvrEdit.Curr, CHR$(13) + CHR$(10)) <> 0 THEN MID$(OvrEdit.Curr, INSTR(OvrEdit.Curr, CHR$(13) + CHR$(10)), 2) = "^M" ELSE EXIT FOR
NEXT X%
CALL XSetElement(Handle%, OvrEdit, LEN(OvrEdit), Count%)
NEXT Count%
EndLoadOvr:
CLOSE File%
END SUB

SUB Passedupd (Temp$, More$)
  COLOR 15, 0
  FOR Count% = 1 TO LEN(More$)
  Char$ = MID$(More$, Count%, 1)
  IF Char$ = "|" AND RIGHT$(More$, 1) = "|" THEN Temp$ = "|" + Temp$: More$ = LEFT$(More$, LEN(More$) - 1): GOTO SkipMore
  IF Char$ = "|" AND LEFT$(RIGHT$(More$, 2), 1) = "|" THEN Temp$ = RIGHT$(More$, 2) + Temp$: More$ = LEFT$(More$, LEN(More$) - 2): GOTO SkipMore
  IF Char$ = "|" THEN
  Clr$ = MID$(More$, Count% + 1, 2)
IF Clr$ = "" THEN GOTO Printed1
IF ASC(LEFT$(Clr$, 1)) < 48 OR ASC(LEFT$(Clr$, 1)) > 57 THEN GOTO Printed1 ELSE Colr% = VAL(Clr$)
  IF ASC(RIGHT$(Clr$, 1)) < 48 OR ASC(RIGHT$(Clr$, 1)) > 57 THEN GOTO Printed1 ELSE Colr% = VAL(Clr$)
  IF Colr% = 0 THEN COLOR , 0: GOTO Skipproc1
  IF Colr% > 30 THEN PRINT "|"; : GOTO Printed1
  IF Colr% > 15 THEN Colr% = Colr% - 15: COLOR , Colr%:  ELSE COLOR Colr%
Skipproc1:
  Count% = Count% + 2
  END IF
Printed1:
  NEXT Count%
SkipMore:
  Leno% = 4
  LOCATE Statline%, 1: PRINT "...";
  FOR Count% = 1 TO LEN(Temp$)
  Char$ = MID$(Temp$, Count%, 1)
  IF Char$ = "|" THEN
  IF Count% = LEN(Temp$) THEN PRINT Char$; SPACE$(1); : EXIT SUB
  Clr$ = MID$(Temp$, Count% + 1, 2)
  IF ASC(LEFT$(Clr$, 1)) < 48 OR ASC(LEFT$(Clr$, 1)) > 57 THEN PRINT "|"; : Leno% = Leno% + 1: GOTO Printed2 ELSE Colr% = VAL(Clr$)
  IF ASC(RIGHT$(Clr$, 1)) < 48 OR ASC(RIGHT$(Clr$, 1)) > 57 THEN PRINT "|"; : Leno% = Leno% + 1: GOTO Printed2 ELSE Colr% = VAL(Clr$)
  IF Colr% = 0 THEN COLOR , 0: GOTO Skipproc2
  IF Colr% > 30 THEN PRINT "|"; : Leno% = Leno% + 1: GOTO Printed2
  IF Colr% > 15 THEN Colr% = Colr% - 15: COLOR , Colr%:  ELSE COLOR Colr%
Skipproc2:
  Count% = Count% + 2
  ELSE
  Leno% = Leno% + 1
  IF Leno% >= 78 THEN LOCATE Statline%, Leno% - 1: PRINT "..."; : EXIT SUB
  PRINT Char$;
  END IF
Printed2:
  NEXT Count%
  IF Leno% >= 78 THEN LOCATE Statline%, Leno% - 1: PRINT "..."; : EXIT SUB
  LOCATE Statline%, Leno%: COLOR 8, 0: PRINT SPACE$(80 - Leno%);
END SUB

DEFINT A-Z
FUNCTION QBCRC# (Segment, Offset&, Length, CRC#)
'switch to input segment
DEF SEG = Segment
'Since we're going to calculate the CRC 4 bytes at a time, this FOR/NEXT
'takes care of all the oddballs left over...
FOR A = 1 TO Length AND 3
    IF INKEY$ = CHR$(27) THEN QBCRC# = -1: EXIT FUNCTION
    'Using CINT(CRC#) AND 255 instead of CRC# AND 255 improves speed
    'but it will only work when compiled without range checking
    CRC# = CRCTable#(((CRC#) AND 255) XOR PEEK(Offset&)) XOR (((CRC# AND &HFFFFFF00) \ 256) AND &HFFFFFF)
    Offset& = Offset& + 1
NEXT
'Adjust length- divide it by 4 using unsigned division
Length = ((Length AND &HFFFC) \ 4) AND &H3FFF
'Drop into loop
GOTO B
'Updates the CRC on the next 4 bytes, doing this 4 bytes at a time
'results in a small improvement in speed, since the compiled code
'will jump less often...
A:
    IF INKEY$ = CHR$(27) THEN QBCRC# = -1: EXIT FUNCTION
    CRC# = CRCTable#(((CRC#) AND 255) XOR PEEK(Offset&)) XOR (((CRC# AND &HFFFFFF00) \ 256) AND &HFFFFFF)
    CRC# = CRCTable#(((CRC#) AND 255) XOR PEEK(Offset& + 1)) XOR (((CRC# AND &HFFFFFF00) \ 256) AND &HFFFFFF)
    CRC# = CRCTable#(((CRC#) AND 255) XOR PEEK(Offset& + 2)) XOR (((CRC# AND &HFFFFFF00) \ 256) AND &HFFFFFF)
    CRC# = CRCTable#(((CRC#) AND 255) XOR PEEK(Offset& + 3)) XOR (((CRC# AND &HFFFFFF00) \ 256) AND &HFFFFFF)
    Offset& = Offset& + 4             '4 bytes over now
    Length = Length - 1             '1 less byte
B:  IF Length <> 0 THEN GOTO A      'if more bytes then go
'All done
    QBCRC# = CRC#
END FUNCTION

DEFSNG A-Z
FUNCTION RegCheck% (Name$, Key$)
FOR X = 1 TO LEN(Name$)
Value1& = ASC(MID$(Name$, X, 1)) + Value1&
NEXT X
Value1& = (LEN(Name$) + Value1&) * LEN(Name$)
Value1& = ASC(LEFT$(Name$, 1)) + ASC(RIGHT$(Name$, 1)) + Value1&
KeyCode$ = LTRIM$(RTRIM$(STR$(LEN(LTRIM$(RTRIM$(STR$(Value1&))))))) + LTRIM$(RTRIM$(STR$(Value1&)))
Value2& = ASC(LEFT$(Name$, 1)) * LEN(Name$)
Value2& = Value2& + (ASC(RIGHT$(Name$, 1)) * LEN(Name$))
KeyCode$ = KeyCode$ + LTRIM$(RTRIM$(STR$(LEN(LTRIM$(RTRIM$(STR$(Value2&))))))) + LTRIM$(RTRIM$(STR$(Value2&)))
KeyCode$ = KeyCode$ + LTRIM$(RTRIM$(STR$(LEN(LTRIM$(RTRIM$(STR$((Value1& + Value2&) * LEN(Name$)))))))) + LTRIM$(RTRIM$(STR$((Value1& + Value2&) * LEN(Name$))))
KeyCode$ = KeyCode$ + LTRIM$(RTRIM$(STR$(Serial%)))
IF KeyCode$ = Key$ THEN RegCheck% = 1 ELSE RegCheck% = 0
END FUNCTION

SUB SaveOvr
File% = FREEFILE
OPEN "RENEGADE.OVR" FOR BINARY AS File%
FOR Count% = 1 TO MaxRecord%
CALL XGetElement(Handle%, OvrEdit, LEN(OvrEdit), Count%)
IF OvrEdit.Changed = 0 THEN GOTO NextCount:
LOCATE , LEN(Saving$) + 1
PRINT Count%; "of"; MaxRecord%;
Leno$ = CHR$(OvrEdit.Stringlen)
IF LEFT$(OvrEdit.Dupe, 1) <> CHR$(0) THEN
FOR Dup% = 1 TO LEN(RTRIM$(OvrEdit.Dupe)) STEP 6
ON ERROR GOTO 0
Duped& = VAL(MID$(OvrEdit.Dupe, Dup%, 6))
PUT File%, Duped&, Leno$
NEXT Dup%
END IF
PUT File%, OvrEdit.Offset, Leno$
FOR X% = 1 TO OvrEdit.Stringlen
IF INSTR(OvrEdit.Curr, "^M") <> 0 THEN MID$(OvrEdit.Curr, INSTR(OvrEdit.Curr, "^M"), 2) = CHR$(13) + CHR$(10) ELSE EXIT FOR
NEXT X%
Temp$ = LEFT$(OvrEdit.Curr, OvrEdit.Stringlen)
IF LEFT$(OvrEdit.Dupe, 1) <> CHR$(0) THEN
FOR Dup% = 1 TO LEN(RTRIM$(OvrEdit.Dupe)) STEP 6
LOCATE , LEN(Saving$) + 2
PRINT "Dupe #"; LTRIM$(STR$(Dup% \ 6)); "         ";
Duped& = VAL(MID$(OvrEdit.Dupe, Dup%, 6))
PUT File%, Duped& + 1, Temp$
NEXT Dup%
END IF
PUT File%, OvrEdit.Offset + 1, Temp$
NextCount:
NEXT Count%
CLOSE
PRINT
END SUB

SUB ScrnUpd
COLOR 8, 0
LOCATE 2, 1: PRINT STRING$(80, 196);
LOCATE 23, 1: PRINT STRING$(80, 196);
LOCATE 21, 1: PRINT STRING$(80, 196);
LOCATE 19, 1: PRINT STRING$(80, 196);
COLOR 7, 0
LOCATE 1, 1: PRINT Header$(1); SPACE$(80 - LEN(Header$(1)));
LOCATE 24, 1: PRINT Header$(2); SPACE$(80 - LEN(Header$(2)));
LOCATE 24, 40
LOCATE EditLine%, 1: PRINT SPACE$(80);
MemStat$ = "Free Mem: " + LTRIM$(RTRIM$(STR$(FRE(-1))))
LOCATE 24, 77 - LEN(MemStat$)
PRINT MemStat$;
PageLoc$ = "           Page " + LTRIM$(RTRIM$(STR$(Page%))) + " of " + LTRIM$(RTRIM$(STR$(MaxPage%)))
LOCATE 1, 80 - LEN(PageLoc$)
PRINT PageLoc$;
LOCATE 24, 80
IF HelpLoad% = 0 THEN
COLOR 8, 0
PRINT "■";
ELSE
COLOR 10, 0
PRINT "■";
END IF
VIEW PRINT 4 TO Statline% - 2
CLS
VIEW PRINT
COLOR 3, 0
Begin:
FOR Count% = 1 TO NoOfRecs%
IF RecordNum% = MaxRecord% THEN EXIT SUB
RecordNum% = ((Page% - 1) * NoOfRecs%) + Count%
CALL XGetElement(Handle%, OvrEdit, LEN(OvrEdit), RecordNum%)
COLOR 3, 0
LOCATE 3 + Count%, 1
PRINT RTRIM$(OvrEdit.Desc);
IF LEFT$(OvrEdit.Dupe, 1) <> CHR$(0) THEN
COLOR 1, 0
LOCATE 3 + Count%, 23
PRINT "D";
END IF
COLOR 8, 0
LOCATE 3 + Count%, 25
Temp1$ = RTRIM$(OvrEdit.Curr)
IF LEN(Temp1$) > 54 THEN Temp1$ = LEFT$(Temp1$, 51) + "..."
PRINT Temp1$; SPACE$(80 - 25 - LEN(Temp1$));
NEXT Count%
END SUB

REM $STATIC
SUB StartScreen
CLS : COLOR 8, 0: PRINT "elisstar"; : COLOR 15, 0: PRINT "                                                          ";
COLOR 1, 0: PRINT "▄▄▄"; : COLOR 9, 0: PRINT "▄▄▄";
COLOR 7, 0: PRINT "▄▄▄"; : COLOR 15, 0: PRINT "▄▄   ";
PRINT "                                                  ";
COLOR 1, 0: PRINT "▄▄▄"; : COLOR 9, 0: PRINT "▄▄▄▄";
COLOR 7, 0: PRINT "▄"; : COLOR 9, 1: PRINT "░▒▓█";
COLOR 9, 7: PRINT "▓▒"; : COLOR 7, 0: PRINT "▄";
COLOR 9, 1: PRINT "░▓█"; : COLOR 9, 7: PRINT "▓";
COLOR 9, 1: PRINT "░▓█"; : COLOR 9, 7: PRINT "▓░";
COLOR 15, 7: PRINT "░▒▓█"; : COLOR 15, 0: PRINT "  ";
PRINT "         "; : COLOR 1, 0: PRINT "▄▄▄█";
COLOR 9, 1: PRINT "▒▒▓▓██"; : COLOR 9, 0: PRINT "▄▄  ";
COLOR 1, 0: PRINT "██"; : COLOR 9, 1: PRINT "░░▒▒▓";
COLOR 15, 0: PRINT "    "; : COLOR 9, 7: PRINT "▓▒▒░░ ";
COLOR 9, 1: PRINT "░▒▒▓▓"; : COLOR 9, 7: PRINT "██▓▓";
COLOR 9, 0: PRINT "▄"; : COLOR 9, 1: PRINT " ░▒▓█";
COLOR 9, 7: PRINT "▓▒░"; : COLOR 9, 1: PRINT "▒▓█";
COLOR 9, 7: PRINT "▓▒░ "; : COLOR 15, 7: PRINT "░";
COLOR 9, 7: PRINT "█▓░"; : COLOR 9, 0: PRINT "▀";
COLOR 9, 1: PRINT "█"; : COLOR 9, 7: PRINT "▓░";
COLOR 15, 7: PRINT "░"; : COLOR 7, 0: PRINT "▀▀";
COLOR 15, 0: PRINT "▀   "; : PRINT "     ";
COLOR 1, 0: PRINT "▄▄"; : COLOR 1, 1: PRINT "  ";
COLOR 9, 1: PRINT "░░▒▒▓▓██"; : COLOR 9, 7: PRINT "▓▓▒▒░";
COLOR 7, 0: PRINT "█▄"; : COLOR 9, 1: PRINT "░▒▒▓▓█";
COLOR 15, 0: PRINT "   "; : COLOR 9, 7: PRINT "▒▒░░  ";
COLOR 9, 1: PRINT "▒▒▓▓█"; : COLOR 9, 0: PRINT "▀▀";
COLOR 9, 7: PRINT "▓▒▒░░"; : COLOR 9, 1: PRINT "▒▓█";
COLOR 9, 0: PRINT "▄"; : COLOR 7, 0: PRINT "▄▄";
COLOR 9, 1: PRINT "▒▓█"; : COLOR 9, 7: PRINT "▓";
COLOR 9, 0: PRINT "▀"; : COLOR 9, 7: PRINT "░ ";
COLOR 15, 7: PRINT "░▒"; : COLOR 9, 7: PRINT "▓░";
COLOR 15, 7: PRINT "░"; : COLOR 15, 0: PRINT " ";
COLOR 9, 7: PRINT "▓░"; : COLOR 15, 7: PRINT "░▒";
COLOR 15, 0: PRINT "      "; : PRINT "   ";
COLOR 1, 0: PRINT "▄█"; : COLOR 1, 7: PRINT "█";
COLOR 1, 1: PRINT " "; : COLOR 9, 1: PRINT "░░▒▒▓▓██";
COLOR 9, 7: PRINT "▓▓▒▒"; : COLOR 7, 0: PRINT "█████ ";
COLOR 9, 1: PRINT "▓▓██"; : COLOR 9, 7: PRINT "░░";
COLOR 15, 0: PRINT " "; : COLOR 9, 7: PRINT "▒░░  ";
COLOR 15, 7: PRINT "░"; : COLOR 15, 0: PRINT " ";
COLOR 9, 1: PRINT "▓▓██"; : COLOR 9, 7: PRINT "▓▓▒▒░░  ";
COLOR 9, 1: PRINT "▓█"; : COLOR 9, 7: PRINT "▓▒░ ";
COLOR 9, 1: PRINT "▓█"; : COLOR 9, 7: PRINT "▓▒";
COLOR 7, 0: PRINT "▄"; : COLOR 7, 7: PRINT " ";
COLOR 15, 7: PRINT "░▒▓"; : COLOR 9, 7: PRINT "░";
COLOR 15, 7: PRINT "░▓"; : COLOR 15, 0: PRINT " ";
COLOR 9, 7: PRINT "░"; : COLOR 15, 7: PRINT "░▒▓";
COLOR 15, 0: PRINT "      "; : PRINT "  ";
COLOR 1, 0: PRINT "█"; : COLOR 1, 7: PRINT "██";
COLOR 9, 1: PRINT "░░▒▒▓▓"; : COLOR 9, 0: PRINT "▀▀   ▀▀"; : COLOR 7, 0: PRINT "█";
COLOR 7, 0: PRINT "██"; : COLOR 7, 7: PRINT "  ";
COLOR 15, 7: PRINT "░░"; : COLOR 9, 1: PRINT "██";
COLOR 9, 7: PRINT "▓▓▒▒░░  "; : COLOR 15, 7: PRINT "░░";
COLOR 15, 0: PRINT " "; : COLOR 9, 1: PRINT "▓██";
COLOR 9, 7: PRINT "▓▓▒▒░░  "; : COLOR 15, 7: PRINT "░";
COLOR 9, 1: PRINT "▓█"; : COLOR 9, 7: PRINT "▓▒";
COLOR 15, 0: PRINT "   "; : COLOR 9, 1: PRINT "█";
COLOR 9, 7: PRINT "▓▒░ "; : COLOR 15, 7: PRINT "░▒▓█░▓█";
COLOR 15, 0: PRINT " "; : COLOR 15, 7: PRINT "░▒▓█";
COLOR 15, 0: PRINT "      "; : PRINT " "; : COLOR 15, 1: PRINT "  ";
COLOR 9, 1: PRINT "░░▒▒▓▓"; : COLOR 15, 0: PRINT "          ";
COLOR 9, 7: PRINT "  "; : COLOR 15, 7: PRINT "░░▒▒";
COLOR 15, 0: PRINT " "; : COLOR 9, 7: PRINT "▓▒▒░░  ";
COLOR 15, 7: PRINT "░░▒"; : COLOR 15, 0: PRINT "  ";
COLOR 9, 7: PRINT "█▓▓▒▒"; : COLOR 15, 0: PRINT "  ";
COLOR 9, 7: PRINT "  "; : COLOR 15, 7: PRINT "░░▒";
COLOR 9, 1: PRINT "█"; : COLOR 9, 7: PRINT "▓▒░ ";
COLOR 15, 7: PRINT "░▒"; : COLOR 9, 7: PRINT "▓▒░ ";
COLOR 15, 7: PRINT "░▒▓"; : COLOR 15, 0: PRINT "▀";
COLOR 7, 0: PRINT "▀▀"; : COLOR 15, 0: PRINT "▀▀ ";
COLOR 7, 0: PRINT "▀"; : COLOR 15, 0: PRINT "         ";
COLOR 7, 1: PRINT " "; : COLOR 9, 1: PRINT "░░▒▒▓▓█";
COLOR 15, 0: PRINT "           "; : COLOR 15, 7: PRINT "░░▒▒▓▓█";
COLOR 15, 0: PRINT " "; : COLOR 9, 7: PRINT "░░  ";
COLOR 15, 7: PRINT "░░▒▒"; : COLOR 15, 0: PRINT "  ";
COLOR 9, 7: PRINT "▓▓▒▒░"; : COLOR 15, 0: PRINT "    ";
COLOR 15, 7: PRINT "░▒▒▓▓▄"; : COLOR 9, 7: PRINT "░ ";
COLOR 15, 7: PRINT "░▒▓"; : COLOR 15, 0: PRINT "                       ";
COLOR 9, 1: PRINT "░▒▒▓▓██"; : COLOR 9, 7: PRINT "▓▓";
COLOR 15, 0: PRINT "        "; : COLOR 7, 0: PRINT "▄";
COLOR 15, 7: PRINT "░▒▒▓▓██"; : COLOR 15, 0: PRINT "  ";
COLOR 15, 7: PRINT "  ░░▒▒▓"; : COLOR 15, 0: PRINT "   ";
COLOR 9, 7: PRINT "▒▒░░ "; : COLOR 15, 0: PRINT "     ▀▀▀▀▀                            ";
PRINT " "; : COLOR 9, 1: PRINT "▓▓██"; : COLOR 9, 7: PRINT "▓▓▒▒░";
COLOR 7, 0: PRINT "▄▄▄▄▄"; : COLOR 15, 7: PRINT "░░▒▒▓▓██";
COLOR 15, 0: PRINT "█▀   "; : COLOR 15, 7: PRINT "░▒▒▓▓";
COLOR 15, 0: PRINT "                                               ";
PRINT "  "; : COLOR 9, 1: PRINT "█"; : COLOR 9, 7: PRINT "▓▓▒▒░░   ";
COLOR 15, 7: PRINT "░░▒▒▓▓██"; : COLOR 15, 0: PRINT "██▀                               by Electric Visionary     ";
PRINT "    "; : COLOR 7, 0: PRINT "▀▀"; : COLOR 9, 7: PRINT "░  ";
COLOR 15, 7: PRINT "░░▒▒▓▓██"; : COLOR 15, 0: PRINT "█▀▀▀                                                           ";
PRINT "         "; : COLOR 7, 0: PRINT "▀▀▀▀";
COLOR 15, 0: PRINT "▀▀▀"
COLOR 8, 0
PRINT
PRINT "────────────────────────────────────────────────────────────────────────────────";
PRINT "                                                                                ";
PRINT "                                                                                ";
PRINT "                                                                                ";
PRINT "                                                                                ";
PRINT "                                                                                ";
PRINT "                                                                                ";
PRINT "                                                                                ";
PRINT "                                                                                ";
PRINT "────────────────────────────────────────────────────────────────────────────────";
COLOR 7, 0

END SUB

REM $DYNAMIC
SUB StringEdit (RecLoc%)
SplitForward% = 78
SplitBackward% = 40
PASSED = 0
Edited = 0
Record% = ((Page% - 1) * NoOfRecs%) + RecLoc%
LOCATE EditLine%, 1
COLOR 11, 3
CALL XGetElement(Handle%, OvrEdit, LEN(OvrEdit), Record%)
Temp$ = LEFT$(OvrEdit.Curr, OvrEdit.Stringlen)
IF LEN(Temp$) > SplitForward% THEN More$ = LEFT$(Temp$, (SplitForward% \ 2)): Temp$ = RIGHT$(Temp$, LEN(Temp$) - SplitForward% \ 2): PASSED = 1
IF PASSED = 0 AND OvrEdit.Length >= 80 THEN
PRINT Temp$ + STRING$(80 - (LEN(Temp$)), "▒")
ELSE
PRINT Temp$ + STRING$(OvrEdit.Length - (LEN(Temp$ + More$)), "▒")
END IF
IF PASSED = 0 THEN Colorupd Temp$ ELSE Passedupd Temp$, More$: COLOR 11, 3
GOTO StartEdit
ReStart:
IF PASSED = 0 THEN Colorupd Temp$ ELSE Passedupd Temp$, More$: COLOR 11, 3
Record% = ((Page% - 1) * NoOfRecs%) + RecLoc%
CALL XGetElement(Handle%, OvrEdit, LEN(OvrEdit), Record%)
LOCATE EditLine%, 1
COLOR 11, 3
IF PASSED = 0 AND OvrEdit.Length >= 80 THEN
PRINT Temp$; STRING$(80 - LEN(Temp$ + More$), "▒")
ELSE
PRINT Temp$; STRING$(OvrEdit.Length - (LEN(Temp$ + More$)), "▒")
END IF
StartEdit:
COLOR 11, 3
A$ = INKEY$
IF A$ = "" GOTO StartEdit
IF A$ = CHR$(0) + "R" THEN Edited = 1
IF A$ = CHR$(0) + "?" AND OvrEdit.Length < SplitForward% THEN
Edited = 0
Temp$ = LEFT$(OvrEdit.Default$, OvrEdit.Length)
LOCATE EditLine%, 1
PRINT Temp$; STRING$(OvrEdit.Length - LEN(Temp$), "▒")
END IF
IF A$ = CHR$(0) + "?" AND OvrEdit.Length >= SplitForward% THEN
Edited = 0
Temp$ = LEFT$(OvrEdit.Default$, OvrEdit.Length)
More$ = LEFT$(Temp$, (SplitForward% \ 2))
Temp$ = RIGHT$(Temp$, LEN(Temp$) - SplitForward% \ 2):  PASSED = 1
LOCATE EditLine%, 1
PRINT Temp$; STRING$(OvrEdit.Length - (LEN(Temp$ + More$)), "▒");
COLOR , 0
PRINT SPACE$(80 - (OvrEdit.Length - SplitForward% \ 2));
END IF
IF A$ = CHR$(8) AND PASSED = 0 AND LEN(Temp$) <> 0 THEN Temp$ = LEFT$(Temp$, LEN(Temp$) - 1): LOCATE EditLine%, 1: PRINT Temp$; "▒"; : Edited = 1
IF A$ = CHR$(8) AND PASSED = 1 AND LEN(Temp$ + More$) = SplitBackward% + 1 THEN PASSED = 0: Temp$ = LEFT$(More$ + Temp$, LEN(More$ + Temp$) - 1): More$ = "": LOCATE EditLine%, 1: PRINT Temp$; STRING$(80 - LEN(Temp$), "▒"); : Edited = 1
IF A$ = CHR$(8) AND PASSED = 1 AND LEN(Temp$ + More$) THEN Temp$ = LEFT$(Temp$, LEN(Temp$) - 1): LOCATE EditLine%, 1: PRINT Temp$; "▒"; : Edited = 1
IF A$ = CHR$(13) AND PASSED = 0 THEN OvrEdit.Changed = 1: OvrEdit.Stringlen = LEN(Temp$): OvrEdit.Curr = Temp$: CALL XSetElement(Handle%, OvrEdit, LEN(OvrEdit), Record%): EXIT SUB
IF A$ = CHR$(13) AND PASSED = 1 THEN OvrEdit.Changed = 1: OvrEdit.Stringlen = LEN(More$ + Temp$): OvrEdit.Curr = More$ + Temp$: CALL XSetElement(Handle%, OvrEdit, LEN(OvrEdit), Record%): EXIT SUB
IF A$ = CHR$(25) THEN Temp$ = "": More$ = "": PASSED = 0: COLOR , 0: LOCATE Statline%, 1: PRINT SPACE$(80); : GOTO ReStart
IF A$ = CHR$(27) THEN EXIT SUB
IF A$ = CHR$(0) + CHR$(31) THEN
 COLOR 15, 0
 CLS
 PRINT "Free Memory: "; FRE(-1)
 PRINT
 PRINT "Type EXIT to Return to OvrEdit."
 SHELL
 SHELL LEFT$(CurrDir$, 2)
 CHDIR CurrDir$
 CLS
 ScrnUpd
 IF PASSED = 0 THEN Colorupd Temp$ ELSE Passedupd Temp$, More$: COLOR 11, 3
 GOTO ReStart
END IF
IF PASSED = 0 AND INSTR(Include$, UCASE$(A$)) <> 0 AND Edited = 0 THEN Temp$ = A$: Edited = 1: COLOR , 0: LOCATE Statline%, 1: PRINT SPACE$(80); : GOTO ReStart
IF PASSED = 0 AND LEN(Temp$) = SplitForward% AND INSTR(Include$, UCASE$(A$)) <> 0 AND Edited = 1 THEN More$ = LEFT$(Temp$, (SplitForward% \ 2)): Temp$ = RIGHT$(Temp$, LEN(Temp$) - SplitForward% \ 2) + A$: Edited = 1: COLOR 11, 3: LOCATE EditLine%, 1 _
: PRINT STRING$(OvrEdit.Length - (SplitForward% \ 2), "▒"); : COLOR , 0: PRINT SPACE$(80 - (OvrEdit.Length - SplitForward% \ 2)); : Passedupd Temp$, More$: COLOR 11, 3: PASSED = 1: GOTO ReStart
IF PASSED = 0 AND LEN(Temp$) < OvrEdit.Length AND INSTR(Include$, UCASE$(A$)) <> 0 THEN Temp$ = Temp$ + A$: LOCATE EditLine%, 1: PRINT Temp$
IF PASSED = 1 AND INSTR(Include$, UCASE$(A$)) <> 0 AND Edited = 0 THEN Temp$ = A$: Edited = 1: PASSED = 0: COLOR 11, 3: LOCATE EditLine%, 1: PRINT STRING$(80, "▒"); : Colorupd Temp$: GOTO ReStart
IF PASSED = 1 AND LEN(Temp$ + More$) < OvrEdit.Length AND INSTR(Include$, UCASE$(A$)) <> 0 THEN Temp$ = Temp$ + A$: LOCATE EditLine%, 1: PRINT Temp$
IF PASSED = 0 THEN Colorupd Temp$ ELSE Passedupd Temp$, More$: COLOR 11, 3
GOTO StartEdit:
END SUB
