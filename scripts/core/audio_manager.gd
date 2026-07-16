## 音频管理器（Autoload 单例）
## 管理 BGM 和 SFX 的播放，音量从 SaveManager 读取
## 使用 preload() 确保导出时资源被正确打包
extends Node

## 预加载所有音频资源（确保导出系统能追踪）
## BGM
const BGM_GAME: AudioStream = preload("res://assets/audio/bgm/game_bgm.mp3")
## SFX
const SFX_BRICK_DESTROY: AudioStream = preload("res://assets/audio/sfx/brick_destroy.wav")
const SFX_BUTTON_CLICK: AudioStream = preload("res://assets/audio/sfx/button_click.wav")
const SFX_LEVEL_UP: AudioStream = preload("res://assets/audio/sfx/level_up.wav")

## 音频缓存 { "name": AudioStream }
var _bgm_cache: Dictionary = {}
var _sfx_cache: Dictionary = {}

## BGM 播放器
var _bgm_player: AudioStreamPlayer = null

## SFX 播放器池
var _sfx_pool: Array[AudioStreamPlayer] = []
const SFX_POOL_SIZE := 8

## 当前 BGM 名称（避免重复播放）
var _current_bgm: String = ""

func _ready() -> void:
	# 创建 BGM 播放器（设置 ALWAYS 模式，游戏暂停时继续播放）
	_bgm_player = AudioStreamPlayer.new()
	_bgm_player.name = "BGMPlayer"
	_bgm_player.bus = "Master"
	_bgm_player.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(_bgm_player)
	
	# 创建 SFX 播放器池（设置 ALWAYS 模式，游戏暂停时继续播放）
	for i in range(SFX_POOL_SIZE):
		var player := AudioStreamPlayer.new()
		player.name = "SFXPlayer_%d" % i
		player.bus = "Master"
		player.process_mode = Node.PROCESS_MODE_ALWAYS
		add_child(player)
		_sfx_pool.append(player)
	
	# 初始化音频缓存
	_init_audio_cache()

## ===================== BGM API =====================

## 播放 BGM（传入文件名，不含扩展名）
func play_bgm(bgm_name: String) -> void:
	if _current_bgm == bgm_name and _bgm_player.playing:
		return  # 已在播放同一首
	
	var stream: AudioStream = _bgm_cache.get(bgm_name)
	if stream == null:
		if show_missing_audio_warnings:
			push_warning("BGM 未找到: " + bgm_name)
		return
	
	_bgm_player.stream = stream
	_bgm_player.volume_db = _get_bgm_volume_db()
	_bgm_player.play()
	_current_bgm = bgm_name

## 停止 BGM
func stop_bgm() -> void:
	_bgm_player.stop()
	_current_bgm = ""

## 播放菜单 BGM
func play_menu_bgm() -> void:
	play_bgm("menu_bgm")

## 播放游戏 BGM
func play_game_bgm() -> void:
	play_bgm("game_bgm")

## 播放 Boss 战 BGM
func play_boss_bgm() -> void:
	play_bgm("boss_bgm")

## ===================== SFX API =====================

## 是否显示音频未找到警告（调试时可关闭）
var show_missing_audio_warnings: bool = true

## 播放 SFX（传入文件名，不含扩展名）
func play_sfx(sfx_name: String, volume_offset_db: float = 0.0) -> void:
	var stream: AudioStream = _sfx_cache.get(sfx_name)
	if stream == null:
		if show_missing_audio_warnings:
			push_warning("SFX 未找到: " + sfx_name)
		return
	
	# 从池中找一个空闲播放器
	for player in _sfx_pool:
		if not player.playing:
			player.stream = stream
			player.volume_db = _get_sfx_volume_db() + volume_offset_db
			player.play()
			return
	
	# 所有播放器都在用，复用第一个
	_sfx_pool[0].stream = stream
	_sfx_pool[0].volume_db = _get_sfx_volume_db() + volume_offset_db
	_sfx_pool[0].play()

## ===================== 音量控制 =====================

## 获取 BGM 音量（dB）
func _get_bgm_volume_db() -> float:
	var volume: float = SaveManager.get_setting("bgm_volume", 0.8)
	if volume <= 0.0:
		return -80.0  # 静音
	return linear_to_db(volume)

## 获取 SFX 音量（dB）
func _get_sfx_volume_db() -> float:
	var volume: float = SaveManager.get_setting("sfx_volume", 0.8)
	if volume <= 0.0:
		return -80.0  # 静音
	return linear_to_db(volume)

## 刷新音量（设置变更后调用）
func refresh_volume() -> void:
	_bgm_player.volume_db = _get_bgm_volume_db()

## ===================== 内部方法 =====================

## 初始化音频缓存
func _init_audio_cache() -> void:
	_bgm_cache["game_bgm"] = BGM_GAME
	_sfx_cache["brick_destroy"] = SFX_BRICK_DESTROY
	_sfx_cache["button_click"] = SFX_BUTTON_CLICK
	_sfx_cache["level_up"] = SFX_LEVEL_UP

## 获取已加载的 BGM 列表（调试用）
func get_loaded_bgm() -> Array[String]:
	var names: Array[String] = []
	for key in _bgm_cache:
		names.append(key)
	return names

## 获取已加载的 SFX 列表（调试用）
func get_loaded_sfx() -> Array[String]:
	var names: Array[String] = []
	for key in _sfx_cache:
		names.append(key)
	return names
