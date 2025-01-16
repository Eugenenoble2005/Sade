package wlroots
import "../../pixman"
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
Surface :: struct {
	resource:         ^wl.Resource,
	compositor:       ^Compositor,
	buffer:           ^ClientBuffer,
	buffer_damage:    pixman.Region32,
	opaque_region:    pixman.Region32,
	input_region:     pixman.Region32,
	current, pending: SurfaceState,
	cached:           wl.List,
	mapped:           c.bool,
	role:             ^SurfaceRole,
	role_resource:    ^wl.Resource,
	events:           struct {
		client_commit:  wl.Signal,
		commit:         wl.Signal,
		map_:           wl.Signal, /////todo
		unmap:          wl.Signal,
		new_subsurface: wl.Signal,
		destroy:        wl.Signal,
	},
	current_outputs:  wl.List,
	addons:           AddonSet,
	data:             rawptr,
	WLR_PRIVATE:      struct {
		role_resource_destroy:           wl.Listener,
		previous:                        struct {
			scale:                       c.int32_t,
			transform:                   wl.OutputTransform,
			width, height:               c.int,
			buffer_width, buffer_height: c.int,
		},
		unmap_commit:                    c.bool,
		opaque:                          c.bool,
		handling_commit:                 c.bool,
		pending_rejected:                c.bool,
		preferred_buffer_scale:          c.int32_t,
		preferred_buffer_transform_sent: c.bool,
		preferred_buffer_transform:      wl.OutputTransform,
		synced:                          wl.List,
		synced_len:                      c.size_t,
		pending_buffer_resource:         ^wl.Resource,
		pending_buffer_resource_destroy: wl.Listener,
	},
}
SurfaceState :: struct {
	committed:                     c.uint32_t,
	seq:                           c.uint32_t,
	buffer:                        ^Buffer,
	dx, dy:                        c.int32_t,
	surface_damage, buffer_damage: pixman.Region32,
	opaque, input:                 pixman.Region32,
	transform:                     wl.OutputTransform,
	scale:                         c.int32_t,
	frame_callback_list:           wl.List,
	width, height:                 c.int,
	buffer_width, buffer_height:   c.int,
	subsurfaces_below:             wl.List,
	subsurfaces_above:             wl.List,
	viewport:                      struct {
		has_src, has_dst:      c.bool,
		src:                   FBox,
		dst_width, dst_height: c.int,
	},
	cached_state_locks:            c.size_t,
	cached_state_link:             wl.List,
	synced:                        wl.Array,
}
SurfaceRole :: struct {
	name:          cstring,
	no_object:     c.bool,
	client_commit: proc(surface: ^Surface),
	commit:        proc(surface: ^Surface),
	map_:          proc(surface: ^Surface),
	unmap:         proc(surface: ^Surface),
	destroy:       proc(surface: ^Surface),
}
SurfaceSynced :: struct {
	surface: ^Surface,
	impl:    ^struct {}, //TODO,
	link:    wl.List,
	index:   c.size_t,
}
foreign wlroots {
	@(link_name = "wlr_compositor_create")
	CreateCompositor :: proc(_: ^wl.Display, _: c.uint32_t, _: ^Renderer) -> ^Compositor ---
}
