extends RigidBody2D


var id := -1
var parent : Object = null

func _ready():
	self.set_friction(0)
