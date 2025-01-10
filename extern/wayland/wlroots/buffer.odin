package wlroots
import wl "../server"
import "core:c"
BufferImpl :: struct {} //todo
Buffer :: struct {
	impl:               BufferImpl,
	width, height:      c.int,
	dropped:            c.bool,
	n_locks:            c.size_t,
	accessing_data_ptr: c.bool,
	events:             struct {
		destroy: wl.Signal,
		release: wl.Signal,
	},
	addons:             AddonSet,
}

