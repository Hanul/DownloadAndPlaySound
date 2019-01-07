/// daps_audio_sound_pitch(id, pitch)

var _id = argument0;
var pitch = argument1;

if (ds_map_exists(download_and_play_sound_object.sound_map, _id) == true) {
    var sound = ds_map_find_value(download_and_play_sound_object.sound_map, _id);
    if (os_type == os_ios) {
        native_daps_audio_sound_pitch(sound, pitch);
    } else if (os_type == os_android) {
        audio_sound_pitch(sound, pitch);
    }
}
