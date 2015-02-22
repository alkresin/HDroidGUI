/*
 * HDroidGUI - Harbour for Android GUI framework
 * HDWidget
 */

#include "hbclass.ch"

Function hd_SetCtrlName( oCtrl, cName )
   LOCAL nPos

   IF !Empty( cName ) .AND. ValType( cName ) == "C" .AND. oCtrl:oParent != Nil .AND. ! "[" $ cName
      IF ( nPos :=  RAt( ":", cName ) ) > 0 .OR. ( nPos :=  RAt( ">", cName ) ) > 0
         cName := SubStr( cName, nPos + 1 )
      ENDIF
      oCtrl:objName := Upper( cName )
   ENDIF

   RETURN Nil

CLASS HDGroup INHERIT HDGUIObject

   DATA oParent
   DATA aItems   INIT {}

   DATA objName

   METHOD New()
   METHOD FindByName( cName )
   METHOD ToString()

ENDCLASS

METHOD New() CLASS HDGroup

   ::oParent := ::oDefaultParent
   ::oDefaultParent := Self
   IF !Empty( ::oParent )
      Aadd( ::oParent:aItems, Self )
   ENDIF

   RETURN Self

METHOD FindByName( cName ) CLASS HDGroup
 
   LOCAL aItems := ::aItems, oItem, o

   FOR EACH oItem IN aItems
      IF !Empty( oItem:objname ) .AND. oItem:objname == cName
         RETURN oItem
      ELSEIF __ObjHasMsg( oItem, "AITEMS" ) .AND. !Empty( o := oItem:FindByName( cName ) )
         RETURN o
      ENDIF
   NEXT

   RETURN Nil

METHOD ToString() CLASS HDGroup

   LOCAL sRet := "[(", i, nLen := Len( ::aItems )

   FOR i := 1 TO nLen
      sRet += ::aItems[i]:ToString() + Iif( i<nLen, ",,/","" )
   NEXT

   RETURN sRet + ")]"

CLASS HDLayout INHERIT HDGroup

   DATA lHorz
   DATA nWidth, nHeight
   DATA bColor
   DATA oFont

   METHOD New( lHorz, nWidth, nHeight, bcolor, oFont )
   METHOD ToString()

ENDCLASS

METHOD New( lHorz, nWidth, nHeight, bcolor, oFont ) CLASS HDLayout

   ::Super:New()

   ::lHorz := !Empty( lHorz )
   ::nWidth := nWidth
   ::nHeight := nHeight
   ::bColor := bColor

   RETURN Self

METHOD ToString() CLASS HDLayout

   LOCAL sRet := "lay:" + ::objName

   IF !Empty( ::lHorz )
      sRet += ",,o:h"
   ELSE
      sRet += ",,o:v"
   ENDIF
   IF ::nWidth != Nil
      sRet += ",,w:" + Ltrim(Str(::nWidth))
   ENDIF
   IF ::nHeight != Nil
      sRet += ",,h:" + Ltrim(Str(::nHeight))
   ENDIF
   IF ::bColor != Nil
      sRet += ",,cb:" + Iif( Valtype(::bColor)=="C", ::bColor, h4a_ColorN2C(::bColor) )
   ENDIF

   sRet += ::Super:ToString()

   RETURN sRet

CLASS HDWidget INHERIT HDGUIObject

   DATA oParent
   DATA cText
   DATA nWidth, nHeight
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

   RETURN Self

METHOD GetText() CLASS HDWidget

   IF !Empty( ::objname )
      ::cText := h4a_calljava_s_s( "gettxt:" + ::objname + ":" )
   ENDIF

   RETURN ::cText

METHOD SetText( cText ) CLASS HDWidget

   IF !Empty( ::objname )
      ::cText := cText
      h4a_calljava_s_s( "settxt:" + ::objname + ":" + cText )
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
      sRet += ",,ct:" + Iif( Valtype(::tColor)=="C", ::tColor, h4a_ColorN2C(::tColor) )
   ENDIF
   IF ::bColor != Nil
      sRet += ",,cb:" + Iif( Valtype(::bColor)=="C", ::bColor, h4a_ColorN2C(::bColor) )
   ENDIF

   RETURN sRet

CLASS HDTextView INHERIT HDWidget

   METHOD New( cText, nWidth, nHeight, tcolor, bcolor, oFont )
   METHOD ToString()

ENDCLASS

METHOD New( cText, nWidth, nHeight, tcolor, bcolor, oFont ) CLASS HDTextView

   ::Super:New( cText, nWidth, nHeight, tcolor, bcolor, oFont )

   RETURN Self

METHOD ToString() CLASS HDTextView

   RETURN "txt" + ::Super:ToString()


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

   METHOD New( cText, nWidth, nHeight, tcolor, bcolor, oFont, cHint )
   METHOD ToString()

ENDCLASS

METHOD New( cText, nWidth, nHeight, tcolor, bcolor, oFont, cHint ) CLASS HDEdit

   ::Super:New( cText, nWidth, nHeight, tcolor, bcolor, oFont )
   ::cHint := cHint

   RETURN Self

METHOD ToString() CLASS HDEdit

   LOCAL sRet := ""

   IF ::cHint != Nil
      sRet += ",,hint:" + ::cHint
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
