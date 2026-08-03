class_name DangerOverlay
extends Node2D

# Draws a translucent overlay on danger cells (array of Vector2i in 'cells')

export(Array, Vector2i) var cells: Array = []
export(Color) var color: Color = Color(1, 0.2, 0.2, 0.35)
export(int) var cell_size := 48

func _draw() -> void:
    for c in cells:
        var pos = Vector2(c.x * cell_size, c.y * cell_size)
        draw_rect(Rect2(pos, Vector2(cell_size, cell_size)), color)

func set_cells(new_cells: Array) -> void:
    cells = new_cells
    update()
