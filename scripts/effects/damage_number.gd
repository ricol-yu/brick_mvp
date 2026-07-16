## 伤害飘字效果
## 在碰撞点显示伤害数字，向上浮动并淡出
extends Node2D

@onready var label: Label = $Label

func _ready() -> void:
	# 初始位置稍微偏移
	label.position = Vector2(0, 0)
	label.modulate = Color(1, 1, 1, 1)
	
	# Tween 动画：上浮 + 淡出
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(label, "position:y", -30.0, 0.8).set_ease(Tween.EASE_OUT)
	tween.tween_property(label, "modulate:a", 0.0, 0.8).set_delay(0.2).set_ease(Tween.EASE_IN)
	tween.set_parallel(false)
	tween.tween_callback(queue_free)
