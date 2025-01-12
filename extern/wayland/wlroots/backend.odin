package wlroots
import wl "../server"
import "core:c"
when ODIN_OS == .Linux do foreign import wlroots "system:libwlroots-0.19.so"
BackendImpl :: struct {
	start:      proc(backend: ^Backend) -> c.bool,
	destroy:    proc(backend: ^Backend),
	get_drm_fd: proc(backend: ^Backend) -> c.int,
	test:       proc(
		backend: ^Backend,
		states: ^BackendOutputState,
		states_len: c.size_t,
	) -> c.bool,
	commit:     proc(
		backend: ^Backend,
		states: ^BackendOutputState,
		states_len: c.size_t,
	) -> c.bool,
} //todo
BackendOutputState :: struct {
	output: ^Output,
	base:   OutputState,
}
Backend :: struct {
	impl:        ^BackendImpl,
	buffer_caps: c.uint32_t,
	features:    struct {
		timeline: c.bool,
	},
	events:      struct {
		destroy:    wl.Signal,
		new_input:  wl.Signal,
		new_output: wl.Signal,
	},
}


foreign wlroots {
	@(link_name = "wlr_backend_autocreate")
	AutoCreateBackend :: proc(_: ^wl.EventLoop, _: ^^Session) -> ^Backend ---

	@(link_name = "wlr_backend_destroy")
	DestroyBackend :: proc(_: ^Backend) ---

	@(link_name = "wlr_backend_start")
	StartBackend :: proc(_: ^Backend) -> c.bool ---

}
