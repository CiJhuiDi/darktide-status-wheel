# 状态轮盘 (Status Wheel) v2.0.0

在 **通信轮盘（V 键）** 中添加增强选项与状态条目：

- **原生增强 10 项**（整合自 For The Emperor，该 mod 已停更）：要弹药 / 注意 / 帝皇 / 敌人 / 治疗 / 帮助 / 位置 / 是 / 否 / 谢谢，均带角色语音 + 聊天 + 场景标记动作
- **状态 3 项**：大招状态（充能层数 / 冷却进度，可配置格式）、手雷数量、子弹余量（弹夹 + 备弹）

## 特性

| 功能 | 说明 |
|---|---|
| 右键拖拽重排 | 打开轮盘后按住右键拖条目换位置，布局自动保存 |
| 独立快捷键 | Mod Options → 快捷键，给每个选项绑键，不开轮盘直接触发 |
| 帮助联动 | 选「帮助」→ 求救语音 + 聊天通知；队友装本 mod 会收到 → 帮你播语音 + 头顶 10 秒求助标记 |
| 防刷屏冷却 | 同类型消息冷却期（默认 15s，可调） |
| 输出目标 | 仅本地 / 队伍频道（默认，队友可见） |
| 仅战斗显示 | 大厅自动隐藏，训练场/射击场/任务中可用 |
| dibs 禁用 | 重复标记时不喊"我的"（默认开，可关） |

## 安装

1. 将 `status_wheel` 文件夹整个复制到游戏 mods 目录：
   `Steam\steamapps\common\Warhammer 40,000 DARKTIDE\mods\`
2. 打开游戏根目录 `mod_load_order.txt`，把 `status_wheel` 加进去（一字不差，每行一个 mod 名）
3. 启动游戏 → ESC → **Mod Options → 状态轮盘** 查看/调整配置

> ⚠️ 如果还装着旧版 **For The Emperor**：本 mod v2.0 已整合其全部功能，请卸载旧版避免冲突（游戏内会有警告提示）。

## 使用

- 游戏中按 **V** 打开通信轮盘，悬停到条目松开即触发（默认 13 槽：原生增强 10 + 状态 3）
- 轮盘打开时**右键按住拖拽**可重排槽位
- 在 Mod Options 里给选项绑定快捷键，战斗中直接按键触发（大厅无效）

## 配置项

| 设置 | 说明 |
|---|---|
| 启用：大招状态 / 手雷数量 / 子弹余量 | 控制哪些状态条目出现在轮盘上 |
| 输出目标 | 仅本地 / 队伍频道（经 Vivox 发送，队友可见） |
| 发送冷却（秒） | 同类型消息最短发送间隔，0 = 不限 |
| 大招显示格式 | 自动 / 充能层数 / 冷却百分比 / 冷却秒数 |
| 显示备弹 | 子弹余量是否附带备弹池 |
| 轮盘行为 | 重复标记不喊"我的"（disable_dibs）、忽略求助（ignore_help） |
| 快捷键 | 13 个选项各自绑定按键 |

## 说明与已知限制

- 依赖 DMF（Darktide Mod Framework）与 Darktide Mod Loader，需先行安装
- 整合版对原 FTE 的脆弱内部 API 做了防御式适配：失效功能自动降级，不崩溃
- 求助联动的队友响应需要队友也装本 mod（聊天 `#need_help` 协议标记）
- 建议在 DMF 设置中开启 **Developer Mode**，便于热重载（Ctrl+Shift+R）调试

## 文件结构

```
status_wheel/
├── status_wheel.mod                        # 入口清单
└── scripts/mods/status_wheel/
    ├── status_wheel.lua                    # 主逻辑（布局/拖拽/hook/调度）
    ├── status_wheel_data.lua               # 设置项定义
    ├── status_wheel_localization.lua       # 中英本地化
    └── modules/
        ├── wheel_options.lua               # 选项定义（原生 10 + 状态 3）
        ├── wheel_actions.lua               # 动作执行（标记/聊天/语音/状态）
        └── need_help.lua                   # 求助联动（语音/世界标记/响应）
```

## 参考

- For The Emperor (NexusMods mod 135, GitHub MalkyLuke/ForTheEmperorRepo, 已停更)——功能整合来源，源码归档于 `D:\DeepseekWorkspace\暗潮\99-临时文件\fte_ref\`
