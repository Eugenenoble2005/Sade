package wlroots
import wl "../server"
import "core:c"

ScaleFilterMode :: enum c.int {
	Bilinear,
	Nearest,
}
