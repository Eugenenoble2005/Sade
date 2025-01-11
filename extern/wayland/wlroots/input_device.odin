package wlroots
import wl "../server"
import "core:c"

InputDevice :: struct {
	type:   InputDeviceType,
	name:   cstring,
	events: struct {
		destroy: wl.Signal,
	},
	data:   rawptr,
}
InputDeviceType :: enum {
	Keyboard,
	Pointer,
	Touch,
	Tablet,
	Tablet_Pad,
	Switch,
}
