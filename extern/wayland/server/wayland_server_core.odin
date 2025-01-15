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
OutputSubpixel :: enum c.int {
	Unknown,
	None,
	HorizontalRGB,
	HorizontalBGR,
	VerticalRGB,
	VerticalBGR,
}
OutputTransform :: enum c.int {
	Normal,
	t90,
	t180,
	t270,
	Flipped,
	Flipped_90,
	Flipped_180,
	Flipped_270,
}
DataDeviceManagerDndAction :: enum c.int {
	None,
	Copy,
	Move,
	Ask,
}
PointerAxisRelativeDirection :: enum c.int {
	Identical,
	Inverted,
}
PointerButtonState :: enum c.int {
	Released,
	Pressed,
}
PointerAxis :: enum c.int {
	VerticalScroll,
	HorizontalScroll,
}
PointerAxisSource :: enum c.int {
	Wheel,
	Finger,
	Continuous,
	Wheel_Tilt,
}
KeyboardKeyState :: enum c.int {
	Released,
	Pressed,
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

	@(link_name = "wl_list_remove")
	ListRemove :: proc(_: ^List) ---

	@(link_name = "wl_display_add_socket_auto")
	AddDisplaySocketAuto :: proc(_: ^Display) -> cstring ---

	@(link_name = "wl_display_terminate")
	TerminateDisplay :: proc(_: ^Display) ---
}

AddSignal :: proc(signal: ^Signal, listener: ^Listener) {
	ListInsert(signal.listener_list.prev, &listener.link)
}
