/*
 * HDroidGUI - Harbour for Android GUI framework
 * Main header file
 */

#define HDROIDGUI_VERSION         "0.4"
#define HDROIDGUI_BUILD           4

#define MATCH_PARENT   -1
#define WRAP_CONTENT   -2

#define FONT_NORMAL     0
#define FONT_SANS       1
#define FONT_SERIF      2
#define FONT_MONOSPACE  3

#define FONT_BOLD         1
#define FONT_ITALIC       2
#define FONT_BOLD_ITALIC  3

#define ALIGN_LEFT      0
#define ALIGN_CENTER    1
#define ALIGN_RIGHT     2
#define ALIGN_TOP       0
#define ALIGN_VCENTER   4
#define ALIGN_BOTTOM    8

#define BL_TR           0
#define BOTTOM_TOP      1
#define BR_TL           2
#define LEFT_RIGHT      3
#define RIGHT_LEFT      4
#define TL_BR           5
#define TOP_BOTTOM      6
#define TR_BL           7


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
    <oFont> := HDFont():New( <face>, <style>, <height> )

#xcommand INIT FONT <oFont>        ;
             [ FACE <face> ]       ;
             [ STYLE <style> ]     ;
             [ HEIGHT <height> ]   ;
          => ;
    <oFont> := HDFont():New( <face>, <style>, <height> )

#xcommand BEGIN LAYOUT <oLay>               ;
             [<lHorz: HORIZONTAL>]          ;
             [ SIZE <width>, <height> ]     ;
             [ BACKCOLOR <bcolor> ]         ;
             [ FONT <oFont> ]               ;
          => ;
   <oLay> := HDLayout():New( <(oLay)>,<.lHorz.>,<width>,<height>,<bcolor>,<oFont> )

#xcommand END LAYOUT <oLay>   ;
          => ;
   <oLay>:oDefaultParent := <oLay>:oParent

#xcommand TEXTVIEW <oText>                  ;
             [ TEXT <cText> ]               ;
             [ SIZE <width>, <height> ]     ;
             [ TEXTCOLOR <tcolor> ]         ;
             [ BACKCOLOR <bcolor> ]         ;
             [ FONT <oFont> ]               ;
             [<lVScroll: VSCROLL>]          ;
             [<lHScroll: HSCROLL>]          ;
          => ;
   <oText> := HDTextView():New( <(oText)>,<cText>,<width>,<height>,<tcolor>,<bcolor>,<oFont>,<.lVScroll.>,<.lHScroll.> )

#xcommand BUTTON <oBtn>                     ;
             [ TEXT <cText> ]               ;
             [ SIZE <width>, <height> ]     ;
             [ TEXTCOLOR <tcolor> ]         ;
             [ BACKCOLOR <bcolor> ]         ;
             [ FONT <oFont> ]               ;
             [ ON CLICK <bClick> ]          ;
          => ;
   <oBtn> := HDButton():New( <(oBtn)>,<cText>,<width>,<height>,<tcolor>,<bcolor>,<oFont>,<bClick> )

#xcommand EDITBOX <oEdit>                   ;
             [ TEXT <cText> ]               ;
             [ HINT <cHint> ]               ;
             [<lPass: PASSWORD>]            ;
             [ SIZE <width>, <height> ]     ;
             [ TEXTCOLOR <tcolor> ]         ;
             [ BACKCOLOR <bcolor> ]         ;
             [ FONT <oFont> ]               ;
             [ ON KEYDOWN <bKeyDown>]       ;
          => ;
   <oEdit> := HDEdit():New( <(oEdit)>,<cText>,<width>,<height>,<tcolor>,<bcolor>,<oFont>,<cHint>,<.lPass.>,<bKeyDown> )

#xcommand CHECKBOX <oChe>                   ;
             [ TEXT <cText> ]               ;
             [ SIZE <width>, <height> ]     ;
             [ TEXTCOLOR <tcolor> ]         ;
             [ BACKCOLOR <bcolor> ]         ;
             [ FONT <oFont> ]               ;
             [ INIT <lInit> ]               ;
          => ;
   <oChe> := HDCheckBox():New( <(oChe)>,<cText>,<width>,<height>,<tcolor>,<bcolor>,<oFont>,<lInit> )

#xcommand WEBVIEW <oWeb>                    ;
             [ TEXT <cText> ]               ;
             [ SIZE <width>, <height> ]     ;
             [ BACKCOLOR <bcolor> ]         ;
             [<lZoom: ZOOMTOOL>]            ;
             [<lJS: JSCRIPT>]               ;
          => ;
   <oWeb> := HDWebView():New( <(oWeb)>,<cText>,<width>,<height>,,<bcolor>,,<.lZoom.>,<.lJS.> )

#xcommand IMAGEVIEW <oImg>                  ;
             [ SIZE <width>, <height> ]     ;
             [ BACKCOLOR <bcolor> ]         ;
          => ;
   <oImg> := HDImageView():New( <(oImg)>,,<width>,<height>,,<bcolor> )

#xcommand BROWSE <oBrw>                     ;
             [ SIZE <width>, <height> ]     ;
             [ TEXTCOLOR <tcolor> ]         ;
             [ BACKCOLOR <bcolor> ]         ;
             [ FONT <oFont> ]               ;
             [<lHScroll: HSCROLL>]          ;
             [ ON CLICK <bClick> ]          ;
          => ;
   <oBrw> := HDBrowse():New( <(oBrw)>,<width>,<height>,<tcolor>,<bcolor>,<oFont>,<.lHScroll.>,<bClick> )

#xcommand BROWSE <oBrw> ARRAY <aArr>        ;
             [ SIZE <width>, <height> ]     ;
             [ TEXTCOLOR <tcolor> ]         ;
             [ BACKCOLOR <bcolor> ]         ;
             [ FONT <oFont> ]               ;
             [<lHScroll: HSCROLL>]          ;
             [ ON CLICK <bClick> ]          ;
          => ;
   <oBrw> := HDBrwArray():New( <(oBrw)>,<aArr>,<width>,<height>,<tcolor>,<bcolor>,<oFont>,<.lHScroll.>,<bClick> )

#xcommand BROWSE <oBrw> DBF <cAlias>        ;
             [ FILTER <xFilter> ]           ;
             [ SIZE <width>, <height> ]     ;
             [ TEXTCOLOR <tcolor> ]         ;
             [ BACKCOLOR <bcolor> ]         ;
             [ FONT <oFont> ]               ;
             [<lHScroll: HSCROLL>]          ;
             [ ON CLICK <bClick> ]          ;
          => ;
   <oBrw> := HDBrwDbf():New( <(oBrw)>,<cAlias>,<width>,<height>,<tcolor>,<bcolor>,<oFont>,<.lHScroll.>,<bClick>,<xFilter> )

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

#xcommand SET <oWidget> MARGINS [ LEFT <ml>] [ TOP <mt>] [ RIGHT <mr>]  [ BOTTOM <mb>] ;
          => ;
    hd_setMargins( <oWidget>, <ml>, <mt>, <mr>, <mb> )

#xcommand SET <oWidget> PADDING [ LEFT <pl>] [ TOP <pt>] [ RIGHT <pr>]  [ BOTTOM <pb>] ;
          => ;
    hd_setPadding( <oWidget>, <pl>, <pt>, <pr>, <pb> )

#xcommand  INIT STYLE <ostyle>            ;
                [COLORS <colors,...>]     ;
                [ORIENT <norient>]        ;
                [CORNERS <corners,...>]   ;
                [TEXTCOLOR <tcolor>]      ;
          => ;
    <ostyle> := HDStyle():New( {<colors>}, <norient>, {<corners>}, <tcolor> )
