## 分裂砖的小砖块（半尺寸，HP=1）
extends BrickBase

func _ready() -> void:
	brick_width = 32.0
	brick_height = 32.0
	hp = 1.0
	max_hp = 1.0
	super._ready()
	# 调整碰撞形状为半尺寸
	if collision_shape and collision_shape.shape is RectangleShape2D:
		(collision_shape.shape as RectangleShape2D).size = Vector2(32, 32)

func get_brick_type() -> String:
	return "split_child"
