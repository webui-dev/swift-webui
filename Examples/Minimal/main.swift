import SwiftWebUI

let doc = "<html><head><script src='webui.js'></script></head> Hello World</html>"

let win = newWindow()

try! win.show(doc)

wait()
