package ${YYAndroidPackageName};

import android.media.AudioManager;
import android.media.SoundPool;
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
import java.util.HashMap;
import java.util.Map;

public class DownloadAndPlaySoundSoundPool implements DownloadAndPlaySound {

    static private SoundPool soundPool = new SoundPool(32, AudioManager.STREAM_MUSIC, 0);
    static private Map<String, Integer> soundMap = new HashMap<String, Integer>();

    private URL url;
    private boolean isLoop;
    private float volume = 0;

    private String filename;

    private String folderPath;
    private String path;

    private int soundId;
    private Integer streamId;
    private boolean isReady;
    private boolean isReleased;

    private float pitch = 1;

    public DownloadAndPlaySoundSoundPool(String tag, String url, String filename, boolean isLoop) {

        try {
            this.url = new URL(url);
        } catch (MalformedURLException e) {
            e.printStackTrace();
        }
        this.filename = filename;
        this.isLoop = isLoop;

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
    }

    public String getFilename() {
        return filename;
    }

    public boolean isPlaying() {
        return true;
    }

    public void release() {
        if (isReady == true && streamId != null) {
            soundPool.stop(streamId);
        }
        isReleased = true;
    }

    public boolean isReleased() {
        return isReleased;
    }

    public void pause() {
        if (isReleased != true && streamId != null) {
            soundPool.pause(streamId);
        }
    }

    public void resume() {
        if (isReleased != true && streamId != null) {
            soundPool.resume(streamId);
        }
    }

    public void setPitch(float pitch) {
        this.pitch = pitch;
        if (isReady == true && streamId != null) {
            soundPool.setRate(streamId, pitch);
        }
    }
    
    public void setVolume(float volume) {
        this.volume = volume;
        if (isReady == true && streamId != null) {
            soundPool.setVolume(streamId, volume, volume);
        }
    }

    private void ready() {
        isReady = true;

        if (soundMap.get(path) == null) {
            
            soundId = soundPool.load(path, 1);
            soundMap.put(path, soundId);

            soundPool.setOnLoadCompleteListener(new SoundPool.OnLoadCompleteListener() {

                @Override
                public void onLoadComplete(SoundPool _soundPool, int i, int i1) {

                	new Thread(new Runnable() {

						@Override
						public void run() {
		                    if (isReleased != true) {
		                        streamId = soundPool.play(soundId, volume, volume, 0, isLoop == true ? -1 : 0, pitch);
		                    }
						}
					}).start();
                }
            });
        }

        else {
            soundId = soundMap.get(path);

        	new Thread(new Runnable() {

				@Override
				public void run() {
                    if (isReleased != true) {
                        streamId = soundPool.play(soundId, volume, volume, 0, isLoop == true ? -1 : 0, pitch);
                    }
				}
			}).start();
        }
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
