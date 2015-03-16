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

   LOCAL i, sRet := ""

   ::GoTo( nRow )

   FOR i := 1 TO Len( ::aColumns )
      sRet += Eval( ::aColumns[i]:block, Self, nRow, i ) + ":"
   NEXT

   RETURN sRet

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

   METHOD New( cAlias, nWidth, nHeight, tcolor, bcolor, oFont, lHScroll, bClick )
   METHOD RowCount()
   METHOD GoTo( nRow )
   METHOD GetRow( nRow )

ENDCLASS

METHOD New( cAlias, nWidth, nHeight, tcolor, bcolor, oFont, lHScroll, bClick ) CLASS HDBrwDbf

   ::Super:New( nWidth, nHeight, tcolor, bcolor, oFont, lHScroll, bClick )

   ::aBuffer := Array( ::nBufMax, 2 )
   ::data := cAlias
   (cAlias)->( dbGoTop() )

   RETURN Self

METHOD RowCount() CLASS HDBrwDbf
   local n := (::data)->( RecCount() )
   //hd_wrlog( "count "+str(n) )
   RETURN n

METHOD GoTo( nRow ) CLASS HDBrwDbf

   IF nRow != ::nCurrent
      (::data)->( dbSkip(nRow-::nCurrent) )
      ::nCurrent := nRow
   ENDIF

   RETURN nRow

METHOD GetRow( nRow ) CLASS HDBrwDbf

   LOCAL i, sRet := ""

   IF nRow != ::nCurrent .OR. ::nBufSize == 0
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
               ::aBuffer[::nBufCurr,1] := nRow
            ENDIF
         NEXT
      ELSE
         ::GoTo( nRow )
         IF ::nBufSize < ::nBufMax
            ::nBufSize ++
         ELSE
            ADel( ::aBuffer, 1 )
         ENDIF
         ::nBufCurr := ::nBufSize
         ::aBuffer[::nBufCurr,1] := nRow
         ::aBuffer[::nBufCurr,2] := Nil
      ENDIF
   ENDIF

   IF ::aBuffer[::nBufCurr,2] == Nil
      //hd_wrlog( "getrow "+str(nRow) )
      FOR i := 1 TO Len( ::aColumns )
         sRet += Eval( ::aColumns[i]:block, Self, nRow, i ) + ":"
         ::aBuffer[::nBufCurr,2] := sRet
      NEXT
   ELSE
      //hd_wrlog( "getrow buffer "+str(nRow) )
      sRet := ::aBuffer[::nBufCurr,2]
   ENDIF

   RETURN sRet
