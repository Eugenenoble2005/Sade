package events
import wl "../extern/wayland/server"
import wlr "../extern/wayland/wlroots"


newXdgToplevel :: proc(listener: ^wl.Listener, data: rawptr) {}
newXdgPopup :: proc(listener: ^wl.Listener, data: rawptr) {}
