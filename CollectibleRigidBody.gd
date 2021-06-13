extends RigidBody2D

func smear():
	print("smear")
	$CollisionShape2D.disabled = true
	$CollisionShape2D/poop.hide()
	$CollisionShape2D/smear.rotation_degrees = randi() % 360
	$CollisionShape2D/smear.show()
