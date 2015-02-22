/*
 * HDroidGUI - Harbour for Android GUI framework
 * Main header file
 */

#define MATCH_PARENT   -1
#define WRAP_CONTENT   -2

#xcommand ACTIVITY <oAct> TITLE <cTitle>    ;
             [ ON INIT <bInit> ]            ;
             [ ON EXIT <bExit> ]            ;
          => ;
   <oAct> := HDActivity():New( <cTitle>,<bInit>,<bExit> )


#xcommand BEGIN LAYOUT <oLay>               ;
             [<lHorz: HORIZONTAL>]          ;
             [ SIZE <width>, <height> ]     ;
             [ BACKCOLOR <bcolor> ]         ;
             [ FONT <oFont> ]               ;
          => ;
   <oLay> := HDLayout():New( <.lHorz.>,<width>,<height>,<bcolor>,<oFont> );
    [; hd_SetCtrlName( <oLay>,<(oLay)> )]

#xcommand END LAYOUT <oLay>   ;
          => ;
   <oLay>:oDefaultParent := <oLay>:oParent

#xcommand TEXTVIEW <oText>                  ;
             [ TEXT <cText> ]               ;
             [ SIZE <width>, <height> ]     ;
             [ TEXTCOLOR <tcolor> ]         ;
             [ BACKCOLOR <bcolor> ]         ;
             [ FONT <oFont> ]               ;
          => ;
   <oText> := HDTextView():New( <cText>,<width>,<height>,<tcolor>,<bcolor>,<oFont> );
    [; hd_SetCtrlName( <oText>,<(oText)> )]

#xcommand BUTTON <oBtn>                     ;
             [ TEXT <cText> ]             ;
             [ SIZE <width>, <height> ]     ;
             [ TEXTCOLOR <tcolor> ]         ;
             [ BACKCOLOR <bcolor> ]         ;
             [ FONT <oFont> ]               ;
             [ ON CLICK <bClick> ]          ;
          => ;
   <oBtn> := HDButton():New( <cText>,<width>,<height>,<tcolor>,<bcolor>,<oFont>,<bClick> );
   [; hd_SetCtrlName( <oBtn>,<(oBtn)> )]

#xcommand EDITBOX <oEdit>                   ;
             [ TEXT <cText> ]             ;
             [ HINT <cHint> ]               ;
             [ SIZE <width>, <height> ]     ;
             [ TEXTCOLOR <tcolor> ]         ;
             [ BACKCOLOR <bcolor> ]         ;
             [ FONT <oFont> ]               ;
          => ;
   <oEdit> := HDEdit():New( <cText>,<width>,<height>,<tcolor>,<bcolor>,<oFont>,<cHint> );
    [; hd_SetCtrlName( <oEdit>,<(oEdit)> )]

#xcommand CHECKBOX <oChe>                   ;
             [ TEXT <cText> ]             ;
             [ SIZE <width>, <height> ]     ;
             [ TEXTCOLOR <tcolor> ]         ;
             [ BACKCOLOR <bcolor> ]         ;
             [ FONT <oFont> ]               ;
          => ;
   <oChe> := HDCheckBox():New( <cText>,<width>,<height>,<tcolor>,<bcolor>,<oFont> );
    [; hd_SetCtrlName( <oChe>,<(oChe)> )]
