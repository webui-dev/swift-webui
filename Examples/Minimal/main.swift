import webui

let doc = "<html><head><script src='webui.js'></script></head> Hello World</html>"

let win = webui_new_window()

_ = doc.withCString { html in
	webui_show(win, UnsafeMutablePointer(mutating: html))
}

webui_wait()
