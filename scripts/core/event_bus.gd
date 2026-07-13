## 全局信号总线（Autoload）
## 所有系统间的通信都通过 EventBus，避免直接引用，降低耦合
extends Node

# ===================== 球相关信号 =====================
## 球被发射
signal ball_launched
## 球碰撞反弹（碰撞体类型, 碰撞位置）
signal ball_bounced(collider_type: String, position: Vector2)
## 球掉落到底线
signal ball_hit_bottom
## 球被消灭（所有球都没了）
signal all_balls_lost

# ===================== 砖块相关信号 =====================
## 砖块被击中（砖块节点, 伤害值）
signal brick_hit(brick: Node, damage: float)
## 砖块被击碎（砖块节点, 掉落经验值）
signal brick_destroyed(brick: Node, exp_reward: int)
## Bonus Brick 被击碎
signal bonus_brick_destroyed(build_data: Resource)

# ===================== 经验与升级信号 =====================
## 获得经验值（经验值增量）
signal exp_gained(amount: int)
## 玩家升级（新等级）
signal level_up(new_level: int)

# ===================== Build 系统信号 =====================
## 请求显示 Build 选择界面（3个可选Build数据）
signal show_build_selection(builds: Array)
## 玩家选择了 Build（选中的Build数据）
signal build_selected(build_data: Resource)
## Build 效果已应用
signal build_applied(build_data: Resource)

# ===================== Boss 相关信号 =====================
## Boss 出现
signal boss_spawned(boss: Node)
## Boss 被击败
signal boss_defeated(boss: Node)
## Boss 受到伤害
signal boss_damaged(boss: Node, damage: float)

# ===================== 游戏流程信号 =====================
## 关卡变化（关卡索引, 关卡名称）
signal stage_changed(stage_index: int, stage_name: String)
## 游戏开始
signal game_started
## 游戏结束（是否通关, 统计数据）
signal game_over(cleared: bool, stats: Dictionary)
## 游戏暂停/恢复
signal game_paused(is_paused: bool)
## 单局结算完成（金币奖励）
signal run_settled(coins_earned: int)

# ===================== 永久升级信号 =====================
## 购买了永久升级（升级ID）
signal meta_upgrade_purchased(upgrade_id: String)
## 金币数量变化
signal coins_changed(new_amount: int)
## 初始球数量加成（额外球数）
signal meta_start_balls_changed(extra_balls: int)

# ===================== UI 信号 =====================
## 请求显示伤害数字（位置, 伤害值, 是否暴击）
signal show_damage_number(position: Vector2, damage: float, is_crit: bool)
