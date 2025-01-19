package Sade
import common "/common"
import "core:fmt"
import wl "extern/wayland/server"
import wlr "extern/wayland/wlroots"
SadeServer :: common.SadeServer
main :: proc() {
	//init wlr logging
	wlr.InitLogger(.Info, nil)

	InitServer()
}
