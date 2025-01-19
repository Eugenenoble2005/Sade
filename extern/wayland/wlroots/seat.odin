package wlroots
import wl "../server"
import "core:c"
import "core:c/libc"
when ODIN_OS == .Linux do foreign import wlroots "system:libwlroots-0.19.so"

Seat :: struct {
	global:                   ^wl.Global,
	display:                  ^wl.Display,
	clients:                  wl.List,
	//
	name:                     cstring,
	capabilities:             c.uint32_t,
	accumulated_capabilities: c.uint32_t,
	// 
	selection_source:         ^DataSource,
	selection_serial:         c.uint32_t,
	selection_offers:         wl.List,
	//
	primary_selection_source: ^PrimarySelectionSource,
	primary_selection_serial: c.uint32_t,
	//
	drag:                     ^Drag,
	drag_source:              ^DataSource,
	drag_serial:              c.uint32_t,
	drag_offers:              wl.List,
	// 
	pointer_state:            SeatPointerState,
	keyboard_state:           SeatKeyboardState,
	touch_state:              SeatTouchState,
	//
	events:                   struct {
		pointer_grab_begin:            wl.Signal,
		pointer_grab_end:              wl.Signal,
		//
		keyboard_grab_begin:           wl.Signal,
		keyboard_grab_end:             wl.Signal,
		//
		touch_grab_begin:              wl.Signal,
		touch_grab_end:                wl.Signal,
		//
		request_set_cursor:            wl.Signal,
		request_set_selection:         wl.Signal,
		set_selection:                 wl.Signal,
		request_set_primary_selection: wl.Signal,
		set_primary_selection:         wl.Signal,
		request_start_drag:            wl.Signal,
		start_drag:                    wl.Signal,
		destroy:                       wl.Signal,
	},
	data:                     rawptr,
	WLR_PRIVATE:              struct {
		display_destroy:                  wl.Listener,
		selection_source_destroy:         wl.Listener,
		primary_selection_source_destroy: wl.Listener,
		drag_source_destroy:              wl.Listener,
	},
}

SeatKeyboardGrab :: struct {
	interface: ^SeatKeyboardGrabInterface,
	seat:      ^Seat,
	data:      rawptr,
}
SeatKeyboardGrabInterface :: struct {
	enter:       proc(
		grab: ^SeatKeyboardGrab,
		surface: ^Surface,
		keycodes: []c.uint32_t,
		num_keycodes: c.size_t,
		modifiers: ^KeyboardModifiers,
	),
	clear_focus: proc(grab: ^SeatKeyboardGrab),
	key:         proc(
		grab: ^SeatKeyboardGrab,
		time_msec: c.uint32_t,
		key: c.uint32_t,
		state: c.uint32_t,
	),
	modifiers:   proc(grab: ^SeatKeyboardGrab, modifiers: ^KeyboardModifiers),
	cancel:      proc(grab: ^SeatKeyboardGrab),
}

SeatPointerGrab :: struct {
	interface: ^SeatPointerGrabInterface,
	seat:      ^Seat,
	data:      rawptr,
}
SeatTouchGrab :: struct {
	interface: ^SeatTouchGrabInterface,
	seat:      ^Seat,
	data:      rawptr,
}
SeatPointerGrabInterface :: struct {
	enter:       proc(grab: ^SeatPointerGrab, surface: ^Surface, sx: c.double, sy: c.double),
	clear_focus: proc(grab: ^SeatPointerGrab),
	motion:      proc(grab: ^SeatPointerGrab, time_msec: c.uint32_t, sx: c.double, sy: c.double),
	button:      proc(
		grab: ^SeatPointerGrab,
		time_msec: c.uint32_t,
		button: c.uint32_t,
		state: wl.PointerButtonState,
	),
	axis:        proc(
		grab: SeatPointerGrab,
		time_msec: c.uint32_t,
		orientation: wl.PointerAxis,
		value: c.double,
		value_discrete: c.int32_t,
		source: wl.PointerAxisSource,
		relative_direction: wl.PointerAxisRelativeDirection,
	),
	frame:       proc(grab: ^SeatPointerGrab),
	cancel:      proc(grab: ^SeatPointerGrab),
}
SeatTouchGrabInterface :: struct {
	down:      proc(grab: ^SeatTouchGrab, time_msec: c.uint32_t, point: ^TouchPoint) -> c.uint32_t,
	up:        proc(grab: ^SeatTouchGrab, time_msec: c.uint32_t, point: ^TouchPoint) -> c.uint32_t,
	motion:    proc(grab: ^SeatTouchGrab, time_msec: c.uint32_t, point: ^TouchPoint),
	enter:     proc(grab: ^SeatTouchGrab, time_msec: c.uint32_t, point: ^TouchPoint),
	frame:     proc(grab: ^SeatTouchGrab),
	cancel:    proc(grab: ^SeatTouchGrab),
	wl_cancel: proc(grab: ^SeatTouchGrab, seat_client: ^SeatClient),
}
TouchPoint :: struct {
	touch_id:      c.uint32_t,
	surface:       ^Surface,
	client:        ^SeatClient,
	focus_surface: ^Surface,
	focus_client:  ^SeatClient,
	sx, sy:        c.double,
	events:        struct {
		destroy: wl.Signal,
	},
	link:          wl.List,
	WLR_PRIVATE:   struct {
		surface_destroy:       wl.Listener,
		focus_surface_destroy: wl.Listener,
		client_destroy:        wl.Listener,
	},
}
SeatClient :: struct {
	client:            ^wl.Client,
	seat:              ^Seat,
	link:              wl.List,
	resources:         wl.List,
	pointers:          wl.List,
	keyboards:         wl.List,
	touches:           wl.List,
	data_devices:      wl.List,
	events:            struct {
		destroy: wl.Signal,
	},
	serials:           SerialRingset,
	needs_touch_frame: c.bool,
	value120:          struct {
		acc_discrete:  [2]c.int32_t,
		last_discrete: [2]c.int32_t,
		acc_axis:      [2]c.int32_t,
	},
}
SerialRange :: struct {
	min_incl: c.uint32_t,
	max_incl: c.uint32_t,
}
SerialRingset :: struct {
	data:  [128]SerialRange,
	end:   c.int,
	count: c.int,
}
SeatPointerState :: struct {
	seat:               ^Seat,
	focused_client:     ^SeatClient,
	focused_surface:    ^Surface,
	sx, sy:             c.double,
	//
	grab:               ^SeatPointerGrab,
	default_grab:       ^SeatPointerGrab,
	//
	sent_axis_source:   c.bool,
	cached_axis_source: wl.PointerAxisSource,
	//
	buttons:            [16]SeatPointerButton, //WLR_POINTER_BUTTONS_CAP
	button_count:       c.size_t,
	grab_button:        c.uint32_t,
	grab_serial:        c.uint32_t,
	grab_time:          c.uint32_t,
	events:             struct {
		focus_change: wl.Signal,
	},
	WLR_PRIVATE:        struct {
		surface_destroy: wl.Listener,
	},
}
SeatKeyboardState :: struct {
	seat:            ^Seat,
	keyboard:        ^Keyboard,
	//
	focused_client:  ^SeatClient,
	focused_surface: ^Surface,
	//
	grab:            ^SeatKeyboardGrab,
	default_grab:    ^SeatKeyboardGrab,
	//
	events:          struct {
		focus_change: wl.Signal,
	},
	WLR_PRIVATE:     struct {
		keyboard_destroy:     wl.Listener,
		keyboard_keymap:      wl.Listener,
		keyboard_repeat_info: wl.Listener,
		surface_destroy:      wl.Listener,
	},
}
SeatTouchState :: struct {
	seat:         ^Seat,
	touch_points: wl.List,
	//
	grab_serial:  c.uint32_t,
	grab_id:      c.uint32_t,
	//
	grab:         ^SeatTouchGrab,
	default_grab: ^SeatTouchGrab,
}
SeatPointerButton :: struct {
	button:    c.uint32_t,
	n_pressed: c.size_t,
}
SeatPointerRequestSetCursorEvent :: struct {
	seat_client:          ^SeatClient,
	surface:              ^Surface,
	serial:               c.uint32_t,
	hotspot_x, hotspot_y: c.int32_t,
}
SeatRequestSetSelectionEvent :: struct {
	source: ^DataSource,
	serial: c.uint32_t,
}
foreign wlroots {
	@(link_name = "wlr_seat_set_capabilities")
	SetSeatCapabilities :: proc(_: ^Seat, _: c.uint32_t) ---

	@(link_name = "wlr_seat_create")
	CreateSeat :: proc(_: ^wl.Display, _: cstring) -> ^Seat ---

	@(link_name = "wlr_seat_set_keyboard")
	SetSeatKeyboard :: proc(_: ^Seat, _: ^Keyboard) ---

	@(link_name = "wlr_seat_keyboard_notify_modifiers")
	SeatKeyboardNotifyModifiers :: proc(_: ^Seat, _: ^KeyboardModifiers) ---

	@(link_name = "wlr_seat_keyboard_notify_key")
	SeatKeyboardNotifyKey :: proc(_: ^Seat, _: c.uint32_t, _: c.uint32_t, _: c.uint32_t) ---

	@(link_name = "wlr_seat_get_keyboard")
	GetSeatKeyboard :: proc(_: ^Seat) -> ^Keyboard ---

	@(link_name = "wlr_seat_keyboard_notify_enter")
	SeatKeyboardNotifyEnter :: proc(_: ^Seat, _: ^Surface, _: []c.uint32_t, _: c.size_t, _: ^KeyboardModifiers) ---

	@(link_name = "wlr_seat_pointer_notify_enter")
	SeatPointerNotifyEnter :: proc(_: ^Seat, _: ^Surface, _: c.double, _: c.double) ---

	@(link_name = "wlr_seat_pointer_notify_motion")
	SeatPointerNotifyMotion :: proc(_: ^Seat, _: c.uint32_t, _: c.double, _: c.double) ---

	@(link_name = "wlr_seat_pointer_notify_button")
	SeatPointerNotifyButton :: proc(_: ^Seat, _: c.uint32_t, _: c.uint32_t, _: wl.PointerButtonState) -> c.uint32_t ---

	@(link_name = "wlr_seat_pointer_clear_focus")
	ClearSeatPointerFocus :: proc(_: ^Seat) ---

	@(link_name = "wlr_seat_set_selection")
	SetSeatSelection :: proc(_: ^Seat, _: ^DataSource, _: c.uint32_t) ---

	@(link_name = "wlr_seat_pointer_notify_axis")
	SeatPointerNotifyAxis :: proc(_: ^Seat, _: c.uint32_t, _: wl.PointerAxis, _: c.double, _: c.int32_t, _: wl.PointerAxisSource, _: wl.PointerAxisRelativeDirection) ---

	@(link_name = "wlr_seat_pointer_notify_frame")
	SeatPointerNotifyFrame :: proc(_: ^Seat) ---
}
