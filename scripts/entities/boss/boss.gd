## Boss 实体脚本
## 负责 Boss 的移动、受伤、击败逻辑
extends CharacterBody2D

## Boss 数据
var boss_data: BossData = null

## 当前 HP
var hp: float = 0.0

## 移动方向（水平往返用）
var move_direction: float = 1.0

## 圆形运动角度
var circular_angle: float = 0.0

## 圆形运动中心
var circular_center: Vector2 = Vector2.ZERO

## 受击闪烁
var flash_timer: float = 0.0
const FLASH_DURATION := 0.1

## HP 条引用
var hp_bar: ProgressBar = null

func _ready() -> void:
	add_to_group("boss")
	if boss_data:
		_init_from_data()
	_create_visual()

func _init_from_data() -> void:
	hp = boss_data.max_hp
	
	# 创建 HP 条背景（深色边框）
	var hp_bg := ColorRect.new()
	hp_bg.name = "HPBarBG"
	hp_bg.color = Color(0.1, 0.1, 0.1, 0.9)
	hp_bg.size = Vector2(boss_data.body_size.x + 4, 14)
	hp_bg.position = Vector2(-boss_data.body_size.x * 0.5 - 2, -boss_data.body_size.y * 0.5 - 22)
	add_child(hp_bg)
	
	# 创建 HP 条
	hp_bar = ProgressBar.new()
	hp_bar.name = "HPBar"
	hp_bar.custom_minimum_size = Vector2(boss_data.body_size.x, 10)
	hp_bar.max_value = boss_data.max_hp
	hp_bar.value = hp
	hp_bar.position = Vector2(-boss_data.body_size.x * 0.5, -boss_data.body_size.y * 0.5 - 20)
	hp_bar.show_percentage = false
	
	# 设置 HP 条样式（红色填充）
	var fill_style := StyleBoxFlat.new()
	fill_style.bg_color = Color(0.9, 0.2, 0.2, 1.0)
	fill_style.set_corner_radius_all(2)
	hp_bar.add_theme_stylebox_override("fill", fill_style)
	
	# 设置背景样式（深灰色）
	var bg_style := StyleBoxFlat.new()
	bg_style.bg_color = Color(0.3, 0.3, 0.3, 0.8)
	bg_style.set_corner_radius_all(2)
	hp_bar.add_theme_stylebox_override("background", bg_style)
	
	add_child(hp_bar)
	
	# 名称标签
	var name_label := Label.new()
	name_label.text = boss_data.boss_name
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.position = Vector2(-boss_data.body_size.x * 0.5, -boss_data.body_size.y * 0.5 - 42)
	name_label.size = Vector2(boss_data.body_size.x, 16)
	name_label.add_theme_color_override("font_color", Color(1, 0.9, 0.3))
	name_label.add_theme_font_size_override("font_size", 14)
	add_child(name_label)
	
	# HP 数值标签
	var hp_label := Label.new()
	hp_label.name = "HPLabel"
	hp_label.text = "%d/%d" % [int(hp), int(boss_data.max_hp)]
	hp_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hp_label.position = Vector2(-boss_data.body_size.x * 0.5, -boss_data.body_size.y * 0.5 - 6)
	hp_label.size = Vector2(boss_data.body_size.x, 14)
	hp_label.add_theme_color_override("font_color", Color.WHITE)
	hp_label.add_theme_font_size_override("font_size", 12)
	add_child(hp_label)
	
	# 圆形运动中心
	circular_center = global_position

func _create_visual() -> void:
	# 创建 Sprite2D（如果不存在）
	if not has_node("Sprite2D"):
		var sprite := Sprite2D.new()
		sprite.name = "Sprite2D"
		if boss_data:
			sprite.modulate = boss_data.body_color
		else:
			sprite.modulate = Color(0.8, 0.2, 0.2)
		add_child(sprite)
	
	# 创建占位符纹理
	var sprite_node := get_node_or_null("Sprite2D") as Sprite2D
	if sprite_node and sprite_node.texture == null:
		var body_size := boss_data.body_size if boss_data else Vector2(128, 64)
		var img := Image.create(int(body_size.x), int(body_size.y), false, Image.FORMAT_RGBA8)
		img.fill(Color.WHITE)
		sprite_node.texture = ImageTexture.create_from_image(img)
	
	# 创建碰撞体（如果不存在）
	if not has_node("CollisionShape2D"):
		var col := CollisionShape2D.new()
		col.name = "CollisionShape2D"
		var shape := RectangleShape2D.new()
		if boss_data:
			shape.size = boss_data.body_size
		else:
			shape.size = Vector2(128, 64)
		col.shape = shape
		add_child(col)
	
	# 设置碰撞层
	collision_layer = 16  # layer 5 (boss)
	collision_mask = 0    # 不主动检测任何碰撞

func _physics_process(delta: float) -> void:
	if GameManager.current_state != GameManager.GameState.PLAYING:
		return
	if not boss_data:
		return
	
	# 闪烁更新
	if flash_timer > 0:
		flash_timer -= delta
		if flash_timer <= 0:
			_stop_flash()
	
	# 移动模式
	match boss_data.move_pattern:
		"horizontal":
			_move_horizontal(delta)
		"circular":
			_move_circular(delta)

## 水平往返移动（直接设置位置，避免被球撞后位移）
func _move_horizontal(_delta: float) -> void:
	global_position.x += boss_data.move_speed * move_direction * _delta
	
	# 边界反弹
	var half_w := boss_data.body_size.x * 0.5
	if global_position.x - half_w <= BalanceData.WALL_THICKNESS:
		move_direction = 1.0
	elif global_position.x + half_w >= BalanceData.WORLD_WIDTH - BalanceData.WALL_THICKNESS:
		move_direction = -1.0

## 圆形移动（直接设置位置，避免被球撞后位移）
func _move_circular(delta: float) -> void:
	circular_angle += boss_data.move_speed * 0.01 * delta
	var radius := 100.0
	global_position = circular_center + Vector2(
		cos(circular_angle) * radius,
		sin(circular_angle) * radius * 0.5
	)

## 受到伤害
func take_damage(damage: float) -> void:
	hp = maxf(0.0, hp - damage)
	_start_flash()
	
	EventBus.boss_damaged.emit(self, damage)
	
	if hp_bar:
		hp_bar.value = hp
	
	# 更新 HP 数值显示
	var hp_label := get_node_or_null("HPLabel") as Label
	if hp_label and boss_data:
		hp_label.text = "%d/%d" % [int(hp), int(boss_data.max_hp)]
	
	if hp <= 0:
		_on_defeated()

## Boss 被击败
func _on_defeated() -> void:
	EventBus.boss_defeated.emit(self)
	# 掉落经验
	ExpSystem.add_exp(boss_data.exp_reward)
	# 掉落金币
	SaveManager.add_coins(boss_data.coin_reward)
	queue_free()

## 开始闪烁
func _start_flash() -> void:
	flash_timer = FLASH_DURATION
	var sprite := get_node_or_null("Sprite2D") as Sprite2D
	if sprite:
		sprite.modulate = Color(3.0, 3.0, 3.0, 1.0)

## 停止闪烁
func _stop_flash() -> void:
	var sprite := get_node_or_null("Sprite2D") as Sprite2D
	if sprite and boss_data:
		sprite.modulate = boss_data.body_color
