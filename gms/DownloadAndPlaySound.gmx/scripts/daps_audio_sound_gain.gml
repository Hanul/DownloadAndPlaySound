/// daps_audio_sound_gain(id_or_filename, volume, time)

var id_or_filename = argument0;
var volume = argument1;
var time = argument2;

// ID
if (ds_map_exists(download_and_play_sound_object.sound_map, id_or_filename) == true) {
    var sound = ds_map_find_value(download_and_play_sound_object.sound_map, id_or_filename);
    if (os_type == os_ios) {
        native_daps_audio_sound_gain(sound, volume);
    } else if (os_type == os_android) {
        audio_sound_gain(sound, volume, time);
    }
}

else {
    
    // 파일명으로 검색
    var uuid = ds_map_find_first(download_and_play_sound_object.sound_filename_map);
    for (var i = 0; i < ds_map_size(download_and_play_sound_object.sound_filename_map); i += 1) {
        if (ds_map_find_value(download_and_play_sound_object.sound_filename_map, uuid) == id_or_filename) {
            var sound = ds_map_find_value(download_and_play_sound_object.sound_map, uuid);
            if (os_type == os_ios) {
                native_daps_audio_sound_gain(sound, volume);
            } else if (os_type == os_android) {
                audio_sound_gain(sound, volume, time);
            }
        }
        uuid = ds_map_find_next(download_and_play_sound_object.sound_filename_map, uuid);
    }
    
    ds_map_replace(download_and_play_sound_object.volume_map, id_or_filename, volume);
    
    if (os_type == os_ios) {
        native_daps_audio_sound_gain(id_or_filename, volume);
    }
}
