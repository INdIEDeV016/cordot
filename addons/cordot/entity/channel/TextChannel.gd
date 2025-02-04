class_name TextChannel extends Channel

var last_message_id: int
var last_message:
	get = get_last_message
var last_pin_timestamp: int

func _init(data: Dictionary) -> void:
	super(data["id"])
	_update(data)

func send_message(content: String, tts: bool = false, embeds: Array = []) -> BaseMessage:
	var params: Dictionary = {
		content = content,
		tts = tts
	}
	if embeds.size() > 0:
		params["embeds"] = embeds
	return get_rest().request_async(
		DiscordREST.CHANNEL,
		"create_message", [self.id, params]
	)

func fetch_messages(data: ChannelFetchMessgesParams = null) -> Array:
	return await get_rest().request_async(
		DiscordREST.CHANNEL,
		"get_messages", [self.id, data.to_dict() if data else {}]
	)

func fetch_message(message_id: int) -> BaseMessage:
	return get_rest().request_async(
		DiscordREST.CHANNEL,
		"get_message", [self.id, message_id]
	)

func fetch_last_message() -> BaseMessage:
	return fetch_message(last_message_id) if last_message_id else await Awaiter.submit()

func delete_messages(message_ids: PackedStringArray) -> bool:
	return await get_rest().request_async(
		DiscordREST.CHANNEL,
		"bulk_delete_messages", [self.id, message_ids]
	)

func get_last_message() -> BaseMessage:
	return get_container().messages.get(last_message_id)

func get_class() -> String:
	return "TextChannel"

func _update(data: Dictionary) -> void:
	last_pin_timestamp = data.get("last_pin_timestamp", last_pin_timestamp)
	last_message_id = data.get("last_message_id", last_message_id)

func _clone_data() -> Array:
	return [{
		id = self.id,
		last_pin_timestamp = self.last_pin_timestamp,
		last_message_id = self.last_message_id
	}]

#func __set(_value) -> void:
#	pass

class BaseMessage extends DiscordEntity:
	var channel_id: int
	var channel:
		get = get_channel

	func _init(data: Dictionary) -> void:
		super(data["id"])
		channel_id = data["channel_id"]
		_update(data)

	func get_channel() -> TextChannel:
		return self.get_container().channels.get(channel_id)

	func _update(_data: Dictionary) -> void:
		pass

#	func __set(_value):
#		pass
