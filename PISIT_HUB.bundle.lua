--[[
 .____                  ________ ___.    _____                           __                
 |    |    __ _______   \_____  \\_ |___/ ____\_ __  ______ ____ _____ _/  |_  ___________ 
 |    |   |  |  \__  \   /   |   \| __ \   __\  |  \/  ___// ___\\__  \\   __\/  _ \_  __ \
 |    |___|  |  // __ \_/    |    \ \_\ \  | |  |  /\___ \\  \___ / __ \|  | (  <_> )  | \/
 |_______ \____/(____  /\_______  /___  /__| |____//____  >\___  >____  /__|  \____/|__|   
         \/          \/         \/    \/                \/     \/     \/                   
          \_Welcome to LuaObfuscator.com   (Alpha 0.10.9) ~  Much Love, Ferib 

]]--

local Modules = {};
Modules.Utility = (function()
	local UserInputService = game:GetService("UserInputService");
	local Utility = {};
	Utility.New = function(className, props, children)
		local inst = Instance.new(className);
		if props then
			for key, value in pairs(props) do
				if (key ~= "Parent") then
					inst[key] = value;
				end
			end
		end
		if children then
			for _, child in ipairs(children) do
				child.Parent = inst;
			end
		end
		if (props and props.Parent) then
			inst.Parent = props.Parent;
		end
		return inst;
	end;
	Utility.SafeCall = function(fn, ...)
		local FlatIdent_378D0 = 0;
		local ok;
		local err;
		while true do
			if (FlatIdent_378D0 == 0) then
				if (type(fn) ~= "function") then
					return;
				end
				ok, err = pcall(fn, ...);
				FlatIdent_378D0 = 1;
			end
			if (FlatIdent_378D0 == 1) then
				if not ok then
					warn("[PISIT HUB] Error: " .. tostring(err));
				end
				break;
			end
		end
	end;
	Utility.MakeDraggable = function(frame, handle)
		handle = handle or frame;
		local dragging, dragStart, startPos;
		handle.InputBegan:Connect(function(input)
			if ((input.UserInputType == Enum.UserInputType.MouseButton1) or (input.UserInputType == Enum.UserInputType.Touch)) then
				local FlatIdent_10BCC = 0;
				while true do
					if (0 == FlatIdent_10BCC) then
						dragging = true;
						dragStart = input.Position;
						FlatIdent_10BCC = 1;
					end
					if (FlatIdent_10BCC == 1) then
						startPos = frame.Position;
						input.Changed:Connect(function()
							if (input.UserInputState == Enum.UserInputState.End) then
								dragging = false;
							end
						end);
						break;
					end
				end
			end
		end);
		handle.InputChanged:Connect(function(input)
			if (dragging and ((input.UserInputType == Enum.UserInputType.MouseMovement) or (input.UserInputType == Enum.UserInputType.Touch))) then
				local delta = input.Position - dragStart;
				frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y);
			end
		end);
	end;
	Utility.Round = function(val, dec)
		local FlatIdent_2BD95 = 0;
		local mult;
		while true do
			if (FlatIdent_2BD95 == 0) then
				mult = 10 ^ (dec or 0);
				return math.floor((val * mult) + 0.5) / mult;
			end
		end
	end;
	Utility.Clamp = function(val, min, max)
		return math.max(min, math.min(max, val));
	end;
	return Utility;
end)();
Modules.Theme = (function()
	local Theme = {};
	local function newSignal()
		local FlatIdent_23BE8 = 0;
		local signal;
		while true do
			if (1 == FlatIdent_23BE8) then
				signal.Fire = function(self, ...)
					for _, fn in ipairs(signal._listeners) do
						task.spawn(fn, ...);
					end
				end;
				return signal;
			end
			if (FlatIdent_23BE8 == 0) then
				signal = {_listeners={}};
				signal.Connect = function(self, fn)
					local FlatIdent_31A5A = 0;
					while true do
						if (FlatIdent_31A5A == 0) then
							table.insert(signal._listeners, fn);
							return {Disconnect=function()
								for i, l in ipairs(signal._listeners) do
									if (l == fn) then
										table.remove(signal._listeners, i);
										break;
									end
								end
							end};
						end
					end
				end;
				FlatIdent_23BE8 = 1;
			end
		end
	end
	Theme.Palettes = {Red={Accent=Color3.fromHex("#DC1E1E"),AccentDim=Color3.fromHex("#8C1414"),Background=Color3.fromHex("#0F0F0F"),SecondaryBackground=Color3.fromHex("#171717"),ElementBackground=Color3.fromHex("#1B1B1B"),Border=Color3.fromHex("#DC1E1E"),Text=Color3.fromHex("#FFFFFF"),SubText=Color3.fromHex("#B5B5B5"),Success=Color3.fromHex("#3ED17B"),Warning=Color3.fromHex("#E1B33D"),Error=Color3.fromHex("#E14848")},Blue={Accent=Color3.fromHex("#1E7FDC"),AccentDim=Color3.fromHex("#144E8C"),Background=Color3.fromHex("#0F1215"),SecondaryBackground=Color3.fromHex("#171B1F"),ElementBackground=Color3.fromHex("#1B2126"),Border=Color3.fromHex("#1E7FDC"),Text=Color3.fromHex("#FFFFFF"),SubText=Color3.fromHex("#B5B5B5"),Success=Color3.fromHex("#3ED17B"),Warning=Color3.fromHex("#E1B33D"),Error=Color3.fromHex("#E14848")},Green={Accent=Color3.fromHex("#1EDC6E"),AccentDim=Color3.fromHex("#148C46"),Background=Color3.fromHex("#0D110E"),SecondaryBackground=Color3.fromHex("#141914"),ElementBackground=Color3.fromHex("#191F19"),Border=Color3.fromHex("#1EDC6E"),Text=Color3.fromHex("#FFFFFF"),SubText=Color3.fromHex("#B5B5B5"),Success=Color3.fromHex("#3ED17B"),Warning=Color3.fromHex("#E1B33D"),Error=Color3.fromHex("#E14848")},Purple={Accent=Color3.fromHex("#9A1EDC"),AccentDim=Color3.fromHex("#5F148C"),Background=Color3.fromHex("#100E14"),SecondaryBackground=Color3.fromHex("#18151C"),ElementBackground=Color3.fromHex("#1D1922"),Border=Color3.fromHex("#9A1EDC"),Text=Color3.fromHex("#FFFFFF"),SubText=Color3.fromHex("#B5B5B5"),Success=Color3.fromHex("#3ED17B"),Warning=Color3.fromHex("#E1B33D"),Error=Color3.fromHex("#E14848")},Light={Accent=Color3.fromHex("#DC1E1E"),AccentDim=Color3.fromHex("#F0A5A5"),Background=Color3.fromHex("#F2F2F2"),SecondaryBackground=Color3.fromHex("#E6E6E6"),ElementBackground=Color3.fromHex("#FFFFFF"),Border=Color3.fromHex("#DC1E1E"),Text=Color3.fromHex("#101010"),SubText=Color3.fromHex("#5A5A5A"),Success=Color3.fromHex("#2FA860"),Warning=Color3.fromHex("#B98A1F"),Error=Color3.fromHex("#C23A3A")}};
	Theme.Order = {"Red","Blue","Green","Purple","Light"};
	Theme.OnChanged = newSignal();
	Theme.Current = "Red";
	Theme.Active = Theme.Palettes.Red;
	Theme.Get = function(key)
		return Theme.Active[key];
	end;
	Theme.Set = function(name)
		local palette = Theme.Palettes[name];
		if not palette then
			return false, "ไม่พบธีม: " .. tostring(name);
		end
		Theme.Current = name;
		Theme.Active = palette;
		Theme.OnChanged:Fire(palette);
		return true;
	end;
	return Theme;
end)();
Modules.Animation = (function()
	local FlatIdent_1076E = 0;
	local TweenService;
	local Animation;
	while true do
		if (FlatIdent_1076E == 2) then
			Animation.OpenWindow = function(frame)
				local FlatIdent_49AED = 0;
				local goalSize;
				while true do
					if (FlatIdent_49AED == 0) then
						frame.Visible = true;
						goalSize = frame:GetAttribute("TargetSize") or frame.Size;
						FlatIdent_49AED = 1;
					end
					if (FlatIdent_49AED == 2) then
						Animation.Tween(frame, Animation.Easing.Bounce, {Size=goalSize});
						Animation.Tween(frame, Animation.Easing.Normal, {BackgroundTransparency=0});
						break;
					end
					if (FlatIdent_49AED == 1) then
						frame.Size = UDim2.new(goalSize.X.Scale, goalSize.X.Offset, 0, 0);
						frame.BackgroundTransparency = 1;
						FlatIdent_49AED = 2;
					end
				end
			end;
			Animation.CloseWindow = function(frame, onComplete)
				local FlatIdent_6A83E = 0;
				local tw;
				while true do
					if (FlatIdent_6A83E == 1) then
						tw.Completed:Connect(function()
							local FlatIdent_12544 = 0;
							while true do
								if (FlatIdent_12544 == 0) then
									frame.Visible = false;
									if onComplete then
										onComplete();
									end
									break;
								end
							end
						end);
						break;
					end
					if (FlatIdent_6A83E == 0) then
						frame:SetAttribute("TargetSize", frame.Size);
						tw = Animation.Tween(frame, Animation.Easing.Fast, {Size=UDim2.new(frame.Size.X.Scale, frame.Size.X.Offset, 0, 0),BackgroundTransparency=1});
						FlatIdent_6A83E = 1;
					end
				end
			end;
			FlatIdent_1076E = 3;
		end
		if (1 == FlatIdent_1076E) then
			Animation.Easing = {Fast=TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),Normal=TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),Smooth=TweenInfo.new(0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),Bounce=TweenInfo.new(0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out)};
			Animation.Tween = function(inst, info, props)
				local FlatIdent_946F = 0;
				local tw;
				while true do
					if (FlatIdent_946F == 0) then
						tw = TweenService:Create(inst, info, props);
						tw:Play();
						FlatIdent_946F = 1;
					end
					if (FlatIdent_946F == 1) then
						return tw;
					end
				end
			end;
			FlatIdent_1076E = 2;
		end
		if (FlatIdent_1076E == 0) then
			TweenService = game:GetService("TweenService");
			Animation = {};
			FlatIdent_1076E = 1;
		end
		if (FlatIdent_1076E == 3) then
			Animation.Hover = function(inst, hoverCol, normCol)
				local FlatIdent_29B3D = 0;
				while true do
					if (FlatIdent_29B3D == 0) then
						inst.MouseEnter:Connect(function()
							Animation.Tween(inst, Animation.Easing.Fast, {BackgroundColor3=hoverCol});
						end);
						inst.MouseLeave:Connect(function()
							Animation.Tween(inst, Animation.Easing.Fast, {BackgroundColor3=normCol});
						end);
						break;
					end
				end
			end;
			Animation.Click = function(inst)
				local FlatIdent_3EEE1 = 0;
				local orig;
				while true do
					if (FlatIdent_3EEE1 == 0) then
						orig = inst.Size;
						Animation.Tween(inst, TweenInfo.new(0.08), {Size=UDim2.new(orig.X.Scale, orig.X.Offset - 4, orig.Y.Scale, orig.Y.Offset - 2)});
						FlatIdent_3EEE1 = 1;
					end
					if (FlatIdent_3EEE1 == 1) then
						task.delay(0.08, function()
							Animation.Tween(inst, Animation.Easing.Bounce, {Size=orig});
						end);
						break;
					end
				end
			end;
			FlatIdent_1076E = 4;
		end
		if (FlatIdent_1076E == 4) then
			Animation.Glow = function(stroke, active)
				Animation.Tween(stroke, Animation.Easing.Normal, {Transparency=((active and 0) or 0.6)});
			end;
			return Animation;
		end
	end
end)();
Modules.Config = (function()
	local HttpService = game:GetService("HttpService");
	local Config = {};
	Config._flags = {};
	Config._folder = "PISIT_HUB/configs";
	Config._autoSaveEnabled = false;
	local function fsAvailable()
		return (typeof(writefile) == "function") and (typeof(readfile) == "function") and (typeof(isfile) == "function");
	end
	local function ensureFolder()
		if ((typeof(makefolder) == "function") and (typeof(isfolder) == "function")) then
			if not isfolder(Config._folder) then
				makefolder(Config._folder);
			end
		end
	end
	Config.Register = function(flag, getSet)
		Config._flags[flag] = getSet;
	end;
	Config.Save = function(name)
		local FlatIdent_324DE = 0;
		local data;
		local ok;
		local encoded;
		local path;
		local writeOk;
		local writeErr;
		while true do
			if (FlatIdent_324DE == 2) then
				if not ok then
					return false, "เข้ารหัส config ไม่สำเร็จ";
				end
				path = Config._folder .. "/" .. name .. ".json";
				writeOk, writeErr = pcall(writefile, path, encoded);
				FlatIdent_324DE = 3;
			end
			if (FlatIdent_324DE == 0) then
				name = name or "default";
				if not fsAvailable() then
					return false, "File IO ใช้ไม่ได้บนแพลตฟอร์มนี้";
				end
				ensureFolder();
				FlatIdent_324DE = 1;
			end
			if (FlatIdent_324DE == 3) then
				if not writeOk then
					return false, "เขียนไฟล์ไม่สำเร็จ: " .. tostring(writeErr);
				end
				return true, "บันทึกที่ " .. path;
			end
			if (FlatIdent_324DE == 1) then
				data = {};
				for flag, gs in pairs(Config._flags) do
					local FlatIdent_4CC24 = 0;
					local ok;
					local v;
					while true do
						if (FlatIdent_4CC24 == 0) then
							ok, v = pcall(gs.Get);
							if ok then
								data[flag] = v;
							end
							break;
						end
					end
				end
				ok, encoded = pcall(HttpService.JSONEncode, HttpService, data);
				FlatIdent_324DE = 2;
			end
		end
	end;
	Config.Load = function(name)
		local FlatIdent_207CC = 0;
		local path;
		local ok;
		local raw;
		local decodeOk;
		local data;
		while true do
			if (2 == FlatIdent_207CC) then
				ok, raw = pcall(readfile, path);
				if not ok then
					return false, "อ่านไฟล์ไม่สำเร็จ";
				end
				FlatIdent_207CC = 3;
			end
			if (FlatIdent_207CC == 0) then
				name = name or "default";
				if not fsAvailable() then
					return false, "File IO ใช้ไม่ได้บนแพลตฟอร์มนี้";
				end
				FlatIdent_207CC = 1;
			end
			if (FlatIdent_207CC == 1) then
				path = Config._folder .. "/" .. name .. ".json";
				if not isfile(path) then
					return false, "ไม่พบไฟล์ config: " .. path;
				end
				FlatIdent_207CC = 2;
			end
			if (4 == FlatIdent_207CC) then
				for flag, value in pairs(data) do
					local FlatIdent_49280 = 0;
					local gs;
					while true do
						if (FlatIdent_49280 == 0) then
							gs = Config._flags[flag];
							if gs then
								pcall(gs.Set, value);
							end
							break;
						end
					end
				end
				return true, "โหลดจาก " .. path;
			end
			if (3 == FlatIdent_207CC) then
				decodeOk, data = pcall(HttpService.JSONDecode, HttpService, raw);
				if not decodeOk then
					return false, "ถอดรหัส config ไม่สำเร็จ";
				end
				FlatIdent_207CC = 4;
			end
		end
	end;
	Config.EnableAutoSave = function(name, interval)
		local FlatIdent_7F121 = 0;
		while true do
			if (FlatIdent_7F121 == 0) then
				Config._autoSaveEnabled = true;
				task.spawn(function()
					while Config._autoSaveEnabled do
						local FlatIdent_206F8 = 0;
						while true do
							if (0 == FlatIdent_206F8) then
								task.wait(interval or 15);
								if Config._autoSaveEnabled then
									Config.Save(name);
								end
								break;
							end
						end
					end
				end);
				break;
			end
		end
	end;
	Config.DisableAutoSave = function()
		Config._autoSaveEnabled = false;
	end;
	return Config;
end)();
Modules.Notification = (function()
	local Theme = Modules.Theme;
	local Utility = Modules.Utility;
	local Animation = Modules.Animation;
	local Notification = {};
	local container;
	Notification.Init = function(screenGui)
		container = Utility.New("Frame", {Name="PISIT_Notifications",BackgroundTransparency=1,AnchorPoint=Vector2.new(1, 0),Position=UDim2.new(1, -12, 0, 12),Size=UDim2.new(0, 220, 1, -24),Parent=screenGui});
		Utility.New("UIListLayout", {Parent=container,HorizontalAlignment=Enum.HorizontalAlignment.Right,VerticalAlignment=Enum.VerticalAlignment.Top,Padding=UDim.new(0, 6)});
	end;
	Notification.Notify = function(data)
		if not container then
			return;
		end
		data = data or {};
		local card = Utility.New("Frame", {BackgroundColor3=Theme.Get("SecondaryBackground"),BackgroundTransparency=1,Size=UDim2.new(1, 0, 0, 0),AutomaticSize=Enum.AutomaticSize.Y,Parent=container});
		Utility.New("UICorner", {CornerRadius=UDim.new(0, 8),Parent=card});
		local stroke = Utility.New("UIStroke", {Color=Theme.Get("Accent"),Thickness=1,Transparency=1,Parent=card});
		Utility.New("UIPadding", {PaddingLeft=UDim.new(0, 10),PaddingRight=UDim.new(0, 10),PaddingTop=UDim.new(0, 8),PaddingBottom=UDim.new(0, 8),Parent=card});
		Utility.New("UIListLayout", {Padding=UDim.new(0, 2),Parent=card});
		Utility.New("TextLabel", {BackgroundTransparency=1,Size=UDim2.new(1, 0, 0, 16),Text=(data.Title or "แจ้งเตือน"),Font=Enum.Font.GothamBold,TextSize=13,TextColor3=Theme.Get("Text"),TextXAlignment=Enum.TextXAlignment.Left,Parent=card});
		Utility.New("TextLabel", {BackgroundTransparency=1,Size=UDim2.new(1, 0, 0, 0),AutomaticSize=Enum.AutomaticSize.Y,Text=(data.Content or ""),Font=Enum.Font.Gotham,TextSize=12,TextWrapped=true,TextColor3=Theme.Get("SubText"),TextXAlignment=Enum.TextXAlignment.Left,Parent=card});
		Animation.Tween(card, Animation.Easing.Smooth, {BackgroundTransparency=0});
		Animation.Tween(stroke, Animation.Easing.Smooth, {Transparency=0.3});
		task.delay(data.Duration or 4, function()
			if not card.Parent then
				return;
			end
			local tw = Animation.Tween(card, Animation.Easing.Normal, {BackgroundTransparency=1});
			Animation.Tween(stroke, Animation.Easing.Normal, {Transparency=1});
			tw.Completed:Connect(function()
				card:Destroy();
			end);
		end);
	end;
	return Notification;
end)();
Modules.Button = (function()
	local Theme = Modules.Theme;
	local Utility = Modules.Utility;
	local Animation = Modules.Animation;
	local Button = {};
	Button.__index = Button;
	Button.new = function(parent, config)
		local FlatIdent_3CF36 = 0;
		local self;
		local stroke;
		local label;
		while true do
			if (FlatIdent_3CF36 == 0) then
				config = config or {};
				self = setmetatable({}, Button);
				self.Instance = Utility.New("TextButton", {Name="Button",Text="",AutoButtonColor=false,BackgroundColor3=Theme.Get("ElementBackground"),Size=UDim2.new(1, 0, 0, 36),Parent=parent});
				FlatIdent_3CF36 = 1;
			end
			if (2 == FlatIdent_3CF36) then
				label = Utility.New("TextLabel", {BackgroundTransparency=1,Size=UDim2.new(1, 0, 1, 0),Text=(config.Title or "Button"),Font=Enum.Font.GothamMedium,TextSize=13,TextColor3=Theme.Get("Text"),TextXAlignment=Enum.TextXAlignment.Left,Parent=self.Instance});
				Animation.Hover(self.Instance, Theme.Get("ElementBackground"):Lerp(Theme.Get("Accent"), 0.15), Theme.Get("ElementBackground"));
				self.Instance.MouseButton1Click:Connect(function()
					Animation.Click(self.Instance);
					Utility.SafeCall(config.Callback);
				end);
				FlatIdent_3CF36 = 3;
			end
			if (FlatIdent_3CF36 == 1) then
				Utility.New("UICorner", {CornerRadius=UDim.new(0, 6),Parent=self.Instance});
				stroke = Utility.New("UIStroke", {Color=Theme.Get("Border"),Transparency=0.75,Thickness=1,Parent=self.Instance});
				Utility.New("UIPadding", {PaddingLeft=UDim.new(0, 10),PaddingRight=UDim.new(0, 10),Parent=self.Instance});
				FlatIdent_3CF36 = 2;
			end
			if (3 == FlatIdent_3CF36) then
				Theme.OnChanged:Connect(function()
					self.Instance.BackgroundColor3 = Theme.Get("ElementBackground");
					stroke.Color = Theme.Get("Border");
					label.TextColor3 = Theme.Get("Text");
				end);
				return self;
			end
		end
	end;
	return Button;
end)();
Modules.Toggle = (function()
	local Theme = Modules.Theme;
	local Utility = Modules.Utility;
	local Animation = Modules.Animation;
	local Toggle = {};
	Toggle.__index = Toggle;
	Toggle.new = function(parent, config)
		local FlatIdent_3CF01 = 0;
		local self;
		local stroke;
		local label;
		local box;
		local boxStroke;
		local render;
		while true do
			if (FlatIdent_3CF01 == 0) then
				config = config or {};
				self = setmetatable({}, Toggle);
				self.Value = config.Default or false;
				self.Instance = Utility.New("Frame", {Name="Toggle",BackgroundColor3=Theme.Get("ElementBackground"),Size=UDim2.new(1, 0, 0, 36),Parent=parent});
				FlatIdent_3CF01 = 1;
			end
			if (FlatIdent_3CF01 == 4) then
				Theme.OnChanged:Connect(function()
					self.Instance.BackgroundColor3 = Theme.Get("ElementBackground");
					stroke.Color = Theme.Get("Border");
					label.TextColor3 = Theme.Get("Text");
					boxStroke.Color = Theme.Get("Border");
					render(false);
				end);
				return self;
			end
			if (FlatIdent_3CF01 == 3) then
				function render(anim)
					local col = (self.Value and Theme.Get("Accent")) or Theme.Get("Background");
					if anim then
						Animation.Tween(box, Animation.Easing.Fast, {BackgroundColor3=col});
					else
						box.BackgroundColor3 = col;
					end
				end
				box.MouseButton1Click:Connect(function()
					local FlatIdent_4508F = 0;
					while true do
						if (FlatIdent_4508F == 1) then
							Utility.SafeCall(config.Callback, self.Value);
							break;
						end
						if (FlatIdent_4508F == 0) then
							self.Value = not self.Value;
							render(true);
							FlatIdent_4508F = 1;
						end
					end
				end);
				render(false);
				if config.Flag then
					Modules.Config.Register(config.Flag, {Get=function()
						return self.Value;
					end,Set=function(v)
						local FlatIdent_1013A = 0;
						while true do
							if (0 == FlatIdent_1013A) then
								self.Value = (v and true) or false;
								render(false);
								break;
							end
						end
					end});
				end
				FlatIdent_3CF01 = 4;
			end
			if (FlatIdent_3CF01 == 2) then
				box = Utility.New("TextButton", {Text="",AutoButtonColor=false,AnchorPoint=Vector2.new(1, 0.5),Position=UDim2.new(1, 0, 0.5, 0),Size=UDim2.fromOffset(24, 24),BackgroundColor3=Theme.Get("Background"),Parent=self.Instance});
				Utility.New("UICorner", {CornerRadius=UDim.new(0, 4),Parent=box});
				boxStroke = Utility.New("UIStroke", {Color=Theme.Get("Border"),Transparency=0.4,Thickness=1,Parent=box});
				render = nil;
				FlatIdent_3CF01 = 3;
			end
			if (FlatIdent_3CF01 == 1) then
				Utility.New("UICorner", {CornerRadius=UDim.new(0, 6),Parent=self.Instance});
				stroke = Utility.New("UIStroke", {Color=Theme.Get("Border"),Transparency=0.75,Thickness=1,Parent=self.Instance});
				Utility.New("UIPadding", {PaddingLeft=UDim.new(0, 10),PaddingRight=UDim.new(0, 8),Parent=self.Instance});
				label = Utility.New("TextLabel", {BackgroundTransparency=1,Size=UDim2.new(1, -38, 1, 0),Text=(config.Title or "Toggle"),Font=Enum.Font.GothamMedium,TextSize=13,TextColor3=Theme.Get("Text"),TextXAlignment=Enum.TextXAlignment.Left,Parent=self.Instance});
				FlatIdent_3CF01 = 2;
			end
		end
	end;
	return Toggle;
end)();
Modules.Slider = (function()
	local FlatIdent_77172 = 0;
	local UserInputService;
	local Theme;
	local Utility;
	local Animation;
	local Slider;
	while true do
		if (FlatIdent_77172 == 3) then
			Slider.new = function(parent, config)
				config = config or {};
				local self = setmetatable({}, Slider);
				self.Min = config.Min or 0;
				self.Max = config.Max or 100;
				self.Value = Utility.Clamp(config.Default or self.Min, self.Min, self.Max);
				self.Dragging = false;
				self.Instance = Utility.New("Frame", {Name="Slider",BackgroundColor3=Theme.Get("ElementBackground"),Size=UDim2.new(1, 0, 0, 46),Parent=parent});
				Utility.New("UICorner", {CornerRadius=UDim.new(0, 6),Parent=self.Instance});
				local stroke = Utility.New("UIStroke", {Color=Theme.Get("Border"),Transparency=0.75,Thickness=1,Parent=self.Instance});
				Utility.New("UIPadding", {PaddingLeft=UDim.new(0, 10),PaddingRight=UDim.new(0, 10),PaddingTop=UDim.new(0, 6),Parent=self.Instance});
				local header = Utility.New("Frame", {BackgroundTransparency=1,Size=UDim2.new(1, 0, 0, 16),Parent=self.Instance});
				local titleLbl = Utility.New("TextLabel", {BackgroundTransparency=1,Size=UDim2.new(1, -50, 1, 0),Text=(config.Title or "Slider"),Font=Enum.Font.GothamMedium,TextSize=13,TextColor3=Theme.Get("Text"),TextXAlignment=Enum.TextXAlignment.Left,Parent=header});
				local valLbl = Utility.New("TextLabel", {BackgroundTransparency=1,AnchorPoint=Vector2.new(1, 0),Position=UDim2.new(1, 0, 0, 0),Size=UDim2.fromOffset(50, 16),Text=tostring(self.Value),Font=Enum.Font.GothamBold,TextSize=13,TextColor3=Theme.Get("Accent"),TextXAlignment=Enum.TextXAlignment.Right,Parent=header});
				local bar = Utility.New("Frame", {Position=UDim2.new(0, 0, 0, 26),Size=UDim2.new(1, 0, 0, 5),BackgroundColor3=Theme.Get("AccentDim"),Parent=self.Instance});
				Utility.New("UICorner", {CornerRadius=UDim.new(1, 0),Parent=bar});
				local fill = Utility.New("Frame", {Size=UDim2.new(0, 0, 1, 0),BackgroundColor3=Theme.Get("Accent"),Parent=bar});
				Utility.New("UICorner", {CornerRadius=UDim.new(1, 0),Parent=fill});
				local function update(xPos)
					local FlatIdent_2DA99 = 0;
					local rel;
					local raw;
					local stepped;
					while true do
						if (FlatIdent_2DA99 == 0) then
							rel = Utility.Clamp((xPos - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1);
							raw = self.Min + (rel * (self.Max - self.Min));
							FlatIdent_2DA99 = 1;
						end
						if (FlatIdent_2DA99 == 3) then
							Utility.SafeCall(config.Callback, self.Value);
							break;
						end
						if (FlatIdent_2DA99 == 1) then
							stepped = Utility.Round(raw / (config.Increment or 1)) * (config.Increment or 1);
							self.Value = Utility.Clamp(stepped, self.Min, self.Max);
							FlatIdent_2DA99 = 2;
						end
						if (FlatIdent_2DA99 == 2) then
							valLbl.Text = tostring(self.Value);
							fill.Size = UDim2.new((self.Value - self.Min) / (self.Max - self.Min), 0, 1, 0);
							FlatIdent_2DA99 = 3;
						end
					end
				end
				bar.InputBegan:Connect(function(input)
					if ((input.UserInputType == Enum.UserInputType.MouseButton1) or (input.UserInputType == Enum.UserInputType.Touch)) then
						local FlatIdent_4A248 = 0;
						while true do
							if (0 == FlatIdent_4A248) then
								self.Dragging = true;
								update(input.Position.X);
								break;
							end
						end
					end
				end);
				UserInputService.InputChanged:Connect(function(input)
					if (self.Dragging and ((input.UserInputType == Enum.UserInputType.MouseMovement) or (input.UserInputType == Enum.UserInputType.Touch))) then
						update(input.Position.X);
					end
				end);
				UserInputService.InputEnded:Connect(function(input)
					if ((input.UserInputType == Enum.UserInputType.MouseButton1) or (input.UserInputType == Enum.UserInputType.Touch)) then
						self.Dragging = false;
					end
				end);
				fill.Size = UDim2.new((self.Value - self.Min) / (self.Max - self.Min), 0, 1, 0);
				if config.Flag then
					Modules.Config.Register(config.Flag, {Get=function()
						return self.Value;
					end,Set=function(v)
						self.Value = Utility.Clamp(v, self.Min, self.Max);
						valLbl.Text = tostring(self.Value);
						fill.Size = UDim2.new((self.Value - self.Min) / (self.Max - self.Min), 0, 1, 0);
					end});
				end
				Theme.OnChanged:Connect(function()
					self.Instance.BackgroundColor3 = Theme.Get("ElementBackground");
					stroke.Color = Theme.Get("Border");
					titleLbl.TextColor3 = Theme.Get("Text");
					valLbl.TextColor3 = Theme.Get("Accent");
					bar.BackgroundColor3 = Theme.Get("AccentDim");
					fill.BackgroundColor3 = Theme.Get("Accent");
				end);
				return self;
			end;
			return Slider;
		end
		if (FlatIdent_77172 == 0) then
			UserInputService = game:GetService("UserInputService");
			Theme = Modules.Theme;
			FlatIdent_77172 = 1;
		end
		if (2 == FlatIdent_77172) then
			Slider = {};
			Slider.__index = Slider;
			FlatIdent_77172 = 3;
		end
		if (FlatIdent_77172 == 1) then
			Utility = Modules.Utility;
			Animation = Modules.Animation;
			FlatIdent_77172 = 2;
		end
	end
end)();
Modules.Dropdown = (function()
	local Theme = Modules.Theme;
	local Utility = Modules.Utility;
	local Animation = Modules.Animation;
	local Dropdown = {};
	Dropdown.__index = Dropdown;
	Dropdown.new = function(parent, config)
		config = config or {};
		local self = setmetatable({}, Dropdown);
		self.Options = config.Options or {};
		self.Selected = config.Default or self.Options[1] or "";
		self.Open = false;
		self.Instance = Utility.New("Frame", {Name="Dropdown",BackgroundColor3=Theme.Get("ElementBackground"),Size=UDim2.new(1, 0, 0, 36),ClipsDescendants=true,Parent=parent});
		Utility.New("UICorner", {CornerRadius=UDim.new(0, 6),Parent=self.Instance});
		local stroke = Utility.New("UIStroke", {Color=Theme.Get("Border"),Transparency=0.75,Thickness=1,Parent=self.Instance});
		local header = Utility.New("TextButton", {Text="",AutoButtonColor=false,BackgroundTransparency=1,Size=UDim2.new(1, 0, 0, 36),Parent=self.Instance});
		Utility.New("UIPadding", {PaddingLeft=UDim.new(0, 10),PaddingRight=UDim.new(0, 10),Parent=header});
		local lbl = Utility.New("TextLabel", {BackgroundTransparency=1,Size=UDim2.new(1, -20, 1, 0),Text=((config.Title or "Dropdown") .. ": " .. tostring(self.Selected)),Font=Enum.Font.GothamMedium,TextSize=13,TextColor3=Theme.Get("Text"),TextXAlignment=Enum.TextXAlignment.Left,Parent=header});
		local holder = Utility.New("Frame", {Position=UDim2.new(0, 0, 0, 36),Size=UDim2.new(1, 0, 0, 0),BackgroundTransparency=1,Parent=self.Instance});
		Utility.New("UIListLayout", {FillDirection=Enum.FillDirection.Vertical,Padding=UDim.new(0, 2),Parent=holder});
		Utility.New("UIPadding", {PaddingLeft=UDim.new(0, 6),PaddingRight=UDim.new(0, 6),PaddingBottom=UDim.new(0, 6),Parent=holder});
		local function refresh()
			local FlatIdent_3B08E = 0;
			while true do
				if (FlatIdent_3B08E == 0) then
					for _, c in ipairs(holder:GetChildren()) do
						if c:IsA("TextButton") then
							c:Destroy();
						end
					end
					for _, opt in ipairs(self.Options) do
						local FlatIdent_94AF7 = 0;
						local optBtn;
						while true do
							if (FlatIdent_94AF7 == 0) then
								optBtn = Utility.New("TextButton", {Text=opt,AutoButtonColor=false,BackgroundColor3=Theme.Get("Background"),Size=UDim2.new(1, 0, 0, 26),Font=Enum.Font.Gotham,TextSize=12,TextColor3=Theme.Get("SubText"),Parent=holder});
								Utility.New("UICorner", {CornerRadius=UDim.new(0, 4),Parent=optBtn});
								FlatIdent_94AF7 = 1;
							end
							if (FlatIdent_94AF7 == 1) then
								optBtn.MouseButton1Click:Connect(function()
									self.Selected = opt;
									lbl.Text = (config.Title or "Dropdown") .. ": " .. tostring(opt);
									self.Open = false;
									Animation.Tween(self.Instance, Animation.Easing.Fast, {Size=UDim2.new(1, 0, 0, 36)});
									Utility.SafeCall(config.Callback, opt);
								end);
								break;
							end
						end
					end
					break;
				end
			end
		end
		header.MouseButton1Click:Connect(function()
			local FlatIdent_6E549 = 0;
			local targetH;
			while true do
				if (FlatIdent_6E549 == 1) then
					Animation.Tween(self.Instance, Animation.Easing.Smooth, {Size=UDim2.new(1, 0, 0, (self.Open and math.min(targetH, 160)) or 36)});
					break;
				end
				if (FlatIdent_6E549 == 0) then
					self.Open = not self.Open;
					targetH = 36 + (#self.Options * 28) + 8;
					FlatIdent_6E549 = 1;
				end
			end
		end);
		refresh();
		self.Refresh = function(self, list)
			local FlatIdent_D14D = 0;
			while true do
				if (FlatIdent_D14D == 0) then
					self.Options = list;
					refresh();
					break;
				end
			end
		end;
		if config.Flag then
			Modules.Config.Register(config.Flag, {Get=function()
				return self.Selected;
			end,Set=function(v)
				local FlatIdent_803FB = 0;
				while true do
					if (FlatIdent_803FB == 0) then
						self.Selected = v;
						lbl.Text = (config.Title or "Dropdown") .. ": " .. tostring(v);
						break;
					end
				end
			end});
		end
		Theme.OnChanged:Connect(function()
			local FlatIdent_55D83 = 0;
			while true do
				if (FlatIdent_55D83 == 1) then
					lbl.TextColor3 = Theme.Get("Text");
					refresh();
					break;
				end
				if (FlatIdent_55D83 == 0) then
					self.Instance.BackgroundColor3 = Theme.Get("ElementBackground");
					stroke.Color = Theme.Get("Border");
					FlatIdent_55D83 = 1;
				end
			end
		end);
		return self;
	end;
	return Dropdown;
end)();
Modules.ColorPicker = (function()
	local UserInputService = game:GetService("UserInputService");
	local Theme = Modules.Theme;
	local Utility = Modules.Utility;
	local ColorPicker = {};
	ColorPicker.__index = ColorPicker;
	ColorPicker.new = function(parent, config)
		config = config or {};
		local self = setmetatable({}, ColorPicker);
		self.Value = config.Default or Color3.fromRGB(220, 30, 30);
		self.Instance = Utility.New("Frame", {Name="ColorPicker",BackgroundColor3=Theme.Get("ElementBackground"),Size=UDim2.new(1, 0, 0, 100),Parent=parent});
		Utility.New("UICorner", {CornerRadius=UDim.new(0, 6),Parent=self.Instance});
		local stroke = Utility.New("UIStroke", {Color=Theme.Get("Border"),Transparency=0.75,Thickness=1,Parent=self.Instance});
		Utility.New("UIPadding", {PaddingLeft=UDim.new(0, 10),PaddingRight=UDim.new(0, 10),PaddingTop=UDim.new(0, 6),Parent=self.Instance});
		local header = Utility.New("Frame", {BackgroundTransparency=1,Size=UDim2.new(1, 0, 0, 20),Parent=self.Instance});
		local titleLbl = Utility.New("TextLabel", {BackgroundTransparency=1,Size=UDim2.new(1, -30, 1, 0),Text=(config.Title or "Color Picker"),Font=Enum.Font.GothamMedium,TextSize=13,TextColor3=Theme.Get("Text"),TextXAlignment=Enum.TextXAlignment.Left,Parent=header});
		local preview = Utility.New("Frame", {AnchorPoint=Vector2.new(1, 0.5),Position=UDim2.new(1, 0, 0.5, 0),Size=UDim2.fromOffset(20, 20),BackgroundColor3=self.Value,Parent=header});
		Utility.New("UICorner", {CornerRadius=UDim.new(0, 4),Parent=preview});
		local previewStroke = Utility.New("UIStroke", {Color=Theme.Get("Border"),Thickness=1,Parent=preview});
		local r, g, b = math.floor(self.Value.R * 255), math.floor(self.Value.G * 255), math.floor(self.Value.B * 255);
		local fills = {};
		local function makeSlider(name, val, col)
			local row = Utility.New("Frame", {BackgroundTransparency=1,Size=UDim2.new(1, 0, 0, 20),Parent=self.Instance});
			Utility.New("TextLabel", {BackgroundTransparency=1,Size=UDim2.fromOffset(15, 20),Text=name,Font=Enum.Font.GothamBold,TextSize=11,TextColor3=col,Parent=row});
			local bar = Utility.New("Frame", {Position=UDim2.new(0, 18, 0.5, 0),AnchorPoint=Vector2.new(0, 0.5),Size=UDim2.new(1, -18, 0, 4),BackgroundColor3=Theme.Get("AccentDim"),Parent=row});
			Utility.New("UICorner", {CornerRadius=UDim.new(1, 0),Parent=bar});
			local fill = Utility.New("Frame", {Size=UDim2.new(val / 255, 0, 1, 0),BackgroundColor3=col,Parent=bar});
			Utility.New("UICorner", {CornerRadius=UDim.new(1, 0),Parent=fill});
			fills[name] = {bar=bar,fill=fill};
			local dragging = false;
			bar.InputBegan:Connect(function(input)
				if ((input.UserInputType == Enum.UserInputType.MouseButton1) or (input.UserInputType == Enum.UserInputType.Touch)) then
					dragging = true;
				end
			end);
			UserInputService.InputEnded:Connect(function(input)
				if ((input.UserInputType == Enum.UserInputType.MouseButton1) or (input.UserInputType == Enum.UserInputType.Touch)) then
					dragging = false;
				end
			end);
			UserInputService.InputChanged:Connect(function(input)
				if (dragging and ((input.UserInputType == Enum.UserInputType.MouseMovement) or (input.UserInputType == Enum.UserInputType.Touch))) then
					local rel = Utility.Clamp((input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1);
					fill.Size = UDim2.new(rel, 0, 1, 0);
					if (name == "R") then
						r = math.floor((rel * 255) + 0.5);
					elseif (name == "G") then
						g = math.floor((rel * 255) + 0.5);
					elseif (name == "B") then
						b = math.floor((rel * 255) + 0.5);
					end
					self.Value = Color3.fromRGB(r, g, b);
					preview.BackgroundColor3 = self.Value;
					Utility.SafeCall(config.Callback, self.Value);
				end
			end);
		end
		makeSlider("R", r, Color3.fromRGB(255, 80, 80));
		makeSlider("G", g, Color3.fromRGB(80, 255, 100));
		makeSlider("B", b, Color3.fromRGB(80, 150, 255));
		Theme.OnChanged:Connect(function()
			local FlatIdent_86E18 = 0;
			while true do
				if (FlatIdent_86E18 == 1) then
					titleLbl.TextColor3 = Theme.Get("Text");
					previewStroke.Color = Theme.Get("Border");
					FlatIdent_86E18 = 2;
				end
				if (FlatIdent_86E18 == 2) then
					for _, s in pairs(fills) do
						s.bar.BackgroundColor3 = Theme.Get("AccentDim");
					end
					break;
				end
				if (FlatIdent_86E18 == 0) then
					self.Instance.BackgroundColor3 = Theme.Get("ElementBackground");
					stroke.Color = Theme.Get("Border");
					FlatIdent_86E18 = 1;
				end
			end
		end);
		if config.Flag then
			Modules.Config.Register(config.Flag, {Get=function()
				return {r=r,g=g,b=b};
			end,Set=function(v)
				local FlatIdent_3121 = 0;
				while true do
					if (FlatIdent_3121 == 3) then
						if fills.B then
							fills.B.fill.Size = UDim2.new(b / 255, 0, 1, 0);
						end
						break;
					end
					if (FlatIdent_3121 == 2) then
						if fills.R then
							fills.R.fill.Size = UDim2.new(r / 255, 0, 1, 0);
						end
						if fills.G then
							fills.G.fill.Size = UDim2.new(g / 255, 0, 1, 0);
						end
						FlatIdent_3121 = 3;
					end
					if (FlatIdent_3121 == 1) then
						self.Value = Color3.fromRGB(r, g, b);
						preview.BackgroundColor3 = self.Value;
						FlatIdent_3121 = 2;
					end
					if (FlatIdent_3121 == 0) then
						if (typeof(v) ~= "table") then
							return;
						end
						r, g, b = v.r or r, v.g or g, v.b or b;
						FlatIdent_3121 = 1;
					end
				end
			end});
		end
		return self;
	end;
	return ColorPicker;
end)();
Modules.Textbox = (function()
	local Theme = Modules.Theme;
	local Utility = Modules.Utility;
	local Textbox = {};
	Textbox.__index = Textbox;
	Textbox.new = function(parent, config)
		local FlatIdent_1D701 = 0;
		local self;
		local stroke;
		local titleLbl;
		local boxBg;
		local box;
		while true do
			if (FlatIdent_1D701 == 0) then
				config = config or {};
				self = setmetatable({}, Textbox);
				self.Value = config.Default or "";
				FlatIdent_1D701 = 1;
			end
			if (FlatIdent_1D701 == 1) then
				self.Instance = Utility.New("Frame", {Name="Textbox",BackgroundColor3=Theme.Get("ElementBackground"),Size=UDim2.new(1, 0, 0, 50),Parent=parent});
				Utility.New("UICorner", {CornerRadius=UDim.new(0, 6),Parent=self.Instance});
				stroke = Utility.New("UIStroke", {Color=Theme.Get("Border"),Transparency=0.75,Thickness=1,Parent=self.Instance});
				FlatIdent_1D701 = 2;
			end
			if (FlatIdent_1D701 == 2) then
				Utility.New("UIPadding", {PaddingLeft=UDim.new(0, 10),PaddingRight=UDim.new(0, 10),PaddingTop=UDim.new(0, 6),Parent=self.Instance});
				titleLbl = Utility.New("TextLabel", {BackgroundTransparency=1,Size=UDim2.new(1, 0, 0, 16),Text=(config.Title or "Textbox"),Font=Enum.Font.GothamMedium,TextSize=12,TextColor3=Theme.Get("Text"),TextXAlignment=Enum.TextXAlignment.Left,Parent=self.Instance});
				boxBg = Utility.New("Frame", {Position=UDim2.new(0, 0, 0, 22),Size=UDim2.new(1, 0, 0, 22),BackgroundColor3=Theme.Get("Background"),Parent=self.Instance});
				FlatIdent_1D701 = 3;
			end
			if (FlatIdent_1D701 == 4) then
				Theme.OnChanged:Connect(function()
					local FlatIdent_506A5 = 0;
					while true do
						if (FlatIdent_506A5 == 1) then
							titleLbl.TextColor3 = Theme.Get("Text");
							boxBg.BackgroundColor3 = Theme.Get("Background");
							FlatIdent_506A5 = 2;
						end
						if (2 == FlatIdent_506A5) then
							box.TextColor3 = Theme.Get("Text");
							break;
						end
						if (FlatIdent_506A5 == 0) then
							self.Instance.BackgroundColor3 = Theme.Get("ElementBackground");
							stroke.Color = Theme.Get("Border");
							FlatIdent_506A5 = 1;
						end
					end
				end);
				if config.Flag then
					Modules.Config.Register(config.Flag, {Get=function()
						return self.Value;
					end,Set=function(v)
						self.Value = tostring(v);
						box.Text = self.Value;
					end});
				end
				return self;
			end
			if (FlatIdent_1D701 == 3) then
				Utility.New("UICorner", {CornerRadius=UDim.new(0, 4),Parent=boxBg});
				box = Utility.New("TextBox", {BackgroundTransparency=1,Size=UDim2.new(1, 0, 1, 0),Text=self.Value,PlaceholderText=(config.Placeholder or "Type..."),Font=Enum.Font.Gotham,TextSize=12,TextColor3=Theme.Get("Text"),Parent=boxBg});
				box.FocusLost:Connect(function()
					local FlatIdent_35AC5 = 0;
					while true do
						if (FlatIdent_35AC5 == 0) then
							self.Value = box.Text;
							Utility.SafeCall(config.Callback, self.Value);
							break;
						end
					end
				end);
				FlatIdent_1D701 = 4;
			end
		end
	end;
	return Textbox;
end)();
Modules.Paragraph = (function()
	local FlatIdent_14454 = 0;
	local Theme;
	local Utility;
	local Paragraph;
	while true do
		if (FlatIdent_14454 == 2) then
			Paragraph.new = function(parent, config)
				local FlatIdent_5BCFC = 0;
				local self;
				local stroke;
				local titleLbl;
				local contentLbl;
				while true do
					if (FlatIdent_5BCFC == 1) then
						Utility.New("UICorner", {CornerRadius=UDim.new(0, 6),Parent=self.Instance});
						stroke = Utility.New("UIStroke", {Color=Theme.Get("Border"),Transparency=0.8,Thickness=1,Parent=self.Instance});
						Utility.New("UIPadding", {PaddingLeft=UDim.new(0, 10),PaddingRight=UDim.new(0, 10),PaddingTop=UDim.new(0, 8),PaddingBottom=UDim.new(0, 8),Parent=self.Instance});
						FlatIdent_5BCFC = 2;
					end
					if (FlatIdent_5BCFC == 0) then
						config = config or {};
						self = setmetatable({}, Paragraph);
						self.Instance = Utility.New("Frame", {Name="Paragraph",BackgroundColor3=Theme.Get("ElementBackground"),Size=UDim2.new(1, 0, 0, 0),AutomaticSize=Enum.AutomaticSize.Y,Parent=parent});
						FlatIdent_5BCFC = 1;
					end
					if (2 == FlatIdent_5BCFC) then
						Utility.New("UIListLayout", {FillDirection=Enum.FillDirection.Vertical,Padding=UDim.new(0, 4),Parent=self.Instance});
						titleLbl = nil;
						if (config.Title and (config.Title ~= "")) then
							titleLbl = Utility.New("TextLabel", {BackgroundTransparency=1,Size=UDim2.new(1, 0, 0, 16),Text=config.Title,Font=Enum.Font.GothamBold,TextSize=13,TextColor3=Theme.Get("Text"),TextXAlignment=Enum.TextXAlignment.Left,Parent=self.Instance});
						end
						FlatIdent_5BCFC = 3;
					end
					if (FlatIdent_5BCFC == 3) then
						contentLbl = Utility.New("TextLabel", {BackgroundTransparency=1,Size=UDim2.new(1, 0, 0, 0),AutomaticSize=Enum.AutomaticSize.Y,Text=(config.Content or ""),Font=Enum.Font.Gotham,TextSize=12,TextColor3=Theme.Get("SubText"),TextWrapped=true,TextXAlignment=Enum.TextXAlignment.Left,Parent=self.Instance});
						Theme.OnChanged:Connect(function()
							local FlatIdent_669F5 = 0;
							while true do
								if (1 == FlatIdent_669F5) then
									if titleLbl then
										titleLbl.TextColor3 = Theme.Get("Text");
									end
									contentLbl.TextColor3 = Theme.Get("SubText");
									break;
								end
								if (FlatIdent_669F5 == 0) then
									self.Instance.BackgroundColor3 = Theme.Get("ElementBackground");
									stroke.Color = Theme.Get("Border");
									FlatIdent_669F5 = 1;
								end
							end
						end);
						return self;
					end
				end
			end;
			return Paragraph;
		end
		if (FlatIdent_14454 == 0) then
			Theme = Modules.Theme;
			Utility = Modules.Utility;
			FlatIdent_14454 = 1;
		end
		if (FlatIdent_14454 == 1) then
			Paragraph = {};
			Paragraph.__index = Paragraph;
			FlatIdent_14454 = 2;
		end
	end
end)();
Modules.Label = (function()
	local FlatIdent_4D11E = 0;
	local Theme;
	local Utility;
	local Label;
	while true do
		if (FlatIdent_4D11E == 0) then
			Theme = Modules.Theme;
			Utility = Modules.Utility;
			FlatIdent_4D11E = 1;
		end
		if (FlatIdent_4D11E == 2) then
			Label.new = function(parent, config)
				config = config or {};
				local self = setmetatable({}, Label);
				self.Instance = Utility.New("TextLabel", {Name="Label",BackgroundTransparency=1,Size=UDim2.new(1, 0, 0, 20),Text=(config.Text or "Label"),Font=Enum.Font.Gotham,TextSize=12,TextColor3=Theme.Get("SubText"),TextXAlignment=Enum.TextXAlignment.Left,Parent=parent});
				Theme.OnChanged:Connect(function()
					self.Instance.TextColor3 = Theme.Get("SubText");
				end);
				return self;
			end;
			return Label;
		end
		if (FlatIdent_4D11E == 1) then
			Label = {};
			Label.__index = Label;
			FlatIdent_4D11E = 2;
		end
	end
end)();
Modules.Section = (function()
	local Theme = Modules.Theme;
	local Utility = Modules.Utility;
	local Section = {};
	Section.__index = Section;
	Section.new = function(parent, config)
		local FlatIdent_1CFC3 = 0;
		local self;
		local stroke;
		local titleLbl;
		while true do
			if (FlatIdent_1CFC3 == 0) then
				config = config or {};
				self = setmetatable({}, Section);
				self.Instance = Utility.New("Frame", {Name="Section",BackgroundColor3=Theme.Get("SecondaryBackground"),Size=UDim2.new(1, 0, 0, 0),AutomaticSize=Enum.AutomaticSize.Y,Parent=parent});
				FlatIdent_1CFC3 = 1;
			end
			if (FlatIdent_1CFC3 == 2) then
				titleLbl = Utility.New("TextLabel", {BackgroundTransparency=1,Size=UDim2.new(1, 0, 0, 16),Text=(config.Title or "Section"),Font=Enum.Font.GothamBold,TextSize=13,TextColor3=Theme.Get("Accent"),TextXAlignment=Enum.TextXAlignment.Left,Parent=self.Instance});
				self.Content = Utility.New("Frame", {BackgroundTransparency=1,Position=UDim2.new(0, 0, 0, 20),Size=UDim2.new(1, 0, 0, 0),AutomaticSize=Enum.AutomaticSize.Y,Parent=self.Instance});
				Utility.New("UIListLayout", {FillDirection=Enum.FillDirection.Vertical,Padding=UDim.new(0, 6),Parent=self.Content});
				FlatIdent_1CFC3 = 3;
			end
			if (FlatIdent_1CFC3 == 1) then
				Utility.New("UICorner", {CornerRadius=UDim.new(0, 8),Parent=self.Instance});
				stroke = Utility.New("UIStroke", {Color=Theme.Get("Border"),Transparency=0.8,Thickness=1,Parent=self.Instance});
				Utility.New("UIPadding", {PaddingLeft=UDim.new(0, 8),PaddingRight=UDim.new(0, 8),PaddingTop=UDim.new(0, 8),PaddingBottom=UDim.new(0, 8),Parent=self.Instance});
				FlatIdent_1CFC3 = 2;
			end
			if (FlatIdent_1CFC3 == 3) then
				Theme.OnChanged:Connect(function()
					self.Instance.BackgroundColor3 = Theme.Get("SecondaryBackground");
					stroke.Color = Theme.Get("Border");
					titleLbl.TextColor3 = Theme.Get("Accent");
				end);
				return self;
			end
		end
	end;
	Section.CreateButton = function(self, cfg)
		return Modules.Button.new(self.Content, cfg);
	end;
	Section.CreateToggle = function(self, cfg)
		return Modules.Toggle.new(self.Content, cfg);
	end;
	Section.CreateSlider = function(self, cfg)
		return Modules.Slider.new(self.Content, cfg);
	end;
	Section.CreateDropdown = function(self, cfg)
		return Modules.Dropdown.new(self.Content, cfg);
	end;
	Section.CreateTextbox = function(self, cfg)
		return Modules.Textbox.new(self.Content, cfg);
	end;
	Section.CreateParagraph = function(self, cfg)
		return Modules.Paragraph.new(self.Content, cfg);
	end;
	Section.CreateLabel = function(self, cfg)
		return Modules.Label.new(self.Content, cfg);
	end;
	Section.CreateColorPicker = function(self, cfg)
		return Modules.ColorPicker.new(self.Content, cfg);
	end;
	Section.CreateDivider = function(self)
		local FlatIdent_4058F = 0;
		local line;
		while true do
			if (FlatIdent_4058F == 1) then
				return line;
			end
			if (FlatIdent_4058F == 0) then
				line = Utility.New("Frame", {Name="Divider",BackgroundColor3=Theme.Get("Border"),BackgroundTransparency=0.75,Size=UDim2.new(1, 0, 0, 1),Parent=self.Content});
				Theme.OnChanged:Connect(function()
					line.BackgroundColor3 = Theme.Get("Border");
				end);
				FlatIdent_4058F = 1;
			end
		end
	end;
	Section.CreateImage = function(self, cfg)
		local FlatIdent_243F3 = 0;
		local frame;
		local stroke;
		local img;
		while true do
			if (FlatIdent_243F3 == 2) then
				img = Utility.New("ImageLabel", {BackgroundTransparency=1,Size=UDim2.fromScale(1, 1),Image=(cfg.Image or ""),ScaleType=Enum.ScaleType.Crop,Parent=frame});
				Theme.OnChanged:Connect(function()
					frame.BackgroundColor3 = Theme.Get("ElementBackground");
					stroke.Color = Theme.Get("Border");
				end);
				FlatIdent_243F3 = 3;
			end
			if (FlatIdent_243F3 == 1) then
				Utility.New("UICorner", {CornerRadius=UDim.new(0, 6),Parent=frame});
				stroke = Utility.New("UIStroke", {Color=Theme.Get("Border"),Transparency=0.75,Thickness=1,Parent=frame});
				FlatIdent_243F3 = 2;
			end
			if (FlatIdent_243F3 == 0) then
				cfg = cfg or {};
				frame = Utility.New("Frame", {Name="Image",BackgroundColor3=Theme.Get("ElementBackground"),Size=UDim2.new(1, 0, 0, cfg.Height or 120),ClipsDescendants=true,Parent=self.Content});
				FlatIdent_243F3 = 1;
			end
			if (3 == FlatIdent_243F3) then
				return {Instance=frame,Image=img};
			end
		end
	end;
	Section.CreateThemeDropdown = function(self, cfg)
		local FlatIdent_91A09 = 0;
		while true do
			if (FlatIdent_91A09 == 0) then
				cfg = cfg or {};
				return self:CreateDropdown({Title=(cfg.Title or "ธีม"),Options=Theme.Order,Default=Theme.Current,Callback=function(name)
					Theme.Set(name);
				end});
			end
		end
	end;
	Section.CreateKeybind = function(self, cfg)
		local FlatIdent_77CC3 = 0;
		local UserInputService;
		local keybind;
		local inst;
		local keyBtn;
		while true do
			if (FlatIdent_77CC3 == 2) then
				Utility.New("UIPadding", {PaddingLeft=UDim.new(0, 10),PaddingRight=UDim.new(0, 10),Parent=inst});
				Utility.New("TextLabel", {BackgroundTransparency=1,Size=UDim2.new(1, -70, 1, 0),Text=(cfg.Title or "Keybind"),Font=Enum.Font.GothamMedium,TextSize=13,TextColor3=Theme.Get("Text"),TextXAlignment=Enum.TextXAlignment.Left,Parent=inst});
				keyBtn = Utility.New("TextButton", {AnchorPoint=Vector2.new(1, 0.5),Position=UDim2.new(1, 0, 0.5, 0),Size=UDim2.fromOffset(60, 22),BackgroundColor3=Theme.Get("Background"),Text=keybind.Value.Name,Font=Enum.Font.GothamBold,TextSize=11,TextColor3=Theme.Get("Accent"),AutoButtonColor=false,Parent=inst});
				FlatIdent_77CC3 = 3;
			end
			if (4 == FlatIdent_77CC3) then
				if cfg.Flag then
					Modules.Config.Register(cfg.Flag, {Get=function()
						return keybind.Value.Name;
					end,Set=function(name)
						local FlatIdent_8770C = 0;
						local ok;
						local item;
						while true do
							if (FlatIdent_8770C == 0) then
								ok, item = pcall(function()
									return Enum.KeyCode[name];
								end);
								if (ok and item) then
									local FlatIdent_6F3E4 = 0;
									while true do
										if (FlatIdent_6F3E4 == 0) then
											keybind.Value = item;
											keyBtn.Text = item.Name;
											break;
										end
									end
								end
								break;
							end
						end
					end});
				end
				return keybind;
			end
			if (FlatIdent_77CC3 == 1) then
				inst = Utility.New("Frame", {Name="Keybind",BackgroundColor3=Theme.Get("ElementBackground"),Size=UDim2.new(1, 0, 0, 36),Parent=self.Content});
				Utility.New("UICorner", {CornerRadius=UDim.new(0, 6),Parent=inst});
				Utility.New("UIStroke", {Color=Theme.Get("Border"),Transparency=0.75,Thickness=1,Parent=inst});
				FlatIdent_77CC3 = 2;
			end
			if (FlatIdent_77CC3 == 3) then
				Utility.New("UICorner", {CornerRadius=UDim.new(0, 4),Parent=keyBtn});
				keyBtn.MouseButton1Click:Connect(function()
					keybind.Listening = true;
					keyBtn.Text = "...";
				end);
				UserInputService.InputBegan:Connect(function(input, processed)
					if (keybind.Listening and (input.UserInputType == Enum.UserInputType.Keyboard)) then
						local FlatIdent_92569 = 0;
						while true do
							if (FlatIdent_92569 == 0) then
								keybind.Value = input.KeyCode;
								keyBtn.Text = input.KeyCode.Name;
								FlatIdent_92569 = 1;
							end
							if (1 == FlatIdent_92569) then
								keybind.Listening = false;
								return;
							end
						end
					end
					if (not processed and not keybind.Listening and (input.UserInputType == Enum.UserInputType.Keyboard) and (input.KeyCode == keybind.Value)) then
						Utility.SafeCall(cfg.Callback);
					end
				end);
				FlatIdent_77CC3 = 4;
			end
			if (0 == FlatIdent_77CC3) then
				cfg = cfg or {};
				UserInputService = game:GetService("UserInputService");
				keybind = {Value=(cfg.Default or Enum.KeyCode.Unknown),Listening=false};
				FlatIdent_77CC3 = 1;
			end
		end
	end;
	return Section;
end)();
Modules.Tab = (function()
	local Theme = Modules.Theme;
	local Utility = Modules.Utility;
	local Animation = Modules.Animation;
	local Tab = {};
	Tab.__index = Tab;
	Tab.new = function(window, tabListParent, pageParent, config)
		config = config or {};
		local self = setmetatable({}, Tab);
		self.Window = window;
		self.Button = Utility.New("TextButton", {Name="TabBtn",Text="",AutoButtonColor=false,BackgroundTransparency=1,Size=UDim2.new(1, 0, 0, 32),Parent=tabListParent});
		Utility.New("UICorner", {CornerRadius=UDim.new(0, 6),Parent=self.Button});
		Utility.New("UIPadding", {PaddingLeft=UDim.new(0, 8),Parent=self.Button});
		self.Indicator = Utility.New("Frame", {Size=UDim2.new(0, 2, 0, 14),Position=UDim2.new(0, 0, 0.5, 0),AnchorPoint=Vector2.new(0, 0.5),BackgroundColor3=Theme.Get("Accent"),BackgroundTransparency=1,Parent=self.Button});
		Utility.New("UICorner", {CornerRadius=UDim.new(1, 0),Parent=self.Indicator});
		self.Label = Utility.New("TextLabel", {Position=UDim2.new(0, 8, 0, 0),Size=UDim2.new(1, -8, 1, 0),BackgroundTransparency=1,Text=(config.Title or "Tab"),Font=Enum.Font.GothamMedium,TextSize=12,TextColor3=Theme.Get("SubText"),TextXAlignment=Enum.TextXAlignment.Left,Parent=self.Button});
		self.Page = Utility.New("ScrollingFrame", {Name="Page",BackgroundTransparency=1,Size=UDim2.fromScale(1, 1),CanvasSize=UDim2.new(0, 0, 0, 0),AutomaticCanvasSize=Enum.AutomaticSize.Y,ScrollBarThickness=2,Visible=false,Parent=pageParent});
		Utility.New("UIListLayout", {FillDirection=Enum.FillDirection.Vertical,Padding=UDim.new(0, 8),Parent=self.Page});
		Utility.New("UIPadding", {PaddingLeft=UDim.new(0, 2),PaddingRight=UDim.new(0, 6),PaddingTop=UDim.new(0, 2),Parent=self.Page});
		self.Button.MouseButton1Click:Connect(function()
			self.Window:SelectTab(self);
		end);
		Theme.OnChanged:Connect(function()
			local FlatIdent_59C45 = 0;
			while true do
				if (FlatIdent_59C45 == 0) then
					self.Indicator.BackgroundColor3 = Theme.Get("Accent");
					self.Label.TextColor3 = (self.Active and Theme.Get("Text")) or Theme.Get("SubText");
					break;
				end
			end
		end);
		return self;
	end;
	Tab.CreateSection = function(self, cfg)
		return Modules.Section.new(self.Page, cfg);
	end;
	Tab.SetActive = function(self, active)
		local FlatIdent_31791 = 0;
		while true do
			if (FlatIdent_31791 == 0) then
				self.Active = active;
				self.Page.Visible = active;
				FlatIdent_31791 = 1;
			end
			if (1 == FlatIdent_31791) then
				Animation.Tween(self.Indicator, Animation.Easing.Normal, {BackgroundTransparency=((active and 0) or 1)});
				Animation.Tween(self.Label, Animation.Easing.Normal, {TextColor3=((active and Theme.Get("Text")) or Theme.Get("SubText"))});
				break;
			end
		end
	end;
	return Tab;
end)();
Modules.Window = (function()
	local Players = game:GetService("Players");
	local Theme = Modules.Theme;
	local Utility = Modules.Utility;
	local Animation = Modules.Animation;
	local Window = {};
	Window.__index = Window;
	Window.new = function(config)
		config = config or {};
		local self = setmetatable({}, Window);
		self.Tabs = {};
		self.ActiveTab = nil;
		self.Minimized = false;
		local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui");
		self.ScreenGui = Utility.New("ScreenGui", {Name="PISIT_HUB",ResetOnSpawn=false,Parent=playerGui});
		self.Main = Utility.New("Frame", {Name="Main",AnchorPoint=Vector2.new(0.5, 0.5),Position=UDim2.fromScale(0.5, 0.5),Size=UDim2.fromOffset(400, 320),BackgroundColor3=Theme.Get("Background"),ClipsDescendants=true,Parent=self.ScreenGui});
		Utility.New("UICorner", {CornerRadius=UDim.new(0, 10),Parent=self.Main});
		self.MainStroke = Utility.New("UIStroke", {Color=Theme.Get("Border"),Thickness=1.2,Transparency=0.2,Parent=self.Main});
		self:_buildTopBar(config.Title or "PISIT HUB");
		self:_buildBody();
		self:_buildTogglePill();
		Modules.Notification.Init(self.ScreenGui);
		Utility.MakeDraggable(self.Main, self.TopBar);
		Utility.MakeDraggable(self.TogglePill);
		Animation.OpenWindow(self.Main);
		Theme.OnChanged:Connect(function()
			self.Main.BackgroundColor3 = Theme.Get("Background");
			self.MainStroke.Color = Theme.Get("Border");
			self.TopBar.BackgroundColor3 = Theme.Get("SecondaryBackground");
			self.TitleLabel.TextColor3 = Theme.Get("Accent");
			self.CloseBtn.BackgroundColor3 = Theme.Get("ElementBackground");
			self.CloseBtn.TextColor3 = Theme.Get("Text");
			self.MinBtn.BackgroundColor3 = Theme.Get("ElementBackground");
			self.MinBtn.TextColor3 = Theme.Get("Text");
			self.Sidebar.BackgroundColor3 = Theme.Get("SecondaryBackground");
			self.TogglePill.BackgroundColor3 = Theme.Get("SecondaryBackground");
			self.PillStroke.Color = Theme.Get("Accent");
			self.PillLabel.TextColor3 = Theme.Get("Text");
		end);
		return self;
	end;
	Window._buildTopBar = function(self, titleText)
		local FlatIdent_93FA5 = 0;
		while true do
			if (FlatIdent_93FA5 == 1) then
				Utility.New("UIPadding", {PaddingLeft=UDim.new(0, 12),PaddingRight=UDim.new(0, 8),Parent=self.TopBar});
				self.TitleLabel = Utility.New("TextLabel", {BackgroundTransparency=1,Size=UDim2.new(1, -65, 1, 0),Text=titleText,Font=Enum.Font.GothamBold,TextSize=13,TextColor3=Theme.Get("Accent"),TextXAlignment=Enum.TextXAlignment.Left,Parent=self.TopBar});
				FlatIdent_93FA5 = 2;
			end
			if (FlatIdent_93FA5 == 3) then
				self.CloseBtn.MouseButton1Click:Connect(function()
					self.ScreenGui:Destroy();
				end);
				self.MinBtn = Utility.New("TextButton", {AnchorPoint=Vector2.new(1, 0.5),Position=UDim2.new(1, -50, 0.5, 0),Size=UDim2.fromOffset(24, 24),BackgroundColor3=Theme.Get("ElementBackground"),Text="-",Font=Enum.Font.GothamBold,TextSize=13,TextColor3=Theme.Get("Text"),AutoButtonColor=false,Parent=self.TopBar});
				FlatIdent_93FA5 = 4;
			end
			if (FlatIdent_93FA5 == 2) then
				self.CloseBtn = Utility.New("TextButton", {AnchorPoint=Vector2.new(1, 0.5),Position=UDim2.new(1, 0, 0.5, 0),Size=UDim2.fromOffset(24, 24),BackgroundColor3=Theme.Get("ElementBackground"),Text="x",Font=Enum.Font.GothamBold,TextSize=13,TextColor3=Theme.Get("Text"),AutoButtonColor=false,Parent=self.TopBar});
				Utility.New("UICorner", {CornerRadius=UDim.new(0, 5),Parent=self.CloseBtn});
				FlatIdent_93FA5 = 3;
			end
			if (4 == FlatIdent_93FA5) then
				Utility.New("UICorner", {CornerRadius=UDim.new(0, 5),Parent=self.MinBtn});
				self.MinBtn.MouseButton1Click:Connect(function()
					local FlatIdent_202CC = 0;
					while true do
						if (FlatIdent_202CC == 0) then
							self.Minimized = true;
							Animation.CloseWindow(self.Main, function()
								self.TogglePill.Visible = true;
							end);
							break;
						end
					end
				end);
				break;
			end
			if (0 == FlatIdent_93FA5) then
				self.TopBar = Utility.New("Frame", {Name="TopBar",BackgroundColor3=Theme.Get("SecondaryBackground"),Size=UDim2.new(1, 0, 0, 40),Parent=self.Main});
				Utility.New("UICorner", {CornerRadius=UDim.new(0, 10),Parent=self.TopBar});
				FlatIdent_93FA5 = 1;
			end
		end
	end;
	Window._buildBody = function(self)
		self.Body = Utility.New("Frame", {Name="Body",Position=UDim2.new(0, 0, 0, 40),Size=UDim2.new(1, 0, 1, -40),BackgroundTransparency=1,Parent=self.Main});
		self.Sidebar = Utility.New("ScrollingFrame", {Name="Sidebar",BackgroundColor3=Theme.Get("SecondaryBackground"),Size=UDim2.new(0, 110, 1, 0),CanvasSize=UDim2.new(0, 0, 0, 0),AutomaticCanvasSize=Enum.AutomaticSize.Y,ScrollBarThickness=2,Parent=self.Body});
		Utility.New("UIPadding", {PaddingLeft=UDim.new(0, 6),PaddingRight=UDim.new(0, 6),PaddingTop=UDim.new(0, 6),Parent=self.Sidebar});
		Utility.New("UIListLayout", {FillDirection=Enum.FillDirection.Vertical,Padding=UDim.new(0, 3),Parent=self.Sidebar});
		self.PageContainer = Utility.New("Frame", {Name="PageContainer",Position=UDim2.new(0, 110, 0, 0),Size=UDim2.new(1, -110, 1, 0),BackgroundTransparency=1,Parent=self.Body});
	end;
	Window._buildTogglePill = function(self)
		local FlatIdent_33F65 = 0;
		local pillStroke;
		while true do
			if (FlatIdent_33F65 == 3) then
				self.TogglePill.MouseButton1Click:Connect(function()
					local FlatIdent_21387 = 0;
					while true do
						if (FlatIdent_21387 == 0) then
							self.Minimized = false;
							self.TogglePill.Visible = false;
							FlatIdent_21387 = 1;
						end
						if (FlatIdent_21387 == 1) then
							Animation.OpenWindow(self.Main);
							break;
						end
					end
				end);
				break;
			end
			if (FlatIdent_33F65 == 0) then
				self.TogglePill = Utility.New("TextButton", {Name="TogglePill",Text="",AutoButtonColor=false,AnchorPoint=Vector2.new(0.5, 0),Position=UDim2.new(0.5, 0, 0, 16),Size=UDim2.fromOffset(150, 38),BackgroundColor3=Theme.Get("SecondaryBackground"),Visible=false,Parent=self.ScreenGui});
				Utility.New("UICorner", {CornerRadius=UDim.new(1, 0),Parent=self.TogglePill});
				FlatIdent_33F65 = 1;
			end
			if (FlatIdent_33F65 == 2) then
				self.PillLabel = Utility.New("TextLabel", {BackgroundTransparency=1,Size=UDim2.new(1, -16, 1, 0),Position=UDim2.new(0, 16, 0, 0),Text="เปิด PISIT HUB",Font=Enum.Font.GothamBold,TextSize=13,TextColor3=Theme.Get("Text"),TextXAlignment=Enum.TextXAlignment.Left,Parent=self.TogglePill});
				task.spawn(function()
					while self.TogglePill.Parent do
						if self.TogglePill.Visible then
							local FlatIdent_810FF = 0;
							while true do
								if (FlatIdent_810FF == 0) then
									Animation.Glow(pillStroke, true);
									task.wait(0.8);
									FlatIdent_810FF = 1;
								end
								if (FlatIdent_810FF == 1) then
									Animation.Glow(pillStroke, false);
									task.wait(0.8);
									break;
								end
							end
						else
							task.wait(0.3);
						end
					end
				end);
				FlatIdent_33F65 = 3;
			end
			if (FlatIdent_33F65 == 1) then
				self.PillStroke = Utility.New("UIStroke", {Color=Theme.Get("Accent"),Thickness=1.5,Transparency=0.1,Parent=self.TogglePill});
				pillStroke = self.PillStroke;
				FlatIdent_33F65 = 2;
			end
		end
	end;
	Window.CreateTab = function(self, config)
		local FlatIdent_C758 = 0;
		local tab;
		while true do
			if (FlatIdent_C758 == 0) then
				tab = Modules.Tab.new(self, self.Sidebar, self.PageContainer, config);
				table.insert(self.Tabs, tab);
				FlatIdent_C758 = 1;
			end
			if (FlatIdent_C758 == 1) then
				if (#self.Tabs == 1) then
					self:SelectTab(tab);
				end
				return tab;
			end
		end
	end;
	Window.SelectTab = function(self, tab)
		if self.ActiveTab then
			self.ActiveTab:SetActive(false);
		end
		self.ActiveTab = tab;
		tab:SetActive(true);
	end;
	return Window;
end)();
local Library = {};
Library._version = "2.2.0";
Library.CreateWindow = function(self, config)
	return Modules.Window.new(config);
end;
Library.Notify = function(self, data)
	Modules.Notification.Notify(data);
end;
Library.SaveConfig = function(self, name)
	return Modules.Config.Save(name);
end;
Library.LoadConfig = function(self, name)
	return Modules.Config.Load(name);
end;
Library.EnableAutoSave = function(self, name, interval)
	return Modules.Config.EnableAutoSave(name, interval);
end;
Library.DisableAutoSave = function(self)
	return Modules.Config.DisableAutoSave();
end;
Library.SetTheme = function(self, name)
	return Modules.Theme.Set(name);
end;
Library.GetThemes = function(self)
	return Modules.Theme.Order;
end;
return Library;