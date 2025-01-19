package wlroots
import pixman "../../pixman"
import wl "../server"
import "core:c"
when ODIN_OS == .Linux do foreign import wlroots "system:libwlroots-0.19.so"

XdgShell :: struct {
	global:       ^wl.Global,
	version:      c.uint32_t,
	clients:      wl.List,
	popup_grabs:  wl.List,
	ping_timeout: c.uint32_t,
	events:       struct {
		new_surface:  wl.Signal,
		new_toplevel: wl.Signal,
		new_popup:    wl.Signal,
		destroy:      wl.Signal,
	},
	WLR_PRIVATE:  struct {
		display_destroy: wl.Listener,
	},
	data:         rawptr,
}

XdgClient :: struct {
	shell:       ^XdgShell,
	resource:    ^wl.Resource,
	client:      ^wl.Client,
	surfaces:    wl.List,
	link:        wl.List,
	ping_serial: c.uint32_t,
	ping_timer:  ^wl.EventSource,
}

XdgToplevel :: struct {
	resource:         ^wl.Resource,
	base:             ^XdgSurface,
	parent:           ^XdgToplevel,
	current, pending: XdgToplevelState,
	scheduled:        XdgToplevelConfigure,
	requested:        XdgToplevelRequested,
	title:            cstring,
	app_id:           cstring,
	events:           struct {
		destroy:                  wl.Signal,
		request_maximize:         wl.Signal,
		request_fullscreen:       wl.Signal,
		request_minimize:         wl.Signal,
		request_move:             wl.Signal,
		request_resize:           wl.Signal,
		request_show_window_menu: wl.Signal,
		set_parent:               wl.Signal,
		set_title:                wl.Signal,
		set_app_id:               wl.Signal,
	},
	WLR_PRIVATE:      struct {
		synced:       SurfaceSynced,
		parent_unmap: wl.Listener,
	},
}
XdgSurface :: struct {
	client:            ^XdgClient,
	resource:          ^wl.Resource,
	surface:           ^Surface,
	link:              wl.List,
	role:              SurfaceRole,
	role_resource:     wl.Resource,
	//union here
	toplevel_or_popup: union {
		^XdgToplevel,
		^XdgPopup,
	},
	popups:            wl.List,
	configured:        c.bool,
	configure_idle:    ^wl.EventSource,
	scheduled_serial:  c.uint32_t,
	configure_list:    wl.List,
	current, pending:  XdgSurfaceState,
	initialized:       c.bool,
	initial_commit:    c.bool,
	geometry:          Box,
	events:            struct {
		destroy:       wl.Signal,
		ping_timeout:  wl.Signal,
		new_popup:     wl.Signal,
		configure:     wl.Signal,
		ack_configure: wl.Signal,
	},
	data:              rawptr,
	WLR_PRIVATE:       struct {
		toplevel: ^XdgToplevel,
		seat:     ^SeatClient,
		serial:   c.uint32_t,
	},
}
XdgSurfaceState :: struct {
	committed:        c.uint32_t,
	geometry:         Box,
	configure_serial: c.uint32_t,
}
XdgPopup :: struct {
	base:             ^XdgSurface,
	link:             wl.List,
	resource:         ^wl.Resource,
	parent:           ^Surface,
	seat:             ^Seat,
	scheduled:        XdgPopupConfigure,
	current, pending: XdgPopupState,
	events:           struct {
		destroy:    wl.Signal,
		reposition: wl.Signal,
	},
	grab_link:        wl.List,
	WLR_PRIVATE:      struct {
		synced: SurfaceSynced,
	},
}
XdgPopupState :: struct {
	geometry: Box,
	reactive: c.bool,
}
XdgPopupConfigure :: struct {
	fields:           c.uint32_t,
	geometry:         Box,
	rules:            XdgPositionerRules,
	reposition_token: c.uint32_t,
}
XdgPositionerRules :: struct {
	anchor_rect:                 Box,
	anchor:                      XdgPositionerAnchor,
	gravity:                     XdgPositionerGravity,
	constraint_adjustment:       XdgPositionerConstraintAdjustment,
	reactive:                    c.bool,
	has_parent_configure_serial: c.bool,
	parent_configure_serial:     c.uint32_t,
	size, parent_size:           struct {
		width, height: c.int32_t,
	},
	offset:                      struct {
		x, y: c.int32_t,
	},
}

XdgPositionerAnchor :: enum c.int {}
XdgPositionerGravity :: enum c.int {}
XdgPositionerConstraintAdjustment :: enum c.int {}
XdgToplevelState :: struct {
	maximized, fullscreen, resizing, activated, suspended: c.bool,
	tiled:                                                 c.uint32_t,
	width, height:                                         c.uint32_t,
	max_width, max_height:                                 c.int32_t,
	min_width, min_height:                                 c.int32_t,
}
XdgToplevelConfigure :: struct {
	fields:                                                c.uint32_t,
	maximized, fullscreen, resizing, activated, suspended: c.bool,
	tiled:                                                 c.uint32_t,
	width, height:                                         c.int32_t,
	bounds:                                                struct {
		width, height: c.int32_t,
	},
	wm_capbilities:                                        c.uint32_t,
}
XdgToplevelRequested :: struct {
	maximized, minimized, fullscreen: c.bool,
	fullscreen_output:                ^Output,
	WLR_PRIVATE:                      struct {
		fullscreen_output_destroy: wl.Listener,
	},
}
foreign wlroots {
	@(link_name = "wlr_xdg_shell_create")
	CreateXdgShell :: proc(_: ^wl.Display, _: c.uint32_t) -> ^XdgShell ---

	@(link_name = "wlr_xdg_toplevel_set_size")
	SetXdgToplevelSize :: proc(_: ^XdgToplevel, _: c.int32_t, _: c.int32_t) -> c.uint32_t ---

	@(link_name = "wlr_xdg_toplevel_try_from_wlr_surface")
	TryGetXdgToplevelFromSurface :: proc(_: ^Surface) -> ^XdgToplevel ---

	@(link_name = "wlr_xdg_surface_try_from_wlr_surface")
	TryGetXdgSurfaceFromSurface :: proc(_: ^Surface) -> ^XdgSurface ---

	@(link_name = "wlr_xdg_toplevel_set_activated")
	SetActivatedXdgToplevel :: proc(_: ^XdgToplevel, _: c.bool) -> c.uint32_t ---

	@(link_name = "wlr_xdg_surface_schedule_configure")
	ScheduleXdgSurfaceConfiguration :: proc(_: ^XdgSurface) -> c.uint32_t ---
}
