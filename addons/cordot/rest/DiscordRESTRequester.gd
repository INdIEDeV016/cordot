class_name DiscordRESTRequester

var limiter: RESTRateLimiter

func _init(use_Packed: bool = false) -> void:
	limiter = RESTRateLimiter.new(use_Packed)

func request_async(request: RestRequest) -> HTTPResponse:
	var response: HTTPResponse = await limiter.queue_request(request)

	var failed: bool = false

	match response.code:
		HTTPClient.RESPONSE_BAD_REQUEST:
			failed = true
			print_error("The request was improperly formatted, or the server couldn't understand it", request)
		HTTPClient.RESPONSE_UNAUTHORIZED:
			failed = true
			print_error("The Authorization header is missing or invalid", request)
		HTTPClient.RESPONSE_FORBIDDEN:
			failed = true
			print_error("The Authorization token did not have permission to the resource", request)
		HTTPClient.RESPONSE_NOT_FOUND:
			failed = true
			print_error("The resource at the location specified doesn't exist", request)
		HTTPClient.RESPONSE_METHOD_NOT_ALLOWED:
			failed = true
			print_error("The HTTP method used is not valid for the location specified", request)
		HTTPClient.RESPONSE_BAD_GATEWAY: # GATEWAY UNAVAILABLE
			failed = true
			print_error("There was not a gateway available to process the request. Wait a bit and retry", request)
		var code:
			failed = code >= 500
			if failed:
				print_error("Server error when processing the request", request)
	if failed:
		var json = JSON.new()
		var err := json.parse(response.body.get_string_from_utf8().c_unescape())
		var data: Dictionary
		if err == OK and json.get_data() is Dictionary:
			data = json.get_data()
		else:
			printerr()
			print_error_object(data)

	return response

func cdn_download_async(_url: String) -> Resource:
	var url: Dictionary = URL.parse_url(_url)
	var path: String = url.path.split("?", true, 1)[0]
	path = path.split("#", true, 1)[0]
	var format: String = path.get_extension()

	var fail: bool = false
	if not format in DiscordREST.CDN_FILE_FORMATS:
		fail = true
		push_error("Discord CDN: %s is an invalid file format" % format)
#	if size < 16 or size > 4096 or not _power_of_2(size):
#		fail = true
#		push_error("Discord CDN: %d is an invalid size" % size)
	if fail:
		return await Awaiter.submit()

	var response: HTTPResponse = await request_async(
		RestRequest.new().set_url(_url).method_get()
	)
	if not response.successful():
		return null
	var error: int = OK
	var image: Image = Image.new()
	match format:
		"jpg", "jpeg":
			error = image.load_jpg_from_buffer(response.body)
		"png":
			error = image.load_png_from_buffer(response.body)
		"webp":
			error = image.load_webp_from_buffer(response.body)
		_:
			return null
	if error != OK:
		printerr("Error when loading image from buffer: %d" % error)
	var texture: ImageTexture = ImageTexture.new()
	texture.create_from_image(image)
	return texture

func get_last_latency_ms() -> int:
	return limiter.last_latency_ms

func print_error(message: String, request: RestRequest) -> void:
	push_error("Discord REST: "+ message)
	printerr("Discord REST Error")
	printerr("message: ", message)
	printerr("URL: ", request.url)
	printerr("Method: ", limiter._stringify_method(request.method))
	printerr("Body length: ", request.body.size())

func print_error_object(object: Dictionary) -> void:
	printerr("ERROR TRACE START")
	printerr()
	printerr("Error: %s (%s)" % [object["code"], object["message"]])

	if not object.has("errors"):
		printerr()
		printerr("ERROR TRACE END")
		return

	printerr("Errors:")

	var stack: Array = [object["errors"]]
	while stack:
		var dict: Dictionary = stack.pop_back()
		for key in  dict:
			var value = dict[key]
			if value is Dictionary:
				var path: String = dict.get("path", "")
				if key.is_valid_integer():
					path += "[%s]" % key
				else:
					path += "." + key
				value["path"] = path.lstrip(".")
				stack.append(value)
		if dict.has("_errors"):
			var path: String = dict.get("path", "")
			var tabbing: String
			if not path.is_empty():
				tabbing = "\t"
				printerr("\t%s:" % path)
			for error in dict["_errors"]:
				printerr(tabbing + "\t\u2022 %s: %s" % [error["code"], error["message"]])
	printerr()
	printerr("ERROR TRACE END")

static func _power_of_2(n: int) -> bool:
	return (n & (n - 1)) == 0 if n > 0 else false
