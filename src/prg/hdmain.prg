/*
 * HDroidGUI - Harbour for Android GUI framework
 * 
 */
#include "hdext.ch"
#include "hdroidgui.ch"

MEMVAR hrbHandle

FUNCTION event_BtnClick( cName )

   LOCAL oWnd := Atail( HDWindow():aWindows ), oItem

   IF __ObjHasMsg( oWnd, "ONBTNCLICK" )
      RETURN oWnd:onBtnClick( cName )
   ELSE
      oItem := oWnd:FindByName( cName )
      IF !Empty( oItem ) .AND. __ObjHasMsg( oItem, "BCLICK" ) .AND. !Empty( oItem:bClick )
         RETURN Eval( oItem:bClick )
      ENDIF    
   ENDIF

   RETURN ""

FUNCTION event_KeyDown( cName )

   LOCAL oItem
   LOCAL nPos := At( ":", cName ), nKey := Val( Substr( cName, nPos+1 ) )

   cName := Left( cName, nPos-1 )
   oItem := Atail( HDWindow():aWindows ):FindByName( cName )

   IF Empty( oItem ) .OR. !__ObjHasMsg( oItem, "BKEYDOWN" ) .OR. Empty( oItem:bKeyDown )
      RETURN "0"
   ENDIF

   RETURN Eval( oItem:bKeyDown, nKey )

FUNCTION hd_WrLog( cMessage )
   RETURN hd_calljava_s_v( cMessage, "hlog" )

FUNCTION hd_getSysDir( cType )
   RETURN hd_calljava_s_s( cType, "getSysDir" )

FUNCTION hd_ColorN2C( nColor )

   LOCAL s := "#", n1, n2, i

   FOR i := 0 to 2
      n1 := hb_BitAnd( hb_BitShift( nColor,-i*8-4 ), 15 )
      n2 := hb_BitAnd( hb_BitShift( nColor,-i*8 ), 15 )
      s += Chr( Iif(n1<10,n1+48,n1+55) ) + Chr( Iif(n2<10,n2+48,n2+55) )
   NEXT

   RETURN s

FUNCTION hd_MsgInfo( cMessage )

   LOCAL oDlg, oBtn

   INIT DIALOG oDlg TITLE cMessage

   BUTTON oBtn TEXT "Ok"

   hd_calljava_s_v( oDlg:ToString() )

   RETURN Nil

FUNCTION hd_MsgYesNo( cMessage, bContinue )

   LOCAL oDlg, oBtnYes, oBtnNo

   INIT DIALOG oDlg TITLE cMessage

   BUTTON oBtnYes TEXT "Yes"
   BUTTON oBtnNo TEXT "No"

   oDlg:bContinue := bContinue
   oDlg:aButtons := { "OBTNYES", "OBTNNO" }

   hd_calljava_s_v( oDlg:ToString() )

   RETURN Nil

FUNCTION hd_HrbLoad( cName )

   LOCAL cVarHandle := "HRBHANDLE"
   LOCAL sRet := ""
   LOCAL bOldError

   IF !__mvExist( "HRBHANDLE" )
      PUBLIC hrbHandle
   ENDIF

   IF Empty( hrbHandle )
      bOldError := ErrorBlock( { |e|break( e ) } )
      BEGIN SEQUENCE
         hrbHandle := hb_hrbLoad( 4, hd_HomeDir() + cName )
         sRet := "0"
      RECOVER
         FErase( hd_HomeDir() + cName )
         sRet := "1"
      END SEQUENCE
      ErrorBlock( bOldError )
   ENDIF

   RETURN sRet

FUNCTION hd_Main( cAppType )

   LOCAL hf, lRes := .F., oWnd, sRet, sMainFunc := "HDROIDMAIN"
   LOCAL bOldError

   IF cAppType == "1"
      IF !Empty( hf := hb_hrbGetFunsym( hrbHandle, sMainFunc ) )
         bOldError := ErrorBlock( { |e|break( e ) } )
         BEGIN SEQUENCE
            oWnd := Do( hf )
            sRet := oWnd:ToString()
            lRes := .T.
         END SEQUENCE
         ErrorBlock( bOldError )
      ELSE
         RETURN "Error: " + sMainFunc + " is not found"
      ENDIF
   ELSEIF cAppType == "2"
      IF Type( sMainFunc+"()" ) == "U"
         RETURN "Error: " + sMainFunc + "() is not found"
      ELSE
         bOldError := ErrorBlock( { |e|break( e ) } )
         BEGIN SEQUENCE
            oWnd := &(sMainFunc+"()")
            sRet := oWnd:ToString()
            lRes := .T.
         END SEQUENCE
         ErrorBlock( bOldError )
      ENDIF
   ENDIF
   IF !lRes
      RETURN "Error"
   ENDIF

   //hd_Wrlog(sRet)
   RETURN sRet
