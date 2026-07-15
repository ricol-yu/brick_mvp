# 游戏内容全面重设计 — 分步里程碑计划

按"一个里程碑一件事"原则，将全部内容拆分为 15 个独立里程碑。每个里程碑完成后独立可测，不混合不同类型任务。

---

## M01：新增敌对砖块类型（6 种）

**目标**：新增 6 种以"给玩家制造压力"为核心设计的敌对砖块，含场景、脚本、美术。每种砖块对应一种压力维度，并与配套 Boss 形成联动。

**设计总览**：

| 砖块 | 压力类型 | 行为 | 配套 Boss |
|------|---------|------|----------|
| 分裂砖 | 清场压力 | 击碎时分裂为 2 个半 HP 小砖块，体积缩小一半 | 史莱姆 Boss（击杀后分裂为 2 个小 Boss） |
| 再生砖 | DPS 检测 | 每 3 秒回复 1 HP，必须集中火力 | 邪恶牧师 Boss（技能：给全场砖块回血） |
| 幽灵砖 | 时机把握 | 实体态（1.5s）可击中 → 灵体态（1.5s）球直接穿过 | 幽灵 Boss（自身也能瞬移闪避） |
| 护盾砖 | 输出检测 | 外层 2 HP 护盾，护盾存在时砖块无敌 | 骑士 Boss（自身也有护盾阶段） |
| 加速砖 | 时间压力 | 击碎时全场砖块下推加速 50%，持续 3 秒，可叠加 | 狂战士 Boss（狂暴状态全场加速） |
| 诅咒砖 | 操控颠覆 | 击碎时给挡板施加"操控反转"诅咒，左右方向相反，持续 5 秒 | 巫妖 Boss（周期性给挡板施加诅咒） |

**新增文件**：

分裂砖：
- `scenes/entities/bricks/brick_split.tscn`
- `scripts/entities/bricks/brick_split.gd` — 继承 BrickBase，覆盖 `_on_destroyed()`，生成 2 个半 HP 小砖块（宽度 32px），体积缩小一半避免挤压
- `scenes/entities/bricks/brick_split_child.tscn` — 小砖块场景（32x32，HP=1）
- `assets/sprites/bricks/brick_split.png` + `brick_split_child.png`

再生砖：
- `scenes/entities/bricks/brick_regen.tscn`
- `scripts/entities/bricks/brick_regen.gd` — 继承 BrickBase，`_process()` 中每 3 秒 `hp += 1`（不超过 max_hp），HP 回复时绿色闪烁
- `assets/sprites/bricks/brick_regen.png` — 绿色砖块，带脉冲视觉

幽灵砖：
- `scenes/entities/bricks/brick_ghost.tscn`
- `scripts/entities/bricks/brick_ghost.gd` — 继承 BrickBase，相位循环：实体态（1.5s，可碰撞）→ 灵体态（1.5s，collision_shape 禁用，球直接穿过），通过 `_process()` 切换 `is_phase_solid` 状态。`ball.gd` 碰撞砖块时检查此状态，灵体态则跳过碰撞
- `assets/sprites/bricks/brick_ghost.png` — 半透明砖块

护盾砖：
- `scenes/entities/bricks/brick_shield.tscn`
- `scripts/entities/bricks/brick_shield.gd` — 继承 BrickBase，利用基类已有的 `shield` 属性（2 HP），护盾存在时受击只扣护盾不扣砖块 HP，护盾碎裂时蓝色碎裂特效
- `assets/sprites/bricks/brick_shield.png` — 带蓝色护盾光环

加速砖：
- `scenes/entities/bricks/brick_haste.tscn`
- `scripts/entities/bricks/brick_haste.gd` — 继承 BrickBase，覆盖 `_on_destroyed()`，调用 `game_world.apply_push_speed_boost(1.5, 3.0)` 给全场砖块加速
- `assets/sprites/bricks/brick_haste.png` — 带速度线/闪电标记

诅咒砖：
- `scenes/entities/bricks/brick_curse.tscn`
- `scripts/entities/bricks/brick_curse.gd` — 继承 BrickBase，覆盖 `_on_destroyed()`，调用 `game_world.apply_paddle_curse(5.0)` 给挡板施加操控反转诅咒
- `assets/sprites/bricks/brick_curse.png` — 暗紫色砖块，带符文

**修改文件**：
- `scripts/main/game_world.gd` — `BRICK_SCENES` 字典新增 6 种映射：`"split"`, `"regen"`, `"ghost"`, `"shield"`, `"haste"`, `"curse"`；新增 `apply_push_speed_boost()` 和 `apply_paddle_curse()` 方法
- `scripts/entities/ball/ball.gd` — `_handle_collision()` 中碰撞砖块时检查幽灵砖灵体态（跳过碰撞）
- `scripts/entities/paddle/paddle.gd` — 新增诅咒状态：`is_cursed` 标记 + 计时器，诅咒期间 `move_direction` 取反

**完成标准**：
1. 分裂砖击碎后生成 2 个体积缩半的小砖块
2. 再生砖每 3 秒回复 1 HP
3. 幽灵砖灵体态时球直接穿过
4. 护盾砖护盾存在时砖块 HP 不变
5. 加速砖击碎后全场加速 3 秒
6. 诅咒砖击碎后挡板操控反转 5 秒

**工作量**：3.5 天

---

## M02：关卡配置重设计

**目标**：重新设计 7 关的 `.tres` 配置文件，规划完整难度曲线。

**修改文件**：
- `data/levels/level_01~07.tres` — 重写全部 7 关的 rows、push_speed_multiplier、row_spawn_multiplier
- `scripts/main/game_world.gd` — `LEVEL_PATHS` 数组新增 level_06、level_07 路径

**关卡设计**：

| 关卡 | 主题 | 行数 | 砖块搭配 | 下压倍率 | 间隔倍率 |
|------|------|------|---------|---------|---------|
| L1 | 新手教学 | 3 | 全普通 | 0.8 | 1.2 |
| L2 | 硬砖初体验 | 4 | 普通+少量硬砖 | 1.0 | 1.0 |
| L3 | 密集阵型 | 5 | 全普通(密集) | 1.2 | 0.8 |
| L4 | 混合节奏 | 5 | 普通+硬砖交替 | 1.3 | 0.7 |
| L5 | Boss-守卫者 | 4+Boss | 硬砖+荆棘砖+再生砖 | 1.0 | 0.9 |
| L6 | 极限挑战 | 6 | 硬砖+荆棘+闪避+引力 | 1.8 | 0.6 |
| L7 | Boss-终极毁灭者 | 5+Boss | 全类型混合+Boss | 1.5 | 0.7 |

**完成标准**：7 关可依次通关，难度递进合理，L5/L7 触发 Boss 战。

**工作量**：1 天

**依赖**：M01（使用新砖块类型）

---

## M03：关卡过渡动画

**目标**：关卡切换时显示"第 X 关 - 关卡名"大字淡入淡出效果。

**修改文件**：
- `scripts/main/game_world.gd` — `_spawn_new_row()` 中关卡切换时触发过渡动画
- `scenes/main/game_world.tscn` — 新增过渡 Label 节点

**完成标准**：关卡切换时有 1.5 秒过渡提示，不干扰游戏节奏。

**工作量**：0.5 天

**依赖**：M02

---

## M04：Build 配置重设计

**目标**：重新设计 20 个 Build 的 `.tres` 配置数据。

**修改文件**：
- `data/builds/ball_builds/b001~b010.tres` — 10 个球 Build
- `data/builds/paddle_builds/p001~p006.tres` — 6 个挡板 Build
- `data/builds/safety_builds/s001~s004.tres` — 4 个安全 Build
- `scripts/systems/build_pool.gd` — `BUILD_PATHS` 数组更新为新路径

**完成标准**：20 个 Build 数据文件正确加载，Build 池能按权重抽选。

**工作量**：1 天

**依赖**：无

---

## M05：新增 Build 效果代码

**目标**：为 M04 中新增的 Build 类型实现运行时效果逻辑。

**修改文件**：
- `scripts/entities/ball/ball.gd` — 冰冻 Build（击中减速）、闪电链 Build（弹射伤害）、磁铁 Build（角度修正）
- `scripts/entities/ball/ball_damage_calc.gd` — 新增 `ice_slow`、`chain_damage`、`magnet_strength` 属性 + `apply_build_effect()` 扩展
- `scripts/entities/paddle/paddle.gd` — 护盾墙 Build（底线保护次数）、时间减速 Build（反弹后全场减速）
- `scripts/main/game_world.gd` — 修复 Build（底线碰撞修复砖块）、弹射底线 Build、护盾 Build

**完成标准**：所有 20 个 Build 选中后效果正确生效。

**工作量**：2.5 天

**依赖**：M04

---

## M06：进化系统

**目标**：实现双 Build 满级合成进化机制，含 8 组进化配方。

**新增文件**：
- `scripts/systems/evolution_system.gd` — 进化条件检测、触发逻辑
- `data/evolutions/evolution_*.tres` — 8 个进化配方资源
- `data/builds/evolved/ev_*.tres` — 8 个进化 Build 数据
- `scenes/ui/evolution_popup.tscn` + `scripts/ui/evolution_popup.gd` — 进化动画 UI

**修改文件**：
- `scripts/systems/build_system.gd` — `apply_build()` 后调用进化检查
- `scripts/core/event_bus.gd` — 新增 `evolution_available`、`evolution_triggered` 信号
- `scripts/systems/build_pool.gd` — 加载进化 Build 路径
- `project.godot` — 注册 `evolution_system` 为 Autoload

**进化配方**：

| Build A (满) | Build B (满) | 进化结果 | 效果 |
|-------------|-------------|---------|------|
| 力量 | 极速 | 暴风之力 | 伤害=速度x0.5 |
| 巨球 | 穿透 | 毁灭巨球 | 体积x3+无限穿透 |
| 分裂 | 暴击 | 暴击分裂 | 子球触发暴击 |
| 火焰 | 闪电链 | 雷火风暴 | 燃烧触发闪电链 |
| Zone扩大 | 暴击反弹 | 完美暴击 | Perfect区50%,暴击x4 |
| 反弹复制 | 分裂 | 球海战术 | 每次反弹3子球 |
| 护盾墙 | 护盾 | 绝对防御 | 3次底线+1次完全抵挡 |
| 冰冻 | 减速场 | 绝对零度 | 底线碰撞冻结3秒 |

**完成标准**：两个 Build 满级后自动弹出进化提示，确认后合成进化 Build，原 Build 消失。

**工作量**：3 天

**依赖**：M05

---

## M07：Boss 行为重设计

**目标**：为 3 个 Boss 实现阶段切换和攻击行为。

**新增文件**：
- `scenes/entities/boss/boss_projectile.tscn` + `scripts/entities/boss/boss_projectile.gd` — Boss 弹幕实体

**修改文件**：
- `scripts/entities/boss/boss.gd` — 新增阶段切换逻辑、弹幕生成、砖块生成调用
- `data/bosses/boss_guardian.tres` — 更新 HP 120、攻击间隔 5 秒
- `data/bosses/boss_final.tres` — 更新 HP 250、攻击间隔 4 秒、三阶段
- `data/bosses/boss_ice_queen.tres` — 新增冰霜女王数据（HP 80、冰冻波）
- `scripts/main/game_world.gd` — Boss 弹幕生成接口、Boss 登场动画（Camera2D 震动）
- `assets/sprites/boss/boss_ice_queen.png` — 冰霜女王精灵
- `assets/sprites/boss/boss_projectile.png` — 弹幕精灵

**Boss 行为（与新砖块配套）**：
- 守卫者：阶段1 每5秒生成荆棘砖+再生砖混合列，阶段2(HP<50%) 加速+每3秒生成再生砖
- 终极毁灭者：阶段1 弹幕5颗，阶段2(HP<60%) 弹幕7颗+生成引力砖，阶段3(HP<30%) 弹幕9颗+击杀玩家砖块后召唤分裂砖
- 冰霜女王：每5秒冰冻波（减速球2秒），冻结期间闪避砖移动频率翻倍

**完成标准**：3 个 Boss 各有独特攻击模式，阶段切换正确触发，弹幕可被球击碎。

**工作量**：3.5 天

**依赖**：M02（关卡配置引用 Boss）

---

## M08：天赋树系统

**目标**：重写永久升级系统为 24 节点天赋树。

**修改文件**：
- `scripts/systems/meta_progression.gd` — 重写为 4 分支天赋树数据结构
- `scripts/core/save_manager.gd` — 存档结构兼容迁移（旧 5 项 → 新 24 节点）
- `scripts/ui/meta_shop.gd` — 重写为天赋树 UI（4 列纵向分支，节点连线）
- `scenes/ui/meta_shop.tscn` — 重写场景布局
- `scripts/systems/build_pool.gd` — 天赋节点解锁特殊 Build 联动
- `scripts/ui/hud_controller.gd` — 进化洞察提示图标

**天赋分支**：
- 攻击（6 节点）：球体强化 → 暴击精通 → 元素亲和 → 穿透大师 → 毁灭之力
- 防御（6 节点）：挡板扩展 → Perfect大师 → 底线守护 → 护盾充能 → 绝对壁垒
- 辅助（6 节点）：经验加速 → Build运气 → Tag大师 → 初始Build → 天赋异禀
- 特殊（6 节点）：金币猎手 → 多球出击 → Build解锁 → 进化洞察 → 命运之手

**完成标准**：天赋树 UI 可交互，节点可购买，效果正确应用到游戏中，旧存档可迁移。

**工作量**：4 天

**依赖**：M04（Build 池数据）

---

## M09：成就系统

**目标**：实现 40 个成就的定义、检测、解锁通知和列表展示。

**新增文件**：
- `scripts/systems/achievement_system.gd` — 成就定义 + 检测逻辑
- `scenes/ui/achievements.tscn` + `scripts/ui/achievements.gd` — 成就列表 UI

**修改文件**：
- `scripts/core/event_bus.gd` — 新增 `achievement_unlocked` 信号
- `scripts/core/save_manager.gd` — 存档新增 `achievements` 字段
- `scripts/ui/hud_controller.gd` — 成就解锁 Toast 通知
- `scripts/ui/main_menu.gd` — 新增"成就"按钮入口
- `project.godot` — 注册 `achievement_system` 为 Autoload

**完成标准**：40 个成就在对应条件达成时自动解锁并弹出通知，成就列表可查看已解锁/未解锁状态。

**工作量**：2.5 天

**依赖**：无（成就检测逻辑分散在各系统回调中，但系统本身可独立开发）

---

## M10：解锁体系

**目标**：实现渐进式内容解锁，控制玩家的内容可见顺序。

**新增文件**：
- `scripts/systems/unlock_system.gd` — 解锁条件检测 + 查询 API

**修改文件**：
- `scripts/core/save_manager.gd` — 存档新增 `unlocks` 字段
- `scripts/systems/build_pool.gd` — 查询解锁状态过滤 Build 池
- `scripts/ui/main_menu.gd` — 模式入口根据解锁状态启用/禁用

**解锁规则**：
- L4-L7 关卡：通关前置关卡
- 困难难度：通关普通模式
- 挑战/无尽模式：通关故事模式 L3/L5
- 稀有 Build：天赋树特定节点
- 词缀系统：通关 L2

**完成标准**：未解锁内容在 UI 中灰显/锁定，满足条件后自动解锁。

**工作量**：1.5 天

**依赖**：M09（成就解锁触发部分解锁）

---

## M11：关卡词缀/变异系统

**目标**：每局随机生成 2-3 个词缀修饰关卡规则，增加每局变化性。

**新增文件**：
- `scripts/systems/mutation_system.gd` — 词缀抽取和应用逻辑
- `data/mutations/mutation_*.tres` — 15 个词缀资源

**修改文件**：
- `scripts/main/game_world.gd` — `_ready()` 时调用词缀系统并应用效果
- `scripts/ui/hud_controller.gd` — 显示当前局词缀图标
- `scripts/core/event_bus.gd` — 新增 `mutations_applied` 信号
- `project.godot` — 注册 `mutation_system` 为 Autoload

**词缀池（15 个）**：加速、硬化、密集、迷雾、急速、分裂、脆弱、冰冻、弹幕、幸运、连击、贪婪、弹射、磁铁、混沌

**完成标准**：每局开始随机显示 2-3 个词缀，效果正确应用到游戏中。

**工作量**：2.5 天

**依赖**：M02（关卡系统）、M07（Boss 弹幕词缀）

---

## M12：多游戏模式

**目标**：新增挑战模式（20 关）、无尽模式、每日挑战。

**新增文件**：
- `scripts/systems/challenge_system.gd` — 挑战模式管理
- `data/challenges/challenge_*.tres` — 20 个挑战配置
- `scenes/ui/challenge_select.tscn` + `scripts/ui/challenge_select.gd` — 挑战列表 UI
- `scripts/systems/daily_challenge.gd` — 每日挑战种子生成

**修改文件**：
- `scripts/core/game_manager.gd` — 新增 `GameMode` 枚举（STORY/CHALLENGE/ENDLESS/DAILY）
- `scripts/main/game_world.gd` — 无尽模式逻辑（无限生成 + 递增难度）
- `scripts/ui/main_menu.gd` — 新增模式选择入口
- `scripts/core/scene_manager.gd` — 新增模式跳转方法

**完成标准**：4 种模式均可独立进入和游玩，各有独立的胜负判定和分数记录。

**工作量**：4 天

**依赖**：M11（词缀系统用于挑战和每日挑战）

---

## M13：多角色系统

**目标**：实现 3 个可选角色，各有独特被动能力。

**新增文件**：
- `scripts/data/character_data.gd` — 角色 Resource 定义
- `data/characters/char_*.tres` — 3 个角色数据
- `scenes/ui/character_select.tscn` + `scripts/ui/character_select.gd` — 角色选择 UI
- `assets/sprites/ui/char_*.png` — 3 个角色图标

**修改文件**：
- `scripts/main/game_world.gd` — 根据角色应用初始加成
- `scripts/entities/ball/ball_damage_calc.gd` — 角色被动属性
- `scripts/ui/main_menu.gd` — 开始游戏前进入角色选择
- `scripts/systems/unlock_system.gd` — 角色解锁条件

**角色设计**：
- 弹球新手：基础角色，无特殊能力（默认）
- 火焰法师：初始自带满级火焰，球速度-10%
- 钢铁守卫：挡板+30%，底线+2次，球伤害-20%

**完成标准**：角色选择后效果正确应用，未解锁角色灰显。

**工作量**：2.5 天

**依赖**：M10（解锁体系）

---

## M14：UI 与特效美术

**目标**：统一 UI 视觉风格，补充游戏内粒子特效。

**UI 样式**：
- 按钮 StyleBoxFlat 统一（圆角、悬停、按下）
- 面板背景（半透明深色+边框）
- Build 卡片图标（20 个，32x32 像素风）
- 天赋树图标（24 个）
- 主菜单动态背景

**粒子特效**：
- 砖块碎裂（GPUParticles2D）
- 暴击数字飘字（Label 动画）
- 球拖尾（GPUParticles2D）
- Boss 登场（屏幕震动+名称淡入）
- Build 获取动画（卡片飞入）
- 进化动画（合并+闪光）

**新增文件**：
- `assets/sprites/ui/build_icons/*.png` — 20 个 Build 图标
- `assets/sprites/ui/talent_icons/*.png` — 24 个天赋图标
- `scenes/effects/brick_break_particles.tscn`
- `scenes/effects/ball_trail_particles.tscn`

**修改文件**：
- `assets/default_theme.tres` — 统一按钮/面板样式
- `scripts/ui/build_select_ui.gd` — Build 卡片图标显示
- `scripts/entities/bricks/brick_base.gd` — 碎裂时生成粒子
- `scripts/ui/hud_controller.gd` — 暴击数字飘字

**完成标准**：UI 风格统一，粒子特效正常播放，不影响性能。

**工作量**：5 天

**依赖**：M06（进化 UI）、M08（天赋树 UI）完成后统一打磨

---

## M15：音频补充

**目标**：补充 BGM 和 SFX，完善音频体验。

**新增文件**：
- `assets/audio/bgm/menu_bgm.mp3` — 菜单 BGM
- `assets/audio/bgm/boss_bgm.mp3` — Boss 战 BGM
- `assets/audio/sfx/ball_bounce.wav` — 球碰墙
- `assets/audio/sfx/boss_appear.wav` — Boss 出现
- `assets/audio/sfx/purchase.wav` — 购买升级
- `assets/audio/sfx/evolution.wav` — 进化触发
- `assets/audio/sfx/victory.wav` — 通关
- `assets/audio/sfx/ball_split.wav` — 球分裂
- `assets/audio/sfx/brick_ice.wav` — 冰冻砖碎裂
- `assets/audio/sfx/brick_explosive.wav` — 爆炸砖引爆

**修改文件**：
- `scripts/core/audio_manager.gd` — 新增 preload 常量 + 缓存注册
- `scripts/main/game_world.gd` — Boss 登场时切换 BGM
- `scripts/ui/main_menu.gd` — 菜单 BGM 播放

**完成标准**：所有场景有对应 BGM/SFX，音量平衡，无缺失音效。

**工作量**：2 天

**依赖**：M07（Boss BGM）、M06（进化 SFX）

---

## 里程碑依赖图与执行顺序

```
M01 砖块类型 ──→ M02 关卡配置 ──→ M03 过渡动画
                     │
                     └──→ M07 Boss 行为 ──→ M11 词缀系统 ──→ M12 多模式
                                                                    │
M04 Build 配置 ──→ M05 Build 效果 ──→ M06 进化系统 ──→ M08 天赋树 ──→ M10 解锁体系 ──→ M13 多角色
                     │                    │
                     │                    └──→ M14 UI/特效（需 M06+M08 完成）
                     │
                     └──────────────────────→ M15 音频（需 M06+M07 完成）

M09 成就系统（可独立开发，与各里程碑并行）
```

**推荐执行顺序**：

| 阶段 | 并行组 | 里程碑 | 累计天数 |
|------|--------|--------|---------|
| 1 | A | M01 砖块类型 | 1.5 |
| 1 | B | M04 Build 配置 | 1 |
| 1 | C | M09 成就系统 | 2.5 |
| 2 | A | M02 关卡配置 | 1 |
| 2 | B | M05 Build 效果 | 2.5 |
| 3 | A | M03 过渡动画 | 0.5 |
| 3 | B | M07 Boss 行为 | 3.5 |
| 3 | C | M06 进化系统 | 3 |
| 4 | A | M08 天赋树 | 4 |
| 4 | B | M11 词缀系统 | 2.5 |
| 5 | A | M10 解锁体系 | 1.5 |
| 5 | B | M15 音频 | 2 |
| 6 | A | M12 多模式 | 4 |
| 6 | B | M14 UI/特效 | 5 |
| 7 | | M13 多角色 | 2.5 |

**总工作量：35-40 天**
