package va.us.ass;

import android.os.Handler;
import android.os.Message;
import android.os.Looper;
import va.us.ass.Jii;


public class Hid extends Handler {
    public Hid() {
//        super(Looper.getMainLooper()); // 绑定到主线程的 Looper
    }

    @Override
    public void handleMessage(Message message) {
        int rr = message.what;
//        System.out.println("【libWave】handleMessage msg：" + rr);
        Jii.sdVV(rr);
    }
}

