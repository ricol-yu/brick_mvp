## 球伤害计算器
## 独立的伤害计算模块，被 ball.gd 调用
class_name BallDamageCalc
extends RefCounted

## 球的运行时属性（受 Build 影响）
var damage: float = BalanceData.BALL_BASE_DAMAGE
var speed: float = BalanceData.BALL_BASE_SPEED
var size: float = BalanceData.BALL_BASE_SIZE
var crit_chance: float = BalanceData.BALL_BASE_CRIT_CHANCE
var crit_multiplier: float = BalanceData.BALL_BASE_CRIT_MULTIPLIER
var pierce: int = BalanceData.BALL_BASE_PIERCE
var split_count: int = BalanceData.BALL_BASE_SPLIT_COUNT

## 挡板反弹加成倍率
var reflect_bonus: float = BalanceData.PADDLE_BASE_REFLECT_BONUS

## 下压减速比例（Safety Build）
var push_speed_reduction: float = 0.0

## 火焰伤害（Fire Build）
var fire_damage: float = 0.0
var fire_duration: float = 0.0

## 重置到基础值
func reset() -> void:
	damage = BalanceData.BALL_BASE_DAMAGE
	speed = BalanceData.BALL_BASE_SPEED
	size = BalanceData.BALL_BASE_SIZE
	crit_chance = BalanceData.BALL_BASE_CRIT_CHANCE
	crit_multiplier = BalanceData.BALL_BASE_CRIT_MULTIPLIER
	pierce = BalanceData.BALL_BASE_PIERCE
	split_count = BalanceData.BALL_BASE_SPLIT_COUNT
	reflect_bonus = BalanceData.PADDLE_BASE_REFLECT_BONUS
	push_speed_reduction = 0.0
	fire_damage = 0.0
	fire_duration = 0.0

## 获取速度倍率（用于伤害计算）
func get_speed_multiplier() -> float:
	return speed / BalanceData.BALL_BASE_SPEED

## 计算碰撞砖块的伤害
## reflect_multiplier: 反弹类型倍率（普通=1, Perfect=1.25, 保底线=0.8）
func calc_brick_damage(reflect_multiplier: float = 1.0) -> Dictionary:
	var result := BalanceData.calculate_damage(
		damage,
		get_speed_multiplier(),
		crit_chance,
		crit_multiplier,
		reflect_multiplier * reflect_bonus
	)
	return result

## 应用 Build 效果到属性
func apply_build_effect(build_data: BuildData) -> void:
	var eff := build_data.effect
	if eff.has("damageAdd"):
		damage += eff["damageAdd"]
	if eff.has("damageMultiplier"):
		damage *= eff["damageMultiplier"]
	if eff.has("speedAdd"):
		speed += eff["speedAdd"]
	if eff.has("speedMultiplier"):
		speed *= eff["speedMultiplier"]
	if eff.has("sizeAdd"):
		size += eff["sizeAdd"]
	if eff.has("sizeMultiplier"):
		size *= eff["sizeMultiplier"]
	if eff.has("critChanceAdd"):
		crit_chance = minf(crit_chance + eff["critChanceAdd"], 1.0)
	if eff.has("critMultiplierAdd"):
		crit_multiplier += eff["critMultiplierAdd"]
	if eff.has("pierceAdd"):
		pierce += int(eff["pierceAdd"])
	if eff.has("splitCountAdd"):
		split_count += int(eff["splitCountAdd"])
	if eff.has("reflectBonusAdd"):
		reflect_bonus += eff["reflectBonusAdd"]
	if eff.has("pushSpeedReduction"):
		push_speed_reduction += eff["pushSpeedReduction"]
	if eff.has("fireDamage"):
		fire_damage += eff["fireDamage"]
	if eff.has("fireDuration"):
		fire_duration += eff["fireDuration"]
