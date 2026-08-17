# status_wheel · 项目交接摘要

> **给新会话的快速上手文档**：读完这个 + 通用规范（`暗潮\01-开发规范\Darktide-Mod开发规范.md`）即可接手。
> 最后更新：2026-08-18 01:05 | 当前版本：v2.0.0（已推未实测）

---

## 一、项目是什么

《战锤40K：暗潮》的增强通信轮盘 mod（DMF Lua mod，V 键）。v2.0.0 整合了**已停更的 For The Emperor**（NexusMods 135，2025-03 后不维护）全部功能 + 本 mod 原有状态输出：

- **轮盘 14 槽**：原生增强 10 项（要弹药/注意/帝皇/敌人/治疗/帮助/位置/是/否/谢谢，带语音+聊天+标记动作）+ 报告高压 + 状态 3 项（大招/手雷/子弹余量）
- **右键拖拽重排**槽位，布局跨会话保存
- **每项独立快捷键**（Mod Options 绑定，战斗内直接触发）
- **求助联动**：选帮助 → 本地求救语音 + 聊天 `#need_help` 协议；队友装本 mod 收到 → 帮播语音 + 头顶 10 秒求助标记
- **dibs 禁用**（重复标记不喊"我的"）
- 仅战斗显示（大厅隐藏）；防刷屏冷却；输出可配仅本地/队伍频道

- **位置**：`D:\DeepseekWorkspace\暗潮\04-Mods\status_wheel\`
- **仓库**：https://github.com/CiJhuiDi/darktide-status-wheel（已推未实测，无 Release）
- **状态**：实现完成，**待游戏内实测**

## 二、文件结构

```
status_wheel/
├── status_wheel.mod              # version = "2.0.0"、author = "CiJhuiDi"
├── README.md                     # 功能/安装/配置
├── release\status_wheel_2.0.0.zip
└── scripts\mods\status_wheel\
    ├── status_wheel.lua          # 主逻辑：wheel_config 布局/拖拽/hook/调度/状态读取
    ├── status_wheel_data.lua     # 设置项（含 14 个 keybind）
    ├── status_wheel_localization.lua
    └── modules\
        ├── wheel_options.lua     # 选项定义（FTE 10 + 高压 + 状态 3）
        ├── wheel_actions.lua     # 动作执行（tag/chat/voice/status/压力报告，全 pcall）
        └── need_help.lua         # 求助联动（语音/世界标记/队友响应）
```

## 三、关键机制

### 布局（wheel_config）

- `mod:get("wheel_config") or table.clone(DEFAULT)`（14 槽）；拖拽交换后 `mod:set` 立即保存
- 有**迁移逻辑**：默认布局新增条目自动追加到已保存配置尾部（老用户升级不丢布局）
- `generate_options` 过滤被禁用的状态条目（enable_* 开关）

### 快捷键

- data 里 keybind 设置：`type="keybind", keybind_type="function_call", function_name="keybind_<key>"`
- 主文件 `setup_keybind_functions()` 遍历 wheel_options 生成 `mod["keybind_"..key]` 函数 → `mod.run_option_by_keybind(option)`（战斗 + 存活检查）

### 求助联动（need_help.lua）

- 本地：`vo_call_for_help`（require `dialogues/generated/gameplay_vo_<voice>` 随机播求救语音，memoise 缓存）+ `send_wheel_message`（带 `#need_help` 协议标记）
- 队友响应：`mod:hook_safe("VivoxManager", "_handle_event", ...)`（DMF 字符串 hook 自动延迟）→ 检测 `#need_help` → 帮播语音 + `add_world_marker_unit` 头顶标记（10 秒清理）

## 四、踩坑（血泪，勿重蹈）

1. **崩溃坑（已修）**：轮盘选项**必须带 `voice_event_data` 字段**！原生 `hud_element_smart_tagging.lua` 选中回调访问 `option.voice_event_data.voice_tag_id`（遥测），nil 直接崩游戏（日志：`attempt to index field 'voice_event_data' (a nil value)`）。空 `{voice_tag_concept, voice_tag_id=""}` 不发声防崩。**改 wheel_options.lua 加新选项时必带！**
2. **重叠坑（已修）**：轮盘半径固定 ~190px，14 槽每槽仅 ~85px 弧长，112px 图标必叠。图标/扇区尺寸按槽位动态缩放：≤8:112 / 9-10:100 / 11-12:88 / 13-14:76。
3. **防御式适配**：FTE 直读的私有字段全换公开 API（`Managers.chat._sessions`→`sessions()`、`Managers.player._players_by_peer`→`players_at_peer()`）；SmartTagSystem/VivoxManager 用 DMF 字符串 hook（类未定义自动延迟，class() 定义时挂上）。
4. 战斗判定：`Managers.state.game_mode:game_mode()` 拿对象 `:name()`；hub 模式用武器槽配置/持械信号区分训练场/射击场。
5. 原生 `_populate_wheel` 完全替换为 wheel_config 生成的选项（FTE 方式）；`_update_widget_locations` hook 清 start_angle 防错位。

## 五、参考

- FTE 源码：`暗潮\99-临时文件\fte_ref\ForTheEmperorRepo-main\`（整合来源）
- 游戏 UI 源码：在线仓库 Aussiemon/Darktide-Source-Code（本地反编译无 UI 层；smart_tagging 主文件已下载到 `99-临时文件\ref\hud_element_smart_tagging.lua`）

## 六、待办

- [ ] 游戏内实测：14 槽布局/拖拽/快捷键/高压按钮/help 联动/与旧 FTE 共存警告
- [ ] 实测通过 → 打 zip（已备）+ Release
