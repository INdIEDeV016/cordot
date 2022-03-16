class_name DiscordRESTAdapter extends Node

var requester: DiscordRESTRequester setget __set
var mediator: DiscordRESTMediator   setget __set

var application: ApplicationRESTAPI setget __set
var channel: ChannelRESTAPI         setget __set
var guild: GuildRESTAPI             setget __set
var interaction: InteractionRESTAPI setget __set
var user: UserRESTAPI               setget __set
var webhook: WebhookRESTAPI         setget __set

func _init(token: String, entity_manger: BaseDiscordEntityManager) -> void:
	name = "RESTAdapter"
	
	requester = DiscordRESTRequester.new()
	mediator = Mediator.new(self)
	
	application = ApplicationRESTAPI.new(token, requester, entity_manger)
	channel = ChannelRESTAPI.new(token, requester, entity_manger)
	guild = GuildRESTAPI.new(token, requester, entity_manger)
	interaction = InteractionRESTAPI.new(token, requester, entity_manger)
	user = UserRESTAPI.new(token, requester, entity_manger)
	webhook = WebhookRESTAPI.new(token, requester, entity_manger)

func __set(_value) -> void:
	pass

class Mediator extends DiscordRESTMediator:
	
	var client: WeakRef
	
	func _init(rest_client: DiscordRESTAdapter) -> void:
		client = weakref(rest_client)
	
	func get_rest() -> DiscordRESTAdapter:
		return client.get_ref()
	
	func request_async(type: int, request: String, arguments: Array):
		var rest: DiscordRESTAdapter = get_rest()
		match type:
			DiscordREST.APPLICATION:
				return rest.application.callv(request, arguments)
			DiscordREST.CHANNEL:
				return rest.channel.callv(request, arguments)
			DiscordREST.GUILD:
				return rest.guild.callv(request, arguments)
			DiscordREST.INTERACTION:
				return rest.interaction.callv(request, arguments)
			DiscordREST.USER:
				return rest.user.callv(request, arguments)
			DiscordREST.WEBHOOK:
				return rest.webhook.callv(request, arguments)
	
	func cdn_download_async(url: String) -> Resource:
		return get_rest().requester.cdn_download_async(url)
