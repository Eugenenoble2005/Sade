package wayland_server
when ODIN_OS == .Linux do foreign import wayland "system:libwayland-server.so"

Display :: struct {}
Global :: struct {}
EventLoop :: struct {}
Signal :: struct {
	listener_list: List,
}
List :: struct {
	prev: ^List,
	next: ^List,
}
Listener :: struct {
	link:   List,
	notify: proc(_: ^Listener, _: rawptr),
}
EventSource :: struct {}
OutputSubpixel :: enum {
	Unknown,
	None,
	HorizontalRGB,
	HorizontalBGR,
	VerticalRGB,
	VerticalBGR,
}
OutputTransform :: enum {
	Normal,
	t90,
	t180,
	t270,
	Flipped,
	Flipped_90,
	Flipped_180,
	Flipped_270,
}
foreign wayland {
	@(link_name = "wl_display_create")
	CreateDisplay :: proc() -> ^Display ---

	@(link_name = "wl_display_destroy")
	DestroyDisplay :: proc(_: ^Display) ---

	@(link_name = "wl_event_loop_create")
	CreateEventLoop :: proc() -> ^EventLoop ---

	@(link_name = "wl_display_get_event_loop")
	GetEventLoop :: proc(_: ^Display) -> ^EventLoop ---

	@(link_name = "wl_event_loop_destroy")
	DestroyEventLoop :: proc(_: ^EventLoop) ---

	@(link_name = "wl_display_run")
	RunDisplay :: proc(_: ^Display) ---

	@(link_name = "wl_list_init")
	InitList :: proc(_: ^List) ---

	@(link_name = "wl_list_insert")
	ListInsert :: proc(_: ^List, _: ^List) ---
}

AddSignal :: proc(signal: ^Signal, listener: ^Listener) {
	ListInsert(signal.listener_list.prev, &listener.link)
}

