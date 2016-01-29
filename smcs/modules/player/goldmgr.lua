----------------------------------------
--$Id: goldmgr.lua 4082 2014-05-19 02:44:03Z zork $
----------------------------------------
--[[
-- 钻石金币操作
--
--]]
local Type1 = CommonData.CURRENCY_TYPE.GOLD
local Type2 = CommonData.CURRENCY_TYPE.MONEY

local TypeMap = {Type1,Type2,Type1,Type2,}
local AddTypes = {"","","-","-"}
local GMID = 22

--钻石金币操作面板展示
function GoldOperationShow(self, PlatformID, Results)
	local Options = GetQueryArgs()
	local Platforms = CommonFunc.GetPlatformList()
	--获得服务器列表
	local Servers = CommonFunc.GetServers(Options.PlatformID)
	local OperationTypes = {"加钻石", "加金币","扣钻石", "扣金币"}
	--展示数据
	local Titles = {"平台", "服", "账号", "角色", "执行结果", }
	local PlatformStr = PlatformID and Platforms[PlatformID] or "all"
	local SeverMap = CommonFunc.GetServers(PlatformID)
	local TableData = {}
	for _, Result in ipairs(Results or {}) do
		local CTable = {PlatformStr, SeverMap[Result.HostID] or "", Result.Uid or "", Result.Name or "", Result.Result or "执行失败"}
		table.insert(TableData, CTable)
	end
	local DataTable = {
		["ID"] = "logTable",
		["NoDivPage"] = true,
	}
	local Params = {
		Options = Options,
		Platforms = Platforms,
		Servers = Servers,
		OperationTypes = OperationTypes,
		Titles = Titles,
		TableData = TableData,
		DataTable = DataTable,
	}
	Viewer:View("template/player/goldOperation.html", Params)
end

function DoGoldOperation(self)
	local Results = {}
	if ngx.var.request_method == "POST" then
		local Args = GetPostArgs()
		local RoleName = Args.RoleName
		local OperationInfo = GMRuleData:Get({ID = GMID})
		local Rule = OperationInfo[1].Rule
		local OperationType = Args.OperationType
		OperationType = tonumber(OperationType)
		local OperationTime = os.date("%Y-%m-%d %H:%M:%S",ngx.time())
		if Args.RoleName and Args.RoleName ~= "" then
			--这里执行需要输入角色的GM指令
			Results = self:GetUserInfo(Args)
			--验证所填参数是否正确，这里要分填写玩家uid的和不用填写玩家uid的
			if #Results ~= 0 then
				for _, UidInfo in ipairs(Results) do
					local GMParams = {UidInfo.Uid, TypeMap[OperationType], AddTypes[OperationType] .. Args.Number} --加上玩家uid验证
					--验证参数
					local Flag, GMCMD = CommonFunc.VerifyGMParms(Rule, GMParams)
					if not Flag then
						ExtMsg = "GM参数不对，参数为："..table.concat(GMParams, ",")
						self:GoldOperationShow(Args.PlatformID, Results) --展示结果
						return
					else
						--执行GM指令
						Args.HostID = UidInfo.HostID
						local Flag, Result = CommonFunc.ExecuteGM(Args, GMID, GMCMD, OperationTime)
						UidInfo.Result = Result
					end
				end
			end
		end
		self:GoldOperationShow(Args.PlatformID, Results) --展示结果
	end
	
end

--获得玩家uid列表
function GetUserInfo(self, Options)
	local Results = {}
	if Options.RoleName and Options.RoleName ~= "" then
		--先查tblUserInfo表获得玩家对应的HostID
		local RoleName = Options.RoleName
		local RoleNames = string.split(RoleName, ";")
		local UserOptions = {
			PlatformID = Options.PlatformID,
			HostID = Options.HostID,
			Names = table.concat(RoleNames, "','")
		}
		Results = UserInfoData:Get(UserOptions)
	end
	return Results
end

DoRequest()