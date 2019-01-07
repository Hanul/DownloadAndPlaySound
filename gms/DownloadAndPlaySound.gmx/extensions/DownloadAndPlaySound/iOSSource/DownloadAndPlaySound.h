#import <AVFoundation/AVFoundation.h>

@interface DownloadAndPlaySound : NSObject<AVAudioPlayerDelegate>
{
    NSString * tag;
    NSString * url;
    
    NSMutableDictionary * audioMap;
    NSMutableDictionary * volumeMap;
}

- (double) native_daps_init:(char *)tag Arg2:(char *)url;
- (char *) native_daps_create_uuid;
- (double) native_daps_ready_audio:(char *)filename;
- (char *) native_daps_audio_play_sound:(char *)filename Arg2:(double)loop;
- (double) native_daps_audio_stop_sound:(char *)id;
- (double) native_daps_audio_sound_pitch:(char *)id Arg2:(double)pitch;
- (double) native_daps_audio_is_playing:(char *)id;
- (double) native_daps_audio_sound_gain:(char *)id Arg2:(double)volume;

@end
