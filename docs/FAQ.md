# FAQ

**Does PISIT HUB use or copy any code from Rayfield or other UI libraries?**
No. Every module in `src/` was written from scratch with its own class structure, naming conventions, and visual system. PISIT HUB does not import, require, or reference any third-party UI library.

**Does PISIT HUB make any HTTP requests?**
No. The library itself performs zero network calls. `Config.lua` only touches the local filesystem via `writefile`/`readfile` (guarded — see below).

**What happens if `writefile`/`readfile` aren't available (e.g. in Roblox Studio)?**
`Config.Save`/`Config.Load` detect this via `Config.lua`'s `fsAvailable()` check and return `false, "File IO is not available on this platform."` instead of erroring, so the rest of the UI continues to work normally.

**Can I add my own theme?**
Yes — see [Theme.md](Theme.md#registering-a-custom-theme). `Library:RegisterTheme(name, palette)` accepts a partial palette; any missing keys fall back to the `Red` theme automatically.

**Can I add my own icons?**
Yes — `Library.Icons.Register(name, "rbxassetid://...")`. Reference the name in any element's `Icon` field.

**How do I make an element's value persist across sessions?**
Give it a unique `Flag` in its config table. Every stateful element (Toggle, Slider, Dropdown, Textbox, Keybind, ColorPicker) automatically registers itself with `Config.lua` under that flag. Calling `Library:SaveConfig(name)` / `Library:LoadConfig(name)` then captures/restores every registered flag at once.

**Does the callback fire when a config is loaded?**
No — restoring a value from a saved config intentionally skips the callback, to avoid re-triggering side effects (like re-equipping an item) purely because the UI was reopened. Only direct user interaction or an explicit `element:Set(value)` call (without the internal `fromConfig` flag) fires the callback.

**Is PISIT HUB mobile-friendly?**
Yes. Every drag/slider/dropdown interaction is wired through both `Enum.UserInputType.MouseButton1` and `Enum.UserInputType.Touch`, and `Window.new` picks a responsive default size based on `Utility.IsMobile()`.

**How do I fully remove the UI from the game?**
Call `Window:Destroy()` (or `Library:Destroy()` to destroy every window created through that Library instance). This is irreversible. Use `Window:Close()` if you might want to reopen the same window later with `Window:Open()`.

**Can I run multiple windows at once?**
Yes. `Library.Windows` is a plain array; nothing in the library assumes a single global window.
