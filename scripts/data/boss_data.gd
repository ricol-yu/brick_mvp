## Boss 数据结构定义（Godot Resource）
## 每个 Boss 存储为 .tres 文件
class_name BossData
extends Resource

## Boss ID
@export var id: String = ""

## 显示名称
@export var boss_name: String = ""

## 最大 HP
@export var max_hp: float = 100.0

## 移动速度（像素/秒）
@export var move_speed: float = 60.0

## 移动模式：horizontal（水平往返）、circular（圆形）
@export_enum("horizontal", "circular") var move_pattern: String = "horizontal"

## 碰撞体大小（宽×高）
@export var body_size: Vector2 = Vector2(128, 64)

## 击败后掉落金币
@export var coin_reward: int = 20

## 击败后掉落经验
@export var exp_reward: int = 10

## 特殊攻击间隔（秒，0 = 无特殊攻击）
@export var attack_interval: float = 0.0

## 颜色（占位符用）
@export var body_color: Color = Color(0.8, 0.2, 0.2)
