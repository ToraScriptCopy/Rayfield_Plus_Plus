# Rayfield++ 

## What's New?

- **More icons** – now you can use **Geist** and **Craft** icon sets alongside Lucide. Just type `geist:home` or `craft:settings` and the library will handle the rest (once you map the asset IDs).
- **Fresh UI elements**:
  - **Popup** – a modal window that floats above everything (great for alerts or quick inputs).
  - **Tag** – a small label to highlight important info.
  - **Key Value Display** – a dynamic indicator that shows the current value of a variable (updates in real time).
  - **Progress Bar** – classic progress bar for loading, health, or any percentage‑based value.
  - **Image Holder** – a container to display any Roblox image by its asset ID.
  - **Console** – a button that opens the Roblox developer console (handy for debugging).
  - **Lockable Element** – lock (hide or disable) any UI element until a condition is met (e.g., enough coins).
- **Window customisation**:
  - Background transparency (`SetBackgroundTransparency`).
  - Background image (`SetBackgroundImage`).
  - Rainbow effect with adjustable speed (`EnableRainbowEffect` / `DisableRainbowEffect`).
- **Minis UIs** – small draggable widgets (toggle or button) that stay on top of all windows. Perfect for quick access to frequently used functions.
- **Improved binds** – now they work reliably without skipped inputs or glitches.
- **Smart saving** – settings are saved with a short delay to avoid excessive file writes when values change rapidly.

## How to Install

1. Grab the two files:
   - `source.lua` – the original Rayfield library.
   - `source+.lua` – the Rayfield++ extension.
2. Load them in the correct order in your script:
   ```lua
   local Rayfield = loadstring(game:HttpGet("https://raw.githubusercontent.com/your-repo/source.lua"))()
   local RayfieldPlus = loadstring(game:HttpGet("https://raw.githubusercontent.com/your-repo/source+.lua"))()
   RayfieldPlus.extend(Rayfield)
   ```
   After that, every `Rayfield:CreateWindow()` call will return windows with all the new goodies.

## Usage Examples

### Window with transparency and rainbow
```lua
local Window = Rayfield:CreateWindow({
    Name = "My Hub",
    ConfigurationSaving = { Enabled = true, FileName = "myhub" }
})
Window:SetBackgroundTransparency(0.3)
Window:EnableRainbowEffect(0.3) -- speed
```

### Mini toggle (always on top)
```lua
local miniToggle = Window:CreateMiniToggle({
    Name = "Anti-AFK",
    CurrentValue = true,
    Callback = function(val)
        print("Anti-AFK is now " .. (val and "on" or "off"))
    end
})
-- later you can change the value
miniToggle:Set(false)
```

### Progress bar on a tab
```lua
local Tab = Window:CreateTab("Stats")
local progress = Tab:CreateProgressBar({
    Name = "Health",
    CurrentValue = 75
})
-- update it
progress:Set(50)
```

### Popup with a message
```lua
local popup = Tab:CreatePopup({
    Title = "Attention!",
    Content = "You found a secret code!"
})
popup:Show()

-- or a global popup not attached to any window
local globalPopup = Rayfield:CreatePopup({
    Title = "Global Notification",
    Content = "This popup is visible everywhere"
})
globalPopup:Show()
```

### Locking an element based on a flag
Suppose you have a flag `"money"` that stores the player's coins, and you want to show a button only when coins >= 100.
```lua
local button = Tab:CreateButton({ Name = "Buy a gun", Callback = function() end })
local locker = Tab:CreateLockableElement(button, "money", function()
    return Rayfield.Flags["money"].CurrentValue >= 100
end)
-- once you have enough coins, the button appears automatically
```

### Console button
```lua
Tab:CreateConsoleButton({ Name = "Open Console" })
```

### Using Geist / Craft icons
```lua
local Tab = Window:CreateTab("Menu", "geist:home") -- icon from Geist
-- also works anywhere you use the Image parameter
Tab:CreateButton({ Name = "Settings", Callback = function() end, Image = "craft:settings" })
```

## Important Notes

- For Geist and Craft icons to work, you need to fill the `Icons_Geist` and `Icons_Craft` tables inside the extension code with your own asset IDs and rect data (I left them empty as placeholders – you can add them easily).
- Lockable elements are checked via `RunService.Heartbeat`, so they react almost instantly.
- Minis UIs are draggable – just click and drag them anywhere on the screen.
- Smart saving is triggered automatically when you use `QueueSave`, but if you modify values directly, remember to call `Rayfield:QueueSave(flag, value)` to queue a save.

## Compatibility

This extension is built for Rayfield Build 1.749 (the one included in this repo). If you're using a much older or newer version, there might be slight differences – I recommend using the provided `source.lua` for best results.


---

Enjoy your enhanced Rayfield experience and make your UIs even more awesome! 🚀
