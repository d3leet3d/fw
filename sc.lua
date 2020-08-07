local ScriptService = script.Parent
local ServerStorage = game:GetService("ServerStorage")
local Remotes = Instance.new("Folder")
Remotes.Name = "Remotes"
Remotes.Parent = game.ReplicatedStorage:WaitForChild("LeetsFrameWorkClient")
local Loaded = game.ReplicatedStorage:WaitForChild("LeetsFrameWorkClient"):WaitForChild("Loaded")
local Framework = {}
local Mt = {__Index = Framework}
local Players
function Build()
	local function InitService(Service)
		if (type(Service.Init) == "function") then
			for i,v in pairs(Framework) do
			if tostring(v) ~= tostring(Service) then
				Service[i] = v
			end
		end
			Service:Init()
		end
	end
	local function BuildServiceRemotes(Service)
		if Service.Client then
			for i,Event in pairs(Service.Client.Events) do
				if not Remotes:FindFirstChild(tostring(Event)) then
					local Re = Instance.new("RemoteEvent")
					Re.Name = tostring(Event)
					Re.Parent = Remotes
					Service.Client.Events[tostring(Event)] = Re
				end
			end
			for i,Func in pairs(Service.Client.Functions) do
				if not Remotes:FindFirstChild(tostring(Func)) then
					local Re = Instance.new("RemoteFunction")
					Re.Name = tostring(Func)
					Re.Parent = Remotes
					Service.Client.Events[tostring(Func)] = Re
				end
			end
		end
	end
	local function StartServices(Services)
		
		for i,Service in pairs(Services) do
			BuildServiceRemotes(Service)
			if (type(Service.Start) == "function") then
				coroutine.resume(coroutine.create(Service.Start))
			end
			
		end
	end
	
	local function InstallService(Module)
		local Service = require(Module)
		Framework[Module.Name] = Service
		setmetatable(Service,Mt)
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
		local ModuleFolder = ServerStorage:WaitForChild("ServerModules")
		for _,Module in pairs(ModuleFolder:GetChildren()) do
			if Module:IsA("ModuleScript") then
				InstallService(Module)
			end
		end
	end
	local function StartPlayerAdded(Services)
		for i,Service in pairs(Services) do
			if (type(Service.PlayerAdded) == "function") then
				game.Players.PlayerAdded:Connect(Service.PlayerAdded)
				for _,Player in pairs(game.Players:GetPlayers()) do
					Service:PlayerAdded(Player)
				end
			end
		end
	end
	ModuleToService()
	InitAllServices(Framework)
	StartServices(Framework)
	StartPlayerAdded(Framework)
end
Build()
Loaded.Value = true
