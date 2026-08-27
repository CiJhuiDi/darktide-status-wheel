# status_wheel · 项目交接摘要

> **给新会话的快速上手文档**：读完这个 + 通用规范（`暗潮\01-开发规范\Darktide-Mod开发规范.md`）即可接手。
> 最后更新：2026-08-27 13:00 | 当前版本：v2.0.0（已发 Release，2026-08-27；待游戏内实测）

---

## 一、项目是什么

《战锤40K：暗潮》的增强通信轮盘 mod（DMF Lua mod，V 键）。v2.0.0 整合了**已停更的 For The Emperor**（NexusMods 135，2025-03 后不维护）全部功能 + 本 mod 原有状态输出：

- **轮盘 14 槽**：原版 7 项（要弹药/注意/帝皇/敌人/治疗/位置/谢谢，带语音+聊天+标记动作）+ FTE 新增 3 项（帮助/是/否）+ 报告高压 + 状态 3 项（大招/手雷/子弹余量）
- **选项分类开关（2026-08-20 新增，3 类）**：native 原版 7 项（emperor 对应原版 cheer）/ enhanced FTE 新增 3 项（help/no/yes）/ status **本 mod 新增状态 4 项**（ability/grenade/ammo_status/**pressure 高压**，用户要求高压并入状态类）；每类一个折叠 group，**组内第一项 = 类总开关**（enable_native / enable_enhanced / enable_status），其后子开关（7+3 个 enable_option_* + enable_ability/grenade/ammo/enable_pressure）；被禁用选项从轮盘消失且对应快捷键失效（run_option_by_keybind 传 key 检查 is_option_enabled）
- **归类结构坑（2026-08-20 用户纠错）**：总开关不能独立悬在组外（增强总开关出现在原版组下面很乱）——总开关必须和子开关同组，组内第一项；用户明确"mod 新增的四样（大招/手雷/子弹/高压）和总开关归到一起"
- **拖拽索引错位坑（2026-08-20 用户实测发现，已修）**：FTE 原版拖拽直接操作 wheel_config[i]——前提是显示列表和布局一一对应（FTE 时代只有 3 个状态开关，几乎全开）。引入分类开关后用户一关选项，显示列表是过滤后的，拖拽索引就对不上隐藏项 → 拖了没反应。修：get_visible_config() 过滤出可见 key 列表，拖拽在可见列表内换位，再按"可见项原位填充、禁用项保持原位"合并回 wheel_config
- **动态槽位/均分/缩放（2026-08-20 新增）**：_populate_wheel hook 按实际显示数重建 entries（_setup_entries 销毁重建可增可减）、同步 settings.wheel_slots、apply_icon_sizes 按实际数缩放图标（≤8:112 / 9-10:100 / 11-12:88 / 13+:76）；空轮盘保护 count 最小 1（防 0 除）；重建时清 dragged 引用
- **style 引用坑（2026-08-20 修复，用户实测发现图标大小没变）**：改 definitions.style 对已创建 widget 不生效（widget.style 是创建时拷贝/独立表）——apply_icon_sizes 改为**遍历 entries 直接改 widget.style**（实际渲染对象）+ definitions 同步兜底；旧 FTE 方式（只改 definitions）从未实测过
- **拖拽总开关（2026-08-20 新增）**：enable_drag_reorder（默认开，在"轮盘行为"组）——关掉后右键拖拽重排彻底禁用、布局锁定（防实战误触）；on_setting_changed 对该设置不触发轮盘刷新
- **右键拖拽重排**槽位，布局跨会话保存
- **每项独立快捷键**（Mod Options 绑定，战斗内直接触发）
- **求助联动**：选帮助 → 本地求救语音 + 聊天 `#need_help` 协议；队友装本 mod 收到 → 帮播语音 + 头顶 10 秒求助标记
- **dibs 禁用**（重复标记不喊"我的"）
- 仅战斗显示（大厅隐藏）；防刷屏冷却；输出可配仅本地/队伍频道

- **位置**：`D:\DeepseekWorkspace\暗潮\04-Mods\status_wheel\`
- **仓库**：https://github.com/CiJhuiDi/darktide-status-wheel（✅ 已发 Release v2.0.0，2026-08-27）
- **状态**：实现完成，已发 Release v2.0.0，**待游戏内实测**

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
- `generate_options` 过滤：`is_option_enabled(key)` 双重判断（类总开关 + 选项 enable_setting），用 `== false` 判断（未保存返回 nil 视为开启，老用户升级不丢选项）
- **动态槽位**：`_populate_wheel` hook 每次按 `#option_list` 重建 entries + 同步 `settings.wheel_slots` + 缩放图标（原生 `_update_widget_locations` 用 `#entries` 均分角度，entries 数=实际数即自动均分）
- `on_setting_changed`：所有 `enable_` 前缀设置变更都标 wheel_dirty 下帧刷新（拖拽开关除外）
- **弹药状态（2026-08-20 修复）**：get_ammo_status 不再报"近战武器"——手持近战/空手时自动遍历武器槽找第一把有弹药的远程武器（优先当前手持远程）；无远程武器才报 no_ranged_weapon

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
- [ ] 实测新增的**选项分类开关**（4 类总开关 + 13 子开关显隐、快捷键联动失效、折叠 group 显示）
- [ ] 实测**动态槽位/均分/缩放**（关掉部分选项后剩余项是否均分、图标是否按数量缩放、空轮盘不崩）
- [ ] 实测**弹药修复**（手持近战报告弹药 → 应报远程武器弹药）
- [x] 打 zip + Release（v2.0.0，2026-08-27 已发：https://github.com/CiJhuiDi/darktide-status-wheel/releases/tag/v2.0.0）
