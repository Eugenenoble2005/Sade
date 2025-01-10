package wlroots
import wl "../server"
import "core:c"

Session :: struct {
	active:        c.bool,
	vtnr:          c.uint,
	seat:          [256]c.char,
	udev:          ^struct {},
	mon:           ^struct {},
	udev_event:    ^wl.EventSource,
	seat_handle:   ^struct {},
	libseat_event: ^wl.EventSource,
	devices:       wl.List,
	event_loop:    ^wl.EventLoop,
	events:        struct {
		active:       wl.Signal,
		add_drm_card: wl.Signal,
		destroy:      wl.Signal,
	},
	WLR_PRIVATE:   struct {
		event_loop_destroy: wl.Listener,
	},
}

