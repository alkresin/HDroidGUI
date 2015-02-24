/*
 * HDroidGUI - Harbour for Android GUI framework
 * 
 */
#include "hdext.ch"

MEMVAR hrbHandle

FUNCTION event_BtnClick( cName )
   LOCAL oItem := HDGUIObject():oDefaultParent:aItems[1]

   IF __ObjHasMsg( oItem, "AITEMS" )
      oItem := oItem:FindByName( cName )
   ELSEIF Empty( oItem:objname ) .OR. !(oItem:objname == cName)
      oItem := Nil
   ENDIF
   IF Empty( oItem ) .OR. !__ObjHasMsg( oItem, "BCLICK" ) .OR. Empty( oItem:bClick )
      RETURN ""
   ENDIF

   RETURN Eval( oItem:bClick )

FUNCTION event_KeyDown( cName )

   LOCAL oItem := HDGUIObject():oDefaultParent:aItems[1]
   LOCAL nPos := At( ":", cName ), nKey := Val( Substr( cName, nPos+1 ) )

   cName := Left( cName, nPos-1 )
   IF __ObjHasMsg( oItem, "AITEMS" )
      oItem := oItem:FindByName( cName )
   ELSEIF Empty( oItem:objname ) .OR. !(oItem:objname == cName)
      oItem := Nil
   ENDIF
   IF Empty( oItem ) .OR. !__ObjHasMsg( oItem, "BKEYDOWN" ) .OR. Empty( oItem:bKeyDown )
      RETURN "0"
   ENDIF

   RETURN Eval( oItem:bKeyDown, nKey )

FUNCTION h4a_WrLog( cMessage )
   RETURN h4a_calljava_s_v( cMessage, "hlog" )

FUNCTION h4a_getSysDir( cType )
   RETURN h4a_calljava_s_s( cType, "getSysDir" )

FUNCTION h4a_ColorN2C( nColor )

   LOCAL s := "#", n1, n2, i

   FOR i := 0 to 2
      n1 := hb_BitAnd( hb_BitShift( nColor,-i*8-4 ), 15 )
      n2 := hb_BitAnd( hb_BitShift( nColor,-i*8 ), 15 )
      s += Chr( Iif(n1<10,n1+48,n1+55) ) + Chr( Iif(n2<10,n2+48,n2+55) )
   NEXT

   RETURN s

FUNCTION h4a_HrbLoad( cName )

   LOCAL cVarHandle := "HRBHANDLE"
   LOCAL sRet := ""
   LOCAL bOldError

   IF !__mvExist( "HRBHANDLE" )
      PUBLIC hrbHandle
   ENDIF

   IF Empty( hrbHandle )
      bOldError := ErrorBlock( { |e|break( e ) } )
      BEGIN SEQUENCE
         hrbHandle := hb_hrbLoad( 4, h4a_HomeDir() + cName )
         sRet := "0"
      RECOVER
         FErase( h4a_HomeDir() + cName )
         sRet := "1"
      END SEQUENCE
      ErrorBlock( bOldError )
   ENDIF

   RETURN sRet

FUNCTION h4a_Main( cAppType )

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

   //h4a_Wrlog(sRet)
   RETURN sRet
