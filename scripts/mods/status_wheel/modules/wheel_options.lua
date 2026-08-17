-- chunkname: @scripts/mods/status_wheel/modules/wheel_options.lua
--[[
	轮盘选项定义（整合 For The Emperor 的 10 原生增强选项 + 状态轮盘的 3 状态条目）

	选项结构：
		display_name   轮盘显示名（本地化 key，原生 loc 或本 mod 注入）
		icon           图标路径
		action         动作 id：ability / grenade / ammo（状态输出）、help（求助联动）、
		               yes / no（聊天反馈）；nil = 走 tag_type / chat / voice 字段
		tag_type       （可选）触发游戏 smart tag
		chat_message_data = { text = 本地化 key, channel = 频道 }   （可选）发聊天消息
		voice_event_data = { voice_tag_concept, voice_tag_id }      （可选）角色语音
]]

local ChatManagerConstants = require("scripts/foundation/managers/chat/chat_manager_constants")
local VOQueryConstants = require("scripts/settings/dialogue/vo_query_constants")

local ChannelTags = ChatManagerConstants.ChannelTag

local WHEEL_OPTION = table.enum(
	"ammo", "attention", "emperor", "enemy", "health", "help",
	"location", "no", "thanks", "yes", "pressure",
	"ability", "grenade", "ammo_status"
)

local wheel_options = {
	[WHEEL_OPTION.ammo] = {
		display_name = "loc_communication_wheel_display_name_need_ammo",
		icon = "content/ui/materials/hud/communication_wheel/icons/ammo",
		voice_event_data = {
			voice_tag_concept = VOQueryConstants.concepts.on_demand_com_wheel,
			voice_tag_id = VOQueryConstants.trigger_ids.com_wheel_vo_need_ammo,
		},
		chat_message_data = {
			text = "loc_communication_wheel_need_ammo",
			channel = ChannelTags.MISSION,
		},
	},
	[WHEEL_OPTION.attention] = {
		display_name = "loc_communication_wheel_display_name_attention",
		icon = "content/ui/materials/hud/communication_wheel/icons/attention",
		tag_type = "location_attention",
		voice_event_data = {
			voice_tag_concept = VOQueryConstants.concepts.on_demand_com_wheel,
			voice_tag_id = VOQueryConstants.trigger_ids.com_wheel_vo_over_here,
		},
	},
	[WHEEL_OPTION.emperor] = {
		display_name = "loc_for_the_emperor",
		icon = "content/ui/materials/icons/system/escape/achievements",
		voice_event_data = {
			voice_tag_concept = VOQueryConstants.concepts.on_demand_com_wheel,
			voice_tag_id = VOQueryConstants.trigger_ids.com_wheel_vo_for_the_emperor,
		},
	},
	[WHEEL_OPTION.enemy] = {
		display_name = "loc_communication_wheel_display_name_enemy",
		icon = "content/ui/materials/hud/communication_wheel/icons/enemy",
		tag_type = "location_threat",
		voice_event_data = {
			voice_tag_concept = VOQueryConstants.concepts.on_demand_com_wheel,
			voice_tag_id = VOQueryConstants.trigger_ids.com_wheel_vo_enemy_over_here,
		},
	},
	[WHEEL_OPTION.health] = {
		display_name = "loc_communication_wheel_display_name_need_health",
		icon = "content/ui/materials/hud/communication_wheel/icons/health",
		voice_event_data = {
			voice_tag_concept = VOQueryConstants.concepts.on_demand_com_wheel,
			voice_tag_id = VOQueryConstants.trigger_ids.com_wheel_vo_need_health,
		},
		chat_message_data = {
			text = "loc_communication_wheel_need_health",
			channel = ChannelTags.MISSION,
		},
	},
	[WHEEL_OPTION.help] = {
		display_name = "loc_communication_wheel_need_help",
		icon = "content/ui/materials/hud/interactions/icons/help",
		action = "help",
		voice_event_data = {
			voice_tag_concept = VOQueryConstants.concepts.on_demand_com_wheel,
			voice_tag_id = "",
		},
	},
	[WHEEL_OPTION.pressure] = {
		display_name = "status_wheel_pressure",
		icon = "content/ui/materials/hud/communication_wheel/icons/attention",
		action = "pressure",
	},
	[WHEEL_OPTION.location] = {
		display_name = "loc_communication_wheel_display_name_location",
		icon = "content/ui/materials/hud/communication_wheel/icons/location",
		tag_type = "location_ping",
		voice_event_data = {
			voice_tag_concept = VOQueryConstants.concepts.on_demand_com_wheel,
			voice_tag_id = VOQueryConstants.trigger_ids.com_wheel_vo_lets_go_this_way,
		},
	},
	[WHEEL_OPTION.no] = {
		display_name = "loc_social_menu_confirmation_popup_decline_button",
		icon = "content/ui/materials/icons/list_buttons/cross",
		action = "no",
		voice_event_data = {
			voice_tag_concept = VOQueryConstants.concepts.on_demand_com_wheel,
			voice_tag_id = VOQueryConstants.trigger_ids.com_wheel_vo_no,
		},
	},
	[WHEEL_OPTION.thanks] = {
		display_name = "loc_communication_wheel_display_name_thanks",
		icon = "content/ui/materials/hud/communication_wheel/icons/thanks",
		voice_event_data = {
			voice_tag_concept = VOQueryConstants.concepts.on_demand_com_wheel,
			voice_tag_id = VOQueryConstants.trigger_ids.com_wheel_vo_thank_you,
		},
		chat_message_data = {
			text = "loc_communication_wheel_thanks",
			channel = ChannelTags.MISSION,
		},
	},
	[WHEEL_OPTION.yes] = {
		display_name = "loc_social_menu_confirmation_popup_confirm_button",
		icon = "content/ui/materials/icons/list_buttons/check",
		action = "yes",
		voice_event_data = {
			voice_tag_concept = VOQueryConstants.concepts.on_demand_com_wheel,
			voice_tag_id = VOQueryConstants.trigger_ids.com_wheel_vo_yes,
		},
	},

	-- 状态条目（本 mod 原有，action 驱动）
	[WHEEL_OPTION.ability] = {
		display_name = "status_wheel_ability",
		icon = "content/ui/materials/icons/abilities/default",
		action = "ability",
	},
	[WHEEL_OPTION.grenade] = {
		display_name = "status_wheel_grenade",
		icon = "content/ui/materials/icons/abilities/throwables/default",
		action = "grenade",
	},
	[WHEEL_OPTION.ammo_status] = {
		display_name = "status_wheel_ammo",
		icon = "content/ui/materials/hud/communication_wheel/icons/ammo",
		action = "ammo",
	},
}

-- 默认布局（FTE 原生 10 项 + 高压报告 + 状态 3 项 = 14 槽）
local DEFAULT_WHEEL_CONFIG = {
	"thanks", "health", "emperor", "yes", "enemy", "location", "attention", "no", "help", "pressure", "ammo",
	"ability", "grenade", "ammo_status",
}

-- 状态条目的设置开关 id（从 wheel_config 生成选项时过滤）
local ENABLE_SETTING_BY_OPTION = {
	ability = "enable_ability",
	grenade = "enable_grenade",
	ammo = "enable_ammo",
}

return {
	WHEEL_OPTION = WHEEL_OPTION,
	wheel_options = wheel_options,
	DEFAULT_WHEEL_CONFIG = DEFAULT_WHEEL_CONFIG,
	ENABLE_SETTING_BY_OPTION = ENABLE_SETTING_BY_OPTION,
}
