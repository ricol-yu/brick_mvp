## 坚硬砖块（需 3 次命中击碎）
extends BrickBase

func _ready() -> void:
	hp = BalanceData.BRICK_HARD_HP
	super._ready()

func get_brick_type() -> String:
	return "hard"
