package xkbcommon
import "core:c"
when ODIN_OS == .Linux do foreign import xkb "system:libxkbcommon.so"

ModMask :: c.uint32_t
LayoutIndex :: c.uint32_t
LayoutMask :: c.uint32_t
LedIndex :: c.uint32_t
ModIndex :: c.uint32_t
Keysym :: c.uint32_t
Keycode :: c.uint32_t
Keymap :: struct {}
State :: struct {}
Context :: struct {}

ContextFlags :: enum c.int {
	No_Flags,
	No_Default_Includes,
	No_Environment_Names,
	No_Secure_Getenv,
}

RuleNames :: struct {
	rules:   cstring,
	model:   cstring,
	layout:  cstring,
	variant: cstring,
	options: cstring,
}
KeymapCompileFlags :: enum c.int {
	No_Flags,
}
foreign xkb {
	@(link_name = "xkb_context_new")
	NewXKBContext :: proc(_: ContextFlags) -> ^Context ---

	@(link_name = "xkb_keymap_new_from_names")
	NewKeymapFromNames :: proc(_: ^Context, _: ^RuleNames, _: KeymapCompileFlags) -> ^Keymap ---

	@(link_name = "xkb_keymap_unref")
	UnrefKeymap :: proc(_: ^Keymap) ---

	@(link_name = "xkb_context_unref")
	UnrefContext :: proc(_: ^Context) ---

	@(link_name = "xkb_state_key_get_syms")
	GetSyms :: proc(_: ^State, key: Keycode, _: ^^Keysym) -> c.int ---
}
