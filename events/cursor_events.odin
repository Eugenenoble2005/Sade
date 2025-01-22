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
			auto_cast sade.cursor.y - auto_cast sade.grab_y, //auto cast int to float, probably not the best way to do this
		)
	} else if sade.cursor_mode == .Resize {
		ProcessCursorResize(sade)
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
ProcessCursorResize :: proc(sade: ^SadeServer) {
	sade_toplevel := sade.grabbed_toplevel
	border_x: f64 = sade.cursor.x - sade.grab_x
	border_y: f64 = sade.cursor.y - sade.grab_y
	new_left: i32 = sade.grab_geobox.x
	new_right: i32 = sade.grab_geobox.x + sade.grab_geobox.width

	new_top: i32 = sade.grab_geobox.y
	new_bottom: i32 = sade.grab_geobox.y + sade.grab_geobox.height

	if sade.resize_edges & auto_cast wlr.Edges.Top != 0 {
		new_top = auto_cast border_y
		if new_top >= new_bottom {
			new_top = new_bottom - 1
		}
	} else if sade.resize_edges & auto_cast wlr.Edges.Bottom != 0 {
		new_bottom = auto_cast border_y
		if new_bottom <= new_top {
			new_bottom = new_top + 1
		}
	}
	if sade.resize_edges & auto_cast wlr.Edges.Left != 0 {
		new_left = auto_cast border_x
		if new_left >= new_right {
			new_left = new_right - 1
		}
	} else if sade.resize_edges & auto_cast wlr.Edges.Right != 0 {
		new_right = auto_cast border_x
		if new_right <= new_left {
			new_right = new_left + 1
		}
	}
	geo_box: ^wlr.Box = &sade_toplevel.toplevel.base.geometry
	wlr.SetSceneNodePosition(
		&sade_toplevel.scene_tree.node,
		new_left - geo_box.x,
		new_top - geo_box.y,
	)
	new_width: i32 = new_right - new_left
	new_height: i32 = new_bottom - new_top
	wlr.SetXdgToplevelSize(sade_toplevel.toplevel, new_width, new_height)

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
cursorAxis :: proc(listener: ^wl.Listener, data: rawptr) {
	sade := container_of(listener, SadeServer, "cursor_axis")
	EVENT := cast(^wlr.PointerAxisEvent)data
	wlr.SeatPointerNotifyAxis(
		sade.seat,
		EVENT.time_msec,
		EVENT.orientaion,
		EVENT.delta,
		EVENT.delta_discrete,
		EVENT.source,
		EVENT.relative_direction,
	)
}

cursorFrame :: proc(listener: ^wl.Listener, data: rawptr) {
	sade := container_of(listener, SadeServer, "cursor_frame")
	wlr.SeatPointerNotifyFrame(sade.seat)
}
