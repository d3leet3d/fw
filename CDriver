local Player = game.Players.LocalPlayer
local UserInput = game:GetService("UserInputService")
local Character
repeat wait()
	Character = Player.Character
until Character

local Rs = game:GetService("RunService")
local Fw = game.ReplicatedStorage:WaitForChild("LeetsFrameWorkClient")
Remotes = Fw:WaitForChild("Remotes")
local Framework = {}
local Mt = {__Index = Framework}
function Build()
	local function InitService(Service)
		if (type(Service.Init) == "function") then
			Service.Player = Player
			Service.Remotes = Remotes
			for i,v in pairs(Framework) do
				if tostring(v) ~= tostring(Service) then
					Service[i] = v
				end
			end
			local S,E = pcall(function()
				Service:Init()
			end)
			if not S then
				warn("Controller".." Init Failed:"..E)
			end
		end
	end

	local function StartServices(Services)
		for i,Service in pairs(Services) do
			if (type(Service.Start) == "function") then
				coroutine.resume(coroutine.create(function()
					local S,E = pcall(function()
						Service:Start()
					end)
					if not S then
						warn("Controller <".. tostring(i) .."> Start Failed:"..E)
					end
				end))
			end
		end
	end

	local function InstallService(Module)
		local Service = require(Module)
		Framework[Module.Name] = Service
		setmetatable(Service,Mt)
		Service.CC = {}
		function Service:OnCharacterAdded(Callback)
			table.insert(Service.CC,Callback)
		end
		function Service:UserInput(Callback,Input,TargetKey)
			if Input == "Began" then
				if TargetKey ~= nil then
					UserInput.InputBegan:Connect(function(_Input,Typing)
						if not Typing then
							if _Input.KeyCode == TargetKey then
								Callback()
							end
						end
					end)
				elseif TargetKey == nil then
					UserInput.InputBegan:Connect(Callback)
				end
			elseif Input == "Ended" then
				if TargetKey ~= nil then
					UserInput.InputEnded:Connect(function(_Input,Typing)
						if not Typing then
							if _Input.KeyCode == TargetKey then
								Callback()
							end
						end
					end)
				elseif TargetKey == nil then
					UserInput.InputEnded:Connect(Callback)
				end
			end
		end
	end

	local function InitAllServices(Services)
		local serviceTables = {}
		local function CollectServices(_services)
			for _,service in pairs(_services) do
				if (getmetatable(service) == Mt) then
					serviceTables[#serviceTables + 1] = service
				else
					CollectServices(service)
				end
			end
		end
		CollectServices(Services)
		table.sort(serviceTables,function(a,b)
			local AOrder = (type(a.__LoadOrder) == "number" and a.__LoadOrder or math.huge)
			local BOrder = (type(b.__LoadOrder) == "number" and b.__LoadOrder or math.huge)
			return (AOrder < BOrder)
		end)
		for _,Service in ipairs(serviceTables) do
			InitService(Service)
		end
	end
	local function ModuleToService()
		for _,Module in pairs(Fw:WaitForChild("ClientModules"):GetChildren()) do
			if Module:IsA("ModuleScript") then
				InstallService(Module:Clone())
			end
		end
		game.Debris:AddItem(Fw:WaitForChild("ClientModules"),1)
	end
	local function UpDateCharacter(Services)
		for i,Service in pairs(Services) do
			Service.Character = Character
			local function StartCallBack(Character)
				if #Service.CC > 0 then
					for i,Callback in pairs(Service.CC) do
						Callback(Character)
					end
				end
			end
			StartCallBack(Character)
			Player.CharacterAdded:Connect(function(Char) 
				Service.Character = Char
				StartCallBack(Char)
			end)
		end
	end
	local function StartUpDate(Services)
		for i,Service in pairs(Services) do
			if (type(Service.Update) == "function") then
				Rs.RenderStepped:Connect(Service.Update)
			end
		end
	end
	ModuleToService()
	InitAllServices(Framework)
	StartServices(Framework)
	UpDateCharacter(Framework)
	StartUpDate(Framework)
end
repeat wait() until Fw:WaitForChild("Loaded").Value == true
Build()
