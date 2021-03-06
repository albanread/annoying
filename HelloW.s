;    s.HelloW
;


; headers

        GET     ^.AsmHdrs.h.SWINames

; macro


        MACRO
$label  ADDL    $reg, $var
        LCLA    count
        LCLA    varcopy
        LCLA    value
varcopy SETA    $var
count   SETA    0
        WHILE   varcopy > 0
      [ varcopy :AND: 3 = 0
varcopy SETA    varcopy :SHR: 2
count   SETA    count + 2
      |
value   SETA    (varcopy :AND: 255) :SHL: (count)
        ADD     $reg, $reg, #&$value
varcopy SETA    varcopy :SHR: 8
count   SETA    count + 8
      ]
        WEND
        MEND


        MACRO
$label  ADDR    $reg, $dest, $cond
$label  ADR$cond.L $reg, $dest
        MEND

                GBLA    addr_verbose
addr_verbose    SETA    0
        MACRO
$label  addr    $reg, $object, $cc
        LCLA    value
value   SETA    .-$object+8
        Immediate &$value
 [ immediate
$label  ADR$cc  $reg, $object
  [ addr_verbose :AND: 1 <> 0
 ! 0,"addr saved a word"
  ]
 |
$label  ADR$cc.L $reg, $object
  [ addr_verbose :AND: 2 <> 0
 ! 0,"addr didn't save a word"
  ]
 ]
        MEND


        MACRO
$label  DEC     $reg,$by
        [ "$by" = ""
$label  SUB     $reg,$reg,#1
        |
$label  SUB     $reg,$reg,#$by
        ]
        MEND



        MACRO
$label  DivRem  $rc, $ra, $rb, $rtemp, $norem
$label
     [ NoARMVE
        MOV     $rtemp, $rb
        CMP     $rtemp, $ra, LSR #1
01
        MOVLS   $rtemp, $rtemp, LSL #1
        CMPLS   $rtemp, $ra, LSR #1
        BLS     %BT01
        MOV     $rc, #0
02
        CMP     $ra, $rtemp
        SUBCS   $ra, $ra, $rtemp
        ADC     $rc, $rc, $rc
        MOV     $rtemp, $rtemp, LSR #1
        CMP     $rtemp, $rb
        BCS     %BT02
     ELIF ("$rb" :LEFT: 1) == "#"
        MOV     $rtemp, $rb
        UDIV    $rc, $ra, $rtemp
      [ "$norem" == ""
        MLS     $ra, $rtemp, $rc, $ra
      ]
     |
        UDIV    $rc, $ra, $rb
      [ "$norem" == ""
        MLS     $ra, $rb, $rc, $ra
      ]
     ]
        MEND

        MACRO
$label  Error   $errno, $errstr
$label  ADR     R0, %FT01
        SWI     OS_GenerateError
01
        &       $errno
        =       "$errstr", 0
        ALIGN
        MEND


        MACRO
$label  INC     $reg,$by
        [ "$by" = ""
$label  ADD     $reg,$reg,#1
        |
$label  ADD     $reg,$reg,#$by
        ]
        MEND



        MACRO
$label  MULTIPLY $rc, $ra, $rb
$label  MUL     $rc, $rb, $ra ; sexy 2u version with regs in the right order
        MEND




        MACRO
$label  Pull    $reglist, $cond, $hat
        ; loop to find "-" or "," in reglist - if
        ; not we can optimise a single-register
        ; load to be faster on SA, ARM9.
        ; fails (loudly) if RLIST directive in use
        LCLS   temps
        LCLL   onereg
temps   SETS   "$reglist"
onereg  SETL   "$hat" = ""
        WHILE  onereg :LAND: :LEN: temps > 0
        [ temps :LEFT: 1 = "," :LOR: temps :LEFT: 1 = "-"
onereg  SETL   {FALSE}
        ]
temps   SETS   temps :RIGHT: (:LEN: temps - 1)
        WEND
        [ onereg
$label  LDR$cond $reglist, [r13], #4
        |
$label  LDM$cond.FD r13!, {$reglist}$hat
        ]
        MEND


        MACRO
$label  Push   $reglist, $cond
        LCLS   temps
        LCLL   onereg
temps   SETS   "$reglist"
onereg  SETL   {TRUE}
        WHILE  onereg :LAND: :LEN: temps > 0
        [ temps :LEFT: 1 = "," :LOR: temps :LEFT: 1 = "-"
onereg  SETL   {FALSE}
        ]
temps   SETS   temps :RIGHT: (:LEN: temps - 1)
        WEND
        [ onereg
$label  STR$cond $reglist, [r13, #-4]!
        |
$label  STM$cond.FD r13!, {$reglist}
        ]
        MEND


        MACRO
$label  Swap    $ra, $rb, $cc
$label  EOR$cc  $ra, $ra, $rb
        EOR$cc  $rb, $ra, $rb
        EOR$cc  $ra, $ra, $rb
        MEND




; constants

; window flags

WF_Movable              EQU     &2
WF_WimpRedraws          EQU     &10
WF_Pane                 EQU     &20
WF_Outside              EQU     &40
WF_NoBackClose          EQU     &80
WF_ScrollReqAR          EQU     &100
WF_ScrollReq            EQU     &200
WF_GCOLours             EQU     &400
WF_NoBelow              EQU     &800
WF_HotKeys              EQU     &1000
WF_StayOnScreen         EQU     &2000
WF_IgnoreR              EQU     &4000
WF_IgnoreL              EQU     &8000
WF_OpenQ                EQU     &10000
WF_OnTopQ               EQU     &20000
WF_FullSizeQ            EQU     &40000
WF_ToggleSizeQ          EQU     &80000
WF_InputFocusQ          EQU     &100000
WF_ForceOnScreenQ       EQU     &200000
WF_BackIcon             EQU     &81000000
WF_CloseIcon            EQU     &82000000
WF_TitleBar             EQU     &84000000
WF_ToggleSizeIcon       EQU     &88000000
WF_VScrollBar           EQU     &90000000
WF_AdjSizeIcon          EQU     &a0000000
WF_HScrollBar           EQU     &c0000000

WFLAG  EQU  WF_Movable :OR:  WF_ScrollReqAR  :OR:  WF_IgnoreR   :OR:  WF_IgnoreL  :OR:  WF_BackIcon  :OR:  WF_CloseIcon  :OR:  WF_VScrollBar  :OR:  WF_AdjSizeIcon  :OR: WF_HScrollBar  :OR:  WF_ToggleSizeIcon  :OR: WF_TitleBar :OR: WF_StayOnScreen

; windowblock offsets
;
wminx      EQU  0
wminy      EQU  4
wmaxx      EQU  8
wmaxy      EQU 12
xscrl      EQU 16
yscrl      EQU 20
bhind      EQU 24
wflags     EQU 28
tfg        EQU 32
tbg        EQU 33
wafg       EQU 34
wabg       EQU 35
sboc       EQU 36
sbic       EQU 37
tbgf       EQU 28
extra      EQU 39
waminy     EQU 40
waminx     EQU 44
wamaxx     EQU 48
wamaxy     EQU 52
tbflags    EQU 56
wbtype     EQU 60
sablock    EQU 64
minw       EQU 68
minh       EQU 70
title      EQU 72
numcons    EQU 84
icon0      EQU 88

; characters
;

TAB     *       9
CR      *       13
LF      *       10
HSP     *       31             ; hard space
Esc     *       27

        AREA    |data|, DATA,  READWRITE

        ALIGN   256

task    DCB     "TASK"
name    DCB      "A Wimp TASK", 0
        DCD  0



; filter wimp messages
;
wanted  DCB  1,2,3,4,5,6,7,8,9,10,11,12,17,18,19,0

mask    DCD  2_11100000110001

        ALIGN 256


sprname DCB  "offscn", 0, 0
hello   DCB  "Hello", 0
        ALIGN
clkit   DCB  "Clicked on it", 0
        ALIGN
bye     DCB  "Bye",0
        ALIGN
ureq    DCB  "User Request message",0
        ALIGN
prebye  DCB  "Ready to quit?",0
        ALIGN
bytes   DCB  " Bytes available", 0
        ALIGN
m1      DCB  "Message# ", 0
        ALIGN
m2      DCB  " Action# ", 0
        ALIGN
m3      DCB  " Quit? ", 0
        ALIGN
m4      DCB  " Polls: ", 0
        ALIGN

minver  DCD 310                     ; required os version


; variables

osver   DCD     0                   ; our OS version
thndl   DCD     0                   ; our Wimp task Handle
ramlim  DCD     0                   ; end of our memory
send    DCD     0                   ; end of scratch

        ALIGN   256

evtcd   DCD     0                   ; event code

hwnd    DCD     0

poll                                ; Wimp Poll block
                                  ; some useful poll values
pollwd  DCD     0                   ; poll word
sender  DCD     0                   ; Sender handle
fini    DCD     0                   ; finished?
action  DCD     0                   ; poll action
trips   DCD     0                   ; messages polled.

settingsblk
        DCD     0                   ; used for handle
winsize
        DCD     0                   ; min x
        DCD     0                   ; min y
        DCD     0                   ; max x
        DCD     0                   ; max y

        DCD     0                   ; sx
        DCD     0                   ; sy

        DCD     0                   ; r minx
        DCD     0                   ; r miny
        DCD     0                   ; r maxx
        DCD     0                   ; r maxy

        DCD     0                   ; whatever

        ALIGN   256

; spritea
;

sprtptr
        DCD     0
sprx    DCD     800
spry    DCD     600
sprdir  DCD     0

sprcoord
        DCD     0
        DCD     -32


; initial settings used to create/open our window.
;



whwnd  DCD 0
winsetting                           ; used to open window.
wincoords
        DCD  100, 100, 1636, 1124    ; minx, miny, maxx, maxy
winscroll
        DCD  0, 0                    ; scroll
winbehind
        DCD  -1                      ; behind
winflags
        DCD WFLAG                    ; &FF00C152
wincols                              ; colours
        DCB  7, 2, 1, 0
        DCB  3, 1, 12, 0
winwa                                ; work area
        DCD  0,0,1536,1024

        DCD  &3D                     ; tiflags
        DCD  BT_ClickAR              ; wbtype
        DCD  1                       ; sprite area 1=wimp
        DCW  1536, 1024              ; min size (words)

wintitle
        DCB     "My Window",0,0,0,0,0,0
        ALIGN
winicons
        DCD  0
        SPACE 512


; button constants
;


BT_Ignore      EQU &0000
BT_Over        EQU &1000
BT_ClickAR     EQU &2000
BT_Click       EQU &3000
BT_Release     EQU &4000
BT_2Click      EQU &5000
BT_ClickDrag   EQU &6000
BT_ReleaseDrag EQU &7000
BT_2ClickDrag  EQU &8000
BT_OverClick   EQU &9000
BT_1Drag2      EQU &a000
BT_1Drag       EQU &b000
BT_CaretDrag   EQU &e000
BT_Caret       EQU &f000


; offsets

wherex  EQU     0
wherey  EQU     4
whereb  EQU     8
whereh  EQU     12
wherei  EQU     16
wheresz EQU     24




; -- Memory Map ----------------------------------


slot         EQU    8388606
topmem       EQU    8388606
sbase        EQU    4177920
sasize       EQU    3500000
sp0          EQU    sbase - 1024

where        EQU    sp0 - 16384
sprsav       EQU    where - 512
scratch      EQU    sprsav - 512

; -- --------------------------------------------
updt       EQU    scratch - 512
updt_hndl  EQU    updt + 0
updt_x     EQU    updt + 4
updt_y     EQU    updt + 8
updt_xx    EQU    updt + 12
updt_xy    EQU    updt + 16
updt_sx    EQU    updt + 20
updt_sy    EQU    updt + 24
updt_rx    EQU    updt + 28
updt_ry    EQU    updt + 32
updt_rxx   EQU    updt + 36
updt_rxy   EQU    updt + 40


; program code

        AREA    |code|, CODE,  READONLY

        CODE32
        ALIGN   256


toSprite

       Push  "r0-r4, lr"
       ADDR  r4, sprdir
       LDR   r0, [r4]
       CMP   r0, #1
       Pull "r0-r4, pc", EQ

       MOV   r0, #1
       STR   r0, [r4]
       LDR  r1, =sbase

       LDR   r0, =316
       ADDR  r2, sprname
       MOV   r3, #0

       SWI   OS_SpriteOp
       LDR   r4, =sprsav
       STR   r0, [r4, #4]!
       STR   r1, [r4, #4]!
       STR   r2, [r4, #4]!
       STR   r3, [r4, #4]!
       Pull "r0-r4, pc"

toScreen

       Push  "r0-r4, lr"
       ADDR  r4, sprdir
       LDR   r0, [r4]
       CMP   r0, #0
       Pull  "r0-r4, pc", EQ

       MOV   r0, #0
       STR   r0, [r4]

       LDR  r1, =sbase
       LDR  r4, =sprsav

       LDR   r0, [r4, #4]!
       LDR   r1, [r4, #4]!
       LDR   r2, [r4, #4]!
       LDR   r3, [r4, #4]!
       SWI   OS_SpriteOp
       Pull  "r0-r4,pc"

makeFromScreen

       Push  "r0-r8,lr"
       LDR   r0, =256+16
       LDR   r1, =sbase
       ADDR  r2, sprname
       MOV   r3, #0
       MOV   r4, #0
       MOV   r5, #0
       LDR   r6, =1526
       LDR   r7, =1012
       SWI   OS_SpriteOp
       ADDR  r8, sprtptr
       STR   r2, [r8]
       Pull "r0-r8, pc"

initSprites
       Push  "r0-r5, lr"
       LDR   r4, =sbase
       LDR   r0, =sasize
       STR   r0, [r4]
       MOV   r0, #0
       STR   r0, [r4, #4]!
       MOV   r0, #16
       STR   r0, [r4, #4]!
       STR   r0, [r4, #4]!
       LDR   r1, =sbase
       LDR   r0, =256+9
       SWI   OS_SpriteOp
       BL    makeFromScreen
       Pull  "r0-r5, pc"


plotSpriteAt

       Push  "r0-r5, lr"
       LDR   r0, =512+34
       MOV   r1, #0
       LDR   r1, =sbase
       ADDR  r2, sprtptr
       LDR   r2, [r2]
       LDR   r3, = 100
       LDR   r4, = 110
       MOV   r5, #0
       SWI   OS_SpriteOp
       Pull  "r0-r5, pc"


; -------------------------------------------------
; ENTRY
; -------------------------------------------------

        ENTRY

        LDR     r0, =slot
        MOV     r1, #-1
        SWI     Wimp_SlotSize

        LDR     r0, =sp0
        MOV     r13, r0

        BL      initSprites

        BL      toSprite

        MOV     r1, #0        ;
        ADDL    r1, &FAFAFA   ; white-ish
        MOV     r0, #16       ; graphics bg
        SWI     OS_SetColour

        MOV     r1, #0        ;
        ADDL    r1, &FF000F   ;
        MOV     r0, #0        ; graphics fg
        SWI     OS_SetColour


        MOV     r0, #16       ; clg on sprite
        SWI     OS_WriteC

        MOV     r1, #200
        MOV     r2, #200
        MOV     r0, #180
        SWI     OS_Plot

        MOV     r0, #5
        SWI     OS_WriteC

        ADDR    r0, hello
        SWI     OS_Write0
        SWI     OS_NewLine

        BL      toScreen

        MOV     r0, #1
        ADDR    r8, task
        LDR     r1, [r8]        ; "TASK"
        ADDR    r8, minver
        LDR     r0, [r8]
        ADDR    r2, name
        ADDR    r3, wanted
        SWI     Wimp_Initialise
        ADDR    r8,  osver
        STR     r0, [r8, #4]!   ; osver
        STR     r1, [r8]        ; taskhandle to handle

        ; make and open window

        ADDR    r1, winsetting

        SWI     Wimp_CreateWindow
        ADDR    r2, hwnd
        STR     r0, [r2]

        ADDR    r1, whwnd
        STR     r0, [r1]

        SWI     Wimp_OpenWindow

        ; WIMP POLL

        EOR     r0, r0, r0
        ADDR    r8,fini
        STR     r0,[r8]


polling




pollwimp

        MOV     r0, #1
        ADDR    r1, poll
        ADDR    r3, wanted
        ADDR    r2, thndl           ; our task handle
        LDR     r2, [r2]
        SWI     Wimp_Poll

        ADDR    r2, evtcd
        STR     r0, [r2]             ; message type
        ADDR    r3, action
        LDR     r1, [r2,#16]         ; message action
        STR     r1, [r3]

        CMP     r0, #0
        BEQ     qquit

        ADDR    r1, poll

amesg
       ; MOV    r6, r0
       ; BL     saymsg
       ; MOV    r0, r6

msg1
        CMP     r0, #1      ; draw win
        BEQ     OnRedraw

msg2
        CMP     r0, #2      ; open win message (e.g. it moved)
        BNE     msg3
        SWI     Wimp_OpenWindow
        B       qquit

msg3    CMP     r0, #3      ; close win and quit
        BNE     msg4

        SWI     Wimp_DeleteWindow
        ADDR    r2, thndl
        LDR     r0, [r2]
        SWI     Wimp_CloseDown
        SWI     OS_Exit


msg4    CMP     r0, #4            ; pointer leaving
        BLEQ    ptrleave
        BEQ     qquit

msg5    CMP     r0, #5            ; pointer entering
        BLEQ    ptrenter
        BEQ     qquit

msg6    CMP     r0, #6            ; mouse click
        BNE     msg18

        LDR     r2, =where        ; track where clicked.
        LDR     r0, [r1,#wherex]  ; x
        STR     r0, [r2,#wherex]
        LDR     r0, [r1,#wherey]  ; y
        STR     r0, [r2,#wherey]
        LDR     r0, [r1,#whereb]  ; button
        STR     r0, [r2,#whereb]
        LDR     r3, [r1,#whereh]  ; handle
        STR     r3, [r2,#whereh]
        LDR     r0, [r1,#wherei]  ; icon
        STR     r0, [r8,#wherei]

        MOV     r0, r3
        MOV     r1, #-1
        MOV     r2, #0
        MOV     r3, #-1
        MOV     r4, #32
        MOV     r5, #-1
        SWI     Wimp_SetCaretPosition


        B       qquit


msg18   CMP     r0, #18       ; user message
        BNE     msg17
        ; ..
        B       polling

msg17   CMP     r0, #17
        BNE     qquit
        CMP     r7, #8
        BLEQ    preq
        BEQ     qquit
        CMP     r7, #0        ; quit message
        BEQ     quit



qquit
        ADDR    r2, fini      ; ready to quit?
        LDR     r2, [r2]
        CMP     r2, #1
        BNE     polling



quit

        ADDR    r8, thndl
        LDR     r0, [r8]
        SWI     Wimp_CloseDown
        SWI     OS_Exit


OnRedraw

        ; clip graphics to our window.



        Push    "r0-r2"

        ADDR    r0, hwnd
        LDR     r0, [r0]
        LDR     r1, =updt_hndl
        STR     r0, [r1]
        SWI     Wimp_RedrawWindow

        CMP     r0, #0
        Pull    "r0-r2", EQ
        BEQ     qquit

        MOV     r2, #0

nextrect

        ; !This does not always set the graphics clipping region
        ; like it really should ...

        LDR     r1, =updt_hndl
        SWI     Wimp_GetRectangle

        LDR     r1, =updt_rx

therect
        Push    "r0-r7"
        LDR     r4, [r1]
        LDR     r5, [r1, #4]!
        LDR     r6, [r1, #4]!
        LDR     r7, [r1, #4]!

        ; set origin to our window
        MOV     r0, #29
        SWI     OS_WriteC
        MOV     r0, r4
        SWI     OS_WriteC
        MOV     r0, r5
        SWI     OS_WriteC
        Pull    "r0-r7"



        CMP     r2, #0
        BLEQ    drawthing

        CMP    r0, #0
        Pull    "r0-r2", EQ
        BEQ    qquit

        INC    r2
        B      nextrect

; say message


;
;saymsg
;        ADDR    r0, m1
;        SWI     OS_Write0
;
;        ADDR    r8, evtcd
;        LDR     R0, [r8]
;        MOV     r2, #160
;        ADDR    r1, scratch
;        SWI     OS_ConvertInteger4
;        ADDR    r0, scratch
;        SWI     OS_Write0
;
;        ADDR    r0, m2
;        SWI     OS_Write0
;
;        ADDR    r8, action
;        LDR     R0, [r8]
;        MOV     r2, #160
;        ADDR    r1, scratch
;        SWI     OS_ConvertHex8
;        ADDR    r0, scratch
;        SWI     OS_Write0
;
;        ADDR    r0, m3
;        SWI     OS_Write0
;
;        ADDR    r8, fini
;        LDR     R0, [r8]
;        MOV     r2, #160
;        ADDR    r1, scratch
;        SWI     OS_ConvertInteger4
;        ADDR    r0, scratch
;        SWI     OS_Write0
;
;        ADDR    r0, m4
;        SWI     OS_Write0
;
;        ADDR    r8, trips
;        LDR     R0, [r8]
;        MOV     r2, #160
;        ADDR    r1, scratch
;        SWI     OS_ConvertInteger4
;        ADDR    r0, scratch
;        SWI     OS_Write0
;
;
;        SWI     OS_NewLine
;        MOV     r15, r14


ptrenter
ptrleave


preq
        MOV     r15, r14


drawthing
       Push    "r0-r2,lr"
       BL      plotSpriteAt
       Pull    "r0-r2,pc"



        END




