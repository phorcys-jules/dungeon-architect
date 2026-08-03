class_name DangerOverlay
extends Node2D

@export var cells: Array[Vector2i] = []
@export var color: Color = Color(1.0, 0.2, 0.2, 0.35)
@export var cell_size: int = 48

func _draw() -> void:
	for cell in cells:
		var position := Vector2(cell.x * cell_size, cell.y * cell_size)
		draw_rect(Rect2(position, Vector2(cell_size, cell_size)), color)

func set_cells(new_cells: Array[Vector2i]) -> void:
	cells = new_cells
	queue_redraw()
