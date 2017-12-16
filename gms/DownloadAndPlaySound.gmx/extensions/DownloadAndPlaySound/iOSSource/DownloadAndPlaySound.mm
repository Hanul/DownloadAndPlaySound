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
        // release가 자동으로 됨
        [soundMap removeObjectForKey:[NSString stringWithUTF8String:id_or_filename]];
    }

    return (double)-1;
}

- (char *) daps_audio_play_sound:(char *)filename Arg2:(double)priority Arg3:(double)loop
{
    NSString * id = [NSString stringWithUTF8String:filename];
    
    // 이미 존재하는 사운드면 재생
    if (soundMap[id] != nil) {
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
        dispatch_async(queue, ^{
            AVAudioPlayer * player = soundMap[id];
            if (player != nil && [player isPlaying] == NO) {
                [player play];
            }
        });
        dispatch_release(queue);
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
        
        // 플레이어 생성
        NSURL * fileURL = [NSURL fileURLWithPath:filePath];
        AVAudioPlayer * player = [[AVAudioPlayer alloc] initWithContentsOfURL:fileURL error:nil];
        if (volumeMap[id] != nil) {
            [player setVolume:[volumeMap[id] floatValue]];
        }
        if (loop == 1) {
            player.numberOfLoops = -1;
        }
        soundMap[id] = player;
        
        // 사운드 재생
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
        dispatch_async(queue, ^{
            AVAudioPlayer * player = soundMap[id];
            if (player != nil && [player isPlaying] == NO) {
                [player play];
            }
        });
        dispatch_release(queue);
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
    if (volumeMap[[NSString stringWithUTF8String:id_or_filename]] != nil) {
        // release가 자동으로 됨
        [volumeMap removeObjectForKey:[NSString stringWithUTF8String:id_or_filename]];
    }
    volumeMap[[NSString stringWithUTF8String:id_or_filename]] = [[NSNumber numberWithDouble:volume] copy];
    
    if (soundMap[[NSString stringWithUTF8String:id_or_filename]] != nil) {
        [soundMap[[NSString stringWithUTF8String:id_or_filename]] setVolume:(float) volume];
    }
    
    return (double)-1;
}

@end

