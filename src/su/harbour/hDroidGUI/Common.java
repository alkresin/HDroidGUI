package su.harbour.hDroidGUI;

import android.app.Activity;
import android.view.Surface;
import android.os.Build;
import android.graphics.Point;
import android.content.pm.ActivityInfo;
import android.view.Display;

import android.widget.ImageView;

import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Matrix;

public class Common {

    public static Bitmap imageRotate( Bitmap bitmap, int angle ) {

       Matrix mat = new Matrix();
       mat.postRotate(angle);

       return Bitmap.createBitmap( bitmap, 0, 0, bitmap.getWidth(), 
             bitmap.getHeight(), mat, true );

    }

    public static void setImage( ImageView iv, String sPath ) {

       int targetW = iv.getWidth();
       int targetH = iv.getHeight();

       BitmapFactory.Options bmOptions = new BitmapFactory.Options();
       bmOptions.inJustDecodeBounds = true;
       BitmapFactory.decodeFile( sPath, bmOptions );
       int photoW = bmOptions.outWidth;
       int photoH = bmOptions.outHeight;

       /* Figure out which way needs to be reduced less */
       int scaleFactor = 1;
       if ((targetW > 0) || (targetH > 0)) {
          scaleFactor = Math.min(photoW/targetW, photoH/targetH);
       }

       /* Set bitmap options to scale the image decode target */
       bmOptions.inJustDecodeBounds = false;
       bmOptions.inSampleSize = scaleFactor;
       bmOptions.inPurgeable = true;

       /* Decode the JPEG file into a Bitmap */
       Bitmap bitmap = BitmapFactory.decodeFile( sPath, bmOptions );

       if( (photoW > photoH) != (targetW > targetH) )
          iv.setImageBitmap( imageRotate(bitmap,90) );
       else
          iv.setImageBitmap( bitmap );
    }

   @SuppressWarnings("deprecation")
   public static void lockOrientation() {
       Activity activity = Harbour.context;
       Display display = activity.getWindowManager().getDefaultDisplay();
       int rotation = display.getRotation();
       int height;
       int width;
       if (Build.VERSION.SDK_INT < Build.VERSION_CODES.HONEYCOMB_MR2) {
           height = display.getHeight();
           width = display.getWidth();
       } else {
           Point size = new Point();
           display.getSize(size);
           height = size.y;
           width = size.x;
       }
       switch (rotation) {
       case Surface.ROTATION_90:
           if (width > height)
               activity.setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_LANDSCAPE);
           else
               activity.setRequestedOrientation(9/* reversePortait */);
           break;
       case Surface.ROTATION_180:
           if (height > width)
               activity.setRequestedOrientation(9/* reversePortait */);
           else
               activity.setRequestedOrientation(8/* reverseLandscape */);
           break;          
       case Surface.ROTATION_270:
           if (width > height)
               activity.setRequestedOrientation(8/* reverseLandscape */);
           else
               activity.setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_PORTRAIT);
           break;
       default :
           if (height > width)
               activity.setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_PORTRAIT);
           else
               activity.setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_LANDSCAPE);
       }
   }

   public static void unlockOrientation() {
      Harbour.context.setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_UNSPECIFIED);
   }

}
