怪物精灵素材规范
================
类型: hard（硬砖怪）
单帧尺寸: 96x48 像素
碰撞体积: 96x48

文件清单:
  idle.png   - 待机动画 spritesheet (2帧, 总尺寸 194x48)
  hit.png    - 受击动画 spritesheet (3帧, 总尺寸 292x48)
  death.png  - 死亡动画 spritesheet (5帧, 总尺寸 488x48)

Spritesheet 规范:
  - 格式: PNG, 32-bit RGBA, 透明背景
  - 排列: 帧水平排列, 帧间距 2px（相邻帧之间留2像素空白，防止边缘粘连）
  - 同张内帧尺寸严格一致
  - 无抗锯齿, 无 ICC 色彩配置

动画参数:
  idle:  2帧, FPS=3,  循环
  hit:   3帧, FPS=14, 播完回idle
  death: 5帧, FPS=8,  播完queue_free

动画描述:
  idle:  灰褐色石块堆叠的矮壮傀儡，身体有裂缝，眼睛是发光的橙色矿晶。身体石块微微错位摩擦，裂缝中透出橙色微光
  hit:   裂缝扩大，橙色光芒增强，石块震颤
  death: 石块逐层崩裂，从顶部开始碎裂散落
