------------------------------------------
--$Id: message_log_data.lua 3850 2014-05-14 08:26:00Z zork $
------------------------------------------
--[[
CREATE TABLE `tblMessageLog` (
  `ID` int(11) NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `HostID` int(11) NOT NULL DEFAULT '0' COMMENT '服ID',
  `Uid` bigint(20) NOT NULL DEFAULT '0' COMMENT '角色ID',
  `SenderName`  varchar(32) NOT NULL DEFAULT '' COMMENT '发信人', 
  `MessageType` tinyint NOT NULL DEFAULT '1' COMMENT '邮件类型,1:奖励,2:提示', 
  `Title` varchar(128) NOT NULL DEFAULT '' COMMENT '标题',  
  `Content` varchar(256) NOT NULL DEFAULT '' COMMENT '内容',   
  `Bonus` varchar(128) NOT NULL DEFAULT '' COMMENT '奖励内容', 
  `Time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '时间',
  PRIMARY KEY (`ID`),
  KEY `index1` (`Time`),
  KEY `index2` (`Uid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='邮件日志表' 

--]]
module(...,package.seeall)

--查询数据
function Get(self, PlatformID, Options)
	local Where = " where 1=1 "
	if Options.HostID and Options.HostID ~= "" then
		Where = Where .. " and HostID = '" .. Options.HostID .. "'"
	end
	if Options.Time and Options.Time ~= "" then
		Where = Where .. " and Time = '" .. Options.Time .. "'"
	end
	if Options.StartTime and Options.StartTime ~= "" then
		Where = Where .. " and Time >= '" .. Options.StartTime .. "'"
	end
	if Options.EndTime and Options.EndTime ~= "" then
		Where = Where .. " and Time <= '" .. Options.EndTime .. "'"
	end
	if Options.Uid and Options.Uid ~= "" then
		Where = Where .. " and Uid = '" .. Options.Uid .. "'"
	end
	if Options.Name and Options.Name ~= "" then
		Where = Where .. " and Name = '" .. Options.Name .. "'"
	end
	if Options.TargetUid and Options.TargetUid ~= "" then
		Where = Where .. " and TargetUid = '" .. Options.TargetUid .. "'"
	end
	if Options.Content and Options.Content ~= "" then
		Where = Where .. " and Content like '%" .. Options.Content .. "%'"
	end
	local Sql = "select * from " .. PlatformID .. "_log.tblMessageLog " .. Where
	local Res, Err = DB:ExeSql(Sql)
	if not Res then return {}, Err end
	return Res
end

--获得某一时间点的数据，并且组装成{Uid=Time}格式
function GetSameTimeStatics(self, PlatformID, Options)
	local Res = self:Get(PlatformID, Options)
	local Results = {}
	for _, Info in ipairs(Res) do
		Results[Info.Uid] = Info.Time
	end
	return Results
end

local Cols = {"HostID", "Uid", "SenderUid", "SenderName", "TargetUid", "Title", "Content", 
	"Bonus", "Urs", "Name", "Time"}

function BatchInsert(self, PlatformID, Results)
	local StrResults = {}
	for _, Result  in ipairs(Results) do
		local List = {}
		for _, Col in ipairs(Cols) do
			local Value = Result[Col] or ""
			table.insert(List, "'" .. Value .. "'")
		end
		local StrValue = table.concat(List, ",")
		table.insert(StrResults, StrValue)
	end
	--插入数据库
	local Sql = "insert into " .. PlatformID .. "_log.tblMessageLog(" .. table.concat(Cols, ",") .. ") values("
	-- 采用批量插入的方式
	Sql = Sql .. table.concat(StrResults, "),(") .. ")"
	local Res, Err = DB:ExeSql(Sql)
	if not Res then return nil, Err end
	return Res
end

function GetUid(self, PlatformID, HostID, Name)
	local Uid = ""
	local Res = UserInfoData:Get({PlatformID = PlatformID, HostID = HostID, Name = Name})
	if Res and Res[1] then
		Uid = Res[1]["Uid"]
	end
	return Uid
end
