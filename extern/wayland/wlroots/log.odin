package wlroots
import "core:c"
when ODIN_OS == .Linux do foreign import wlroots "system:libwlroots-0.19.so"

foreign wlroots {
	@(link_name = "wlr_log_init")
	InitLogger :: proc(_: LogVerbosity, callback: proc(_: LogVerbosity, _fmt: cstring, #c_vararg args: ..any)) ---

	@(link_name = "_wlr_log")
	Log :: proc(_: LogVerbosity, _: cstring, #c_vararg _: ..any) ---
}
LogVerbosity :: enum c.int {
	Silent,
	Error,
	Info,
	Debug,
	ImportanceLast, //??
}
