package wlroots
import wl "../server"
import "core:c"
when ODIN_OS == .Linux do foreign import wlroots "system:libwlroots-0.19.so"

XCursorManager :: struct {
	name:          cstring,
	size:          c.size_t,
	scaled_themes: wl.List,
}
foreign wlroots {
	@(link_name = "wlr_xcursor_manager_create")
	CreateXCursorManager :: proc(_: cstring, size: c.uint32_t) -> ^XCursorManager ---
}

