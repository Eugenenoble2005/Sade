package wlroots
import "../../pixman"
import wl "../server"
import "core:c"
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

SceneNodeType :: enum {
	Tree,
	Rect,
	Buffer,
}
SceneDebugDamageOption :: enum {
	None,
	Renderer,
	Highlight,
}

foreign wlroots {
	@(link_name = "wlr_scene_create")
	CreateScene :: proc() -> ^Scene ---

	@(link_name = "wlr_scene_attach_output_layout")
	AttachSceneToOutputLayout :: proc(_: ^Scene, _: ^OutputLayout) -> ^SceneOutputLayout ---

}

