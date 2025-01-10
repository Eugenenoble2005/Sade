package wlroots
import wl "../server"
import "core:c"
when ODIN_OS == .Linux do foreign import wlroots "system:libwlroots-0.19.so"

Compositor :: struct {
	global:      ^wl.Global,
	renderer:    ^Renderer,
	events:      struct {
		new_surface: wl.Signal,
		destroy:     wl.Signal,
	},
	WLR_PRIVATE: struct {
		display_destroy:  wl.Listener,
		renderer_destroy: wl.Listener,
	},
}
foreign wlroots {
	@(link_name = "wlr_compositor_create")
	CreateCompositor :: proc(_: ^wl.Display, _: c.uint32_t, _: ^Renderer) -> ^Compositor ---
}

