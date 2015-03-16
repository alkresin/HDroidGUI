package su.harbour.hDroidGUI;

import android.content.Context;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.LinearLayout;
import android.widget.AbsListView;
import android.widget.TextView;

import android.widget.LinearLayout.LayoutParams;
import android.view.Gravity;


public class BrowseAdapter extends BaseAdapter {

   Context ctx;
   String stag = null;
   int [] aColumns = null;
   int iRowHeight = 0;

   BrowseAdapter( Context context, String tag ) {
     ctx = context;
     stag = tag;
     String stru = Harbour.hbobj.hrbCall( "CB_BROWSE","str:" + stag + ":" );
     int nPos1 = 0, nPos2, nPos0, nSch = 0;

     while( nPos1 >= 0 && stru.substring(nPos1,nPos1+2).equals(",,") ) {
        nPos1 += 2;
        nPos2 = stru.indexOf( ":",nPos1 );
        if( stru.substring(nPos1,nPos2).equals("h") ) {
           nPos1 = nPos2 + 1;
           nPos2 = stru.indexOf( ",,",nPos1 );
           iRowHeight = Integer.parseInt( stru.substring( nPos1, nPos2 ) );

        } else if( stru.substring(nPos1,nPos2).equals("col") ) {
           nPos1 = nPos2+1;
           nPos0 = nPos1;
           do {
              nPos2 = stru.indexOf( ":",nPos1 );
              if( nPos2 > 0 )
                 nSch ++;
              nPos1 = nPos2 + 1;
           } while( nPos2 > 0 );
           aColumns = new int [nSch];
           nPos1 = nPos0;
           nSch = 0;
           do {
              nPos2 = stru.indexOf( ":",nPos1 );
              if( nPos2 > 0 ) {
                 aColumns[nSch] = Integer.parseInt( stru.substring( nPos1, nPos2 ) );
                 nSch ++;
              }
              nPos1 = nPos2 + 1;
           } while( nPos2 > 0 );
           break;
        }
        nPos1 = stru.indexOf( ",,",nPos1 );
     }
   }

   @Override
   public int getCount() {

      return Integer.parseInt( Harbour.hbobj.hrbCall( "CB_BROWSE","cou:" + stag + ":" ) );
   }

   @Override
   public Object getItem( int position ) {
      return null;
   }

   @Override
   public long getItemId( int position ) {
     return position;
   }

   @Override
   public View getView( int position, View convertView, ViewGroup parent ) {

     View view = convertView;
     String sRow = Harbour.hbobj.hrbCall( "CB_BROWSE","row:" + stag + ":" + position );
     int nPos1, nPos2, nWidth, i, iLength;
     LinearLayout ll;
     TextView tv;

     if(view == null) {    
        // Create row as a View
        LinearLayout.LayoutParams parms;
        ll = new LinearLayout(ctx);
        ll.setOrientation(LinearLayout.HORIZONTAL);

        if( iRowHeight > 0 ) {
           AbsListView.LayoutParams params = new AbsListView.LayoutParams( LinearLayout.LayoutParams.MATCH_PARENT, iRowHeight );
           ll.setLayoutParams(params);
        }

        iLength = aColumns.length;
        for( i=0; i<iLength; i++ ) {
           nWidth = aColumns[i];
           tv = new TextView(ctx);
           if( nWidth == 0 )
              parms = new LinearLayout.LayoutParams(  nWidth, LinearLayout.LayoutParams.MATCH_PARENT, 1 );
           else
              parms = new LinearLayout.LayoutParams(  nWidth, LinearLayout.LayoutParams.MATCH_PARENT );
           tv.setLayoutParams(parms);
           tv.setGravity( Gravity.CENTER_VERTICAL );
           ll.addView( tv );
        }

        view = ll;
     }

     // Fill the row (View) with values
     nPos1 = i = 0;
     do {
       nPos2 = sRow.indexOf( ":",nPos1 );
       if( nPos2 > 0 ) {
          tv = (TextView) ((ViewGroup)view).getChildAt(i);
          tv.setText( sRow.substring( nPos1, nPos2 ) );
          i++;
       }
       nPos1 = nPos2 + 1;
     } while( nPos2 > 0 );

     return view;
   }

}
