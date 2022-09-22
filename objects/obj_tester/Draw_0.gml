var _y = y;
for (var i = 0; i < array_length(sprites); i++) {
	draw_sprite(sprites[@ i], 0, x, _y);
	_y += sprite_get_height(sprites[@ 0]);
	_y += 32;
}

if (!is_undefined(final_surf) && surface_exists(final_surf)) {
	draw_surface(final_surf, x, _y);
}

if (!is_undefined(palette_surf) && surface_exists(palette_surf)) {
	var _width = surface_get_width(palette_surf);
	var _height = surface_get_height(palette_surf);
	var _surf_y = 0;
	var _x = (room_width - 256);
	var _amount = (room_height - 128) div 4;
	while (_surf_y < _height) {
		draw_surface_part_ext(palette_surf, 0, _surf_y, _width, min(_amount, _height - _surf_y), _x, y, 4, 4, c_white, 1);
		_x += 32;
		_surf_y += _amount;
	}
}
/* Copyright 2022 Springroll Games / Yosi */