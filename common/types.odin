package common
import wl "../extern/wayland/server"
import wlr "../extern/wayland/wlroots"
import "core:c/libc"
SadeServer :: struct {
	display:          ^wl.Display,
	event_loop:       ^wl.EventLoop,
	backend:          ^wlr.Backend,
	renderer:         ^wlr.Renderer,
	allocator:        ^wlr.Allocator,
	output_layout:    ^wlr.OutputLayout,
	outputs:          wl.List,
	new_output:       wl.Listener,
	scene:            ^wlr.Scene,
	scene_layout:     ^wlr.SceneOutputLayout,
	toplevels:        wl.List,
	xdg_shell:        ^wlr.XdgShell,
	new_xdg_toplevel: wl.Listener,
	new_xdg_popup:    wl.Listener,
	cursor:           ^wlr.Cursor,
	cursor_mgr:       ^wlr.XCursorManager,
	cursor_motion:    wl.Listener,
	keyboards:        wl.List,
	seat:             ^wlr.Seat,
	new_input:        wl.Listener,
	grab_x, grab_y:   f64,
	cursor_mode:      SadeCursorMode,
	grabbed_toplevel: ^SadeToplevel,
}
SadeToplevel :: struct {
	link:               wl.List,
	server:             ^SadeServer,
	scene_tree:         ^wlr.SceneTree,
	map_:               wl.Listener,
	unmap_:             wl.Listener,
	commit:             wl.Listener,
	destroy:            wl.Listener,
	request_mode:       wl.Listener,
	request_resize:     wl.Listener,
	request_maximize:   wl.Listener,
	request_fullscreen: wl.Listener,
}
SadeOutput :: struct {
	link:          wl.List,
	server:        ^SadeServer,
	wlr_output:    ^wlr.Output,
	frame:         wl.Listener,
	request_state: wl.Listener,
	destroy:       wl.Listener,
}
SadeCursorMode :: enum {
	Passthrough,
	Move,
	Resize,
}
Calloc :: proc($T: typeid) -> ^T {
	//wlroots makes me do this
	return cast(^T)libc.calloc(1, size_of(T))
}
