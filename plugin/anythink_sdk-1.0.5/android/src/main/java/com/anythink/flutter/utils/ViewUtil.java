package com.anythink.flutter.utils;

import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.Path;
import android.graphics.PorterDuff;
import android.graphics.PorterDuffXfermode;

public class ViewUtil {

    public static void drawRadiusMask(Canvas canvas, int width, int height, int radius) {
        try {
            Paint paint = new Paint(Paint.ANTI_ALIAS_FLAG);
            paint.setColor(Color.WHITE);
            Bitmap maskBitmap = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888);
            Canvas canvas1 = new Canvas(maskBitmap);
            canvas1.drawPath(ViewUtil.getRadiusPath(radius, width, height), paint);
            paint.setXfermode(new PorterDuffXfermode(PorterDuff.Mode.DST_IN));


            canvas.drawBitmap(maskBitmap, 0, 0, paint);
//        canvas.restoreToCount(saveCount);
        } catch (Throwable e) {
            e.printStackTrace();
        }
    }

    public static Path getRadiusPath(int radius, int width, int height) {
        Path path = new Path();
        path.moveTo(radius, 0);

        path.lineTo(width - radius, 0);
        path.quadTo(width, 0, width, radius);

        path.lineTo(width, height - radius);
        path.quadTo(width, height, width - radius, height);

        path.lineTo(radius, height);
        path.quadTo(0, height, 0, height - radius);

        path.lineTo(0, radius);
        path.quadTo(0, 0, radius, 0);

        path.close();

        return path;
    }

}
