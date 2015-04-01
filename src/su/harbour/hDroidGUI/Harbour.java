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
import android.widget.CheckBox;
import android.widget.ListView;
import android.widget.ImageView;
import android.widget.AdapterView;
import android.widget.BaseAdapter;

import android.app.AlertDialog;
import android.content.DialogInterface;
import android.app.ProgressDialog;

import java.util.Arrays;
import org.json.JSONArray;
import org.json.JSONException;
import android.text.method.PasswordTransformationMethod;

import android.util.Log;
import android.widget.Toast;

import android.app.Notification;
import android.app.NotificationManager;

import java.text.SimpleDateFormat;
import java.util.Date;
import android.provider.MediaStore;
import android.net.Uri;


public class Harbour {

    private static final String MAINHRB = "main.hrb";
    public static final int ACTION_TAKE_PHOTO = 1;

    private static boolean bHrb;
    private static View mainView = null;
    private static View prevView = null;
    public static Harbour hbobj;
    public static CreateUI createui;
    public static Activity context;
    public static Class dopClass = null;
    public static String cHomePath;
    public static float [] aScrSize = { 0,0,0,0,0,0,0 };

    public static JSONArray jaMenu = null;
    private static String sActivity = null;
    private static String sActions = null;

    private static ProgressDialog progress;

    public static String sTemp;

    public Harbour( Context cont ) {
       //context = cont;
       cHomePath = cont.getFilesDir() + "/";
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
       context = (Activity)cont;
       mainView = view;
       doActions();
    }

    public static View createAct( Context cont, String sAct ) {

       String sMain;
       context = (Activity)cont;

       DisplayMetrics dmetrics = new DisplayMetrics();
       ((Activity)cont).getWindowManager().getDefaultDisplay().getMetrics(dmetrics);
       aScrSize[0] = dmetrics.widthPixels;
       aScrSize[1] = dmetrics.heightPixels;
       aScrSize[2] = dmetrics.xdpi;
       aScrSize[3] = dmetrics.ydpi;
       aScrSize[4] = dmetrics.density;
       aScrSize[5] = dmetrics.densityDpi;
       aScrSize[6] = dmetrics.scaledDensity;

       jaMenu = null;
       if( bHrb )
          hbobj.hrbOpen( MAINHRB );

       if( sAct != null )
          sMain = sAct;
       else {
          hbobj.hrbCall( "HD_MAIN", bHrb? "1" : "2" );
          sMain = sActivity;
       }
       //hlog("hrbmain-1 "+sMain );
       if( sMain != null ) {
          prevView = mainView;
          mainView = createui.CreateActivity( (Activity)context, sMain);
       }
       else {
          mainView = null;
       }
       //hlog("hrbmain-2");
       
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
/*
    public static void SetMenu( Menu menu ) {

       if( jaMenu == null )
          return;

       int i, ilen = jaMenu.length();
       try {
          for( i = 1; i<ilen; i++ ) {

             menu.add( Menu.NONE, i, Menu.NONE, jaMenu.getString(i) );
          }
       }
       catch (JSONException e) {
          Harbour.hlog("jaMenu error");
          return;
       }
       jaMenu = null;
    }

    public static void onMenuSel( int id ) {
       hbobj.hrbCall( "EVENT_MENU", "/" + id );
    }
*/
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

    public static void doActions() {

       String message;
       String scmd;
       View view = null;
       int nPos1 = 0, nPos2, nPos, nPos3;

       if( sActions == null )
          return;

       do {
          nPos2 = sActions.indexOf( "///", nPos1 );
          if( nPos2 < 0 )
             message = sActions.substring( nPos1 );
          else
             message = sActions.substring( nPos1,nPos2 );

          nPos = message.indexOf(":");
          nPos3 = message.indexOf(":",nPos+1);
          scmd = message.substring( 0,nPos );
          view = mainView.findViewWithTag( message.substring( nPos+1,nPos3 ) );
          if( view != null ) {
             if( scmd.equals( "adachg" ) ) {
                   ((BrowseAdapter)((ListView)view).getAdapter()).notifyDataSetChanged();
             } else if( scmd.equals( "listrefr" ) ) {
                   ((ListView)view).invalidateViews();
             }
          }
          nPos1 += 3;
       } while( nPos2 > 0 );

       sActions = null;
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
       } else if( scmd.equals( "pdstart" ) ) {
          String sTitle = "", sMess = "";
          nPos1 = message.indexOf(":",nPos+1);
          if( nPos1 > 0 ) {
             sTitle = message.substring( nPos+1,nPos1 );
             nPos = nPos1 + 1;
             nPos1 = message.indexOf(":",nPos+1);
             if( nPos1 > 0 )
                sMess = message.substring( nPos,nPos1 );
          }
          progress = ProgressDialog.show( context, sTitle, sMess );
       } else if( scmd.equals( "pdend" ) ) {
          progress.dismiss();
       } else if( scmd.equals( "photo" ) ) {

          String sDir = "", sName = "";
          nPos1 = message.indexOf(":",nPos+1);
          if( nPos1 > 0 ) {
             sDir = message.substring( nPos+1,nPos1 );
             nPos = nPos1 + 1;
             nPos1 = message.indexOf(":",nPos+1);
             if( nPos1 > 0 )
                sName = message.substring( nPos,nPos1 );
          }
          File f = null;
          File fDir = sDir.isEmpty()? Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_PICTURES) : new File(sDir);
          if( sName.isEmpty() ) {
             sName = "img_" + new SimpleDateFormat("yyyyMMdd_HHmmss").format(new Date());
             try {
                f = File.createTempFile( sName, ".jpg", fDir );
             } catch (IOException e) {
                hlog("Err: "+message);
                return;
             }
          }
          else {
             f = new File( fDir, sName );
             try {
                f.createNewFile();
             } catch (IOException e) {
                hlog("Err: "+message);
                return;
             }
          }
          Intent intent = new Intent(MediaStore.ACTION_IMAGE_CAPTURE);
          intent.putExtra(MediaStore.EXTRA_OUTPUT, Uri.fromFile(f));
          sTemp = f.getAbsolutePath();
          context.startActivityForResult( intent, ACTION_TAKE_PHOTO );

       } else {

          nPos1 = message.indexOf(":",nPos+1);
          if( nPos1 > 0 ) {
             stag = message.substring( nPos+1,nPos1 );
             view = mainView.findViewWithTag( stag );
             if( view == null && prevView != null ) {
                view = prevView.findViewWithTag( stag );
                if( view != null ) {
                   if( sActions == null )
                      sActions = message;
                   else
                      sActions = sActions + "///" + message;
                   view = null;
                }
             }
          }

          if( view != null ) {
             if( scmd.equals( "settxt" ) ) {
                ((TextView)view).setText( CreateUI.getStr( message.substring( nPos1+1 ) ) );
             } else if( scmd.equals( "setval" ) ) {
                if( view instanceof CheckBox )
                   ((CheckBox)view).setChecked( message.substring( nPos1+1 ).equals("1") );
             } else if( scmd.equals( "setsels" ) ) {
                ((EditText)view).setSelection( Integer.parseInt( message.substring( nPos1+1 ) ) );
             } else if( scmd.equals( "setimg" ) ) {
                Uri uri = Uri.fromFile( new File( message.substring(nPos1+1) ) );
                if( uri != null )
                   ((ImageView)view).setImageURI( uri );
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

             return "" + aScrSize[0] + "/" + aScrSize[1] + "/" + aScrSize[2] + "/" + aScrSize[3] + aScrSize[4] + "/" + aScrSize[5] + "/" + aScrSize[6];
          } else {

             nPos1 = message.indexOf(":",nPos+1);
             if( nPos1 > 0 ) {
                stag = message.substring( nPos+1,nPos1 );
                tview = (TextView) mainView.findViewWithTag( stag );
             }

             if( tview != null ) {
                if( scmd.equals( "gettxt" ) ) {
                   return (String) tview.getText().toString();
                } else if( scmd.equals( "getval" ) ) {
                   if( tview instanceof CheckBox )
                      return ((CheckBox)tview).isChecked()? "1" : "0";
                } else if( scmd.equals( "getsels" ) ) {
                   return (String) "" + tview.getSelectionStart();
                } else if( scmd.equals( "getsele" ) ) {
                   return (String) "" + tview.getSelectionEnd();
                }
             }
          }
       }
       return "err";
    }

    public static void activ( String sAct ) {

       if( !sAct.substring(0,6).equals("[\"act:") )
          return;
       int nPos1 = sAct.indexOf("\"",6);
       String sId = sAct.substring(6,nPos1);
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

       int iBtns = 0;

       View [] aResults = new View [12];
       int iResults = 0;
       aResults[0] = null;

       //String sId = sDlg.substring(4,nPos3);

       AlertDialog.Builder builder = new AlertDialog.Builder(context);

       try {
          JSONArray jArray = new JSONArray(sDlg);
          int nPos, i, ilen = jArray.length();
          String sItem, sName, sObjName;
          String sText, sHint;
          boolean bPass;

          for( i = 0; i<ilen; i++ ) {
             if( jArray.get(i).getClass().getSimpleName().equals( "String" ) ) {

                sItem = jArray.getString(i);
                nPos = sItem.indexOf( ":" );
                sName = sItem.substring( 0,nPos );
                if( sName.equals("t") )
                   builder.setTitle(sItem.substring( nPos+1 ));

             } else {

                JSONArray jArr1 = jArray.getJSONArray(i), jArr2;
                int j, ilen1 = jArr1.length(), j2, ilen2;
                for( j = 0; j<ilen1; j++ ) {
                   jArr2 = jArr1.getJSONArray(j);
                   ilen2 = jArr2.length();

                   sText = "";
                   sHint = "";
                   bPass = false;

                   for( j2 = 1; j2<ilen2; j2++ ) {
                      sItem = jArr2.getString(j2);
                      nPos = sItem.indexOf( ":" );
                      sName = sItem.substring( 0,nPos );

                      if( sName.equals("t") ) {
                         sText = sItem.substring( nPos+1 );
                      } else if( sName.equals("hint") ) {
                         sHint = CreateUI.getStr(sItem.substring( nPos+1 ));
                      } else if( sName.equals("pass") ) {
                         bPass = true;
                      }

                   }

                   sItem = jArr2.getString(0);
                   nPos = sItem.indexOf( ":" );
                   sName = sItem.substring( 0,nPos );
                   sObjName = sItem.substring( nPos+1 );
                   if( sName.equals("btn") ) {
                      iBtns ++;
                      switch( iBtns ) {
                         case 1:
                            builder.setNegativeButton(sText,new BtnClickListener(sObjName,aResults));
                            break;
                         case 2:
                            builder.setNeutralButton(sText,new BtnClickListener(sObjName,aResults));
                            break;
                         case 3:
                            builder.setPositiveButton(sText,new BtnClickListener(sObjName,aResults));
                            break;
                      }
                   } else if( sName.equals("txt") ) {
                      builder.setMessage(sText);
                   } else if( sName.equals("edi") ) {
                      EditText ev = new EditText(context);
                      if( !sHint.isEmpty() )
                         ev.setHint( sHint );
                      if( bPass )
                         ev.setTransformationMethod(new PasswordTransformationMethod());
                      aResults[iResults] = ev;
                      builder.setView( ev );
                      iResults ++;
                      aResults[iResults] = null;
                   }
                }
             }
          }
       }
       catch (JSONException e) {
          hlog("dialog: json error");
          return;
       }
       if( iBtns > 0 )
          builder.setCancelable(false);
    	
        AlertDialog alert = builder.create();
        alert.show();

    }

    private static class BtnClickListener implements DialogInterface.OnClickListener {
        String sBtnName;
        View [] aViews;

        public BtnClickListener( String s, View [] av ){
             super();
             sBtnName = s;
             aViews = av;
        }

        @Override
        public void onClick(DialogInterface dialog, int id) {
           String s = "";
           int iArr = 0;

           while ( aViews[iArr] != null )
              iArr ++;
           if( iArr > 0 ) {
              String [] aRes = new String [iArr];
              iArr = 0;
              while ( aViews[iArr] != null ) {
                 //hlog( ( aViews[iArr] instanceof EditText )? "yes" : "no" );
                 aRes[iArr] = ((EditText)aViews[iArr]).getText().toString();
                 iArr ++;
              }
              JSONArray jsonArr = new JSONArray(Arrays.asList(aRes));
              s = jsonArr.toString();
           }
           dialog.cancel();
           hbobj.hrbCall( "EVENT_BTNCLICK", sBtnName + s );
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
