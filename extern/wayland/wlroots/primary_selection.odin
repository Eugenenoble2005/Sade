package wlroots
import wl "../server"
import "core:c"
import "core:c/libc"

PrimarySelectionSource :: struct {
	impl:       ^struct {}, //todo
	mime_types: wl.Array,
	events:     struct {
		destroy: wl.Signal,
	},
	data:       rawptr,
}
foreign wlroots {}

