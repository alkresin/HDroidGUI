package su.harbour.hDroidGUI;

import android.content.Context;
import android.app.Activity;
import android.app.ActionBar;

import android.view.View;
import android.view.ViewGroup;
import android.widget.LinearLayout;
import android.widget.ScrollView;
import android.widget.TextView;
import android.widget.Button;
import android.widget.EditText;
import android.view.KeyEvent;
import android.widget.CheckBox;
import android.widget.ListView;
import android.widget.HorizontalScrollView;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.text.method.PasswordTransformationMethod;

import android.webkit.WebView;
import android.webkit.WebSettings;
import android.webkit.WebViewClient;
import android.webkit.JavascriptInterface;

import android.widget.LinearLayout.LayoutParams;
import android.view.Gravity;

import android.graphics.drawable.Drawable;
import android.graphics.drawable.GradientDrawable;
import android.graphics.drawable.StateListDrawable;
import android.content.res.ColorStateList;

import android.graphics.Color;
import android.graphics.Typeface;
import android.util.TypedValue;

import android.content.res.Resources;

import org.json.JSONArray;
import org.json.JSONException;


public class CreateUI {

    static final int LAYOUT  = 1;
    static final int TEXT = 2;
    static final int TEXTINSCROLL = 3;

    private static String sPackage = null;
    private static Resources resources = null;

    public CreateUI( Context cont ) {

       sPackage = cont.getPackageName();
       resources = cont.getResources();

    }

    public View CreateActivity( Activity act, String sContent ) {

       View rootView = null;
       if( !sContent.substring(0,6).equals("[\"act:") )
          return null;

       JSONArray jArray = null;
       try {
          jArray = new JSONArray(sContent);
       }
       catch (JSONException e) {
          Harbour.hlog("jArray error");
          return null;
       }

       int nPos, i, ilen = jArray.length();
       String sItem, sName;
       ActionBar bar = act.getActionBar();

       if( bar != null )
          bar.setIcon(android.R.color.transparent);
       try {
          for( i = 0; i<ilen; i++ ) {
             if( jArray.get(i).getClass().getSimpleName().equals( "String" ) ) {

                sItem = jArray.getString(i);
                nPos = sItem.indexOf( ":" );
                sName = sItem.substring( 0,nPos );
                if( sName.equals("t") )
                   act.setTitle( getStr(sItem.substring(nPos+1)) );
                else if( sName.equals("stlh") ) {
                   if( bar != null ) {
                      UIStyle style = UIStyle.find( sItem.substring(nPos+1), true );
                      if( style != null )
                         bar.setBackgroundDrawable( style.getDrawable() );
                      //Harbour.hlog( "ActionBar1:"+((act.getActionBar()==null)? "null" : "Ok") );
                   }
                }

             } else {               
                JSONArray jArr1 = jArray.getJSONArray(i);
                int j, ilen1 = jArr1.length();
                sItem = jArr1.getString(0);
                if( sItem.equals( "menu" ) ) {
                   Harbour.jaMenu = jArr1;
                } else if( sItem.substring(0,3).equals("lay") )
                   rootView = CreateGroupView(jArr1);
                else
                   rootView = CreateView(jArr1);
             }
          }
       }   
       catch (JSONException e) {
          Harbour.hlog("jArray.get error");
          return null;
       }
       return rootView;
    }

    private View CreateGroupView( JSONArray jArray ) throws JSONException {

       int nPos, i, ilen = jArray.length();
       String sItem, sName, sObjName;

       String [][] aParams = new String [24][2];
       aParams[0][0] = null;
       int iArr = 0;

       View mView;
       LinearLayout ll = new LinearLayout(Harbour.context);

       sItem = jArray.getString(0);
       nPos = sItem.indexOf( ":" );
       sObjName = sItem.substring( nPos+1 );

       //Harbour.hlog( "CreateG-1/"+jArray.toString());
       for( i = 1; i<ilen; i++ ) {
          if( jArray.get(i).getClass().getSimpleName().equals( "String" ) ) {

             sItem = jArray.getString(i);
             nPos = sItem.indexOf( ":" );
             aParams[iArr][1] = sItem.substring(nPos+1);
             aParams[iArr][0] = sItem.substring( 0,nPos );
             iArr ++;
             aParams[iArr][0] = null;

          } else
             break;
       }
       if( iArr > 0 ) {
          iArr = 0;
          while( aParams[iArr][0] != null ) {

             if( aParams[iArr][0].equals("o") ) {
                if( aParams[iArr][1].equals("v") )
                   ll.setOrientation(LinearLayout.VERTICAL);
                else
                   ll.setOrientation(LinearLayout.HORIZONTAL);
             }
             iArr ++;
          }
          SetSize( (View)ll, aParams, LAYOUT );
       }

       JSONArray jArr1 = jArray.getJSONArray(i), jArr2;
       int j, ilen1 = jArr1.length();
       for( j = 0; j<ilen1; j++ ) {

          jArr2 = jArr1.getJSONArray(j);
          sItem = jArr2.getString(0);
          if( sItem.substring(0,3).equals("lay") )
             mView = CreateGroupView( jArr2 );
          else
             mView = CreateView( jArr2 );
          if( mView == null )
             return null;
          ll.addView(mView);
       }

       if( !sObjName.isEmpty() )
          ll.setTag( sObjName );        
       
       return ll;
    }

    private View CreateView( JSONArray jArray ) throws JSONException {

       int nPos, i, ilen = jArray.length();
       String sItem, sName, sObjName;

       View mView;

       boolean bVScroll = false;
       String [][] aParams = new String [24][2];
       aParams[0][0] = null;
       int iArr = 0;

       String scmd;

       //Harbour.hlog( "CreateV-1/"+jArray.toString());
       sItem = jArray.getString(0);
       nPos = sItem.indexOf( ":" );
       sName = sItem.substring( 0,nPos );
       sObjName = sItem.substring( nPos+1 );

       for( i = 1; i<ilen; i++ ) {

          sItem = jArray.getString(i);
          nPos = sItem.indexOf( ":" );
          aParams[iArr][1] = sItem.substring(nPos+1);
          aParams[iArr][0] = sItem.substring( 0,nPos );
          iArr ++;
          aParams[iArr][0] = null;

       }

       iArr = 0;
       if( sName.equals("txt") ) {

          TextView mtextview = new TextView(Harbour.context);
          while( aParams[iArr][0] != null ) {
             scmd = aParams[iArr][0];
             if( scmd.equals("t") ) {
                mtextview.setText(getStr(aParams[iArr][1]));
             } else if( scmd.equals("ct") ) {
                mtextview.setTextColor(parseColor(aParams[iArr][1]));
             } else if( scmd.equals("f") ) {
                setFont( mtextview, aParams[iArr][1] );
             } else if( scmd.equals("vscroll") ) {
                bVScroll = true;
             } else if( scmd.equals("hscroll") ) {
                mtextview.setHorizontallyScrolling(true);
             }
             iArr ++;
          }
          mView = mtextview;

       } else if( sName.equals("btn") ) {

          Button mButton = new Button(Harbour.context);
          while( aParams[iArr][0] != null ) {
             scmd = aParams[iArr][0];
             if( scmd.equals("t") ) {
                mButton.setText(getStr(aParams[iArr][1]));
             } else if( scmd.equals("ct") ) {
                mButton.setTextColor(parseColor(aParams[iArr][1]));
             } else if( scmd.equals("f") ) {
                setFont( mButton, aParams[iArr][1] );
             } else if( scmd.equals("bcli") ) {
                if( !sObjName.isEmpty() )
                   mButton.setOnClickListener(new View.OnClickListener() {
                      public void onClick(View v) {
                         Harbour.hbobj.hrbCall( "EVENT_BTNCLICK",(String)v.getTag() );
                      }
                   });
             }
             iArr ++;
          }
          mView = mButton;

       } else if( sName.equals("edi") ) {

          EditText medit = new EditText(Harbour.context);
          while( aParams[iArr][0] != null ) {
             scmd = aParams[iArr][0];
             if( scmd.equals("t") ) {
                medit.setText(getStr(aParams[iArr][1]));
             } else if( scmd.equals("ct") ) {
                medit.setTextColor(parseColor(aParams[iArr][1]));
             } else if( scmd.equals("hint") ) {
                medit.setHint(getStr(aParams[iArr][1]));
             } else if( scmd.equals("pass") ) {
                medit.setTransformationMethod(new PasswordTransformationMethod());
             } else if( scmd.equals("f") ) {
                setFont( medit, aParams[iArr][1] );
             } else if( scmd.equals("bkey") ) {
                if( !sObjName.isEmpty() ) {
                   medit.setOnKeyListener(new View.OnKeyListener() {
                      public boolean onKey(View v, int keyCode, KeyEvent event) {
                         if (event.getAction() == KeyEvent.ACTION_DOWN) {
                            String sRes = Harbour.hbobj.hrbCall( "EVENT_KEYDOWN",(String)v.getTag()+":"+keyCode );
                            return sRes.equals( "1" )? true : false;
                         }
                         return false;
                      }
                   });
                }
             }
             iArr ++;
          }
          mView = medit;

       } else if( sName.equals("che") ) {

          CheckBox mche = new CheckBox(Harbour.context);
          while( aParams[iArr][0] != null ) {
             scmd = aParams[iArr][0];
             if( scmd.equals("t") ) {
                mche.setText(getStr(aParams[iArr][1]));
             } else if( scmd.equals("v") ) {
                mche.setChecked( true );
             } else if( scmd.equals("ct") ) {
                mche.setTextColor(parseColor(aParams[iArr][1]));
             }
             iArr ++;
          }
          mView = mche;

       } else if( sName.equals("web") ) {

          WebView web = new WebView(Harbour.context);
          boolean bZoom = false, bJS = false;

          web.setWebViewClient( new MyWebViewClient() );

          while( aParams[iArr][0] != null ) {
             scmd = aParams[iArr][0];
             if( scmd.equals("t") )
                web.loadDataWithBaseURL(null, aParams[iArr][1], "text/html", "utf-8", null);
             else if( scmd.equals("zoom") )
                bZoom = true;
             else if( scmd.equals("js") )
                bJS = true;
             iArr ++;
          }
          WebSettings settings = web.getSettings();
          settings.setBuiltInZoomControls( bZoom );
          settings.setJavaScriptEnabled( bJS );

          mView = web;

       } else if( sName.equals("brw") ) {

          boolean bHScroll = false;
          boolean bHead = false, bFoot = false;
          LinearLayout llv = null;
          JSONArray jaRow = null, jaCol = null, ja;
          int ihdh = -10, ihdcb = -10, ihdct = -10;
          int ifth = -10, iftcb = -10, iftct = -10;
          int j, iCols = 0, ilen1, iBWidth = 0;
          int [] aColumns = null;
          String [] aColHead = null;
          String [] aColFoot = null;

          ListView mlv = new ListView(Harbour.context);

          while( aParams[iArr][0] != null ) {
             scmd = aParams[iArr][0];
             if( scmd.equals("hscroll") ) {
                bHScroll = true;
             } else if( scmd.equals("row") ) {
                jaRow = new JSONArray(aParams[iArr][1]);
             } else if( scmd.equals("col") ) {
                jaCol = new JSONArray(aParams[iArr][1]);
                iCols = jaCol.length();
                aColumns = new int [iCols];
                aColHead = new String [iCols];
                aColFoot = new String [iCols];
                for( i = 0; i<iCols; i++ ) {
                   ja = jaCol.getJSONArray(i);
                   ilen1 = ja.length();
                   for( j = 0; j<ilen1; j++ ) {
                      sItem = ja.getString(j);
                      nPos = sItem.indexOf( ":" );
                      sName = sItem.substring( 0,nPos );
                      if( sName.equals("w") ) {
                         aColumns[i] = Integer.parseInt( sItem.substring( nPos+1 ) );
                         if( aColumns[i] == 0 )
                            iBWidth = -999999;
                         else
                            iBWidth += aColumns[i];
                      } else if( sName.equals("hd") ) {
                         aColHead[i] = sItem.substring( nPos+1 );
                         bHead = true;
                      } else if( sName.equals("ft") ) {
                         aColFoot[i] = sItem.substring( nPos+1 );
                         bFoot = true;
                      }
                   }
                }
             } else if( scmd.equals("hdh") ) {
                ihdh = Integer.parseInt(aParams[iArr][1]);
                bHead = true;
             } else if( scmd.equals("hdcb") ) {
                ihdcb = parseColor(aParams[iArr][1]);
                bHead = true;
             } else if( scmd.equals("hdct") ) {
                ihdct = parseColor(aParams[iArr][1]);
                bHead = true;
             } else if( scmd.equals("fth") ) {
                ifth = Integer.parseInt(aParams[iArr][1]);
                bFoot = true;
             } else if( scmd.equals("ftcb") ) {
                iftcb = parseColor(aParams[iArr][1]);
                bFoot = true;
             } else if( scmd.equals("ftct") ) {
                iftct = parseColor(aParams[iArr][1]);
                bFoot = true;
             } else if( scmd.equals("bcli") ) {
                if( !sObjName.isEmpty() )
                   mlv.setOnItemClickListener(new OnItemClickListener() {
                         public void onItemClick(AdapterView<?> p, View v,
                             int pos, long id) {
                            Harbour.hbobj.hrbCall( "CB_BROWSE","cli:"+(String)p.getTag()+":"+pos );
                         }
                       });
             }
             iArr ++;
          }
          if( bHead || bFoot ) {
             llv = new LinearLayout(Harbour.context);
             llv.setOrientation(LinearLayout.VERTICAL);
             LinearLayout llh = null, llf = null;
             LinearLayout.LayoutParams prms;
             if( bHead ) {
                llh = new LinearLayout(Harbour.context);
                llh.setOrientation(LinearLayout.HORIZONTAL);
                llv.addView( llh );
                prms = new LinearLayout.LayoutParams(
                   (iBWidth<=0)? LinearLayout.LayoutParams.MATCH_PARENT : iBWidth,
                   (ihdh==-10)? LinearLayout.LayoutParams.WRAP_CONTENT : ihdh );
                llh.setLayoutParams(prms);
             }
             prms = new LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT, 0, 1 );
             mlv.setLayoutParams(prms);
             llv.addView( mlv );
             if( bFoot ) {
                llf = new LinearLayout(Harbour.context);
                llf.setOrientation(LinearLayout.HORIZONTAL);
                llv.addView( llf );
                prms = new LinearLayout.LayoutParams(
                   (iBWidth<=0)? LinearLayout.LayoutParams.MATCH_PARENT : iBWidth,
                   (ifth==-10)? LinearLayout.LayoutParams.WRAP_CONTENT : ifth );
                llf.setLayoutParams(prms);
             }
             for( i = 0; i<iCols; i++ ) {
                if( bHead ) {
                   TextView tv = new TextView(Harbour.context);
                   if( ihdcb != -10 ) {
                      tv.setBackgroundColor(ihdcb);
                   }
                   if( ihdct != -10 )
                      tv.setTextColor(ihdct);
                   prms = new LinearLayout.LayoutParams(
                      (aColumns[i]>0)? aColumns[i]-2 : LinearLayout.LayoutParams.MATCH_PARENT,
                      LinearLayout.LayoutParams.MATCH_PARENT );
                   prms.setMargins( 0, 0, 2, 0 );
                   tv.setLayoutParams(prms);
                   tv.setPadding( 2, 2, 2, 2 );
                   tv.setText( aColHead[i] );
                   llh.addView( tv );
                }
                if( bFoot ) {
                   TextView tv = new TextView(Harbour.context);
                   if( iftcb != -10 ) {
                      tv.setBackgroundColor(iftcb);
                   }
                   if( iftct != -10 )
                      tv.setTextColor(iftct);
                   prms = new LinearLayout.LayoutParams(
                      (aColumns[i]>0)? aColumns[i]-2 : LinearLayout.LayoutParams.MATCH_PARENT,
                      LinearLayout.LayoutParams.MATCH_PARENT );
                   prms.setMargins( 0, 0, 2, 0 );
                   tv.setLayoutParams(prms);
                   tv.setPadding( 2, 2, 2, 2 );
                   tv.setText( aColFoot[i] );
                   llf.addView( tv );
                }
             }
          }

          mlv.setAdapter( new BrowseAdapter(Harbour.context, sObjName, jaRow, jaCol ) );
          mlv.setTag( sObjName );
          sObjName = "";

          if( bHScroll ) {
             HorizontalScrollView hsv = new HorizontalScrollView(Harbour.context);
             LinearLayout ll = new LinearLayout(Harbour.context);
             ll.setOrientation(LinearLayout.HORIZONTAL);

             hsv.addView( ll );
             ll.addView( (bHead||bFoot)? llv : mlv );
             mView = hsv;
          } else
             mView = ((bHead||bFoot)? llv : mlv);

       }  else
          return null;

       if( !sObjName.isEmpty() )
          mView.setTag( sObjName );

       if( bVScroll ) {

          ScrollView sv = new ScrollView(Harbour.context);

          LinearLayout.LayoutParams parms = new LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,LinearLayout.LayoutParams.MATCH_PARENT);
          mView.setLayoutParams(parms);

          sv.addView(mView);

          SetSize( sv, aParams, TEXTINSCROLL );
          return sv;

       } else {

          SetSize( mView, aParams, TEXT );
          return mView;
       }
    }

    private static void setFont( TextView mView, String sFont ) {
       
       int nface = Integer.parseInt( sFont.substring(0,1) );
       int nstyle = Integer.parseInt( sFont.substring(2,3) );
       int nsize = Integer.parseInt( sFont.substring(4) );

       if( nface != 0 || nstyle != 0 ) {
          Typeface tface = null;
          switch( nface ) {
              case 0: 
                 tface = Typeface.DEFAULT;
                 break;
              case 1: 
                 tface = Typeface.SANS_SERIF;
                 break;
              case 2: 
                 tface = Typeface.SERIF;
                 break;
              case 3: 
                 tface = Typeface.MONOSPACE;
                 break;
          }
          mView.setTypeface( tface, nstyle );          
       }
       if( nsize != 0 )
           mView.setTextSize( TypedValue.COMPLEX_UNIT_DIP,nsize );
    }

    private static void SetSize( View mView, String [][] aParams, int ivType ) throws JSONException {

       if( aParams == null )
          return;

       int iArr = 0;
       int iHeight = -10, iWidth = -10;
       int iml = 0, imt = 0, imr = 0, imb = 0;
       int ipl = 0, ipt = 0, ipr = 0, ipb = 0;
       int iAlign = 0;
       boolean bm = false, bp = false;
       String sStyle = null;
       String scmd;

       while( aParams[iArr][0] != null ) {
          scmd = aParams[iArr][0];
          if( scmd.equals("h") ) {
             iHeight = Integer.parseInt(aParams[iArr][1]);
          } else if( scmd.equals("w") ) {
             iWidth = Integer.parseInt(aParams[iArr][1]);
          } else if( scmd.equals("ali") ) {
             iAlign = Integer.parseInt(aParams[iArr][1]);
          } else if( scmd.equals("ml") ) {
             iml = Integer.parseInt(aParams[iArr][1]);
             bm = true;
          } else if( scmd.equals("mt") ) {
             imt = Integer.parseInt(aParams[iArr][1]);
             bm = true;
          } else if( scmd.equals("mr") ) {
             imr = Integer.parseInt(aParams[iArr][1]);
             bm = true;
          } else if( scmd.equals("mb") ) {
             imb = Integer.parseInt(aParams[iArr][1]);
             bm = true;
          } else if( scmd.equals("pl") ) {
             ipl = Integer.parseInt(aParams[iArr][1]);
             bp = true;
          } else if( scmd.equals("pt") ) {
             ipt = Integer.parseInt(aParams[iArr][1]);
             bp = true;
          } else if( scmd.equals("pr") ) {
             ipr = Integer.parseInt(aParams[iArr][1]);
             bp = true;
          } else if( scmd.equals("pb") ) {
             ipb = Integer.parseInt(aParams[iArr][1]);
             bp = true;
          } else if( scmd.equals("cb") ) {
             mView.setBackgroundColor(parseColor(aParams[iArr][1]));
          } else if( scmd.equals("stl") ) {
             sStyle = aParams[iArr][1];
          }
          iArr ++;
       }
       if( iHeight != -10 || iWidth != -10 || bm || iAlign != 0 ) {
          LinearLayout.LayoutParams parms;
          if( iHeight == -10 )
             iHeight = LinearLayout.LayoutParams.MATCH_PARENT;
          if( iWidth == -10 )
             iWidth = LinearLayout.LayoutParams.MATCH_PARENT;
          if( iHeight == 0 || iWidth == 0 )
             parms = new LinearLayout.LayoutParams(iWidth,iHeight,1);
          else
             parms = new LinearLayout.LayoutParams(iWidth,iHeight);
          if( bm )
             parms.setMargins( iml, imt, imr, imb );
          mView.setLayoutParams(parms);
       }
       if( bp )
          mView.setPadding( ipl, ipt, ipr, ipb );
       if( iAlign != 0 ) {
          int gravity = ( ( (iAlign & 1)>0 )? Gravity.CENTER_HORIZONTAL : 0 ) |
                ( ( (iAlign & 2)>0 )? Gravity.RIGHT : 0 ) |
                ( ( (iAlign & 4)>0 )? Gravity.CENTER_VERTICAL : 0 ) |
                ( ( (iAlign & 8)>0 )? Gravity.BOTTOM : 0 );
          try {
             if( ivType == TEXT )
                ((TextView)mView).setGravity( gravity );
             else if( ivType == TEXTINSCROLL )
                ((TextView) ((ViewGroup)mView).getChildAt(0)).setGravity( gravity );
             else if( ivType == LAYOUT )
                ((LinearLayout)mView).setGravity( gravity );
          }
          catch (Exception e) {
          }
       }
       if( sStyle != null )
          UIStyle.setDrawable( mView, sStyle );
    }

    private static int parseColor( String sColor ) {

       int iColor;

       try {
          iColor = Color.parseColor( sColor );

       } catch (IllegalArgumentException e) {
          iColor = 0;
       }

       return iColor;
    }

    public static String getStr( String sRes ) {
       if( sRes.length() > 2 && sRes.substring( 0,2 ).equals( "$$" ) ) {
          int id = resID( sRes.substring( 2 ), "string" );
          if( id == 0 )
             return "";
          else
             return Harbour.context.getString( id );
       }
       else
          return sRes;
    }

    private static int resID( String sRes, String sType ) {

       int id = 0;

       try {
          id = resources.getIdentifier( sRes, sType, sPackage );
       }
       catch (Exception e) {
          id = 0;
       }
       
       return id;
    }

    private static class UIStyle {

       private static final GradientDrawable.Orientation [] aOrient = { GradientDrawable.Orientation.BL_TR,
         GradientDrawable.Orientation.BOTTOM_TOP, GradientDrawable.Orientation.BR_TL,
         GradientDrawable.Orientation.LEFT_RIGHT, GradientDrawable.Orientation.RIGHT_LEFT,
         GradientDrawable.Orientation.TL_BR , GradientDrawable.Orientation.TOP_BOTTOM,
         GradientDrawable.Orientation.TR_BL };
       static UIStyle [] aStyles = new UIStyle[24];
       static int iStyles = 0;
       static int [] [] aStates =  { {android.R.attr.state_pressed},
                     {android.R.attr.state_focused},
                     {} };

       String id;
       GradientDrawable.Orientation orient;
       int [] aColors;
       float [] aCorners;
       int tColor;


       public UIStyle( String cid ) {

          id = cid;
          aStyles[iStyles] = this;
          iStyles ++;
       }

       public UIStyle( String cid, String sStyle ) throws JSONException {

          this( cid );

          JSONArray jArray = new JSONArray(sStyle);
          int i = jArray.getInt(0);
          orient = ( i<8 )? aOrient[i] : aOrient[1];

          JSONArray jArr1 = jArray.getJSONArray(1);
          int ilen = jArr1.length();

          aColors = (ilen>0)? new int[ilen] : null;
          for( i=0; i<ilen; i++ )
             aColors[i] = parseColor(jArr1.getString(i));

          jArr1 = jArray.getJSONArray(2);
          ilen = jArr1.length();

          if( ilen>0 ) {
             int iCorners = (ilen==1)? 1:8;
             aCorners = new float[iCorners];
             for( i=0; i<iCorners; i++ )
                aCorners[i] = (i<ilen)? (float)Integer.parseInt(jArr1.getString(i)) : 0;
          }
          else
             aCorners = null;
          String scolor = jArray.getString(3);
          tColor = scolor.isEmpty()? -10 : parseColor(scolor);

       }

       public static UIStyle find( String cid, boolean bNew ) throws JSONException {

          int i;
          UIStyle style = null;

          for( i=0; i < iStyles; i++ )
             if( aStyles[i].id.equals( cid ) ) {
                style = aStyles[i];
                break;
             }
          if( style == null && bNew ) {
             String sStyle = Harbour.hbobj.hrbCall( "CB_STYLE",cid );
             if( !sStyle.isEmpty() ) {                  
                style = new UIStyle( cid, sStyle );
             }
          }

          return style;
       }

       public static void setDrawable( View mView, String sStyle ) throws JSONException {

          UIStyle style1 = null, style2 = null, style3 = null;
          int tColor1 = -10, tColor2 = -10, tColor3 = -10;
          if( mView == null )
             return;

          int nPos = sStyle.indexOf( "," );
          if( nPos > 0 ) {
            style1 = find( sStyle.substring(0,nPos), true );
            int nPos1 = sStyle.indexOf( ",",nPos+1 );
            if( nPos1 < 0 ) {
               style2 = find( sStyle.substring(nPos+1), true );
            } else {
               if( nPos1 > nPos+1 )
                  style2 = find( sStyle.substring(nPos+1,nPos1), true );
               style3 = find( sStyle.substring(nPos1+1), true );
            }
            StateListDrawable states = new StateListDrawable();
            if( style1 != null && style1.tColor != -10 )
               tColor1 = tColor2 = tColor3 = style1.tColor;

            if( style3 != null ) {
               states.addState(new int[] {android.R.attr.state_pressed}, style3.getDrawable());
               if( style3.tColor != -10 )
                  tColor3 = style3.tColor;
            }
            if( style2 != null ) {
               states.addState(new int[] {android.R.attr.state_focused}, style2.getDrawable());
               if( style2.tColor != -10 )
                  tColor2 = style2.tColor;
            }
            if( style1 != null )
               states.addState(new int[] {}, style1.getDrawable());
            mView.setBackground( states );

            if( tColor1 != -10 )
               ((TextView)mView).setTextColor (new ColorStateList ( aStates,
                      new int [] { tColor3, tColor2, tColor1 } ));
          } else {
            style1 = find( sStyle, true );
            if( style1 != null ) {
                mView.setBackground( style1.getDrawable() );
                if( style1.tColor != -10 )
                   ((TextView)mView).setTextColor( style1.tColor );
            }
          }
       }

       public GradientDrawable getDrawable() {

          GradientDrawable g;
          if( aColors.length == 1 ) {
             g = new GradientDrawable();
             g.setColor( aColors[0] );
          }
          else
             g = new GradientDrawable(this.orient, this.aColors);
          if( aCorners != null ) {
             if( aCorners.length == 1 )
                g.setCornerRadius( aCorners[0] );
             else
                g.setCornerRadii( aCorners );
          }

          return g;
       }

    }

    private class MyWebViewClient extends WebViewClient {
        @Override
        public boolean shouldOverrideUrlLoading(WebView webView, String url) {
            return false;
        }
    }

}