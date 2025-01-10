package wlroots
import wl "../server"
import "core:c"
when ODIN_OS == .Linux do foreign import wlroots "system:libwlroots-0.19.so"
BackendImpl :: struct {} //todo
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

