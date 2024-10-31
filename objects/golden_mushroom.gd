extends StaticBody3D

signal golden_mushroom_found

func _on_area_3d_body_entered(_body: Node3D) -> void:
	golden_mushroom_found.emit()
	queue_free()
