-- Color Shading v2.0
-- Aseprite Script that opens a dynamic palette picker window with relevant color shading options
-- Written by Dominick John, twitter @dominickjohn
-- Contributed to by David Capello
-- Expanded and changed by Chaonic
-- https://github.com/ChaonicTheDeathKitten/aseprite/
-- Instructions:
--    Place this file into the Aseprite scripts folder (File -> Scripts -> Open Scripts Folder)
--    Run the "Color Shading" script (File -> Scripts -> Color Shading) to open the palette window.
-- Commands:
--    Base: Clicking on either base color will switch the shading palette to that saved color base.
--    "Get" Button: Updates base colors using the current foreground and background color and regenerates shading.
--    Left click: Set clicked color as foreground color.
--    Right click: Set clicked color as background color.
--    Middle click: Set clicked color as foreground color and regenerate all shades based on this new color.
local dlg;
local helpDlg = Dialog("帮助")
    :label { text = "Color Shading++ 简易教程          by 流浪鬼" }
    :separator()
    :label { text = "点击get按钮，将会以当前画布的前景色进行生成。" }
    :newrow()
    :label { text = "如果开启autoPick模式，当更改前景色时将会" }
    :newrow()
    :label { text = "自动更新颜色。" }
    :newrow()
    :label { text = "基本使用:" }
    :newrow()
    :label { text = "   鼠标左键：吸取颜色到前景色" }
    :newrow()
    :label { text = "   鼠标中键：以当前颜色为基色更新" }
    :newrow()
    :label { text = "   鼠标右键：吸取颜色到背景色" }


local autoPick = true;
local fgListenerCode;
local bgListenerCode;
local eyeDropper = true;

local FGcache;
local BGcache;

local SH1
local SH2
local SH3
local SH4
local SH5
local SH6
local SH8
local SH9
local SH10
local SH11
local SH12
local SH13
local SHF1
local SHF2
local SHF3
local SHF4
local SHF5
local SHF6
local SHF8
local SHF9
local SHF1
local SHF1
local SHF1
local SHF1
local SK1
local SK2
local SK3
local SK4
local SK5
local SK6
local SK8
local SK9
local SK10
local SK11
local SK12
local SK13
local LI1
local LI2
local LI3
local LI4
local LI5
local LI6
local LI8
local LI9
local LI10
local LI11
local LI12
local LI13
local LS1
local LS2
local LS3
local LS4
local LS5
local LS6
local LS8
local LS9
local LS10
local LS11
local LS12
local LS13
local SA1
local SA2
local SA3
local SA4
local SA5
local SA6
local SA8
local SA9
local SA10
local SA11
local SA12
local SA13
local SF1
local SF2
local SF3
local SF4
local SF5
local SF6
local SF8
local SF9
local SF10
local SF11
local SF12
local SF13
local HH1
local HH2
local HH3
local HH4
local HH5
local HH6
local HH7
local HH8
local HH9
local HH10
local HH11

function lerp(first, second, by) return first * (1 - by) + second * by end

function lerpRGBInt(color1, color2, amount)
    local X1 = 1 - amount
    local X2 = color1 >> 24 & 255
    local X3 = color1 >> 16 & 255
    local X4 = color1 >> 8 & 255
    local X5 = color1 & 255
    local X6 = color2 >> 24 & 255
    local X7 = color2 >> 16 & 255
    local X8 = color2 >> 8 & 255
    local X9 = color2 & 255
    local X10 = X2 * X1 + X6 * amount
    local X11 = X3 * X1 + X7 * amount
    local X12 = X4 * X1 + X8 * amount
    local X13 = X5 * X1 + X9 * amount
    return X10 << 24 | X11 << 16 | X12 << 8 | X13
end

function colorToInt(color)
    return (color.red << 16) + (color.green << 8) + (color.blue)
end

function colorShift(color, hueShift, satShift, lightShift, shadeShift)
    local newColor = Color(color) -- Make a copy of the color so we don't modify the parameter

    -- SHIFT HUE
    newColor.hslHue = (newColor.hslHue + hueShift * 360) % 360

    -- SHIFT SATURATION
    if (satShift > 0) then
        newColor.saturation = lerp(newColor.saturation, 1, satShift)
    elseif (satShift < 0) then
        newColor.saturation = lerp(newColor.saturation, 0, -satShift)
    end

    -- SHIFT LIGHTNESS
    if (lightShift > 0) then
        newColor.lightness = lerp(newColor.lightness, 1, lightShift)
    elseif (lightShift < 0) then
        newColor.lightness = lerp(newColor.lightness, 0, -lightShift)
    end

    -- SHIFT SHADING
    local newShade = Color {
        red = newColor.red,
        green = newColor.green,
        blue = newColor.blue
    }
    local shadeInt = 0
    if (shadeShift >= 0) then
        newShade.hue = 50
        shadeInt = lerpRGBInt(colorToInt(newColor), colorToInt(newShade),
            shadeShift)
    elseif (shadeShift < 0) then
        newShade.hue = 215
        shadeInt = lerpRGBInt(colorToInt(newColor), colorToInt(newShade),
            -shadeShift)
    end
    newColor.red = shadeInt >> 16
    newColor.green = shadeInt >> 8 & 255
    newColor.blue = shadeInt & 255

    return newColor
end

function modifyColor(C)
    -- SHADING COLORS
    SH1 = colorShift(C, 0, 0.4, -0.6, -0.6)
    SH2 = colorShift(C, 0, 0.333, -0.5, -0.5)
    SH3 = colorShift(C, 0, 0.266, -0.4, -0.4)
    SH4 = colorShift(C, 0, 0.2, -0.3, -0.3)
    SH5 = colorShift(C, 0, 0.133, -0.2, -0.2)
    SH6 = colorShift(C, 0, 0.066, -0.1, -0.1)
    SH8 = colorShift(C, 0, 0.066, 0.1, 0.1)
    SH9 = colorShift(C, 0, 0.133, 0.2, 0.2)
    SH10 = colorShift(C, 0, 0.2, 0.3, 0.3)
    SH11 = colorShift(C, 0, 0.266, 0.4, 0.4)
    SH12 = colorShift(C, 0, 0.333, 0.5, 0.5)
    SH13 = colorShift(C, 0, 0.4, 0.6, 0.6)

    -- SHADING COLORS SOFTLY
    SHF1 = colorShift(C, 0, 0.3, -0.45, -0.45)
    SHF2 = colorShift(C, 0, 0.25, -0.375, -0.375)
    SHF3 = colorShift(C, 0, 0.2, -0.3, -0.3)
    SHF4 = colorShift(C, 0, 0.15, -0.225, -0.225)
    SHF5 = colorShift(C, 0, 0.1, -0.15, -0.15)
    SHF6 = colorShift(C, 0, 0.05, -0.075, -0.075)
    SHF8 = colorShift(C, 0, 0.05, 0.075, 0.075)
    SHF9 = colorShift(C, 0, 0.1, 0.15, 0.15)
    SHF10 = colorShift(C, 0, 0.15, 0.225, 0.225)
    SHF11 = colorShift(C, 0, 0.2, 0.3, 0.3)
    SHF12 = colorShift(C, 0, 0.25, 0.375, 0.375)
    SHF13 = colorShift(C, 0, 0.3, 0.45, 0.45)

    -- SKIN
    SK1 = colorShift(C, 0, 0.3, -0.45, -0.3)
    SK2 = colorShift(C, 0, 0.25, -0.375, -0.25)
    SK3 = colorShift(C, 0, 0.2, -0.3, -0.2)
    SK4 = colorShift(C, 0, 0.15, -0.225, -0.15)
    SK5 = colorShift(C, 0, 0.1, -0.15, -0.1)
    SK6 = colorShift(C, 0, 0.05, -0.075, -0.05)
    SK8 = colorShift(C, 0, -0.025, 0.075, 0.025)
    SK9 = colorShift(C, 0, 0.05, 0.15, 0.05)
    SK10 = colorShift(C, 0, 0.075, 0.225, 0.075)
    SK11 = colorShift(C, 0, 0.1, 0.3, 0.1)
    SK12 = colorShift(C, 0, 0.125, 0.375, 0.125)
    SK13 = colorShift(C, 0, 0.15, 0.45, 0.15)

    -- LIGHTNESS COLORS
    LI1 = colorShift(C, 0, 0, -0.8571, 0)
    LI2 = colorShift(C, 0, 0, -0.7142, 0)
    LI3 = colorShift(C, 0, 0, -0.5714, 0)
    LI4 = colorShift(C, 0, 0, -0.4285, 0)
    LI5 = colorShift(C, 0, 0, -0.2857, 0)
    LI6 = colorShift(C, 0, 0, -0.1428, 0)
    LI8 = colorShift(C, 0, 0, 0.1428, 0)
    LI9 = colorShift(C, 0, 0, 0.2857, 0)
    LI10 = colorShift(C, 0, 0, 0.4285, 0)
    LI11 = colorShift(C, 0, 0, 0.5714, 0)
    LI12 = colorShift(C, 0, 0, 0.7142, 0)
    LI13 = colorShift(C, 0, 0, 0.8571, 0)

    -- LIGHTNESS COLORS
    LS1 = colorShift(C, 0, 0, -0.5, 0)
    LS2 = colorShift(C, 0, 0, -0.4166, 0)
    LS3 = colorShift(C, 0, 0, -0.3333, 0)
    LS4 = colorShift(C, 0, 0, -0.25, 0)
    LS5 = colorShift(C, 0, 0, -0.1666, 0)
    LS6 = colorShift(C, 0, 0, -0.0833, 0)
    LS8 = colorShift(C, 0, 0, 0.0833, 0)
    LS9 = colorShift(C, 0, 0, 0.1666, 0)
    LS10 = colorShift(C, 0, 0, 0.25, 0)
    LS11 = colorShift(C, 0, 0, 0.3333, 0)
    LS12 = colorShift(C, 0, 0, 0.4166, 0)
    LS13 = colorShift(C, 0, 0, 0.5, 0)

    -- SATURATION COLORS
    SA1 = colorShift(C, 0, -0.8571, 0, 0)
    SA2 = colorShift(C, 0, -0.7142, 0, 0)
    SA3 = colorShift(C, 0, -0.5714, 0, 0)
    SA4 = colorShift(C, 0, -0.4285, 0, 0)
    SA5 = colorShift(C, 0, -0.2857, 0, 0)
    SA6 = colorShift(C, 0, -0.1428, 0, 0)
    SA8 = colorShift(C, 0, 0.1428, 0, 0)
    SA9 = colorShift(C, 0, 0.2857, 0, 0)
    SA10 = colorShift(C, 0, 0.4285, 0, 0)
    SA11 = colorShift(C, 0, 0.5714, 0, 0)
    SA12 = colorShift(C, 0, 0.7142, 0, 0)
    SA13 = colorShift(C, 0, 0.8571, 0, 0)

    -- SOFT HUE COLORS
    SF1 = colorShift(C, -0.0833, 0, 0, 0)
    SF2 = colorShift(C, -0.0694, 0, 0, 0)
    SF3 = colorShift(C, -0.0555, 0, 0, 0)
    SF4 = colorShift(C, -0.0416, 0, 0, 0)
    SF5 = colorShift(C, -0.0277, 0, 0, 0)
    SF6 = colorShift(C, -0.0138, 0, 0, 0)
    SF8 = colorShift(C, 0.0138, 0, 0, 0)
    SF9 = colorShift(C, 0.0277, 0, 0, 0)
    SF10 = colorShift(C, 0.0416, 0, 0, 0)
    SF11 = colorShift(C, 0.0555, 0, 0, 0)
    SF12 = colorShift(C, 0.0694, 0, 0, 0)
    SF13 = colorShift(C, 0.0833, 0, 0, 0)

    -- HARD HUE COLORS
    HH1 = colorShift(C, 0.0833, 0, 0, 0)
    HH2 = colorShift(C, 0.1666, 0, 0, 0)
    HH3 = colorShift(C, 0.25, 0, 0, 0)
    HH4 = colorShift(C, 0.3333, 0, 0, 0)
    HH5 = colorShift(C, 0.4166, 0, 0, 0)
    HH6 = colorShift(C, 0.50, 0, 0, 0)
    HH7 = colorShift(C, 0.5833, 0, 0, 0)
    HH8 = colorShift(C, 0.6666, 0, 0, 0)
    HH9 = colorShift(C, 0.75, 0, 0, 0)
    HH10 = colorShift(C, 0.8333, 0, 0, 0)
    HH11 = colorShift(C, 0.9166, 0, 0, 0)
end

function calculateColors(baseColor)
    -- CACHING
    FGcache = app.fgColor
    if (fg ~= nil) then FGcache = fg end

    BGcache = app.bgColor
    if (bg ~= nil) then BGcache = bg end

    -- CURRENT CORE COLOR TO GENERATE SHADING
    local C = baseColor
    if (shadingColor ~= nil) then C = shadingColor end

    modifyColor(C);

    dlg:modify { id = "baseu", colors = { FGcache, BGcache } }
    dlg:modify {
        id = "shau",
        colors = {
            SH1, SH2, SH3, SH4, SH5, SH6, C, SH8, SH9, SH10, SH11, SH12, SH13
        }
    }
    dlg:modify {
        id = "shasf",
        colors = {
            SHF1, SHF2, SHF3, SHF4, SHF5, SHF6, C, SHF8, SHF9, SHF10, SHF11,
            SHF12, SHF13
        }
    }
    dlg:modify {
        id = "skin",
        colors = {
            SK1, SK2, SK3, SK4, SK5, SK6, C, SK8, SK9, SK10, SK11, SK12, SK13
        }
    }
    dlg:modify {
        id = "litu",
        colors = {
            LI1, LI2, LI3, LI4, LI5, LI6, C, LI8, LI9, LI10, LI11, LI12, LI13
        }
    }
    dlg:modify {
        id = "lits",
        colors = {
            LS1, LS2, LS3, LS4, LS5, LS6, C, LS8, LS9, LS10, LS11, LS12, LS13
        }
    }
    dlg:modify {
        id = "satu",
        colors = {
            SA1, SA2, SA3, SA4, SA5, SA6, C, SA8, SA9, SA10, SA11, SA12, SA13
        }
    }
    dlg:modify {
        id = "shueu",
        colors = {
            SF1, SF2, SF3, SF4, SF5, SF6, C, SF8, SF9, SF10, SF11, SF12, SF13
        }
    }
    dlg:modify {
        id = "hhueu",
        colors = {
            C, HH1, HH2, HH3, HH4, HH5, HH6, HH7, HH8, HH9, HH10, HH11, HH12
        }
    }
end

function oneShadesClick(ev)
    eyeDropper = false;

    if (ev.button == MouseButton.LEFT) then
        app.fgColor = ev.color
    elseif (ev.button == MouseButton.RIGHT) then
        app.bgColor = ev.color
    elseif (ev.button == MouseButton.MIDDLE) then
        app.fgColor = ev.color
        calculateColors(app.fgColor)
    end

end

function showColors(shadingColor, fg, bg, windowBounds)
    dlg = Dialog {
        title = "Color Shading++",
        onclose = function()
            -- onDialog close
            app.events:off(fgListenerCode)
            app.events:off(bgListenerCode)
        end
    }

    -- CACHING
    FGcache = app.fgColor
    if (fg ~= nil) then FGcache = fg end

    BGcache = app.bgColor
    if (bg ~= nil) then BGcache = bg end

    -- CURRENT CORE COLOR TO GENERATE SHADING
    local C = app.fgColor
    if (shadingColor ~= nil) then C = shadingColor end

    modifyColor(C);

    -- DIALOGUE
    dlg:shades {
        -- SAVED COLOR BASES
        id = "baseu",
        label = "基色",
        colors = { FGcache, BGcache },
        onclick = function(ev) calculateColors(ev.color) end
    }:button {
        -- GET BUTTON
        id = "getu",
        text = "获取",
        onclick = function() calculateColors(app.fgColor) end
    }:button {
        -- help
        text = "帮助",
        onclick = function() helpDlg:show {} end
    }:shades {
        -- SHADING
        id = "shau",
        label = "阴影",
        colors = {
            SH1, SH2, SH3, SH4, SH5, SH6, C, SH8, SH9, SH10, SH11, SH12, SH13
        },
        onclick = function(ev) oneShadesClick(ev) end
    }:shades {
        -- SHADING SOFTLY
        id = "shasf",
        label = "软阴影",
        colors = {
            SHF1, SHF2, SHF3, SHF4, SHF5, SHF6, C, SHF8, SHF9, SHF10, SHF11,
            SHF12, SHF13
        },
        onclick = function(ev) oneShadesClick(ev) end
    }:shades {
        -- SKIN
        id = "skin",
        label = "肤色",
        colors = {
            SK1, SK2, SK3, SK4, SK5, SK6, C, SK8, SK9, SK10, SK11, SK12, SK13
        },
        onclick = function(ev) oneShadesClick(ev) end
    }:shades {
        -- LIGHTNESS
        id = "litu",
        label = "高光",
        colors = {
            LI1, LI2, LI3, LI4, LI5, LI6, C, LI8, LI9, LI10, LI11, LI12, LI13
        },
        onclick = function(ev) oneShadesClick(ev) end
    }:shades {
        -- SOFT LIGHTNESS
        id = "lits",
        label = "柔光",
        colors = {
            LS1, LS2, LS3, LS4, LS5, LS6, C, LS8, LS9, LS10, LS11, LS12, LS13
        },
        onclick = function(ev) oneShadesClick(ev) end
    }:shades {
        -- SATURATION
        id = "satu",
        label = "色差",
        colors = {
            SA1, SA2, SA3, SA4, SA5, SA6, C, SA8, SA9, SA10, SA11, SA12, SA13
        },
        onclick = function(ev) oneShadesClick(ev) end
    }:shades {
        -- SOFT HUE
        id = "shueu",
        label = "软色调",
        colors = {
            SF1, SF2, SF3, SF4, SF5, SF6, C, SF8, SF9, SF10, SF11, SF12, SF13
        },
        onclick = function(ev) oneShadesClick(ev) end
    }:shades {
        -- HARD HUE
        id = "hhueu",
        label = "硬色调",
        colors = {
            C, HH1, HH2, HH3, HH4, HH5, HH6, HH7, HH8, HH9, HH10, HH11, HH12
        },
        onclick = function(ev) oneShadesClick(ev) end
    }:check {
        id = "check",
        label = "模式",
        text = "自动拾取",
        selected = autoPick,
        onclick = function() autoPick = not autoPick; end
    }

    dlg:show { wait = false, bounds = windowBounds }
end

local function onFgChange()
    if (eyeDropper == true and autoPick == true) then
        FGcache = app.fgColor;
        BGcache = app.bgColor;
        calculateColors(app.fgColor);
    elseif (eyeDropper == false) then
        -- print("inside shades")
    end
    eyeDropper = true;

end

-- run the script ------------------------------------------------------------------
do
    showColors(app.fgColor)
    fgListenerCode = app.events:on('fgcolorchange', onFgChange);
    bgListenerCode = app.events:on('bgcolorchange', onFgChange);
end
