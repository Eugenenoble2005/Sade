package wlroots
import wl "../server"
import "core:c"

Swapchain :: struct {
	allocator:     ^Allocator,
	width, height: c.int,
	format:        DRMFormat,
	slots:         [4]SwapchainSlot,
	WLR_PRIVATE:   struct {
		allocator_destroy: wl.Listener,
	},
}
SwapchainSlot :: struct {
	buffer:      ^Buffer,
	acquired:    c.bool,
	WLR_PRIVATE: struct {
		release: wl.Listener,
	},
}
