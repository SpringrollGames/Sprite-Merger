pressed = false;
image_blend = c_white;
if (position_meeting(mouse_x, mouse_y, id)) {
	image_blend = c_ltgray;
	if (mouse_check_button_pressed(mb_left)) {
		pressed = true;
		image_blend = c_black;
	}
}
/* Copyright 2022 Springroll Games / Yosi */