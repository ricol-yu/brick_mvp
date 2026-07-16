## 护盾砖 — 外层 2 HP 护盾，护盾存在时砖块无敌
extends BrickBase

## 护盾是否已碎裂
var shield_was_broken: bool = false

func _ready() -> void:
	hp = BalanceData.BRICK_NORMAL_HP
	shield = 2.0  # 外层护盾 2 HP
	super._ready()

func get_brick_type() -> String:
	return "shield"

## 覆写受击逻辑，检测护盾碎裂
func take_damage(damage: float) -> void:
	var shield_before := shield
	super.take_damage(damage)
	# 检测护盾从有到无
	if shield_before > 0 and shield <= 0 and not shield_was_broken:
		shield_was_broken = true
		_on_shield_broken()

## 护盾碎裂时的视觉反馈
func _on_shield_broken() -> void:
	if sprite:
		# 蓝色碎裂闪烁
		sprite.modulate = Color(0.5, 0.7, 1.5, 1.0)
