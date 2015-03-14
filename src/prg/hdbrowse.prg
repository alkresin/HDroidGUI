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

   DATA aColumns   INIT  {}
   DATA xDataSet
   DATA nCurrent   INIT  0

   DATA bRowcount

   METHOD New( cText, nWidth, nHeight, tcolor, bcolor, oFont )
   METHOD AddColumn( oColumn )
   METHOD RowCount()
   METHOD GetRow( nRow )
   METHOD GetStru()

   METHOD ToString()

ENDCLASS

METHOD New( cText, nWidth, nHeight, tcolor, bcolor, oFont ) CLASS HDBrowse

   ::Super:New( cText, nWidth, nHeight, tcolor, bcolor, oFont )

   RETURN Self

METHOD AddColumn( oColumn ) CLASS HDBrowse

   AAdd( ::aColumns, oColumn )

   RETURN oColumn

METHOD RowCount() CLASS HDBrowse

   IF ::bRowcount != Nil
      RETURN Eval( ::bRowcount, Self )
   ENDIF

   RETURN 0

METHOD GetRow( nRow ) CLASS HDBrowse

   LOCAL i, sRet := ""

   FOR i := 1 TO Len( ::aColumns )
      sRet += Eval( ::aColumns[i]:block, Self, nRow+1, i ) + ":"
   NEXT

   ::nCurrent := nRow + 1

   RETURN sRet

METHOD GetStru() CLASS HDBrowse

   LOCAL i, sRet := ""

   FOR i := 1 TO Len( ::aColumns )
      sRet += Ltrim( Str( ::aColumns[i]:nWidth ) ) + ":"
   NEXT

   RETURN sRet


METHOD ToString() CLASS HDBrowse

   RETURN "brw" + ::Super:ToString()
