package su.harbour.hDroidGUI;

import android.content.Context;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.LinearLayout;
import android.widget.TextView;

import android.widget.LinearLayout.LayoutParams;


public class BrowseAdapter extends BaseAdapter {

   Context ctx;
   String stag = null;
   String stru = null;

   BrowseAdapter( Context context, String tag ) {
     ctx = context;
     stag = tag;
     stru = Harbour.hbobj.hrbCall( "CB_BROWSE","str:" + stag + ":" );
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
     int nPos1, nPos2, nWidth, i = 0;
     LinearLayout ll;
     TextView tv;

     if (view == null) {    
        // Create row as a View
        LinearLayout.LayoutParams parms;
        ll = new LinearLayout(ctx);
        ll.setOrientation(LinearLayout.HORIZONTAL);

        nPos1 = 0;
        do {
          nPos2 = stru.indexOf( ":",nPos1 );
          if( nPos2 > 0 ) {
             nWidth = Integer.parseInt( stru.substring( nPos1, nPos2 ) );

             tv = new TextView(ctx);
             if( nWidth == 0 )
                parms = new LinearLayout.LayoutParams(  nWidth, LinearLayout.LayoutParams.MATCH_PARENT, 1 );
             else
                parms = new LinearLayout.LayoutParams(  nWidth, LinearLayout.LayoutParams.MATCH_PARENT );
             tv.setLayoutParams(parms);

             ll.addView( tv );
          }
          nPos1 = nPos2 + 1;
        } while( nPos2 > 0 );

        view = ll;
     }

     // Fill the row (View) with values
     nPos1 = 0;
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
