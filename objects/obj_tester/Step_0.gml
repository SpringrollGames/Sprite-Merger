//Button inputs
var _add = false;
var _clear_sprites = false;
var _clear_palette = false;
var _merge = false;
with (obj_button) {
	if (pressed) {
		if (text == "Add Sprite") {
			_add = true;
		}
		if (text == "Clear Sprites") {
			_clear_sprites = true;
		}
		if (text == "Clear Palette") {
			_clear_palette = true;
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

//Clear Sprites
if (_clear_sprites) {
	while (array_length(sprites) > 0) {
		sprite_delete(sprites[@ 0]);
		array_delete(sprites, 0, 1);
	}
	if (!is_undefined(final_surf) && surface_exists(final_surf)) {
		surface_free(final_surf);
	}
}

//Clear Palette
if (_clear_palette) {
	if (!is_undefined(palette_surf) && surface_exists(palette_surf)) {
		surface_free(palette_surf);
	}
	palette_array = [];
	color_combos = [];
	if (!is_undefined(palette_buffer)) {
		buffer_delete(palette_buffer);
	}
	palette_buffer = undefined;
	palette_pointer = 0;
	num_sprites_prev = 0;
}

//Merging
if (_merge) {
	//Safety checks
	var _n = array_length(sprites);
	if (_n <= 0) {
		show_message("Cannot merge 0 sprites!");
		exit;
	}
	var _base = sprites[@ 0];
	var _w = sprite_get_width(_base);
	var _h = sprite_get_height(_base);
	if (num_sprites_prev != 0 && _n != num_sprites_prev) {
		show_message("You must clear the palette before merging with a different number of sprites!");
		exit;
	}
	for (var i = 1; i < _n; i++) {
		if (sprite_get_width(sprites[@ i]) != _w ||
			sprite_get_height(sprites[@ i]) != _h) {
			show_message("All the sprites must be the same size!");
			exit;
		}
	}
	var _size = (_w * _h * 4); //Buffer size
	var _current_color = 0;
	
	//Variables
	sprite_buffers = [];
	final_buffer = buffer_create(_size, buffer_fixed, 1);
	if (is_undefined(palette_buffer)) {
		palette_buffer = buffer_create(1, buffer_grow, 1);
		palette_pointer = 0;
	}
	buffer_seek(palette_buffer, buffer_seek_start, palette_pointer);
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
	palette_pointer = buffer_tell(palette_buffer);
	
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
	buffer_set_surface(palette_buffer, palette_surf, 0);
	
	//Save the surfaces
	var _timestamp = timestamp_create();
	surface_save(final_surf, _timestamp + "_sprite.png");
	surface_save(palette_surf, _timestamp + "_palette.png");
	
	//Clean up
	buffer_delete(final_buffer);
	while (array_length(sprite_buffers) > 0) {
		buffer_delete(sprite_buffers[@ 0]);
		array_delete(sprite_buffers, 0, 1);
	}
	num_sprites_prev = _n;
	
	show_debug_message(color_combos);
}
/* Copyright 2022 Springroll Games / Yosi */