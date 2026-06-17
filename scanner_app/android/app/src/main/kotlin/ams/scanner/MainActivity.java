package ams.scanner;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.BinaryMessenger;
import android.app.ActivityManager;
import android.content.Context;
import android.content.Intent;
import android.os.Build;
import android.os.Bundle;

import androidx.annotation.NonNull;
//import com.google.firebase.FirebaseApp;
//import com.google.firebase.appdistribution.FirebaseAppDistribution;
//import com.google.firebase.appdistribution.FirebaseAppDistributionException;

import io.flutter.plugins.GeneratedPluginRegistrant;

public class MainActivity extends FlutterActivity {
    public static BinaryMessenger binaryMessenger;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
    }

    @Override
    public void onBackPressed() {
        return;
    }

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine);
        binaryMessenger = getFlutterEngine().getDartExecutor().getBinaryMessenger();
    }

    @Override
    protected void onStart() {
        super.onStart();
    }

    @Override
    protected void onResume() {
        super.onResume();
    }

    @Override
    protected void onDestroy() {
        binaryMessenger = null;
        stopService(new Intent(this, ForegroundService.class));
        new ForegroundService().resetData();
        new ForegroundService().stopSelf();
        super.onDestroy();
    }

    @Override
    protected void onPause() {
        stopService(new Intent(this, ForegroundService.class));
        new ForegroundService().stopSelf();
        super.onPause();
    }

    public static BinaryMessenger getForegroundService() {
        return binaryMessenger;
    }

}