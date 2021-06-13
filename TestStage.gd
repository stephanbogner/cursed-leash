extends Node2D

# Layer 1 Person
# Layer 2 Dog
# Layer 3 Rope
# Layer 4 Poop

signal invert_screen_signal

var time_per_round = 90
var times_per_soul_switch = [14, 14, 12, 12, 10, 10, 8, 8, 6, 6, 6, 6, 6, 6]
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

var sound_zt = preload("res://sounds/Curse zt.ogg")
var sound_switch = preload("res://sounds/Curse switch.ogg")

func _ready():
	new_round()
	
	rope = Rope.instance()
	$RopeContainer.add_child(rope)
	rope.spawn(Person, Dog)
	#$Cam/ShaderColor.get_material().set_shader_param("intensity", 0)

func _physics_process(delta):
	var round_time_left = $RoundTimer.get_time_left()
	var fraction_left = round_time_left/time_per_round
	$Cam/CanvasLayer/Interface/TimeBar.set_value(fraction_left)
	
	var time_left = $SoulSwitchTimer.get_time_left()
	print(time_left)
	
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
	
	if Input.is_action_just_pressed("player1_action_primary"):
		if person == "player1" and power["player1"] >= 33:
			power["player1"] -= 33
			rope.pull()
			updatePowerBars()
			#Dog.get_node("C/reaction-zip").play()
			var selectedSound = barkZips[randi() % (barkZips.size() - 1)] # Via https://docs.godotengine.org/en/latest/tutorials/math/random_number_generation.html#getting-a-random-number
			playSound(selectedSound)
			Cam.get_node("ScreenShake").start(0.05, 15, 24, 0)
			
	if Input.is_action_just_pressed("player2_action_primary"):
		if person == "player2" and power["player2"] >= 33:
			power["player2"] -= 33
			rope.pull()
			updatePowerBars()
			#Dog.get_node("C/reaction-zip").play()
			var selectedSound = barkZips[randi() % (barkZips.size() - 1)] # Via https://docs.godotengine.org/en/latest/tutorials/math/random_number_generation.html#getting-a-random-number
			playSound(selectedSound)
			Cam.get_node("ScreenShake").start(0.05, 15, 24, 0)
		
	var person_position = Person.get_position()
	var dog_position = Dog.get_position()
	var position_between_players = (person_position + dog_position) / 2
	Cam.global_position = position_between_players
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
	$Cam/CanvasLayer/Interface/Power_player1.set_value(power.player1)
	$Cam/CanvasLayer/Interface/Power_player2.set_value(power.player2)

func _on_SoulSwitchTimer_timeout():
	$SoulSwitchTimer.stop()
	var time_per_soul_switch = copy_times_per_soul_switch.pop_front()
	$SoulSwitchTimer.set_wait_time(time_per_soul_switch)
	$SoulSwitchTimer.start()
	
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
	update_avatars(false)
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
	score[player] += 1
	updateScoreUI()


func _on_TestStage_invert_screen_signal(boolean):
	$Cam/ShaderColor.visible = boolean
	$Cam/ShaderGlitch.visible = boolean
	
	if boolean == true:
		update_avatars(true)
		playSound(sound_zt)
		Cam.get_node("ScreenShake").start(0.05, 18, 33, 0)
	else:
		update_avatars(false)

func update_avatars(inverted):
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

func playSound(sound):
	var ztPlayer = AudioStreamPlayer.new()
	add_child(ztPlayer)
	sound.set_loop(false)
	ztPlayer.set_stream(sound)
	ztPlayer.play()
	yield(ztPlayer, "finished") #Via https://godotengine.org/qa/67049/help-with-audiostreamplayer
	ztPlayer.queue_free()

func evaluate_winner():
	if score.player1 == score.player2:
		print("Tie")
	elif score.player1 < score.player2:
		print("Player 2 (on the right) won")
	else:
		print("Player 1 (on the left) won")

func new_round():
	copy_times_per_soul_switch = [] + times_per_soul_switch
	person = "player1"
	
	score = {
		"player1": 0,
		"player2": 0
	}
	
	power = {
		"player1": 100,
		"player2": 100
	}
	updatePowerBars()
	
	updateScoreUI()
	
	place_loot(160)
	update_avatars(false)
	
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
	new_round()
	pass # Replace with function body.


func _on_PowerTimer_timeout():
	power.player1 += 0.5
	power.player1 = min(100, power.player1)
	power.player2 += 0.5
	power.player2 = min(100, power.player1)
	updatePowerBars()
