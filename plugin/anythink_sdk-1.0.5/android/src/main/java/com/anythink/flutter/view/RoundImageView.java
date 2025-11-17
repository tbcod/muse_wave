package com.anythink.flutter.view;

import android.content.Context;
import android.graphics.Canvas;
import android.util.AttributeSet;

import com.anythink.flutter.utils.Utils;
import com.anythink.flutter.utils.ViewUtil;
import com.anythink.nativead.api.ATNativeImageView;


public class RoundImageView extends ATNativeImageView implements IRoundView {

    int mRadius;

    public RoundImageView(Context context) {
        super(context);
    }

    public RoundImageView(Context context, AttributeSet attrs) {
        super(context, attrs);
    }

    public RoundImageView(Context context, AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
    }

    @Override
    public void setRadiusInDip(int dip) {
        this.mRadius = Utils.dip2px(getContext(), dip);
    }

    @Override
    public void draw(Canvas canvas) {

        if (mRadius > 0) {
            int saveCount = canvas.saveLayer(0, 0, getWidth(), getHeight(), null, Canvas.ALL_SAVE_FLAG);
            super.draw(canvas);
            ViewUtil.drawRadiusMask(canvas, getWidth(), getHeight(), mRadius);
            canvas.restoreToCount(saveCount);

            return;
        }

        super.draw(canvas);
    }

}
