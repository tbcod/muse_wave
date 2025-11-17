package com.anythink.flutter.view;

import android.content.Context;
import android.graphics.Canvas;
import android.graphics.drawable.GradientDrawable;
import android.util.AttributeSet;
import android.widget.TextView;

import com.anythink.flutter.utils.Utils;
import com.anythink.flutter.utils.ViewUtil;


public class RoundTextView extends TextView implements IRoundView {

    int mRadius;

    public RoundTextView(Context context) {
        super(context);
    }

    public RoundTextView(Context context, AttributeSet attrs) {
        super(context, attrs);
    }

    public RoundTextView(Context context, AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
    }

    @Override
    public void setRadiusInDip(int dip) {
        this.mRadius = Utils.dip2px(getContext(), dip);
    }

    public void setCornerBackGround(int color, int radius) {

        setRadiusInDip(radius);

        GradientDrawable gd = new GradientDrawable();
        gd.setColor(color);
        gd.setCornerRadius(radius);

        setBackground(gd);
    }


    @Override
    public void onDrawForeground(Canvas canvas) {

        if (mRadius > 0) {
            int saveCount = canvas.saveLayer(0, 0, getWidth(), getHeight(), null, Canvas.ALL_SAVE_FLAG);
            super.onDrawForeground(canvas);
            canvas.translate(getPaddingLeft(), getPaddingTop());
            ViewUtil.drawRadiusMask(canvas, getWidth() - getPaddingLeft() * 2, getHeight() - getPaddingTop() * 2, mRadius);
            canvas.restoreToCount(saveCount);
            return;
        }

        super.onDrawForeground(canvas);
    }

}
