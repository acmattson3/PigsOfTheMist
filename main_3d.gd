extends Node3D

var debugging = false

@onready var mushroom = load("res://objects/large_mushroom_3d.tscn")
@onready var golden_mushroom = load("res://objects/golden_mushroom.tscn")

@onready var static_objects = $World/StaticObjects

const mushroom_freq = 0.3
const spawn_radius = 3
const mushroom_spacing = 4
const spawn_area = 50
const golden_mushroom_spawn_dist = 10

var curr_gold_shroom = null

var golden_mushrooms_found = 0

@onready var player = $Player3D

var random_sound_elapsed = 0.0
var random_sound_interval = 12.0
func _process(delta):
	random_sound_elapsed += delta
	
	if random_sound_elapsed >= random_sound_interval:
		$RandomScarySound.global_position = player.global_position
		$RandomScarySound.play()
		random_sound_elapsed = 0.0
		random_sound_interval = randf_range(0.0, 60.0) + 30.0

func _ready() -> void:
	$Pig3D.auto_component.player = $Player3D
	$Pig3D2.auto_component.player = $Player3D
	$Pig3D3.auto_component.player = $Player3D
	
	if debugging:
		return
	var rng = RandomNumberGenerator.new()
	for x in range(-spawn_area,spawn_area):
		for z in range(-spawn_area,spawn_area):
			var can_spawn = true
			if x*x + z*z <= spawn_radius*spawn_radius:
				can_spawn = false
			for shroom in static_objects.get_children():
				if shroom.global_position.distance_to(Vector3(x, 0, z)) < mushroom_spacing:
					can_spawn = false
					break
			if rng.randf() < mushroom_freq:
				can_spawn = false
			if can_spawn:
				spawn_mushroom(x+rng.randf()/2.0, z+rng.randf()/2.0, rng.randf(), rng.randf_range(0.05, 2))
	
	place_golden_shroom()
	
	
func spawn_mushroom(x, z, rotate_normalized, size):
	#print("Spawning mushroom at (", x, ", ", z, ") with scale ", size)
	var new_mushroom = mushroom.instantiate()
	static_objects.add_child(new_mushroom)
	new_mushroom.global_position = Vector3(x, 0.0, z)
	new_mushroom.scale = Vector3(size, size, size)
	new_mushroom.rotation.y = 2*PI*rotate_normalized

func place_golden_shroom():
	var rng = RandomNumberGenerator.new()
	
	var rand_pos = Vector3(rng.randf_range(-spawn_area,spawn_area), 0, rng.randf_range(-spawn_area,spawn_area))
	while rand_pos.distance_to(Vector3.ZERO) <= golden_mushroom_spawn_dist:
		rand_pos = Vector3(rng.randf_range(-spawn_area,spawn_area), 0, rng.randf_range(-spawn_area,spawn_area))
	
	for shroom in static_objects.get_children():
		var total_repositions = 0
		while shroom.global_position.distance_to(rand_pos) < 1.0 and total_repositions <= 100:
			var shroom_to_golden_shroom = shroom.global_position - rand_pos
			rand_pos += shroom_to_golden_shroom / 5.0
			total_repositions += 1
		if total_repositions > 100:
			place_golden_shroom() # Start over
			return
	
	var gold_shroom = golden_mushroom.instantiate()
	gold_shroom.golden_mushroom_found.connect(_on_mushroom_found)
	add_child(gold_shroom)
	gold_shroom.global_position = rand_pos
	curr_gold_shroom = gold_shroom
	
	$World.bake_navigation_mesh()
	player.ui.golden_mushroom_pos = rand_pos

func _on_mushroom_found():
	golden_mushrooms_found += 1
	player.ui.mushrooms_obtained = golden_mushrooms_found
	print("Golden mushroom found! Total of ", golden_mushrooms_found)
	player.health_component.heal(50.0)
	place_golden_shroom()
