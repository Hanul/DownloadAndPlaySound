package co.hanul.downloadandplaysound;

import android.media.MediaPlayer;
import android.os.AsyncTask;
import android.os.Environment;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.MalformedURLException;
import java.net.URL;

public class DownloadAndPlaySoundMediaPlayer implements DownloadAndPlaySound {

    private URL url;

    private String folderPath;
    private String path;

    private boolean isReady;
    private MediaPlayer mediaPlayer = new MediaPlayer();
    private int currentPosition;

    public DownloadAndPlaySoundMediaPlayer(String tag, String url, String filename, boolean isLoop) {

        try {
            this.url = new URL(url);
        } catch (MalformedURLException e) {
            e.printStackTrace();
        }

        folderPath = Environment.getExternalStorageDirectory() + "/" + tag + "/gamesound/";
        path = folderPath + filename;

        // 이미 파일이 존재하면 즉시 준비 완료
        if (new File(path).exists() == true) {
            ready();
        }

        // 아니면 다운로드 시작
        else {
            File folder = new File(folderPath);
            if (folder.exists() != true) {
                folder.mkdirs();
            }
            new DownloadTask().execute();
        }

        mediaPlayer.setLooping(isLoop);
        mediaPlayer.setOnCompletionListener(new MediaPlayer.OnCompletionListener() {
            @Override
            public void onCompletion(MediaPlayer mediaPlayer) {
                release();
            }
        });
    }

    public void release() {

        if (mediaPlayer != null) {

            if (mediaPlayer.isPlaying() == true) {
                mediaPlayer.stop();
            }

            mediaPlayer.release();
            mediaPlayer = null;
        }
    }

    public void pause() {
        if (mediaPlayer != null && isReady == true) {
            mediaPlayer.pause();
            currentPosition = mediaPlayer.getCurrentPosition();
        }
    }

    public void resume() {
        if (mediaPlayer != null && isReady == true) {
            mediaPlayer.seekTo(currentPosition);
            mediaPlayer.start();
        }
    }

    public void setVolume(float volume) {
        mediaPlayer.setVolume(volume, volume);
    }

    private void ready() {
        isReady = true;

        try {
            mediaPlayer.setDataSource(path);
            mediaPlayer.prepare();
        } catch (IOException e) {
            e.printStackTrace();
        }

        mediaPlayer.start();
    }

    private class DownloadTask extends AsyncTask<String, Integer, String> {

        @Override
        protected String doInBackground(String... notUsing) {
            InputStream input = null;
            OutputStream output = null;
            HttpURLConnection connection = null;
            try {
                connection = (HttpURLConnection) url.openConnection();
                connection.connect();

                if (connection.getResponseCode() == HttpURLConnection.HTTP_OK) {

                    input = connection.getInputStream();
                    output = new FileOutputStream(path);

                    byte data[] = new byte[4096];
                    int count;
                    while ((count = input.read(data)) != -1) {
                        // Task가 중단되면 끝
                        if (isCancelled() == true) {
                            input.close();
                            return null;
                        }
                        output.write(data, 0, count);
                    }
                    // 다운로드가 끝나면 준비 완료
                    ready();
                }
            } catch (Exception e) {
                e.printStackTrace();
            } finally {
                try {
                    if (output != null) {
                        output.close();
                    }
                    if (input != null) {
                        input.close();
                    }
                } catch (IOException e) {
                    e.printStackTrace();
                }

                if (connection != null) {
                    connection.disconnect();
                }
            }
            return null;
        }
    }
}
