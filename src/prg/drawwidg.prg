/*
 * HDroidGUI - Harbour for Android GUI framework
 * Fonts, styles
 */

#include "hbclass.ch"
#include "hdroidgui.ch"

CLASS HDFont INHERIT HDGUIObject

   CLASS VAR aFonts   INIT { }
   DATA  typeface, style, height
   DATA nCounter   INIT 1

   METHOD New( typeface, style, height )
   METHOD Release()

ENDCLASS

METHOD New( typeface, style, height ) CLASS HDFont

   LOCAL i, nlen := Len( ::aFonts )

   typeface := Iif( typeface == Nil, FONT_NORMAL, typeface )
   style := Iif( style == Nil, FONT_NORMAL, style )
   height := Iif( height == Nil, 0, height )

   FOR i := 1 TO nlen
      IF ::aFonts[i]:typeface == typeface .AND. ;
            ::aFonts[i]:style == style .AND.    ;
            ::aFonts[i]:height == height

         ::aFonts[ i ]:nCounter ++
         RETURN ::aFonts[ i ]
      ENDIF
   NEXT

   ::typeface := typeface
   ::style    := style
   ::height   := height

   AAdd( ::aFonts, Self )

   RETURN Self

METHOD Release() CLASS HDFont
   LOCAL i, nlen := Len( ::aFonts )

   ::nCounter --
   IF ::nCounter == 0
      FOR i := 1 TO nlen
         IF ::aFonts[i]:typeface == ::typeface .AND. ;
               ::aFonts[i]:style == ::style .AND.    ;
               ::aFonts[i]:height == ::height

            ADel( ::aFonts, i )
            ASize( ::aFonts, nlen - 1 )
            EXIT
         ENDIF
      NEXT
   ENDIF

   RETURN Nil

CLASS HDStyle INHERIT HDGUIObject

   CLASS VAR aStyles   INIT { }

   DATA id
   DATA aColors
   DATA tColor
   DATA aCorners

   METHOD New( aColors, tColor, aCorners )
   METHOD toString( nId )
ENDCLASS

METHOD New( aColors, tColor, aCorners ) CLASS HDStyle

   LOCAL i, nlen := Len( ::aStyles )

   tColor := Iif( tColor == Nil, -1, tColor )

   FOR i := 1 TO nlen
      IF hd_aCompare( ::aStyles[i]:aColors, aColors ) .AND. ;
         hd_aCompare( ::aStyles[i]:aCorners, aCorners ) .AND. ;
         ::aStyles[i]:tColor == tColor

         RETURN ::aStyles[ i ]
      ENDIF
   NEXT

   ::aColors  := aColors
   ::tColor   := tColor
   ::aCorners := aCorners

   AAdd( ::aStyles, Self )
   ::id := Len( ::aStyles )

   RETURN Self

METHOD toString( nId ) CLASS HDStyle

   LOCAL oStyle, aRet := {}

   IF nId > 0 .AND. nId <= Len( ::aStyles )
      oStyle := ::aStyles[nId]
      Aadd( aRet, Iif( !Empty(oStyle:aColors), oStyle:aColors, {} ) )
      Aadd( aRet, Iif( !Empty(oStyle:aCorners), oStyle:aCorners, {} ) )
      Aadd( aRet, Iif( oStyle:tColor != -1, Ltrim(Str(oStyle:tColor)), "" ) )
      RETURN hb_jsonEncode( aRet )
   ENDIF

   RETURN ""

FUNCTION hd_aCompare( arr1, arr2 )

   LOCAL i, nLen

   IF arr1 == Nil .AND. arr2 == Nil
      RETURN .T.
   ELSEIF Valtype( arr1 ) == Valtype( arr2 ) .AND. Valtype( arr1 ) == "A" ;
         .AND. ( nLen := Len( arr1 ) ) == Len( arr2 )
      FOR i := 1 TO nLen
         IF !( arr1[i] == arr2[i] )
            RETURN .F.
         ENDIF
      NEXT
      RETURN .T.
   ENDIF

   RETURN .F.
