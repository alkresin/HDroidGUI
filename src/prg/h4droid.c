/*
 * HDroidGUI - Harbour for Android GUI framework
 * 
 */

#include <string.h>
#include <jni.h>

#include "hbvm.h"
#include "hbstack.h"
#include "hbapi.h"
#include "hbapiitm.h"

static char * szHomePath = NULL;
static char * szHrb = NULL;

static JNIEnv* h_env;
static jobject h_thiz;

HB_FUNC( HD_HOMEDIR )
{
   hb_retc( szHomePath );
}

HB_FUNC( HD_CALLJAVA_S_V )
{

   const char * szFunc = (HB_ISCHAR(2))? hb_parc(2) : "jcb_sz_v";
   jclass cls = (*h_env)->GetObjectClass( h_env, h_thiz );

   jmethodID mid = (*h_env)->GetStaticMethodID( h_env, cls, szFunc, "(Ljava/lang/String;)V" );

   if( mid )
      (*h_env)->CallStaticVoidMethod( h_env, cls, mid, (*h_env)->NewStringUTF( h_env, hb_parc(1) ) );

}

HB_FUNC( HD_CALLJAVA_S_S )
{
   char * szRet;
   const char * szFunc = (HB_ISCHAR(2))? hb_parc(2) : "jcb_sz_sz";
   jstring jsRet;
   jclass cls = (*h_env)->GetObjectClass( h_env, h_thiz );

   jmethodID mid = (*h_env)->GetStaticMethodID( h_env, cls, szFunc, "(Ljava/lang/String;)Ljava/lang/String;" );

   if( mid ) {
      jsRet = (jstring)(*h_env)->CallStaticObjectMethod( h_env, cls, mid, (*h_env)->NewStringUTF( h_env, hb_parc(1) ) );
      szRet = (char*)(*h_env)->GetStringUTFChars( h_env, jsRet, NULL );
      hb_retc( szRet );
      (*h_env)->ReleaseStringUTFChars( h_env, jsRet, szRet );
   }
}

void Java_su_harbour_hDroidGUI_Harbour_vmInit( JNIEnv* env, jobject thiz )
{

    hb_vmInit( 0 );
}

void Java_su_harbour_hDroidGUI_Harbour_vmQuit( JNIEnv* env, jobject thiz )
{

    hb_vmQuit();
}

static char * sz_callhrb_sz( char * szName, char * szParam1 )
{
   PHB_DYNS pSym_onEvent = hb_dynsymFindName( szName );

   if( pSym_onEvent )
   {
      hb_vmPushSymbol( hb_dynsymSymbol( pSym_onEvent ) );
      hb_vmPushNil();
      hb_vmPushString( szParam1, strlen( szParam1 ) );
      hb_vmDo( 1 );
      return (char *) hb_parc(-1);
   }
   else
      return "";
}

static char * sz_callhrb_i( char * szName, int iParam1 )
{
   PHB_DYNS pSym_onEvent = hb_dynsymFindName( szName );

   if( pSym_onEvent )
   {
      hb_vmPushSymbol( hb_dynsymSymbol( pSym_onEvent ) );
      hb_vmPushNil();
      hb_vmPushInteger( iParam1 );
      hb_vmDo( 1 );
      return (char *) hb_parc(-1);
   }
   else
      return "";
}

void Java_su_harbour_hDroidGUI_Harbour_setHomePath( JNIEnv* env, jobject thiz, jstring js )
{
   szHomePath = (char *) (*env)->GetStringUTFChars( env, js, NULL );
}

void Java_su_harbour_hDroidGUI_Harbour_setHrb( JNIEnv* env, jobject thiz, jstring js )
{
   szHrb = (char *) (*env)->GetStringUTFChars( env, js, NULL );
}

jstring Java_su_harbour_hDroidGUI_Harbour_hrbOpen( JNIEnv* env, jobject thiz )
{
   h_env = env;
   h_thiz = thiz;

   if( szHrb )
      return (*env)->NewStringUTF( env, sz_callhrb_sz( "HD_HRBLOAD", szHrb ) );
   else
      return (*env)->NewStringUTF( env, "" );
}

jstring Java_su_harbour_hDroidGUI_Harbour_hrbCall( JNIEnv* env, jobject thiz, jstring jsModName, jstring jsParam )
{
   h_env = env;
   h_thiz = thiz;

   char * szModName = (char *) (*env)->GetStringUTFChars( env, jsModName, NULL );
   char * szParam = (jsParam)? (char *) (*env)->GetStringUTFChars( env, jsParam, NULL ) : "";
   char * szRet = (*env)->NewStringUTF( env, sz_callhrb_sz( szModName,szParam ) );

   (*env)->ReleaseStringUTFChars( env, jsModName, szModName );
   if( jsParam )
      (*env)->ReleaseStringUTFChars( env, jsParam, szParam );
   return szRet;
}
