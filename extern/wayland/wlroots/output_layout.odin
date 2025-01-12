package wlroots
import wl "../server"
import "core:c"
when ODIN_OS == .Linux do foreign import wlroots "system:libwlroots-0.19.so"

OutputLayout :: struct {
	outputs:         wl.List,
	display:         ^wl.Display,
	events:          struct {
		add:     wl.Signal,
		change:  wl.Signal,
		destroy: wl.Signal,
	},
	data:            rawptr,
	display_destroy: wl.Listener,
}
OutputLayoutOutput :: struct {
	layout:          ^OutputLayout,
	output:          ^Output,
	x, y:            c.int,
	link:            wl.List,
	auto_configured: c.bool,
	events:          struct {
		destroy: wl.Signal,
	},
	WLR_PRIVATE:     struct {
		addon:  Addon,
		commit: wl.Listener,
	},
}
foreign wlroots {
	@(link_name = "wlr_output_layout_create")
	CreateOutputLayout :: proc(_: ^wl.Display) -> ^OutputLayout ---

	@(link_name = "wlr_output_layout_destroy")
	DestroyOutputLayout :: proc(_: ^OutputLayout) ---

	@(link_name = "wlr_output_layout_add_auto")
	AddOutputLayoutAuto :: proc(_: ^OutputLayout, _: ^Output) -> ^OutputLayoutOutput ---
}
