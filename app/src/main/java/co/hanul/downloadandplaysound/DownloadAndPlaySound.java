package co.hanul.downloadandplaysound;

public interface DownloadAndPlaySound {
    void release();
    void pause();
    void resume();
    void setVolume(float volume);
}
