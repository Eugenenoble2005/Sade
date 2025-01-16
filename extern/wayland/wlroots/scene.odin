package wlroots
import "../../pixman"
import wl "../server"
import "core:c"
import "core:sys/posix"
when ODIN_OS == .Linux do foreign import wlroots "system:libwlroots-0.19.so"

Scene :: struct {
	tree:                         SceneTree,
	outputs:                      wl.List,
	linux_dmabuf_v1:              LinuxDMABufV1,
	linux_dmabuf_v1_destroy:      wl.Listener,
	debug_damage_option:          SceneDebugDamageOption,
	direct_scanout:               c.bool,
	calculate_visibility:         c.bool,
	highlight_transparent_region: c.bool,
}

SceneTree :: struct {
	node:     SceneNode,
	children: wl.List,
}

SceneNode :: struct {
	type:        SceneNodeType,
	parent:      ^SceneTree,
	link:        wl.List,
	enabled:     c.bool,
	x, y:        c.int,
	events:      struct {
		destroy: wl.Signal,
	},
	data:        rawptr,
	addons:      AddonSet,
	WLR_PRIVATE: struct {
		visible: pixman.Region32,
	},
}
SceneOutputLayout :: struct {
	layout:         ^OutputLayout,
	scene:          ^Scene,
	outputs:        wl.List,
	layout_change:  wl.Listener,
	layout_destroy: wl.Listener,
	scene_destroy:  wl.Listener,
}

SceneNodeType :: enum c.int {
	Tree,
	Rect,
	Buffer,
}
SceneDebugDamageOption :: enum c.int {
	None,
	Renderer,
	Highlight,
}
SceneOutput :: struct {
	output:      ^Output,
	link:        wl.List,
	scene:       ^Scene,
	addon:       Addon,
	damage_ring: DamageRing,
	x, y:        c.int,
	events:      struct {
		destroy: wl.Signal,
	},
	WLR_PRIVATE: struct {
		pending_commit_damage:     pixman.Region32,
		index:                     c.uint8_t,
		prev_scanout:              c.bool,
		gamma_lut_changed:         c.bool,
		gamma_lut:                 ^GammaControlV1,
		output_commit:             wl.Listener,
		output_damage:             wl.Listener,
		output_needs_frame:        wl.Listener,
		damager_highlight_regions: wl.List,
		render_list:               wl.Array,
		in_timeline:               ^DRMSyncObjTimeline,
		in_point:                  c.uint64_t,
	},
}
SceneOutputStateOptions :: struct {
	timer:           ^SceneTimer,
	color_transform: ^ColorTransform,
	swapchain:       ^Swapchain,
}
SceneTimer :: struct {
	pre_render_duration: c.int64_t,
	render_timer:        ^RenderTimer,
}
SceneBuffer :: struct {
	node:                  SceneNode,
	buffer:                ^Buffer,
	events:                struct {
		outputs_update: wl.Signal,
		output_enter:   wl.Signal,
		output_leave:   wl.Signal,
		output_sample:  wl.Signal,
		frame_done:     wl.Signal,
	},
	point_accepts_input:   proc(buffer: ^SceneBuffer, sx: ^c.double, sy: ^c.double) -> c.bool,
	primary_output:        ^SceneOutput,
	opacity:               c.bool,
	filter_mode:           ScaleFilterMode,
	src_box:               FBox,
	dst_width, dst_height: c.int,
	transform:             wl.OutputTransform,
	opaque_region:         pixman.Region32,
	WLR_PRIVATE:           struct {
		active_outputs:              c.uint64_t,
		texture:                     ^Texture,
		prev_feedback_options:       LinuxDMABufFeedbackV1InitOptions,
		own_buffer:                  c.bool,
		buffer_width, buffer_height: c.int,
		buffer_is_opaque:            c.bool,
		wait_timeline:               ^DRMSyncObjTimeline,
		wait_point:                  c.uint64_t,
		buffer_release:              wl.Listener,
		renderer_destroy:            wl.Listener,
	},
}

SceneSurface :: struct {
	buffer:      ^SceneBuffer,
	surface:     ^Surface,
	WLR_PRIVATE: struct {
		clip:            Box,
		addon:           Addon,
		outputs_update:  wl.Listener,
		output_enter:    wl.Listener,
		output_leave:    wl.Listener,
		output_sample:   wl.Listener,
		frame_done:      wl.Listener,
		surface_destroy: wl.Listener,
		surface_commit:  wl.Listener,
	},
}
foreign wlroots {
	@(link_name = "wlr_scene_create")
	CreateScene :: proc() -> ^Scene ---

	@(link_name = "wlr_scene_attach_output_layout")
	AttachSceneToOutputLayout :: proc(_: ^Scene, _: ^OutputLayout) -> ^SceneOutputLayout ---

	@(link_name = "wlr_scene_node_set_position")
	SetSceneNodePosition :: proc(_: ^SceneNode, _: c.int, _: c.int) ---

	@(link_name = "wlr_scene_get_scene_output")
	GetSceneOutput :: proc(_: ^Scene, _: ^Output) -> ^SceneOutput ---

	@(link_name = "wlr_scene_output_create")
	CreateOutputScene :: proc(_: ^Scene, _: ^Output) -> ^SceneOutput ---

	@(link_name = "wlr_scene_output_layout_add_output")
	AddSceneOutputLayoutToOutput :: proc(_: ^SceneOutputLayout, _: ^OutputLayoutOutput, _: ^SceneOutput) ---

	@(link_name = "wlr_scene_output_commit")
	CommitOutputScene :: proc(_: ^SceneOutput, _: ^SceneOutputStateOptions) -> c.bool ---

	@(link_name = "wlr_scene_output_send_frame_done")
	SendOutputFrameDone :: proc(_: ^SceneOutput, _: ^posix.timespec) ---

	@(link_name = "wlr_scene_xdg_surface_create")
	CreateXdgSurfaceScene :: proc(_: ^SceneTree, _: ^XdgSurface) -> ^SceneTree ---

	@(link_name = "wlr_scene_node_raise_to_top")
	RaiseSceneNodeToTop :: proc(_: ^SceneNode) ---

	@(link_name = "wlr_scene_node_at")
	GetSceneNodeAt :: proc(_: ^SceneNode, _: c.double, _: c.double, _: ^c.double, _: ^c.double) -> ^SceneNode ---

	@(link_name = "wlr_scene_buffer_from_node")
	GetSceneBufferFromNode :: proc(_: ^SceneNode) -> ^SceneBuffer ---

	@(link_name = "wlr_scene_surface_try_from_buffer")
	TryGetSceneSurfaceFromBuffer :: proc(_: ^SceneBuffer) -> ^SceneSurface ---
}
