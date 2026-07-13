## 永久升级系统（Autoload）
## 管理 Meta Shop 中的永久升级，连接 SaveManager 持久化
extends Node

## 永久升级定义 { upgrade_id: { "name", "description", "max_level", "base_cost", "cost_scale" } }
const UPGRADES: Dictionary = {
	"meta_ball_damage": {
		"name": "球体强化",
		"description": "球基础伤害 +0.1",
		"max_level": 5,
		"base_cost": 10,
		"cost_scale": 1.5,
		"effect_key": "damageAdd",
		"effect_value_per_level": 0.1,
	},
	"meta_paddle_width": {
		"name": "挡板扩展",
		"description": "挡板基础宽度 +5",
		"max_level": 5,
		"base_cost": 10,
		"cost_scale": 1.5,
		"effect_key": "widthAdd",
		"effect_value_per_level": 5.0,
	},
	"meta_start_exp": {
		"name": "经验加速",
		"description": "每局初始经验 +2",
		"max_level": 3,
		"base_cost": 15,
		"cost_scale": 2.0,
		"effect_key": "startExp",
		"effect_value_per_level": 2,
	},
	"meta_coin_bonus": {
		"name": "金币猎手",
		"description": "每局结束金币奖励 +10%",
		"max_level": 5,
		"base_cost": 20,
		"cost_scale": 1.8,
		"effect_key": "coinBonus",
		"effect_value_per_level": 0.1,
	},
	"meta_start_balls": {
		"name": "多球出击",
		"description": "每局初始球数量 +1",
		"max_level": 3,
		"base_cost": 25,
		"cost_scale": 2.0,
		"effect_key": "startBalls",
		"effect_value_per_level": 1,
	},
}

func _ready() -> void:
	EventBus.game_started.connect(_on_game_started)

## 获取升级的当前等级
func get_upgrade_level(upgrade_id: String) -> int:
	return SaveManager.get_meta_upgrade_level(upgrade_id)

## 获取升级的当前花费
func get_upgrade_cost(upgrade_id: String) -> int:
	if not UPGRADES.has(upgrade_id):
		return 999999
	var info: Dictionary = UPGRADES[upgrade_id]
	var level := get_upgrade_level(upgrade_id)
	return int(info["base_cost"] * pow(info["cost_scale"], level))

## 尝试购买升级
func try_purchase(upgrade_id: String) -> bool:
	if not UPGRADES.has(upgrade_id):
		return false
	var info: Dictionary = UPGRADES[upgrade_id]
	var level := get_upgrade_level(upgrade_id)
	if level >= info["max_level"]:
		return false
	var cost := get_upgrade_cost(upgrade_id)
	if SaveManager.spend_coins(cost):
		EventBus.meta_upgrade_purchased.emit(upgrade_id)
		return true
	return false

## 获取某个升级的效果值（基于当前等级）
func get_effect_value(upgrade_id: String) -> float:
	if not UPGRADES.has(upgrade_id):
		return 0.0
	var info: Dictionary = UPGRADES[upgrade_id]
	var level := get_upgrade_level(upgrade_id)
	return float(info["effect_value_per_level"]) * level

## 游戏开始时应用永久升级效果
func _on_game_started() -> void:
	# 应用初始经验加成
	var start_exp := int(get_effect_value("meta_start_exp"))
	if start_exp > 0:
		ExpSystem.add_exp(start_exp)
	
	# 应用初始球数量加成
	var extra_balls := int(get_effect_value("meta_start_balls"))
	if extra_balls > 0:
		# 通知 GameWorld 生成额外的球
		EventBus.meta_start_balls_changed.emit(extra_balls)

## 获取金币奖励加成倍率
func get_coin_bonus_multiplier() -> float:
	return 1.0 + get_effect_value("meta_coin_bonus")
