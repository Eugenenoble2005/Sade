package Sade
import "core:fmt"
import wl "extern/wayland/server"
import wlr "extern/wayland/wlroots"
SadeServer :: struct {
	display:          ^wl.Display,
	event_loop:       ^wl.EventLoop,
	backend:          ^wlr.Backend,
	renderer:         ^wlr.Renderer,
	allocator:        ^wlr.Allocator,
	output_layout:    ^wlr.OutputLayout,
	outputs:          wl.List,
	new_output:       wl.Listener,
	scene:            ^wlr.Scene,
	scene_layout:     ^wlr.SceneOutputLayout,
	toplevels:        wl.List,
	xdg_shell:        ^wlr.XdgShell,
	new_xdg_toplevel: wl.Listener,
	new_xdg_popup:    wl.Listener,
	cursor:           ^wlr.Cursor,
	cursor_mgr:       ^wlr.XCursorManager,
	cursor_motion:    wl.Listener,
	keyboards:        wl.List,
	new_input:        wl.Listener,
}
sade: SadeServer

main :: proc() {
	//init wlr logging
	wlr.InitLogger(.Debug, nil)

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
	sade.new_output.notify = handle_new_output
	wl.AddSignal(&sade.backend.events.new_output, &sade.new_output)

	sade.scene = wlr.CreateScene()
	sade.scene_layout = wlr.AttachSceneToOutputLayout(sade.scene, sade.output_layout)

	wl.InitList(&sade.toplevels)
	//XDG PROTOCOL
	sade.xdg_shell = wlr.CreateXdgShell(sade.display, 3)
	sade.new_xdg_toplevel.notify = new_xdg_toplevel
	wl.AddSignal(&sade.xdg_shell.events.new_toplevel, &sade.new_xdg_toplevel)
	sade.new_xdg_popup.notify = new_xdg_popup
	wl.AddSignal(&sade.xdg_shell.events.new_popup, &sade.new_xdg_popup)

	//CURSOR
	sade.cursor = wlr.CreateCursor()
	wlr.AttachCursorToOutputLayout(sade.cursor, sade.output_layout)
	sade.cursor_mgr = wlr.CreateXCursorManager(nil, 24)
	sade.cursor_motion.notify = cursor_motion
	wl.AddSignal(&sade.cursor.events.motion, &sade.cursor_motion)

	wl.InitList(&sade.keyboards)
	sade.new_input.notify = handle_new_input
	wl.AddSignal(&sade.backend.events.new_input, &sade.new_input)

	if (!wlr.StartBackend(sade.backend)) {
		wlr.DestroyBackend(sade.backend)
		wl.DestroyDisplay(sade.display)
	}
	wl.RunDisplay(sade.display)
}

handle_new_output :: proc(listener: ^wl.Listener, data: rawptr) {
	OUTPUT := cast(^wlr.Output)data
	server: ^SadeServer = container_of(listener, SadeServer, "new_output")
	wlr.InitOutputRender(OUTPUT, server.allocator, server.renderer)
	state: wlr.OutputState
	wlr.InitOutputState(&state)
	wlr.SetOutputStateEnabledStatus(&state, true)

	mode: ^wlr.OutputMode = wlr.PreferredOutputMode(OUTPUT)
	if mode != nil {
		wlr.SetOutputStateMode(&state, mode)
	}
	wlr.CommitOutputState(OUTPUT, &state)
	wlr.FinishOutputState(&state)
}
handle_new_input :: proc(listener: ^wl.Listener, data: rawptr) {
	fmt.println("New input device")
	server: ^SadeServer = container_of(listener, SadeServer, "new_input")
	INPUT_DEVICE := cast(^wlr.InputDevice)data

	//attack pointer as input device
	if INPUT_DEVICE.type == .Pointer do wlr.AttachCursorAsInputDevice(sade.cursor, INPUT_DEVICE)
}
new_xdg_toplevel :: proc(listener: ^wl.Listener, data: rawptr) {}
new_xdg_popup :: proc(listenet: ^wl.Listener, data: rawptr) {}
cursor_motion :: proc(listener: ^wl.Listener, data: rawptr) {
	fmt.println("Cursor moved!!")
	sade: ^SadeServer = container_of(listener, SadeServer, "cursor_motion")
	POINTER_MOTION_EVENT := cast(^wlr.PointerMotionEvent)data
	fmt.println("position is %d", POINTER_MOTION_EVENT.delta_x)
	//move the cursor
	wlr.MoveCursor(
		sade.cursor,
		&POINTER_MOTION_EVENT.pointer.base,
		POINTER_MOTION_EVENT.delta_x,
		POINTER_MOTION_EVENT.delta_y,
	)

}
