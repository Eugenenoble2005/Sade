package wlroots
import wl "../server"
import "core:c"
when ODIN_OS == .Linux do foreign import wlroots "system:libwlroots-0.19.so"

DataDeviceManager :: struct {
	global:       ^wl.Global,
	data_sources: wl.List,
	events:       struct {
		destroy: wl.Signal,
	},
	data:         rawptr,
	WLR_PRIVATE:  struct {
		display_destroy: wl.Listener,
	},
}

DataSource :: struct {
	impl:               ^struct {}, //todo
	mime_types:         wl.Array,
	actions:            c.int32_t,
	accepted:           c.bool,
	current_dnd_action: wl.DataDeviceManagerDndAction,
	compositor_action:  c.uint32_t,
	events:             struct {
		destroy: wl.Signal,
	},
}
Drag :: struct {
	grab_type:                    GrabType,
	keyboard_grab:                SeatKeyboardGrab,
	pointer_grab:                 SeatPointerGrab,
	touch_grab:                   SeatTouchGrab,
	seat:                         ^Seat,
	seat_client:                  ^SeatClient,
	focus_client:                 ^SeatClient,
	icon:                         ^DragIcon,
	focus:                        ^Surface,
	source:                       ^DataSource,
	started, dropped, cancelling: c.bool,
	grab_touch_id, touch_id:      c.int32_t,
	events:                       struct {
		focus:   wl.Signal,
		motion:  wl.Signal,
		drop:    wl.Signal,
		destroy: wl.Signal,
	},
	data:                         rawptr,
	WLR_PRIVATE:                  struct {
		source_destroy:      wl.Listener,
		seat_client_destroy: wl.Listener,
		focus_destroy:       wl.Listener,
		icon_destroy:        wl.Listener,
	},
}
GrabType :: enum {
	Keyboard,
	Keyboard_Pointer,
	Keyboard_Touch,
}
DragIcon :: struct {
	drag:        ^Drag,
	surface:     ^Surface,
	events:      struct {
		destroy: wl.Signal,
	},
	data:        rawptr,
	WLR_PRIVATE: struct {
		surface_destroy: wl.Listener,
	},
}
foreign wlroots {
	@(link_name = "wlr_data_device_manager_create")
	CreateDataDeviceManager :: proc(_: ^wl.Display) -> ^DataDeviceManager ---
}
