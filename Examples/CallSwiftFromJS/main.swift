import SwiftWebUI

let doc = """
<!doctype html>
<html>
	<head>
		<title>Call Swift from JavaScript Example</title>
		<script src="webui.js"></script>
		<style>
			body {
				background: linear-gradient(to left, #36265a, #654da9);
				color: AliceBlue;
				font: 16px sans-serif;
				text-align: center;
				margin-top: 30px;
			}
			button {
				margin: 5px 0 10px;
			}
		</style>
	</head>
	<body>
		<h1>WebUI - Call Swift from JavaScript</h1>
		<br />
		<p>
			Call Swift functions with arguments (<em>See the logs in your terminal</em>)
		</p>
		<button onclick="webui.handleStr('Hello', 'World');">Call handle_str()</button>
		<br />
		<button onclick="webui.handleInt(123, 456, 789);">Call handleInt()</button>
		<br />
		<button onclick="webui.handleBool(true, false);">Call handleBool()</button>
		<br />
		<p>Call a Swift function that returns a response</p>
		<button onclick="getRespFromSwift();">Call handleResponse()</button>
		<div>Double: <input type="text" id="input-number" value="2" /></div>
		<script>
			async function getRespFromSwift() {
				const input = document.getElementById('input-number');
				const number = input.value;
				const result = await webui.handleResp(number);
				input.value = result;
			}
		</script>
	</body>
</html>
"""

func handleStr(_ e: Event) {
	let str1: String = try! getArg(e)
	let str2: String = try! getArg(e, 1)

	print("handleStr 1: \(str1)") // Hello
	print("handleStr 2: \(str2)") // World
}

func handleInt(e: Event) {
	let num1: Int = try! getArg(e)
	let num2: Int = try! getArg(e, 1)
	let num3: Int = try! getArg(e, 2)

	print("handleInt 1: \(num1)") // 123
	print("handleInt 2: \(num2)") // 456
	print("handleInt 3: \(num3)") // 789
}

func handleBool(e: Event) {
	let status1: Bool = try! getArg(e)
	let status2: Bool = try! getArg(e, 1)

	print("handleBool 1: \(status1)") // true
	print("handleBool 2: \(status2)") // false
}

func handleResp(e: Event) {
	let count: Int = try! getArg(e)
	response(e, count * 2)
}

// Create a new window.
let win = newWindow()

// Bind Swift functions.
win.bind("handleStr", handleStr)
win.bind("handleInt", handleInt)
win.bind("handleBool", handleBool)
win.bind("handleResp", handleResp)

// Show html frontend.
try! win.show(doc)

// Wait until all windows get closed.
wait()
