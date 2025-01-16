package wlroots
import wl "../server"
import "core:c"
LinuxDMABufV1 :: struct {}//TODO

LinuxDMABufFeedbackV1InitOptions :: struct {
	main_renderer:               ^Renderer,
	scanout_primary_output:      ^Output,
	output_layer_feedback_event: ^OutputLayerFeedbackEvent,
}
