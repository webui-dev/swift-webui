import webui

public typealias Event = UnsafeMutablePointer<webui_event_t>?

public typealias BindCallback = @convention(c) (Event) -> Void

enum WebUIError: Error {
	case runtimeError(String)
}

public final class Window {
	let id: Int

	public init(_ webui_win: Int) {
		id = webui_win
	}

	public func bind(_ element: String, _ cb: BindCallback) {
		webui_bind(id, element, cb)
	}

	public func show(_ html: String) throws {
		if !(html.withCString { html in
			webui_show(id, html)
		}) {
			throw WebUIError.runtimeError("error: failed to show window")
		}
	}

	public func close() {
		webui_close(id)
	}

	public func destroy() {
		webui_destroy(id)
	}

	public func is_shown() -> Bool {
		webui_is_shown(id)
	}
}

public func newWindow() -> Window {
	return Window(webui_new_window())
}

public func wait() {
	webui_wait()
}

public func exit() {
	webui_exit()
}

public func clean() {
	webui_clean()
}

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
