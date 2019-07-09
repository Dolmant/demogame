extends RigidBody2D

export var size = 1

func _ready():
	pass

func _on_Growth_timeout():
	print("growth")
	size += 1
	$Label.text = str(size)

func eaten():
	print("plant eaten")
	if size > 0:
		size -= 1
		$Label.text = str(size)
		return true
	return false