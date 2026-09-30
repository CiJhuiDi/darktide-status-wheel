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

-- 原版看不懂的 action 类选项（状态输出 / 求助 / 高压 / 是否）。
-- 处理了就返回 true，调用方据此决定还要不要走通用动作。
local function run_action_option(option)
	local action = option.action

	-- 状态条目：输出大招/手雷/子弹状态
	if action == "ability" or action == "grenade" or action == "ammo" then
		mod.handle_status_command(action)

		return true
	end

	-- 求助联动
	if action == "help" then
		mod.need_help(10)

		return true
	end

	-- 高压告警
	if action == "pressure" then
		mod.send_pressure_report()

		return true
	end

	-- 是/否：聊天反馈（带颜色）
	if action == "yes" or action == "no" then
		mod.send_wheel_message(Localize(option.display_name), 5, action)

		return true
	end

	return false
end

-- 通用动作：标记 / 聊天 / 语音 / 遥测
local function run_generic_actions(option)
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

-- 快捷键路径：完整执行。
-- 快捷键**不经原版轮盘回调**，tag/chat/voice 必须自己来，
-- 否则原生选项（如「谢谢」）绑了快捷键会直接没反应。
mod.run_option_actions = function (option)
	if not option then
		return
	end

	if not run_action_option(option) then
		run_generic_actions(option)
	end
end

-- 轮盘选中路径：**只做原版不做的部分**。
-- 原版 _on_com_wheel_stop_callback 已经按 option 的 tag_type / chat_message_data /
-- voice_event_data 三个字段执行过了（见 hud_element_smart_tagging.lua L337-377），
-- 这里再走一遍 run_generic_actions 就会让聊天/语音/标记各发两次
-- （2026-09-12 用户实测「谢谢」连发两次）。
mod.execute_option = function (option)
	if not option then
		return
	end

	run_action_option(option)
end

-- 快捷键总入口：战斗状态 + 存活检查 + 选项启用检查（被类/子开关禁用则不触发）
mod.run_option_by_keybind = function (key, option)
	if not mod.is_in_combat() then
		return
	end

	if key and mod.is_option_enabled and not mod.is_option_enabled(key) then
		return
	end

	local unit = mod.get_local_player_unit()

	if not unit then
		return
	end

	mod.run_option_actions(option)
end
