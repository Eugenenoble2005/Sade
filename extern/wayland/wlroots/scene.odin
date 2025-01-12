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
	type:    SceneNodeType,
	parent:  ^SceneTree,
	link:    wl.List,
	enabled: c.bool,
	x, y:    c.int,
	events:  struct {
		destroy: wl.Signal,
	},
	data:    rawptr,
	addons:  AddonSet,
	visible: pixman.Region32,
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
	output:                    ^Output,
	link:                      wl.List,
	scene:                     ^Scene,
	addon:                     Addon,
	damage_ring:               DamageRing,
	x, y:                      c.int,
	events:                    struct {
		destroy: wl.Signal,
	},
	WLR_PRIVATE:               struct {},
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
}
