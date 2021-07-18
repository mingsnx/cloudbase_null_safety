package com.cloudbase.cloudbase_null_safety;

import androidx.annotation.NonNull;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;
import java.util.Map;

/** CloudbaseAuthPlugin */
public class CloudbaseAuthPlugin implements FlutterPlugin, MethodCallHandler {

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    final MethodChannel channel = new MethodChannel(flutterPluginBinding.getFlutterEngine().getDartExecutor(), "cloudbase_null_safety");
    channel.setMethodCallHandler(new CloudbaseAuthPlugin());
  }

  // This static function is optional and equivalent to onAttachedToEngine. It supports the old
  // pre-Flutter-1.12 Android projects. You are encouraged to continue supporting
  // plugin registration via this function while apps migrate to use the new Android APIs
  // post-flutter-1.12 via https://flutter.dev/go/android-project-migration.
  //
  // It is encouraged to share logic between onAttachedToEngine and registerWith to keep
  // them functionally equivalent. Only one of onAttachedToEngine or registerWith will be called
  // depending on the user's project. onAttachedToEngine or registerWith must both be defined
  // in the same class.
  public static void registerWith(Registrar registrar) {
    final MethodChannel channel = new MethodChannel(registrar.messenger(), "cloudbase_null_safety");
    channel.setMethodCallHandler(new CloudbaseAuthPlugin());
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    switch (call.method) {
      case "wxauth.register":
        handleWxAuthRegister(call, result);
        break;
      case "wxauth.login":
        handleWxAuthLogin(call, result);
        break;
      default:
        result.success("OK");
        break;
    }
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
  }

  private void handleWxAuthRegister(MethodCall call, Result result) {
    Map<String, String> arguments = call.arguments();
    String wxAppId = arguments.get("wxAppId");
    try {
      CloudbaseWxAuth.initialize(wxAppId);
      result.success(null);
    } catch (Exception e) {
      result.error("WX_AUTH_REGISTER_FAILED", "WX_AUTH_REGISTER_FAILED", null);
    }
  }

  private void handleWxAuthLogin(MethodCall call, Result result) {
    CloudbaseWxAuth wxAuth = CloudbaseWxAuth.getInstance();
    if (wxAuth != null) {
      wxAuth.login(result);
    } else {
      result.error("WX_AUTH_NO_INSTANCE", "WX_AUTH_NO_INSTANCE", null);
    }
  }
}
