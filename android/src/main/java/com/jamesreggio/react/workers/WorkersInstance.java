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
import com.facebook.react.ReactNativeHost;
import com.facebook.react.ReactPackage;
import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.LifecycleEventListener;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContext;
import com.facebook.react.bridge.WritableMap;
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
        return false;
      }

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
