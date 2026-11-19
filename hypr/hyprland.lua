
-- ── Storm Mono · hyprland.lua ────────────────────────────────────

local accent = "rgb(ffffff)"
local accent_hi = "rgb(cfcfcf)"
local bg_base = "rgb(0a0a0a)"
local surface = "rgba(1a1a1a80)"
local border = "rgb(444444)"
local red = "rgb(ffffff)"
local green = "rgb(c8c8c8)"

local mod = "ALT"

-- ── Environment ──────────────────────────────────────────────────

hl.env("QT_QPA_PLATFORMTHEME", "qt6ct")

-- ── Monitors ─────────────────────────────────────────────────────

hl.monitor({
    output = "DP-1",
    mode = "1920x1080@120",
    position = "0x0",
    scale = "1",
})

hl.monitor({
    output = "HDMI-A-1",
    mode = "1920x1080@65",
    position = "1920x0",
    scale = "1",
})

hl.monitor({
    output = "eDP-1",
    mode = "1920x1080@60",
    position = "0x1080",
    scale = "1",
})

-- ── Workspaces ──────────────────────────────────────────────────

for i = 1, 9 do
    hl.workspace_rule({
        workspace = tostring(i),
        monitor = "DP-1",
        default = i == 1,
    })

    hl.workspace_rule({
        workspace = tostring(10 + i),
        monitor = "HDMI-A-1",
        default = i == 1,
    })

    hl.workspace_rule({
        workspace = tostring(20 + i),
        monitor = "eDP-1",
        default = i == 1,
    })
end

-- ── Animations ──────────────────────────────────────────────────

hl.curve("lightning", {
    type = "bezier",
    points = {
        { 0.05, 0.9 },
        { 0.1, 1.05 },
    },
})

hl.curve("smooth", {
    type = "bezier",
    points = {
        { 0.25, 0.46 },
        { 0.45, 0.94 },
    },
})

hl.curve("snappy", {
    type = "bezier",
    points = {
        { 0.4, 0.0 },
        { 0.2, 1.0 },
    },
})

-- Окна: открытие — пружина с лёгким «отскоком», закрытие — быстрый
-- ease-in со сжатием и затуханием, перемещение/ресайз — пружина
hl.curve("pop", { type = "spring", mass = 1, stiffness = 260, damping = 21 })
hl.curve("glide", { type = "spring", mass = 1, stiffness = 238, damping = 26 })
hl.curve("easeOutQuint", { type = "bezier", points = { { 0.23, 1 }, { 0.32, 1 } } })
hl.curve("easeInCubic", { type = "bezier", points = { { 0.32, 0 }, { 0.67, 0 } } })

hl.animation({ leaf = "windows",    enabled = true, speed = 4.8, spring = "glide" })
hl.animation({ leaf = "windowsMove", enabled = true, speed = 4.8, spring = "glide" })
-- открытие как на маке: окно вырастает из маленького, быстро и без отскока (кривая macOS «zoom»)
hl.curve("macOpen",  { type = "bezier", points = { { 0.16, 1 }, { 0.3, 1 } } })
hl.curve("macClose", { type = "bezier", points = { { 0.4, 0 }, { 0.9, 0.5 } } })
hl.animation({ leaf = "windowsIn",  enabled = true, speed = 3.6, bezier = "macOpen", style = "popin 12%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 2.0, bezier = "macClose", style = "popin 80%" })
hl.animation({ leaf = "fadeIn",     enabled = true, speed = 2.8, bezier = "macOpen" })
hl.animation({ leaf = "fadeOut",    enabled = true, speed = 2.0, bezier = "easeInCubic" })


hl.animation({
    leaf = "border",
    enabled = true,
    speed = 8,
    bezier = "snappy",
})

hl.animation({
    leaf = "borderangle",
    enabled = true,
    speed = 60,
    bezier = "snappy",
    style = "loop",
})

hl.animation({
    leaf = "fade",
    enabled = true,
    speed = 5,
    bezier = "smooth",
})

hl.animation({
    leaf = "workspaces",
    enabled = true,
    speed = 5,
    bezier = "lightning",
    style = "slidevert",
})

-- ── Application binds ────────────────────────────────────────────

hl.bind("ALT + T", hl.dsp.exec_cmd("kitty --start-as=normal"))
hl.bind(mod .. " + Q", hl.dsp.window.close())
hl.bind(mod .. " + SHIFT + Q", hl.dsp.exit())

-- лаунчер: Spotlight MacShell (раньше rofi). mod = ALT, Super+Space — тоже Spotlight (macshell.lua)
-- hl.bind(mod .. " + Space", hl.dsp.exec_cmd("rofi -show drun"))
hl.bind(mod .. " + R", hl.dsp.exec_cmd("qs -c MacShell ipc call spotlight toggle"))

hl.bind(mod .. " + F", hl.dsp.window.fullscreen({
    mode = "fullscreen",
    action = "toggle",
}))

hl.bind(mod .. " + P", hl.dsp.window.pseudo())

hl.bind(mod .. " + b", hl.dsp.exec_cmd("firefox"))
hl.bind(mod .. " + C", hl.dsp.exec_cmd("kitty -e claude"))

-- плавающее ↔ плитка: текущее окно
hl.bind(mod .. " + W", hl.dsp.window.float({
    action = "toggle",
}))

-- все окна рабочего стола: плавающие ↔ плитка
hl.bind(mod .. " + SHIFT + W",
    hl.dsp.exec_cmd("~/.config/hypr/scripts/float-all.sh"))

hl.bind(mod .. " + E", hl.dsp.exec_cmd("nautilus --new-window"))
hl.bind(mod .. " + SHIFT + E", hl.dsp.exec_cmd("kitty -e yazi"))

hl.bind(mod .. " + M", hl.dsp.exec_cmd("Telegram"))
hl.bind(mod .. " + D", hl.dsp.exec_cmd("discord"))
hl.bind(mod .. " + O", hl.dsp.exec_cmd("obsidian"))
hl.bind(mod .. " + I", hl.dsp.exec_cmd("code"))

hl.bind(mod .. " + SHIFT + B",
    hl.dsp.exec_cmd("google-chrome-stable"))

hl.bind(mod .. " + Escape", hl.dsp.exec_cmd("missioncenter"))
hl.bind(mod .. " + A", hl.dsp.exec_cmd("pavucontrol"))
hl.bind(mod .. " + V", hl.dsp.exec_cmd("happ"))
hl.bind(mod .. " + N", hl.dsp.exec_cmd("kitty -e nvim"))

-- quicknote: временная заметка, ничего не сохраняет (Alt+Z — открыть/закрыть)
hl.bind("ALT + Z", hl.dsp.exec_cmd("~/.local/bin/quicknote"))
hl.window_rule({
    name   = "quicknote-float",
    match  = { class = "^(dev\\.local\\.quicknote)$" },
    float  = true,
    size   = "460 340",
    move   = "(cursor_x-(window_w*0.5)) (cursor_y-(window_h*0.5))",
})

-- ── Focus movement ──────────────────────────────────────────────

hl.bind(mod .. " + H", hl.dsp.focus({ direction = "left" }))
hl.bind(mod .. " + L", hl.dsp.focus({ direction = "right" }))
hl.bind(mod .. " + K", hl.dsp.focus({ direction = "up" }))
hl.bind(mod .. " + J", hl.dsp.focus({ direction = "down" }))

-- ── Mouse ────────────────────────────────────────────────────────

hl.bind(mod .. " + mouse:272",
    hl.dsp.window.drag(),
    { mouse = true })

hl.bind(mod .. " + mouse:273",
    hl.dsp.window.resize(),
    { mouse = true })

-- ── Workspace management ────────────────────────────────────────

-- Monitor mapping:
-- DP-1     = 1-9
-- HDMI-A-1 = 11-19
-- eDP-1    = 21-29

local function get_workspace_id(n)
    local monitor = hl.get_active_monitor()

    if not monitor then
        return n
    end

    local name = monitor.name

    if name == "DP-1" then
        return n
    elseif name == "HDMI-A-1" then
        return 10 + n
    elseif name == "eDP-1" then
        return 20 + n
    end

    return n
end

local function switch_workspace(n)
    local target = get_workspace_id(n)

    hl.dispatch(hl.dsp.focus({
        workspace = target,
    }))
end

local function move_to_workspace(n)
    local target = get_workspace_id(n)

    hl.dispatch(hl.dsp.window.move({
        workspace = target,
    }))
end

-- Keyboard numbers

for i = 1, 9 do
    local n = i
    local key = tostring(n)

    hl.bind(mod .. " + " .. key, function()
        switch_workspace(n)
    end)

    hl.bind(mod .. " + SHIFT + " .. key, function()
        move_to_workspace(n)
    end)
end

-- Numpad with NumLock enabled

for i = 1, 9 do
    local n = i
    local key = "KP_" .. tostring(n)

    hl.bind(key, function()
        switch_workspace(n)
    end)
end

-- Numpad with NumLock disabled

local numpad_keys = {
    KP_End = 1,
    KP_Down = 2,
    KP_Next = 3,
    KP_Left = 4,
    KP_Begin = 5,
    KP_Right = 6,
    KP_Home = 7,
    KP_Up = 8,
    KP_Prior = 9,
}

for key, n in pairs(numpad_keys) do
    hl.bind(key, function()
        switch_workspace(n)
    end)
end

-- ── Touchpad gestures ───────────────────────────────────────────

-- Свайп тремя пальцами вверх/вниз — переключение воркспейсов
hl.gesture({
    fingers = 3,
    direction = "vertical",
    action = "workspace",
})

-- ALT + свайп тремя пальцами — перенести текущее окно на соседний
-- воркспейс (в пределах диапазона текущего монитора) и перейти за ним
local function move_window_relative(delta)
    if not hl.get_active_window() then
        return
    end

    local monitor = hl.get_active_monitor()
    local ws = monitor and monitor.active_workspace
    if not ws or not ws.id then
        return
    end

    local base = get_workspace_id(1) - 1
    local n = ws.id - base + delta
    if n < 1 or n > 9 then
        return
    end

    hl.dispatch(hl.dsp.window.move({
        workspace = base + n,
    }))
end

hl.gesture({
    fingers = 3,
    direction = "up",
    mods = "ALT",
    action = function() move_window_relative(1) end,
})

hl.gesture({
    fingers = 3,
    direction = "down",
    mods = "ALT",
    action = function() move_window_relative(-1) end,
})

-- ── Screenshots ─────────────────────────────────────────────────

-- [MacShell] Print теперь скриншот MacShell
-- hl.bind("Print", hl.dsp.exec_cmd("grimblast copy area"))
-- редактор Satty всплывает по центру поверх окон, а не встаёт плиткой
hl.window_rule({
    name   = "satty-float",
    match  = { class = "^(com\\.gabm\\.satty)$" },
    float  = true,
    center = true,
    size   = "80% 80%",
})

-- shot: grimblast снимает, Satty редактирует (~/.local/bin/shot)
hl.bind("Print",                hl.dsp.exec_cmd("~/.local/bin/shot area"))     -- область → редактор
hl.bind(mod .. " + SHIFT + S",  hl.dsp.exec_cmd("~/.local/bin/shot area"))     -- то же, если нет клавиши Print
hl.bind("SHIFT + Print",        hl.dsp.exec_cmd("~/.local/bin/shot window"))   -- активное окно → редактор
hl.bind(mod .. " + Print",      hl.dsp.exec_cmd("~/.local/bin/shot screen"))   -- весь экран → редактор
hl.bind("CTRL + Print",         hl.dsp.exec_cmd("~/.local/bin/shot quick"))    -- область сразу в буфер и файл

-- ── Volume ──────────────────────────────────────────────────────

hl.bind(
    "XF86AudioRaiseVolume",
    hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"),
    { locked = true, repeating = true }
)

hl.bind(
    "XF86AudioLowerVolume",
    hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),
    { locked = true, repeating = true }
)

hl.bind(
    "XF86AudioMute",
    hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle")
)

-- ── Brightness ──────────────────────────────────────────────────

hl.bind(
    "XF86MonBrightnessUp",
    hl.dsp.exec_cmd("brightnessctl set 5%+"),
    { locked = true, repeating = true }
)

hl.bind(
    "XF86MonBrightnessDown",
    hl.dsp.exec_cmd("brightnessctl set 5%-"),
    { locked = true, repeating = true }
)

-- ── Configuration ───────────────────────────────────────────────

hl.config({
    input = {
        kb_layout = "us,ru",
        kb_options = "grp:alt_shift_toggle",
        follow_mouse = 1,
        sensitivity = 0,

        touchpad = {
            natural_scroll = true,
        },
    },

    general = {
        gaps_in = 5,
        gaps_out = 12,
        border_size = 2,

        col = {
            active_border = {
                colors = {
                    "rgb(8a8a8a)",
                    "rgb(555555)",
                },
                angle = 45,
            },

            inactive_border = border,
        },

        layout = "dwindle",
        resize_on_border = true,
    },

    decoration = {
        rounding = 12,
        active_opacity = 0.92,
        inactive_opacity = 0.80,
        fullscreen_opacity = 1.0,

        blur = {
            enabled = true,
            size = 4,
            passes = 2,
            new_optimizations = true,
            xray = false,
            noise = 0.012,
            contrast = 0.9,
            brightness = 1.0,
            vibrancy = 0.2,
            vibrancy_darkness = 0.0,
        },
    },

    animations = {
        enabled = true,
    },

    dwindle = {
        preserve_split = true,
        -- новое окно всегда справа, а не там, где курсор
        smart_split = false,
        force_split = 2,
        -- делить колонками, даже если плитка выше, чем шире (1.5 → вертикально только совсем узкие)
        split_width_multiplier = 1.5,
    },

    misc = {
        force_default_wallpaper = 0,
        disable_hyprland_logo = true,
        -- под экраном блокировки рисовать рабочий стол, а не чёрное: MacLock проявляется поверх обоев,
        -- без провала в чёрный (при загрузке под ним заставка с теми же обоями)
        session_lock_xray = true,
    },
})

-- ── Dock (hyprland-macos-dock) ───────────────────────────────────

hl.layer_rule({
    name  = "dock-glass",
    match = { namespace = "^(hyprland-dock)$" },
    blur  = true,
    ignore_alpha = 0.02,
    no_anim = true,
})

-- ── Виджет «Система» (~/.config/quickshell/SysMonitor) ─────────
hl.layer_rule({
    name  = "syswidget-glass",
    match = { namespace = "^(syswidget)$" },
    blur  = true,
    ignore_alpha = 0.05,
})

-- ── Экран загрузки: появляется сразу, без анимации Hyprland ───────
hl.layer_rule({
    name  = "splash-noanim",
    match = { namespace = "^(splash)$" },
    no_anim = true,
})

-- ── Autostart ────────────────────────────────────────────────────

hl.on("hyprland.start", function()
    -- экран загрузки первым: закрывает всё, пока не поднимется MacShell (~/.config/quickshell/Splash)
    hl.exec_cmd("qs -c Splash")
    -- автовход (greetd initial_session выставляет MACSHELL_AUTOLOCK=1): сразу экран блокировки MacLock,
    -- после пароля он растворяется в рабочий стол — без перезапуска Hyprland и чёрного промига
    hl.exec_cmd("~/.local/bin/macshell-autolock")

    hl.exec_cmd(
        "systemctl --user start wireplumber pipewire pipewire-pulse"
    )

    hl.exec_cmd(
        "pactl set-default-sink alsa_output.pci-0000_03_00.6.analog-stereo"
    )

    -- [MacShell] обои теперь через awww: hyprpaper --config ~/.config/hypr/hyprpaper.conf

    -- [MacShell] hl.exec_cmd("~/.config/hypr/set-wallpaper.sh")
    -- [MacShell] hl.exec_cmd("waybar")
    -- [MacShell] hl.exec_cmd("~/.config/waybar/scripts/sidebar.sh init")
    -- [MacShell] hl.exec_cmd("dunst")
    -- [MacShell] hl.exec_cmd("~/.local/bin/hyprland-dock --daemonize")
    -- [MacShell] виджет «Система» теперь внутри MacShell (тип system): hl.exec_cmd("qs -c SysMonitor -d")
    hl.exec_cmd("hypridle")   -- блокировка через 15 мин бездействия (hypridle.conf)

    hl.exec_cmd(
        "wl-paste --type text --watch cliphist store"
    )

    hl.exec_cmd(
        "wl-paste --type image --watch cliphist store"
    )

    hl.exec_cmd("wayvnc")

    hl.exec_cmd(
        "dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP=Hyprland"
    )

    hl.exec_cmd(
        "systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
    )
end)


-- >>> MacShell (added by install.sh) >>>
-- Load the generated MacShell autostart and keybind module.
require("macshell")
-- Liquid Glass: blur behind the shell surfaces
hl.layer_rule({ name = "macdock",  match = { namespace = "macdock"  }, blur = true, ignore_alpha = 0.2,  no_anim = true })
hl.layer_rule({ name = "macspot",  match = { namespace = "macspot"  }, blur = true, ignore_alpha = 0.05, no_anim = true })
hl.layer_rule({ name = "macbarbg", match = { namespace = "macbarbg" }, blur = true, ignore_alpha = 0.05, no_anim = true })
hl.layer_rule({ name = "macshot",  match = { namespace = "macshot"  }, no_anim = true })
-- <<< MacShell <<<
