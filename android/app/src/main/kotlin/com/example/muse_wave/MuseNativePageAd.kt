package com.example.muse_wave

import android.content.Context
import android.graphics.Color
import android.graphics.drawable.Drawable
import android.graphics.drawable.GradientDrawable
import android.util.TypedValue
import android.view.Gravity
import android.view.ViewGroup
import android.widget.Button
import android.widget.FrameLayout
import android.widget.ImageView
import android.widget.LinearLayout
import android.widget.TextView
import com.google.android.gms.ads.nativead.NativeAd
import com.google.android.gms.ads.nativead.NativeAdView
import io.flutter.plugins.googlemobileads.GoogleMobileAdsPlugin
import com.google.android.gms.ads.nativead.MediaView


class MuseNativePageAd(private val context: Context) : GoogleMobileAdsPlugin.NativeAdFactory {

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
            ).apply {
                setMargins(dpToPx(0), dpToPx(8), dpToPx(0), dpToPx(0))
            }
            setPadding(0, dpToPx(0), 0, 0)
            setBackgroundColor(Color.TRANSPARENT)
        }

        adView.addView(container)

        if (nativeAd.mediaContent != null) {
            val mediaView = MediaView(context).apply {
                layoutParams = LinearLayout.LayoutParams(
                    ViewGroup.LayoutParams.MATCH_PARENT,
                    dpToPx(160)
                )
            }
            mediaView.mediaContent = nativeAd.mediaContent
            adView.mediaView = mediaView
            container.addView(mediaView)
        } else if (nativeAd.images.isNotEmpty()) {
            val imageView = ImageView(context).apply {
                layoutParams = LinearLayout.LayoutParams(
                    ViewGroup.LayoutParams.MATCH_PARENT,
                    dpToPx(160)
                )
                scaleType = ImageView.ScaleType.CENTER_CROP
                setImageDrawable(nativeAd.images[0].drawable)
            }
            adView.imageView = imageView;
            container.addView(imageView)
        }

        val rowLayout = LinearLayout(context).apply {
            orientation = LinearLayout.HORIZONTAL
            gravity = Gravity.CENTER_VERTICAL
            layoutParams = LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.WRAP_CONTENT
            ).apply {
                setMargins(dpToPx(18), dpToPx(24), dpToPx(18), dpToPx(2))
            }
        }


         val adIconView = ImageView(context).apply {
            layoutParams = LinearLayout.LayoutParams(dpToPx(48), dpToPx(48)).apply {
                rightMargin = dpToPx(6)
            }
            scaleType = ImageView.ScaleType.FIT_CENTER
        }
        adIconView.setImageDrawable(nativeAd.icon?.drawable)
        adView.iconView = adIconView
        rowLayout.addView(adIconView)

        val textV = LinearLayout(context).apply {
            orientation = LinearLayout.VERTICAL
            layoutParams = LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,
                LinearLayout.LayoutParams.WRAP_CONTENT
            )
//            setBackgroundColor(Color.RED)
        }

        val headline = TextView(context).apply {
            text = nativeAd.headline
            gravity = Gravity.LEFT
            textSize = 16f
            maxLines = 1
            layoutParams = LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.WRAP_CONTENT
            ).apply {
                setMargins(dpToPx(0), dpToPx(0), dpToPx(0), dpToPx(0))
            }
            setTextColor(Color.BLACK)
        }
        adView.headlineView = headline
        textV.addView(headline)

        val bodyV = TextView(context).apply {
            text = nativeAd.body
            gravity = Gravity.CENTER
            textSize = 14f
            maxLines = 1
            layoutParams = LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.WRAP_CONTENT
            ).apply {
                setMargins(dpToPx(0), dpToPx(6), dpToPx(0), dpToPx(2))
            }
            setTextColor(Color.parseColor("#333333"))
        }
        adView.bodyView = bodyV
        textV.addView(bodyV)
        rowLayout.addView(textV)
        container.addView(rowLayout)

        val actionButton = Button(context).apply {
            text = nativeAd.callToAction
            textSize = 16f
            background = createRoundedBackground(Color.parseColor("#b79efe"), dpToPx(8).toFloat())
            layoutParams = LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                dpToPx(40)
            ).apply {
                setMargins(dpToPx(18), dpToPx(24), dpToPx(18), dpToPx(0))
            }
            setTextColor(Color.WHITE)
        }
        adView.callToActionView = actionButton
        container.addView(actionButton)

        val priceV = TextView(context).apply {
            text = nativeAd.price
            gravity = Gravity.CENTER
            textSize = 18f
            maxLines = 1
            layoutParams = FrameLayout.LayoutParams(
                dpToPx(48),
                dpToPx(48)
            )
            setTextColor(Color.TRANSPARENT)
//            setBackgroundColor(Color.RED)
        }
        adView.priceView = priceV
        adView.addView(priceV)
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