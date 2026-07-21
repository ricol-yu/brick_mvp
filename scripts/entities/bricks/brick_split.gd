## 分裂砖 — 击碎时分裂为 2 个半 HP 小砖块
extends BrickBase

## 分裂后小砖块的 HP
var child_hp: float = 0.0

## 精灵图资源
const IDLE_TEX := preload("res://assets/sprites/monsters/split/idle.png")
const HIT_TEX := preload("res://assets/sprites/monsters/split/hit.png")
const DEATH_TEX := preload("res://assets/sprites/monsters/split/death.png")

## 帧尺寸（根据实际 spritesheet 计算，1.5x 缩放后）
const IDLE_FRAME_W := 50
const IDLE_FRAME_COUNT := 4
const HIT_FRAME_W := 50
const HIT_FRAME_COUNT := 3
const DEATH_FRAME_W := 56
const DEATH_FRAME_COUNT := 5
const FRAME_H := 48

func _ready() -> void:
	hp = 3.0  # 测试用：至少 3 次 hit 才死亡
	child_hp = hp * 0.5
	super._ready()
	# 配置动画
	_setup_animations()

func get_brick_type() -> String:
	return "split"

## 配置动画 SpriteFrames
func _setup_animations() -> void:
	if not anim_sprite:
		return
	
	var sprite_frames := SpriteFrames.new()
	
	# idle 动画: 4帧, 33px宽, FPS=5, 循环
	sprite_frames.add_animation("idle")
	sprite_frames.set_animation_loop("idle", true)
	sprite_frames.set_animation_speed("idle", 5.0)
	for i in range(IDLE_FRAME_COUNT):
		var region := Rect2(i * IDLE_FRAME_W, 0, IDLE_FRAME_W, FRAME_H)
		var atlas := AtlasTexture.new()
		atlas.atlas = IDLE_TEX
		atlas.region = region
		sprite_frames.add_frame("idle", atlas)
	
	# hit 动画: 3帧, 33px宽, FPS=12, 不循环
	sprite_frames.add_animation("hit")
	sprite_frames.set_animation_loop("hit", false)
	sprite_frames.set_animation_speed("hit", 12.0)
	for i in range(HIT_FRAME_COUNT):
		var region := Rect2(i * HIT_FRAME_W, 0, HIT_FRAME_W, FRAME_H)
		var atlas := AtlasTexture.new()
		atlas.atlas = HIT_TEX
		atlas.region = region
		sprite_frames.add_frame("hit", atlas)
	
	# death 动画: 5帧, 37px宽, FPS=10, 不循环
	sprite_frames.add_animation("death")
	sprite_frames.set_animation_loop("death", false)
	sprite_frames.set_animation_speed("death", 10.0)
	for i in range(DEATH_FRAME_COUNT):
		var region := Rect2(i * DEATH_FRAME_W, 0, DEATH_FRAME_W, FRAME_H)
		var atlas := AtlasTexture.new()
		atlas.atlas = DEATH_TEX
		atlas.region = region
		sprite_frames.add_frame("death", atlas)
	
	anim_sprite.sprite_frames = sprite_frames
	anim_sprite.visible = true
	_anim_configured = true
	
	# 隐藏旧的 Sprite2D
	if sprite:
		sprite.visible = false
	
	# 播放待机动画
	_play_anim_state(AnimState.IDLE)

## 砖块被击碎 — 生成 2 个小砖块
func _on_destroyed() -> void:
	# 播放死亡动画，动画结束后 _on_anim_finished 会 queue_free
	if _anim_configured:
		_play_anim_state(AnimState.DEATH)
		if collision_shape:
			collision_shape.set_deferred("disabled", true)
	else:
		EventBus.brick_destroyed.emit(self, reward_exp)
		_spawn_child_bricks()
		queue_free()

## 死亡动画播放完成后生成子砖块
func _on_anim_finished() -> void:
	if current_anim_state == AnimState.HIT:
		_play_anim_state(AnimState.IDLE)
	elif current_anim_state == AnimState.DEATH:
		AudioManager.play_sfx("brick_destroy")
		EffectSpawner.spawn_brick_break(global_position, get_brick_type())
		EventBus.brick_destroyed.emit(self, reward_exp)
		_spawn_child_bricks()
		queue_free()

## 生成 2 个分裂小砖块
func _spawn_child_bricks() -> void:
	var child_scene_path := "res://scenes/entities/bricks/brick_split_child.tscn"
	if not ResourceLoader.exists(child_scene_path):
		return
	var child_scene := load(child_scene_path)
	if not child_scene:
		return
	
	var half_w := brick_width * 0.5
	# 左侧小砖块
	var left_child: Node2D = child_scene.instantiate()
	left_child.position = position + Vector2(-half_w * 0.5, 0)
	get_parent().add_child(left_child)
	# add_child 触发 _ready() 后会覆盖 hp，必须在之后设置
	left_child.hp = child_hp
	left_child.max_hp = child_hp
	
	# 右侧小砖块
	var right_child: Node2D = child_scene.instantiate()
	right_child.position = position + Vector2(half_w * 0.5, 0)
	get_parent().add_child(right_child)
	right_child.hp = child_hp
	right_child.max_hp = child_hp
