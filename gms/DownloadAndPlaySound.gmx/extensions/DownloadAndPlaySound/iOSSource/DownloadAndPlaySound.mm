#import "DownloadAndPlaySound.h"

@implementation DownloadAndPlaySound

- (id) init
{
    // 음악 앱과 동시 재생되도록
    [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryAmbient error: nil];
    
    tag = @"";
    url = @"";
    
    audioMap = [[NSMutableDictionary alloc] init];
    audioFilenameMap = [[NSMutableDictionary alloc] init];
    volumeMap = [[NSMutableDictionary alloc] init];
    
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
    // id
    if (audioMap[[NSString stringWithUTF8String:id_or_filename]] != nil) {
        [audioMap[[NSString stringWithUTF8String:id_or_filename]] stop];
        // release가 자동으로 됨
        [audioMap removeObjectForKey:[NSString stringWithUTF8String:id_or_filename]];
        [audioFilenameMap removeObjectForKey:[NSString stringWithUTF8String:id_or_filename]];
    }
    
    // filename
    else {
        for (NSString * id in [audioMap allKeys]) {
            if ([audioFilenameMap[id] isEqualToString:[NSString stringWithUTF8String:id_or_filename]]) {
                [audioMap[id] stop];
                // release가 자동으로 됨
                [audioMap removeObjectForKey:id];
                [audioFilenameMap removeObjectForKey:id];
            }
        }
    }

    return (double)-1;
}

- (char *) daps_audio_play_sound:(char *)filename Arg2:(double)priority Arg3:(double)loop
{
    NSString * id = [[NSUUID UUID] UUIDString];
    
    NSString * filenameStr = [NSString stringWithUTF8String:filename];
    
    NSString * folderPath = [NSString stringWithFormat:@"%@/%@", [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0], tag];
    NSString * filePath = [NSString stringWithFormat:@"%@/%@", folderPath, [NSString stringWithUTF8String:filename]];
    NSURL * fileURL = [NSURL fileURLWithPath:filePath];
    
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
    
    // 배경 음악
    if ([[filenameStr substringToIndex:4] isEqualToString:@"bgm_"]) {
        
        // 플레이어 생성
        AVAudioPlayer * player = [[AVAudioPlayer alloc] initWithContentsOfURL:fileURL error:nil];
        player.numberOfLoops = loop == 1 ? -1 : 0;
        player.delegate = self;
        [player play];
        
        // 볼륨 설정
        if (volumeMap[[NSString stringWithUTF8String:filename]] != nil) {
            [player setVolume:[volumeMap[[NSString stringWithUTF8String:filename]] floatValue]];
        }
        
        audioMap[id] = player;
        audioFilenameMap[id] = filenameStr;
    }
    
    // 효과음
    else if (volumeMap[[NSString stringWithUTF8String:filename]] == nil || [volumeMap[[NSString stringWithUTF8String:filename]] doubleValue] > 0) {
        
        SystemSoundID soundId;
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)fileURL, &soundId);
        AudioServicesPlaySystemSoundWithCompletion(soundId, ^{
            AudioServicesRemoveSystemSoundCompletion(soundId);
            AudioServicesDisposeSystemSoundID(soundId);
        });
    }
    
    return (char *)[id UTF8String];
}

- (double) daps_audio_sound_pitch:(char *)id Arg2:(double)pitch
{
    return (double)-1;
}

- (double) daps_audio_is_playing:(char *)id_or_filename
{
    bool isPlaying = NO;
    
    // id
    if (audioMap[[NSString stringWithUTF8String:id_or_filename]] != nil) {
        if ([audioMap[[NSString stringWithUTF8String:id_or_filename]] isPlaying] == YES) {
            isPlaying = YES;
        }
    }
    
    // filename
    else {
        for (NSString * id in [audioMap allKeys]) {
            if ([audioFilenameMap[id] isEqualToString:[NSString stringWithUTF8String:id_or_filename]] && [audioMap[id] isPlaying] == YES) {
                isPlaying = YES;
            }
        }
    }
    
    return isPlaying;
}

- (double) daps_audio_sound_gain:(char *)id_or_filename Arg2:(double)volume Arg3:(double)time
{
    if (volumeMap[[NSString stringWithUTF8String:id_or_filename]] != nil) {
        // release가 자동으로 됨
        [volumeMap removeObjectForKey:[NSString stringWithUTF8String:id_or_filename]];
    }
    volumeMap[[NSString stringWithUTF8String:id_or_filename]] = [NSNumber numberWithDouble:volume];
    
    // id
    if (audioMap[[NSString stringWithUTF8String:id_or_filename]] != nil) {
        [audioMap[[NSString stringWithUTF8String:id_or_filename]] setVolume:(float) volume];
    }
    
    // filename
    else {
        for (NSString * id in [audioMap allKeys]) {
            if ([audioFilenameMap[id] isEqualToString:[NSString stringWithUTF8String:id_or_filename]]) {
                [audioMap[id] setVolume:(float) volume];
            }
        }
    }
    
    return (double)-1;
}

// 재생이 끝나면 자동 삭제
- (void) audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    NSArray * allKeys = [audioMap allKeysForObject:player];
    for (NSString * id in allKeys) {
        [audioMap[id] stop];
        // release가 자동으로 됨
        [audioMap removeObjectForKey:id];
        [audioFilenameMap removeObjectForKey:id];
    }
}

@end

