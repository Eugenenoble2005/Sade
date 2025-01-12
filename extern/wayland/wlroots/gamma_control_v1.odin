package wlroots
import wl "../server"
import "core:c"
GammaControlV1 :: struct {
	resource:    ^wl.Resource,
	output:      ^Output,
	manager:     ^GammaControlManagerV1,
	link:        wl.List,
	table:       ^c.uint16_t,
	ramp_size:   c.size_t,
	data:        rawptr,
	WLR_PRIVATE: struct {
		output_destroy_listener: wl.Listener,
	},
}
GammaControlManagerV1 :: struct {
	global:      ^wl.Global,
	controls:    wl.List,
	events:      struct {
		destroy:   wl.Signal,
		set_gamma: wl.Signal,
	},
	data:        rawptr,
	WLR_PRIVATE: struct {
		display_destroy: wl.Listener,
	},
}
