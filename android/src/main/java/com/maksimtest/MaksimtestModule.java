package com.maksimtest;

import androidx.annotation.NonNull;
import android.util.Log;

import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.WritableArray;
import com.facebook.react.bridge.WritableNativeArray;
import com.facebook.react.module.annotations.ReactModule;

import java.util.Arrays;


@ReactModule(name = MaksimtestModule.NAME)
public class MaksimtestModule extends ReactContextBaseJavaModule {

  public static final String NAME = "Maksimtest";

  public MaksimtestModule(ReactApplicationContext reactContext) {
    super(reactContext);
  }

  @Override
  @NonNull
  public String getName() {
    return NAME;
  }

  @ReactMethod
  public void getPeaks(String path, Promise promise) {
    String uri = "https://maksimsea.ru/nw2.mp3";
    WaveformExtractor waveformExtractor = new WaveformExtractor(path, null, 12, 6);
    Log.e("XSXGOT","this is ----- inPath = + "+waveformExtractor.inPath+" ///// ");

    WritableArray array = new WritableNativeArray();
    //array.pushArray({waveformExtractor.listMax, waveformExtractor.listMax});
    promise.resolve(waveformExtractor.listOb);
  }







}
