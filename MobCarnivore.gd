extends Area2D

export var speed = 30
export var sight = 200

export (PackedScene) var MobCarnivore

var screen_size  # Size of the game window.

var state = 0
var location = Vector2(0, 0)
var food = Node2D # Must be a plant
var target = Node2D # Must be dynamic to follow a target
var rot_speed = 2
# 0 = looking for food
# 1 = going to location
# 2 = eating

var picked_random = false

# 3 = replicating

func _ready():
	$AnimatedSprite.animation = "walk"
	screen_size = get_viewport_rect().size
	$Area2D/CollisionShape2D.shape.radius = sight

func set_direction():
	state = 1
	var elements = $Area2D.get_overlapping_bodies()
	for element in elements:
		if element.is_in_group("Herbivore"):
			print("found herbivore to eat!")
			target = element
			picked_random = false
			return
	picked_random = true
	target = Node2D.new()
	# Move 2 seconds in a random direction
	target.position = (Vector2(rand_range(1, screen_size.x), rand_range(1, screen_size.y))-global_position).normalized() * speed * 2 + global_position
	target.position.x = clamp(target.position.x, 0, screen_size.x)
	target.position.y = clamp(target.position.y, 0, screen_size.y)

func walk(delta):
	if(!$AnimatedSprite.is_playing()):
    	$AnimatedSprite.play("walk")
	if !is_instance_valid(target):
		state = 0
		return
	if (target.position - global_position).length() < 10:
		state = 0
	var velocity = target.position - global_position
	velocity = velocity.normalized() * speed
	var target_rot = rad2deg(Vector2(0, 1).angle_to(velocity))
	var current_rot = $AnimatedSprite.rotation_degrees + 180
	if current_rot != target_rot:
		$AnimatedSprite.rotation_degrees += clamp(target_rot - current_rot, -rot_speed, rot_speed)
		velocity = velocity * (1 - clamp(target_rot - current_rot, -rot_speed, rot_speed) / (rot_speed * 2))
	position += velocity * delta

func eat():
	print("herbivore eaten")
	$AnimatedSprite.play("eat")
	food && food.eaten()
	state = 0
	
func replicate():
	state = 0
	var topscene = get_parent().add_child(MobCarnivore.instance())

func _process(delta):
	match state:
		0:
			set_direction()
		1:
			walk(delta)
		2:
			eat()
		3:
			replicate()
	position.x = clamp(position.x, 0, screen_size.x)
	position.y = clamp(position.y, 0, screen_size.y)

func _on_MobCarnivore_area_shape_entered(area_id, area, area_shape, self_shape):
	print("Entered Carnivore body")
	print(area.get_groups())
	if area.is_in_group("Herbivore"):
		print("eat herbivore yayyy")
		state = 2
		food = area

func _on_Timer_timeout():
	queue_free()

# if randomly walking and we see a herbivore, eat it
func _on_Area2D_area_shape_entered(area_id, area, area_shape, self_shape):
	print("Entered Carnivore sight")
	print(area.get_groups())
	if (state == 0 || state == 1) && picked_random && area.is_in_group("Herbivore"):
		state = 1
		print("imma eat that herbivore")
		picked_random = false
		target = area


func _on_AnimatedSprite_animation_finished():
	if($AnimatedSprite.animation == "eat"):
		$AnimatedSprite.stop()
