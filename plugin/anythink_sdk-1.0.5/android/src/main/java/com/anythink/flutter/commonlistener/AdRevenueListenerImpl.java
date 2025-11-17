package com.anythink.flutter.commonlistener;

import androidx.annotation.NonNull;

import com.anythink.flutter.utils.Const;
import com.anythink.flutter.utils.MsgTools;
import com.anythink.flutter.ATFlutterEventManager;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

import com.anythink.core.api.ATAdRevenueListener;
import com.anythink.core.api.ATAdInfo;

import org.json.JSONArray;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class AdRevenueListenerImpl implements ATAdRevenueListener {
    private String placementId;

    public AdRevenueListenerImpl(String placementId) {
        this.placementId = placementId;
    }

    @Override
    public void onAdRevenuePaid(ATAdInfo adInfo) {
        MsgTools.printMsg("onAdRevenuePaid: " + adInfo + "placementID: " + placementId);

        ATFlutterEventManager.getInstance().sendCallbackMsgToFlutter(
                Const.CallbackMethodCall.CommonADCall, Const.CommonADCallBack.AdShowRevenueCallbackKey,
                placementId, adInfo.toString(), null);
    }

    public String getPlacementId() {
        return placementId;
    }

    public void setPlacementId(String placementId) {
        this.placementId = placementId;
    }
}

