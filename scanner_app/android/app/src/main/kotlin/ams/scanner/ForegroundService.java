package ams.scanner;

import static io.flutter.embedding.android.KeyData.CHANNEL;
import androidx.annotation.Nullable;
import io.flutter.plugin.common.MethodChannel;
import android.app.Notification;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.Service;
import android.content.Context;
import android.content.Intent;
import android.os.Build;
import android.os.Handler;
import android.os.IBinder;
import android.util.Log;
import android.view.Gravity;
import android.widget.Toast;
import com.common.sdk.emv.PinpadEnum;
import com.common.sdk.emv.PinpadService;
import com.example.main.R;
import com.telpo.emv.EmvAmountData;
import com.telpo.emv.EmvCandidateApp;
import com.telpo.emv.EmvOnlineData;
import com.telpo.emv.EmvPinData;
import com.telpo.emv.EmvService;
import com.telpo.emv.EmvServiceListener;
import com.telpo.emv.EmvTLV;
import com.telpo.util.DefaultAPPCAPK;
import com.telpo.util.ErrMsg;
import java.io.UnsupportedEncodingException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.concurrent.locks.ReentrantLock;

public class ForegroundService extends Service {
    private final String TAG = "ForegroundService.java";
    private final String CHANNEL_ID = "NUSTAR Merchant App";
    public com.common.sdk.emv.PinpadService pinpadService;
    private NotificationChannel channel = null;
    private Notification.Builder notification = null;
    private String magStripeCardValue = null;
    private MainActivity main = new MainActivity();

    private static int BOTTOM = 80;
    private static int TOP = 48;
    private static int CENTER = 17;
    public ReentrantLock ThreadLock = new ReentrantLock();
    public ReentrantLock MerchantThreadLock = new ReentrantLock();
    public int _LastCode = 0;
    public String currentKSN = "";
    public boolean stopDetect = false;
    public boolean stopThread = false;
    public boolean earnStopDetect = false;
    public boolean earnStopThread = false;
    public Context context;
    public EmvService emvService;
    public int selectAPPResult = 0;
    public boolean isDevInit = false;
    public boolean UIThreadisRunning = true;
    public String pinBlock = "";
    public String cardNum = "";
    public String Track1 = null;
    public String Track2 = null;
    public boolean isMag = false;
    public boolean isNoErr = true;

    EmvServiceListener MyListener = new EmvServiceListener() {
        @Override
        public int onInputAmount(EmvAmountData emvAmountData) {
            emvAmountData.TransCurrCode = 156;
            emvAmountData.ReferCurrCode = 156;
            emvAmountData.TransCurrExp = 2;
            emvAmountData.ReferCurrExp = 2;
            emvAmountData.ReferCurrCon = 1;
            emvAmountData.CashbackAmount = 0;
            return EmvService.EMV_TRUE;
        }

        @Override
        public int onInputPin(EmvPinData emvPinData) {
            int result =0;

            if (emvPinData.type != EmvService.ONLIEN_ENCIPHER_PIN) {
                Log.i(TAG, "offline PIN! EMV Processing...");
                return EmvService.EMV_TRUE;
            }

            if (_LastCode == PinpadService.PIN_ERROR_TIMEOUT) {
                result = EmvService.ERR_TIMEOUT;
            }
            else if (_LastCode == PinpadService.PIN_ERROR_CANCEL){
                result = EmvService.ERR_USERCANCEL;
            } else if (_LastCode == PinpadService.PIN_ERROR_NOKEY) {
                result = EmvService.ERR_NOPIN;

            } else if (_LastCode == PinpadService.PIN_OK) {
                result = EmvService.EMV_TRUE;
            } else {
                Log.e(TAG, "Get PIN Error: " + ErrMsg.GetPinPadErrMsg(result));
                return result;
            }
            return result;
        }

        @Override
        public int onSelectApp(EmvCandidateApp[] emvCandidateApps) {
            final EmvCandidateApp[] mAppList = emvCandidateApps;
            int appListLen = emvCandidateApps.length;
            selectAPPResult = 0;
            final String[] items = new String[appListLen];
            for (int i = 0; i < appListLen; i++) {
                items[i] = emvCandidateApps[i].appName;
            }
            new Handler(context.getMainLooper()).post(() -> {
                android.app.AlertDialog.Builder builder = new android.app.AlertDialog.Builder(context)
                        .setTitle("Please Select App")
                        .setCancelable(false)
                        .setSingleChoiceItems(items, 0, (dialog, which) -> {
                            showLog("callback [onSelectApp] You Select \"" + items[which]);
                            selectAPPResult = mAppList[which].index;
                        })
                        .setPositiveButton("OK", (dialog, which) -> UIThreadisRunning = false)
                        .setNegativeButton("Cancel", (dialog, which) -> selectAPPResult = EmvService.ERR_USERCANCEL);
                builder.create().show();
            });
            return selectAPPResult;
        }

        @Override
        public int onSelectAppFail(int i) {
            return EmvService.EMV_TRUE;
        }

        @Override
        public int onFinishReadAppData() {
            int ret = 0;
            EmvTLV tlv = new EmvTLV(0x9F06);
            emvService.Emv_GetTLV(tlv);
            showLog("AID:"+ com.telpo.util.StringUtil.bytesToHexString(tlv.Value));
            tlv = new EmvTLV(0x5A);
            ret = emvService.Emv_GetTLV(tlv);
            if (EmvService.EMV_TRUE == ret) {
                showLog("0x5A:"+ com.telpo.util.StringUtil.bytesToHexString(tlv.Value));
            } else {
                tlv = new EmvTLV(0x57);
                ret = emvService.Emv_GetTLV(tlv);
                if (EmvService.EMV_TRUE == ret) {
                    showLog("0x57:" + com.telpo.util.StringUtil.bytesToHexString(tlv.Value));
                } else {
                    showLog("Get cardNum Fail");
                }
            }
            return EmvService.EMV_TRUE;
        }

        @Override
        public int onVerifyCert() {
            return EmvService.EMV_TRUE;
        }

        @Override
        public int onOnlineProcess(EmvOnlineData emvOnlineData) {
            if (null == emvOnlineData) {
                return EmvService.ONLINE_FAILED;
            }
            if (pay()) {
                emvOnlineData.ResponeCode = "00".getBytes();
                return EmvService.ONLINE_APPROVE;
            } else {
                return EmvService.ONLINE_FAILED;
            }
        }

        @Override
        public int onRequireTagValue(int i, int i1, byte[] bytes) {
            return 0;
        }

        @Override
        public int onRequireDatetime(byte[] bytes) {
            SimpleDateFormat formatter = new SimpleDateFormat("yyyyMMddHHmmss");
            Date curDate = new Date(System.currentTimeMillis());
            String str = formatter.format(curDate);
            byte[] time = new byte[0];
            try {
                time = str.getBytes("ascii");
                System.arraycopy(time, 0, bytes, 0, bytes.length);
                return EmvService.EMV_TRUE;
            } catch (UnsupportedEncodingException e) {
                e.printStackTrace();
                showLog("onRequireDatetime failed");
                return EmvService.EMV_FALSE;
            }
        }

        @Override
        public int onReferProc() {
            return EmvService.EMV_TRUE;
        }

        @Override
        public int OnCheckException(String s) {
            return EmvService.EMV_FALSE;
        }

        @Override
        public int OnCheckException_qvsdc(int i, String s) {
            return EmvService.EMV_FALSE;
        }
    };

    /// --- WISEASY --- ///
    /* public Core systemCore;
    private BankCard magneticCard; */

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        initDev();
        checkSignalFromApp();

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            channel = new NotificationChannel(
                    CHANNEL_ID,
                    CHANNEL_ID,
                    NotificationManager.IMPORTANCE_LOW
            );
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            getSystemService(NotificationManager.class).createNotificationChannel(channel);
        }

        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.O) {
            notification = new Notification.Builder(this, CHANNEL_ID)
                    .setContentText(getString(R.string.notification_message))
                    .setSmallIcon(R.mipmap.ic_launcher);
        }

        startForeground(1001, notification.build());

        return super.onStartCommand(intent, flags, startId);

        /* // WISEASSY PRINT AND MAGSTRIPE INIT
            new Thread(() -> {
                magneticCard = new BankCard(getApplicationContext());
                systemCore = new Core(getApplicationContext());
                while (true) {
                    wiseasyMagneticStripeReader();
                    try {
                        //Log.e(TAG, getString(R.string.foreground_service_message));
                        Thread.sleep(1000);
                    } catch (InterruptedException e) {
                        e.printStackTrace();
                    }
                }
            }).start();
        */
    }

    @Nullable @Override
    public IBinder onBind(Intent intent) {
        return null;
    }

    private void merchantStripeDetect() {
        MerchantThread earn = new MerchantThread();
        Thread thread = new Thread(earn);
        thread.start();
    }

    public class MerchantThread implements Runnable {
        @Override
        public void run() {
            if (!earnStopThread) {
                if (magStripeCardValue == null) {
                    MerchantThreadLock.lock();
                }
                resetData();
            } else {
                MerchantThreadLock.unlock();
            }
            try {
                EmvService.MagStripeCloseReader();
                _LastCode = EmvService.MagStripeOpenReader();
                if (EmvService.EMV_DEVICE_TRUE == _LastCode) {
                    while (!earnStopDetect) {
                        if (EmvService.MagStripeCheckCard(1000) == EmvService.EMV_DEVICE_TRUE) {
                            magStripeCardValue = EmvService.MagStripeReadStripeData(2);
                        }
                        Thread.sleep(3000);
                    }
                    EmvService.MagStripeCloseReader();
                }
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
        }
    };

    private void initDev() {
        context = this;
        emvService = EmvService.getInstance();
        emvService.setListener(MyListener);
        if (EmvService.EMV_TRUE != (_LastCode = emvService.Open(context))) {
            showLog("EmvService.Open Fail:\" + _LastCode");
            return;
        }
        if (EmvService.EMV_DEVICE_TRUE != (_LastCode = emvService.deviceOpen())) {
            showLog("EmvService.deviceOpen Fail: " + _LastCode);
            return;
        }
        emvService.Emv_RemoveAllApp();
        emvService.Emv_RemoveAllCapk();
        DefaultAPPCAPK.Add_All_APP(emvService);
        DefaultAPPCAPK.Add_Default_APP(emvService);
        DefaultAPPCAPK.Add_Amex_AID(emvService);
        DefaultAPPCAPK.Add_Mir_AID(emvService);
        DefaultAPPCAPK.Add_Rupay_AID(emvService);
        DefaultAPPCAPK.Add_QTransit_AID(emvService);
        DefaultAPPCAPK.Add_All_CAPK(emvService);
        DefaultAPPCAPK.Add_All_CAPK_Test(emvService);
        DefaultAPPCAPK.Add_Default_CAPK(emvService);
        DefaultAPPCAPK.Add_Amex_Capk(emvService);
        DefaultAPPCAPK.Add_Mir_Capk(emvService);
        DefaultAPPCAPK.Add_Rupay_Capk(emvService);
        DefaultAPPCAPK.Add_QTransit_Capk(emvService);
        _LastCode = InitPinPad();
        if (PinpadService.PIN_OK != _LastCode) {
            showLog("InitPinPad Fail:"+_LastCode);
            return;
        }
        _LastCode = WriteKey();
        if (PinpadService.PIN_OK != _LastCode) {
            showLog("WriteKey Fail:"+_LastCode);
            return;
        }
        isDevInit = true;
    }

    private int saveMasterKey(byte[] masterKey) {
        return pinpadService.Pinpad_Write_Normal_Key(0,
                PinpadEnum.ENUM_WRITE_MODE.KEY_WRITE_DIRECT,
                0,
                PinpadEnum.PINPAD_NOR_KEY_TYPE.PINKEY_MASTER,
                masterKey
        );
    }

    public int WriteKey() {
        byte[] MasterKey = new byte[]{0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11};
        _LastCode = saveMasterKey(MasterKey);
        if (PinpadService.PIN_OK != _LastCode) {
            return _LastCode;
        }
        return _LastCode;
    }

    public void showLog(String Mes) {
        Log.e(TAG, Mes);
    }

    public void showToast(String message, int position) {
        Toast ts = Toast.makeText(this, message, Toast.LENGTH_SHORT);
        ts.setGravity(position | Gravity.CENTER_HORIZONTAL, 0, 0);
        ts.show();
    }

    public boolean pay() {
        return true;
    }

    public int InitPinPad() {
        pinpadService = new com.common.sdk.emv.PinpadService(context);
        return pinpadService.Pinpad_Open(context);
    }

    public void resetData() {
        currentKSN = "";
        pinBlock = "";
        cardNum = "";
        Track1 = "";
        Track2 = "";
        isMag = false;
        isNoErr = true;
        earnStopDetect = false;
    }

    private void checkSignalFromApp() {
        new MethodChannel(main.getForegroundService(), CHANNEL).setMethodCallHandler((call, result) -> {
            if (call.method.equals(getString(R.string.merchant_mag_stripe_clear_data))) {
                earnStopThread = true;
                earnStopDetect = true;
                magStripeCardValue = "";
            }
            if (call.method.equals(getString(R.string.merchant_stripe_swipe_card))) {
                earnStopThread = false;
                earnStopDetect = false;
                merchantStripeDetect();
                if (magStripeCardValue != null && magStripeCardValue != "") {
                    result.success(magStripeCardValue);
                }
            }
        });
    }

}