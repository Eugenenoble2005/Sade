package wlroots
import "core:c"
DMABufAttributes :: struct {
	width, height: c.int32_t,
	format:        c.uint32_t,
	modifier:      c.uint64_t,
	n_planes:      c.int,
	offset:        [4]c.uint32_t,
	stride:        [4]c.uint32_t,
	fd:            [4]c.int,
}
