package com.anythink.flutter.nativead;

import android.app.Activity;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Color;
import android.text.TextUtils;
import android.util.TypedValue;
import android.view.Gravity;
import android.view.View;
import android.view.ViewGroup;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.anythink.core.api.ATAdAppInfo;
import com.anythink.flutter.utils.Const;
import com.anythink.flutter.utils.MsgTools;
import com.anythink.flutter.utils.Utils;
import com.anythink.flutter.view.RoundFrameLayout;
import com.anythink.flutter.view.RoundImageView;
import com.anythink.flutter.view.RoundTextView;
import com.anythink.flutter.view.SimpleWebViewActivity;
import com.anythink.nativead.api.ATNativeImageView;
import com.anythink.nativead.api.ATNativeMaterial;
import com.anythink.nativead.api.ATNativePrepareExInfo;
import com.anythink.nativead.api.ATNativePrepareInfo;

import java.io.InputStream;
import java.util.ArrayList;
import java.util.List;

public class SelfRenderViewUtil {

    Activity mActivity;
    ViewInfo mViewInfo;
    ImageView mDislikeView;
    int mNetworkType;

    public SelfRenderViewUtil(Activity pActivity, ViewInfo pViewInfo, int networkType) {
        mActivity = pActivity;
        mViewInfo = pViewInfo;
        mNetworkType = networkType;
    }

    public FrameLayout bindSelfRenderView(ATNativeMaterial adMaterial, ATNativePrepareInfo nativePrepareInfo, ViewInfo pViewInfo) {
        RoundFrameLayout frameLayout = new RoundFrameLayout(mActivity);
        TextView titleView = new RoundTextView(mActivity);
        TextView descView = new RoundTextView(mActivity);
        TextView ctaView = new RoundTextView(mActivity);

        //click views
        List<View> clickViewList = new ArrayList<>();
        //click
        List<View> customClickViews = new ArrayList<>();

        final View mediaView = adMaterial.getAdMediaView(frameLayout);

        if (pViewInfo.titleView != null) {

            if (!TextUtils.isEmpty(pViewInfo.titleView.textcolor)) {
                titleView.setTextColor(Color.parseColor(pViewInfo.titleView.textcolor));
            }

            if (pViewInfo.titleView.textSize > 0) {
                titleView.setTextSize(TypedValue.COMPLEX_UNIT_PX, pViewInfo.titleView.textSize);
            }
            MsgTools.printMsg("title---->" + adMaterial.getTitle());
            titleView.setText(adMaterial.getTitle());

            titleView.setSingleLine();
            titleView.setMaxEms(15);
            titleView.setEllipsize(TextUtils.TruncateAt.END);

            ViewInfo.add2ParentView(frameLayout, titleView, pViewInfo.titleView, -1);
            nativePrepareInfo.setTitleView(titleView);//bind title
        }


        if (pViewInfo.ctaView != null) {
            if (!TextUtils.isEmpty(pViewInfo.ctaView.textcolor)) {
                //                 MsgTools.pirntMsg("#"+Integer.toHexString(pViewInfo.ctaView.textcolor));
                //                ctaView.setTextColor(pViewInfo.ctaView.textcolor);
                ctaView.setTextColor(Color.parseColor(pViewInfo.ctaView.textcolor));
            }

            if (pViewInfo.ctaView.textSize > 0) {
                ctaView.setTextSize(TypedValue.COMPLEX_UNIT_PX, pViewInfo.ctaView.textSize);
            }


            ctaView.setGravity(Gravity.CENTER);
            ctaView.setSingleLine();
            ctaView.setMaxEms(15);
            ctaView.setEllipsize(TextUtils.TruncateAt.END);

            MsgTools.printMsg("cta---->" + adMaterial.getCallToActionText());
            ctaView.setText(adMaterial.getCallToActionText());

            ViewInfo.add2ParentView(frameLayout, ctaView, pViewInfo.ctaView, -1);
            nativePrepareInfo.setCtaView(ctaView);//bind cta button
        }


        if (pViewInfo.descView != null && descView != null) {

            if (!TextUtils.isEmpty(pViewInfo.descView.textcolor)) {
                descView.setTextColor(Color.parseColor(pViewInfo.descView.textcolor));

            }
            if (pViewInfo.descView.textSize > 0) {
                descView.setTextSize(TypedValue.COMPLEX_UNIT_PX, pViewInfo.descView.textSize);
            }
            MsgTools.printMsg("desc---->" + adMaterial.getDescriptionText());
            descView.setText(adMaterial.getDescriptionText());


            descView.setMaxLines(3);
            descView.setMaxEms(15);
            descView.setEllipsize(TextUtils.TruncateAt.END);

            ViewInfo.add2ParentView(frameLayout, descView, pViewInfo.descView, -1);
            nativePrepareInfo.setDescView(descView);//bind desc
        }

        ATNativeImageView iconView = null;
        if (pViewInfo.IconView != null) {

            FrameLayout iconArea = new RoundFrameLayout(mActivity);

            View adIconView = adMaterial.getAdIconView();
            if (adIconView == null) {
                MsgTools.printMsg("icon ---> " + adMaterial.getIconImageUrl());
                iconView = new RoundImageView(mActivity);
                iconArea.addView(iconView, new FrameLayout.LayoutParams(FrameLayout.LayoutParams.MATCH_PARENT, FrameLayout.LayoutParams.MATCH_PARENT));
                iconView.setImage(adMaterial.getIconImageUrl());
            } else {
                MsgTools.printMsg("adIconView ---> " + adIconView);
                iconArea.addView(adIconView, new FrameLayout.LayoutParams(FrameLayout.LayoutParams.MATCH_PARENT, FrameLayout.LayoutParams.MATCH_PARENT));
            }

            // 加载图片
            ViewInfo.add2ParentView(frameLayout, iconArea, pViewInfo.IconView, -1);
            nativePrepareInfo.setIconView(iconView);//bind icon
        }


        if (mediaView != null) {
//            mediaView.setLayerType(View.LAYER_TYPE_SOFTWARE, null);
            MsgTools.printMsg("mediaView ---> 视屏播放 " + adMaterial.getVideoUrl());
            if (pViewInfo.imgMainView != null) {
//                RoundFrameLayout roundFrameLayout = new RoundFrameLayout(mActivity);
//                roundFrameLayout.addView(mediaView);
//                ViewInfo.add2ParentView(frameLayout, roundFrameLayout, pViewInfo.imgMainView, -1);


                ViewInfo.add2ParentView(frameLayout, mediaView, pViewInfo.imgMainView, -1);
            }
        } else {
            //加载大图
            MsgTools.printMsg("mainImageView ---> " + adMaterial.getMainImageUrl());
            if (pViewInfo.imgMainView != null) {
                final ATNativeImageView mainImageView = new RoundImageView(mActivity);
                ViewInfo.add2ParentView(frameLayout, mainImageView, pViewInfo.imgMainView, -1);
                mainImageView.setImage(adMaterial.getMainImageUrl());
                nativePrepareInfo.setMainImageView(mainImageView);//bind main image
            }
        }


        if (!TextUtils.isEmpty(adMaterial.getAdFrom()) && mNetworkType == 23) {
            FrameLayout.LayoutParams adFromParam = new FrameLayout.LayoutParams(FrameLayout.LayoutParams.WRAP_CONTENT, FrameLayout.LayoutParams.WRAP_CONTENT);
            adFromParam.leftMargin = Utils.dip2px(mActivity, 3);
            adFromParam.bottomMargin = Utils.dip2px(mActivity, 3);
            adFromParam.gravity = Gravity.BOTTOM;
            TextView adFromTextView = new RoundTextView(mActivity);
            adFromTextView.setTextSize(TypedValue.COMPLEX_UNIT_DIP, 6);
            adFromTextView.setPadding(Utils.dip2px(mActivity, 5), Utils.dip2px(mActivity, 2), Utils.dip2px(mActivity, 5), Utils.dip2px(mActivity, 2));
            adFromTextView.setBackgroundColor(0xff888888);
            adFromTextView.setTextColor(0xffffffff);
            adFromTextView.setText(adMaterial.getAdFrom());

            frameLayout.addView(adFromTextView, adFromParam);
            nativePrepareInfo.setAdFromView(adFromTextView);//bind ad from
        }

        if (pViewInfo.elementsView != null) {
            ATAdAppInfo adAppInfo = adMaterial.getAdAppInfo();
            if (adAppInfo != null) {

                MsgTools.printMsg("adAppInfo----> " + adAppInfo.toString());

                String appName = adAppInfo.getAppName();
                if (!TextUtils.isEmpty(appName)) {
                    MsgTools.printMsg("update title ----> " + appName);
                    titleView.setText(appName);
                }

                View elementsView = createElementsView(pViewInfo.elementsView, adAppInfo);

                if (elementsView != null) {
                    RoundFrameLayout roundFrameLayout = new RoundFrameLayout(mActivity);
                    roundFrameLayout.addView(elementsView);

                    ViewInfo.add2ParentView(frameLayout, roundFrameLayout, pViewInfo.elementsView, -1);
                }
            } else {
                MsgTools.printMsg("adAppInfo----> null");
            }
        }

        if (pViewInfo.customView != null && pViewInfo.customView.size() > 0) {

            for (ViewInfo.INFO customViewInfo : pViewInfo.customView) {

                if (TextUtils.isEmpty(customViewInfo.customViewType)) {
                    continue;
                }

                try {

                    View customView = getCustomView(customViewInfo);

                    if (customView != null) {

                        RoundFrameLayout roundFrameLayout = new RoundFrameLayout(mActivity);
                        roundFrameLayout.addView(customView);


                        ViewInfo.add2ParentView(frameLayout, roundFrameLayout, customViewInfo, -1);
                    }

                } catch (Throwable e) {
                    e.printStackTrace();
                }

            }
        }


        ATNativeImageView logoView = null;
        if (pViewInfo.adLogoView != null) {
            logoView = new RoundImageView(mActivity);
            ViewInfo.add2ParentView(frameLayout, logoView, pViewInfo.adLogoView, -1);
            nativePrepareInfo.setAdLogoView(logoView);//bind ad choice
            logoView.setImage(adMaterial.getAdChoiceIconUrl());
            MsgTools.printMsg("adMaterial choice icon url == null:" + (adMaterial.getAdChoiceIconUrl() == null));

            if (TextUtils.isEmpty(adMaterial.getAdChoiceIconUrl())) {
                MsgTools.printMsg("start to add adMaterial label textview");
                RoundTextView adLableTextView = new RoundTextView(mActivity);
                adLableTextView.setTextColor(Color.WHITE);
                adLableTextView.setText("AD");
                adLableTextView.setTextSize(11);
                adLableTextView.setPadding(Utils.dip2px(mActivity, 3), 0, Utils.dip2px(mActivity, 3), 0);
                adLableTextView.setBackgroundColor(Color.parseColor("#66000000"));
                if (frameLayout != null) {
                    FrameLayout.LayoutParams layoutParams = new FrameLayout.LayoutParams(ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.WRAP_CONTENT);
                    layoutParams.leftMargin = Utils.dip2px(mActivity, 3);
                    layoutParams.topMargin = Utils.dip2px(mActivity, 3);
                    frameLayout.addView(adLableTextView, layoutParams);

                    MsgTools.printMsg("add adMaterial label textview 2 activity");

                    nativePrepareInfo.setAdLogoView(adLableTextView);//bind ad choice
                }
            }
            FrameLayout.LayoutParams adLogoLayoutParams = new FrameLayout.LayoutParams(pViewInfo.adLogoView.mWidth, pViewInfo.adLogoView.mHeight);
            adLogoLayoutParams.leftMargin = pViewInfo.adLogoView.mX;
            adLogoLayoutParams.topMargin = pViewInfo.adLogoView.mY;
            nativePrepareInfo.setChoiceViewLayoutParams(adLogoLayoutParams);//bind layout params for adMaterial choice
        }

        if (pViewInfo.dislikeView != null) {
            initDislikeView(pViewInfo.dislikeView);
            ViewInfo.add2ParentView(frameLayout, mDislikeView, pViewInfo.dislikeView, -1);
            nativePrepareInfo.setCloseView(mDislikeView);//bind close button
        }

        if (pViewInfo.rootView != null) {
            dealWithClick(frameLayout, pViewInfo.rootView.isCustomClick, clickViewList, customClickViews, "root");
        }
        if (pViewInfo.titleView != null) {
            dealWithClick(titleView, pViewInfo.titleView.isCustomClick, clickViewList, customClickViews, "title");
        }
        if (pViewInfo.descView != null) {
            dealWithClick(descView, pViewInfo.descView.isCustomClick, clickViewList, customClickViews, "desc");
        }
        if (pViewInfo.IconView != null && iconView != null) {
            dealWithClick(iconView, pViewInfo.IconView.isCustomClick, clickViewList, customClickViews, "icon");
        }
        if (pViewInfo.adLogoView != null) {
            dealWithClick(logoView, pViewInfo.adLogoView.isCustomClick, clickViewList, customClickViews, "adLogo");
        }
        if (pViewInfo.ctaView != null) {
            dealWithClick(ctaView, pViewInfo.ctaView.isCustomClick, clickViewList, customClickViews, "cta");
        }


        nativePrepareInfo.setClickViewList(clickViewList);//bind click view list

        if (nativePrepareInfo instanceof ATNativePrepareExInfo) {
            ((ATNativePrepareExInfo) nativePrepareInfo).setCreativeClickViewList(customClickViews);//bind custom view list
        }

        return frameLayout;
    }

    private View getCustomView(ViewInfo.INFO customViewInfo) {
        View customView = null;

        switch (customViewInfo.customViewType) {
            case Const.TYPE_CUSTOM_VIEW.image:
                String imagePath = customViewInfo.imagePath;
                if (!TextUtils.isEmpty(imagePath)) {
                    MsgTools.printMsg("customView, imagePath ----> " + imagePath);

                    if (imagePath.startsWith("http")) {
                        ATNativeImageView customImageView = new RoundImageView(mActivity);
                        customImageView.setImage(imagePath);

                        customView = customImageView;
                    } else {

                        try {
                            InputStream imageInputStream = mActivity.getResources().getAssets().open(imagePath);

                            ImageView customImageView = new RoundImageView(mActivity);
                            Bitmap bitmap = BitmapFactory.decodeStream(imageInputStream);
                            customImageView.setImageBitmap(bitmap);

                            customView = customImageView;
                        } catch (Throwable e) {
                            e.printStackTrace();
                        }

                    }

                }
                break;

            case Const.TYPE_CUSTOM_VIEW.label:
                if (!TextUtils.isEmpty(customViewInfo.title)) {
                    TextView customTextView = new TextView(mActivity);
                    MsgTools.printMsg("customView, label title ----> " + customViewInfo.title);

                    if (!TextUtils.isEmpty(customViewInfo.textcolor)) {
                        customTextView.setTextColor(Color.parseColor(customViewInfo.textcolor));
                    }

                    if (customViewInfo.textSize > 0) {
                        customTextView.setTextSize(TypedValue.COMPLEX_UNIT_PX, customViewInfo.textSize);
                    }
                    customTextView.setText(customViewInfo.title);

                    customTextView.setGravity(Gravity.CENTER);

                    customTextView.setSingleLine();
                    customTextView.setMaxEms(15);
                    customTextView.setEllipsize(TextUtils.TruncateAt.END);

                    customView = customTextView;
                }
                break;
            case Const.TYPE_CUSTOM_VIEW.view:
                MsgTools.printMsg("customView, view ----> ");
                customView = new View(mActivity);

                break;
        }
        return customView;
    }

    private void initDislikeView(ViewInfo.INFO dislikeInfoView) {
        if (mDislikeView == null) {
            mDislikeView = new RoundImageView(mActivity);
            mDislikeView.setImageResource(Utils.getResId(mActivity, "btn_close", "drawable"));
        }

        FrameLayout.LayoutParams layoutParams = new FrameLayout.LayoutParams(dislikeInfoView.mWidth, dislikeInfoView.mHeight);
        layoutParams.leftMargin = dislikeInfoView.mX;
        layoutParams.topMargin = dislikeInfoView.mY;

        if (!TextUtils.isEmpty(dislikeInfoView.bgcolor)) {
            mDislikeView.setBackgroundColor(Color.parseColor(dislikeInfoView.bgcolor));
        }

        mDislikeView.setLayoutParams(layoutParams);
    }

    private void dealWithClick(View view, boolean isCustomClick, List<View> clickViews, List<View> customClickViews, String name) {
        if (mNetworkType == 8 || mNetworkType == 22) {
            if (isCustomClick) {
                if (view != null) {
                    MsgTools.printMsg("add customClick ----> " + name);
                    customClickViews.add(view);
                }
                return;
            }
        }
        if (view != null) {
            MsgTools.printMsg("add click ----> " + name);
            clickViews.add(view);
        }
    }

    private View createElementsView(ViewInfo.INFO elementsView, ATAdAppInfo atAdAppInfo) {
        if (elementsView == null || atAdAppInfo == null) {
            MsgTools.printMsg("createElementsView ----> " + elementsView + ", " + atAdAppInfo);
            return null;
        }


//        String appName = atAdAppInfo.getAppName();
        String appVersion = atAdAppInfo.getAppVersion();
        String publisher = atAdAppInfo.getPublisher();
        String appPermissonUrl = atAdAppInfo.getAppPermissonUrl();
        String appPrivacyUrl = atAdAppInfo.getAppPrivacyUrl();
        String functionUrl = atAdAppInfo.getFunctionUrl();

        LinearLayout linearLayout = new LinearLayout(mActivity);
        linearLayout.setOrientation(LinearLayout.HORIZONTAL);

        if (!TextUtils.isEmpty(functionUrl)) {
            TextView functionView = new TextView(mActivity);
            setupElementView(elementsView, "function", functionView, "功能");
            setOpenUrlClickListener(functionView, functionUrl);

            linearLayout.addView(functionView);
        }
        if (!TextUtils.isEmpty(appPrivacyUrl)) {
            TextView privacyView = new TextView(mActivity);
            setupElementView(elementsView, "privacy", privacyView, "隐私");
            setOpenUrlClickListener(privacyView, appPrivacyUrl);

            linearLayout.addView(privacyView);
        }
        if (!TextUtils.isEmpty(appPermissonUrl)) {
            TextView permissionView = new TextView(mActivity);
            setupElementView(elementsView, "permission", permissionView, "权限");
            setOpenUrlClickListener(permissionView, appPermissonUrl);

            linearLayout.addView(permissionView);
        }

//        if (!TextUtils.isEmpty(appName)) {
//            TextView appNameView = new TextView(mActivity);
//            setupElementView(elementsView, "appName", appNameView, appName);
//
//            linearLayout.addView(appNameView);
//        }
        if (!TextUtils.isEmpty(publisher)) {
            TextView publisherView = new TextView(mActivity);
            setupElementView(elementsView, "publisher", publisherView, publisher);

            linearLayout.addView(publisherView);
        }
        if (!TextUtils.isEmpty(appVersion)) {
            TextView appVersionView = new TextView(mActivity);
            setupElementView(elementsView, "appVersion", appVersionView, "v" + appVersion);

            linearLayout.addView(appVersionView);
        }

        if (linearLayout.getChildCount() > 0) {
            return linearLayout;
        } else {
            return null;
        }
    }


    private void setupElementView(ViewInfo.INFO elementsView, String tag, TextView view, String text) {
        try {
            view.setTextColor(Color.parseColor(elementsView.textcolor));
            view.setTextSize(TypedValue.COMPLEX_UNIT_PX, elementsView.textSize);
            MsgTools.printMsg(tag + "----> " + text);
            view.setText(text);

            view.setSingleLine();
            view.setMaxEms(15);
            view.setEllipsize(TextUtils.TruncateAt.END);

            int padding = Utils.dip2px(mActivity, 2);
            view.setPadding(padding, padding, padding, padding);

            LinearLayout.LayoutParams params = new LinearLayout.LayoutParams(ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.WRAP_CONTENT);
            params.gravity = Gravity.CENTER_VERTICAL;
            view.setLayoutParams(params);
        } catch (Throwable e) {
            e.printStackTrace();
        }
    }

    private void setOpenUrlClickListener(View view, final String url) {
        view.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                try {
                    MsgTools.printMsg("open url: " + url);

//                    Intent intent = new Intent(Intent.ACTION_VIEW,
//                            Uri.parse(url));
//                    intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TASK
//                            | Intent.FLAG_ACTIVITY_NEW_TASK);
//                    Context context = mActivity;
//                    if (context != null) {
//                        context.startActivity(intent);
//                    }

                    Intent intent = new Intent(mActivity, SimpleWebViewActivity.class);
                    intent.putExtra(SimpleWebViewActivity.EXTRA_URL, url);

                    intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);

                    mActivity.startActivity(intent);

                } catch (Throwable e2) {
                    e2.printStackTrace();
                }
            }
        });
    }


}
