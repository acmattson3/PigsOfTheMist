extends Node3D

var player = null
@onready var move_dir = Vector3.ZERO
@onready var nav_agent = $NavigationAgent3D
var move_pos = null
var target_pos = Vector3.ZERO

var move_away_elapsed = 0.0
var move_away_interval = 60.0
var move_away_pm = 16.0
var move_away_offset = -15.0
var curr_move_time = 30.0
var moving_away: bool = false
var player_near: bool = false

var attack_time = 30.0

var set_target_elapsed = 10.0
var attack_elapsed = 31.0
var squeal_elapsed = 4.0
var time = 0.0
var prev_pos = null
var stuck_elapsed = 0.0
func _physics_process(delta):
	time += delta
	squeal_elapsed += delta
	if moving_away:
		move_away_elapsed += delta
	else:
		attack_elapsed += delta
		if player.global_position.distance_to(global_position) < 2.0:
			attack_elapsed += delta # Stop attacking quicker when nearer the player
	
	if prev_pos == null:
		prev_pos = global_position
	
	
	set_target_elapsed += delta
	
	var rng = RandomNumberGenerator.new() 
	
	if move_away_elapsed >= curr_move_time and moving_away: # Attacking!
		if rng.randf() > 0.5:
			$DistantSquealSound.play()
		player_near = false
		moving_away = false
		attack_elapsed = 0.0
		move_away_elapsed = 0.0
	
	if not moving_away:
		target_pos = player.global_position
		if player.global_position.distance_to(global_position) < 5.0 and squeal_elapsed > 7.0:
			var sound = get_node("NearbySquealSound" + str(rng.randi_range(1, 2)))
			sound.play()
			squeal_elapsed = 0.0
	
	if attack_elapsed >= attack_time and not moving_away: # Moving away!
		moving_away = true
		curr_move_time = move_away_interval + move_away_offset + move_away_pm*rng.randf_range(-1.0,1.0)
		target_pos = Vector3(rng.randf_range(-50.0,50.0), 0.0, rng.randf_range(-50.0,50.0))
		attack_elapsed = 0.0
	
	if moving_away and global_position.distance_to(player.global_position) < 15.0:
		if not player_near and move_away_elapsed > 5.0:
			player_near = true
			target_pos = global_position
		
		target_pos += (global_position-player.global_position).normalized() * delta * 10.0
	
	if set_target_elapsed > 0.25:
		nav_agent.set_target_position(target_pos)
		set_target_elapsed = 0.0

func get_input_dir():
	move_pos = nav_agent.get_next_path_position()
	
	move_dir = (global_position-move_pos).normalized()
	
	return -Vector2(move_dir.x, move_dir.z).normalized()
