package su.harbour.hDroidGUI;

import android.content.Context;
import android.app.Activity;

import android.view.View;
import android.widget.LinearLayout;
import android.widget.ScrollView;
import android.widget.TextView;
import android.widget.Button;
import android.widget.EditText;
import android.view.KeyEvent;
import android.widget.CheckBox;
import android.widget.ListView;
import android.widget.HorizontalScrollView;

import android.widget.LinearLayout.LayoutParams;

import android.graphics.Color;
import android.graphics.Typeface;
import android.util.TypedValue;

import android.content.res.Resources;


public class CreateUI {

    private static String sPackage = null;
    private static Resources resources = null;

    public CreateUI( Context cont ) {

       sPackage = cont.getPackageName();
       resources = cont.getResources();

    }

    public View CreateActivity( Activity act, String sContent ) {

       View rootView;
       if( !sContent.substring(0,4).equals("act:") )
          return null;
       int nPos1 = sContent.indexOf(",,",4), nPosNext;

       //sActId = sContent.substring(4,nPos1);
       nPosNext = sContent.indexOf(",,/",5);
       String [][] aParams = GetParamsList( sContent.substring(nPos1,nPosNext) );
       int iArr = 0;
       while( aParams[iArr][0] != null ) {

          if( aParams[iArr][0].equals("t") ) {
             act.setTitle( getStr(aParams[iArr][1]) );
          }
          iArr ++;
       }

       sContent = sContent.substring(nPosNext+3);

       if( sContent.substring(0,4).equals("menu") ) {
          nPosNext = sContent.indexOf(",,/",5);
          Harbour.sMenu = sContent.substring(4,nPosNext);
          sContent = sContent.substring(nPosNext+3);
       }
       if( sContent.substring(0,3).equals("lay") )
          rootView = CreateGroupView(sContent);
       else
          rootView = CreateView(sContent);
            
       return rootView;
    }

    private View CreateGroupView( String sContent ) {

       int nPos = sContent.indexOf("[(");
       int nPos1 = sContent.indexOf(",,");
       String sObjName;

       LinearLayout ll = new LinearLayout(Harbour.context);

       //Log.i(TAG, "CreateG-1/"+sContent);
       if( nPos1 >= 0 && nPos1 < nPos ) {
          String [][] aParams = GetParamsList( sContent.substring(nPos1,nPos) );
          int iArr = 0;
          while( aParams[iArr][0] != null ) {

             //Log.i(TAG, "CreateG-2 "+aParams[iArr][0]+"/"+aParams[iArr][1]);
             if( aParams[iArr][0].equals("o") ) {
                if( aParams[iArr][1].equals("v") )
                   ll.setOrientation(LinearLayout.VERTICAL);
                else
                   ll.setOrientation(LinearLayout.HORIZONTAL);
             } else if( aParams[iArr][0].equals("cb") ) {
                ll.setBackgroundColor(parseColor(aParams[iArr][1]));
             }
             iArr ++;
          }
          SetSize( (View)ll, aParams );
          sObjName = sContent.substring(4,nPos1);

       }  else
          sObjName = sContent.substring(4,nPos);

       if( !sObjName.isEmpty() )
          ll.setTag( sObjName );
          
       // scan layout items
       sContent = sContent.substring(nPos+2);
       //Log.i(TAG, "CreateG-3/"+sContent);
       nPos1 = 0;
       View mView;
       int nPos2;
       int nLast = sContent.length() - 2;
       do {
          nPos2 = sContent.indexOf(")]",nPos1);
          //Log.i(TAG, "CreateG4a "+nPos+" "+nPos2+" "+nPos1+" "+nLast+" "+sContent.substring(nPos1));
          if( sContent.substring(nPos1,nPos1+3).equals("lay") ) {
             nPos = nPos1;
             int i1 = -1;
             int i2 = 1;
             while( true ) {
                while( nPos < nPos2 && nPos >= 0 ) {
                   i1 ++;
                   nPos = sContent.indexOf("[(",nPos+2);
                }
                if( i1 <= i2 )
                   break;
                else {
                   nPos2 = sContent.indexOf(")]",nPos2+2);
                   if( nPos2 < 0 )
                      return null;
                   i2 ++;
                }
             }
             nPos2 += 2;
             //Log.i(TAG, "CreateG4b "+nPos+" "+nPos2+" "+nPos1);
             mView = CreateGroupView(sContent.substring(nPos1,nPos2));
             if( sContent.substring(nPos2,nPos2+3).equals(",,/") )
                nPos2 +=3;
             nPos = nPos1 = nPos2;
          }
          else {
             nPos = sContent.indexOf(",,/",nPos1);
             if( nPos < 0 ) //|| nPos > nPos2 )
                nPos = nLast;
             mView = CreateView(sContent.substring(nPos1,nPos));
             nPos1 = nPos + 3;
          }
          if( mView == null )
             return null;

          ll.addView(mView);
          //Log.i(TAG, "CreateG5 "+(String)ll.getTag()+":"+(String)mView.getTag()+"/"+nPos+" "+nPos2+" "+nPos1);
       } while( nPos < nLast);
       
       return ll;
    }

    private View CreateView( String sContent ) {

       String sName;
       String sObjName = "";
       View mView;
       boolean bScroll = false;
       String [][] aParams = null;
       int iArr = 0;
       int nPos2 = sContent.indexOf(")]");
       int nPos = sContent.indexOf(",,/");

       //Log.i(TAG, "CreateT-1 "+sContent);
       if( nPos < 0 || nPos > nPos2 )
          nPos = nPos2;
       if( nPos >= 0 )
          sContent = sContent.substring(0,nPos);
       //Log.i(TAG, "CreateT-2/"+sContent);

       nPos = sContent.indexOf(",,");
       if( nPos < 0 )
          sName = sContent;
       else {
          aParams = GetParamsList( sContent.substring(nPos) );
          sName = sContent.substring(0,nPos);
       }
       nPos = sName.indexOf(":");
       if( nPos > 0 ) {
          sObjName = sName.substring(nPos+1);
          sName = sName.substring(0,nPos);
       }
       if( sName.equals("txt") ) {

          TextView mtextview = new TextView(Harbour.context);
          if( aParams != null )
             while( aParams[iArr][0] != null ) {

                if( aParams[iArr][0].equals("t") ) {
                   mtextview.setText(getStr(aParams[iArr][1]));
                } else if( aParams[iArr][0].equals("ct") ) {
                   mtextview.setTextColor(parseColor(aParams[iArr][1]));
                } else if( aParams[iArr][0].equals("cb") ) {
                   mtextview.setBackgroundColor(parseColor(aParams[iArr][1]));
                } else if( aParams[iArr][0].equals("f") ) {
                   setFont( mtextview, aParams[iArr][1] );
                } else if( aParams[iArr][0].equals("scroll") ) {
                   bScroll = true;
                }
                iArr ++;
             }
          mView = mtextview;

       } else if( sName.equals("btn") ) {

          Button mButton = new Button(Harbour.context);
          if( aParams != null )
             while( aParams[iArr][0] != null ) {

                if( aParams[iArr][0].equals("t") ) {
                   mButton.setText(getStr(aParams[iArr][1]));
                } else if( aParams[iArr][0].equals("ct") ) {
                   mButton.setTextColor(parseColor(aParams[iArr][1]));
                } else if( aParams[iArr][0].equals("cb") ) {
                   mButton.setBackgroundColor(parseColor(aParams[iArr][1]));
                } else if( aParams[iArr][0].equals("f") ) {
                   setFont( mButton, aParams[iArr][1] );
                } else if( aParams[iArr][0].equals("bcli") ) {
                   if( !sObjName.isEmpty() )
                      mButton.setOnClickListener(new View.OnClickListener() {
                         public void onClick(View v) {
                            String sRes = Harbour.hbobj.hrbCall( "EVENT_BTNCLICK",(String)v.getTag() );
                         }
                      });
                }
                iArr ++;
             }
          mView = mButton;

       } else if( sName.equals("edi") ) {

          EditText medit = new EditText(Harbour.context);
          if( aParams != null )
             while( aParams[iArr][0] != null ) {

                if( aParams[iArr][0].equals("t") ) {
                   medit.setText(getStr(aParams[iArr][1]));
                } else if( aParams[iArr][0].equals("ct") ) {
                   medit.setTextColor(parseColor(aParams[iArr][1]));
                } else if( aParams[iArr][0].equals("cb") ) {
                   medit.setBackgroundColor(parseColor(aParams[iArr][1]));
                } else if( aParams[iArr][0].equals("hint") ) {
                   medit.setHint(getStr(aParams[iArr][1]));
                } else if( aParams[iArr][0].equals("f") ) {
                   setFont( medit, aParams[iArr][1] );
                } else if( aParams[iArr][0].equals("bkey") ) {
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
          if( aParams != null )
             while( aParams[iArr][0] != null ) {

                if( aParams[iArr][0].equals("t") ) {
                   mche.setText(getStr(aParams[iArr][1]));
                } else if( aParams[iArr][0].equals("ct") ) {
                   mche.setTextColor(parseColor(aParams[iArr][1]));
                } else if( aParams[iArr][0].equals("cb") ) {
                   mche.setBackgroundColor(parseColor(aParams[iArr][1]));
                }
                iArr ++;
             }
          mView = mche;

       } else if( sName.equals("brw") ) {

          HorizontalScrollView hsv = new HorizontalScrollView(Harbour.context);
          LinearLayout ll = new LinearLayout(Harbour.context);
          ll.setOrientation(LinearLayout.HORIZONTAL);

          ListView mlv = new ListView(Harbour.context);
          mlv.setAdapter( new BrowseAdapter(Harbour.context, sObjName ) );

          hsv.addView( ll );
          ll.addView( mlv );
          mView = hsv;
          //mView = mlv;

       }  else
          return null;

       if( !sObjName.isEmpty() )
          mView.setTag( sObjName );


       if( bScroll ) {

          ScrollView sv = new ScrollView(Harbour.context);

          SetSize( sv, aParams );
          LinearLayout.LayoutParams parms = new LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,LinearLayout.LayoutParams.MATCH_PARENT);
          mView.setLayoutParams(parms);

          sv.addView(mView);
          return sv;

       } else {

          SetSize( mView, aParams );
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

    private static void SetSize( View mView, String [][] aParams ) {      

       if( aParams == null )
          return;

       int iArr = 0;
       int iHeight = -10, iWidth = -10;
       int iml = 0, imt = 0, imr = 0, imb = 0;
       int ipl = 0, ipt = 0, ipr = 0, ipb = 0;
       boolean bm = false, bp = false;

       while( aParams[iArr][0] != null ) {

          if( aParams[iArr][0].equals("h") ) {
             iHeight = Integer.parseInt(aParams[iArr][1]);
          } else if( aParams[iArr][0].equals("w") ) {
             iWidth = Integer.parseInt(aParams[iArr][1]);
          } else if( aParams[iArr][0].equals("ml") ) {
             iml = Integer.parseInt(aParams[iArr][1]);
             bm = true;
          } else if( aParams[iArr][0].equals("mt") ) {
             imt = Integer.parseInt(aParams[iArr][1]);
             bm = true;
          } else if( aParams[iArr][0].equals("mr") ) {
             imr = Integer.parseInt(aParams[iArr][1]);
             bm = true;
          } else if( aParams[iArr][0].equals("mb") ) {
             imb = Integer.parseInt(aParams[iArr][1]);
             bm = true;
          } else if( aParams[iArr][0].equals("pl") ) {
             ipl = Integer.parseInt(aParams[iArr][1]);
             bp = true;
          } else if( aParams[iArr][0].equals("pt") ) {
             ipt = Integer.parseInt(aParams[iArr][1]);
             bp = true;
          } else if( aParams[iArr][0].equals("pr") ) {
             ipr = Integer.parseInt(aParams[iArr][1]);
             bp = true;
          } else if( aParams[iArr][0].equals("pb") ) {
             ipb = Integer.parseInt(aParams[iArr][1]);
             bp = true;
          }
          iArr ++;
       }
       if( iHeight != -10 || iWidth != -10 || bm ) {
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
          if( bp )
             mView.setPadding( ipl, ipt, ipr, ipb );
       }

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

    public static String[][] GetParamsList( String sParam ) {
    
       String [][] aParams = new String [24][2];
       aParams[0][0] = null;

       int nPos;
       int nPos1;
       int iArr = 0;
       String sP;
       if( sParam.substring(0,2).equals(",,") )
          nPos1 = 2;
       else
          nPos1 = 0;
       //Log.i(TAG, "getp-0/"+sParam);
       do {
          nPos = sParam.indexOf(",,", nPos1);
          if( nPos < 0 )
             sP = sParam.substring(nPos1);
          else
             sP = sParam.substring(nPos1,nPos);

          //Log.i(TAG, "getp-1 "+nPos+" "+sP);
          nPos1 = sP.indexOf(":");
          if( nPos1 > 0 ) {
             aParams[iArr][1] = sP.substring(nPos1+1);
             aParams[iArr][0] = sP.substring(0,nPos1);
             iArr ++;
             aParams[iArr][0] = null;
          } else
             break;

          nPos1 = nPos + 2;

       } while( nPos > 0 );

       return aParams;
    }

}