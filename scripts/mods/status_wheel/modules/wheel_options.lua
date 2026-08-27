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
		enable_setting = "enable_option_ammo",
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
		enable_setting = "enable_option_attention",
		tag_type = "location_attention",
		voice_event_data = {
			voice_tag_concept = VOQueryConstants.concepts.on_demand_com_wheel,
			voice_tag_id = VOQueryConstants.trigger_ids.com_wheel_vo_over_here,
		},
	},
	[WHEEL_OPTION.emperor] = {
		display_name = "loc_for_the_emperor",
		icon = "content/ui/materials/icons/system/escape/achievements",
		enable_setting = "enable_option_emperor",
		voice_event_data = {
			voice_tag_concept = VOQueryConstants.concepts.on_demand_com_wheel,
			voice_tag_id = VOQueryConstants.trigger_ids.com_wheel_vo_for_the_emperor,
		},
	},
	[WHEEL_OPTION.enemy] = {
		display_name = "loc_communication_wheel_display_name_enemy",
		icon = "content/ui/materials/hud/communication_wheel/icons/enemy",
		enable_setting = "enable_option_enemy",
		tag_type = "location_threat",
		voice_event_data = {
			voice_tag_concept = VOQueryConstants.concepts.on_demand_com_wheel,
			voice_tag_id = VOQueryConstants.trigger_ids.com_wheel_vo_enemy_over_here,
		},
	},
	[WHEEL_OPTION.health] = {
		display_name = "loc_communication_wheel_display_name_need_health",
		icon = "content/ui/materials/hud/communication_wheel/icons/health",
		enable_setting = "enable_option_health",
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
		enable_setting = "enable_option_help",
		action = "help",
		voice_event_data = {
			voice_tag_concept = VOQueryConstants.concepts.on_demand_com_wheel,
			voice_tag_id = "",
		},
	},
	[WHEEL_OPTION.pressure] = {
		display_name = "status_wheel_pressure",
		icon = "content/ui/materials/hud/communication_wheel/icons/attention",
		enable_setting = "enable_pressure",
		action = "pressure",
		-- 原生轮盘回调会访问 voice_event_data.voice_tag_id（遥测），必须带（空 trigger 不发声）
		voice_event_data = {
			voice_tag_concept = VOQueryConstants.concepts.on_demand_com_wheel,
			voice_tag_id = "",
		},
	},
	[WHEEL_OPTION.location] = {
		display_name = "loc_communication_wheel_display_name_location",
		icon = "content/ui/materials/hud/communication_wheel/icons/location",
		enable_setting = "enable_option_location",
		tag_type = "location_ping",
		voice_event_data = {
			voice_tag_concept = VOQueryConstants.concepts.on_demand_com_wheel,
			voice_tag_id = VOQueryConstants.trigger_ids.com_wheel_vo_lets_go_this_way,
		},
	},
	[WHEEL_OPTION.no] = {
		display_name = "loc_social_menu_confirmation_popup_decline_button",
		icon = "content/ui/materials/icons/list_buttons/cross",
		enable_setting = "enable_option_no",
		action = "no",
		voice_event_data = {
			voice_tag_concept = VOQueryConstants.concepts.on_demand_com_wheel,
			voice_tag_id = VOQueryConstants.trigger_ids.com_wheel_vo_no,
		},
	},
	[WHEEL_OPTION.thanks] = {
		display_name = "loc_communication_wheel_display_name_thanks",
		icon = "content/ui/materials/hud/communication_wheel/icons/thanks",
		enable_setting = "enable_option_thanks",
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
		enable_setting = "enable_option_yes",
		action = "yes",
		voice_event_data = {
			voice_tag_concept = VOQueryConstants.concepts.on_demand_com_wheel,
			voice_tag_id = VOQueryConstants.trigger_ids.com_wheel_vo_yes,
		},
	},

	-- 状态条目（本 mod 原有，action 驱动）
	-- 注意：原生轮盘回调会访问 voice_event_data.voice_tag_id（遥测），必须带（空 trigger 不发声）
	[WHEEL_OPTION.ability] = {
		display_name = "status_wheel_ability",
		icon = "content/ui/materials/icons/abilities/default",
		enable_setting = "enable_ability",
		action = "ability",
		voice_event_data = {
			voice_tag_concept = VOQueryConstants.concepts.on_demand_com_wheel,
			voice_tag_id = "",
		},
	},
	[WHEEL_OPTION.grenade] = {
		display_name = "status_wheel_grenade",
		icon = "content/ui/materials/icons/abilities/throwables/default",
		enable_setting = "enable_grenade",
		action = "grenade",
		voice_event_data = {
			voice_tag_concept = VOQueryConstants.concepts.on_demand_com_wheel,
			voice_tag_id = "",
		},
	},
	[WHEEL_OPTION.ammo_status] = {
		display_name = "status_wheel_ammo",
		icon = "content/ui/materials/hud/communication_wheel/icons/ammo",
		enable_setting = "enable_ammo",
		action = "ammo",
		voice_event_data = {
			voice_tag_concept = VOQueryConstants.concepts.on_demand_com_wheel,
			voice_tag_id = "",
		},
	},
}

-- 默认布局（FTE 原生 10 项 + 高压报告 + 状态 3 项 = 14 槽）
local DEFAULT_WHEEL_CONFIG = {
	"thanks", "health", "emperor", "yes", "enemy", "location", "attention", "no", "help", "pressure", "ammo",
	"ability", "grenade", "ammo_status",
}

-- 选项分类（轮盘选项按类分组，每类一个总开关）：
--   native = 原版轮盘 7 项（emperor 对应原版 cheer）/ enhanced = FTE 新增 3 项 /
--   status = 本 mod 新增状态 4 项（大招/手雷/子弹/报告高压）
local OPTION_SECTION = {
	-- 原版轮盘就有（增强版定义，带语音/聊天/标记）
	ammo = "native", attention = "native", emperor = "native",
	enemy = "native", health = "native", location = "native", thanks = "native",
	-- FTE 新增
	help = "enhanced", no = "enhanced", yes = "enhanced",
	-- 本 mod 新增状态（含报告高压）
	ability = "status", grenade = "status", ammo_status = "status", pressure = "status",
}

-- 类总开关设置 id：关闭后整个类的选项不出现在轮盘上（快捷键同步失效）
local SECTION_ENABLE_SETTING = {
	native = "enable_native",
	enhanced = "enable_enhanced",
	status = "enable_status",
}

return {
	WHEEL_OPTION = WHEEL_OPTION,
	wheel_options = wheel_options,
	DEFAULT_WHEEL_CONFIG = DEFAULT_WHEEL_CONFIG,
	OPTION_SECTION = OPTION_SECTION,
	SECTION_ENABLE_SETTING = SECTION_ENABLE_SETTING,
}
