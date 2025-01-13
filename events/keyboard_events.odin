package events
import wl "../extern/wayland/server"
import wlr "../extern/wayland/wlroots"
import xkb "../extern/xkbcommon"
import "core:fmt"
ServerNewKeyboard :: proc(sade: ^SadeServer, device: ^wlr.InputDevice) {
	fmt.println("We have located a keyboard")
	KEYBOARD: ^wlr.Keyboard = wlr.GetKeyboardFromInputDevice(device)
	sade_keyboard: ^SadeKeyboard = Calloc(SadeKeyboard)
	sade_keyboard.server = sade
	sade_keyboard.keyboard = KEYBOARD
	xkb_context: ^xkb.Context = xkb.NewXKBContext(.No_Flags)
	xkb_keymap: ^xkb.Keymap = xkb.NewKeymapFromNames(xkb_context, nil, .No_Flags)

	//set the keymap, default keymap is US
	wlr.SetKeyMap(KEYBOARD, xkb_keymap)
	xkb.UnrefKeymap(xkb_keymap)
	xkb.UnrefContext(xkb_context)
	wlr.SetKeyboardRepeatInfo(KEYBOARD, 25, 600)

	sade_keyboard.modifiers.notify = handleKeyboardModifiers
	wl.AddSignal(&KEYBOARD.events.modifiers, &sade_keyboard.modifiers)

	sade_keyboard.key.notify = handleKeyboardKeyPress
	wl.AddSignal(&KEYBOARD.events.key, &sade_keyboard.key)

	sade_keyboard.destroy.notify = handleKeyboardDestroy
	wl.AddSignal(&device.events.destroy, &sade_keyboard.destroy)

	wlr.SetSeatKeyboard(sade.seat, sade_keyboard.keyboard)
	wl.ListInsert(&sade.keyboards, &sade_keyboard.link)
}

handleKeyboardModifiers :: proc(listener: ^wl.Listener, data: rawptr) {
	sade_keyboard := container_of(listener, SadeKeyboard, "modifiers")
	//set the keyboard of the seat.... again
	wlr.SetSeatKeyboard(sade_keyboard.server.seat, sade_keyboard.keyboard)
	//send mod to clients
	wlr.SeatKeyboardNotifyModifiers(sade_keyboard.server.seat, &sade_keyboard.keyboard.modifiers)

}
handleKeyboardKeyPress :: proc(listener: ^wl.Listener, data: rawptr) {
	sade_keyboard := container_of(listener, SadeKeyboard, "key")
	sade: ^SadeServer = sade_keyboard.server
	EVENT: ^wlr.KeyboardKeyEvent = cast(^wlr.KeyboardKeyEvent)data
	SEAT: ^wlr.Seat = sade.seat

	keycode := EVENT.keycode + 8
	syms: [^]xkb.Keysym
	syms_place: ^xkb.Keysym
	nsyms: int = cast(int)xkb.GetSyms(sade_keyboard.keyboard.xkb_state, keycode, auto_cast &syms) //??
	handled := false
	modifiers := wlr.GetKeyboardModifiers(sade_keyboard.keyboard)
	//Use alt mod for now
	MOD_ALT := u32(wlr.KeyboardModifer.Alt)
	if (modifiers & MOD_ALT != 0 && EVENT.state == .Pressed) {
		fmt.println("Alt was pressed")
		for i in 0 ..< nsyms {
			handled = handleKeybind(sade, syms[i])
		}
	}

}

handleKeybind :: proc(sade: ^SadeServer, sym: xkb.Keysym) -> bool {
	fmt.println(sym)
	return true
}
handleKeyboardDestroy :: proc(listener: ^wl.Listener, data: rawptr) {}
