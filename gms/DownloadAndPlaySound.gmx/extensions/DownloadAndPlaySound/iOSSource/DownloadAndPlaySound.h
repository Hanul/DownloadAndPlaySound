#import <AVFoundation/AVFoundation.h>

@interface DownloadAndPlaySound : NSObject
{
}

- (double) daps_init:(char *)tag Arg2:(char *)url;
- (double) daps_audio_stop_sound:(char *)id_or_filename;
- (char *) daps_audio_play_sound:(char *)filename Arg2:(double)priority Arg3:(double)loop;
- (double) daps_audio_sound_pitch:(char *)id Arg2:(double)pitch;
- (double) daps_audio_is_playing:(char *)id_or_filename;

@end
