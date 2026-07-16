## 诅咒砖 — 击碎时给球施加减速诅咒，球速降低至 40%，持续 6 秒
extends BrickBase

## 诅咒持续时间（秒）
const CURSE_DURATION: float = 6.0
## 减速倍率（40% 原速）
const CURSE_SLOW_MULTIPLIER: float = 0.4

func _ready() -> void:
	hp = BalanceData.BRICK_NORMAL_HP
	super._ready()

func get_brick_type() -> String:
	return "curse"

## 砖块被击碎 — 触发球减速
func _on_destroyed() -> void:
	EventBus.brick_destroyed.emit(self, reward_exp)
	_apply_curse()
	queue_free()

## 应用减速效果
func _apply_curse() -> void:
	var ball := get_tree().get_first_node_in_group("ball") as Node2D
	if ball and ball.has_method("apply_curse_slow"):
		ball.apply_curse_slow(CURSE_SLOW_MULTIPLIER, CURSE_DURATION)
