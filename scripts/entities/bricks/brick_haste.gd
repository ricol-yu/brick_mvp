## 加速砖 — 击碎时全场砖块下推加速 50%，持续 3 秒，可叠加
extends BrickBase

## 加速倍率
const HASTE_MULTIPLIER: float = 1.5
## 加速持续时间（秒）
const HASTE_DURATION: float = 3.0

func _ready() -> void:
	hp = BalanceData.BRICK_NORMAL_HP
	super._ready()

func get_brick_type() -> String:
	return "haste"

## 砖块被击碎 — 触发全场加速
func _on_destroyed() -> void:
	EventBus.brick_destroyed.emit(self, reward_exp)
	_apply_haste()
	queue_free()

## 应用加速效果
func _apply_haste() -> void:
	var game_world := get_tree().get_first_node_in_group("game_world") as Node2D
	if game_world and game_world.has_method("apply_push_speed_boost"):
		game_world.apply_push_speed_boost(HASTE_MULTIPLIER, HASTE_DURATION)
