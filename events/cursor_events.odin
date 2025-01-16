package events
import wl "../extern/wayland/server"
import wlr "../extern/wayland/wlroots"
import "core:fmt"

cursorMotion :: proc(listener: ^wl.Listener, data: rawptr) {
	sade: ^SadeServer = container_of(listener, SadeServer, "cursor_motion")
	POINTER_MOTION_EVENT := cast(^wlr.PointerMotionEvent)data
	wlr.MoveCursor(
		sade.cursor,
		&POINTER_MOTION_EVENT.pointer.base,
		POINTER_MOTION_EVENT.delta_x,
		POINTER_MOTION_EVENT.delta_y,
	)
	time := POINTER_MOTION_EVENT.time_msec
	ProcessCursorMotion(sade, time)
}
ResetCursorMode :: proc(sade: ^SadeServer) {
	sade.cursor_mode = .Passthrough
	sade.grabbed_toplevel = nil
}

cursorMotionAbsolute :: proc(listener: ^wl.Listener, data: rawptr) {
	sade := container_of(listener, SadeServer, "cursor_motion_absolute")
	EVENT := cast(^wlr.PointerMotionAbsoluteEvent)data
	wlr.WarpCursorAbsolute(sade.cursor, &EVENT.pointer.base, EVENT.x, EVENT.y)
	ProcessCursorMotion(sade, EVENT.time_msec)
}
ProcessCursorMotion :: proc(sade: ^SadeServer, time: u32) {
	if sade.cursor_mode == .Move {
		//move grabbed toplevel
		sade_toplevel := sade.grabbed_toplevel
		wlr.SetSceneNodePosition(
			&sade_toplevel.scene_tree.node,
			auto_cast sade.cursor.x - auto_cast sade.grab_x,
			auto_cast sade.cursor.y - auto_cast sade.grab_y, //auto cast int to float
		)
	} else if sade.cursor_mode == .Resize {
		return
	}
	if sade.cursor_mode != .Passthrough do return
	sx, sy: f64
	SEAT := sade.seat
	surface: ^wlr.Surface = nil
	sade_toplevel := DesktopTopLevelAt(sade, sade.cursor.x, sade.cursor.y, &surface, &sx, &sy)
	if sade_toplevel == nil {
		wlr.SetXcursor(sade.cursor, sade.cursor_mgr, "default")
	}
	if surface != nil {
		wlr.SeatPointerNotifyEnter(SEAT, surface, sx, sy)
		wlr.SeatPointerNotifyMotion(SEAT, time, sx, sy)
	} else {
		wlr.ClearSeatPointerFocus(SEAT)
	}
}

cursorButton :: proc(listener: ^wl.Listener, data: rawptr) {
	sade := container_of(listener, SadeServer, "cursor_button")
	EVENT := cast(^wlr.PointerButtonEvent)data
	wlr.SeatPointerNotifyButton(sade.seat, EVENT.time_msec, EVENT.button, EVENT.state)
	if EVENT.state == .Released {
		ResetCursorMode(sade)
	} else {
		//focus the client that was clicked on 
		sx, sy: f64
		surface: ^wlr.Surface
		sade_toplevel := DesktopTopLevelAt(sade, sade.cursor.x, sade.cursor.y, &surface, &sx, &sy)
		if sade_toplevel != nil {
			FocusToplevel(sade_toplevel)
		}
	}
}
