extends Node2D

# Layer 1 Person
# Layer 2 Dog
# Layer 3 Rope
# Layer 4 Poop

signal invert_screen_signal
signal change_player

var time_per_round = 60
#var times_per_soul_switch = [14, 14, 12, 12, 10, 10, 8, 8, 6, 6, 6, 6, 6, 6]
var times_per_soul_switch = [14, 14, 10, 10, 6, 6, 10, 10, 10, 10]
var copy_times_per_soul_switch
var warning_time_switch = 5
var invert_screen = false
var Collectible = preload("res://Collectible.tscn")
var Rope = preload("res://Rope.tscn")
var rope
var start_pos := Vector2(100, 100)
var end_pos := Vector2(200, 200)

onready var Person = get_node("Person")
onready var Dog = get_node("Dog")
onready var Cam = get_node("Cam")

var score = {
	"player1": 0,
	"player2": 0
}

var power = {
	"player1": 100.0,
	"player2": 100.0
}

var person = "player1"

var barkZips = [
	preload("res://sounds/Bark zip 1.ogg"),
	preload("res://sounds/Bark zip 2.ogg"),
	preload("res://sounds/Bark zip 3.ogg"),
	preload("res://sounds/Bark zip 4.ogg"),
	preload("res://sounds/Bark zip 5.ogg")
]

var soundsPerson = [
	preload("res://sounds/Call 1.ogg"),
	preload("res://sounds/Call 2.ogg"),
	preload("res://sounds/Call 3.ogg"),
	preload("res://sounds/Call 4.ogg"),
	preload("res://sounds/Call 5.ogg"),
	preload("res://sounds/Call 6.ogg"),
	preload("res://sounds/Call 7.ogg"),
]

var soundsDog = [
	preload("res://sounds/Bark 1.ogg"),
	preload("res://sounds/Bark 2.ogg"),
	preload("res://sounds/Bark 3.ogg"),
	preload("res://sounds/Bark 4.ogg"),
	preload("res://sounds/Bark 5.ogg"),
	preload("res://sounds/Bark 6.ogg"),
	preload("res://sounds/Bark 7.ogg"),
]

var sounds_click = [
	preload("res://sounds/Click 1.ogg"),
	preload("res://sounds/Click 2.ogg"),
	preload("res://sounds/Click 3.ogg"),
]

var switchSoundPlayed = false
var sound_zt = preload("res://sounds/Curse zt.ogg")
var sound_switch = preload("res://sounds/Curse switch.ogg")
var sound_beast_mode = preload("res://sounds/Bark high pitched.ogg")

var current_stage = "screen1"

# Via https://www.reddit.com/r/godot/comments/9jjro2/how_to_detet_mouse_clicks_in_ui_element/
func _input(event):
	if event is InputEventMouseButton && event.pressed == true:
		interface_input()

func screenShakeAndRumble(duration = 0.2, frequency = 15, amplitude = 16, priority = 0):
	Cam.get_node("ScreenShake").start(duration, frequency, amplitude, priority)
	var amplitude_small_motor = clamp(amplitude/8, 0, 1)
	var amplitude_large_motor = clamp(amplitude/20, 0, 1)
	print(amplitude_small_motor, amplitude_large_motor)
	Input.start_joy_vibration(0, amplitude_small_motor, amplitude_large_motor, min(0.05, duration) )
	pass

func interface_input():
	screenShakeAndRumble(0.05, 8, 18, 0)
	print("clicked")
	playRandomSound(sounds_click)
	if current_stage == "screen1":
		$Cam/CanvasLayer/Intro/Screen1.hide()
		current_stage = "screen2"
	elif current_stage == "screen2":
		$Cam/CanvasLayer/Intro/Screen2.hide()
		current_stage = "screen3"
	elif current_stage == "screen3":
		$Cam/CanvasLayer/Intro.hide()
		$Cam/CanvasLayer/Intro/Screen1.show()
		$Cam/CanvasLayer/Intro/Screen2.show()
		current_stage = "explanation"
		updateScoreUI()
		update_avatars()
		showBubblesFor(8)
	elif current_stage == "round-over":
		current_stage = "game"
		screenShakeAndRumble(0.3, 24, 35)
		new_round()

func _ready():
	place_loot(200)
	$Cam/CanvasLayer/Intro/Screen1/text/headline/animpl.play("cycle")
	$Cam/CanvasLayer/Intro/Screen1/text/button/animpl.play("cycle")
	$Cam/CanvasLayer/Intro/Screen2/text/button/animpl.play("cycle")
	$Cam/CanvasLayer/Intro/Screen3/text/button/animpl.play("cycle")
	$Cam/ShaderColor.hide()
	rope = Rope.instance()
	$RopeContainer.add_child(rope)
	rope.spawn(Person, Dog)
	#$Cam/ShaderColor.get_material().set_shader_param("intensity", 0)

func _physics_process(delta):
	$bubble_dog.position = $Dog/C/head.global_position + Vector2(-130, 60)
	$bubble_person.position = $Person.position + Vector2(100, 40)
	
	if Input.is_action_just_pressed("ui_accept"):
		interface_input()
	
	if current_stage == "game":
		var round_time_left = $RoundTimer.get_time_left()
		var fraction_left = round_time_left/time_per_round
		$Cam/CanvasLayer/Interface/TimeBar.set_value(fraction_left)
		
		var time_left = $SoulSwitchTimer.get_time_left()
		
		var length_of_switch_sound = 1.1
		if time_left < length_of_switch_sound:
			if switchSoundPlayed == false:
				switchSoundPlayed = true
				playSound(sound_switch)
		
		if time_left < warning_time_switch:
			var extra_black_screen = 0.2
			var inverted_fraction = max(0,(time_left - extra_black_screen)/(warning_time_switch - extra_black_screen))
			var fraction = 1 - inverted_fraction
			if time_left < extra_black_screen:
				if invert_screen == false:
					emit_signal("invert_screen_signal", true)
					print("now true")
				invert_screen = true
			else:
				var helper_invert = sin(fraction * fraction * fraction * 80);
				if helper_invert < 0:
					if invert_screen == false:
						emit_signal("invert_screen_signal", true)
						print("now true")
					invert_screen = true
				else:
					if invert_screen == true:
						emit_signal("invert_screen_signal", false)
						print("now false")
					invert_screen = false
			#$Cam/ShaderGlitch.get_material().set_shader_param("shake_power", fraction/10)
			#$Cam/ShaderGlitch.get_material().set_shader_param("shake_rate", 0.2)
			#$Cam/Shader.get_material().set_shader_param("shaderStrength", fraction)
		
	if current_stage == "game" or current_stage == "round-over" or current_stage == "explanation":
		if Input.is_action_just_pressed("player1_action_primary"):
			check_input_primary("player1")
			
		if Input.is_action_just_pressed("player2_action_primary"):
			check_input_primary("player2")
			
		if Input.is_action_just_pressed("player1_action_secondary"):
			check_input_secondary("player1")
			
		if Input.is_action_just_pressed("player2_action_secondary"):
			check_input_secondary("player2")
		
	var person_position = Person.get_position()
	var dog_position = Dog.get_position()
	var position_between_players = (person_position + dog_position) / 2
	Cam.global_position = position_between_players

func check_input_primary(player):
	var cost_rope_pull = 66
	var cost_beast_mode = 33
	# If person is played by player
	if person == player:
		print("check for human action")
		if power[player] >= cost_rope_pull:
			power[player] -= cost_rope_pull
			rope.pull()
			updatePowerBars()
			playRandomSound(barkZips)
			
			screenShakeAndRumble(0.05, 15, 24, 0)
	
	# If person is not played by player -> dog
	if person != player:
		print("check for dog action")
		if power[player] >= cost_beast_mode:
			power[player] -= cost_beast_mode
			updatePowerBars()
			playSound(sound_beast_mode)
			$Dog.activate_beast_mode()
			screenShakeAndRumble(0.05, 8, 18, 0)
	
func check_input_secondary(player):
	if person == player:
		screenShakeAndRumble(0.05, 3, 8, 0)
		playRandomSound(soundsPerson)
	if person != player:
		screenShakeAndRumble(0.05, 3, 8, 0)
		playRandomSound(soundsDog)
	
#func _input(event):
#	if event is InputEventMouseButton and !event.is_pressed():
#		if start_pos == Vector2.ZERO:
#			start_pos = get_global_mouse_position()
#		else:
#			end_pos = get_global_mouse_position()
#			var rope = Rope.instance()
#			add_child(rope)
#			rope.spwan_rope(start_pos, end_pos)
#			start_pos = Vector2.ZERO
#			end_pos = Vector2.ZERO

func updatePowerBars():
	#print(power)
	$Cam/CanvasLayer/Interface/Power_player1.set_value(power.player1)
	$Cam/CanvasLayer/Interface/Power_player2.set_value(power.player2)

func _on_SoulSwitchTimer_timeout():
	$SoulSwitchTimer.stop()
	switchSoundPlayed = false
	var time_per_soul_switch = copy_times_per_soul_switch.pop_front()
	$SoulSwitchTimer.set_wait_time(time_per_soul_switch)
	$SoulSwitchTimer.start()
	#showBubblesFor(3)
	rope.chaos()
	#var radians = $Dog.global_position.angle_to($Person.global_position)
	#var radiansForPerson = radians - PI / 2
	#var directionForPerson = Vector2(cos(radiansForPerson), sin(radiansForPerson))
	#print(radiansForPerson, " ", directionForPerson)
	#$Person.add_central_force(directionForPerson * 400)
	#var radians = r.get_rotation() - PI / 2
	#var direction = Vector2(cos(radians), sin(radians))
	#r.set_linear_velocity(direction * 40 * i)
	
	#$Dog.
	
	print("switch")
	if person == "player1":
		person = "player2"
	else:
		person = "player1"
	update_avatars()
	emit_signal("invert_screen_signal", false)
	pass # Replace with function body.

func place_loot(number_of_loot):
	for n in $Poops.get_children():
		n.queue_free()
	
	for	i in number_of_loot:
		var collectible = Collectible.instance()
		$Poops.add_child(collectible)

#func _on_LootDropTimer_timeout():
#	var collectible = Collectible.instance()
	#add_child(collectible)
	#pass # Replace with function body.

func updateScoreUI():
	$Cam/CanvasLayer/Interface.get_node("Player1").set_text(str(score.player1))
	$Cam/CanvasLayer/Interface.get_node("Player2").set_text(str(score.player2))
	print(score)

func _on_Dog_scored(player):
	screenShakeAndRumble(0.05, 10, 20, 0)
	if current_stage == "game":
		score[player] += 1
		updateScoreUI()


func _on_TestStage_invert_screen_signal(boolean):
	$Cam/ShaderColor.visible = boolean
	
	if boolean == true:
		update_avatars(true)
		playSound(sound_zt)
		screenShakeAndRumble(0.05, 18, 33, 0)
	else:
		update_avatars()

func update_avatars(inverted = false):
	if inverted == false:
		$Cam/CanvasLayer/Interface/person_player1.visible = person == "player1"
		$Cam/CanvasLayer/Interface/pug_player1.visible = person != "player1"
		$Cam/CanvasLayer/Interface/person_player2.visible = person == "player2"
		$Cam/CanvasLayer/Interface/pug_player2.visible = person != "player2"
	else:
		$Cam/CanvasLayer/Interface/person_player1.visible = person != "player1"
		$Cam/CanvasLayer/Interface/pug_player1.visible = person == "player1"
		$Cam/CanvasLayer/Interface/person_player2.visible = person != "player2"
		$Cam/CanvasLayer/Interface/pug_player2.visible = person == "player2"

func playRandomSound(sounds):
	var selectedSound = sounds[randi() % sounds.size()]
	playSound(selectedSound)

func playSound(sound):
	var ztPlayer = AudioStreamPlayer.new()
	add_child(ztPlayer)
	sound.set_loop(false)
	ztPlayer.set_stream(sound)
	ztPlayer.play()
	yield(ztPlayer, "finished") #Via https://godotengine.org/qa/67049/help-with-audiostreamplayer
	ztPlayer.queue_free()

func evaluate_winner():
	$Cam/CanvasLayer/Winner/P1win.hide()
	$Cam/CanvasLayer/Winner/P2win.hide()
	$Cam/CanvasLayer/Winner/Tie.hide()
	if score.player1 == score.player2:
		$Cam/CanvasLayer/Winner/Tie.show()
		print("Tie")
	elif score.player1 > score.player2:
		$Cam/CanvasLayer/Winner/P1win.show()
		print("Player 1 (on the left) won")
	else:
		$Cam/CanvasLayer/Winner/P2win.show()
		print("Player 2 (on the right) won")
	$Cam/CanvasLayer/Winner.show()
	current_stage = "round-over"
	$SoulSwitchTimer.stop()

func new_round(leaveLoot = false):
	$Cam/ShaderColor.hide()
	$Cam/CanvasLayer/Winner.hide()
	copy_times_per_soul_switch = [] + times_per_soul_switch
	person = "player1"
	emit_signal("change_player", person)
	
	score = {
		"player1": 0,
		"player2": 0
	}
	
	power = {
		"player1": 100.0,
		"player2": 100.0
	}
	updatePowerBars()
	updateScoreUI()
	
	if leaveLoot == false:
		place_loot(200)

	update_avatars()
	
	$RoundTimer.stop()
	$RoundTimer.set_wait_time(time_per_round)
	$RoundTimer.one_shot = true
	$RoundTimer.start()
	
	$SoulSwitchTimer.stop()
	var time_per_soul_switch = copy_times_per_soul_switch.pop_front()
	$SoulSwitchTimer.set_wait_time(time_per_soul_switch)
	$SoulSwitchTimer.one_shot = true
	$SoulSwitchTimer.start()

func _on_RoundTimer_timeout():
	evaluate_winner()
	#new_round()
	pass # Replace with function body.


func _on_PowerTimer_timeout():
	power.player1 += 0.5
	power.player1 = min(100, power.player1)
	power.player2 += 0.5
	power.player2 = min(100, power.player2)
	updatePowerBars()

func showBubblesFor(showFor):
	$bubble_dog.show()
	$bubble_person.show()
	$BubbleOverlayTimer.stop()
	$BubbleOverlayTimer.set_wait_time(showFor)
	$BubbleOverlayTimer.one_shot = true
	$BubbleOverlayTimer.start()

func _on_BubbleOverlayTimer_timeout():
	if current_stage == "explanation":
		new_round(true)
		current_stage = "game"
	$bubble_dog.hide()
	$bubble_person.hide()
