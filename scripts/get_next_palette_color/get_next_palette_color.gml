function get_next_palette_color() {
	var _color = make_color_hsv(hue, sat, val);
	val += 71;
	if (val > 255) {
		val -= 255;
		hue += 16;
		if (hue > 255) {
			hue -= 255;
		}
	}
	_color = _color | 0xFF << 24;
	return _color;
}
/* Copyright 2022 Springroll Games / Yosi */