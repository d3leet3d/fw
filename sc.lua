local ScriptService = script.Parent
local ServerStorage = game:GetService("ServerStorage")
local Framework = {}
local Mt = {__Index = Framework}

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
	
	local function StartServices(Services)
		for i,Service in pairs(Services) do
			if (type(Service.Start) == "function") then
				local function Start()
					Service:Start()
				end
				coroutine.resume(coroutine.create(Start))
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
	ModuleToService()
	InitAllServices(Framework)
	StartServices(Framework)
end
Build()
