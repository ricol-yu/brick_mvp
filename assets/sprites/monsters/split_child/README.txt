怪物精灵素材规范
================
类型: split_child（分裂小子怪）
单帧尺寸: 96x48 像素（通过 AnimatedSprite2D scale=0.5 缩小至 48x24 显示）
碰撞体积: 48x24

注意: 此怪物为分裂砖击碎后产生的子砖，直接复用分裂砖的精灵图素材。
      通过 AnimatedSprite2D 的 scale = Vector2(0.5, 0.5) 实现半尺寸效果。
      无需单独提供 spritesheet 素材。

素材来源:
  复用 split/ 目录下的素材:
  - res://assets/sprites/monsters/split/idle.png
  - res://assets/sprites/monsters/split/hit.png
  - res://assets/sprites/monsters/split/death.png

动画参数（与分裂砖一致）:
  idle:  4帧, FPS=5,  循环
  hit:   3帧, FPS=12, 播完回idle
  death: 5帧, FPS=10, 播完queue_free
