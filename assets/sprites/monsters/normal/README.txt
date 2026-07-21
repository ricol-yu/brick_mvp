怪物精灵素材规范
================
类型: normal（普通怪）
单帧尺寸: 96x48 像素
碰撞体积: 96x48

文件清单:
  idle.png   - 待机动画 spritesheet (2帧, 总尺寸 194x48)
  hit.png    - 受击动画 spritesheet (2帧, 总尺寸 194x48)
  death.png  - 死亡动画 spritesheet (4帧, 总尺寸 390x48)

Spritesheet 规范:
  - 格式: PNG, 32-bit RGBA, 透明背景
  - 排列: 帧水平排列, 帧间距 2px（相邻帧之间留2像素空白，防止边缘粘连）
  - 同张内帧尺寸严格一致
  - 无抗锯齿, 无 ICC 色彩配置

动画参数:
  idle:  2帧, FPS=4,  循环
  hit:   2帧, FPS=12, 播完回idle
  death: 4帧, FPS=10, 播完queue_free

动画描述:
  idle:  橙红色圆胖小步兵，戴简易铁皮头盔，手持小圆盾。身体轻微上下起伏，头盔微微晃动
  hit:   头盔歪斜，身体后仰，盾牌微偏
  death: 头盔飞出，身体碎裂成小块散落
