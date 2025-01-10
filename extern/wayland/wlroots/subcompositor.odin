package wlroots
import wl "../server"
import "core:c"
when ODIN_OS == .Linux do foreign import wlroots "system:libwlroots-0.19.so"

SubCompositor :: struct {
	global:          ^wl.Global,
	display_destroy: wl.Listener,
	events:          struct {
		destroy: wl.Signal,
	},
}
foreign wlroots {
	@(link_name = "wlr_subcompositor_create")
	CreateSubCompositor :: proc(_: ^wl.Display) -> ^SubCompositor ---
}

