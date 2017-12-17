#import <AVFoundation/AVFoundation.h>

@interface DownloadAndPlaySound : NSObject<AVAudioPlayerDelegate>
{
    NSString * tag;
    NSString * url;
    
    NSMutableDictionary * audioMap;
    NSMutableDictionary * audioFilenameMap;
    NSMutableDictionary * volumeMap;
}

- (double) daps_init:(char *)tag Arg2:(char *)url;
- (double) daps_audio_stop_sound:(char *)id_or_filename;
- (char *) daps_audio_play_sound:(char *)filename Arg2:(double)priority Arg3:(double)loop;
- (double) daps_audio_sound_pitch:(char *)id Arg2:(double)pitch;
- (double) daps_audio_is_playing:(char *)id_or_filename;
- (double) daps_audio_sound_gain:(char *)id_or_filename Arg2:(double)volume Arg3:(double)time;

@end
