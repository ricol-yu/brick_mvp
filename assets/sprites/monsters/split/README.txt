怪物精灵素材规范
================
类型: split（分裂怪）
单帧尺寸: 96x48 像素（idle/hit 实际绘制宽约 50px，death 约 56px，居中于 96px 帧内）
碰撞体积: 96x48

文件清单:
  idle.png   - 待机动画 spritesheet (4帧, 总尺寸 206x48)
  hit.png    - 受击动画 spritesheet (3帧, 总尺寸 156x48)
  death.png  - 死亡动画 spritesheet (5帧, 总尺寸 288x48)

Spritesheet 规范:
  - 格式: PNG, 32-bit RGBA, 透明背景
  - 排列: 帧水平排列, 帧间距 2px（相邻帧之间留2像素空白，防止边缘粘连）
  - 同张内帧尺寸严格一致（每帧占 96x48，角色居中绘制）
  - 无抗锯齿, 无 ICC 色彩配置

动画参数:
  idle:  4帧, FPS=5,  循环
  hit:   3帧, FPS=12, 播完回idle
  death: 5帧, FPS=10, 播完queue_free

动画描述:
  idle:  细胞状脉动，中心微微膨胀收缩
  hit:   收缩震颤
  death: 从中间裂开，两半向左右分离（暗示即将一分为二）
