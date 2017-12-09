package ${YYAndroidPackageName};

import android.os.AsyncTask;

import org.json.JSONException;
import org.json.JSONObject;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.OutputStreamWriter;
import java.io.PrintWriter;
import java.net.ConnectException;
import java.net.Socket;
import java.net.SocketException;
import java.net.UnknownHostException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Iterator;
import java.util.UUID;

import com.yoyogames.runner.RunnerJNILib;

import android.content.Intent;
import android.content.res.Configuration;
import android.view.KeyEvent;
import android.view.Menu;
import android.view.MenuItem;
import android.app.Dialog;
import android.view.MotionEvent;

public class DownloadAndPlaySoundExt implements IExtensionBase {

	private Map<String, DownloadAndPlaySound> soundMap = new HashMap<String, DownloadAndPlaySound>();

	public double daps_audio_stop_sound(String id_or_filename) {
		
		// id
		if (soundMap.get(id_or_filename) != null) {
			soundMap.get(id_or_filename).release();
			soundMap.remove(id_or_filename);
		}

		// filename
		else {
			Iterator<Map.Entry<String, DownloadAndPlaySound>> iter = soundMap.entrySet().iterator();
			while (iter.hasNext()) {
				Map.Entry<String, DownloadAndPlaySound> entry = iter.next();
				if (entry.getValue().filename.equals(id_or_filename + ".ogg") == true) {
					entry.getValue().release();
				}

				if (entry.getValue().isReleased() == true) {
					soundMap.remove(entry.getKey());
				}
			}
		}

		return -1;
	}

	public String daps_audio_play_sound(String filename, double priority, double loop) {
		String id = UUID.randomUUID().toString();
		soundMap.put(id, new DownloadAndPlaySound("__GMS_PROJECT", "http://cwserver3.btncafe.com:8523/R/gamesound/" + filename + ".ogg", filename + ".ogg"));
		return id;
	}

	public double daps_audio_sound_pitch(String id, double pitch) {
		return -1;
	}

	public double daps_audio_is_playing(String id_or_filename) {

		boolean isPlaying = false;

		// id
		if (soundMap.get(id_or_filename) != null) {
			if (soundMap.get(id_or_filename).isPlaying() == true) {
				isPlaying = true;
			}
		}

		// filename
		else {
			Iterator<Map.Entry<String, DownloadAndPlaySound>> iter = soundMap.entrySet().iterator();
			while (iter.hasNext()) {
				Map.Entry<String, DownloadAndPlaySound> entry = iter.next();
				if (entry.getValue().filename.equals(id_or_filename + ".ogg") == true && entry.getValue().isPlaying() == true) {
					isPlaying = true;
				}
			}
		}

		return isPlaying == true ? 1 : 0;
	}

	public double daps_audio_sound_gain(String id, double volume, double time) {
		return -1;
	}

	// Interface implements
	public void onStart() {}

	public void onRestart() {}

	public void onStop() {}

	public void onDestroy() {}

	public void onPause() {
		Iterator<Map.Entry<String, DownloadAndPlaySound>> iter = soundMap.entrySet().iterator();
		while (iter.hasNext()) {
			Map.Entry<String, DownloadAndPlaySound> entry = iter.next();
			if (entry.getValue().isReleased() == true) {
				soundMap.remove(entry.getKey());
			} else {
				entry.getValue().pause();
			}
		}
	}

	public void onResume() {
		Iterator<Map.Entry<String, DownloadAndPlaySound>> iter = soundMap.entrySet().iterator();
		while (iter.hasNext()) {
			Map.Entry<String, DownloadAndPlaySound> entry = iter.next();
			if (entry.getValue().isReleased() == true) {
				soundMap.remove(entry.getKey());
			} else {
				entry.getValue().resume();
			}
		}
	}

	public void onConfigurationChanged(Configuration newConfig) {}

	public void onRequestPermissionsResult(int requestCode, String permissions[], int[] grantResults) {}

	public void onActivityResult(int requestCode, int resultCode, Intent data) {}

	public boolean onKeyDown(int keyCode, KeyEvent event) {
		return false;
	}

	public boolean onKeyUp(int keyCode, KeyEvent event) {
		return false;
	}

	public boolean onKeyLongPress(int keyCode, KeyEvent event) {
		return false;
	}

	public boolean onTouchEvent(final MotionEvent event) {
		return false;
	}

	public void onWindowFocusChanged(boolean hasFocus) {}

	public boolean onCreateOptionsMenu(Menu menu) {
		return false;
	}

	public boolean onOptionsItemSelected(MenuItem item) {
		return false;
	}

	public Dialog onCreateDialog(int id) {
		return null;
	}

	public boolean onGenericMotionEvent(MotionEvent event) {
		return false;
	}

	public boolean dispatchGenericMotionEvent(MotionEvent event) {
		return false;
	}

	public boolean dispatchKeyEvent(KeyEvent event) {
		return false;
	}
}
