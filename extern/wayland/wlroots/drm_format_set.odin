package wlroots
import "core:c"

DRMFormat :: struct {
	format:    c.uint32_t,
	len:       c.size_t,
	capacity:  c.size_t,
	modifiers: ^c.uint64_t,
}

DRMFormatSet :: struct {
	len:      c.size_t,
	capacity: c.size_t,
	formats:  ^DRMFormat,
}
