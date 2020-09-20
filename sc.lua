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
	local function BuildServiceRemotes(Service)
		if Service.Client then
			for i,index in pairs(Service.Client.Events) do
				if not Remotes:FindFirstChild(tostring(index.Event)) then
					local Re = Instance.new("RemoteEvent")
					Re.Name = tostring(index.Event)
					if (type(index.Func) == "function") then
						Re.OnServerEvent:Connect(index.Func)
					end
					Re.Parent = Remotes
					Service.RemoteEvents[tostring(index.Event)] = Re
				end
			end
			for i,index in pairs(Service.Client.Functions) do
				if not Remotes:FindFirstChild(tostring(index.Name)) then
					local Re = Instance.new("RemoteFunction")
					Re.Name = tostring(index.Name)
					if (type(index.Func) == "function") then
						Re.OnServerInvoke = index.Func
					end
					Service.RemoteFunctions = Re
					Re.Parent = Remotes
				end
			end
		end
	end
	local function InitService(Service)
		Service.RemoteEvents = {}
		Service.RemoteFunctions = {}
		BuildServiceRemotes(Service)
		if (type(Service.Init) == "function") then
			for i,v in pairs(Framework) do
			if tostring(v) ~= tostring(Service) then
				Service[i] = v
			end
		end
			Service:Init()
		end
	end
	local function StartServices(Services)
		
		for i,Service in pairs(Services) do
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
	local function StartLeaving(Services)
		for i,Service in pairs(Services) do
			if (type(Service.PlayerLeaving) == "function") then
				game.Players.PlayerRemoving:Connect(Service.PlayerLeaving)
			end
		end
	end
	ModuleToService()
	InitAllServices(Framework)
	StartServices(Framework)
	StartPlayerAdded(Framework)
	StartLeaving(Framework)
end
Build()
Loaded.Value = true
