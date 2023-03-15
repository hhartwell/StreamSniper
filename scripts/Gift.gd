extends Gift

func _ready() -> void:
	# I use a file in the working directory to store auth data
	# so that I don't accidentally push it to the repository.
	# Replace this or create a auth file with 3 lines in your
	# project directory:
	# <bot username>
	# <oauth token>
	# <initial channel>
	var authfile := File.new()
	authfile.open(".twitch_auth", File.READ)
	var botname := authfile.get_line()
	var token := authfile.get_line()
	var initial_channel = authfile.get_line()
	
	print("Twitch config loaded, initial channel: " + initial_channel)

	connect_to_twitch()
	yield(self, "twitch_connected")

	# Login using your username and an oauth token.
	# You will have to either get a oauth token yourself or use
	# https://twitchapps.com/tokengen/
	# to generate a token with custom scopes.
	authenticate_oauth(botname, token)
	if(yield(self, "login_attempt") == false):
	  print("Invalid username or token.")
	  return
	
	print("Joining channel " + initial_channel)
	join_channel(initial_channel)

	connect("cmd_no_permission", self, "no_permission")
	connect("chat_message", self, "chat_message")

	# Adds a command with a specified permission flag.
	# All implementations must take at least one arg for the command info.
	# Implementations that recieve args requrires two args,
	# the second arg will contain all params in a PoolStringArray
	# This command can only be executed by VIPS/MODS/SUBS/STREAMER
	# add_command("test", self, "command_test", 0, 0, PermissionFlag.NON_REGULAR)

	# These two commands can be executed by everyone
	add_command("helloworld", self, "hello_world")
	add_command("greetme", self, "greet_me")

	# This command can only be executed by the streamer
	add_command("streamer_only", self, "streamer_only", 0, 0, PermissionFlag.STREAMER)

	# Command that requires exactly 1 arg.
	add_command("greet", self, "greet", 1, 1)

	# Command that prints every arg seperated by a comma (infinite args allowed), at least 2 required
	add_command("list", self, "list", -1, 2)
	
	
	
	add_command("spawn", self, "spawn")
	
	

	# Send a chat message to the only connected channel (<channel_name>)
	# Fails, if connected to more than one channel.
	chat("I'm alive!")

	# Send a chat message to channel <channel_name>
#	chat("TEST", initial_channel)

	# Send a whisper to target user
#	whisper("TEST", initial_channel)


func chat_message(data : SenderData, msg : String) -> void:
	print("Message received: " + msg)

# Check the CommandInfo class for the available info of the cmd_info.
func command_test(cmd_info : CommandInfo) -> void:
	print("A")

func hello_world(cmd_info : CommandInfo) -> void:
	chat("HELLO WORLD!")

func streamer_only(cmd_info : CommandInfo) -> void:
	chat("Streamer command executed")

func no_permission(cmd_info : CommandInfo) -> void:
	chat("NO PERMISSION!")

func greet(cmd_info : CommandInfo, arg_ary : PoolStringArray) -> void:
	chat("Greetings, " + arg_ary[0])

func greet_me(cmd_info : CommandInfo) -> void:
	chat("Greetings, " + cmd_info.sender_data.tags["display-name"] + "!")

func list(cmd_info : CommandInfo, arg_ary : PoolStringArray) -> void:
	chat(arg_ary.join(", "))

func spawn(cmd_info : CommandInfo) -> void:
	chat("I am spawning a thing, because ya said so")
	
	$"../EnemySpawner".spawn_enemy()
