package events
import wl "../extern/wayland/server"
import wlr "../extern/wayland/wlroots"

handleNewInput :: proc(listener: ^wl.Listener, data: rawptr) {
	sade: ^SadeServer = container_of(listener, SadeServer, "new_input")
	INPUT_DEVICE := cast(^wlr.InputDevice)data

	//attach pointer as input device
	#partial switch INPUT_DEVICE.type {
	case .Keyboard:
		ServerNewKeyboard(sade, INPUT_DEVICE)
	case .Pointer:
		wlr.AttachCursorAsInputDevice(sade.cursor, INPUT_DEVICE)

	}

	//set pointer capabilites
	caps: uint = 1
	//set keyboard capabilites
	if !wl.IsListEmpty(&sade.keyboards) do caps |= 2
	wlr.SetSeatCapabilities(sade.seat, auto_cast caps)
}
