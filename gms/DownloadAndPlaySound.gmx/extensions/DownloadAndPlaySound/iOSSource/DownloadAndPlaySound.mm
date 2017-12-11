#import "DownloadAndPlaySound.h"

@implementation DownloadAndPlaySound

- (double) native_check_is_other_audio_playing
{
    return (double)-1;
}

- (double) daps_init:(char *)tag Arg2:(char *)url
{
    return (double)-1;
}

- (double) daps_audio_stop_sound:(char *)id_or_filename
{
    return (double)-1;
}

- (char *) daps_audio_play_sound:(char *)filename Arg2:(double)priority Arg3:(double)loop
{
    return nil;
}

- (double) daps_audio_sound_pitch:(char *)id Arg2:(double)pitch
{
    return (double)-1;
}

- (double) daps_audio_is_playing:(char *)id_or_filename
{
    return (double)-1;
}

@end
