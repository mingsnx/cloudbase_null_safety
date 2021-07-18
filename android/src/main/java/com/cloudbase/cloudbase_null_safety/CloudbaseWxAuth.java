package com.cloudbase.cloudbase_null_safety;

import android.app.Activity;
import android.app.Application;
import android.app.Application.ActivityLifecycleCallbacks;
import android.os.Bundle;

import androidx.annotation.NonNull;

import io.flutter.plugin.common.MethodChannel.Result;

import com.tencent.mm.opensdk.modelbase.BaseReq;
import com.tencent.mm.opensdk.modelbase.BaseResp;
import com.tencent.mm.opensdk.modelmsg.SendAuth;
import com.tencent.mm.opensdk.openapi.IWXAPI;
import com.tencent.mm.opensdk.openapi.IWXAPIEventHandler;
import com.tencent.mm.opensdk.openapi.WXAPIFactory;

import java.lang.ref.WeakReference;

public class CloudbaseWxAuth implements IWXAPIEventHandler, ActivityLifecycleCallbacks {
  private static CloudbaseWxAuth instance = null;
  private String wxAppId = "";
  private IWXAPI wxApi;
  private Result flutterCallback = null;
  private WeakReference<Activity> wxEntryHandler = null;

  private CloudbaseWxAuth(String wxAppId) throws Exception {
    this.wxAppId = wxAppId;

    // 获取应用对象
    Application application = (Application) Class.forName("android.app.AppGlobals").getMethod("getInitialApplication").invoke(null, (Object[]) null);

    // 注册app
    wxApi = WXAPIFactory.createWXAPI(application, wxAppId, true);
    boolean isRegisterApp = wxApi.registerApp(wxAppId);
    if (!isRegisterApp) {
      throw new Exception("WX_AUTH_REGISTER_FAILED");
    }

    // 注册wxEntry
    application.registerActivityLifecycleCallbacks(this);
  }


  static CloudbaseWxAuth initialize(@NonNull String wxAppId) throws Exception {
    if (instance != null) {
      return instance;
    }

    instance = new CloudbaseWxAuth(wxAppId);
    return instance;
  }

  static CloudbaseWxAuth getInstance() {
    return instance;
  }


  void login(Result result) {
    if (wxApi == null) {
      result.error("WX_AUTH_NO_INSTANCE", "WX_AUTH_NO_INSTANCE", null);
      return;
    }

    if (!wxApi.isWXAppInstalled()) {
      result.error("WX_AUTH_NO_INSTALLED", "WX_AUTH_NO_INSTALLED", null);
      return;
    }

    flutterCallback = result;

    final SendAuth.Req req = new SendAuth.Req();
    req.scope = "snsapi_userinfo";
    req.state = "diandi_wx_login";
    wxApi.sendReq(req);
  }

  // 微信发送请求到第三方应用时，会回调到该方法
  @Override
  public void onReq(BaseReq req) {

  }

  // 第三方应用发送到微信的请求处理后的响应结果，会回调到该方法
  // app发送消息给微信，处理返回消息的回调
  @Override
  public void onResp(BaseResp resp) {
    if (flutterCallback == null) {
      return;
    }

    if (resp.errCode == BaseResp.ErrCode.ERR_OK) {
      flutterCallback.success(((SendAuth.Resp) resp).code);
    } else {
      flutterCallback.error("WX_AUTH_LOGIN_FAILED", "WX_AUTH_LOGIN_FAILED", null);
    }

    if (wxEntryHandler != null && wxEntryHandler.get() != null) {
      wxEntryHandler.get().finish();
      wxEntryHandler = null;
    }
  }

  @Override
  public void onActivityCreated(Activity activity, Bundle savedInstanceState) {
    // 监控到wxEntry被创建后, 注册到wxApi
    if (activity.getLocalClassName().equals("wxapi.WXEntryActivity")  && wxApi != null) {
      wxEntryHandler = new WeakReference<>(activity);
      wxApi.handleIntent(activity.getIntent(), this);
    }
  }

  @Override
  public void onActivityStarted(Activity activity) {

  }

  @Override
  public void onActivityResumed(Activity activity) {

  }

  @Override
  public void onActivityPaused(Activity activity) {

  }

  @Override
  public void onActivityStopped(Activity activity) {

  }

  @Override
  public void onActivitySaveInstanceState(Activity activity, Bundle outState) {

  }

  @Override
  public void onActivityDestroyed(Activity activity) {

  }

}
