-- chunkname: @scripts/mods/status_wheel/status_wheel.lua
--[[
	状态轮盘 (Status Wheel) v2.0.0
	整合 For The Emperor（Enhanced Comms Wheel，已停更）全部功能 + 状态输出：

	轮盘（默认 13 槽，可拖拽重排 + 持久化）：
	  - 原生增强 10 项：要弹药/注意/帝皇/敌人/治疗/帮助/位置/是/否/谢谢
	    （带角色语音、聊天消息、场景标记动作）
	  - 状态 3 项：大招状态 / 手雷数量 / 子弹余量（本 mod 原有）

	特性：
	  - 右键拖拽重排槽位，布局跨会话保存（mod:set("wheel_config")）
	  - 每项独立快捷键（Mod Options 里绑定），不开轮盘直接触发
	  - 帮助联动：选帮助 → 本地求救语音 + 聊天 #need_help 协议；
	    队友装了本 mod 会收到 → 帮播语音 + 头顶 10 秒求助标记
	  - dibs 禁用：禁掉标记系统"抢"回复（默认开）
	  - 仅战斗状态注入（大厅隐藏）；防刷屏冷却；输出可配仅本地/队伍频道
	  - 与旧版 For The Emperor 冲突检测（发现则警告，建议卸载旧版）

	兼容说明：原版 FTE 直读私有字段/脆弱内部 API，本整合版全部防御式适配
	（pcall + 能力检测 + 公开 API 替代），失效功能自动降级不崩。
	参考：MalkyLuke/ForTheEmperorRepo（MIT），已归档 D:\DeepseekWorkspace\暗潮\99-临时文件\fte_ref\
]]

local mod = get_mod("status_wheel")

-- ############ 模块加载 ############

local wheel_options_module = mod:io_dofile("status_wheel/scripts/mods/status_wheel/modules/wheel_options")
mod:io_dofile("status_wheel/scripts/mods/status_wheel/modules/wheel_actions")
mod:io_dofile("status_wheel/scripts/mods/status_wheel/modules/need_help")

local WHEEL_OPTION = wheel_options_module.WHEEL_OPTION
local wheel_options = wheel_options_module.wheel_options
local DEFAULT_WHEEL_CONFIG = wheel_options_module.DEFAULT_WHEEL_CONFIG
local ENABLE_SETTING_BY_OPTION = wheel_options_module.ENABLE_SETTING_BY_OPTION

-- ############ 全局本地化注入（轮盘显示名等，原生 Localize 可解析） ############

local status_wheel_localization = mod:io_dofile("status_wheel/scripts/mods/status_wheel/status_wheel_localization")

mod:add_global_localize_strings({
	status_wheel_ability = status_wheel_localization.status_wheel_ability,
	status_wheel_grenade = status_wheel_localization.status_wheel_grenade,
	status_wheel_ammo = status_wheel_localization.status_wheel_ammo,
	status_wheel_pressure = status_wheel_localization.status_wheel_pressure,
	loc_for_the_emperor = status_wheel_localization.mod_title,
	loc_communication_wheel_need_help = status_wheel_localization.need_help_comms_wheel,
})

-- 原生"要弹药"文案首字母大写处理（FTE 同款：Need Ammo）
do
	local ok, raw = pcall(function ()
		return Localize("loc_communication_wheel_need_ammo")
	end)

	if ok and type(raw) == "string" then
		local parts = string.split(raw, " ")

		for i, str in ipairs(parts) do
			if i ~= 2 then
				parts[i] = string.lower(str)
			end
		end

		mod:add_global_localize_strings({
			loc_communication_wheel_need_ammo = {
				en = table.concat(parts, " "),
			},
		})
	end
end

-- ############ 布局配置（wheel_config） ############

-- 槽位顺序（key 列表），跨会话持久化；拖拽重排/修改后立即保存
mod.wheel_config = mod:get("wheel_config") or table.clone(DEFAULT_WHEEL_CONFIG)

-- 迁移：默认布局中新增的条目若不在已保存配置里，追加到尾部（老用户升级后也能看到新按钮）
do
	local changed = false

	for i = 1, #DEFAULT_WHEEL_CONFIG do
		local key = DEFAULT_WHEEL_CONFIG[i]
		local found = false

		for j = 1, #mod.wheel_config do
			if mod.wheel_config[j] == key then
				found = true

				break
			end
		end

		if not found then
			mod.wheel_config[#mod.wheel_config + 1] = key
			changed = true
		end
	end

	if changed then
		mod:set("wheel_config", mod.wheel_config)
	end
end

local function save_wheel_config()
	mod:set("wheel_config", mod.wheel_config)
end

local num_slots = #mod.wheel_config

-- 由布局生成选项表：过滤被禁用的状态条目，跳过未知 key
local function generate_options(wheel_config)
	local options = {}

	for i = 1, #wheel_config do
		local key = wheel_config[i]
		local option = wheel_options[key]

		if option then
			local enable_setting = ENABLE_SETTING_BY_OPTION[key]

			if not enable_setting or mod:get(enable_setting) then
				options[#options + 1] = option
			end
		end
	end

	return options
end

-- ############ 调试输出 ############

local function debug_notify(message)
	if mod:get("debug_mode") then
		mod:notify("[状态轮盘] " .. tostring(message))
	end
end

-- ############ 游戏模式 / 战斗判定（保留原实现） ############

local function get_game_mode_name()
	local game_mode_manager = Managers.state and Managers.state.game_mode

	if not game_mode_manager then
		return "none"
	end

	local ok, game_mode = pcall(function ()
		return game_mode_manager:game_mode()
	end)

	if ok and game_mode and game_mode.name then
		local ok2, name = pcall(game_mode.name, game_mode)

		if ok2 and name then
			return name
		end
	end

	return "unknown"
end

-- 共享给 wheel_actions / need_help
mod.get_local_player_unit = function ()
	local player = Managers.player and Managers.player:local_player(1)

	if not player then
		return nil
	end

	local unit = player.player_unit

	if not unit or not Unit.alive(unit) then
		return nil
	end

	return unit
end

-- 是否处于战斗状态（大厅隐藏，训练场/射击场/任务中可用）
mod.is_in_combat = function ()
	local name = get_game_mode_name()

	if name == "none" or name == "unknown" then
		return false
	end

	if name == "prologue_hub" or name == "hub_singleplay" then
		return false
	end

	if name == "hub" then
		local unit = mod.get_local_player_unit()

		if not unit then
			return false
		end

		-- 信号 1：有武器槽配置（训练场/射击场玩家 unit 装备了武器）
		if ScriptUnit.has_extension(unit, "visual_loadout_system") then
			local visual_loadout_extension = ScriptUnit.extension(unit, "visual_loadout_system")
			local weapon_slots = visual_loadout_extension:slot_configuration_by_type("weapon")

			if weapon_slots then
				for _, config in pairs(weapon_slots) do
					if config then
						return true
					end
				end
			end
		end

		-- 信号 2：当前持械（非空手）
		if ScriptUnit.has_extension(unit, "unit_data_system") then
			local unit_data_extension = ScriptUnit.extension(unit, "unit_data_system")
			local inventory_component = unit_data_extension:read_component("inventory")
			local wielded_slot = inventory_component and inventory_component.wielded_slot

			if wielded_slot ~= nil and wielded_slot ~= "slot_unarmed" then
				return true
			end
		end

		return false
	end

	return true
end

-- ############ 状态数据读取（保留原实现） ############

local function get_ability_extension(unit)
	if not ScriptUnit.has_extension(unit, "ability_system") then
		return nil
	end

	return ScriptUnit.extension(unit, "ability_system")
end

local function get_combat_ability_status()
	local unit = mod.get_local_player_unit()

	if not unit then
		return nil
	end

	local ability_extension = get_ability_extension(unit)

	if not ability_extension then
		return nil
	end

	local ability_type = "combat_ability"

	if not ability_extension:has_ability_type(ability_type) then
		return mod:localize("no_ability")
	end

	local format = mod:get("ability_format")
	local can_use = ability_extension:can_use_ability(ability_type)

	if can_use then
		return mod:localize("ability_ready")
	end

	local max_charges = ability_extension:max_ability_charges(ability_type)
	local remaining_charges = ability_extension:remaining_ability_charges(ability_type)

	if (format == "charges" or format == "auto") and max_charges and max_charges > 1 then
		return mod:localize("ability_charges", remaining_charges, max_charges)
	end

	local max_cooldown = ability_extension:max_ability_cooldown(ability_type)
	local remaining_cooldown = ability_extension:remaining_ability_cooldown(ability_type)

	if max_cooldown and max_cooldown > 0 then
		local percent = math.max(remaining_cooldown / max_cooldown * 100, 0)
		local seconds = math.ceil(remaining_cooldown)

		if format == "percent" then
			return mod:localize("ability_charging_percent", math.floor(percent))
		elseif format == "seconds" then
			return mod:localize("ability_charging_seconds", seconds)
		else
			return mod:localize("ability_charging_mixed", math.floor(percent), seconds)
		end
	end

	return mod:localize("ability_charging")
end

local function get_grenade_status()
	local unit = mod.get_local_player_unit()

	if not unit then
		return nil
	end

	local ability_extension = get_ability_extension(unit)

	if not ability_extension then
		return nil
	end

	local remaining = ability_extension:remaining_ability_charges("grenade_ability")
	local max = ability_extension:max_ability_charges("grenade_ability")

	if not max or max <= 0 then
		return mod:localize("no_grenade")
	end

	return mod:localize("grenade_count", remaining, max)
end

local function get_ammo_status()
	local unit = mod.get_local_player_unit()

	if not unit then
		return nil
	end

	if not ScriptUnit.has_extension(unit, "unit_data_system") or not ScriptUnit.has_extension(unit, "visual_loadout_system") then
		return nil
	end

	local unit_data_extension = ScriptUnit.extension(unit, "unit_data_system")
	local visual_loadout_extension = ScriptUnit.extension(unit, "visual_loadout_system")
	local slot_configuration = visual_loadout_extension:slot_configuration_by_type("weapon")
	local inventory_component = unit_data_extension:read_component("inventory")
	local wielded_slot = inventory_component and inventory_component.wielded_slot or "none"

	if wielded_slot == "none" or not slot_configuration[wielded_slot] then
		return nil
	end

	local slot_component = unit_data_extension:read_component(wielded_slot)

	if not slot_component then
		return nil
	end

	local clip = slot_component.current_ammunition_clip and slot_component.current_ammunition_clip[1] or 0
	local max_clip = slot_component.max_ammunition_clip and slot_component.max_ammunition_clip[1] or 0

	if max_clip <= 0 then
		return mod:localize("melee_weapon")
	end

	if mod:get("ammo_show_reserve") then
		local reserve = slot_component.current_ammunition_reserve or 0
		local max_reserve = slot_component.max_ammunition_reserve or 0

		return mod:localize("ammo_clip_reserve", clip, max_clip, reserve, max_reserve)
	end

	return mod:localize("ammo_clip", clip, max_clip)
end

-- ############ 聊天输出（保留原实现，返回是否发送成功） ############

-- 发送状态消息：队伍/任务频道或仅本地（system_chat_message 事件）
mod.send_status_message = function (message)
	if not message then
		return false
	end

	local output_target = mod:get("output_target")

	if output_target == "party" and Managers.chat then
		local ok, channels = pcall(function ()
			return Managers.chat:connected_chat_channels()
		end)

		if ok and channels then
			-- 任务中队友聊天走 MISSION 频道（原生轮盘聊天消息也是 MISSION）；大厅组队走 PARTY 频道
			local target_tags = {
				"MISSION",
				"PARTY",
			}

			for i = 1, #target_tags do
				local target_tag = target_tags[i]

				for channel_handle, channel in pairs(channels) do
					if channel.tag == target_tag then
						local ok_send = pcall(Managers.chat.send_channel_message, Managers.chat, channel_handle, message)

						return ok_send
					end
				end
			end
		end

		-- 配置了队伍频道但找不到（异常情况），回落本地显示并提示
		debug_notify("未找到任务/队伍频道，已回落为本地显示")
	end

	if Managers.event then
		Managers.event:trigger("system_chat_message", message, "SYSTEM")

		return true
	end

	return false
end

-- 状态输出命令（冷却 + 读取 + 发送）
mod.handle_status_command = function (action)
	if not mod.is_in_combat() then
		return
	end

	-- 防刷屏冷却：同类型消息在冷却期内不再发送，本地提示剩余时间
	local cooldown = mod:get("send_cooldown")

	if cooldown == nil then
		cooldown = 15
	end

	if cooldown and cooldown > 0 then
		local now = os.clock()
		local last = mod.last_send_time and mod.last_send_time[action]

		if last and now - last < cooldown then
			local remain = math.ceil(cooldown - (now - last))

			if Managers.event then
				Managers.event:trigger("system_chat_message", mod:localize("cooldown_message", remain), "SYSTEM")
			end

			return
		end

		mod.last_send_time = mod.last_send_time or {}
		mod.last_send_time[action] = now
	end

	local status_text

	if action == "ability" then
		status_text = get_combat_ability_status()
	elseif action == "grenade" then
		status_text = get_grenade_status()
	elseif action == "ammo" then
		status_text = get_ammo_status()
	end

	if not status_text then
		status_text = mod:localize("status_wheel_error")
	end

	mod.send_status_message(status_text)
end

-- ############ 快捷键 ############

-- 为每个选项生成 keybind 函数（DMF keybind 设置触发 mod:keybind_<name>）
local function setup_keybind_functions()
	for key, option in pairs(wheel_options) do
		mod["keybind_" .. key] = function ()
			mod.run_option_by_keybind(option)
		end
	end
end

setup_keybind_functions()

-- ############ 样式放大（FTE：图标/扇区尺寸） ############

local ICON_SIZE = { 112, 112 }
local LINE_SIZE = { 200, 147 }
local SLICE_SIZE = { 120, 140 }

mod:hook_require("scripts/ui/hud/elements/smart_tagging/hud_element_smart_tagging_settings", function (settings)
	mod.smart_tagging_settings = settings
	settings.wheel_slots = num_slots
	mod:info("[status_wheel] wheel_slots -> " .. tostring(num_slots))
end)

mod:hook_require("scripts/ui/hud/elements/smart_tagging/hud_element_smart_tagging_definitions", function (definitions)
	local style = definitions.entry_widget_definition and definitions.entry_widget_definition.style

	if not style then
		mod:warning("[status_wheel] smart_tagging definitions style not found, style scaling skipped")

		return
	end

	local ok = pcall(function ()
		style.style_id_2.size = ICON_SIZE -- icon
		style.style_id_3.size = LINE_SIZE -- slice_eighth_line

		style.style_id_4.size = SLICE_SIZE -- slice_eighth_highlight
		style.style_id_4.uvs = { { 0.1, 0 }, { 0.9, 1 } }

		style.style_id_5.size = SLICE_SIZE -- slice_eighth
		style.style_id_5.uvs = { { 0.1, 0 }, { 0.9, 1 } }
	end)

	if not ok then
		mod:warning("[status_wheel] definitions style fields missing, style scaling skipped")
	end
end)

-- ############ Hooks ############

-- 选项合并：完全替换为 wheel_config 布局（FTE 方式）
mod:hook("HudElementSmartTagging", "_populate_wheel", function (func, self, options)
	options = options or {}

	local current_slots = #mod.wheel_config

	if #self._entries < current_slots then
		self:_setup_entries(current_slots)
	end

	return func(self, generate_options(mod.wheel_config))
end)

-- 10+ 槽下原生 start_angle 偏移会导致选项错位/重叠，强制均匀分布
mod:hook("HudElementSmartTagging", "_update_widget_locations", function (func, self)
	local saved = {}

	for i = 1, #self._entries do
		local option = self._entries[i].option

		if option and option.start_angle then
			saved[i] = option.start_angle
			option.start_angle = nil
		end
	end

	local result = func(self)

	for i, angle in pairs(saved) do
		self._entries[i].option.start_angle = angle
	end

	return result
end)

-- 选中拦截：原生流程执行后，检测自定义/增强选项并执行动作
mod:hook_safe("HudElementSmartTagging", "_on_com_wheel_stop_callback", function (self, t, ui_renderer, render_settings, input_service)
	if self.destroyed then
		return
	end

	local wheel_active = self._wheel_active
	local wheel_hovered_entry = wheel_active and self:_is_wheel_entry_hovered(t)

	if wheel_hovered_entry then
		local option = wheel_hovered_entry.option

		if option then
			mod.execute_option(option)
		end
	end
end)

-- 刷新：首次初始化 / 拖拽重排 / 进出战斗 / 设置变更
mod:hook_safe("HudElementSmartTagging", "update", function (self, dt, t, ui_renderer, render_settings, input_service)
	if not mod.smart_tagging_instance then
		mod.smart_tagging_instance = self
		debug_notify("hook 已注册")

		-- 旧版 FTE 冲突检测
		if get_mod("ForTheEmperor") then
			mod:warning("[status_wheel] 检测到旧版 For The Emperor：本 mod v2.0 已整合其全部功能，请卸载旧版避免冲突")
		end
	end

	-- 拖拽重排（FTE：右键按住拖条目换槽）
	if self._wheel_active and Mouse.button(1) == 1 then
		local hovered_entry, hovered_index = self:_is_wheel_entry_hovered(t)

		if hovered_entry then
			if not mod.dragged_entry then
				mod.dragged_entry = hovered_entry
				mod.dragged_index = hovered_index
			end

			if hovered_index ~= mod.dragged_index then
				local config = mod.wheel_config
				local replaced_key = config[hovered_index]
				config[hovered_index] = config[mod.dragged_index]
				config[mod.dragged_index] = replaced_key

				mod.dragged_entry = hovered_entry
				mod.dragged_index = hovered_index

				save_wheel_config()
				self:_populate_wheel({})
			end

			-- 拖拽视觉反馈：当前条目图标/扇区偏移放大
			local wheel_background_widget = self._widgets_by_name.wheel_background

			if wheel_background_widget and wheel_background_widget.content then
				wheel_background_widget.content.text = Localize(mod.dragged_entry.option.display_name)
			end

			for i, entry in pairs(self._entries) do
				local icon = entry.widget.style.style_id_2
				local highlight = entry.widget.style.style_id_4
				local slice = entry.widget.style.style_id_5

				if i == hovered_index then
					local angle = hovered_entry.widget.content.angle
					local offset_x = math.sin(angle) * 30
					local offset_y = math.cos(angle) * 30

					icon.offset[1] = offset_x
					icon.offset[2] = offset_y
					highlight.offset[1] = offset_x
					highlight.offset[2] = offset_y
					slice.offset[1] = offset_x
					slice.offset[2] = offset_y

					highlight.color[1] = 200
					slice.color[1] = 200
				else
					icon.offset[1] = 0
					icon.offset[2] = 0
					highlight.offset[1] = 0
					highlight.offset[2] = 0
					slice.offset[1] = 0
					slice.offset[2] = 0

					highlight.color[1] = 50
					slice.color[1] = 50
				end
			end
		end
	else
		-- 松开拖拽：恢复视觉
		for _, entry in pairs(self._entries) do
			local icon = entry.widget.style.style_id_2
			local highlight = entry.widget.style.style_id_4
			local slice = entry.widget.style.style_id_5

			icon.offset[1] = 0
			icon.offset[2] = 0
			highlight.offset[1] = 0
			highlight.offset[2] = 0
			slice.offset[1] = 0
			slice.offset[2] = 0

			highlight.color[1] = 150
			slice.color[1] = 150
		end

		mod.dragged_entry = nil
		mod.dragged_index = nil
	end

	local in_combat = mod.is_in_combat()

	if in_combat ~= mod.in_combat_prev then
		mod.in_combat_prev = in_combat
		mod.wheel_dirty = true
		debug_notify("战斗状态切换 -> " .. tostring(in_combat) .. "（game_mode: " .. get_game_mode_name() .. "）")
	end

	if mod.wheel_dirty then
		mod.wheel_dirty = false

		self:_populate_wheel({})
	end
end)

-- ############ dibs 禁用（FTE：禁掉标记系统"抢"回复） ############

mod:hook("SmartTagSystem", "reply_tag", function (func, self, tag_id, replier_unit, reply_name)
	if mod:get("disable_dibs") and reply_name == "dibs" then
		local ok, tag = pcall(function ()
			return self._all_tags[tag_id]
		end)

		if ok and tag then
			pcall(function ()
				self:cancel_tag(tag_id, tag._tagger_unit)

				self:set_tag(tag._template.name, replier_unit, tag._target_unit)
			end)

			return
		end
	end

	return func(self, tag_id, replier_unit, reply_name)
end)

-- ############ Callbacks ############

-- 设置变更时标记脏，下帧刷新轮盘条目
mod.on_setting_changed = function (setting_id)
	local refresh_settings = {
		enable_ability = true,
		enable_grenade = true,
		enable_ammo = true,
	}

	if refresh_settings[setting_id] then
		mod.wheel_dirty = true
	end
end

-- 每帧清理过期求助标记
mod.update = function ()
	mod.update_help_markers()
end

-- 卸载/禁用时保存布局
mod.on_unload = function ()
	save_wheel_config()
	mod.smart_tagging_instance = nil
	mod.dragged_entry = nil
	mod.dragged_index = nil
end

-- 首次加载标记脏：HUD 元素可能已初始化（热重载场景），靠 update 钩子在下帧注入
mod.wheel_dirty = true
