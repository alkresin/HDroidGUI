/*
 * HDroidGUI - Harbour for Android GUI framework
 * HDWidget
 */

#include "hbclass.ch"

Function hd_SetCtrlName( oCtrl, cName )
   LOCAL nPos

   IF !Empty( cName ) .AND. ValType( cName ) == "C"
      IF ( nPos :=  RAt( ":", cName ) ) > 0 .OR. ( nPos :=  RAt( ">", cName ) ) > 0
         cName := SubStr( cName, nPos + 1 )
      ENDIF
      oCtrl:objName := Upper( cName )
   ENDIF

   RETURN Nil

CLASS HDWidget INHERIT HDGUIObject

   DATA oParent
   DATA cText
   DATA nWidth, nHeight
   DATA nMarginL, nMarginT, nMarginR, nMarginB
   DATA nPaddL, nPaddT, nPaddR, nPaddB
   DATA nAlign  INIT 0
   DATA tColor, bColor
   DATA oFont

   DATA objName

   METHOD New( cText, nWidth, nHeight, tcolor, bcolor, oFont )
   METHOD GetText()
   METHOD SetText( cText )
   METHOD ToString()

ENDCLASS

METHOD New( cText, nWidth, nHeight, tcolor, bcolor, oFont ) CLASS HDWidget

   ::oParent := ::oDefaultParent
   IF !Empty( ::oParent )
      Aadd( ::oParent:aItems, Self )
   ENDIF

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


METHOD ToString() CLASS HDWidget

   LOCAL sRet := ":" + ::objName

   IF !Empty( ::cText )
      sRet += ",,t:" + ::cText
   ENDIF
   IF  ::nWidth != Nil
      sRet += ",,w:" + Ltrim(Str(::nWidth))
   ENDIF
   IF ::nHeight != Nil
      sRet += ",,h:" + Ltrim(Str(::nHeight))
   ENDIF
   IF ::tColor != Nil
      sRet += ",,ct:" + Iif( Valtype(::tColor)=="C", ::tColor, hd_ColorN2C(::tColor) )
   ENDIF
   IF ::bColor != Nil
      sRet += ",,cb:" + Iif( Valtype(::bColor)=="C", ::bColor, hd_ColorN2C(::bColor) )
   ENDIF
   IF !Empty( ::oFont )
      sRet += ",,f:" + Ltrim(Str(::oFont:typeface)) + "/" + ;
            Ltrim(Str(::oFont:style)) + "/" + Ltrim(Str(::oFont:height))
   ENDIF
   IF ::nMarginL != Nil
      sRet += ",,ml:" + Ltrim(Str(::nMarginL))
   ENDIF
   IF ::nMarginT != Nil
      sRet += ",,mt:" + Ltrim(Str(::nMarginT))
   ENDIF
   IF ::nMarginR != Nil
      sRet += ",,mr:" + Ltrim(Str(::nMarginR))
   ENDIF
   IF ::nMarginB != Nil
      sRet += ",,mb:" + Ltrim(Str(::nMarginB))
   ENDIF
   IF ::nPaddL != Nil
      sRet += ",,pl:" + Ltrim(Str(::nPaddL))
   ENDIF
   IF ::nPaddT != Nil
      sRet += ",,pt:" + Ltrim(Str(::nPaddT))
   ENDIF
   IF ::nPaddR != Nil
      sRet += ",,pr:" + Ltrim(Str(::nPaddR))
   ENDIF
   IF ::nPaddB != Nil
      sRet += ",,pb:" + Ltrim(Str(::nPaddB))
   ENDIF
   IF ::nAlign != 0
      sRet += ",,ali:" + Ltrim(Str(::nAlign))
   ENDIF

   RETURN sRet

CLASS HDLayout INHERIT HDWidget

   DATA aItems   INIT {}
   DATA lHorz

   METHOD New( lHorz, nWidth, nHeight, bcolor, oFont )
   METHOD FindByName( cName )
   METHOD ToString()

ENDCLASS

METHOD New( lHorz, nWidth, nHeight, bcolor, oFont ) CLASS HDLayout

   ::Super:New( , nWidth, nHeight,, bcolor, oFont )
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

METHOD ToString() CLASS HDLayout

   LOCAL sRet := "lay" + ::Super:ToString(), i, nLen := Len( ::aItems )

   IF !Empty( ::lHorz )
      sRet += ",,o:h"
   ELSE
      sRet += ",,o:v"
   ENDIF

   sRet += "[("

   FOR i := 1 TO nLen
      sRet += ::aItems[i]:ToString() + Iif( i<nLen, ",,/","" )
   NEXT

   RETURN sRet + ")]"


CLASS HDTextView INHERIT HDWidget

   DATA lVScroll INIT .F.
   DATA lHScroll INIT .F.

   METHOD New( cText, nWidth, nHeight, tcolor, bcolor, oFont, lVScroll, lHScroll )
   METHOD ToString()

ENDCLASS

METHOD New( cText, nWidth, nHeight, tcolor, bcolor, oFont, lVScroll, lHScroll ) CLASS HDTextView

   ::Super:New( cText, nWidth, nHeight, tcolor, bcolor, oFont )
   ::lVScroll := lVScroll
   ::lHScroll := lHScroll

   RETURN Self

METHOD ToString() CLASS HDTextView

   LOCAL sRet := ""

   IF !Empty( ::lVScroll )
      sRet += ",,vscroll:t"
   ENDIF
   IF !Empty( ::lHScroll )
      sRet += ",,hscroll:t"
   ENDIF

   RETURN "txt" + ::Super:ToString() + sRet


CLASS HDButton INHERIT HDWidget

   DATA bClick

   METHOD New( cText, nWidth, nHeight, tcolor, bcolor, oFont, bClick )
   METHOD ToString()

ENDCLASS

METHOD New( cText, nWidth, nHeight, tcolor, bcolor, oFont, bClick ) CLASS HDButton

   ::Super:New( cText, nWidth, nHeight, tcolor, bcolor, oFont )

   ::bClick := bClick

   RETURN Self

METHOD ToString() CLASS HDButton

   LOCAL sRet := ""

   IF ::bClick != Nil
      sRet += ",,bcli:1"
   ENDIF

   RETURN "btn" + ::Super:ToString() + sRet

CLASS HDEdit INHERIT HDWidget

   DATA cHint
   DATA lPass      INIT .F.
   DATA bKeyDown

   METHOD New( cText, nWidth, nHeight, tcolor, bcolor, oFont, cHint, lPass, bKeyDown )
   METHOD getCursorPos( n )
   METHOD setCursorPos( nPos )
   METHOD ToString()

ENDCLASS

METHOD New( cText, nWidth, nHeight, tcolor, bcolor, oFont, cHint, lPass, bKeyDown ) CLASS HDEdit

   ::Super:New( cText, nWidth, nHeight, tcolor, bcolor, oFont )
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

METHOD ToString() CLASS HDEdit

   LOCAL sRet := ""

   IF ::cHint != Nil
      sRet += ",,hint:" + ::cHint
   ENDIF
   IF ::lPass
      sRet += ",,pass:"
   ENDIF
   IF ::bKeyDown != Nil
      sRet += ",,bkey:1"
   ENDIF

   RETURN "edi" + ::Super:ToString() + sRet

CLASS HDCheckBox INHERIT HDWidget

   METHOD New( cText, nWidth, nHeight, tcolor, bcolor, oFont )
   METHOD ToString()

ENDCLASS

METHOD New( cText, nWidth, nHeight, tcolor, bcolor, oFont ) CLASS HDCheckBox

   ::Super:New( cText, nWidth, nHeight, tcolor, bcolor, oFont )

   RETURN Self

METHOD ToString() CLASS HDCheckBox

   RETURN "che" + ::Super:ToString()
