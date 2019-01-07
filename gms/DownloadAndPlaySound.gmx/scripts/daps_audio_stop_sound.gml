/// daps_audio_stop_sound(id_or_filename)

var id_or_filename = argument0;

// 사운드 중단
if (ds_map_exists(download_and_play_sound_object.sound_map, id_or_filename) == true) {
    var sound = ds_map_find_value(download_and_play_sound_object.sound_map, id_or_filename);
    if (os_type == os_ios) {
        native_daps_audio_stop_sound(sound);
    } else if (os_type == os_android) {
        audio_stop_sound(sound);
    }
    ds_map_delete(download_and_play_sound_object.sound_map, id_or_filename);
    ds_map_delete(download_and_play_sound_object.sound_filename_map, id_or_filename);
}

else {
    
    // 파일명으로 검색
    var to_remove_sound_ids = ds_list_create();
    var uuid = ds_map_find_first(download_and_play_sound_object.sound_filename_map);
    for (var i = 0; i < ds_map_size(download_and_play_sound_object.sound_filename_map); i += 1) {
        if (ds_map_find_value(download_and_play_sound_object.sound_filename_map, uuid) == id_or_filename) {
            ds_list_add(to_remove_sound_ids, uuid);
        }
        uuid = ds_map_find_next(download_and_play_sound_object.sound_filename_map, uuid);
    }
    
    for (var i = 0; i < ds_list_size(to_remove_sound_ids); i += 1) {
        var uuid2 = ds_list_find_value(to_remove_sound_ids, i);
        var sound = ds_map_find_value(download_and_play_sound_object.sound_map, uuid2);
        if (os_type == os_ios) {
            native_daps_audio_stop_sound(sound);
        } else if (os_type == os_android) {
            audio_stop_sound(sound);
        }
        ds_map_delete(download_and_play_sound_object.sound_map, uuid2);
        ds_map_delete(download_and_play_sound_object.sound_filename_map, uuid2);
    }
    ds_list_destroy(to_remove_sound_ids);
}

// 대기열 목록 삭제
if (ds_map_exists(download_and_play_sound_object.to_play_sound_info_map, id_or_filename) == true) {
    var to_play_sound_infos = ds_map_find_value(download_and_play_sound_object.to_play_sound_info_map, id_or_filename);
    
    for (var i = 0; i < ds_list_size(to_play_sound_infos); i += 1) {
        ds_map_destroy(ds_list_find_value(to_play_sound_infos, i));
    }
    
    ds_list_clear(to_play_sound_infos);
}

else {
    
    // ID로 검색
    var filename = ds_map_find_first(download_and_play_sound_object.to_play_sound_info_map);
    for (var i = 0; i < ds_map_size(download_and_play_sound_object.to_play_sound_info_map); i += 1) {
        var to_play_sound_infos = ds_map_find_value(download_and_play_sound_object.to_play_sound_info_map, filename);
        
        for (var j = 0; j < ds_list_size(to_play_sound_infos); j += 1) {
            var info = ds_list_find_value(to_play_sound_infos, j);
            if (ds_map_find_value(info, 'id') == id_or_filename) {
                ds_map_destroy(info);
                ds_list_delete(to_play_sound_infos, j);
                j -= 1;
            }
        }
    
        filename = ds_map_find_next(download_and_play_sound_object.to_play_sound_info_map, filename);
    }
}
