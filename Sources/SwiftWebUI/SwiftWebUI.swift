import Foundation
import webui

public typealias BindCallback<T> = (Event) throws -> T

enum WebUIError: Error {
	case runtimeError(String)
}

var bindCallbacks: [Int: BindCallback<Any>] = [:]

func swiftEventHandler(_ webui_event_ptr: UnsafeMutablePointer<webui_event_t>?) {
	let e = webui_event_ptr?.pointee
	guard let window = e?.window,
	      let eventType = e?.event_type,
	      let element = e?.element,
	      let eventNumber = e?.event_number,
	      let bindId = e?.bind_id
	else {
		return
	}
	let event = Event(
		window: window,
		eventType: eventType,
		element: element,
		eventNumber: eventNumber,
		bindId: bindId
	)
	// Call user callback function.
	let result = try! bindCallbacks[event.bindId]?(event)
	if result is Void {
		return
	}
	guard let result = result else { return }
	try! event.response(result)
}

public final class Window {
	let id: Int

	init(_ webui_win: Int) {
		id = webui_win
	}

	/// Binds a function to the WebUI window object or directly to a HTML elements click event.
	/// Empty element means all events.
	/// - Parameters:
	///   - element: The name under which the function will be callable / the HTML elements ID.
	///   - callback: The callback function.
	// public func bind(_ element: String, _ callback: BindCallbackSwift) {
	public func bind<T>(_ element: String, _ callback: @escaping BindCallback<T>) {
		let id = webui_bind(id, element, swiftEventHandler)
		bindCallbacks[id] = callback
	}

	/// Shows a window using embedded HTML, or a file.
	/// If the window is already open, it will be refreshed.
	/// - Parameter html: The HTML, URL, or a local file.
	/// - Throws: `WebUIError.runtimeError` if showing the window was not successful.
	public func show(_ html: String) throws {
		if !(html.withCString { html in webui_show(id, html) }) {
			throw WebUIError.runtimeError("error: failed to show window")
		}
	}

	/// Closes the window. The window object will still exist.
	public func close() {
		webui_close(id)
	}

	/// Closes the window and free its memory resources.
	public func destroy() {
		webui_destroy(id)
	}

	/// Checks if window is running.
	public func is_shown() -> Bool {
		webui_is_shown(id)
	}

	/// Sets windows root folder.
	/// - Parameter path: The local folder full path.
	public func setRootFolder(_ path: String) throws {
		if !(path.withCString { p in webui_set_root_folder(id, p) }) {
			throw WebUIError.runtimeError("error: failed to set root folder for window `\(id)`")
		}
	}

	/// Runs JavaScript without waiting for the response.
	/// - Parameter script: The JavaScript to run.
	public func run(_ script: String) {
		script.withCString { script in
			webui_run(id, script)
		}
	}
}

public struct Event {
	let cStruct: webui_event_t
	let id: Int
	public let window: Window
	public let eventType: Int
	public let element: String
	public let bindId: Int

	init(window: Int, eventType: Int, element: UnsafeMutablePointer<CChar>?, eventNumber: Int, bindId: Int) {
		cStruct = webui_event_t(window: window, event_type: eventType, element: element, event_number: eventNumber, bind_id: bindId)
		id = eventNumber
		self.window = Window(window)
		self.eventType = eventType
		self.element = String(cString: element!)
		self.bindId = bindId
	}

	/// Gets an argument passed from JavaScript.
	/// - Parameters:
	///   - event: The event object.
	///   - idx: The argument position starting from 0.
	public func getArg<T>(_ idx: Int = 0) throws -> T {
		var cEvent = cStruct
		let arg_count = webui_get_count(&cEvent)
		if idx >= arg_count {
			throw WebUIError.runtimeError("error: argument index out of range (index: \(idx), argument count: \(arg_count))")
		}
		if T.self == String.self {
			let str = webui_get_string_at(&cEvent, idx)!
			return String(cString: str) as! T
		} else if T.self == Int.self {
			return Int(webui_get_int_at(&cEvent, idx)) as! T
		} else if T.self == Bool.self {
			return webui_get_bool_at(&cEvent, idx) as! T
		} else if T.self == Double.self {
			return webui_get_float_at(&cEvent, idx) as! T
		}
		// TODO: automatically decode other types.
		throw WebUIError.runtimeError("error: failed to get argument at index `\(idx)`")
	}

	/// Returns a response to JavaScript.
	/// - Parameters:
	///   - event: The event object.
	///   - value: The response value.
	func response<T>(_ value: T) throws {
		var cEvent = cStruct
		if value is String {
			(value as! String).withCString { str in webui_return_string(&cEvent, str) }
		} else if value is Int {
			webui_return_int(&cEvent, Int64(value as! Int))
		} else if value is Bool {
			webui_return_bool(&cEvent, value as! Bool)
		} else if value is Double {
			webui_return_float(&cEvent, value as! Double)
		} else {
			// TODO: automatically encode other types as JSON string.
			throw WebUIError.runtimeError("""
			error: failed to return response value `\(value)` with type `\(type(of: value))`.
			Pass a type `String`, `Int`, `Bool`, `Double`, or in case of Objects and Arrays JSON encoded values.
			""")
		}
	}
}

/// Creates a new window object.
public func newWindow() -> Window {
	return Window(webui_new_window())
}

/// Creates a new window object using a specified id.
public func newWindowId(_ id: Int) -> Window {
	return Window(webui_new_window_id(id))
}

/// Gets a free window id that can be used with newWindowId.
public func getNewWindowId() -> Int {
	return webui_get_new_window_id()
}

/// Waits until all opened windows get closed.
public func wait() {
	webui_wait()
}

/// Closes all open windows. `webui_wait()` will return (break).
public func exit() {
	webui_exit()
}

/// Frees all memory resources. Should be called only at the end.
public func clean() {
	webui_clean()
}

/// Sets the web-server root folder path for all windows.
/// Should be used before `webui_show()`.
/// - Parameter path: The full path to the local folder.
public func setRootFolder(_ path: String) throws {
	if !(path.withCString { p in
		webui_set_default_root_folder(p)
	}) {
		throw WebUIError.runtimeError("error: failed to set default root folder")
	}
}

public func setTLSCertificate(_ certifcatePem: String, _ privateKeyPem: String) throws {
	if !(certifcatePem.withCString { certPem in
		privateKeyPem.withCString { keyPem in
			webui_set_tls_certificate(certPem, keyPem)
		}
	}) {
		throw WebUIError.runtimeError("error: failed to set TLS certificate")
	}
}
