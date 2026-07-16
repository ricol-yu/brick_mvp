## 碰撞闪光效果
## 在碰撞点显示一个快速缩放+淡出的闪光
extends Node2D

@onready var sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	# 初始缩放很小
	sprite.scale = Vector2(0.3, 0.3)
	sprite.modulate = Color(1, 1, 1, 1)
	
	# Tween 动画：缩放 + 淡出
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(sprite, "scale", Vector2(1.5, 1.5), 0.15).set_ease(Tween.EASE_OUT)
	tween.tween_property(sprite, "modulate:a", 0.0, 0.15).set_ease(Tween.EASE_IN)
	tween.set_parallel(false)
	tween.tween_callback(queue_free)
