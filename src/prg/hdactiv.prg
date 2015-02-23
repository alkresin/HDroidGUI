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

   RETURN Self

METHOD ToString() CLASS HDActivity

   LOCAL sRet := "act,,t:" + ::title + ",,/"

   IF !Empty( ::aItems )
      sRet += ::aItems[1]:ToString()
   ENDIF

   RETURN sRet
