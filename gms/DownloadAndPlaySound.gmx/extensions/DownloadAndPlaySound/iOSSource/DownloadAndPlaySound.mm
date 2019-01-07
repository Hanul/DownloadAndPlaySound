#import "DownloadAndPlaySound.h"

@implementation DownloadAndPlaySound

const int EVENT_OTHER_SOCIAL = 70;
extern int CreateDsMap( int _num, ... );
extern void CreateAsynEventWithDSMap(int dsmapindex, int event_index);

- (id) init
{
    // 음악 앱과 동시 재생되도록
    [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryAmbient error: nil];
    
    tag = @"";
    url = @"";
    
    audioMap = [[NSMutableDictionary alloc] init];
    volumeMap = [[NSMutableDictionary alloc] init];
    
    return self;
}

- (double) native_daps_init:(char *)tag Arg2:(char *)url
{
    self->tag = [[NSString stringWithUTF8String:tag] copy];
    self->url = [[NSString stringWithUTF8String:url] copy];
    
    return (double)1;
}

- (char *) native_daps_create_uuid
{
    return (char *)[[[NSUUID UUID] UUIDString] UTF8String];
}

- (double) native_daps_ready_audio:(char *)filename
{
    NSString * folderPath = [NSString stringWithFormat:@"%@/%@", [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0], tag];
    NSString * filePath = [NSString stringWithFormat:@"%@/%@", folderPath, [NSString stringWithUTF8String:filename]];

    NSFileManager * fileManager = [NSFileManager defaultManager];
    
    // 폴더가 없으면 생성
    if ([fileManager fileExistsAtPath:folderPath] != YES) {
        [fileManager createDirectoryAtPath:folderPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    // 파일이 존재하지 않으면 다운로드
    if ([fileManager fileExistsAtPath:filePath] != YES) {
        NSData * data = [NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@mp3/%@.mp3", url, [NSString stringWithUTF8String:filename]]]];
        [data writeToFile:filePath atomically:YES];
    }
    
    int dsMapIndex = CreateDsMap(2,
                                 "type", 0.0, "__SOUND_READY",
                                 "filename", 0.0, filename
                                 );
    
    CreateAsynEventWithDSMap(dsMapIndex, EVENT_OTHER_SOCIAL);
    
    return (double)-1;
}

- (char *) native_daps_audio_play_sound:(char *)filename Arg2:(double)loop
{
    NSString * id = [[NSUUID UUID] UUIDString];
    
    NSString * folderPath = [NSString stringWithFormat:@"%@/%@", [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0], tag];
    NSString * filePath = [NSString stringWithFormat:@"%@/%@", folderPath, [NSString stringWithUTF8String:filename]];
    NSURL * fileURL = [NSURL fileURLWithPath:filePath];
    
    // 배경 음악
    if ([[[NSString stringWithUTF8String:filename] substringToIndex:4] isEqualToString:@"bgm_"]) {
        
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

- (double) native_daps_audio_stop_sound:(char *)id
{
    if (audioMap[[NSString stringWithUTF8String:id]] != nil) {
        [audioMap[[NSString stringWithUTF8String:id]] stop];
        // release가 자동으로 됨
        [audioMap removeObjectForKey:[NSString stringWithUTF8String:id]];
    }
    
    return (double)-1;
}

- (double) native_daps_audio_sound_pitch:(char *)id Arg2:(double)pitch
{
    return (double)-1;
}

- (double) native_daps_audio_is_playing:(char *)id
{
    bool isPlaying = NO;
    
    if (audioMap[[NSString stringWithUTF8String:id]] != nil) {
        if ([audioMap[[NSString stringWithUTF8String:id]] isPlaying] == YES) {
            isPlaying = YES;
        }
    }
    
    return isPlaying;
}

- (double) native_daps_audio_sound_gain:(char *)id Arg2:(double)volume
{
    if (volumeMap[[NSString stringWithUTF8String:id]] != nil) {
        // release가 자동으로 됨
        [volumeMap removeObjectForKey:[NSString stringWithUTF8String:id]];
    }
    volumeMap[[NSString stringWithUTF8String:id]] = [NSNumber numberWithDouble:volume];
    
    if (audioMap[[NSString stringWithUTF8String:id]] != nil) {
        [audioMap[[NSString stringWithUTF8String:id]] setVolume:(float) volume];
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
    }
}

@end

