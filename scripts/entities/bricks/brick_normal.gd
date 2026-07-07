## 普通砖块（1次击碎）
extends BrickBase

func _ready() -> void:
	hp = BalanceData.BRICK_NORMAL_HP
	super._ready()

func get_brick_type() -> String:
	return "normal"
