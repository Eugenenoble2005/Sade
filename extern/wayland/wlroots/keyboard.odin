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
KeyboardModifer :: enum c.int {
	Shift = 1 << 0,
	Caps  = 1 << 1,
	Ctrl  = 1 << 2,
	Alt   = 1 << 3,
	Mod2  = 1 << 4,
	Mod3  = 1 << 5,
	Logo  = 1 << 6,
	Mod5  = 1 << 7,
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
		keymap:      wl.Signal,
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
KeyboardKeyEvent :: struct {
	time_msec:    c.uint32_t,
	keycode:      c.uint32_t,
	update_state: c.bool,
	state:        wl.KeyboardKeyState,
}

foreign wlroots {
	@(link_name = "wlr_keyboard_from_input_device")
	GetKeyboardFromInputDevice :: proc(_: ^InputDevice) -> ^Keyboard ---

	@(link_name = "wlr_keyboard_set_keymap")
	SetKeyMap :: proc(_: ^Keyboard, _: ^xkb.Keymap) -> c.bool ---

	@(link_name = "wlr_keyboard_set_repeat_info")
	SetKeyboardRepeatInfo :: proc(_: ^Keyboard, _: c.int32_t, _: c.int32_t) ---

	@(link_name = "wlr_keyboard_get_modifiers")
	GetKeyboardModifiers :: proc(_: ^Keyboard) -> c.uint32_t ---
}
