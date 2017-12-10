package ${YYAndroidPackageName};

import android.content.Context;
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

    private String filename;

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
        this.filename = filename;

        folderPath = Environment.getExternalStorageDirectory() + "/" + tag + "/gamesound/";
        path = folderPath + filename;

        if (new File(path).exists() == true) {
            ready();
        }

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

    public String getFilename() {
        return filename;
    }

    public boolean isPlaying() {
        return mediaPlayer != null && mediaPlayer.isPlaying() == true;
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

    public boolean isReleased() {
        return mediaPlayer == null;
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

    public void setPitch(float pitch) {
        // ignore.
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
                        if (isCancelled() == true) {
                            input.close();
                            return null;
                        }
                        output.write(data, 0, count);
                    }
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
