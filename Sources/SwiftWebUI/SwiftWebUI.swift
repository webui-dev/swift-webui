import webui

public typealias Event = UnsafeMutablePointer<webui_event_t>?

public typealias BindCallback = @convention(c) (Event) -> Void

enum WebUIError: Error {
	case runtimeError(String)
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
	public func bind(_ element: String, _ callback: BindCallback) {
		webui_bind(id, element, callback)
	}

	/// Shows a window using embedded HTML, or a file.
	/// If the window is already open, it will be refreshed.
	/// - Parameter html: The HTML, URL, or a local file.
	/// - Throws: `WebUIError.runtimeError` if showing the window was not successful.
	public func show(_ html: String) throws {
		if !(html.withCString { html in
			webui_show(id, html)
		}) {
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

/// Gets an argument passed from JavaScript.
/// - Parameters:
///   - event: The event object.
///   - idx: The event object.
public func getArg<T>(_ event: Event, _ idx: Int = 0) throws -> T {
	let arg_count = webui_get_count(event)
	if idx >= arg_count {
		throw WebUIError.runtimeError("error: argument index out of range (index: \(idx), argument count: \(arg_count))")
	}
	if T.self == String.self {
		let str = webui_get_string_at(event, idx)!
		return String(cString: str) as! T
	} else if T.self == Int.self {
		return Int(webui_get_int_at(event, idx)) as! T
	} else if T.self == Bool.self {
		return webui_get_bool_at(event, idx) as! T
	} else if T.self == Double.self {
		return webui_get_float_at(event, idx) as! T
	}
	// TODO: automatically decode other types.
	throw WebUIError.runtimeError("error: failed to get argument at index `\(idx)`")
}

/// Returns a response to JavaScript.
/// - Parameters:
///   - event: The event object.
///   - value: The response value.
public func response<T>(_ event: Event, _ value: T) {
	if value is String {
		(value as! String).withCString { str in
			webui_return_string(event, str)
		}
	} else if value is Int {
		webui_return_int(event, Int64(value as! Int))
	} else if value is Bool {
		webui_return_bool(event, value as! Bool)
	} else if value is Double {
		webui_return_float(event, value as! Double)
	}
	// TODO: automatically encode other types as JSON string.
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
