/*
 * HDroidGUI - Harbour for Android GUI framework
 * Main header file
 */

#define HDROIDGUI_VERSION         "0.2"
#define HDROIDGUI_BUILD           3

#define MATCH_PARENT   -1
#define WRAP_CONTENT   -2

#define FONT_NORMAL     0
#define FONT_SANS       1
#define FONT_SERIF      2
#define FONT_MONOSPACE  3

#define FONT_BOLD         1
#define FONT_ITALIC       2
#define FONT_BOLD_ITALIC  3

#xcommand INIT WINDOW <oAct> TITLE <cTitle> ;
             [ ON INIT <bInit> ]            ;
             [ ON EXIT <bExit> ]            ;
          => ;
   <oAct> := HDActivity():New( <cTitle>,<bInit>,<bExit> )

#xcommand ACTIVATE WINDOW <oAct> ;
          => ;
   <oAct>:Activate()


#xcommand ACTIVITY <oAct> TITLE <cTitle>    ;
             [ ON INIT <bInit> ]            ;
             [ ON EXIT <bExit> ]            ;
          => ;
   <oAct> := HDActivity():New( <cTitle>,<bInit>,<bExit> )

#xcommand ACTIVATE ACTIVITY <oAct> ;
          => ;
   <oAct>:Activate()


#xcommand INIT DIALOG <oDlg> [TITLE <cTitle>] ;
             [ ON INIT <bInit> ]            ;
             [ ON EXIT <bExit> ]            ;
          => ;
   <oDlg> := HDDialog():New( <cTitle>,<bInit>,<bExit> )

#xcommand ACTIVATE DIALOG <oDlg> ;
          => ;
   <oDlg>:Activate()


#xcommand MENU [ ID <nId> ] [ TITLE <cTitle> ] ;
          => ;
    HDActivity():oDefaultParent:AddMenu( <nId>, <cTitle> )

#xcommand ENDMENU => HDActivity():oDefaultParent:EndMenu()

#xcommand MENUITEM <title> [ ID <nId> ]   ;
            ACTION <act>                  ;
          => ;
    HDActivity():oDefaultParent:AddMenuItem( <title>, <nId>, <{act}> )


#xcommand PREPARE FONT <oFont>     ;
             [ FACE <face> ]       ;
             [ STYLE <style> ]     ;
             [ HEIGHT <height> ]   ;
          => ;
    <oFont> := HDFont():Add( <face>, <style>, <height> )

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
             [<lScroll: SCROLL>]            ;
          => ;
   <oText> := HDTextView():New( <cText>,<width>,<height>,<tcolor>,<bcolor>,<oFont>,<.lScroll.> );
    [; hd_SetCtrlName( <oText>,<(oText)> )]

#xcommand BUTTON <oBtn>                     ;
             [ TEXT <cText> ]               ;
             [ SIZE <width>, <height> ]     ;
             [ TEXTCOLOR <tcolor> ]         ;
             [ BACKCOLOR <bcolor> ]         ;
             [ FONT <oFont> ]               ;
             [ ON CLICK <bClick> ]          ;
          => ;
   <oBtn> := HDButton():New( <cText>,<width>,<height>,<tcolor>,<bcolor>,<oFont>,<bClick> );
   [; hd_SetCtrlName( <oBtn>,<(oBtn)> )]

#xcommand EDITBOX <oEdit>                   ;
             [ TEXT <cText> ]               ;
             [ HINT <cHint> ]               ;
             [ SIZE <width>, <height> ]     ;
             [ TEXTCOLOR <tcolor> ]         ;
             [ BACKCOLOR <bcolor> ]         ;
             [ FONT <oFont> ]               ;
             [ ON KEYDOWN <bKeyDown>]       ;
          => ;
   <oEdit> := HDEdit():New( <cText>,<width>,<height>,<tcolor>,<bcolor>,<oFont>,<cHint>,<bKeyDown> );
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

#xcommand SET TIMER <oTimer>  ;
             VALUE <value> ACTION <bAction> ;
          => ;
    <oTimer> := HDTimer():New( <value>, <bAction> )

#xcommand INIT NOTIFICATION <oNotify> TITLE <cTitle> ;
             [ TEXT <cText> ]             ;
             [ SUBTEXT <cSubText> ]       ;
             [<lLight: LIGHT>]            ;
             [<lSound: SOUND>]            ;
             [<lVibr:  VIBRATION>]        ;
          => ;
    <oNotify> := HDNotify():New( <.lLight.>, <.lSound.>, <.lVibr.>, <cTitle>, <cText>, <cSubText> )
