---@diagnostic disable: undefined-global
---@module 'hl'

require("exec")
require("workspaces")

--###############
--## MONITORS ###
--###############

hl.monitor({
	output = "eDP-1",
	mode = "preferred",
	position = "0x0",
	scale = 1,
})

hl.monitor({
	output = "HDMI-A-1",
	mode = "preferred",
	position = "auto",
	scale = 1,
	mirror = "eDP-1",
})

--##################
--## MY PROGRAMS ###
--##################

local terminal = "kitty"
local fileManager = "thunar"
local browser = "firefox"

--############################
--## ENVIRONMENT VARIABLES ###
--############################

hl.env("GDK_BACKEND", "wayland,x11,*")
hl.env("QT_QPA_PLATFORM", "wayland;xcb")
hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_TYPE", "wayland")
hl.env("XDG_SESSION_DESKTOP", "Hyprland")
hl.env("QT_AUTO_SCREEN_SCALE_FACTOR", 1)
hl.env("XCURSOR_THEME", "Bibata-Modern-Classic")
hl.env("XCURSOR_SIZE", 24)
hl.env("QT_QPA_PLATFORMTHEME", "qt5ct")
hl.env("QT_PLATFORMTHEME", "qt6ct")
hl.env("QT_STYLE_OVERRIDE", "kvantum")

--####################
--## LOOK AND FEEL ###
--####################

hl.config({
	general = {
		gaps_in = 4,
		gaps_out = 14,
		border_size = 2,
		--no_border_on_floating = false
		float_gaps = 0,
		gaps_workspaces = 0,
		resize_on_border = false,
		allow_tearing = false,
		layout = "dwindle",
		snap = {
			enabled = false,
		},
		col = {
			active_border = { colors = { "rgba(33ccffee)", "rgba(00ff99ee)" }, angle = 45 },
			inactive_border = "rgba(595959aa)",
		},
	},
})

hl.config({
	decoration = {
		rounding = 7,
		rounding_power = 2,
		-- Change transparency of focused and unfocused windows
		active_opacity = 0.75,
		inactive_opacity = 0.75,
		fullscreen_opacity = 1.0,
		border_part_of_window = true,
		shadow = {
			enabled = true,
			range = 4,
			render_power = 3,
			color = "rgba(1a1a1aee)",
		},
		blur = {
			enabled = true,
			size = 4,
			passes = 2,
			ignore_opacity = true,
			vibrancy = 0.1696,
			noise = 0.0,
			-- 0.0 - 1.0
			contrast = 0.5,
			popups = true,
			input_methods = true,
		},
	},
})

hl.config({
	animations = {
		enabled = true,
	},
})

hl.curve("linear", { type = "bezier", points = { { 0, 0 }, { 1, 1 } } })
hl.curve("md3_standard", { type = "bezier", points = { { 0.2, 0 }, { 0, 1 } } })
hl.curve("md3_decel", { type = "bezier", points = { { 0.05, 0.7 }, { 0.1, 1 } } })
hl.curve("md3_accel", { type = "bezier", points = { { 0.3, 0 }, { 0.8, 0.15 } } })
hl.curve("overshot", { type = "bezier", points = { { 0.05, 0.9 }, { 0.1, 1.1 } } })
hl.curve("crazyshot", { type = "bezier", points = { { 0.1, 1.5 }, { 0.76, 0.92 } } })
hl.curve("hyprnostretch", { type = "bezier", points = { { 0.05, 0.9 }, { 0.1, 1.0 } } })
hl.curve("fluent_decel", { type = "bezier", points = { { 0.1, 1 }, { 0, 1 } } })
hl.curve("easeInOutCirc", { type = "bezier", points = { { 0.85, 0 }, { 0.15, 1 } } })
hl.curve("easeOutCirc", { type = "bezier", points = { { 0, 0.55 }, { 0.45, 1 } } })
hl.curve("easeOutExpo", { type = "bezier", points = { { 0.16, 1 }, { 0.3, 1 } } })

hl.animation({ leaf = "windows", enabled = true, speed = 3, bezier = "md3_decel", style = "popin 60%" })
hl.animation({ leaf = "border", enabled = true, speed = 10, bezier = "linear" })
hl.animation({ leaf = "fade", enabled = true, speed = 2.5, bezier = "md3_decel" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 3.5, bezier = "easeOutExpo", style = "slide" })
hl.animation({ leaf = "specialWorkspace", enabled = true, speed = 3, bezier = "md3_decel", style = "slidevert" })

hl.config({
	dwindle = {
		-- pseudotile = true # Master switch for pseudotiling. Enabling is bound to mainMod + P in the keybinds section below
		preserve_split = true,
		-- You probably want this
	},
})

hl.config({
	master = {
		new_status = "master",
	},
})

--############
--## INPUT ###
--############

hl.config({
	input = {
		kb_layout = "us",
		repeat_rate = 30,
		natural_scroll = false,
		follow_mouse = 1,
		sensitivity = 0.2,
		-- -1.0 - 1.0, 0 means no modification.
		scroll_factor = 1.0,
		touchpad = {
			natural_scroll = true,
			scroll_factor = 0.5,
			disable_while_typing = true,
		},
	},
})

hl.config({
	gestures = {
		workspace_swipe_invert = true,
		workspace_swipe_distance = 700,
	},
})

hl.gesture({
	["fingers"] = 3,
	["direction"] = "horizontal",
	["action"] = "workspace",
})

hl.device({
	name = "epic-mouse-v1",
	sensitivity = -0.5,
})

hl.config({
	misc = {
		force_default_wallpaper = 0,
		-- Set to 0 or 1 to disable the anime mascot wallpapers
		disable_hyprland_logo = true,
		-- If true disables the random hyprland logo / anime girl background. :(
		font_family = "JetBrains Mono",
		animate_manual_resizes = true,
		--new_window_takes_over_fullscreen = 2
		on_focus_under_fullscreen = 2,
	},
})

--##################
--## KEYBINDINGS ###
--##################

local mainMod = "SUPER"
local d = ""

hl.bind(mainMod .. " + " .. "T", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + " .. "Q", hl.dsp.window.close())
hl.bind("ALT" .. " + " .. "F4", hl.dsp.window.close())
hl.bind(mainMod .. " + " .. "E", hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + " .. "F", hl.dsp.exec_cmd(browser))
hl.bind(mainMod .. " + " .. "V", hl.dsp.window.float())
hl.bind("ALT" .. " + " .. "Return", hl.dsp.window.fullscreen())
hl.bind(mainMod .. " + " .. "I", hl.dsp.exec_cmd("sh ~/.config/hypr/scripts/toggle_btop.sh"))
hl.bind(mainMod .. " + " .. "A", hl.dsp.exec_cmd("~/.config/hypr/scripts/toggle_wofi.sh"))
hl.bind("SUPER" .. " + " .. "B", hl.dsp.exec_cmd("sh ~/.config/hypr/scripts/clipboard_menu.sh"))
hl.bind(mainMod .. " + " .. "P", hl.dsp.window.pseudo())
hl.bind(mainMod .. " + " .. "C", hl.dsp.exec_cmd("vscodium"))
hl.bind("SUPER" .. " + " .. "L", hl.dsp.exec_cmd("~/.config/hypr/scripts/lock.sh"))
-- Keybinding for the power menu
hl.bind("SUPER + SHIFT" .. " + " .. "backspace", hl.dsp.exit())
hl.bind("SUPER + CTRL" .. " + " .. "T", hl.dsp.exec_cmd("sh ~/.config/hypr/scripts/theme_selector.sh"))
hl.bind("SUPER + SHIFT" .. " + " .. "V", hl.dsp.exec_cmd("sh ~/.config/hypr/scripts/clipboard_menu.sh"))
hl.bind("SUPER + CTRL" .. " + " .. "backspace", hl.dsp.exec_cmd("sh ~/.config/hypr/scripts/power_menu.sh"))
-- Screenshot a selected region
hl.bind("F11", hl.dsp.exec_cmd("sh ~/.config/hypr/scripts/screenshot.sh --region"))
-- Screenshot the active window
hl.bind("SUPER" .. " + " .. "Print", hl.dsp.exec_cmd("sh ~/.config/hypr/scripts/screenshot.sh --full"))
hl.bind("SUPER + SHIFT" .. " + " .. "C", hl.dsp.exec_cmd("hyprpicker -a"))
-- Screen recording
hl.bind("SUPER" .. " + " .. "R", hl.dsp.exec_cmd("sh ~/.config/hypr/scripts/record.sh full"))
hl.bind("SUPER + SHIFT" .. " + " .. "R", hl.dsp.exec_cmd("sh ~/.config/hypr/scripts/record.sh area"))
hl.bind("SUPER" .. " + " .. "F12", hl.dsp.exec_cmd("/home/Shubham/.config/hypr/scripts/battery-saver-toggle.sh"))
hl.bind("ALT" .. " + " .. "Tab", hl.dsp.window.cycle_next())
-- change focus to another window
hl.bind(mainMod .. " + " .. "left", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + " .. "right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + " .. "up", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + " .. "down", hl.dsp.focus({ direction = "down" }))
-- Switch workspaces with mainMod + [0-9]
hl.bind(mainMod .. " + " .. 1, hl.dsp.focus({ workspace = 1 }))
hl.bind(mainMod .. " + " .. 2, hl.dsp.focus({ workspace = 2 }))
hl.bind(mainMod .. " + " .. 3, hl.dsp.focus({ workspace = 3 }))
hl.bind(mainMod .. " + " .. 4, hl.dsp.focus({ workspace = 4 }))
hl.bind(mainMod .. " + " .. 5, hl.dsp.focus({ workspace = 5 }))
hl.bind(mainMod .. " + " .. 6, hl.dsp.focus({ workspace = 6 }))
hl.bind(mainMod .. " + " .. 7, hl.dsp.focus({ workspace = 7 }))
hl.bind(mainMod .. " + " .. 8, hl.dsp.focus({ workspace = 8 }))
hl.bind(mainMod .. " + " .. 9, hl.dsp.focus({ workspace = 9 }))
hl.bind(mainMod .. " + " .. 0, hl.dsp.focus({ workspace = 10 }))
-- Move active window to a workspace with mainMod + SHIFT + [0-9]
hl.bind(mainMod .. " + " .. "SHIFT" .. " + " .. 1, hl.dsp.window.move({ workspace = 1 }))
hl.bind(mainMod .. " + " .. "SHIFT" .. " + " .. 2, hl.dsp.window.move({ workspace = 2 }))
hl.bind(mainMod .. " + " .. "SHIFT" .. " + " .. 3, hl.dsp.window.move({ workspace = 3 }))
hl.bind(mainMod .. " + " .. "SHIFT" .. " + " .. 4, hl.dsp.window.move({ workspace = 4 }))
hl.bind(mainMod .. " + " .. "SHIFT" .. " + " .. 5, hl.dsp.window.move({ workspace = 5 }))
hl.bind(mainMod .. " + " .. "SHIFT" .. " + " .. 6, hl.dsp.window.move({ workspace = 6 }))
hl.bind(mainMod .. " + " .. "SHIFT" .. " + " .. 7, hl.dsp.window.move({ workspace = 7 }))
hl.bind(mainMod .. " + " .. "SHIFT" .. " + " .. 8, hl.dsp.window.move({ workspace = 8 }))
hl.bind(mainMod .. " + " .. "SHIFT" .. " + " .. 9, hl.dsp.window.move({ workspace = 9 }))
hl.bind(mainMod .. " + " .. "SHIFT" .. " + " .. 0, hl.dsp.window.move({ workspace = 10 }))
-- Example special workspace (scratchpad)
hl.bind(mainMod .. " + " .. "S", hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + " .. "SHIFT" .. " + " .. "S", hl.dsp.window.move({ workspace = "special:magic" }))
-- Scroll through existing workspaces with mainMod + scroll
hl.bind(mainMod .. " + " .. "CTRL" .. " + " .. "LEFT", hl.dsp.focus({ workspace = "r-1" }))
hl.bind(mainMod .. " + " .. "CTRL" .. " + " .. "RIGHT", hl.dsp.focus({ workspace = "r+1" }))
-- Move/resize windows with mainMod + LMB/RMB and dragging
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true, description = d .. " hold to move window" })
hl.bind(
	mainMod .. " + mouse:273",
	hl.dsp.window.resize(),
	{ mouse = true, description = d .. " hold to resize window" }
)
-- Move/Resize focused window
hl.bind(mainMod .. " + Z", hl.dsp.window.drag(), { mouse = true, description = d .. " hold to move window" })
hl.bind(mainMod .. " + X", hl.dsp.window.resize(), { mouse = true, description = d .. " hold to resize window" })

d = "[Window Management|Resize Active Window]"

-- Resize windows
hl.bind(mainMod .. " + " .. "SHIFT" .. " + " .. "Right", hl.dsp.window.resize({ x = 30, y = 0, relative = true }))
hl.bind(mainMod .. " + " .. "SHIFT" .. " + " .. "Left", hl.dsp.window.resize({ x = -30, y = 0, relative = true }))
hl.bind(mainMod .. " + " .. "SHIFT" .. " + " .. "Up", hl.dsp.window.resize({ x = 0, y = -30, relative = true }))
hl.bind(mainMod .. " + " .. "SHIFT" .. " + " .. "Down", hl.dsp.window.resize({ x = 0, y = 30, relative = true }))

-- Move active window around current workspace with mainMod + SHIFT + CTRL [←→↑↓]
d = "[Window Management|Move active window across workspace]"
local moveactivewindow = "grep -q true <<< $(hyprctl activewindow -j | jq -r .floating) && hyprctl dispatch moveactive"

hl.bind(
	mainMod .. " + " .. "SHIFT + CTRL" .. " + " .. "left",
	hl.dsp.exec_cmd(
		"grep -q true <<< $(hyprctl activewindow -j | jq -r .floating) && hyprctl dispatch moveactive -30 0 || hyprctl dispatch movewindow l"
	)
)

hl.bind(
	mainMod .. " + " .. "SHIFT + CTRL" .. " + " .. "right",
	hl.dsp.exec_cmd(
		"grep -q true <<< $(hyprctl activewindow -j | jq -r .floating) && hyprctl dispatch moveactive 30 0 || hyprctl dispatch movewindow r"
	)
)

hl.bind(
	mainMod .. " + " .. "SHIFT + CTRL" .. " + " .. "up",
	hl.dsp.exec_cmd(
		"grep -q true <<< $(hyprctl activewindow -j | jq -r .floating) && hyprctl dispatch moveactive 0 -30 || hyprctl dispatch movewindow u"
	)
)

hl.bind(
	mainMod .. " + " .. "SHIFT + CTRL" .. " + " .. "down",
	hl.dsp.exec_cmd(
		"grep -q true <<< $(hyprctl activewindow -j | jq -r .floating) && hyprctl dispatch moveactive 0 30 || hyprctl dispatch movewindow d"
	)
)

-- Laptop multimedia keys for volume and LCD brightness

-- Volume
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("sh ~/.config/hypr/scripts/osd.sh volume up"))
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("sh ~/.config/hypr/scripts/osd.sh volume down"))
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("sh ~/.config/hypr/scripts/osd.sh volume mute"))

-- Brightness
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("sh ~/.config/hypr/scripts/osd.sh brightness up"))
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("sh ~/.config/hypr/scripts/osd.sh brightness down"))

-- Requires playerctl
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })

--#############################
--## WINDOWS AND WORKSPACES ###
--#############################

-- Global suppression rule
hl.window_rule({
	match = {
		class = ".*",
	},
	suppress_event = "maximize",
})

-- Opacity for nm-applet (using the 'override' syntax from the wiki example)
hl.window_rule({
	match = {
		class = "^(nm-applet)$",
	},
	opacity = "0.80 override 0.70 override 1.0 override",
})

-- nm-connection-editor
hl.window_rule({
	match = {
		class = "^(nm-connection-editor)$",
	},
	float = true,
	size = { "750", "460" },
	center = true,
})

-- PulseAudio Volume Control
hl.window_rule({
	match = {
		class = "^(org.pulseaudio.pavucontrol)$",
	},
	float = true,
	size = { "750", "460" },
	center = true,
})

-- Bluetooth Manager
hl.window_rule({
	match = {
		class = "^(blueman-manager)$",
	},
	float = true,
	size = { "750", "460" },
	center = true,
})

-- Wofi
hl.window_rule({
	match = {
		class = "^(wofi)$",
	},
	rounding = 15,
	no_shadow = true,
})

-- File Roller (Archive Manager)
hl.window_rule({
	match = {
		class = "^(org.gnome.FileRoller)$",
	},
	float = true,
	size = { "750", "460" },
	center = true,
})

-- YouTube Music
hl.window_rule({
	match = {
		title = "^(music.youtube.com_/$)",
	},
	tile = true,
})

hl.layer_rule({
	match = {
		namespace = "wofi",
	},
	blur = true,
})

hl.layer_rule({
	match = {
		namespace = "notifications",
	},
	blur = true,
})

hl.layer_rule({
	match = {
		namespace = "notifications",
	},
	ignore_alpha = 1,
})

--! unset the group name
d = " "
