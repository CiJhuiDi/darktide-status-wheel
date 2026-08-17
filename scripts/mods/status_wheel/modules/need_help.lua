-- chunkname: @scripts/mods/status_wheel/modules/need_help.lua
--[[
	求助联动（整合 For The Emperor 的 need_help 模块，防御式适配）

	- 本地方向：选「帮助」→ 播角色求救语音 + 聊天发消息（带 #need_help 协议标记）+ 冷却
	- 队友方向：hook VivoxManager 收到 #need_help 消息 → 帮队友播语音 + 队友头顶生成 10 秒求助标记

	原版 FTE 直读私有字段（Managers.chat._sessions / Managers.player._players_by_peer），
	本整合版全部换成公开 API（sessions() / players_at_peer()）；
	VivoxManager 用 DMF 字符串 hook（类未定义时自动延迟，class() 定义时挂上，安全）。
]]

local mod = get_mod("status_wheel")

local memoised_vo_settings = mod:persistent_table("memoised_vo_settings")

mod.help_markers = {}

-- 播求救语音（自己或队友）
mod.vo_call_for_help = function (player_needing_help)
	if not (player_needing_help and player_needing_help._profile and player_needing_help._profile.selected_voice) then
		return
	end

	local vo_settings_path = "dialogues/generated/gameplay_vo_" .. player_needing_help._profile.selected_voice

	local vo_settings = memoised_vo_settings[vo_settings_path]

	if not vo_settings then
		local ok, settings = pcall(require, vo_settings_path)

		if not (ok and settings and settings.calling_for_help and settings.calling_for_help.sound_events) then
			return
		end

		vo_settings = settings
		memoised_vo_settings[vo_settings_path] = vo_settings
	end

	local vo_sound_events = vo_settings.calling_for_help.sound_events
	local vo_sound_from_pool = vo_sound_events[math.random(#vo_sound_events)]
	local vo_file_path = "wwise/externals/" .. vo_sound_from_pool

	local ok_local, local_player = pcall(function ()
		return Managers.player:local_player(1)
	end)

	if not (ok_local and local_player) then
		return
	end

	local ok_world, world = pcall(function ()
		return Managers.world:world("level_world")
	end)

	if not ok_world then
		return
	end

	local ok_wwise, wwise_world = pcall(function ()
		return Managers.world:wwise_world(world)
	end)

	if not ok_wwise then
		return
	end

	if player_needing_help ~= local_player then
		pcall(function ()
			Managers.ui:play_2d_sound("wwise/events/ui/play_hud_objective_part_done")

			wwise_world:trigger_resource_external_event(
				"wwise/events/vo/play_sfx_es_player_vo",
				"es_vo_prio_1",
				vo_file_path,
				4,
				wwise_world:make_auto_source(player_needing_help.player_unit, 1)
			)
		end)
	else
		pcall(function ()
			wwise_world:trigger_resource_external_event(
				"wwise/events/vo/play_sfx_es_player_vo_2d",
				"es_player_vo_2d",
				vo_file_path,
				4,
				wwise_world:make_auto_source(local_player.player_unit, 1)
			)
		end)
	end
end

-- 本地方向求助：语音 + 聊天（#need_help 协议）+ 冷却
mod.need_help = function (cooldown)
	if mod.last_need_help and os.clock() - mod.last_need_help < cooldown then
		return
	end

	local ok, local_player = pcall(function ()
		return Managers.player:local_player(1)
	end)

	if ok and local_player then
		mod.vo_call_for_help(local_player)
	end

	mod.send_wheel_message(mod:localize("need_help"), cooldown, "need_help")

	mod.last_need_help = os.clock()
end

-- 队友求助响应：收到 #need_help → 帮队友播语音 + 头顶求助标记（10 秒）
mod:hook_safe("VivoxManager", "_handle_event", function (self, message)
	if not (message and message.message_body and not message.is_current_user) then
		return
	end

	if not string.find(message.message_body, "#need_help") then
		return
	end

	if mod:get("ignore_help") then
		return
	end

	local session_handle = message.session_handle
	local participant_uri = message.participant_uri

	-- 公开 API 替代 FTE 的 Managers.chat._sessions
	local sender

	pcall(function ()
		local sessions = Managers.chat:sessions()
		local session = sessions[session_handle]

		sender = session and session.participants and session.participants[participant_uri]
	end)

	if not (sender and sender.peer_id) then
		return
	end

	-- 公开 API 替代 FTE 的 Managers.player._players_by_peer
	local player_needing_help

	pcall(function ()
		player_needing_help = Managers.player:players_at_peer(sender.peer_id)[1]
	end)

	if not player_needing_help then
		return
	end

	mod.vo_call_for_help(player_needing_help)

	if mod.help_markers[sender.peer_id] then
		Managers.event:trigger("remove_world_marker", mod.help_markers[sender.peer_id].marker_id)
	end

	local callback = function (marker_id)
		mod.help_markers[sender.peer_id] = {
			marker_id = marker_id,
			time = os.clock(),
		}
	end

	pcall(function ()
		Managers.event:trigger(
			"add_world_marker_unit",
			"player_assistance",
			player_needing_help.player_unit,
			callback,
			{
				player = player_needing_help,
			}
		)
	end)
end)

-- 供主文件 update 调用：清理过期标记
mod.update_help_markers = function ()
	for peer_id, marker in pairs(mod.help_markers) do
		if os.clock() - marker.time > 10 then
			Managers.event:trigger("remove_world_marker", marker.marker_id)

			mod.help_markers[peer_id] = nil
		end
	end
end
