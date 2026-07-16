## 分裂砖 — 击碎时分裂为 2 个半 HP 小砖块
extends BrickBase

## 分裂后小砖块的 HP
var child_hp: float = 0.0

func _ready() -> void:
	hp = BalanceData.BRICK_NORMAL_HP
	child_hp = hp * 0.5
	super._ready()

func get_brick_type() -> String:
	return "split"

## 砖块被击碎 — 生成 2 个小砖块
func _on_destroyed() -> void:
	EventBus.brick_destroyed.emit(self, reward_exp)
	_spawn_child_bricks()
	queue_free()

## 生成 2 个分裂小砖块
func _spawn_child_bricks() -> void:
	var child_scene_path := "res://scenes/entities/bricks/brick_split_child.tscn"
	if not ResourceLoader.exists(child_scene_path):
		return
	var child_scene := load(child_scene_path)
	if not child_scene:
		return
	
	var half_w := brick_width * 0.5
	# 左侧小砖块
	var left_child: Node2D = child_scene.instantiate()
	left_child.position = position + Vector2(-half_w * 0.5, 0)
	left_child.hp = child_hp
	left_child.max_hp = child_hp
	get_parent().add_child(left_child)
	
	# 右侧小砖块
	var right_child: Node2D = child_scene.instantiate()
	right_child.position = position + Vector2(half_w * 0.5, 0)
	right_child.hp = child_hp
	right_child.max_hp = child_hp
	get_parent().add_child(right_child)
