return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`status_wheel` encountered an error loading the Darktide Mod Framework.")

		new_mod("status_wheel", {
			mod_script       = "status_wheel/scripts/mods/status_wheel/status_wheel",
			mod_data         = "status_wheel/scripts/mods/status_wheel/status_wheel_data",
			mod_localization = "status_wheel/scripts/mods/status_wheel/status_wheel_localization",
		})
	end,
	packages = {},
	version = "2.0.0",
}
