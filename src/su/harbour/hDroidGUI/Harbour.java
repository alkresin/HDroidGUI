package su.harbour.hDroidGUI;

import android.os.Environment;
import android.util.DisplayMetrics;
import java.io.File;
import java.io.InputStream;
import java.io.OutputStream;
import java.io.IOException;
import java.io.FileOutputStream;
import android.content.Context;
import android.app.Activity;
import android.view.Menu;
import android.content.Intent;
import android.os.Handler;

import android.view.View;
import android.widget.LinearLayout;
import android.widget.TextView;
import android.widget.EditText;
import android.widget.ListView;
import android.widget.AdapterView;
import android.widget.BaseAdapter;

import android.app.AlertDialog;
import android.content.DialogInterface;

import android.util.Log;
import android.widget.Toast;

import android.app.Notification;
import android.app.NotificationManager;


public class Harbour {

    private static final String MAINHRB = "main.hrb";

    private static boolean bHrb;
    private static View mainView = null;
    private static View prevView = null;
    public static Harbour hbobj;
    public static CreateUI createui;
    public static Context context;
    public static Class dopClass = null;
    public static String cHomePath;
    public static int iScrWidth = 0;
    public static int iScrHeight = 0;

    public static String sMenu = null;
    private static String sActivity = null;

    public Harbour( Context cont ) {
       context = cont;
       cHomePath = context.getFilesDir() + "/";
       setHomePath( cHomePath );
       hbobj = this;
       createui = new CreateUI( cont );
    }

    public native void vmInit();
    public native void vmQuit();
    public native void setHomePath( String js );
    public native void setHrb( String js );
    public native String hrbOpen( String js );
    public native String hrbCall( String jsModName, String jsParam );

    public void Init( boolean bHrb ) {
       this.bHrb = bHrb;
       vmInit();
       if( bHrb )
          CopyFromAsset( MAINHRB );
    }

    public static void setDopClass( Class dclass ) {
       dopClass = dclass;
    }

    public static void setContext( Context cont, View view ) {
       context = cont;
       mainView = view;
    }

    public View createAct( Context cont, String sAct ) {

       String sMain;
       context = cont;

       DisplayMetrics dmetrics = new DisplayMetrics();
       ((Activity)cont).getWindowManager().getDefaultDisplay().getMetrics(dmetrics);
       iScrHeight = dmetrics.heightPixels;
       iScrWidth = dmetrics.widthPixels;

       if( bHrb )
          hrbOpen( MAINHRB );

       if( sAct != null )
          sMain = sAct;
       else {
          hrbCall( "HD_MAIN", bHrb? "1" : "2" );
          sMain = sActivity;
       }
       //Log.i(TAG, "hrbmain-1");
       if( sMain != null ) {
          prevView = mainView;
          mainView = createui.CreateActivity( (Activity)context, sMain);
       }
       else {
          mainView = null;
       }
       //Log.i(TAG, "hrbmain-2");
       
       if( mainView == null ) {
       
          LinearLayout ll = new LinearLayout(context);
          ll.setOrientation(LinearLayout.VERTICAL);

          TextView textview = new TextView(context);
          textview.setText("Error");
          if( sMain != null )
             hlog( sMain );
          else
             hlog( "sMain == null" );
          ll.addView(textview);

          return ll;
       }
       else
          return mainView;

    }

    public static void closeAct( String id ) {

       hbobj.hrbCall( "HD_CLOSEACT", id );

    }

    public static void SetMenu( Menu menu ) {

       if( sMenu == null )
          return;

       int nPos1 = 2, nPos2, nPosEnd = sMenu.indexOf( ")]" );
       int nIndex = 1;

       do {
          nPos2 = sMenu.indexOf( ",,",nPos1 );
          if( nPos2 <= 0 || nPos2 > nPosEnd )
             nPos2 = nPosEnd;
          menu.add( Menu.NONE, nIndex, Menu.NONE, sMenu.substring( nPos1,nPos2 ) );
          nIndex ++;
          nPos1 = nPos2 + 2;
       } while( nPos1 < nPosEnd );

       sMenu = null;

    }

    public static void onMenuSel( int id ) {
       hbobj.hrbCall( "EVENT_MENU", "/" + id );
    }

    private void CopyFromAsset( String hrbName ) {

       String sFile = cHomePath + hrbName;

       setHrb( hrbName );

       if( ! (new File(sFile).isFile()) ) {
          try {
               InputStream myInput = context.getAssets().open(hrbName);
               OutputStream myOutput = new FileOutputStream( sFile );

               byte[] buffer = new byte[myInput.available()];
               int read;
               while ((read = myInput.read(buffer)) != -1) {
                   myOutput.write(buffer, 0, read);
               }

               myOutput.flush();
               myOutput.close();
               myInput.close();

          } catch (IOException e) {
               // toast( "copyDataBase Error : " + e.getMessage() );
          }
       }
    }

    public static void toast( String message ) {

       Toast.makeText( context, message, Toast.LENGTH_SHORT ).show();

    }

    public static void hlog( String message ) {

       Log.i( "Harbour", message );
    }

    public static void jcb_sz_v( String message ) {

       String scmd, stag;
       View view = null;
       int nPos = message.indexOf(":");
       int nPos1;
       
       if( nPos <= 0 )
          return;

       scmd = message.substring( 0,nPos );
       if( scmd.equals( "exit" ) ) {

          android.os.Process.killProcess(android.os.Process.myPid());
       } else if( scmd.equals( "finish" ) ) {

          ((Activity)context).finish();
       } else {

          nPos1 = message.indexOf(":",nPos+1);
          if( nPos1 > 0 ) {
             stag = message.substring( nPos+1,nPos1 );
             view = mainView.findViewWithTag( stag );
             if( view == null && prevView != null ) {
                view = prevView.findViewWithTag( stag );
             }
          }

          if( view != null ) {
             if( scmd.equals( "settxt" ) ) {
                   ((TextView)view).setText( CreateUI.getStr( message.substring( nPos1+1 ) ) );
             } else if( scmd.equals( "setsels" ) ) {
                   ((EditText)view).setSelection( Integer.parseInt( message.substring( nPos1+1 ) ) );
             } else if( scmd.equals( "adachg" ) ) {
                   ((BaseAdapter)((ListView)view).getAdapter()).notifyDataSetChanged();
             }
          }
       }
    }

    public static String jcb_sz_sz( String message ) {

       String scmd, stag;
       TextView tview = null;
       int nPos = message.indexOf(":");
       int nPos1;
       
       if( nPos > 0 ) {

          scmd = message.substring( 0,nPos );
          if( scmd.equals( "getscrsiz" ) ) {

             return "" + iScrWidth + "/" + iScrHeight;
          } else {

             nPos1 = message.indexOf(":",nPos+1);
             if( nPos1 > 0 ) {
                stag = message.substring( nPos+1,nPos1 );
                tview = (TextView) mainView.findViewWithTag( stag );
             }

             if( scmd.equals( "gettxt" ) ) {
                if( tview != null )
                   return (String) tview.getText().toString();
             } else if( scmd.equals( "getsels" ) ) {
                if( tview != null )
                   return (String) "" + tview.getSelectionStart();
             } else if( scmd.equals( "getsele" ) ) {
                if( tview != null )
                   return (String) "" + tview.getSelectionEnd();
             }
          }
       }
       return "err";
    }

    public static void activ( String sAct ) {

       if( !sAct.substring(0,4).equals("act:") )
          return;
       int nPos1 = sAct.indexOf(",,",4);
       String sId = sAct.substring(4,nPos1);

       if( sId.equals("0") )
          sActivity = sAct;
       else if( dopClass != null ) {
          Intent intent = new Intent( context, dopClass );

          intent.putExtra( "sact", sAct );
          intent.putExtra( "sid", sId );
          context.startActivity(intent);
       }
    }

    public static void adlg( String sDlg ) {

       if( !sDlg.substring(0,4).equals("dlg:") )
          return;
       int nPosNext, nPos1, nPos2, nPos3 = sDlg.indexOf(",,");
       int iBtns = 0;
       String [][] aParams;
       String sName, sObjName;
       String sText;
       String sId = sDlg.substring(4,nPos3);
       //DialogInterface.OnClickListener func;

       nPosNext = sDlg.indexOf(",,/",5);
       AlertDialog.Builder builder = new AlertDialog.Builder(context);

       aParams = CreateUI.GetParamsList( sDlg.substring(nPos3,nPosNext) );
       int iArr = 0;
       while( aParams[iArr][0] != null ) {

          if( aParams[iArr][0].equals("t") ) {
             builder.setTitle(aParams[iArr][1]);
          }
          iArr ++;
       }
       if( sDlg.indexOf(",,/btn") > 0 )
          builder.setCancelable(false);

       do {
          nPos1 = nPosNext + 3;
          nPosNext = sDlg.indexOf(",,/",nPos1);
          nPos2 = sDlg.indexOf(",,",nPos1);
          if( nPosNext < 0 )
             aParams = CreateUI.GetParamsList( sDlg.substring(nPos2) );
          else
             aParams = CreateUI.GetParamsList( sDlg.substring(nPos2,nPosNext) );

          iArr = 0;
          sText = "";
          while( aParams[iArr][0] != null ) {

             if( aParams[iArr][0].equals("t") ) {
                sText = aParams[iArr][1];
             } else if( aParams[iArr][0].equals("bcli") ) {
             }
             iArr ++;
          }

          nPos3 = sDlg.indexOf(":",nPos1);
          sName = sDlg.substring(nPos1,nPos3);
          sObjName = sDlg.substring(nPos3+1,nPos2);
          if( sName.equals("btn") ) {
             iBtns ++;
             switch( iBtns ) {
                case 1:
                   builder.setNegativeButton(sText,new BtnClickListener(sObjName));
                   break;
                case 2:
                   builder.setNeutralButton(sText,new BtnClickListener(sObjName));
                   break;
                case 3:
                   builder.setPositiveButton(sText,new BtnClickListener(sObjName));
                   break;
             }
          } else if( sName.equals("txt") ) {
             builder.setMessage(sText);
          }            
       } while( nPosNext > 0 );
    	
        AlertDialog alert = builder.create();
        alert.show();

    }

    private static class BtnClickListener implements DialogInterface.OnClickListener {
        String sBtnName;

        public BtnClickListener( String s ){
             super();
             sBtnName = s;
        }

        @Override
        public void onClick(DialogInterface dialog, int id) {
           dialog.cancel();
           //Log.i(TAG, "Dialog - click "+sBtnName);
           hbobj.hrbCall( "EVENT_BTNCLICK",sBtnName );
        }
    }

    static Handler tmHandler;
    static Runnable tmRunnable;
    static String [] aTimers = new String [12];
    static long [][] aTimeVal = new long [12][2];
    static int iTimers = 0;

    public static void timer( String sTimer ) {

       String sId;

       if( sTimer.substring(0,4).equals("set:") ) {
          int nPos = sTimer.indexOf( ":", 4 );
          sId = sTimer.substring( 4,nPos );

          aTimers[iTimers] = sId;
          aTimeVal[iTimers][0] = Integer.parseInt( sTimer.substring( nPos+1 ) );
          aTimeVal[iTimers][1] = System.currentTimeMillis();
          iTimers ++;

          if( tmHandler == null ) {
             tmHandler = new Handler();
             tmRunnable = new Runnable() {

                @Override
                public void run() {
                    long millis = System.currentTimeMillis();
                    long nVal = 100000;
                    int i;

                    for( i = 0; i < iTimers; i++ ) {
                       if( millis >= aTimeVal[i][1] ) {
                          aTimeVal[i][1] = millis + aTimeVal[i][0];
                          hbobj.hrbCall( "EVENT_TIMER",aTimers[i] );
                       }
                       if( nVal > aTimeVal[i][1] - millis )
                          nVal = aTimeVal[i][1] - millis;
                    }

                    tmHandler.postDelayed(this, nVal);
                }
             };
          }

          tmHandler.postDelayed(tmRunnable, 0);

       } else if( sTimer.substring(0,5).equals("kill:") ) {
          int i, j;
          sId = sTimer.substring( 5 );

          for( i = 0; i < iTimers; i++ ) {
             if( aTimers[i] == sId ) {
                for( j = i; j < iTimers-1; j++ ) {
                   aTimers[j] = aTimers[j+1];
                   aTimeVal[j][0] = aTimeVal[j+1][0];
                   aTimeVal[j][1] = aTimeVal[j+1][1];
                }
                break;
             }
          }

          iTimers--;
          if( iTimers == 0 )
             tmHandler.removeCallbacks(tmRunnable);
       }

    }

    public static void notify( String sNotify ) {

       Notification.Builder builder = new Notification.Builder(context);

       int notifyId, nDef = 0;
       int nPos = sNotify.indexOf( ",," ), nPos2;

       if( nPos > 0 ) {
          notifyId = Integer.parseInt( sNotify.substring( 0,nPos ) );
          //nPos2 = nPos + 2;
          //nPos = sNotify.indexOf( ",,",nPos2 );
          if( nPos > 0 && sNotify.substring( nPos+5,nPos+7 ).equals( ",," ) ) {
             if( sNotify.substring( nPos+2,nPos+3 ).equals( "y" ) )
                nDef |= Notification.DEFAULT_LIGHTS;
             if( sNotify.substring( nPos+3,nPos+4 ).equals( "y" ) )
                nDef |= Notification.DEFAULT_SOUND;
             if( sNotify.substring( nPos+4,nPos+5 ).equals( "y" ) )
                nDef |= Notification.DEFAULT_VIBRATE;
             builder.setDefaults( nDef );

             nPos2 = nPos + 7;
             nPos = sNotify.indexOf( ",,",nPos2 );
             if( nPos > 0 ) {
                builder.setContentTitle( sNotify.substring( nPos2,nPos ) );

                nPos2 = nPos + 2;
                nPos = sNotify.indexOf( ",,",nPos2 );
                if( nPos > 0 ) {
                   builder.setContentText( sNotify.substring( nPos2,nPos ) );

                   nPos2 = nPos + 2;
                   nPos = sNotify.indexOf( ",,",nPos2 );
                   if( nPos > 0 )
                      builder.setSubText( sNotify.substring( nPos2,nPos ) );
                }

                builder.setSmallIcon( android.R.drawable.arrow_down_float );
                NotificationManager notifMan = (NotificationManager) context.getSystemService(Context.NOTIFICATION_SERVICE);
                notifMan.notify( notifyId, builder.build() );
             }
          }
       }

    }


    public static String getSysDir( String type ) {
       if( type.equals( "doc" ) )
          return Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOCUMENTS) + "/";
       else if( type.equals( "pic" ) )
          return Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_PICTURES) + "/";
       else if( type.equals( "mus" ) )
          return Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_MUSIC) + "/";
       else if( type.equals( "mov" ) )
          return Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_MOVIES) + "/";
       else if( type.equals( "down" ) )
          return Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOWNLOADS) + "/";
       else if( type.equals( "ring" ) )
          return Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_RINGTONES ) + "/";
       else if( type.equals( "ext" ) )
          return Environment.getExternalStorageDirectory() + "/";
       else
          return "";
    }

    static {
        System.loadLibrary("harbour");
        System.loadLibrary("h4droid");
    }

}
