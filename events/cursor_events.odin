package events
import wl "../extern/wayland/server"
import wlr "../extern/wayland/wlroots"


cursorMotion :: proc(listener: ^wl.Listener, data: rawptr) {
	sade: ^SadeServer = container_of(listener, SadeServer, "cursor_motion")
	POINTER_MOTION_EVENT := cast(^wlr.PointerMotionEvent)data
	//move the cursor
	wlr.MoveCursor(
		sade.cursor,
		&POINTER_MOTION_EVENT.pointer.base,
		POINTER_MOTION_EVENT.delta_x,
		POINTER_MOTION_EVENT.delta_y,
	)
	if sade.cursor_mode == .Move {
		//process cursor move 
		return
	} else if sade.cursor_mode == .Resize {
		//process cursor resize
		return
	}
	//otherwise get toplevel and send cursor event
	//currently just set a static xcursor theme since i have not implemented any toplevels yet
	wlr.SetXcursor(sade.cursor, sade.cursor_mgr, auto_cast "default")

}
