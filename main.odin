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
	seat:             ^wlr.Seat,
	new_input:        wl.Listener,
	grab_x, grab_y:   f64,
	cursor_mode:      SadeCursorMode,
	grabbed_toplevel: ^SadeToplevel,
}
SadeToplevel :: struct {
	link:               wl.List,
	server:             ^SadeServer,
	scene_tree:         ^wlr.SceneTree,
	map_:               wl.Listener,
	unmap_:             wl.Listener,
	commit:             wl.Listener,
	destroy:            wl.Listener,
	request_mode:       wl.Listener,
	request_resize:     wl.Listener,
	request_maximize:   wl.Listener,
	request_fullscreen: wl.Listener,
}
SadeOutput :: struct {
	link:          wl.List,
	server:        ^SadeServer,
	wlr_output:    ^wlr.Output,
	frame:         wl.Listener,
	request_state: wl.Listener,
	destroy:       wl.Listener,
}
SadeCursorMode :: enum {
	Passthrough,
	Move,
	Resize,
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
	sade.cursor_mode = .Passthrough
	sade.cursor_motion.notify = cursor_motion
	wl.AddSignal(&sade.cursor.events.motion, &sade.cursor_motion)

	wl.InitList(&sade.keyboards)
	sade.new_input.notify = handle_new_input
	wl.AddSignal(&sade.backend.events.new_input, &sade.new_input)
	sade.seat = wlr.CreateSeat(sade.display, "Sade")

	if (!wlr.StartBackend(sade.backend)) {
		wlr.DestroyBackend(sade.backend)
		wl.DestroyDisplay(sade.display)
	};wl.RunDisplay(sade.display)
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
	sade_output: SadeOutput
	sade_output.wlr_output = OUTPUT
	sade_output.server = server
	sade_output.frame.notify = output_frame
	wl.AddSignal(&OUTPUT.events.frame, &sade_output.frame)
	wl.ListInsert(&server.outputs, &sade_output.link)

	//implement this
	l_output := wlr.AddOutputLayoutAuto(sade.output_layout, OUTPUT)
}

output_frame :: proc(listener: ^wl.Listener, data: rawptr) {
	fmt.println("Output ready to render frame")
	output: ^SadeOutput = container_of(listener, SadeOutput, "frame")
	scene := output.server.scene
	//to be contrinued

}
handle_new_input :: proc(listener: ^wl.Listener, data: rawptr) {
	server: ^SadeServer = container_of(listener, SadeServer, "new_input")
	INPUT_DEVICE := cast(^wlr.InputDevice)data

	//attach pointer as input device
	if INPUT_DEVICE.type == .Pointer do wlr.AttachCursorAsInputDevice(sade.cursor, INPUT_DEVICE)
	//set pointer capabilites
	caps: uint = 1
	//set keyboard capabilites
	if wl.IsListEmpty(&sade.keyboards) == 0 do caps |= 2
	wlr.SetSeatCapabilities(sade.seat, auto_cast caps)
}
new_xdg_toplevel :: proc(listener: ^wl.Listener, data: rawptr) {}
new_xdg_popup :: proc(listenet: ^wl.Listener, data: rawptr) {}
cursor_motion :: proc(listener: ^wl.Listener, data: rawptr) {
	sade: ^SadeServer = container_of(listener, SadeServer, "cursor_motion")
	POINTER_MOTION_EVENT := cast(^wlr.PointerMotionEvent)data
	//move the cursor
	wlr.MoveCursor(
		sade.cursor,
		&POINTER_MOTION_EVENT.pointer.base,
		POINTER_MOTION_EVENT.delta_x,
		POINTER_MOTION_EVENT.delta_y,
	)
	if sade.cursor_mode == .Move {
		//process cursor move 
		return
	} else if sade.cursor_mode == .Resize {
		//process cursor resize
		return
	}
	//otherwise get toplevel and send cursor event
	//currently just set a static xcursor theme since i have not implemented any toplevels yet
	wlr.SetXcursor(sade.cursor, sade.cursor_mgr, auto_cast "Layan")


}
