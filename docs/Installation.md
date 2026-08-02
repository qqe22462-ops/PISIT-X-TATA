# Installation

PISIT HUB is distributed as a plain folder of `ModuleScript` files (`src/`). There is no compiled binary and no external loader dependency — you own the full source.

## Option 1: Roblox Studio (recommended for game developers)

1. Copy the `src` folder into your project.
2. Rename the `src` folder itself to `PISIT_HUB` and place it under `ReplicatedStorage` (or `ServerStorage`/`StarterPlayerScripts`, depending on where your script that opens the UI runs from).
3. Because the folder contains an `init.lua`, Roblox automatically treats the folder as a single `ModuleScript` named `PISIT_HUB` — requiring the folder requires `init.lua`, and `init.lua` internally requires every sibling module (`Theme`, `Window`, `Tab`, ...).
4. Require it from a `LocalScript`:

```lua
local Library = require(game:GetService("ReplicatedStorage"):WaitForChild("PISIT_HUB"))
```

## Option 2: Executor / Script Hub environment

If you are loading PISIT HUB inside a script executor rather than through Roblox Studio's instance tree, host the raw files (e.g. via a GitHub raw URL or your own script hub) and load `init.lua` last, after every dependency module has been made available under a shared table, for example:

```lua
local repo = "https://raw.githubusercontent.com/your-username/pisit-hub/main/src/"

local function fetch(file)
    return loadstring(game:HttpGet(repo .. file .. ".lua"))()
end

-- init.lua expects to `require(script.X)`, so in a loadstring-based
-- environment you should instead adapt init.lua's requires to call
-- fetch("Theme"), fetch("Window"), etc. See Examples.md for a full
-- loader-compatible bootstrap script.
```

> **Note:** The `require(script.X)` calls used throughout `src/` assume a real Roblox Instance tree (Option 1). If you need a `loadstring`-based single-file loader, wrap each module in a table keyed by name and replace `require(script.X)` calls with lookups into that table — a working example is provided in [Examples.md](Examples.md).

## Verifying installation

```lua
local Library = require(path.to.PISIT_HUB)
print("PISIT HUB version:", Library._version)
```

If this prints a version string with no errors, installation succeeded. Continue to [Getting Started](Getting%20Started.md).
