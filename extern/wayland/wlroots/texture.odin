package wlroots
import "core:c"

Texture :: struct {
	impl:          ^struct {},
	width, height: c.uint32_t,
	renderer:      ^Renderer,
}

