## 诅咒砖 — 击碎时给挡板施加"操控反转"诅咒，左右方向相反，持续 5 秒
extends BrickBase

## 诅咒持续时间（秒）
const CURSE_DURATION: float = 5.0

func _ready() -> void:
	hp = BalanceData.BRICK_NORMAL_HP
	super._ready()

func get_brick_type() -> String:
	return "curse"

## 砖块被击碎 — 触发挡板诅咒
func _on_destroyed() -> void:
	EventBus.brick_destroyed.emit(self, reward_exp)
	_apply_curse()
	queue_free()

## 应用诅咒效果
func _apply_curse() -> void:
	var paddle := get_tree().get_first_node_in_group("paddle") as Node2D
	if paddle and paddle.has_method("apply_curse"):
		paddle.apply_curse(CURSE_DURATION)
