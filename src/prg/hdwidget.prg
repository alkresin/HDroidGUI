/*
 * HDroidGUI - Harbour for Android GUI framework
 * HDWidget
 */

#include "hbclass.ch"

CLASS HDWidget INHERIT HDGUIObject

   DATA oParent
   DATA cText
   DATA nWidth, nHeight
   DATA nMarginL, nMarginT, nMarginR, nMarginB
   DATA nPaddL, nPaddT, nPaddR, nPaddB
   DATA nAlign  INIT 0
   DATA tColor, bColor
   DATA oFont
   DATA oStyle

   DATA objName

   METHOD New( cName, cText, nWidth, nHeight, tcolor, bcolor, oFont )
   METHOD GetText()
   METHOD SetText( cText )
   METHOD ToArray( arr )

ENDCLASS

METHOD New( cName, cText, nWidth, nHeight, tcolor, bcolor, oFont ) CLASS HDWidget

   LOCAL nPos

   ::oParent := ::oDefaultParent
   IF !Empty( ::oParent )
      Aadd( ::oParent:aItems, Self )
   ENDIF

   IF Empty( cName ) .OR. ValType( cName ) != "C"
      cName := "_WDG" + Ltrim(Str(HDWindow():nIdWdg++))
   ENDIF

   IF ( nPos :=  RAt( ":", cName ) ) > 0 .OR. ( nPos :=  RAt( ">", cName ) ) > 0
      cName := SubStr( cName, nPos + 1 )
   ENDIF
   ::objName := Upper( cName )

   ::cText := cText
   ::nWidth := nWidth
   ::nHeight := nHeight
   ::tColor := tColor
   ::bColor := bColor
   ::oFont := oFont

   RETURN Self

METHOD GetText() CLASS HDWidget

   IF !Empty( ::objname )
      ::cText := hd_calljava_s_s( "gettxt:" + ::objname + ":" )
   ENDIF

   RETURN ::cText

METHOD SetText( cText ) CLASS HDWidget

   IF !Empty( ::objname )
      ::cText := cText
      hd_calljava_s_v( "settxt:" + ::objname + ":" + cText )
   ENDIF

   RETURN cText

METHOD ToArray( arr ) CLASS HDWidget

   LOCAL s, i

   IF arr == Nil
      arr := {}
   ENDIF

   IF !Empty( ::cText )
      Aadd( arr, "t:" + ::cText )
   ENDIF
   IF  ::nWidth != Nil
      Aadd( arr, "w:" + Ltrim(Str(::nWidth)) )
   ENDIF
   IF ::nHeight != Nil
      Aadd( arr, "h:" + Ltrim(Str(::nHeight)) )
   ENDIF
   IF ::tColor != Nil
      Aadd( arr, "ct:" + Iif( Valtype(::tColor)=="C", ::tColor, hd_ColorN2C(::tColor) ) )
   ENDIF
   IF ::bColor != Nil
      Aadd( arr, "cb:" + Iif( Valtype(::bColor)=="C", ::bColor, hd_ColorN2C(::bColor) ) )
   ENDIF
   IF !Empty( ::oFont )
      Aadd( arr, "f:" + Ltrim(Str(::oFont:typeface)) + "/" + ;
            Ltrim(Str(::oFont:style)) + "/" + Ltrim(Str(::oFont:height)) )
   ENDIF
   IF ::nMarginL != Nil
      Aadd( arr, "ml:" + Ltrim(Str(::nMarginL)) )
   ENDIF
   IF ::nMarginT != Nil
      Aadd( arr, "mt:" + Ltrim(Str(::nMarginT)) )
   ENDIF
   IF ::nMarginR != Nil
      Aadd( arr, "mr:" + Ltrim(Str(::nMarginR)) )
   ENDIF
   IF ::nMarginB != Nil
      Aadd( arr, "mb:" + Ltrim(Str(::nMarginB)) )
   ENDIF
   IF ::nPaddL != Nil
      Aadd( arr, "pl:" + Ltrim(Str(::nPaddL)) )
   ENDIF
   IF ::nPaddT != Nil
      Aadd( arr, "pt:" + Ltrim(Str(::nPaddT)) )
   ENDIF
   IF ::nPaddR != Nil
      Aadd( arr, "pr:" + Ltrim(Str(::nPaddR)) )
   ENDIF
   IF ::nPaddB != Nil
      Aadd( arr, "pb:" + Ltrim(Str(::nPaddB)) )
   ENDIF
   IF ::nAlign != 0
      Aadd( arr, "ali:" + Ltrim(Str(::nAlign)) )
   ENDIF
   IF ::oStyle != Nil
      IF Valtype( ::oStyle ) == "A"
         s := ""
         FOR i := 1 TO Len( ::oStyle )
            s += Iif( i>1, ",", "" ) + Iif( Empty(::oStyle[i]), "", Ltrim(Str(::oStyle[i]:id)) )
            Aadd( arr, "stl:" + s )
         NEXT
      ELSE
         Aadd( arr, "stl:" + Ltrim(Str(::oStyle:id)) )
      ENDIF
   ENDIF

   RETURN arr


CLASS HDLayout INHERIT HDWidget

   DATA aItems   INIT {}
   DATA lHorz

   METHOD New( cName, lHorz, nWidth, nHeight, bcolor, oFont )
   METHOD FindByName( cName )
   METHOD ToArray( arr )

ENDCLASS

METHOD New( cName, lHorz, nWidth, nHeight, bcolor, oFont ) CLASS HDLayout

   ::Super:New( cName,, nWidth, nHeight,, bcolor, oFont )
   ::oDefaultParent := Self

   ::lHorz := !Empty( lHorz )
   ::nWidth := nWidth
   ::nHeight := nHeight
   ::bColor := bColor

   RETURN Self

METHOD FindByName( cName ) CLASS HDLayout
 
   LOCAL aItems := ::aItems, oItem, o

   FOR EACH oItem IN aItems
      IF !Empty( oItem:objname ) .AND. oItem:objname == cName
         RETURN oItem
      ELSEIF __ObjHasMsg( oItem, "AITEMS" ) .AND. !Empty( o := oItem:FindByName( cName ) )
         RETURN o
      ENDIF
   NEXT

   RETURN Nil

METHOD ToArray( arr ) CLASS HDLayout

   LOCAL i, nLen := Len( ::aItems ), arr1

   IF arr == Nil
      arr := {}
   ENDIF

   Aadd( arr, "lay:" + ::objname )
   IF !Empty( ::lHorz )
      Aadd( arr, "o:h" )
   ELSE
      Aadd( arr, "o:v" )
   ENDIF
   ::Super:ToArray( arr )

   Aadd( arr, arr1 := {} )
   FOR i := 1 TO nLen
      Aadd( arr1, ::aItems[i]:ToArray() )
   NEXT

   RETURN arr


CLASS HDTextView INHERIT HDWidget

   DATA lVScroll INIT .F.
   DATA lHScroll INIT .F.

   METHOD New( cName, cText, nWidth, nHeight, tcolor, bcolor, oFont, lVScroll, lHScroll )
   METHOD ToArray( arr )

ENDCLASS

METHOD New( cName, cText, nWidth, nHeight, tcolor, bcolor, oFont, lVScroll, lHScroll ) CLASS HDTextView

   ::Super:New( cName, cText, nWidth, nHeight, tcolor, bcolor, oFont )
   ::lVScroll := lVScroll
   ::lHScroll := lHScroll

   RETURN Self

METHOD ToArray( arr ) CLASS HDTextView

   IF arr == Nil
      arr := {}
   ENDIF

   Aadd( arr, "txt:" + ::objname )
   IF !Empty( ::lVScroll )
      Aadd( arr, "vscroll:t" )
   ENDIF
   IF !Empty( ::lHScroll )
      Aadd( arr, "hscroll:t" )
   ENDIF

   RETURN ::Super:ToArray( arr )


CLASS HDButton INHERIT HDWidget

   DATA bClick

   METHOD New( cName, cText, nWidth, nHeight, tcolor, bcolor, oFont, bClick )
   METHOD ToArray( arr )

ENDCLASS

METHOD New( cName, cText, nWidth, nHeight, tcolor, bcolor, oFont, bClick ) CLASS HDButton

   ::Super:New( cName, cText, nWidth, nHeight, tcolor, bcolor, oFont )

   ::bClick := bClick

   RETURN Self

METHOD ToArray( arr ) CLASS HDButton

   IF arr == Nil
      arr := {}
   ENDIF

   Aadd( arr, "btn:" + ::objname )
   IF ::bClick != Nil
      Aadd( arr, "bcli:1" )
   ENDIF

   RETURN ::Super:ToArray( arr )


CLASS HDEdit INHERIT HDWidget

   DATA cHint
   DATA lPass      INIT .F.
   DATA bKeyDown

   METHOD New( cName, cText, nWidth, nHeight, tcolor, bcolor, oFont, cHint, lPass, bKeyDown )
   METHOD getCursorPos( n )
   METHOD setCursorPos( nPos )
   METHOD ToArray( arr )

ENDCLASS

METHOD New( cName, cText, nWidth, nHeight, tcolor, bcolor, oFont, cHint, lPass, bKeyDown ) CLASS HDEdit

   ::Super:New( cName, cText, nWidth, nHeight, tcolor, bcolor, oFont )
   ::cHint := cHint
   IF Valtype( lPass ) == "L"
      ::lPass := lPass
   ENDIF
   ::bKeyDown := bKeyDown

   RETURN Self

METHOD getCursorPos( n ) CLASS HDEdit

   LOCAL nPos := Val( hd_calljava_s_s( Iif( Empty(n).OR.n==1,"getsels:","getsele:" ) + ::objname + ":" ) )

   RETURN nPos

METHOD setCursorPos( nPos ) CLASS HDEdit

   hd_calljava_s_v( "setsels:" + ::objname + ":" + Ltrim(Str(nPos)) )

   RETURN Nil

METHOD ToArray( arr ) CLASS HDEdit

   IF arr == Nil
      arr := {}
   ENDIF

   Aadd( arr, "edi:" + ::objname )
   IF ::cHint != Nil
      Aadd( arr, "hint:" + ::cHint )
   ENDIF
   IF ::lPass
      Aadd( arr, "pass:" )
   ENDIF
   IF ::bKeyDown != Nil
      Aadd( arr, "bkey:1" )
   ENDIF

   RETURN ::Super:ToArray( arr )


CLASS HDCheckBox INHERIT HDWidget

   DATA lValue  INIT .F.

   METHOD New( cName, cText, nWidth, nHeight, tcolor, bcolor, oFont, lInit )
   METHOD Value( lValue ) SETGET
   METHOD ToArray( arr )

ENDCLASS

METHOD New( cName, cText, nWidth, nHeight, tcolor, bcolor, oFont, lInit ) CLASS HDCheckBox

   ::Super:New( cName, cText, nWidth, nHeight, tcolor, bcolor, oFont )
   IF Valtype( lInit ) == "L"
      ::lValue := lInit
   ENDIF

   RETURN Self

METHOD Value( lValue ) CLASS HDCheckBox

   IF lValue != Nil
      IF ValType( lValue ) != "L"
         lValue := .F.
      ENDIF
      hd_calljava_s_v( "setval:" + ::objname + ":" + iif( lValue,"1","0" ) )
      RETURN ( ::lValue := lValue )
   ENDIF

   RETURN ( ::lValue := ( hd_calljava_s_s( "getval:" + ::objname + ":" ) == "1" ) )

METHOD ToArray( arr ) CLASS HDCheckBox

   IF arr == Nil
      arr := {}
   ENDIF

   Aadd( arr, "che:" + ::objname )
   IF ::lValue
      Aadd( arr, "v:1" )
   ENDIF

   RETURN ::Super:ToArray( arr )

CLASS HDWebView INHERIT HDWidget

   DATA lZoom INIT .F.
   DATA lJS INIT .F.

   METHOD New( cName, cText, nWidth, nHeight, tcolor, bcolor, oFont, lZoom, lJS )
   METHOD ToArray( arr )

ENDCLASS

METHOD New( cName, cText, nWidth, nHeight, tcolor, bcolor, oFont, lZoom, lJS ) CLASS HDWebView

   ::Super:New( cName, cText, nWidth, nHeight,, bcolor )
   ::lZoom := lZoom
   ::lJS := lJS

   RETURN Self

METHOD ToArray( arr ) CLASS HDWebView

   IF arr == Nil
      arr := {}
   ENDIF

   Aadd( arr, "web:" + ::objname )
   IF !Empty( ::lZoom )
      Aadd( arr, "zoom:t" )
   ENDIF
   IF !Empty( ::lJS )
      Aadd( arr, "js:t" )
   ENDIF

   RETURN ::Super:ToArray( arr )

CLASS HDImageView INHERIT HDWidget

   METHOD New( cName, cText, nWidth, nHeight, tcolor, bcolor, oFont )
   METHOD ToArray( arr )

ENDCLASS

METHOD New( cName, cText, nWidth, nHeight, tcolor, bcolor, oFont ) CLASS HDImageView

   ::Super:New( cName,, nWidth, nHeight,, bcolor )

   RETURN Self

METHOD ToArray( arr ) CLASS HDImageView

   IF arr == Nil
      arr := {}
   ENDIF

   Aadd( arr, "img:" + ::objname )

   RETURN ::Super:ToArray( arr )
