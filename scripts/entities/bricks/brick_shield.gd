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
	var hp_before := hp
	super.take_damage(damage)
	# 伤害全被护盾吸收，砖块 HP 未变，恢复原始颜色而非受击暗色
	if hp >= hp_before and hp > 0 and sprite:
		sprite.modulate = _base_color
	# 检测护盾从有到无
	if shield_before > 0 and shield <= 0 and not shield_was_broken:
		shield_was_broken = true
		_on_shield_broken()

## 护盾碎裂时：变成硬砖（3 HP）
func _on_shield_broken() -> void:
	# 护盾碎裂后，砖块变成硬砖（3 HP）
	hp = BalanceData.BRICK_HARD_HP
	max_hp = BalanceData.BRICK_HARD_HP
	# 将基色改为硬砖的灰色，后续受击变暗基于此颜色计算
	_base_color = Color(0.5, 0.5, 0.6, 1.0)
	# 换成硬砖贴图
	var hard_tex := load("res://assets/sprites/bricks/brick_hard.png")
	if sprite and hard_tex:
		sprite.texture = hard_tex
	# 必须重新调用 _update_visual 让 sprite 颜色反映新 HP
	_update_visual()
