//Button inputs
var _add = false;
var _clear = false;
var _merge = false;
with (obj_button) {
	if (pressed) {
		if (text == "Add Sprite") {
			_add = true;
		}
		if (text == "Clear All") {
			_clear = true;
		}
		if (text == "Merge") {
			_merge = true;
		}
	}
}

//Add
if (_add) {
	try {
		var _file = get_open_filename("PNG (*.png)|*.png", "sprite_strip.png");
		if (_file != "" && file_exists(_file)) {
			array_push(sprites, sprite_add(_file, 1, false, false, 0, 0));
		}
	} catch (_e) {
		show_message(_e);
	}
}

//Clear
if (_clear) {
	while (array_length(sprites) > 0) {
		sprite_delete(sprites[@ 0]);
		array_delete(sprites, 0, 1);
	}
	if (!is_undefined(final_surf) && surface_exists(final_surf)) {
		surface_free(final_surf);
	}
	if (!is_undefined(palette_surf) && surface_exists(palette_surf)) {
		surface_free(palette_surf);
	}
}

//Merging
if (_merge) {
	var _n = array_length(sprites);
	if (_n <= 0) {
		show_message("Cannot merge 0 sprites!");
		exit;
	}
	var _base = sprites[@ 0];
	var _w = sprite_get_width(_base);
	var _h = sprite_get_height(_base);
	var _size = (_w * _h * 4); //Buffer size
	var _current_color = 0;
	
	//Variables
	color_combos = [];
	final_buffer = buffer_create(_size, buffer_fixed, 1);
	palette_buffer = buffer_create(1, buffer_grow, 1);
	palette_array = [];
	hue = 0;
	sat = 150;
	val = 0;

	//Turn sprites into sprite_buffers
	for (var i = 0; i < _n; i++) {
		sprite_buffers[@ i] = buffer_create(_size, buffer_fixed, 1);
	
		var _spr = sprites[@ i];
		var _surf = surface_create(_w, _h);

		//Draw sprite to surface
		surface_set_target(_surf);
		draw_clear_alpha(c_black, 0);
		draw_sprite(_spr, 0, 0, 0);
		surface_reset_target();
	
		//Get a buffer from the surface
		var _b = sprite_buffers[@ i];
		buffer_get_surface(_b, _surf, 0);
		surface_free(_surf);
	}
	
	//Find unique color combos in sprites
	for (var _x = 0; _x < _w; _x++) {
		for (var _y = 0; _y < _h; _y++) {
			var _pos = (_x + (_y * _w)) * 4;
			var _color_array = [];
			for (var i = 0; i < _n; i++) {
				var _b = sprite_buffers[@ i];
				var _col = 0;
				_col = buffer_peek(_b, _pos, buffer_u32);
				array_push(_color_array, _col);
			}
			
			//Check if the color combo is unique
			var _index = array_find(color_combos, _color_array);
			if (_index == -1) {
				//Add the palette color to the start of the array
				_current_color = get_next_palette_color();
				array_push(color_combos, _color_array);
				array_push(palette_array, _current_color);
				
				//Add the palette color to the buffer
				buffer_write(palette_buffer, buffer_u32, _current_color);
				
				//Add the sprite colors to the buffer
				for (var j = 0; j < _n; j++) {
					var _sprite_color = _color_array[@ j];
					buffer_write(palette_buffer, buffer_u32, _sprite_color);
				}
			} else {
				_current_color = palette_array[@ _index];
			}
			
			//Add pixel to the final sprite
			buffer_poke(final_buffer, _pos + 0, buffer_u32, _current_color);
		}
	}
	
	//Draw the final sprite to the surface
	if (!is_undefined(final_surf) && surface_exists(final_surf)) {
		surface_free(final_surf);
	}
	final_surf = surface_create(_w, _h);
	buffer_set_surface(final_buffer, final_surf, 0);
	
	//Create the palette sprite
	if (!is_undefined(palette_surf) && surface_exists(palette_surf)) {
		surface_free(palette_surf);
	}
	palette_surf = surface_create(_n + 1, array_length(palette_array));
	buffer_resize(palette_buffer, buffer_tell(palette_buffer));
	buffer_set_surface(palette_buffer, palette_surf, 0);
	
	//Save the surfaces
	var _timestamp = timestamp_create();
	surface_save(final_surf, _timestamp + "_sprite.png");
	surface_save(palette_surf, _timestamp + "_palette.png");
}
/* Copyright 2022 Springroll Games / Yosi */