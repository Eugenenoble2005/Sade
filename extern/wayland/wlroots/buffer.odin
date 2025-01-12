package wlroots
import wl "../server"
import "core:c"
import "core:sys/posix"
BufferImpl :: struct {
	destroy:               proc(buffer: ^Buffer),
	get_dmabuf:            proc(buffer: ^Buffer, attribs: ^DMABufAttributes) -> c.bool,
	get_shm:               proc(buffer: ^Buffer, attribs: ^ShmAttributes) -> c.bool,
	begin_data_ptr_access: proc(
		buffer: ^Buffer,
		flags: c.uint32_t,
		data: ^rawptr,
		format: c.uint32_t,
		stride: c.size_t,
	) -> c.bool,
	end_data_ptr_access:   proc(buffer: ^Buffer),
} //todo
ShmAttributes :: struct {
	fd:            c.int,
	format:        c.uint32_t,
	width, height: c.int,
	stride:        c.int,
	offset:        posix.off_t,
}
Buffer :: struct {
	impl:               ^BufferImpl,
	width, height:      c.int,
	dropped:            c.bool,
	n_locks:            c.size_t,
	accessing_data_ptr: c.bool,
	events:             struct {
		destroy: wl.Signal,
		release: wl.Signal,
	},
	addons:             AddonSet,
}

ClientBuffer :: struct {
	base:        Buffer,
	texture:     ^Texture,
	source:      ^Buffer,
	WLR_PRIVATE: struct {
		source_destroy:   wl.Listener,
		renderer_destroy: wl.Listener,
	},
}
