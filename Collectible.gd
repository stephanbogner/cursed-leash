extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	var randomX = randi() % 2300 * 2 - 2300
	var randomY = randi() % 2300 * 2 - 2300
	print(randomX, randomY)
	self.set_global_position(Vector2(randomX, randomY))

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
