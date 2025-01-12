package events
import "../common"
import wl "../extern/wayland/server"
import wlr "../extern/wayland/wlroots"
import "core:c/libc"
import "core:fmt"
import "core:sys/linux"
import "core:sys/posix"
SadeServer :: common.SadeServer
SadeOutput :: common.SadeOutput
Calloc :: common.Calloc

handleNewOutput :: proc(listener: ^wl.Listener, data: rawptr) {
	OUTPUT := cast(^wlr.Output)data
	sade: ^SadeServer = container_of(listener, SadeServer, "new_output")
	wlr.InitOutputRender(OUTPUT, sade.allocator, sade.renderer)
	state: wlr.OutputState
	wlr.InitOutputState(&state)
	wlr.SetOutputStateEnabledStatus(&state, true)

	mode: ^wlr.OutputMode = wlr.PreferredOutputMode(OUTPUT)
	if mode != nil {
		wlr.SetOutputStateMode(&state, mode)
	}
	wlr.CommitOutputState(OUTPUT, &state)
	wlr.FinishOutputState(&state)
	sade_output: ^SadeOutput = Calloc(SadeOutput)
	sade_output.wlr_output = OUTPUT
	sade_output.server = sade

	sade_output.frame.notify = frameOutput
	wl.AddSignal(&OUTPUT.events.frame, &sade_output.frame)

	sade_output.request_state.notify = requestOutputState
	wl.AddSignal(&OUTPUT.events.request_state, &sade_output.request_state)

	sade_output.destroy.notify = destroyOutput
	wl.AddSignal(&OUTPUT.events.destroy, &sade_output.destroy)

	wl.ListInsert(&sade.outputs, &sade_output.link)

	l_output := wlr.AddOutputLayoutAuto(sade.output_layout, OUTPUT)
	scene_output := wlr.CreateOutputScene(sade.scene, OUTPUT)
	wlr.AddSceneOutputLayoutToOutput(sade.scene_layout, l_output, scene_output)
}
requestOutputState :: proc(listener: ^wl.Listener, data: rawptr) {
	sade_output: ^SadeOutput = container_of(listener, SadeOutput, "request_state")
	event := cast(^wlr.OutputEventRequestState)data
	fmt.println("data is %d", event.output.needs_frame)
	wlr.CommitOutputState(sade_output.wlr_output, event.state)
}
destroyOutput :: proc(listener: ^wl.Listener, data: rawptr) {
	OUTPUT: ^SadeOutput = container_of(listener, SadeOutput, "destroy")
	wl.ListRemove(&OUTPUT.frame.link)
	wl.ListRemove(&OUTPUT.request_state.link)
	wl.ListRemove(&OUTPUT.destroy.link)
	wl.ListRemove(&OUTPUT.link)
}
frameOutput :: proc(listener: ^wl.Listener, data: rawptr) {
	output: ^SadeOutput = container_of(listener, SadeOutput, "frame")
	scene := output.server.scene
	scene_output := wlr.GetSceneOutput(scene, output.wlr_output)
	wlr.CommitOutputScene(scene_output, nil)
	now: posix.timespec
	posix.clock_gettime(.MONOTONIC, &now)
	wlr.SendOutputFrameDone(scene_output, &now)
}
