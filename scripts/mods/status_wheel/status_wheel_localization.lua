-- chunkname: @scripts/mods/status_wheel/status_wheel_localization.lua
-- 状态轮盘 (Status Wheel) 本地化

return {
	mod_name = {
		en = "Status Wheel",
		["zh-cn"] = "状态轮盘",
	},
	mod_description = {
		en = "Enhanced comms wheel (V key): 10 native options with voice/chat/tag actions, right-click drag to rearrange, per-option keybinds, help beacon — plus status options printing your combat ability, grenade count, and ammo to chat. Integrates the discontinued For The Emperor mod.",
		["zh-cn"] = "增强通信轮盘（V 键）：10 个原生选项（含语音/聊天/标记动作）、右键拖拽重排、每个选项独立快捷键、求助标记——外加状态条目（大招/手雷/子弹）。整合了已停更的 For The Emperor。",
	},

	-- 轮盘条目名（全局注入用）
	mod_title = {
		en = "For the Emperor!",
		["zh-cn"] = "为了帝皇！",
	},
	need_help_comms_wheel = {
		en = "Need Help",
		["zh-cn"] = "需要帮助",
	},
	need_help = {
		en = "I need help!",
		["zh-cn"] = "我需要帮助！",
	},

	-- 轮盘条目名
	status_wheel_ability = {
		en = "Combat Ability",
		["zh-cn"] = "大招状态",
	},
	status_wheel_grenade = {
		en = "Grenades",
		["zh-cn"] = "手雷数量",
	},
	status_wheel_ammo = {
		en = "Ammo",
		["zh-cn"] = "子弹余量",
	},
	status_wheel_pressure = {
		en = "Under Pressure",
		["zh-cn"] = "报告高压",
	},
	status_wheel_pressure_msg = {
		en = "Under pressure!!!",
		["zh-cn"] = "高压！！！",
	},

	-- 设置项（轮盘行为，整合自 For The Emperor）
	options = {
		en = "Wheel Behavior",
		["zh-cn"] = "轮盘行为",
	},
	disable_dibs = {
		en = "Disable calling dibs when re-tagging",
		["zh-cn"] = "重复标记时不喊“我的”",
	},
	disable_dibs_desc = {
		en = "Call out and extend existing tags instead of saying \"That's mine!\"",
		["zh-cn"] = "重复标记时改为喊话并延长已有标记，而不是说“那是我的！”。",
	},
	ignore_help = {
		en = "Ignore help",
		["zh-cn"] = "忽略求助",
	},
	ignore_help_desc = {
		en = "Mute teammates and disable indicators when they need help",
		["zh-cn"] = "队友求助时静音并禁用提示标记。",
	},
	keybinds = {
		en = "Keybinds",
		["zh-cn"] = "快捷键",
	},
	keybind_emperor = {
		en = "For the Emperor",
		["zh-cn"] = "帝皇",
	},
	keybind_no = {
		en = "No",
		["zh-cn"] = "否",
	},
	keybind_yes = {
		en = "Yes",
		["zh-cn"] = "是",
	},
	keybind_thanks = {
		en = "Thanks",
		["zh-cn"] = "谢谢",
	},
	keybind_ammo = {
		en = "Need Ammo",
		["zh-cn"] = "需要弹药",
	},
	keybind_health = {
		en = "Need Health",
		["zh-cn"] = "需要治疗",
	},
	keybind_pressure = {
		en = "Under Pressure",
		["zh-cn"] = "报告高压",
	},
	keybind_help = {
		en = "Need Help",
		["zh-cn"] = "需要帮助",
	},
	keybind_attention = {
		en = "Attention",
		["zh-cn"] = "注意",
	},
	keybind_location = {
		en = "Location",
		["zh-cn"] = "位置",
	},
	keybind_enemy = {
		en = "Enemy",
		["zh-cn"] = "敌人",
	},
	keybind_ability = {
		en = "Combat Ability",
		["zh-cn"] = "大招状态",
	},
	keybind_grenade = {
		en = "Grenades",
		["zh-cn"] = "手雷数量",
	},
	keybind_ammo_status = {
		en = "Ammo",
		["zh-cn"] = "子弹余量",
	},

	-- 设置项（原有）
	enable_ability = {
		en = "Enable: Combat Ability",
		["zh-cn"] = "启用：大招状态",
	},
	enable_ability_description = {
		en = "Adds a wheel option that prints your combat ability status.",
		["zh-cn"] = "在轮盘中添加大招状态条目。",
	},
	enable_grenade = {
		en = "Enable: Grenades",
		["zh-cn"] = "启用：手雷数量",
	},
	enable_grenade_description = {
		en = "Adds a wheel option that prints your grenade count.",
		["zh-cn"] = "在轮盘中添加手雷数量条目。",
	},
	enable_ammo = {
		en = "Enable: Ammo",
		["zh-cn"] = "启用：子弹余量",
	},
	enable_ammo_description = {
		en = "Adds a wheel option that prints your current weapon ammo.",
		["zh-cn"] = "在轮盘中添加子弹余量条目。",
	},
	output_target = {
		en = "Output Target",
		["zh-cn"] = "输出目标",
	},
	output_target_description = {
		en = "Where the status messages are printed. Party (default) = teammates can see your status in chat. Local = only you see it.",
		["zh-cn"] = "状态消息输出到哪里。队伍（默认）= 队友能在聊天栏看到你的状态；本地 = 只有自己可见。",
	},
	send_cooldown = {
		en = "Send Cooldown (seconds)",
		["zh-cn"] = "发送冷却（秒）",
	},
	send_cooldown_description = {
		en = "Minimum seconds between two status messages of the same type, to avoid spamming the party chat. 0 = no limit.",
		["zh-cn"] = "同类型状态消息的最短发送间隔，避免刷屏队伍频道。0 = 不限制。",
	},
	cooldown_message = {
		en = "Cooldown, %ds until you can send again",
		["zh-cn"] = "冷却中，%ds 后可再次发送",
	},
	seconds = {
		en = "s",
		["zh-cn"] = "秒",
	},
	output_target_local_setting_text = {
		en = "Local only",
		["zh-cn"] = "仅本地",
	},
	output_target_party_setting_text = {
		en = "Party chat",
		["zh-cn"] = "队伍频道",
	},
	ability_format = {
		en = "Ability Display Format",
		["zh-cn"] = "大招显示格式",
	},
	ability_format_description = {
		en = "How the combat ability status is formatted. Auto picks charges for charge-based abilities and cooldown for cooldown-based ones.",
		["zh-cn"] = "大招状态的显示格式。自动模式：充能制技能显示充能层数，冷却制技能显示冷却进度。",
	},
	ability_format_auto_setting_text = {
		en = "Auto",
		["zh-cn"] = "自动",
	},
	ability_format_charges_setting_text = {
		en = "Charges",
		["zh-cn"] = "充能层数",
	},
	ability_format_percent_setting_text = {
		en = "Cooldown %",
		["zh-cn"] = "冷却百分比",
	},
	ability_format_seconds_setting_text = {
		en = "Cooldown seconds",
		["zh-cn"] = "冷却秒数",
	},
	ammo_show_reserve = {
		en = "Show Reserve Ammo",
		["zh-cn"] = "显示备弹",
	},
	ammo_show_reserve_description = {
		en = "Also prints the reserve ammo pool for the current weapon.",
		["zh-cn"] = "在弹夹余量之外，同时显示当前武器的备弹。",
	},
	debug_mode = {
		en = "Debug Mode",
		["zh-cn"] = "调试模式",
	},
	debug_mode_description = {
		en = "Shows popup notifications at key steps (hook registration, combat state, entry injection) to verify the mod is working.",
		["zh-cn"] = "在关键步骤（hook 注册、战斗状态切换、条目注入）弹屏通知，用于确认 mod 是否正常工作。",
	},

	-- 状态消息文案（%s / %d 为占位符）
	ability_ready = {
		en = "Combat Ability: READY",
		["zh-cn"] = "大招状态：可用",
	},
	ability_charging = {
		en = "Combat Ability: recharging",
		["zh-cn"] = "大招状态：冷却中",
	},
	ability_charging_percent = {
		en = "Combat Ability: recharging %d%%",
		["zh-cn"] = "大招状态：冷却中 %d%%",
	},
	ability_charging_seconds = {
		en = "Combat Ability: recharging %ds",
		["zh-cn"] = "大招状态：冷却中 %ds",
	},
	ability_charging_mixed = {
		en = "Combat Ability: recharging %d%% (%ds)",
		["zh-cn"] = "大招状态：冷却中 %d%%（%ds）",
	},
	ability_charges = {
		en = "Combat Ability: %d/%d charges",
		["zh-cn"] = "大招状态：充能 %d/%d",
	},
	no_ability = {
		en = "Combat Ability: not equipped",
		["zh-cn"] = "大招状态：未装备",
	},
	grenade_count = {
		en = "Grenades: %d/%d",
		["zh-cn"] = "手雷数量：%d/%d",
	},
	no_grenade = {
		en = "Grenades: none",
		["zh-cn"] = "手雷数量：无",
	},
	ammo_clip = {
		en = "Ammo: %d/%d",
		["zh-cn"] = "子弹余量：%d/%d",
	},
	ammo_clip_reserve = {
		en = "Ammo: %d/%d (reserve %d/%d)",
		["zh-cn"] = "子弹余量：%d/%d（备弹 %d/%d）",
	},
	melee_weapon = {
		en = "Ammo: melee weapon",
		["zh-cn"] = "子弹余量：近战武器",
	},
	status_wheel_error = {
		en = "Unable to read status (not in a game?)",
		["zh-cn"] = "无法获取状态（不在游戏中？）",
	},
}
