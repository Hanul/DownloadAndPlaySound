/// daps_init(tag, url)

var tag = argument0;
var url = argument1;

download_and_play_sound_object.is_inited = true;

return native_daps_init(tag, url);

