package wlroots
import wl "../server"
import "core:c"
when ODIN_OS == .Linux do foreign import wlroots "system:libwlroots-0.19.so"

Cursor :: struct {
	state:  ^CursorState,
	x, y:   c.double, //coords?
	events: struct {
		motion:                wl.Signal,
		motion_absolute:       wl.Signal,
		button:                wl.Signal,
		axis:                  wl.Signal,
		frame:                 wl.Signal,
		swipe_begin:           wl.Signal,
		swipe_update:          wl.Signal,
		swipe_end:             wl.Signal,
		pinch_begin:           wl.Signal,
		pinch_update:          wl.Signal,
		pinch_end:             wl.Signal,
		hold_begin:            wl.Signal,
		hold_end:              wl.Signal,
		touch_up:              wl.Signal,
		touch_down:            wl.Signal,
		touch_motion:          wl.Signal,
		touch_cancel:          wl.Signal,
		touch_frame:           wl.Signal,
		tablet_tool_axis:      wl.Signal,
		tablet_tool_proximity: wl.Signal,
		tablet_tool_tip:       wl.Signal,
		tablet_tool_button:    wl.Signal,
	},
	data:   rawptr,
}
CursorState :: struct {}

foreign wlroots {
	@(link_name = "wlr_cursor_create")
	CreateCursor :: proc() -> ^Cursor ---

	@(link_name = "wlr_cursor_destroy")
	DestroyCursor :: proc(_: ^Cursor) ---

	@(link_name = "wlr_cursor_attach_output_layout")
	AttachCursorToOutputLayout :: proc(_: ^Cursor, _: ^OutputLayout) ---

	@(link_name = "wlr_cursor_attach_input_device")
	AttachCursorAsInputDevice :: proc(_: ^Cursor, _: ^InputDevice) ---

	@(link_name = "wlr_cursor_move")
	MoveCursor :: proc(_: ^Cursor, _: ^InputDevice, _: c.double, _: c.double) ---
}
