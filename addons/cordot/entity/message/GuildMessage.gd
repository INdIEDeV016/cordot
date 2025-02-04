class_name GuildMessage extends Message

var guild_id: int
var guild: Guild:
	get = get_guild
var member: Guild.Member
var role_mentions: Array
var mention_everyone: bool
var is_tts: bool

func _init(data: Dictionary) -> void:
	super(data)
	guild_id = data["guild_id"]
	is_tts = data.get("tts", false)
	member = data["member"]

func get_guild() -> Guild:
	return get_container().guilds.get(guild_id)

func get_channel() -> TextChannel:
	return self.get_container().channels.get(
		channel_id, self.guild.get_thread(channel_id)
	)

func crosspost() -> GuildMessage:
	if self.channel.type != Channel.Type.GUILD_NEWS:
		push_error("Can not crosspost a message in a non-news channel")
		return await Awaiter.submit()
	return get_rest().request_async(
		DiscordREST.CHANNEL,
		"crosspost_message", [channel_id, self.id]
	)

func get_class() -> String:
	return "GuildMessage"

func _update(data: Dictionary) -> void:
	super(data)
	role_mentions = data.get("role_mentions", role_mentions)
	role_mentions = data.get("role_mentions", role_mentions)
	mention_everyone = data.get("mention_everyone", mention_everyone)

func _clone_data() -> Array:
	var data: Array = super()

	var arguments: Dictionary = data[0]
	arguments["guild_id"] = self.guild_id
	arguments["role_mentions"] = self.role_mentions.duplicate()
	arguments["channel_mentions"] = self.channel_mentions.duplicate()
	arguments["mention_everyone"] = self.mention_everyone
	arguments["is_tts"] = self.is_tts
	arguments["member"] = self.member

	return data

#func __set(_value) -> void:
#	pass
