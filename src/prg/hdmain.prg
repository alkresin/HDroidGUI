/*
 * HDroidGUI - Harbour for Android GUI framework
 * 
 */
#include "hdext.ch"
#include "hdroidgui.ch"

MEMVAR hrbHandle

FUNCTION event_Menu( cName )

   LOCAL oWnd := Atail( HDWindow():aWindows ), id := Val(Substr(cName,2))

   IF Valtype( oWnd:aMenu ) == "A" .AND. id > 0 .AND. id <= Len( oWnd:aMenu )
      Eval( oWnd:aMenu[id,3] )
   ENDIF

   RETURN Nil

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

FUNCTION event_Timer( cName )

   RETURN HDTimer():TimerFunc( cName )

FUNCTION cb_Browse( cCmd )
   
   LOCAL nPos := hb_At( ":",cCmd,5 ), sq, nRow
   LOCAL oItem := Atail( HDWindow():aWindows ):FindByName( Substr( cCmd, 5, nPos-5 ) )

   IF Empty( oItem ) .AND. Len(HDWindow():aWindows) > 1
      oItem := HDWindow():aWindows[Len(HDWindow():aWindows)-1]:FindByName( Substr( cCmd, 5, nPos-5 ) )
   ENDIF
   IF !Empty( oItem )
      IF ( sq := Left( cCmd,3 ) ) == "row"
         RETURN oItem:GetRow( Val( Substr( cCmd, nPos+1 ) ) + 1 )
      ELSEIF sq == "cou"
         RETURN LTrim( Str( oItem:RowCount() ) )
      ELSEIF sq == "cli"
         oItem:GoTo( nRow := ( Val( Substr( cCmd, nPos+1 ) ) + 1 ) )
         RETURN Eval( oItem:bClick, oItem, nRow )
      ENDIF
   ENDIF

   RETURN ""

FUNCTION hd_WrLog( cMessage )
   RETURN hd_calljava_s_v( cMessage, "hlog" )

FUNCTION hd_Toast( cMessage )
   RETURN hd_calljava_s_v( cMessage, "toast" )

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

FUNCTION hd_Version( n )

   IF !Empty( n )
      IF n == 1
         RETURN HDROIDGUI_VERSION
      ELSEIF n == 2
         RETURN HDROIDGUI_BUILD
      ENDIF
   ENDIF

   RETURN "HDroidGUI " + HDROIDGUI_VERSION + " Build " + Ltrim(Str(HDROIDGUI_BUILD))

FUNCTION hd_getScreenSize()

   LOCAL s := hd_calljava_s_s( "getscrsiz:" )
   LOCAL nPos := At( "/", s )

   IF nPos > 0
      RETURN { Val( Left(s,nPos-1) ), Val( Substr(s,nPos+1) ) }
   ENDIF

   RETURN Nil

FUNCTION hd_setMargins( oWidget, ml, mt, mr, mb )

   IF PCount() == 2
      mt := mr := mb := ml
   ENDIF
   IF PCount() == 3
      mr := ml
      mb := mt
   ENDIF
   oWidget:nMarginL := ml
   oWidget:nMarginT := mt
   oWidget:nMarginR := mr
   oWidget:nMarginB := mb

   RETURN Nil

FUNCTION hd_setPadding( oWidget, pl, pt, pr, pb )

   IF PCount() == 2
      pt := pr := pb := pl
   ENDIF
   IF PCount() == 3
      pr := pl
      pb := pt
   ENDIF
   oWidget:nPaddL := pl
   oWidget:nPaddT := pt
   oWidget:nPaddR := pr
   oWidget:nPaddB := pb

   RETURN Nil

FUNCTION hd_MsgInfo( cMessage, bExit )

   LOCAL oDlg, oBtn

   INIT DIALOG oDlg TITLE cMessage ON EXIT bExit

   BUTTON oBtn TEXT "Ok"

   ACTIVATE DIALOG oDlg

   RETURN Nil

FUNCTION hd_MsgYesNo( cMessage, bExit )

   LOCAL oDlg, oBtnYes, oBtnNo

   INIT DIALOG oDlg TITLE cMessage ON EXIT bExit

   BUTTON oBtnYes TEXT "Yes"
   BUTTON oBtnNo TEXT "No"

   oDlg:aButtons := { "OBTNYES", "OBTNNO" }

   ACTIVATE DIALOG oDlg

   RETURN Nil

FUNCTION hd_MsgGet( cMessage, cHint, bExit )

   LOCAL oDlg, oEdit1, oBtn

   INIT DIALOG oDlg TITLE cMessage ON EXIT bExit

   EDITBOX oEdit1
   IF cHint != Nil
      oEdit1:cHint := cHint
   ENDIF
   BUTTON oBtn TEXT "Ok"

   ACTIVATE DIALOG oDlg

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

   LOCAL hf, oWnd, sMainFunc := "HDROIDMAIN"
   //LOCAL bOldError
   STATIC lFirst := .T.

   IF lFirst
      ErrorBlock( {|oError|DefError(oError)} )
   ENDIF
   HDWindow():lMain := .T.
   IF cAppType == "1"
      IF !Empty( hf := hb_hrbGetFunsym( hrbHandle, sMainFunc ) )
         //bOldError := ErrorBlock( { |e|break( e ) } )
         BEGIN SEQUENCE
            oWnd := Do( hf, lFirst )
         END SEQUENCE
         //ErrorBlock( bOldError )
      ELSE
         RETURN ""
      ENDIF
   ELSEIF cAppType == "2"
      IF Type( sMainFunc+"()" ) == "U"
         RETURN ""
      ELSE
         //bOldError := ErrorBlock( { |e|break( e ) } )
         BEGIN SEQUENCE
            oWnd := &(sMainFunc+"("+Iif(lFirst,".t.",".f.")+")")
         END SEQUENCE
         //ErrorBlock( bOldError )
      ENDIF
   ENDIF
   lFirst := .F.
   HDWindow():lMain := .F.

   RETURN ""

FUNCTION hd_InitWindow( cId )

   LOCAL aWindows := HDWindow():aWindows, i, aBack

   IF !Empty( cId )
      FOR i := Len( aWindows ) TO 1 STEP -1
         IF aWindows[i]:id == cId
            aWindows[i]:Init()
            EXIT
         ENDIF
      NEXT
      IF i == 0
         aBack := HDWindow():aBackupW
         FOR i := Len( aBack ) TO 1 STEP -1
            IF aBack[i]:id == cId
               AAdd( aWindows, aBack[i] )
               ADel( aBack, i )
               ASize( HDWindow():aBackupW, Len(HDWindow():aBackupW)-1 )
               Atail( aWindows ):Init()
            ENDIF
         NEXT
      ENDIF
   ENDIF

   RETURN "1"

FUNCTION hd_CloseAct( cId )

   IF !Empty( HDWindow():aWindows )
      HDWindow():Close( cId )
   ENDIF

   RETURN "1"

#include "error.ch"
STATIC FUNCTION DefError( oError )

   LOCAL cMessage, cDOSError, aOptions, nChoice, n

   // By default, division by zero results in zero
   IF oError:genCode == EG_ZERODIV .AND. oError:canSubstitute
      RETURN 0
   ENDIF

   // By default, retry on RDD lock error failure */
   IF oError:genCode == EG_LOCK .AND. oError:canRetry
      RETURN .T.
   ENDIF

   // Set NetErr() of there was a database open error
   IF oError:genCode == EG_OPEN .AND. oError:osCode == 32 .AND. oError:canDefault
      NetErr( .T. )
      RETURN .F.
   ENDIF

   // Set NetErr() if there was a lock error on dbAppend()
   IF oError:genCode == EG_APPENDLOCK .AND. oError:canDefault
      NetErr( .T. )
      RETURN .F.
   ENDIF

   cMessage := ErrorMessage( oError )
   IF ! Empty( oError:osCode )
      cDOSError := hb_StrFormat( "(DOS Error %1$d)", oError:osCode )
   ENDIF

   IF cDOSError != NIL
      cMessage += " " + cDOSError
   ENDIF

   n := 1
   DO WHILE ! Empty( ProcName( ++n ) )
      cMessage += Chr( 13 ) + Chr( 10 ) + "Called from " + ProcFile( n ) + "->" + ProcName( n ) + "(" + AllTrim( Str( ProcLine( n ++ ) ) ) + ")"
   ENDDO

   hd_wrlog( cMessage )
   hd_Toast( "Harbour error" )
   BREAK(oError)

   RETURN .F.
