package wlroots
import wl "../server"
import "core:c"
when ODIN_OS == .Linux do foreign import wlroots "system:libwlroots-0.19.so"

Pointer :: struct {
	base:        InputDevice,
	impl:        ^struct {}, //todo
	output_name: cstring,
	events:      struct {
		motion:          wl.Signal,
		motion_absolute: wl.Signal,
		button:          wl.Signal,
		axis:            wl.Signal,
		frame:           wl.Signal,
		swipe_begin:     wl.Signal,
		swipe_update:    wl.Signal,
		swipe_end:       wl.Signal,
		pinch_begin:     wl.Signal,
		pinch_update:    wl.Signal,
		pinch_end:       wl.Signal,
		hold_begin:      wl.Signal,
		hold_end:        wl.Signal,
	},
	data:        rawptr,
}
PointerMotionAbsoluteEvent :: struct {
	pointer:   ^Pointer,
	time_msec: c.uint32_t,
	x, y:      c.double,
}
PointerButtonEvent :: struct {
	pointer:   ^Pointer,
	time_msec: c.uint32_t,
	button:    c.uint32_t,
	state:     wl.PointerButtonState,
}
PointerAxisEvent :: struct {
	pointer:            ^Pointer,
	time_msec:          c.uint32_t,
	source:             wl.PointerAxisSource,
	orientaion:         wl.PointerAxis,
	relative_direction: wl.PointerAxisRelativeDirection,
	delta:              c.double,
	delta_discrete:     c.int32_t,
}
PointerMotionEvent :: struct {
	pointer:                ^Pointer,
	time_msec:              c.uint32_t,
	delta_x, delta_y:       c.double,
	unaccel_dx, unaccel_dy: c.double,
}


foreign wlroots {

}
