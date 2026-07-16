## 挡板实体脚本
## 负责挡板的移动控制、Perfect Zone 检测
extends CharacterBody2D

## 挡板当前宽度（像素）
var paddle_width: float = BalanceData.PADDLE_BASE_WIDTH

## 挡板移动速度
var move_speed: float = BalanceData.PADDLE_BASE_MOVE_SPEED

## 挡板高度（像素）
var paddle_height: float = 16.0

## 子节点引用
@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	add_to_group("paddle")
	_update_collision_shape()
	EventBus.build_applied.connect(_on_build_applied)

func _physics_process(delta: float) -> void:
	if GameManager.current_state not in [GameManager.GameState.PREPARING, GameManager.GameState.PLAYING]:
		return
	
	# 处理输入
	var input_dir := 0.0
	if Input.is_action_pressed("move_left"):
		input_dir -= 1.0
	if Input.is_action_pressed("move_right"):
		input_dir += 1.0
	
	# 移动挡板
	velocity = Vector2(input_dir * move_speed, 0)
	move_and_slide()
	
	# 限制挡板在屏幕范围内
	var half_width := paddle_width * 0.5
	var wall_left := BalanceData.WALL_THICKNESS + half_width
	var wall_right := BalanceData.WORLD_WIDTH - BalanceData.WALL_THICKNESS - half_width
	global_position.x = clampf(global_position.x, wall_left, wall_right)
	
	# 准备阶段按空格发射球
	if GameManager.current_state == GameManager.GameState.PREPARING:
		if Input.is_action_just_pressed("launch_ball"):
			GameManager.launch_ball()

## 更新碰撞形状
func _update_collision_shape() -> void:
	if collision_shape and collision_shape.shape is RectangleShape2D:
		(collision_shape.shape as RectangleShape2D).size = Vector2(paddle_width, paddle_height)
	if sprite:
		sprite.scale = Vector2(paddle_width / BalanceData.PADDLE_BASE_WIDTH, 1.0)

## 应用挡板相关 Build 效果
func _on_build_applied(build_data: Resource) -> void:
	if build_data is BuildData and (build_data as BuildData).type == "Paddle":
		var eff: Dictionary = (build_data as BuildData).effect
		if eff.has("moveSpeedAdd"):
			move_speed += eff["moveSpeedAdd"]
		if eff.has("widthAdd"):
			paddle_width += eff["widthAdd"]
			_update_collision_shape()
