package Sade
import common "/common"
import events "/events"
import "core:c/libc"
import "core:fmt"
import "core:sys/posix"
import wl "extern/wayland/server"
import wlr "extern/wayland/wlroots"

InitServer :: proc() {
	sade: SadeServer
	//init wlr logging
	wlr.InitLogger(.Info, nil)

	sade.display = wl.CreateDisplay()
	defer wl.DestroyDisplay(sade.display)

	sade.event_loop = wl.GetEventLoop(sade.display)
	sade.backend = wlr.AutoCreateBackend(sade.event_loop, nil)
	defer wlr.DestroyBackend(sade.backend)
	if (sade.backend == nil) {
		fmt.println("Could not create backend")
	}
	defer wlr.DestroyBackend(sade.backend)
	sade.renderer = wlr.AutoCreateRenderer(sade.backend)
	if (sade.renderer == nil) {
		fmt.println("Could not create rendeerer")
	}
	defer wlr.DestroyRenderer(sade.renderer)

	wlr.RendererInitWlDisplay(sade.renderer, sade.display)

	sade.allocator = wlr.AutoCreateAllocator(sade.backend, sade.renderer)
	if (sade.allocator == nil) {
		fmt.println("Could not create allocator")
	}
	defer wlr.DestroyAllocator(sade.allocator)

	wlr.CreateCompositor(sade.display, 5, sade.renderer)
	wlr.CreateSubCompositor(sade.display)
	wlr.CreateDataDeviceManager(sade.display)

	sade.output_layout = wlr.CreateOutputLayout(sade.display)
	wl.InitList(&sade.outputs)
	sade.new_output.notify = events.handleNewOutput
	wl.AddSignal(&sade.backend.events.new_output, &sade.new_output)

	sade.scene = wlr.CreateScene()
	sade.scene_layout = wlr.AttachSceneToOutputLayout(sade.scene, sade.output_layout)

	wl.InitList(&sade.toplevels)
	//XDG PROTOCOL
	sade.xdg_shell = wlr.CreateXdgShell(sade.display, 3)
	sade.new_xdg_toplevel.notify = events.newXdgToplevel
	wl.AddSignal(&sade.xdg_shell.events.new_toplevel, &sade.new_xdg_toplevel)
	sade.new_xdg_popup.notify = events.newXdgPopup
	wl.AddSignal(&sade.xdg_shell.events.new_popup, &sade.new_xdg_popup)

	//CURSOR
	sade.cursor = wlr.CreateCursor()
	defer wlr.DestroyCursor(sade.cursor)
	wlr.AttachCursorToOutputLayout(sade.cursor, sade.output_layout)
	sade.cursor_mgr = wlr.CreateXCursorManager(nil, 24)
	defer wlr.DestroyXCursorManager(sade.cursor_mgr)
	sade.cursor_mode = .Passthrough
	sade.cursor_motion.notify = events.cursorMotion
	wl.AddSignal(&sade.cursor.events.motion, &sade.cursor_motion)

	sade.cursor_motion_absolute.notify = events.cursorMotionAbsolute
	wl.AddSignal(&sade.cursor.events.motion_absolute, &sade.cursor_motion_absolute)

	sade.cursor_button.notify = events.cursorButton
	wl.AddSignal(&sade.cursor.events.button, &sade.cursor_button)

	sade.cursor_axis.notify = events.cursorAxis
	wl.AddSignal(&sade.cursor.events.axis, &sade.cursor_axis)

	sade.cursor_frame.notify = events.cursorFrame
	wl.AddSignal(&sade.cursor.events.frame, &sade.cursor_frame)

	wl.InitList(&sade.keyboards)
	sade.new_input.notify = events.handleNewInput
	wl.AddSignal(&sade.backend.events.new_input, &sade.new_input)

	sade.seat = wlr.CreateSeat(sade.display, "seat0")
	sade.request_cursor.notify = events.seatRequestCursor
	wl.AddSignal(&sade.seat.events.request_set_cursor, &sade.request_cursor)

	sade.request_set_selection.notify = events.seatRequestSetSelection
	wl.AddSignal(&sade.seat.events.set_selection, &sade.request_set_selection)

	socket := wl.AddDisplaySocketAuto(sade.display)
	if len(socket) == 0 {
		wlr.DestroyBackend(sade.backend)
	}
	if (!wlr.StartBackend(sade.backend)) {
		wlr.DestroyBackend(sade.backend)
		wl.DestroyDisplay(sade.display)
	}
	posix.setenv("WAYLAND_DISPLAY", socket, true)
	startup_arg: cstring = "foot"
	if len(startup_arg) != 0 {
		if posix.fork() == 0 {
			posix.execl("/bin/sh", "/bin/sh", "-c", startup_arg, nil)
		}
	}
	wlr.Log(.Info, "Running wayland compositor on WAYLAND_DISPLAY %s", socket)
	wl.RunDisplay(sade.display)
}
