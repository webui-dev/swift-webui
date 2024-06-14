import SwiftWebUI

let win1 = newWindowId(1)
let win2 = newWindowId(2)

func switchToSecondPage(_: Event) {
	try! win1.show("second.html")
}

func showSecondWindow(_: Event) {
	try! win2.show("second.html")
	win2.run("document.getElementById('go-back').remove();")
}

func exit(_: Event) {
	exit()
}

try! setRootFolder("Examples/ServeAFolder/ui/")

try! win1.show("index.html")

// Bind functions to ids.
win1.bind("switch-to-second-page", switchToSecondPage)
win1.bind("open-new-window", showSecondWindow)
win1.bind("exit", exit)
win2.bind("exit", exit)

wait()
