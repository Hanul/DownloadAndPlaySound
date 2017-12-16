#import "DownloadAndPlaySound.h"

@implementation DownloadAndPlaySound

- (id) init
{
    tag = @"";
    url = @"";
    
    soundMap = [[NSMutableDictionary alloc] init];
    volumeMap = [[NSMutableDictionary alloc] init];
    
    // 음악 앱과 동시 재생되도록
    [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryAmbient error: nil];
    
    return self;
}

- (double) daps_init:(char *)tag Arg2:(char *)url
{
    self->tag = [[NSString stringWithUTF8String:tag] copy];
    self->url = [[NSString stringWithUTF8String:url] copy];
    return (double)-1;
}

- (double) daps_audio_stop_sound:(char *)id_or_filename
{
    if (soundMap[[NSString stringWithUTF8String:id_or_filename]] != nil) {
        [soundMap[[NSString stringWithUTF8String:id_or_filename]] stop];
        [soundMap[[NSString stringWithUTF8String:id_or_filename]] release];
        [soundMap removeObjectForKey:[NSString stringWithUTF8String:id_or_filename]];
    }
    
    return (double)-1;
}

- (char *) daps_audio_play_sound:(char *)filename Arg2:(double)priority Arg3:(double)loop
{
    if (soundMap[[NSString stringWithUTF8String:filename]] != nil) {
        AVAudioPlayer * player = soundMap[[NSString stringWithUTF8String:filename]];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            [player play];
        });
    }
    
    else {
        
        NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString * documentsDirectory = [paths objectAtIndex:0];
        NSString * folderPath = [NSString stringWithFormat:@"%@/%@", documentsDirectory, tag];
        NSString * filePath = [NSString stringWithFormat:@"%@/%@", folderPath, [NSString stringWithUTF8String:filename]];
        NSFileManager * fileManager = [NSFileManager defaultManager];
        
        // 폴더가 없으면 생성
        if ([fileManager fileExistsAtPath:folderPath] != YES) {
            [fileManager createDirectoryAtPath:folderPath withIntermediateDirectories:YES attributes:nil error:nil];
        }
        
        // 파일이 존재하지 않으면 다운로드
        if ([fileManager fileExistsAtPath:filePath] != YES) {
            NSData * data = [NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@/R/gamesound/mp3/%@.mp3", url, [NSString stringWithUTF8String:filename]]]];
            [data writeToFile:filePath atomically:YES];
        }
        
        NSURL * fileURL = [NSURL fileURLWithPath:filePath];
        AVAudioPlayer * player = [[AVAudioPlayer alloc] initWithContentsOfURL:fileURL error:nil];
        player.numberOfLoops = loop == 1 ? -1 : 0;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            [player play];
        });
        
        soundMap[[NSString stringWithUTF8String:filename]] = player;
        
        if (volumeMap[[NSString stringWithUTF8String:filename]] != nil) {
            [player setVolume:[volumeMap[[NSString stringWithUTF8String:filename]] floatValue]];
        }
    }
    
    return filename;
}

- (double) daps_audio_sound_pitch:(char *)id Arg2:(double)pitch
{
    return (double)-1;
}

- (double) daps_audio_is_playing:(char *)id_or_filename
{
    return soundMap[[NSString stringWithUTF8String:id_or_filename]] != nil && [soundMap[[NSString stringWithUTF8String:id_or_filename]] isPlaying] == YES;
}

- (double) daps_audio_sound_gain:(char *)id_or_filename Arg2:(double)volume Arg3:(double)time
{
    volumeMap[[NSString stringWithUTF8String:id_or_filename]] = [NSNumber numberWithDouble:volume];
    
    if (soundMap[[NSString stringWithUTF8String:id_or_filename]] != nil) {
        [soundMap[[NSString stringWithUTF8String:id_or_filename]] setVolume:(float) volume];
    }
    
    return (double)-1;
}

@end

