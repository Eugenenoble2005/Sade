package wayland_server
import "core:c"
when ODIN_OS == .Linux do foreign import wayland "system:libwayland-server.so"

Display :: struct {}
Global :: struct {}
EventLoop :: struct {}
Signal :: struct {
	listener_list: List,
}
Array :: struct {
	size:  c.size_t,
	alloc: c.size_t,
	data:  rawptr,
}
Resource :: struct {
	object:         Object,
	destroy:        proc(resource: ^Resource),
	link:           List,
	destroy_signal: Signal,
	client:         ^Client,
	data:           rawptr,
}
Object :: struct {
	interface:      ^Interface,
	implementation: rawptr,
	id:             c.uint32_t,
}
Client :: struct {}
Interface :: struct {
	name:         cstring,
	version:      c.int,
	method_count: c.int,
	methods:      ^Message,
	event_count:  c.int,
	events:       ^Message,
}

Message :: struct {
	name:      cstring,
	signature: cstring,
	types:     ^^Interface,
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
DataDeviceManagerDndAction :: enum {
	None,
	Copy,
	Move,
	Ask,
}
PointerAxisRelativeDirection :: enum {
	Identical,
	Inverted,
}
PointerButtonState :: enum {
	Released,
	Pressed,
}
PointerAxis :: enum {
	VerticalScroll,
	HorizontalScroll,
}
PointerAxisSource :: enum {
	Wheel,
	Finger,
	Continuous,
	Wheel_Tilt,
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

	@(link_name = "wl_list_empty")
	IsListEmpty :: proc(_: ^List) -> c.int ---
}

AddSignal :: proc(signal: ^Signal, listener: ^Listener) {
	ListInsert(signal.listener_list.prev, &listener.link)
}
