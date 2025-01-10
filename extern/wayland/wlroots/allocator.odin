package wlroots
import wl "../server"
import "core:c"
when ODIN_OS == .Linux do foreign import wlroots "system:libwlroots-0.19.so"

Allocator :: struct {
	impl:        ^AllocatorInterface,
	buffer_caps: c.uint32_t,
	events:      struct {
		destroy: wl.Signal,
	},
}
AllocatorInterface :: struct {
	create_buffer: proc(
		alloc: ^Allocator,
		width: c.int,
		height: c.int,
		format: ^DRMFormat,
	) -> ^Buffer,
	destroy:       proc(alloc: ^Allocator),
}

foreign wlroots {
	@(link_name = "wlr_allocator_autocreate")
	AutoCreateAllocator :: proc(_: ^Backend, _: ^Renderer) -> ^Allocator ---

	@(link_name = "wlr_allocator_destroy")
	DestroyAllocator :: proc(_: ^Allocator) ---
}

