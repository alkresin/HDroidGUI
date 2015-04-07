package su.harbour.hDroidGUI;

import android.app.Activity;
import android.os.Bundle;
import android.view.View;
import android.view.Menu;
import android.view.MenuItem;
import android.content.Intent;

import org.json.JSONArray;
import org.json.JSONException;

public class HDActivity extends Activity {

   private View mainView;
   private JSONArray jaMenu = null;
   private String sId;
   public boolean bMain = false;

   @Override
   protected void onCreate(Bundle savedInstanceState) {
      super.onCreate(savedInstanceState);

      if( bMain ) {

         sId = "0";
         //MainApp.harb.setDopClass( DopActivity.class );
         mainView = Harbour.createAct( this, null );

      } else {

         Intent intent = getIntent();   
         String sAct = intent.getStringExtra("sact");
         sId = intent.getStringExtra("sid");
         mainView = Harbour.createAct( this, sAct );
      }
      jaMenu = Harbour.jaMenu;
      setContentView( mainView );
      Harbour.hbobj.hrbCall( "HD_INITWINDOW",sId );
   }

   @Override
   protected void onResume() {
       super.onResume();

      Harbour.setContext( this, mainView );
   }

   @Override
   protected void onDestroy() {
       super.onDestroy();

       Harbour.closeAct( sId );
   }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
       //Harbour.SetMenu( menu );
       if( jaMenu == null )
          return false;

       int i, ilen = jaMenu.length();
       try {
          for( i = 1; i<ilen; i++ ) {

             menu.add( Menu.NONE, i, Menu.NONE, jaMenu.getString(i) );
          }
       }
       catch (JSONException e) {
          Harbour.hlog("jaMenu error");
          jaMenu = null;
          return false;
       }
       jaMenu = null;

       return true;
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
       //Harbour.onMenuSel( item.getItemId() );
       Harbour.hbobj.hrbCall( "EVENT_MENU", "/" + item.getItemId() );
       return true;
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
       if(requestCode == Harbour.ACTION_TAKE_PHOTO && resultCode == RESULT_OK ) {
          String sPath = Harbour.sTemp;
          if( sPath != null ) {
             Harbour.hbobj.hrbCall( "CB_PHOTO", sPath );
          }
       }
    }

    @Override 
    public void onBackPressed() {
       if( Harbour.hbobj.hrbCall( "EVENT_BACK", "/" ).equals( "1" ) )
          super.onBackPressed();
    }

    @Override
    protected void onSaveInstanceState(Bundle outState) {
    }


}
