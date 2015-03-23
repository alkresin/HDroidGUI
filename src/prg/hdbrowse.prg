/*
 * HDroidGUI - Harbour for Android GUI framework
 * HDBrowse
 */

#include "hbclass.ch"

CLASS HDColumn INHERIT HDGUIObject

   DATA nWidth INIT 0
   DATA block

   METHOD New( block, nWidth )

ENDCLASS

METHOD New( block, nWidth ) CLASS HDColumn

   ::block  := block
   ::nWidth := nWidth

   RETURN Self

CLASS HDBrowse INHERIT HDWidget

   DATA lHScroll   INIT  .F.
   DATA aColumns   INIT  {}
   DATA data
   DATA nCurrent   INIT  1

   DATA nRowHeight INIT 0

   DATA bRowcount
   DATA bClick

   METHOD New( nWidth, nHeight, tcolor, bcolor, oFont, lHScroll, bClick )
   METHOD AddColumn( oColumn )
   METHOD GoTo( nRow )
   METHOD RowCount()
   METHOD GetRow( nRow )
   METHOD GetStru()
   METHOD Refresh()

   METHOD ToString()

ENDCLASS

METHOD New( nWidth, nHeight, tcolor, bcolor, oFont, lHScroll, bClick ) CLASS HDBrowse

   ::Super:New( , nWidth, nHeight, tcolor, bcolor, oFont )

   ::lHScroll := lHScroll
   ::bClick   := bClick

   RETURN Self

METHOD AddColumn( oColumn ) CLASS HDBrowse

   AAdd( ::aColumns, oColumn )

   RETURN oColumn

METHOD GoTo( nRow ) CLASS HDBrowse

   ::nCurrent := nRow

   RETURN nRow

METHOD RowCount() CLASS HDBrowse

   IF ::bRowcount != Nil
      RETURN Eval( ::bRowcount, Self )
   ENDIF

   RETURN 0

METHOD GetRow( nRow ) CLASS HDBrowse

   LOCAL i, aRet := Array(Len(::aColumns))

   ::GoTo( nRow )

   FOR i := 1 TO Len( ::aColumns )
      aRet[i] := Eval( ::aColumns[i]:block, Self, nRow, i )
   NEXT

   RETURN hb_jsonEncode(aRet)

METHOD GetStru() CLASS HDBrowse

   LOCAL i, sRet := ""

   IF ::nRowHeight > 0
      sRet += ",,h:" + Ltrim(Str(::nRowHeight))
   ENDIF
   sRet += ",,col:"
   FOR i := 1 TO Len( ::aColumns )
      sRet += Ltrim( Str( ::aColumns[i]:nWidth ) ) + ":"
   NEXT

   RETURN sRet


METHOD ToString() CLASS HDBrowse

   LOCAL sRet := ""

   IF !Empty( ::lHScroll )
      sRet += ",,hscroll:t"
   ENDIF
   IF ::bClick != Nil
      sRet += ",,bcli:1"
   ENDIF

   RETURN "brw" + ::Super:ToString() + sRet

METHOD Refresh() CLASS HDBrowse

   RETURN hd_calljava_s_v( "adachg:" + ::objname + ":" )


CLASS HDBrwArray INHERIT HDBrowse

   METHOD New( aArray, nWidth, nHeight, tcolor, bcolor, oFont, lHScroll, bClick )
   METHOD RowCount()

ENDCLASS

METHOD New( aArray, nWidth, nHeight, tcolor, bcolor, oFont, lHScroll, bClick ) CLASS HDBrwArray

   ::Super:New( nWidth, nHeight, tcolor, bcolor, oFont, lHScroll, bClick )

   ::data := aArray

   RETURN Self

METHOD RowCount() CLASS HDBrwArray
   RETURN Len( ::data )


CLASS HDBrwDbf INHERIT HDBrowse

   DATA  nBufMax   INIT  48
   DATA  nBufSize  INIT  0
   DATA  nBufCurr  INIT  0
   DATA  aBuffer
   DATA  nRecno, nRecCount

   METHOD New( cAlias, nWidth, nHeight, tcolor, bcolor, oFont, lHScroll, bClick )
   METHOD RowCount()
   METHOD GoTo( nRow )
   METHOD GetRow( nRow )
   METHOD Refresh()
   METHOD RefreshRow( nRow )

ENDCLASS

METHOD New( cAlias, nWidth, nHeight, tcolor, bcolor, oFont, lHScroll, bClick ) CLASS HDBrwDbf

   ::Super:New( nWidth, nHeight, tcolor, bcolor, oFont, lHScroll, bClick )

   ::aBuffer := Array( ::nBufMax, 2 )
   ::data := cAlias
   (cAlias)->( dbGoTop() )
   ::nRecno := (::data)->( Recno() )
   ::nRecCount := (::data)->( RecCount() )

   RETURN Self

METHOD RowCount() CLASS HDBrwDbf
   RETURN ::nRecCount

METHOD GoTo( nRow ) CLASS HDBrwDbf

   IF ::nRecno != (::data)->( Recno() )
      (::data)->( dbGoTo( ::nRecno ) )
   ENDIF
   IF nRow != ::nCurrent
      (::data)->( dbSkip(nRow-::nCurrent) )
      ::nCurrent := nRow
      ::nRecno := (::data)->( Recno() )
   ENDIF

   RETURN nRow

METHOD GetRow( nRow, lUpd ) CLASS HDBrwDbf

   LOCAL i, sRet, aRet := Array(Len(::aColumns))

   IF ::nBufSize > 0 .AND. ::aBuffer[1,1] <= nRow .AND. ::aBuffer[::nBufSize,1] >= nRow
      FOR i := 1 TO ::nBufSize
         IF ::aBuffer[i,1] == nRow
            ::nBufCurr := i
            EXIT
         ELSEIF ::aBuffer[i,1] > nRow
            AIns( ::aBuffer, i )
            IF ::nBufSize < ::nBufMax
               ::nBufSize ++
            ENDIF
            ::nBufCurr := i
            lUpd := .T.
            ::aBuffer[i] := { nRow, Nil }
         ENDIF
      NEXT
      IF !Empty( lUpd )
         ::GoTo( nRow )
         ::aBuffer[::nBufCurr,2] := Nil
      ENDIF
   ELSE
      ::GoTo( nRow )
      IF ::nBufSize < ::nBufMax
         ::nBufSize ++
      ELSE
         ADel( ::aBuffer, 1 )
         ::aBuffer[::nBufMax] := {}
      ENDIF
      ::nBufCurr := ::nBufSize
      ::aBuffer[::nBufCurr,1] := nRow
      ::aBuffer[::nBufCurr,2] := Nil
   ENDIF

   IF ::aBuffer[::nBufCurr,2] == Nil
      FOR i := 1 TO Len( ::aColumns )
         aRet[i] := Eval( ::aColumns[i]:block, Self, nRow, i )
      NEXT
      sRet := hb_jsonEncode( aRet )
      ::aBuffer[::nBufCurr,2] := sRet
      //hd_wrlog( "getrow "+str(nRow)+" "+Str(::nBufCurr,3)+" "+sRet )
   ELSE
      sRet := ::aBuffer[::nBufCurr,2]
      //hd_wrlog( "getrow buffer "+str(nRow)+" "+Str(::nBufCurr,3) +" "+sRet )
   ENDIF

   RETURN sRet

METHOD Refresh() CLASS HDBrwDbf

   ::nRecCount := (::data)->( RecCount() )

   RETURN ::Super:Refresh()

METHOD RefreshRow( nRow ) CLASS HDBrwDbf

   ::GetRow( Iif( nRow==Nil, ::nCurrent, nRow ), .T. )
   RETURN hd_calljava_s_v( "listrefr:" + ::objname + ":" )
