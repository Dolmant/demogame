extends Area2D

export var speed = 50
export var safe_distance = 150

export (PackedScene) var MobHerbivore

var screen_size  # Size of the game window.

var state = 0
var location = Vector2(0, 0)
var food = Node2D # Must be a plant
var predator = Node2D
var target = Vector2(0, 0) # can be a position as we are always heading to a static location
var rot_speed = 2
# 0 = looking for food
# 1 = going to location
# 2 = eating
# 3 = running from predator
# 4 = replicating
# 5 = digesting, cant do anything except run away

func _ready():
	screen_size = get_viewport_rect().size
	$Area2D/CollisionShape2D.shape.radius = safe_distance

func set_direction():
	state = 1
	var elements = $Area2D.get_overlapping_bodies()
	for element in elements:
		if element.is_in_group("Plant") && element.size > 0:
			target = element.position
			if (target - global_position).length() < 20:
				state = 2
				food = element
			print("found plant to eat!")
			return
	# Move 2 seconds in a random direction
	target = (Vector2(rand_range(1, screen_size.x), rand_range(1, screen_size.y))-global_position).normalized() * speed * 2 + global_position
	target.x = clamp(target.x, 0, screen_size.x)
	target.y = clamp(target.y, 0, screen_size.y)

func walk(delta):
	if(!$AnimatedSprite.is_playing()):
    	$AnimatedSprite.play("walk")
	if (target - global_position).length() < 10:
		state = 0
	var velocity = target - global_position
	velocity = velocity.normalized() * speed
	var target_rot = rad2deg(Vector2(0, 1).angle_to(velocity))
	var current_rot = $AnimatedSprite.rotation_degrees + 180
	if current_rot != target_rot:
		$AnimatedSprite.rotation_degrees += clamp(target_rot - current_rot, -rot_speed, rot_speed)
		velocity = velocity * (1 - clamp(target_rot - current_rot, -rot_speed, rot_speed) / (rot_speed * 2))
	position += velocity * delta

func eat():
	print("herbivore eating now")
	$AnimatedSprite.play("eat")
	if !food.eaten():
		state = 0
	else:
		state = 5
		$Timer.start()
	
func run_away(delta):
	if !is_instance_valid(predator):
		state = 0
		return
	if (predator.position - global_position).length() > (safe_distance + 100):
		state = 0
		print("yay safe")
		return
	var velocity = global_position - predator.position
	velocity = velocity.normalized() * speed
	var target_rot = rad2deg(Vector2(0, 1).angle_to(velocity))
	var current_rot = $AnimatedSprite.rotation_degrees + 180
	if current_rot != target_rot:
		$AnimatedSprite.rotation_degrees += clamp(target_rot - current_rot, -rot_speed, rot_speed)
		velocity = velocity * (1 - clamp(target_rot - current_rot, -rot_speed, rot_speed) / (rot_speed * 2))
	position += velocity * delta
	
func replicate():
	state = 0
	var topscene = get_parent().add_child(MobHerbivore.instance())

func _process(delta):
	match state:
		0:
			set_direction()
		1:
			walk(delta)
		2:
			eat()
		3:
			run_away(delta)
		4:
			replicate()
		5:
			pass
	position.x = clamp(position.x, 0, screen_size.x)
	position.y = clamp(position.y, 0, screen_size.y)

func eaten():
	print("herbivore eaten")
	queue_free()

func _on_Area2D_area_shape_entered(area_id, area, area_shape, self_shape):
	print("Entered Herbivore sight")
	print(area.get_groups())
	if state != 3 && area.is_in_group("Carnivore"):
		print("runnnn")
		predator = area
		state = 3

func _on_MobHerbivore_body_shape_entered(body_id, body, body_shape, local_shape):
	if state != 3 && body.is_in_group("Plant"):
		print("eat plant now yay")
		state = 2
		food = body

func _on_Timer_timeout():
	queue_free()

func _on_AnimatedSprite_animation_finished():
	if($AnimatedSprite.animation == "eat"):
		print("finished eating!")
		$AnimatedSprite.animation = "walk"
		$AnimatedSprite.stop()
		state = 0
