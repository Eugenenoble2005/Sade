package wlroots
import "core:c"

FBox :: struct {
	x, y:          c.double,
	width, height: c.double,
}

Box :: struct {
	x, y:          c.int,
	width, height: c.int,
}

