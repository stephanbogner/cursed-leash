extends RigidBody2D

signal go_to
# Called when the node enters the scene tree for the first time.
func _ready():
	$button_reply/AnimationPlayer.play("Button_Cycle")
	self.emit_signal("go_to", "chat")
	pass # Replace with function body.

# Via https://www.reddit.com/r/godot/comments/9jjro2/how_to_detet_mouse_clicks_in_ui_element/
func _input(event):
	if event is InputEventMouseButton:
		print("clicked")
