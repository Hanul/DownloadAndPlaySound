/// daps_audio_is_playing(filename)

var filename = argument0;

var uuid = ds_map_find_first(download_and_play_sound_object.sound_filename_map);
for (var i = 0; i < ds_map_size(download_and_play_sound_object.sound_filename_map); i += 1) {
    if (ds_map_find_value(download_and_play_sound_object.sound_filename_map, uuid) == filename) {
        return true;
    }
    uuid = ds_map_find_next(download_and_play_sound_object.sound_filename_map, uuid);
}

return false;
