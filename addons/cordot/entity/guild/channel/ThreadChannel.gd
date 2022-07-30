class_name ThreadChannel extends BaseGuildTextChannel

var owner_id: int
var owner: Member:
	get: return guild.get_member(owner_id)
var parent_id: int
var parent: GuildTextChannel:
	get: return guild.get_channel(parent_id)
var message_count: int
var member_count: int
var metadata: ThreadMetaData

func _init(data: Dictionary) -> void:
	super(data)
	type = data["type"]
	owner_id = data["owner_id"]
	parent_id = data["parent_id"]

func get_class() -> String:
	return "Guild.ThreadChannel"

func _update(data: Dictionary) -> void:
	super(data)
	message_count = data.get("message_count", message_count)
	member_count = data.get("member_count", member_count)
	metadata = data.get("metadata", metadata)

func _clone_data() -> Array:
	var data: Array = super()
	
	var arguments: Dictionary = data[0]
	arguments["owner_id"] = self.owner_id
	arguments["parent_id"] = self.parent_id
	arguments["message_count"] = self.message_count
	arguments["member_count"] = self.member_count
	arguments["metadata"] = self.metadata
	
	return data
