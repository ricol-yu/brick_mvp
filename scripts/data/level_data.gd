## 关卡数据结构定义（Godot Resource）
## 每个关卡存储为 .tres 文件
class_name LevelData
extends Resource

## 关卡 ID
@export var id: int = 1

## 关卡名称
@export var level_name: String = ""

## 砖块行配置列表
## 每行: { "type": "normal"|"hard", "count": int, "hp_override": float (可选) }
@export var rows: Array[Dictionary] = []

## 是否出现 Boss
@export var has_boss: bool = false

## Boss 数据（如果 has_boss == true）
@export var boss_id: String = ""

## 砖块下压速度倍率（相对于 BalanceData 基础值）
@export var push_speed_multiplier: float = 1.0

## 新行生成间隔倍率
@export var row_spawn_multiplier: float = 1.0

## 关卡完成奖励金币
@export var coin_reward: int = 5
