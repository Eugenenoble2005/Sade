package wlroots
import wl "../server"
import "core:c"
when ODIN_OS == .Linux do foreign import wlroots "system:libwlroots-0.19.so"

DataDeviceManager :: struct {
	global:       ^wl.Global,
	data_sources: wl.List,
	events:       struct {
		destroy: wl.Signal,
	},
	data:         rawptr,
	WLR_PRIVATE:  struct {
		display_destroy: wl.Listener,
	},
}
foreign wlroots {
	@(link_name = "wlr_data_device_manager_create")
	CreateDataDeviceManager :: proc(_: ^wl.Display) -> ^DataDeviceManager ---
}

