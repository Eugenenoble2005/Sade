package wlroots
import wl "../server"

AddonSet :: struct {
	WLR_PRIVATE: struct {
		addons: wl.List,
	},
}

Addon :: struct {
	impl:        ^struct {
		name:    cstring,
		destroy: proc(addon: ^Addon),
	}, //todo
	WLR_PRIVATE: struct {
		owner: rawptr,
		link:  wl.List,
	},
}
