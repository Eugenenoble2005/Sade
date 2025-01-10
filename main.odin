package Sade
import "core:fmt"
import wl "extern/wayland/server"
import wlr "extern/wayland/wlroots"
SadeServer :: struct {
	display:       ^wl.Display,
	event_loop:    ^wl.EventLoop,
	backend:       ^wlr.Backend,
	renderer:      ^wlr.Renderer,
	allocator:     ^wlr.Allocator,
	output_layout: ^wlr.OutputLayout,
	outputs:       wl.List,
	new_output:    wl.Listener,
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

