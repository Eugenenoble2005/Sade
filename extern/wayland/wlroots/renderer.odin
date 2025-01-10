package wlroots
import wl "../server"
import "core:c"
when ODIN_OS == .Linux do foreign import wlroots "system:libwlroots-0.19.so"

Renderer :: struct {
	render_buffer_caps: c.uint32_t,
	events:             struct {
		destroy: wl.Signal,
		lost:    wl.Signal,
	},
	features:           struct {
		output_color_transform: c.bool,
	},
	impl:               ^struct {},
}

foreign wlroots {
	@(link_name = "wlr_renderer_autocreate")
	AutoCreateRenderer :: proc(_: ^Backend) -> ^Renderer ---

	@(link_name = "wlr_renderer_destroy")
	DestroyRenderer :: proc(_: ^Renderer) ---

	@(link_name = "wlr_renderer_init_wl_display")
	RendererInitWlDisplay :: proc(_: ^Renderer, _: ^wl.Display) -> c.bool ---
}

