-- chunkname: @scripts/mods/status_wheel/modules/wheel_actions.lua
--[[
	轮盘选项动作执行（防御式整合 For The Emperor 的动作逻辑）

	所有脆弱 API 均 pcall 保护 + 能力检测：方法不存在则跳过对应动作并降级，
	不崩溃（原版 FTE 停更后部分内部 API 可能已失效）。

	共享函数通过 mod.* 命名空间（主文件提供 is_in_combat / get_local_player_unit / send_status_message）。
]]

local mod = get_mod("status_wheel")

-- ############ 聊天消息（FTE send_wheel_message 防御版） ############

-- 带颜色格式化 + 冷却 + 发送到队伍/任务频道
mod.last_wheel_message = {}

mod.send_wheel_message = function (message, cooldown, metadata_string)
	if not mod.is_in_combat() then
		return
	end

	cooldown = cooldown or 15

	if mod.last_wheel_message[message] and os.clock() - mod.last_wheel_message[message] < cooldown then
		return
	end

	-- 元数据标签（如 #need_help）附加在颜色标签里，供队友侧识别（FTE 同款协议）
	local formatted_message = string.format("{#color(79,175,255)} %s {#reset()}{#%s}", message, metadata_string)

	local ok = mod.send_status_message(formatted_message)

	if ok then
		mod.last_wheel_message[message] = os.clock()
	end
end

-- ############ 标记（smart tag，防御） ############

local function trigger_smart_tag(tag_type)
	local hud_element = mod.smart_tagging_instance

	if not hud_element then
		return false
	end

	local ok_ray, raycast_data = pcall(function ()
		local force_update_targets = true

		return hud_element:_find_raycast_targets(force_update_targets)
	end)

	if not (ok_ray and raycast_data and raycast_data.static_hit_position) then
		mod:warning("[status_wheel] smart tag raycast unavailable, tag action skipped")

		return false
	end

	local hit_position = raycast_data.static_hit_position

	pcall(function ()
		hud_element:_trigger_smart_tag(tag_type, nil, Vector3Box.unbox(hit_position))
	end)

	return true
end

-- ############ 语音（防御） ############

local function trigger_voice(voice_event_data)
	if not (voice_event_data and voice_event_data.voice_tag_id) then
		return
	end

	local ok_vo, Vo = pcall(require, "scripts/utilities/vo")

	if not ok_vo then
		return
	end

	local unit = mod.get_local_player_unit()

	if not unit then
		return
	end

	pcall(function ()
		Vo.on_demand_vo_event(unit, voice_event_data.voice_tag_concept, voice_event_data.voice_tag_id)
	end)
end

-- ############ 聊天消息（本地化 key 版，防御） ############

local function send_localized_chat(chat_message_data)
	if not (chat_message_data and chat_message_data.text) then
		return
	end

	local hud_element = mod.smart_tagging_instance

	if not hud_element then
		return
	end

	local channel_tag = chat_message_data.channel

	local ok, channel, channel_handle = pcall(function ()
		return hud_element:_get_chat_channel_by_tag(channel_tag)
	end)

	if ok and channel and channel_handle then
		pcall(function ()
			Managers.chat:send_loc_channel_message(channel_handle, chat_message_data.text, nil)
		end)
	end
end

-- 报告高压：聊天发“高压”告警（独立冷却，复用 send_wheel_message 的按消息冷却）
mod.send_pressure_report = function ()
	if not mod.is_in_combat() then
		return
	end

	mod.send_wheel_message(mod:localize("status_wheel_pressure_msg"), 10, "pressure")
end

-- ############ 选项执行总入口 ############

-- 执行一个轮盘选项（轮盘选中或快捷键共用）
mod.execute_option = function (option)
	if not option then
		return
	end

	local action = option.action

	-- 状态条目：输出大招/手雷/子弹状态
	if action == "ability" or action == "grenade" or action == "ammo" then
		mod.handle_status_command(action)

		return
	end

	-- 求助联动
	if action == "help" then
		mod.need_help(10)

		return
	end

	-- 高压告警
	if action == "pressure" then
		mod.send_pressure_report()

		return
	end

	-- 是/否：聊天反馈（带颜色）
	if action == "yes" or action == "no" then
		mod.send_wheel_message(Localize(option.display_name), 5, action)

		return
	end

	-- 通用动作：标记 / 聊天 / 语音
	if option.tag_type then
		trigger_smart_tag(option.tag_type)
	end

	if option.chat_message_data then
		send_localized_chat(option.chat_message_data)
	end

	trigger_voice(option.voice_event_data)

	-- 遥测（防御）
	pcall(function ()
		Managers.telemetry_reporters:reporter("com_wheel"):register_event(option.voice_event_data.voice_tag_id)
	end)
end

-- 快捷键总入口：战斗状态 + 存活检查
mod.run_option_by_keybind = function (option)
	if not mod.is_in_combat() then
		return
	end

	local unit = mod.get_local_player_unit()

	if not unit then
		return
	end

	mod.execute_option(option)
end
