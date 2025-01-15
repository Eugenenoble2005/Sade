package events
import wl "../extern/wayland/server"
import wlr "../extern/wayland/wlroots"
import "core:fmt"
//if anything breaks, check this proc
newXdgToplevel :: proc(listener: ^wl.Listener, data: rawptr) {
	wlr.Log(.Info, "NEW TOPLEVEL")
	sade: ^SadeServer = container_of(listener, SadeServer, "new_xdg_toplevel")
	TOPLEVEL: ^wlr.XdgToplevel = cast(^wlr.XdgToplevel)data
	fmt.println("Attempted to create  a new toplevel")
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

	// sade_toplevel.unmap_.notify = UnmapXdgToplevel
	// wl.AddSignal(&TOPLEVEL.base.surface.events.unmap, &sade_toplevel.unmap_)

	sade_toplevel.commit.notify = CommitXdgToplevel
	wl.AddSignal(&TOPLEVEL.base.surface.events.commit, &sade_toplevel.commit)

	// sade_toplevel.destroy.notify = DestroyXdgToplevel
	// wl.AddSignal(&TOPLEVEL.events.destroy, &sade_toplevel.destroy)

	// //movement
	// sade_toplevel.request_move.notify = RequestMoveXdgToplevel
	// wl.AddSignal(&TOPLEVEL.events.request_move, &sade_toplevel.request_move)

	// sade_toplevel.request_resize.notify = RequestResizeXdgToplevel
	// wl.AddSignal(&TOPLEVEL.events.request_resize, &sade_toplevel.request_resize)

	// sade_toplevel.request_maximize.notify = RequestMaximizeXdgToplevel
	// wl.AddSignal(&TOPLEVEL.events.request_maximize, &sade_toplevel.request_maximize)

	// sade_toplevel.request_fullscreen.notify = RequestFullscreenXdgToplevel
	// wl.AddSignal(&TOPLEVEL.events.request_fullscreen, &sade_toplevel.request_fullscreen)

}
MapXdgToplevel :: proc(listener: ^wl.Listener, data: rawptr) {
	sade_toplevel := container_of(listener, SadeToplevel, "map_")
	wl.ListInsert(&sade_toplevel.server.toplevels, &sade_toplevel.link)
	FocusToplevel(sade_toplevel)
}
UnmapXdgToplevel :: proc(listener: ^wl.Listener, data: rawptr) {
	sade_toplevel := container_of(listener, SadeToplevel, "unmap_")
	if sade_toplevel == sade_toplevel.server.grabbed_toplevel {
		//reset cursor here 
	}
	wl.ListRemove(&sade_toplevel.link)
}
CommitXdgToplevel :: proc(listener: ^wl.Listener, data: rawptr) {
	fmt.println("Commiting surface")
	sade_toplevel := container_of(listener, SadeToplevel, "commit")
	if sade_toplevel.toplevel.base.initial_commit {
		wlr.SetXdgToplevelSize(sade_toplevel.toplevel, 0, 0)
	}
}
DestroyXdgToplevel :: proc(listener: ^wl.Listener, data: rawptr) {
	sade_toplevel := container_of(listener, SadeToplevel, "destroy")

	wl.ListRemove(&sade_toplevel.map_.link)
	wl.ListRemove(&sade_toplevel.unmap_.link)
	wl.ListRemove(&sade_toplevel.commit.link)
	wl.ListRemove(&sade_toplevel.destroy.link)
	wl.ListRemove(&sade_toplevel.request_move.link)
	wl.ListRemove(&sade_toplevel.request_resize.link)
	wl.ListRemove(&sade_toplevel.request_resize.link)
	wl.ListRemove(&sade_toplevel.request_maximize.link)
	wl.ListRemove(&sade_toplevel.request_fullscreen.link)
	CFree(sade_toplevel)
}
RequestMoveXdgToplevel :: proc(listener: ^wl.Listener, data: rawptr) {}
RequestResizeXdgToplevel :: proc(listener: ^wl.Listener, data: rawptr) {}
RequestMaximizeXdgPopup :: proc(listener: ^wl.Listener, data: rawptr) {}
RequestFullscreenXdgToplevel :: proc(listener: ^wl.Listener, data: rawptr) {}
RequestMaximizeXdgToplevel :: proc(listener: ^wl.Listener, data: rawptr) {}


newXdgPopup :: proc(listener: ^wl.Listener, data: rawptr) {}

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
