/*
 * HDroidGUI - Harbour for Android GUI framework
 * HDActivity - Activity class
 */

#include "hbclass.ch"

CLASS HDGUIObject

   CLASS VAR oDefaultParent SHARED

ENDCLASS

CLASS HDWindow INHERIT HDGUIObject

   CLASS VAR aWindows SHARED INIT {}

   DATA title

   DATA aItems   INIT {}

   METHOD New( cTitle )
   METHOD Close()
   METHOD FindByName( cName )

ENDCLASS

METHOD New( cTitle ) CLASS HDWindow

   ::oDefaultParent := Self

   ::title := cTitle

   Aadd( ::aWindows, Self )

   RETURN Self

METHOD Close() CLASS HDWindow
   LOCAL i

   FOR i := Len( ::aWindows ) TO 1 STEP -1
      IF ::aWindows[i] == Self
         ADel( ::aWindows, i )
         ASize( ::aWindows, Len(::aWindows)-1 )
         EXIT
      ENDIF
   NEXT

   RETURN Nil

METHOD FindByName( cName ) CLASS HDWindow
 
   LOCAL aItems := ::aItems, oItem, o

   FOR EACH oItem IN aItems
      IF !Empty( oItem:objname ) .AND. oItem:objname == cName
         RETURN oItem
      ELSEIF __ObjHasMsg( oItem, "AITEMS" ) .AND. !Empty( o := oItem:FindByName( cName ) )
         RETURN o
      ENDIF
   NEXT

   RETURN Nil

CLASS HDActivity INHERIT HDWindow

   DATA oFont
   DATA bInit, bDestroy

   METHOD New( cTitle, bInit, bExit )
   METHOD ToString()

ENDCLASS

METHOD New( cTitle, bInit, bExit ) CLASS HDActivity

   ::Super:New( cTitle )
   ::bInit := bInit
   ::bDestroy := bExit

   RETURN Self

METHOD ToString() CLASS HDActivity

   LOCAL sRet := "act,,t:" + ::title + ",,/"

   IF !Empty( ::aItems )
      sRet += ::aItems[1]:ToString()
   ENDIF

   RETURN sRet

CLASS HDDialog INHERIT HDWindow

   DATA aButtons
   DATA nRes

   DATA bContinue
   DATA bInit, bDestroy

   METHOD New( cTitle, bInit, bExit )
   METHOD onBtnClick( cName )
   METHOD ToString()

ENDCLASS

METHOD New( cTitle, bInit, bExit ) CLASS HDDialog

   ::Super:New( cTitle )
   ::bInit := bInit
   ::bDestroy := bExit

   RETURN Self

METHOD onBtnClick( cName ) CLASS HDDialog

   ::Close()

   IF ::bContinue != Nil
      IF !Empty( ::aButtons )
         ::nRes := Ascan( ::aButtons, cName )
      ENDIF
      Eval( ::bContinue, Self )
   ENDIF

   RETURN "1"

METHOD ToString() CLASS HDDialog

   LOCAL sRet := "ad:dlg,,t:" + ::title + ",,/", i, nLen := Len( ::aItems )

   FOR i := 1 TO nLen
      sRet += ::aItems[i]:ToString() + Iif( i<nLen, ",,/","" )
   NEXT

   RETURN sRet
