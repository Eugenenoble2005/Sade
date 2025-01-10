package wlroots
import "../../pixman"
import wl "../server"
import "core:c"
OutputLayerState :: struct {
	layer:    ^OutputLayer,
	buffer:   ^Buffer,
	src_box:  FBox,
	dst_box:  Box,
	damage:   ^pixman.Region32,
	accepted: c.bool,
}

OutputLayer :: struct {
	link:        wl.List,
	addons:      AddonSet,
	events:      struct {
		feedback: wl.Signal,
	},
	data:        rawptr,
	WLR_PRIVATE: struct {
		src_box: FBox,
		dst_box: Box,
	},
}

