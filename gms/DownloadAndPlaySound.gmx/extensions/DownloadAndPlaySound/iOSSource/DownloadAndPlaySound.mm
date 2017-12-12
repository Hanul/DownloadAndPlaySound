#import "DownloadAndPlaySound.h"

@implementation DownloadAndPlaySound

- (id) init
{
    tag = (char *)[@"" UTF8String];
    url = (char *)[@"" UTF8String];
    
    soundMap = [[NSMutableDictionary alloc] init];
    soundFilenameMap = [[NSMutableDictionary alloc] init];
    volumeMap = [[NSMutableDictionary alloc] init];
    
    return self;
}

- (double) daps_init:(char *)tag Arg2:(char *)url
{
    self->tag = tag;
    self->url = url;
    return (double)-1;
}

- (double) daps_audio_stop_sound:(char *)id_or_filename
{
    // id
    if (soundMap[[NSString stringWithUTF8String:id_or_filename]] != nil) {
        [soundMap[[NSString stringWithUTF8String:id_or_filename]] stop];
        [soundMap[[NSString stringWithUTF8String:id_or_filename]] release];
        [soundMap removeObjectForKey:[NSString stringWithUTF8String:id_or_filename]];
    }
    
    // filename
    else {
        for (NSString * id in [soundMap allKeys]) {
            if ([soundFilenameMap[id] isEqualToString:[NSString stringWithUTF8String:id_or_filename]]) {
                [soundFilenameMap removeObjectForKey:id];
                [soundMap[id] stop];
                [soundMap[id] release];
                [soundMap removeObjectForKey:id];
            }
        }
    }
    
    return (double)-1;
}

- (char *) daps_audio_play_sound:(char *)filename Arg2:(double)priority Arg3:(double)loop
{
    self->tag = (char *)[@"__TEST" UTF8String];
    self->url = (char *)[@"cwserver3.btncafe.com:8523" UTF8String];
    
    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString * documentsDirectory = [paths objectAtIndex:0];
    NSString * filePath = [NSString stringWithFormat:@"%@/%@/%@.mp3", documentsDirectory, [NSString stringWithUTF8String:tag], [NSString stringWithUTF8String:filename]];
    NSFileManager * fileManager = [NSFileManager defaultManager];
    
    // 파일이 존재하지 않으면 다운로드
    if ([fileManager fileExistsAtPath:filePath] != YES){
        NSData * data = [NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@/R/gamesound/mp3/%@.mp3", [NSString stringWithUTF8String:url], [NSString stringWithUTF8String:filename]]]];
        [data writeToFile:filePath atomically:YES];
    }
    
    NSURL * fileURL = [NSURL fileURLWithPath:filePath];
    AVAudioPlayer * player = [[AVAudioPlayer alloc] initWithContentsOfURL:fileURL error:nil];
    player.numberOfLoops = loop == 1 ? -1 : 0;
    player.delegate = self;
    [player play];
    
    NSString * id = [[NSUUID UUID] UUIDString];
    soundMap[id] = player;
    soundFilenameMap[id] = [NSString stringWithUTF8String:filename];
    
    if (volumeMap[[NSString stringWithUTF8String:filename]] != nil) {
        [player setVolume:[volumeMap[[NSString stringWithUTF8String:filename]] floatValue]];
    }
    
    [self daps_audio_sound_pitch:(char *)[id UTF8String] Arg2:0.5];
    
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
    if (soundMap[[NSString stringWithUTF8String:id_or_filename]] != nil) {
        if ([soundMap[[NSString stringWithUTF8String:id_or_filename]] isPlaying] == YES) {
            isPlaying = YES;
        }
    }
    
    // filename
    else {
        for (NSString * id in [soundMap allKeys]) {
            if ([soundFilenameMap[id] isEqualToString:[NSString stringWithUTF8String:id_or_filename]] && [soundMap[id] isPlaying] == YES) {
                isPlaying = YES;
            }
        }
    }
    
    return isPlaying;
}

- (double) daps_audio_sound_gain:(char *)id_or_filename Arg2:(double)volume Arg3:(double)time
{
    volumeMap[[NSString stringWithUTF8String:id_or_filename]] = [NSNumber numberWithDouble:volume];
    
    // id
    if (soundMap[[NSString stringWithUTF8String:id_or_filename]] != nil) {
        [soundMap[[NSString stringWithUTF8String:id_or_filename]] setVolume:(float) volume];
    }
    
    // filename
    else {
        for (NSString * id in [soundMap allKeys]) {
            if ([soundFilenameMap[id] isEqualToString:[NSString stringWithUTF8String:id_or_filename]]) {
                [soundMap[id] setVolume:(float) volume];
            }
        }
    }
    
    return (double)-1;
}

// 재생이 끝나면 자동 release
- (void) audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    NSArray * allKeys = [soundMap allKeysForObject:player];
    for (NSString * id in allKeys) {
        [soundFilenameMap removeObjectForKey:id];
        [soundMap[id] stop];
        [soundMap[id] release];
        [soundMap removeObjectForKey:id];
    }
}

@end
