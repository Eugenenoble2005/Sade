package wlroots
import xkb "../../xkbcommon"
import wl "../server"
import "core:c"
when ODIN_OS == .Linux do foreign import wlroots "system:libwlroots-0.19.so"
KeyboardModifiers :: struct {
	depressed: xkb.ModMask,
	latched:   xkb.ModMask,
	locked:    xkb.ModMask,
	group:     xkb.LayoutIndex,
}
Keyboard :: struct {
	base:          InputDevice,
	//
	impl:          ^struct {}, //todo
	group:         ^KeyboardGroup,
	//
	keymap_string: cstring,
	keymap_size:   c.size_t,
	keymap_fd:     c.int,
	keymap:        ^xkb.Keymap,
	xkb_state:     ^xkb.State,
	//
	led_indexes:   [3]xkb.LedIndex,
	mod_indexes:   [8]xkb.ModIndex,
	//
	leds:          c.uint32_t,
	keycodes:      [32]c.uint32_t,
	num_keycodes:  c.size_t,
	modifiers:     KeyboardModifiers,
	//
	repeat_info:   struct {
		rate:  c.int32_t,
		delay: c.int32_t,
	},
	events:        struct {
		key:         wl.Signal,
		modifiers:   wl.Signal,
		repeat_info: wl.Signal,
	},
	data:          rawptr,
}
KeyboardGroup :: struct {
	keyboard: Keyboard,
	devices:  wl.List,
	keys:     wl.List,
	events:   struct {
		enter: wl.Signal,
		leave: wl.Signal,
	},
	data:     rawptr,
}
foreign wlroots {
	@(link_name = "wlr_keyboard_from_input_device")
	GetKeyboardFromInputDevice :: proc(_: ^InputDevice) -> ^Keyboard ---
}
