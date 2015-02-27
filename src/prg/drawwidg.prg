/*
 * HDroidGUI - Harbour for Android GUI framework
 * Fonts
 */

#include "hbclass.ch"
#include "hdroidgui.ch"

CLASS HDFont INHERIT HDGUIObject

   CLASS VAR aFonts   INIT { }
   DATA  typeface, style, height
   DATA nCounter   INIT 1

   METHOD Add( typeface, style, height )
   METHOD Release()

ENDCLASS


METHOD Add( typeface, style, height ) CLASS HDFont

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
