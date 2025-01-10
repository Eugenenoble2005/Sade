package wlroots
import pixman "../../pixman"
import wl "../server"
import "core:c"
when ODIN_OS == .Linux do foreign import wlroots "system:libwlroots-0.19.so"

Output :: struct {
	impl:                    ^struct {},
	backend:                 ^Backend,
	event_loop:              ^wl.EventLoop,
	global:                  ^wl.Global,
	resources:               wl.List,
	name:                    cstring,
	description:             cstring,
	make, model, serial:     cstring,
	phys_width, phys_height: c.int32_t,
	modes:                   wl.List,
	current_mode:            ^OutputMode,
	width, height:           c.int32_t,
	refresh:                 c.int32_t,
	enabled:                 c.bool,
	scale:                   c.float,
	subpixel:                wl.OutputSubpixel,
	transform:               wl.OutputTransform,
	adaptive_sync_status:    OutputAdaptiveSyncStatus,
	render_format:           c.uint32_t,
	adaptive_sync_supported: c.bool,
	needs_frame:             c.bool,
	frame_pending:           c.bool,
	non_desktop:             c.bool,
	commit_seq:              c.uint32_t,
	events:                  struct {
		frame:         wl.Signal,
		damage:        wl.Signal,
		needs_frame:   wl.Signal,
		precommit:     wl.Signal,
		commit:        wl.Signal,
		present:       wl.Signal,
		bind:          wl.Signal,
		description:   wl.Signal,
		request_state: wl.Signal,
		destroy:       wl.Signal,
	},
	idle_frame:              ^wl.EventSource,
	idle_done:               ^wl.EventSource,
	attach_render_locks:     c.int,
	cursors:                 wl.List,
	hardware_cursor:         ^OutputCursor,
	cursor_swapchain:        ^Swapchain,
	cursor_front_buffer:     ^Buffer,
	software_cursor_locks:   c.int,
	layers:                  wl.List,
	allocator:               ^Allocator,
	renderer:                ^Renderer,
	swapchain:               ^Swapchain,
	addons:                  AddonSet,
	data:                    rawptr,
	WLR_PRIVATE:             struct {
		display_destroy: wl.Listener,
	},
}
OutputState :: struct {
	committed:             c.uint32_t,
	allow_reconfiguration: c.bool,
	damage:                pixman.Region32,
	enabled:               c.bool,
	scale:                 c.float,
	transform:             wl.OutputTransform,
	adaptive_sync_enabled: c.bool,
	render_format:         c.uint32_t,
	subpixel:              wl.OutputSubpixel,
	buffer:                ^Buffer,
	buffer_src_box:        FBox,
	buffer_dst_box:        Box,
	tearing_page_flip:     c.bool,
	mode_type:             OutputStateModeType,
	mode:                  ^OutputMode,
	custom_mode:           struct {
		width, height: c.int32_t,
		refresh:       c.int32_t,
	},
	gamma_lut:             ^c.uint16_t,
	gamma_lut_size:        c.size_t,
	layers:                ^OutputLayerState,
	layers_len:            c.size_t,
	wait_timeline:         ^DRMSyncObjTimeline,
	wait_point:            c.uint64_t,
	signal_timeline:       ^DRMSyncObjTimeline,
	signal_point:          c.uint64_t,
}
OutputMode :: struct {
	width, height:        c.int32_t,
	refresh:              c.int32_t,
	preferred:            c.bool,
	picture_aspect_ratio: OutputModeAspectRatio,
	link:                 wl.List,
}
OutputCursor :: struct {
	output:               ^Output,
	x, y:                 c.double,
	enabled:              c.bool,
	visible:              c.bool,
	width, height:        c.uint32_t,
	src_box:              FBox,
	transform:            wl.OutputTransform,
	hotspot_x, hotspot_y: c.int32_t,
	texture:              ^Texture,
	own_texture:          c.bool,
	link:                 wl.List,
	wait_point:           c.uint64_t,
	WLR_PRIVATE:          struct {
		renderer_destroy: wl.Listener,
	},
}

OutputStateModeType :: enum {
	Fixed,
	Custom,
}
OutputModeAspectRatio :: enum {
	None,
	r4_3,
	r16_9,
	r64_27,
	r256_135,
}
OutputAdaptiveSyncStatus :: enum {
	Disabled,
	Enabled,
}
foreign wlroots {
	@(link_name = "wlr_output_state_init")
	InitOutputState :: proc(_: ^OutputState) ---

	@(link_name = "wlr_output_init_render")
	InitOutputRender :: proc(_: ^Output, _: ^Allocator, _: ^Renderer) -> c.bool ---

	@(link_name = "wlr_output_state_set_enabled")
	SetOutputStateEnabledStatus :: proc(_: ^OutputState, _: c.bool) ---

	@(link_name = "wlr_output_commit_state")
	CommitOutputState :: proc(_: ^Output, _: ^OutputState) -> c.bool ---

	@(link_name = "wlr_output_state_finish")
	FinishOutputState :: proc(_: ^OutputState) ---

	@(link_name = "wlr_output_preferred_mode")
	PreferredOutputMode :: proc(_: ^Output) -> ^OutputMode ---

	@(link_name = "wlr_output_state_set_mode")
	SetOutputStateMode :: proc(_: ^OutputState, _: ^OutputMode) ---


}

