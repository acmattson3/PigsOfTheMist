extends CanvasLayer

@onready var player = get_parent()
var golden_mushroom_pos = Vector3.ZERO
var mushrooms_obtained = 0

const arrow_max_left = 70
const arrow_max_right = 1920 - 70
const arrow_pm_range = (arrow_max_right - arrow_max_left)/2.0
const arrow_center = 960

var prev_cross_y = null
func _process(_delta):
	$PanelContainer/GridContainer/MushroomsFound.text = str(mushrooms_obtained)
	$ProgressBar.value = player.health_component.get_health()
	
	var player_dir = -player.transform.basis.z.normalized()
	var shroom_dir = (player.global_position-golden_mushroom_pos).normalized()
	var cross = player_dir.cross(shroom_dir)
	var dot = player_dir.dot(shroom_dir)
	if prev_cross_y != cross.y:
		prev_cross_y = cross.y
		if dot < 0:
			$Arrow.position.x = arrow_center + arrow_pm_range*cross.y
		elif dot > 0:
			if cross.y < 0:
				$Arrow.position.x = arrow_max_left
			else:
				$Arrow.position.x = arrow_max_right

func display_you_lose():
	$YouLoseLabel.show()
