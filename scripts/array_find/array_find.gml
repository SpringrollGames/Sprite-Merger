///@param {array} array		The array to check
///@param {any} value		The value
/*
Returns the index of the given value in the array, or -1 if the value cannot be found.
*/
function array_find() {
	var _a = argument[0];
	var _v = argument[1];
	var _l = array_length(_a);
	if (is_array(_v)) {
		for (var i = 0; i < _l; i++) {
			if (array_equals(_a[@ i], _v)) {
				return i;
			}
		}
	} else {
		for (var i = 0; i < _l; i++) {
			if (_a[@ i] == _v) {
				return i;
			}
		}
	}
	return -1;
}
/* Copyright 2022 Springroll Games / Yosi */