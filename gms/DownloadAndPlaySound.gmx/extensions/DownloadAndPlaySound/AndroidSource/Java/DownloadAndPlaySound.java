package ${YYAndroidPackageName};

public interface DownloadAndPlaySound {
    String getFilename();
    void release();
    void pause();
    void resume();
    boolean isReleased();
    boolean isPlaying();
    void setPitch(float pitch);
    void setVolume(float volume);
}
