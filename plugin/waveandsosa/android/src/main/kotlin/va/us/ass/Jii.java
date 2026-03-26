package va.us.ass;

import androidx.annotation.Keep;
import java.util.Map;
import android.content.Context;

@Keep
public class Jii{

    static {
        try {
            System.loadLibrary("Waveand");
//            System.out.println("【libWave】load loadLibrary so");
        } catch (Exception e) {
            System.out.println("【libWave】load loadLibrary so error:" + e);
        }
    }

    @Keep
    public static native void dmsMia(Object context, int num);

    @Keep
    public static native void sdVV(int num);

}