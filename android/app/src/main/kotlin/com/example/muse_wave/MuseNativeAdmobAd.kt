package com.example.muse_wave

import android.content.Context
import android.graphics.Color
import android.graphics.drawable.Drawable
import android.graphics.drawable.GradientDrawable
import android.util.TypedValue
import android.view.Gravity
import android.view.ViewGroup
import android.widget.Button
import android.widget.ImageView
import android.widget.LinearLayout
import android.widget.TextView
import com.google.android.gms.ads.nativead.NativeAd
import com.google.android.gms.ads.nativead.NativeAdView
import io.flutter.plugins.googlemobileads.GoogleMobileAdsPlugin


class MuseNativeAdmobAd(private val context: Context) : GoogleMobileAdsPlugin.NativeAdFactory {

    override fun createNativeAd(nativeAd: NativeAd, customOptions: Map<String, Any>?): NativeAdView {

        val adView = NativeAdView(context).apply {
            layoutParams = ViewGroup.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.WRAP_CONTENT
            )
        }

        val container = LinearLayout(context).apply {
            orientation = LinearLayout.VERTICAL
            layoutParams = LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,
                LinearLayout.LayoutParams.WRAP_CONTENT
            )
            setPadding(0, dpToPx(40), 0, 0)
            setBackgroundColor(Color.TRANSPARENT)
        }

        adView.addView(container)

        val mainImage = ImageView(context).apply {
            layoutParams = LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                dpToPx(250)
            )
            scaleType = ImageView.ScaleType.CENTER_CROP
            if (nativeAd.images.isNotEmpty()) {
                setImageDrawable(nativeAd.images[0].drawable)
            }
        }

        container.addView(mainImage)

        val centerLayout = LinearLayout(context).apply {
            orientation = LinearLayout.VERTICAL
            gravity = Gravity.CENTER_HORIZONTAL
            layoutParams = LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.WRAP_CONTENT
            )
            setPadding(0, dpToPx(17), 0, 0)
        }

        val icon = ImageView(context).apply {
            layoutParams = LinearLayout.LayoutParams(dpToPx(64), dpToPx(64)).apply {
                setMargins(0, 0, 0, dpToPx(12))
            }
            nativeAd.icon?.let {
                setImageDrawable(it.drawable)
            }
            background = createRoundedBackground(Color.WHITE, dpToPx(17).toFloat())
        }

        adView.iconView = icon
        centerLayout.addView(icon)

        val body = TextView(context).apply {
            text = nativeAd.body
            setTextColor(Color.WHITE)
            gravity = Gravity.CENTER
            textSize = 14f
            setLineSpacing(1.2f, 1.2f)
        }

        adView.bodyView = body
        centerLayout.addView(body)

        container.addView(centerLayout)

        val ctaButton = Button(context).apply {
            text = nativeAd.callToAction
            setTextColor(Color.BLACK)
            textSize = 16f
            isClickable = false
            background = createRoundedBackground(Color.parseColor("#FFF273"), dpToPx(24).toFloat())
            layoutParams = LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                dpToPx(43)
            ).apply {
                setMargins(dpToPx(6), dpToPx(31), dpToPx(6), dpToPx(21))
            }
        }

        container.addView(ctaButton)

        adView.callToActionView = container
        adView.setNativeAd(nativeAd)

        return adView
    }


    private fun createRoundedBackground(color: Int, radius: Float): Drawable {
        return GradientDrawable().apply {
            setColor(color)
            cornerRadius = radius
        }
    }

    private fun dpToPx(dp: Int): Int {
        return TypedValue.applyDimension(
            TypedValue.COMPLEX_UNIT_DIP,
            dp.toFloat(),
            context.resources.displayMetrics
        ).toInt()
    }
}