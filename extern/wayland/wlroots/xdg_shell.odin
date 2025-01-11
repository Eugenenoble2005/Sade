package wlroots
import pixman "../../pixman"
import wl "../server"
import "core:c"
when ODIN_OS == .Linux do foreign import wlroots "system:libwlroots-0.19.so"

XdgShell :: struct {
	global:          ^wl.Global,
	version:         c.uint32_t,
	clients:         wl.List,
	popup_grabs:     wl.List,
	ping_timeout:    c.uint32_t,
	display_destroy: wl.Listener,
	events:          struct {
		new_surface:  wl.Signal,
		new_toplevel: wl.Signal,
		new_popup:    wl.Signal,
		destroy:      wl.Signal,
	},
	data:            rawptr,
}

XdgClient :: struct {
	shell:       ^XdgShell,
	resource:    ^wl.Resource,
	client:      ^wl.Client,
	surfaces:    wl.List,
	link:        wl.List,
	ping_serial: c.uint32_t,
	ping_timer:  ^wl.EventSource,
}

foreign wlroots {
	@(link_name = "wlr_xdg_shell_create")
	CreateXdgShell :: proc(_: ^wl.Display, _: c.uint32_t) -> ^XdgShell ---
}

