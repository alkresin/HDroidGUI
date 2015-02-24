/*
 * HDroidGUI - Harbour for Android GUI framework
 * HDActivity - Activity class
 */

#include "hbclass.ch"

CLASS HDGUIObject

   CLASS VAR oDefaultParent SHARED

ENDCLASS

CLASS HDActivity INHERIT HDGUIObject

   CLASS VAR aWindows SHARED INIT {}

   DATA title
   DATA oFont

   DATA aItems   INIT {}

   DATA bInit, bDestroy

   METHOD New( cTitle, bInit, bExit )
   METHOD ToString()

ENDCLASS

METHOD New( cTitle, bInit, bExit ) CLASS HDActivity

   ::oDefaultParent := Self

   ::title := cTitle
   ::bInit := bInit
   ::bDestroy := bExit

   Aadd( ::aWindows, Self )

   RETURN Self

METHOD ToString() CLASS HDActivity

   LOCAL sRet := "act,,t:" + ::title + ",,/"

   IF !Empty( ::aItems )
      sRet += ::aItems[1]:ToString()
   ENDIF

   RETURN sRet

CLASS HDDialog INHERIT HDGUIObject

   DATA title
   DATA oFont

   DATA aItems   INIT {}

   DATA bInit, bDestroy

   METHOD New( cTitle, bInit, bExit )
   METHOD ToString()

ENDCLASS

METHOD New( cTitle, bInit, bExit ) CLASS HDDialog

   ::oDefaultParent := Self

   ::title := cTitle
   ::bInit := bInit
   ::bDestroy := bExit

   Aadd( HDActivity():aWindows, Self )

   RETURN Self

METHOD ToString() CLASS HDDialog

   LOCAL sRet := "ad:Dlg,,t:" + ::title + ",,/", i, nLen := Len( ::aItems )

   FOR i := 1 TO nLen
      sRet += ::aItems[i]:ToString() + Iif( i<nLen, ",,/","" )
   NEXT

   RETURN sRet
