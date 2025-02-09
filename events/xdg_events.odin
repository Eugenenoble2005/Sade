package events
import wl "../extern/wayland/server"
import wlr "../extern/wayland/wlroots"
import "core:c"
import "core:fmt"
//if anything breaks, check this proc
newXdgToplevel :: proc(listener: ^wl.Listener, data: rawptr) {
	sade: ^SadeServer = container_of(listener, SadeServer, "new_xdg_toplevel")
	TOPLEVEL: ^wlr.XdgToplevel = cast(^wlr.XdgToplevel)data
	//alloc toplevel for this surface
	sade_toplevel := Calloc(SadeToplevel)
	sade_toplevel.server = sade
	sade_toplevel.toplevel = TOPLEVEL
	sade_toplevel.scene_tree = wlr.CreateXdgSurfaceScene(
		&sade_toplevel.server.scene.tree,
		TOPLEVEL.base,
	)
	sade_toplevel.scene_tree.node.data = sade_toplevel
	TOPLEVEL.base.data = sade_toplevel.scene_tree

	sade_toplevel.map_.notify = MapXdgToplevel
	wl.AddSignal(&TOPLEVEL.base.surface.events.map_, &sade_toplevel.map_)

	sade_toplevel.unmap_.notify = UnmapXdgToplevel
	wl.AddSignal(&TOPLEVEL.base.surface.events.unmap, &sade_toplevel.unmap_)

	sade_toplevel.commit.notify = CommitXdgToplevel
	wl.AddSignal(&TOPLEVEL.base.surface.events.commit, &sade_toplevel.commit)

	sade_toplevel.destroy.notify = DestroyXdgToplevel
	wl.AddSignal(&TOPLEVEL.events.destroy, &sade_toplevel.destroy)

	//movement
	sade_toplevel.request_move.notify = RequestMoveXdgToplevel
	wl.AddSignal(&TOPLEVEL.events.request_move, &sade_toplevel.request_move)

	sade_toplevel.request_resize.notify = RequestResizeXdgToplevel
	wl.AddSignal(&TOPLEVEL.events.request_resize, &sade_toplevel.request_resize)

	sade_toplevel.request_maximize.notify = RequestMaximizeXdgToplevel
	wl.AddSignal(&TOPLEVEL.events.request_maximize, &sade_toplevel.request_maximize)

	sade_toplevel.request_fullscreen.notify = RequestFullscreenXdgToplevel
	wl.AddSignal(&TOPLEVEL.events.request_fullscreen, &sade_toplevel.request_fullscreen)

}
MapXdgToplevel :: proc(listener: ^wl.Listener, data: rawptr) {
	sade_toplevel := container_of(listener, SadeToplevel, "map_")
	wl.ListInsert(&sade_toplevel.server.toplevels, &sade_toplevel.link)
	fmt.println(sade_toplevel.toplevel.title)
	FocusToplevel(sade_toplevel)
}
UnmapXdgToplevel :: proc(listener: ^wl.Listener, data: rawptr) {
	sade_toplevel := container_of(listener, SadeToplevel, "unmap_")
	if sade_toplevel == sade_toplevel.server.grabbed_toplevel {
		ResetCursorMode(sade_toplevel.server)
	}
	wl.ListRemove(&sade_toplevel.link)
}
CommitXdgToplevel :: proc(listener: ^wl.Listener, data: rawptr) {
	sade_toplevel := container_of(listener, SadeToplevel, "commit")
	if sade_toplevel.toplevel.base.initial_commit {
		wlr.SetXdgToplevelSize(sade_toplevel.toplevel, 0, 0)
	}
}
DestroyXdgToplevel :: proc(listener: ^wl.Listener, data: rawptr) {
	wlr.Log(.Info, "Closing toplevel")
	sade_toplevel := container_of(listener, SadeToplevel, "destroy")
	wl.ListRemove(&sade_toplevel.map_.link)
	wl.ListRemove(&sade_toplevel.unmap_.link)
	wl.ListRemove(&sade_toplevel.commit.link)
	wl.ListRemove(&sade_toplevel.destroy.link)
	wl.ListRemove(&sade_toplevel.request_move.link)
	wl.ListRemove(&sade_toplevel.request_resize.link)
	wl.ListRemove(&sade_toplevel.request_maximize.link)
	wl.ListRemove(&sade_toplevel.request_fullscreen.link)
	CFree(sade_toplevel)
}
RequestMoveXdgToplevel :: proc(listener: ^wl.Listener, data: rawptr) {
	sade_toplevel := container_of(listener, SadeToplevel, "request_move")
	BeginInteractive(sade_toplevel, .Move, 0)
	fmt.println("Client requested to be moved")
}
RequestResizeXdgToplevel :: proc(listener: ^wl.Listener, data: rawptr) {
	EVENT := cast(^wlr.XdgToplevelResizeEvent)data
	sade_toplevel := container_of(listener, SadeToplevel, "request_resize")
	BeginInteractive(sade_toplevel, .Resize, EVENT.edges)
}
RequestMaximizeXdgPopup :: proc(listener: ^wl.Listener, data: rawptr) {}
RequestFullscreenXdgToplevel :: proc(listener: ^wl.Listener, data: rawptr) {}
RequestMaximizeXdgToplevel :: proc(listener: ^wl.Listener, data: rawptr) {}


newXdgPopup :: proc(listener: ^wl.Listener, data: rawptr) {
	POPUP := cast(^wlr.XdgPopup)data
	sade_popup := Calloc(SadePopup)
	sade_popup.popup = POPUP

	parent := wlr.TryGetXdgSurfaceFromSurface(POPUP.parent)
	assert(parent != nil)

	parent_tree := parent.data
	POPUP.base.data = wlr.CreateXdgSurfaceScene(cast(^wlr.SceneTree)parent_tree, POPUP.base)

	sade_popup.commit.notify = XdgPopupCommit
	wl.AddSignal(&POPUP.base.surface.events.commit, &sade_popup.commit)

	sade_popup.destroy.notify = XdgPopupDestroy
	wl.AddSignal(&POPUP.base.surface.events.destroy, &sade_popup.destroy)
}

FocusToplevel :: proc(sade_toplevel: ^SadeToplevel) {
	if sade_toplevel == nil do return
	sade := sade_toplevel.server
	SEAT := sade.seat
	prev_surface: ^wlr.Surface = SEAT.keyboard_state.focused_surface
	surface: ^wlr.Surface = sade_toplevel.toplevel.base.surface
	//do not focus already focused surface
	if prev_surface == surface do return

	if prev_surface != nil {
		prev_toplevel := wlr.TryGetXdgToplevelFromSurface(prev_surface)
		if prev_surface != nil {
			wlr.SetActivatedXdgToplevel(prev_toplevel, false)
		}
	}
	KEYBOARD := wlr.GetSeatKeyboard(SEAT)
	wlr.RaiseSceneNodeToTop(&sade_toplevel.scene_tree.node)
	wl.ListRemove(&sade_toplevel.link)
	wl.ListInsert(&sade.toplevels, &sade_toplevel.link)
	//activate new surface
	wlr.SetActivatedXdgToplevel(sade_toplevel.toplevel, true)
	if KEYBOARD != nil {
		wlr.SeatKeyboardNotifyEnter(
			SEAT,
			surface,
			KEYBOARD.keycodes[:], //will probably cause issues
			KEYBOARD.num_keycodes,
			&KEYBOARD.modifiers,
		)
	}
}
//might move this to another file
// i'd be lying if i said i understand how this shit works
DesktopTopLevelAt :: proc(
	sade: ^SadeServer,
	lx: f64,
	ly: f64,
	surface: ^^wlr.Surface,
	sx: ^f64,
	sy: ^f64,
) -> ^SadeToplevel {
	NODE := wlr.GetSceneNodeAt(&sade.scene.tree.node, lx, ly, sx, sy)
	if NODE == nil || NODE.type != .Buffer do return nil
	scene_buffer := wlr.GetSceneBufferFromNode(NODE)
	scene_surface := wlr.TryGetSceneSurfaceFromBuffer(scene_buffer)
	if scene_surface == nil do return nil
	surface^ = scene_surface.surface
	tree := NODE.parent
	for tree != nil && tree.node.data == nil {
		tree = tree.node.parent
	}
	return cast(^SadeToplevel)tree.node.data
}

BeginInteractive :: proc(sade_toplevel: ^SadeToplevel, mode: SadeCursorMode, edges: u32) {
	sade := sade_toplevel.server
	sade.grabbed_toplevel = sade_toplevel
	sade.cursor_mode = mode

	if mode == .Move {
		sade.grab_x = sade.cursor.x - cast(f64)sade_toplevel.scene_tree.node.x
		sade.grab_y = sade.cursor.y - cast(f64)sade_toplevel.scene_tree.node.y
	} else if mode == .Resize {
		geo_box: ^wlr.Box = &sade_toplevel.toplevel.base.geometry
		border_x: f64 =
			cast(f64)(sade_toplevel.scene_tree.node.x + geo_box.x) +
			cast(f64)((edges & cast(u32)wlr.Edges.Right != 0) ? geo_box.width : 0)

		border_y: f64 =
			cast(f64)(sade_toplevel.scene_tree.node.y + geo_box.y) +
			cast(f64)((edges & cast(u32)wlr.Edges.Bottom != 0) ? geo_box.height : 0)

		sade.grab_x = sade.cursor.x - cast(f64)border_x
		sade.grab_y = sade.cursor.y - cast(f64)border_y

		sade.grab_geobox = geo_box^
		sade.grab_geobox.x += sade_toplevel.scene_tree.node.x
		sade.grab_geobox.y += sade_toplevel.scene_tree.node.y

		fmt.println(sade.grab_geobox.x)
		fmt.println(sade.grab_geobox.y)
		sade.resize_edges = edges
	}

}
XdgPopupCommit :: proc(listener: ^wl.Listener, data: rawptr) {
	sade_popup := container_of(listener, SadePopup, "commit")
	if sade_popup.popup.base.initial_commit {
		wlr.ScheduleXdgSurfaceConfiguration(sade_popup.popup.base)
	}
}

XdgPopupDestroy :: proc(listener: ^wl.Listener, data: rawptr) {
	sade_popup := container_of(listener, SadePopup, "destroy")
	wl.ListRemove(&sade_popup.commit.link)
	wl.ListRemove(&sade_popup.destroy.link)

	CFree(sade_popup)
}
