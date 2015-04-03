/*
 * HDroidGUI - Harbour for Android GUI framework
 * HDBrowse
 */

#include "hbclass.ch"

CLASS HDColumn INHERIT HDGUIObject

   DATA nWidth
   DATA block
   DATA cHead, cFoot
   DATA nAlign, nHeadAlign

   METHOD New( block, nWidth, cHeader, cFooter, nAlign, nHeadAlign )

ENDCLASS

METHOD New( block, nWidth, cHeader, cFooter, nAlign, nHeadAlign ) CLASS HDColumn

   ::block  := block
   ::nWidth := Iif( Empty(nWidth), 0, nWidth )
   ::cHead := cHeader
   ::cFoot := cFooter
   ::nAlign := nAlign
   ::nHeadAlign := nHeadAlign

   RETURN Self

CLASS HDBrowse INHERIT HDWidget

   DATA lHScroll   INIT  .F.
   DATA aColumns   INIT  {}
   DATA data
   DATA nCurrent   INIT  1

   DATA nRowHeight INIT 0
   DATA RowTColor, oRowStyle

   DATA nHeadHeight, HeadBColor, HeadTColor
   DATA nFootHeight, FootBColor, FootTColor

   DATA bRowcount
   DATA bClick

   METHOD New( cName, nWidth, nHeight, tcolor, bcolor, oFont, lHScroll, bClick )
   METHOD AddColumn( oColumn )
   METHOD GoTo( nRow )
   METHOD RowCount()
   METHOD CalcRow()
   METHOD GetRow( nRow )
   METHOD Refresh()

   METHOD ToArray( arr )

ENDCLASS

METHOD New( cName, nWidth, nHeight, tcolor, bcolor, oFont, lHScroll, bClick ) CLASS HDBrowse

   ::Super:New( cName,, nWidth, nHeight, tcolor, bcolor, oFont )

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

METHOD CalcRow() CLASS HDBrowse

   LOCAL i, aRet := Array(Len(::aColumns))

   FOR i := 1 TO Len( ::aColumns )
      aRet[i] := Eval( ::aColumns[i]:block, Self, i )
   NEXT

   RETURN hb_jsonEncode(aRet)

METHOD GetRow( nRow ) CLASS HDBrowse

   ::GoTo( nRow )

   RETURN ::CalcRow( nRow )

METHOD ToArray( arr ) CLASS HDBrowse

   LOCAL arr1, arr2, i, s

   IF arr == Nil
      arr := {}
   ENDIF

   Aadd( arr, "brw:" + ::objname )
   IF !Empty( ::lHScroll )
      Aadd( arr, "hscroll:t" )
   ENDIF
   IF ::bClick != Nil
      Aadd( arr, "bcli:1" )
   ENDIF
   IF ::nRowHeight > 0 .OR. ::RowTColor != Nil .OR. ::oRowStyle != Nil
      arr1 := {}
      IF ::nRowHeight > 0
         Aadd( arr1, "h:" + Ltrim(Str(::nRowHeight)) )
      ENDIF
      IF ::RowTColor != Nil
         Aadd( arr1, "ct:" + Iif( Valtype(::RowTColor)=="C", ::RowTColor, hd_ColorN2C(::RowTColor) ) )
      ENDIF
      IF ::oRowStyle != Nil
         IF Valtype( ::oRowStyle ) == "A"
            s := ""
            FOR i := 1 TO Len( ::oRowStyle )
               s += Iif( i>1, ",", "" ) + Iif( Empty(::oRowStyle[i]), "", Ltrim(Str(::oRowStyle[i]:id)) )
            NEXT
            Aadd( arr1, "stl:" + s )
         ELSE
            Aadd( arr1, "stl:" + Ltrim(Str(::oRowStyle:id)) )
         ENDIF
      ENDIF
      Aadd( arr, "row:" + hb_jsonEncode(arr1) )
   ENDIF
   IF !Empty( ::nHeadHeight )
      Aadd( arr, "hdh:"+Ltrim(Str(::nHeadHeight)) )
   ENDIF
   IF ::HeadBColor != Nil
      Aadd( arr, "hdcb:" + Iif( Valtype(::HeadBColor)=="C", ::HeadBColor, hd_ColorN2C(::HeadBColor) ) )
   ENDIF
   IF ::HeadTColor != Nil
      Aadd( arr, "hdct:" + Iif( Valtype(::HeadTColor)=="C", ::HeadTColor, hd_ColorN2C(::HeadTColor) ) )
   ENDIF
   IF !Empty( ::nFootHeight )
      Aadd( arr, "fth:"+Ltrim(Str(::nFootHeight)) )
   ENDIF
   IF ::FootBColor != Nil
      Aadd( arr, "ftcb:" + Iif( Valtype(::FootBColor)=="C", ::FootBColor, hd_ColorN2C(::FootBColor) ) )
   ENDIF
   IF ::FootTColor != Nil
      Aadd( arr, "ftct:" + Iif( Valtype(::FootTColor)=="C", ::FootTColor, hd_ColorN2C(::FootTColor) ) )
   ENDIF

   arr1 := {}
   FOR i := 1 TO Len( ::aColumns )
      arr2 := { "w:" + Ltrim(Str(::aColumns[i]:nWidth)) }
      IF !Empty( ::aColumns[i]:cHead )
         Aadd( arr2, "hd:"+::aColumns[i]:cHead )
      ENDIF
      IF !Empty( ::aColumns[i]:cFoot )
         Aadd( arr2, "ft:"+::aColumns[i]:cFoot )
      ENDIF
      IF !Empty( ::aColumns[i]:nAlign )
         Aadd( arr2, "ali:"+Ltrim(Str(::aColumns[i]:nAlign)) )
      ENDIF
      IF !Empty( ::aColumns[i]:nHeadAlign )
         Aadd( arr2, "hali:"+Ltrim(Str(::aColumns[i]:nHeadAlign)) )
      ENDIF
      Aadd( arr1, arr2 )
   NEXT
   Aadd( arr, "col:" + hb_jsonEncode(arr1) )

   RETURN ::Super:ToArray( arr )

METHOD Refresh() CLASS HDBrowse

   RETURN hd_calljava_s_v( "adachg:" + ::objname + ":" )


CLASS HDBrwArray INHERIT HDBrowse

   METHOD New( cName, aArray, nWidth, nHeight, tcolor, bcolor, oFont, lHScroll, bClick )
   METHOD RowCount()

ENDCLASS

METHOD New( cName, aArray, nWidth, nHeight, tcolor, bcolor, oFont, lHScroll, bClick ) CLASS HDBrwArray

   ::Super:New( cName, nWidth, nHeight, tcolor, bcolor, oFont, lHScroll, bClick )

   ::data := aArray

   RETURN Self

METHOD RowCount() CLASS HDBrwArray
   RETURN Len( ::data )


CLASS HDBrwDbf INHERIT HDBrowse

   DATA  nBufMax
   DATA  nBufSize  INIT  0
   DATA  nBufCurr  INIT  0
   DATA  aBuffer
   DATA  nRecno, nRecCount
   DATA  lFilter   INIT .F.
   DATA  xFilter

   METHOD New( cName, cAlias, nWidth, nHeight, tcolor, bcolor, oFont, lHScroll, bClick, xFilter )
   METHOD RowCount()
   METHOD GoTo( nRow )
   METHOD GetRow( nRow )
   METHOD Rebuild( xFilter )
   METHOD Refresh()
   METHOD RefreshRow( nRow )

   METHOD ToArray( arr )

ENDCLASS

METHOD New( cName, cAlias, nWidth, nHeight, tcolor, bcolor, oFont, lHScroll, bClick, xFilter ) CLASS HDBrwDbf

   ::Super:New( cName, nWidth, nHeight, tcolor, bcolor, oFont, lHScroll, bClick )

   ::data := cAlias

   ::Rebuild( xFilter )

   RETURN Self

METHOD RowCount() CLASS HDBrwDbf
   RETURN ::nRecCount

METHOD GoTo( nRow ) CLASS HDBrwDbf

   IF ::nRecno != (::data)->( Recno() )
      (::data)->( dbGoTo( ::nRecno ) )
   ENDIF
   IF nRow != ::nCurrent
      IF ::lFilter
         (::data)->( dbGoTo( ::aBuffer[nRow,3]) )
      ELSE
         (::data)->( dbSkip(nRow-::nCurrent) )
      ENDIF
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
         //::GoTo( nRow )
         ::aBuffer[::nBufCurr,2] := Nil
      ENDIF
   ELSE
      //::GoTo( nRow )
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
      sRet := ::aBuffer[::nBufCurr,2] := ::Super:GetRow( nRow )
      //hd_wrlog( "getrow "+str(nRow)+" "+Str(::nBufCurr,3)+" "+sRet )
   ELSE
      sRet := ::aBuffer[::nBufCurr,2]
      //hd_wrlog( "getrow buffer "+str(nRow)+" "+Str(::nBufCurr,3) +" "+sRet )
   ENDIF

   RETURN sRet

METHOD Rebuild( xFilter ) CLASS HDBrwDbf

   LOCAL block, arr, nArr := 0

   ::lFilter := .T.
   IF Valtype( xFilter ) == "A"
   ELSEIF Valtype( xFilter ) == "C"
      IF !Empty( ::aColumns )
         dbSelectArea( ::data )
         block := &( "{||" + xFilter + "}" )
         arr := Array( 100 )
         dbGoTop()
         DO WHILE ! Eof()
            IF Eval( block )
               IF nArr == Len( arr )
                  arr := ASize( arr, nArr+100 )
               ENDIF
               nArr ++
               arr[nArr] := { nArr, ::CalcRow(), Recno() }
            ENDIF
            dbSkip(1)
         ENDDO
         IF nArr < Len( arr )
            arr := ASize( arr, nArr )
         ENDIF
         ::aBuffer := arr
         ::nBufSize := ::nBufMax := nArr

         IF nArr > 0
            (::data)->( dbGoTo( arr[1,3] ) )
         ENDIF
         ::nRecno := (::data)->( Recno() )
         ::nRecCount := nArr
      ELSE
         ::aBuffer := Nil
         ::xFilter := xFilter
      ENDIF
   ELSE
      ::lFilter := .F.
      ::nBufMax := 48
      ::nBufSize := ::nBufCurr := 0
      ::aBuffer := Array( ::nBufMax, 2 )
      (::data)->( dbGoTop() )
      ::nRecno := (::data)->( Recno() )
      ::nRecCount := (::data)->( ordKeyCount() )
   ENDIF

   RETURN Nil

METHOD Refresh() CLASS HDBrwDbf

   ::nRecCount := Iif( ::lFilter, Len( ::aBuffer ), (::data)->( ordKeyCount() ) )

   RETURN ::Super:Refresh()

METHOD RefreshRow( nRow ) CLASS HDBrwDbf

   ::GetRow( Iif( nRow==Nil, ::nCurrent, nRow ), .T. )
   RETURN hd_calljava_s_v( "listrefr:" + ::objname + ":" )

METHOD ToArray( arr ) CLASS HDBrwDbf

   IF ::lFilter .AND. ::aBuffer == Nil
      ::Rebuild( ::xFilter )
   ENDIF
   RETURN ::Super:ToArray( arr )
