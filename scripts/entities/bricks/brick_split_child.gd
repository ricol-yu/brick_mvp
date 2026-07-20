## 分裂砖的小砖块（半尺寸，HP=1）
extends BrickBase

## 复用分裂砖的精灵图资源
const IDLE_TEX := preload("res://assets/sprites/monsters/split/idle.png")
const HIT_TEX := preload("res://assets/sprites/monsters/split/hit.png")
const DEATH_TEX := preload("res://assets/sprites/monsters/split/death.png")

## 帧尺寸（与分裂砖一致，通过 scale=0.5 缩小）
const IDLE_FRAME_W := 33
const IDLE_FRAME_COUNT := 4
const HIT_FRAME_W := 33
const HIT_FRAME_COUNT := 3
const DEATH_FRAME_W := 37
const DEATH_FRAME_COUNT := 5
const FRAME_H := 32

func _ready() -> void:
	brick_width = 32.0
	brick_height = 32.0
	hp = 1.0
	max_hp = 1.0
	super._ready()
	# 调整碰撞形状为半尺寸
	if collision_shape and collision_shape.shape is RectangleShape2D:
		(collision_shape.shape as RectangleShape2D).size = Vector2(32, 32)
	# 配置动画（复用分裂砖素材，scale 0.5 已设置在 tscn 中）
	_setup_animations()

func get_brick_type() -> String:
	return "split_child"

## 配置动画 SpriteFrames（复用分裂砖素材）
func _setup_animations() -> void:
	if not anim_sprite:
		return
	
	var sprite_frames := SpriteFrames.new()
	
	# idle 动画
	sprite_frames.add_animation("idle")
	sprite_frames.set_animation_loop("idle", true)
	sprite_frames.set_animation_speed("idle", 5.0)
	for i in range(IDLE_FRAME_COUNT):
		var region := Rect2(i * IDLE_FRAME_W, 0, IDLE_FRAME_W, FRAME_H)
		var atlas := AtlasTexture.new()
		atlas.atlas = IDLE_TEX
		atlas.region = region
		sprite_frames.add_frame("idle", atlas)
	
	# hit 动画
	sprite_frames.add_animation("hit")
	sprite_frames.set_animation_loop("hit", false)
	sprite_frames.set_animation_speed("hit", 12.0)
	for i in range(HIT_FRAME_COUNT):
		var region := Rect2(i * HIT_FRAME_W, 0, HIT_FRAME_W, FRAME_H)
		var atlas := AtlasTexture.new()
		atlas.atlas = HIT_TEX
		atlas.region = region
		sprite_frames.add_frame("hit", atlas)
	
	# death 动画
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
