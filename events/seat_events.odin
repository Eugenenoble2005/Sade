package events
import wl "../extern/wayland/server"
import wlr "../extern/wayland/wlroots"
import x11 "vendor:OpenGL"

seatRequestCursor :: proc(listener: ^wl.Listener, data: rawptr) {
	sade := container_of(listener, SadeServer, "request_cursor")
	EVENT := cast(^wlr.SeatPointerRequestSetCursorEvent)data
	focused_client := sade.seat.pointer_state.focused_client
	if focused_client == EVENT.seat_client do wlr.SetCursorSurface(sade.cursor, EVENT.surface, EVENT.hotspot_x, EVENT.hotspot_y)
}

seatRequestSetSelection :: proc(listener: ^wl.Listener, data: rawptr) {
	sade := container_of(listener, SadeServer, "request_set_selection")
	EVENT := cast(^wlr.SeatRequestSetSelectionEvent)data
	wlr.SetSeatSelection(sade.seat, EVENT.source, EVENT.serial)
}
