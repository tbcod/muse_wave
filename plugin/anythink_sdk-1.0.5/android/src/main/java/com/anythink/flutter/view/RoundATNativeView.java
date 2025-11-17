package com.anythink.flutter.view;

import android.content.Context;
import android.graphics.Canvas;

import com.anythink.flutter.utils.ViewUtil;
import com.anythink.nativead.api.ATNativeAdView;

public class RoundATNativeView extends ATNativeAdView implements IRoundView {

    int mRadius;

    public RoundATNativeView(Context context) {
        super(context);
    }


    @Override
    public void draw(Canvas canvas) {
        int saveCount = canvas.saveLayer(0, 0, getWidth(), getHeight(), null, Canvas.ALL_SAVE_FLAG);
        super.draw(canvas);
        ViewUtil.drawRadiusMask(canvas, getWidth(), getHeight(), mRadius);
        canvas.restoreToCount(saveCount);
    }


    public static int dip2px(Context context, float dipValue) {
        float scale = context.getResources().getDisplayMetrics().density;
        return (int) (dipValue * scale + 0.5f);
    }

    @Override
    public void setRadiusInDip(int dip) {
        mRadius = dip2px(getContext(), dip);
    }
}
