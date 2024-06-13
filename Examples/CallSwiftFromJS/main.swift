import webui

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

func handleStr(e: UnsafeMutablePointer<webui_event_t>?) {
	let str1 = webui_get_string(e)!
	let str2 = webui_get_string_at(e, 1)!

	print("handleStr 1: \(String(cString: str1))") // Hello
	print("handleStr 2: \(String(cString: str2))") // World
}

func handleInt(e: UnsafeMutablePointer<webui_event_t>?) {
	let num1 = webui_get_int_at(e, 0)
	let num2 = webui_get_int_at(e, 1)
	let num3 = webui_get_int_at(e, 2)

	print("handleInt 1: \(num1)") // 123
	print("handleInt 2: \(num2)") // 456
	print("handleInt 3: \(num3)") // 789
}

func handleBool(e: UnsafeMutablePointer<webui_event_t>?) {
	let status1 = webui_get_bool(e)
	let status2 = webui_get_bool_at(e, 1)

	print("handleBool 1: \(status1)") // true
	print("handleBool 2: \(status2)") // false
}

func handleResp(e: UnsafeMutablePointer<webui_event_t>?) {
	let count = webui_get_int(e)
	webui_return_int(e, count * 2)
}

// Create a new window.
let win = webui_new_window()

// Bind Swift functions.
webui_bind(win, "handleStr", handleStr)
webui_bind(win, "handleInt", handleInt)
webui_bind(win, "handleBool", handleBool)
webui_bind(win, "handleResp", handleResp)

// Show html frontend.
_ = doc.withCString { html in
	webui_show(win, UnsafeMutablePointer(mutating: html))
}

// Wait until all windows get closed.
webui_wait()

// Free resources (optional).
webui_clean()
