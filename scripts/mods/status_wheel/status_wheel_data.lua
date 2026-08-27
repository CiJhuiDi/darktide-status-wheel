-- chunkname: @scripts/mods/status_wheel/status_wheel_data.lua
-- 状态轮盘 (Status Wheel) v2.0.0 数据文件：设置项定义

local mod = get_mod("status_wheel")

local mod_data = {
	name = mod:localize("mod_name"),
	description = mod:localize("mod_description"),
	is_togglable = true,
}

-- 所有 setting_id 和 dropdown text id 会自动经过 mod:localize() 本地化
mod_data.options = {
	widgets = {
		-- 三个选项类，各一个折叠组：组内第一项 = 类总开关，其后为子开关
		-- 关闭后整个类的选项不出现在轮盘上（快捷键同步失效）
		-- 轮盘槽位/位置/图标大小随实际显示数自动均分与缩放
		{
			setting_id = "native_options",
			type = "group",
			sub_widgets = {
				-- 类总开关：原版轮盘 7 项
				{
					setting_id = "enable_native",
					type = "checkbox",
					default_value = true,
				},
				{
					setting_id = "enable_option_ammo",
					type = "checkbox",
					default_value = true,
				},
				{
					setting_id = "enable_option_attention",
					type = "checkbox",
					default_value = true,
				},
				{
					setting_id = "enable_option_emperor",
					type = "checkbox",
					default_value = true,
				},
				{
					setting_id = "enable_option_enemy",
					type = "checkbox",
					default_value = true,
				},
				{
					setting_id = "enable_option_health",
					type = "checkbox",
					default_value = true,
				},
				{
					setting_id = "enable_option_location",
					type = "checkbox",
					default_value = true,
				},
				{
					setting_id = "enable_option_thanks",
					type = "checkbox",
					default_value = true,
				},
			},
		},
		{
			setting_id = "enhanced_options",
			type = "group",
			sub_widgets = {
				-- 类总开关：FTE 新增 3 项
				{
					setting_id = "enable_enhanced",
					type = "checkbox",
					default_value = true,
				},
				{
					setting_id = "enable_option_help",
					type = "checkbox",
					default_value = true,
				},
				{
					setting_id = "enable_option_no",
					type = "checkbox",
					default_value = true,
				},
				{
					setting_id = "enable_option_yes",
					type = "checkbox",
					default_value = true,
				},
			},
		},
		{
			setting_id = "status_options",
			type = "group",
			sub_widgets = {
				-- 类总开关：本 mod 新增状态 4 项（大招/手雷/子弹/报告高压）
				{
					setting_id = "enable_status",
					type = "checkbox",
					default_value = true,
				},
				{
					setting_id = "enable_ability",
					type = "checkbox",
					default_value = true,
				},
				{
					setting_id = "enable_grenade",
					type = "checkbox",
					default_value = true,
				},
				{
					setting_id = "enable_ammo",
					type = "checkbox",
					default_value = true,
				},
				{
					setting_id = "enable_pressure",
					type = "checkbox",
					default_value = true,
				},
			},
		},
		-- 输出目标（默认队伍频道：设计初衷是给队友提示状态）
		{
			setting_id = "output_target",
			type = "dropdown",
			default_value = "party",
			options = {
				{ text = "output_target_local_setting_text", value = "local" },
				{ text = "output_target_party_setting_text", value = "party" },
			},
		},
		-- 防刷屏冷却（秒，0 = 不限制）
		{
			setting_id = "send_cooldown",
			type = "numeric",
			default_value = 15,
			range = { 0, 60 },
			unit_text = "seconds",
		},
		-- 大招显示格式
		{
			setting_id = "ability_format",
			type = "dropdown",
			default_value = "auto",
			options = {
				{ text = "ability_format_auto_setting_text",     value = "auto" },
				{ text = "ability_format_charges_setting_text", value = "charges" },
				{ text = "ability_format_percent_setting_text", value = "percent" },
				{ text = "ability_format_seconds_setting_text", value = "seconds" },
			},
		},
		-- 子弹是否显示备弹
		{
			setting_id = "ammo_show_reserve",
			type = "checkbox",
			default_value = true,
		},
		-- 调试模式：关键节点弹屏通知
		{
			setting_id = "debug_mode",
			type = "checkbox",
			default_value = false,
		},
		-- 轮盘行为（整合自 For The Emperor）
		{
			setting_id = "options",
			type = "group",
			sub_widgets = {
				{
					setting_id = "enable_drag_reorder",
					tooltip = "enable_drag_reorder_desc",
					type = "checkbox",
					default_value = true,
				},
				{
					setting_id = "disable_dibs",
					tooltip = "disable_dibs_desc",
					type = "checkbox",
					default_value = true,
				},
				{
					setting_id = "ignore_help",
					tooltip = "ignore_help_desc",
					type = "checkbox",
					default_value = false,
				},
			},
		},
		-- 快捷键（每个轮盘选项一个，不开轮盘直接触发）
		{
			setting_id = "keybinds",
			type = "group",
			sub_widgets = {
				{
					setting_id = "keybind_emperor",
					type = "keybind",
					keybind_trigger = "pressed",
					keybind_type = "function_call",
					function_name = "keybind_emperor",
					default_value = {},
				},
				{
					setting_id = "keybind_no",
					type = "keybind",
					keybind_trigger = "pressed",
					keybind_type = "function_call",
					function_name = "keybind_no",
					default_value = {},
				},
				{
					setting_id = "keybind_yes",
					type = "keybind",
					keybind_trigger = "pressed",
					keybind_type = "function_call",
					function_name = "keybind_yes",
					default_value = {},
				},
				{
					setting_id = "keybind_thanks",
					type = "keybind",
					keybind_trigger = "pressed",
					keybind_type = "function_call",
					function_name = "keybind_thanks",
					default_value = {},
				},
				{
					setting_id = "keybind_ammo",
					type = "keybind",
					keybind_trigger = "pressed",
					keybind_type = "function_call",
					function_name = "keybind_ammo",
					default_value = {},
				},
				{
					setting_id = "keybind_health",
					type = "keybind",
					keybind_trigger = "pressed",
					keybind_type = "function_call",
					function_name = "keybind_health",
					default_value = {},
				},
				{
					setting_id = "keybind_pressure",
					type = "keybind",
					keybind_trigger = "pressed",
					keybind_type = "function_call",
					function_name = "keybind_pressure",
					default_value = {},
				},
				{
					setting_id = "keybind_help",
					type = "keybind",
					keybind_trigger = "pressed",
					keybind_type = "function_call",
					function_name = "keybind_help",
					default_value = {},
				},
				{
					setting_id = "keybind_attention",
					type = "keybind",
					keybind_trigger = "pressed",
					keybind_type = "function_call",
					function_name = "keybind_attention",
					default_value = {},
				},
				{
					setting_id = "keybind_location",
					type = "keybind",
					keybind_trigger = "pressed",
					keybind_type = "function_call",
					function_name = "keybind_location",
					default_value = {},
				},
				{
					setting_id = "keybind_enemy",
					type = "keybind",
					keybind_trigger = "pressed",
					keybind_type = "function_call",
					function_name = "keybind_enemy",
					default_value = {},
				},
				{
					setting_id = "keybind_ability",
					type = "keybind",
					keybind_trigger = "pressed",
					keybind_type = "function_call",
					function_name = "keybind_ability",
					default_value = {},
				},
				{
					setting_id = "keybind_grenade",
					type = "keybind",
					keybind_trigger = "pressed",
					keybind_type = "function_call",
					function_name = "keybind_grenade",
					default_value = {},
				},
				{
					setting_id = "keybind_ammo_status",
					type = "keybind",
					keybind_trigger = "pressed",
					keybind_type = "function_call",
					function_name = "keybind_ammo_status",
					default_value = {},
				},
			},
		},
	},
}

return mod_data
