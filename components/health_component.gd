extends Node3D

var max_health = 100.0
var min_health = 0.0
var _health: float = 90.0:
	set(value):
		if value > max_health:
			_health = max_health
		elif value < min_health:
			_health = min_health
		else:
			_health = value

var last_damaged_elapsed: float = 10.0

var regen_interval: float = 0.5
var last_regen: float = -10.0
var regen_delta: float = 10.0
var regen_rate: float = 2.5 # Health per second

var dead: bool = false

signal damaged(amount: float)
signal healed(amount: float)
signal just_died

var time: float = 0.0
func _process(delta):
	time += delta
	regen_delta = time - last_regen
	last_damaged_elapsed += delta
	
	# Passive healing when not recently damaged
	if last_damaged_elapsed >= 6.0:
		if regen_delta >= regen_interval:
			heal(regen_rate)
			last_regen = time

func get_health():
	return _health

func heal(amount):
	if dead:
		return
	_health += amount
	healed.emit(amount)

func damage(amount):
	_health -= amount
	damaged.emit(amount)
	last_damaged_elapsed = 0.0
	if _health <= 0.0:
		just_died.emit()
		dead = true
