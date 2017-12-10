package co.hanul.downloadandplaysound;

import android.app.Activity;
import android.os.Bundle;
import android.view.View;

public class MainActivity extends Activity {

    private DownloadAndPlaySoundSoundPool downloadAndPlaySound;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        findViewById(R.id.play_button).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                //downloadAndPlaySound = new DownloadAndPlaySoundMediaPlayer("DownloadAndPlaySoundTest7", "http://cwserver3.btncafe.com:8523/R/gamesound/test", "bgm_home.ogg");
                downloadAndPlaySound = new DownloadAndPlaySoundSoundPool("DownloadAndPlaySoundTest6", "http://cwserver3.btncafe.com:8523/R/gamesound/bgm_home.ogg", "bgm_home.ogg");
            }
        });

        findViewById(R.id.stop_button).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                downloadAndPlaySound.release();
            }
        });
    }

    @Override
    protected void onPause() {
        super.onPause();

        if (downloadAndPlaySound != null) {
            downloadAndPlaySound.pause();
        }
    }

    @Override
    protected void onResume() {
        super.onResume();

        if (downloadAndPlaySound != null) {
            downloadAndPlaySound.resume();
        }
    }
}
