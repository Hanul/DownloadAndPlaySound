/// daps_audio_play_sound(filename, priority, loop)

var filename = argument0;
var priority = argument1;
var loop = argument2;

var uuid = native_daps_create_uuid();

if (download_and_play_sound_object.is_inited == true) {
    
    // 준비되어 있는 사운드면 재생
    if (ds_map_exists(download_and_play_sound_object.sound_ready_map, filename) == true && ds_map_find_value(download_and_play_sound_object.sound_ready_map, filename) == true) {
                
        // 1초 이상 지연되면 소리 재생 안함
        if (delta_time / 1000000 < 1) {
        
            if (os_type == os_ios) {
                var sound = native_daps_audio_play_sound(filename, loop);
                if (ds_map_exists(download_and_play_sound_object.volume_map, filename) == true) {
                    native_daps_audio_sound_gain(sound, ds_map_find_value(download_and_play_sound_object.volume_map, filename));
                }
                ds_map_add(download_and_play_sound_object.sound_map, uuid, sound);
                ds_map_add(download_and_play_sound_object.sound_filename_map, uuid, filename);
            } else if (os_type == os_android) {
                var sound = audio_play_sound(ds_map_find_value(download_and_play_sound_object.sound_stream_map, filename), 1, loop);
                if (ds_map_exists(download_and_play_sound_object.volume_map, filename) == true) {
                    audio_sound_gain(sound, ds_map_find_value(download_and_play_sound_object.volume_map, filename), 0);
                }
                ds_map_add(download_and_play_sound_object.sound_map, uuid, sound);
                ds_map_add(download_and_play_sound_object.sound_filename_map, uuid, filename);
            }
        }
    }
    
    // 준비되지 않으면 대기열에 등록
    else {
        var info = ds_map_create();
        ds_map_add(info, 'id', uuid);
        ds_map_add(info, 'loop', loop);
        
        if (ds_map_exists(download_and_play_sound_object.to_play_sound_info_map, filename) != true) {
            ds_map_add(download_and_play_sound_object.to_play_sound_info_map, filename, ds_list_create());
            native_daps_ready_audio(filename);
        }
        
        var to_play_sound_infos = ds_map_find_value(download_and_play_sound_object.to_play_sound_info_map, filename);
        ds_list_add(to_play_sound_infos, info);
    }
}

return uuid;
