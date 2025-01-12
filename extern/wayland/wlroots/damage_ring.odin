package wlroots
import pixman "../../pixman"
import wl "../server"
DamageRing :: struct {
	current:     pixman.Region32,
	WLR_PRIVATE: struct {
		buffers: wl.List,
	},
}
