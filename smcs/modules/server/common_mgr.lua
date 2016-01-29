----------------------------------------
--$Id: common_mgr.lua 88435 2015-09-09 04:07:24Z xiongyunkun $
----------------------------------------
--[[
-- 通用操作
--
--]]

-- 获得json数据封装的对应平台的服务器列表
function GetJsonServer(self)
	local Args = GetPostArgs()
	local PlatformID = Args.PlatformID
	local ServList = MixServerData:Get({PlatformID = PlatformID})
	local ServerInfoList = ServerData:GetAllServers()
	local ServerInfoMap = {}
	for _, Info in ipairs(ServerInfoList) do
		ServerInfoMap[Info.hostid] = Info.name
	end 
	local ServerMap = {}
	for _ , Server in ipairs(ServList) do
		ServerMap[tostring(Server.HostID)] = ServerInfoMap[Server.HostID] or ""
	end
	local JsonStr = json.encode(ServerMap)
	ngx.say(JsonStr)
end

--获得json数据封装的对应平台的合服之后的服务器列表
function GetJsonMergeServer(self)
	local Args = GetPostArgs()
	local ServerMap = ServerData:GetMergedServers(Args)
	local NewServerMap = {}
	for HostID, Name in pairs(ServerMap) do
		NewServerMap[tostring(HostID)] = Name
	end
	local JsonStr = json.encode(NewServerMap)
	ngx.say(JsonStr)
end

DoRequest(true)