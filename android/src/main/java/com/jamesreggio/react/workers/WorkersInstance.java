package com.jamesreggio.react.workers;

import android.app.Activity;
import android.app.Application;
import android.os.Handler;
import android.os.Looper;

import com.facebook.infer.annotation.Assertions;
import com.facebook.infer.annotation.ThreadConfined;
import com.facebook.react.ReactApplication;
import com.facebook.react.ReactInstanceManager.ReactInstanceEventListener;
import com.facebook.react.ReactInstanceManager;
import com.facebook.react.ReactInstanceManagerBuilder;
import com.facebook.react.ReactNativeHost;
import com.facebook.react.ReactPackage;
import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.JSBundleLoader;
import com.facebook.react.bridge.LifecycleEventListener;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContext;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.common.LifecycleState;
import com.facebook.react.modules.systeminfo.AndroidInfoHelpers;
import com.facebook.react.packagerconnection.PackagerConnectionSettings;
import com.facebook.react.shell.MainReactPackage;
import com.facebook.react.uimanager.UIImplementationProvider;
import static com.facebook.infer.annotation.ThreadConfined.UI;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

public class WorkersInstance implements ReactInstanceEventListener, LifecycleEventListener {

  private final Integer key;
  private final ReactApplicationContext parentContext;
  private final ReactNativeHost host;

  private Promise startedPromise;
  private ReactInstanceManager manager;

  public WorkersInstance(
    final Integer key,
    final ReactApplicationContext parentContext,
    final ReactPackage[] packages,
    final String bundleRoot,
    final String bundleResource,
    final Integer bundlerPort,
    final Promise startedPromise
  ) {
    this.key = key;
    this.parentContext = parentContext;
    this.startedPromise = startedPromise;

    final Activity activity = parentContext.getCurrentActivity();
    final Application application = Assertions.assertNotNull(activity).getApplication();
    final ReactNativeHost parentHost = Assertions.assertNotNull((ReactApplication)application).getReactNativeHost();

    this.host = new ReactNativeHost(application) {
      @Override
      protected String getJSMainModuleName() {
        return bundleRoot;
      }

      @Override
      protected String getBundleAssetName() {
        if (bundleResource == null) {
          return null;
        }

        return String.format("%s.bundle", bundleResource);
      }

      @Override
      public boolean getUseDeveloperSupport() {
//        return false;
        return parentHost.getUseDeveloperSupport();
      }

//      @Override
//      protected ReactInstanceManager createReactInstanceManager() {
//        String url = "http://" + AndroidInfoHelpers.getServerHost() + "/" + bundleRoot + ".bundle?platform=android&dev=true&minify=false";
//        String cachedPath = "/data/user/0/com.simpleexample/files/" + bundleRoot + ".js";
//        ReactInstanceManager manager = reactNative50DefaultBuilder()
//                .setJSBundleLoader(JSBundleLoader.createCachedBundleFromNetworkLoader(url, cachedPath))
//                .build();
//
//        manager.getDevSupportManager().handleReloadJS();
//
//        return manager;
//      }

//      private ReactInstanceManagerBuilder reactNative50DefaultBuilder() {
//        ReactInstanceManagerBuilder builder = ReactInstanceManager.builder()
//                .setApplication(application)
//                .setJSMainModulePath(getJSMainModuleName())
//                .setUseDeveloperSupport(getUseDeveloperSupport())
//                .setRedBoxHandler(getRedBoxHandler())
//                .setJavaScriptExecutorFactory(getJavaScriptExecutorFactory())
//                .setUIImplementationProvider(getUIImplementationProvider())
//                .setInitialLifecycleState(LifecycleState.BEFORE_CREATE);
//
//        for (ReactPackage reactPackage : getPackages()) {
//          builder.addPackage(reactPackage);
//        }
//
//        String jsBundleFile = getJSBundleFile();
//        if (jsBundleFile != null) {
//          builder.setJSBundleFile(jsBundleFile);
//        } else {
//          builder.setBundleAssetName(Assertions.assertNotNull(getBundleAssetName()));
//        }
//        return builder;
//      }

      @Override
      protected List<ReactPackage> getPackages() {
        final ArrayList<ReactPackage> allPackages = new ArrayList<>(Arrays.asList(packages));
        allPackages.add(0, new WorkersPackage(packages));
        allPackages.add(0, new MainReactPackage());
        return allPackages;
      }

      @Override
      protected UIImplementationProvider getUIImplementationProvider() {
        return null;
      }
    };
  }

  /**
   * Public interface
   */

  @ThreadConfined(UI)
  public void start() {
    this.manager = this.host.getReactInstanceManager();
    this.manager.addReactInstanceEventListener(this);

    // HACK.
    // This forces react to actually load the worker code from the packager...
    // Without this, it never asks, and the worker code is never loaded/found.
    // It seems they have some hardcoded paths deep within their code, I can't
    // find a way to play nicely with what they are doing.
    host.getReactInstanceManager().getDevSupportManager().handleReloadJS();

    if (!this.manager.hasStartedCreatingInitialContext()) {
      this.manager.createReactContextInBackground();
    }

    this.parentContext.addLifecycleEventListener(this);
    this.onHostResume();
  }

  @ThreadConfined(UI)
  public void stop() {
    if (this.manager != null) {
      this.parentContext.removeLifecycleEventListener(this);
      this.onHostDestroy();
    }
  }

  public void postMessage(final String message) {
    WritableMap body = Arguments.createMap();
    body.putInt("key", this.key);
    body.putString("message", message);

    final ReactInstanceManager manager = Assertions.assertNotNull(this.manager);

    Assertions
      .assertNotNull(manager.getCurrentReactContext())
      .getNativeModule(WorkersInstanceManager.class)
      .emit("message", body);
  }

  /**
   * Event handlers
   */

  @Override
  public void onHostResume() {
    final ReactInstanceManager manager = Assertions.assertNotNull(this.manager);
    final Activity activity = this.parentContext.getCurrentActivity();

    new Handler(Looper.getMainLooper()).post(new Runnable() {
      @Override
      public void run() {
        manager.onHostResume(
          activity,
          null // No default back button implementation necessary.
        );
      }
    });
  }

  @Override
  public void onHostPause() {
    final ReactInstanceManager manager = Assertions.assertNotNull(this.manager);
    final Activity activity = this.parentContext.getCurrentActivity();

    new Handler(Looper.getMainLooper()).post(new Runnable() {
      @Override
      public void run() {
        manager.onHostPause(activity);
      }
    });
  }

  @Override
  @ThreadConfined(UI)
  public void onHostDestroy() {
    final ReactInstanceManager manager = Assertions.assertNotNull(this.manager);
    // Use `destroy` instead of `onHostDestroy` to force the destruction
    // of the underlying JSContext.
    manager.destroy();
  }

  @Override
  public void onReactContextInitialized(ReactContext context) {
    context
      .getNativeModule(WorkersInstanceManager.class)
      .initialize(this.key, this.parentContext, this.startedPromise);

    this.startedPromise = null;
  }

}
