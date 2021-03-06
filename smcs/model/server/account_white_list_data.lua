------------------------------------------
--$Id: account_white_list_data.lua 80684 2015-12-01 03:31:52Z jm $
------------------------------------------
--[[
CREATE TABLE `tblAccountWhiteList` (
  `IndexName` varchar(32) NOT NULL DEFAULT '' COMMENT '索引名', 
  `AccountList` varchar(512) NOT NULL DEFAULT '' COMMENT 'Account列表',
  `Operator` varchar(32) NOT NULL DEFAULT '' COMMENT '操作者',
  `SubmitTime` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT '提交时间´',
  PRIMARY KEY (`IndexName`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='账号白名单列表'

--]]
module(...,package.seeall)

--获得GM指令
function Get(self, Options)
	local Where = "where 1=1 "
	if Options and Options.IndexName and Options.IndexName ~= "" then
		Where = Where .. " and IndexName = '" .. Options.IndexName .. "' "
	end
	local Sql = "select * from smcs.tblAccountWhiteList " .. Where .. ""
	local Res, Err = DB:ExeSql(Sql)
	if not Res then return nil, Err end
	return Res
end


local Cols = {"IndexName", "AccountList", "Operator","SubmitTime"}
local UpdateCols = {"AccountList", "Operator","SubmitTime"}
function Insert(self, Args)
	local List = {}
	for _, Col in ipairs(Cols) do
		local Value = Args[Col] or ""
		table.insert(List, "'" .. Value .. "'")
	end
	local UpdateList = {}
	for _, Col in ipairs(UpdateCols) do
		local Value = Args[Col] or ""
		table.insert(UpdateList, Col .. " = '" .. Value .. "'")
	end
	--插入数据库
	local Sql = "insert into smcs.tblAccountWhiteList(" .. table.concat(Cols, ",") .. ") values("
	-- 采用批量插入的方式
	Sql = Sql .. table.concat(List, ",") .. ") on duplicate key update " ..table.concat( UpdateList, ", ")
	local Res, Err = DB:ExeSql(Sql)
	if not Res then return nil, Err end
	return Res
end

--删除
function Delete(self, IndexName)
	if not IndexName or IndexName == "" then
		return 
	end
	local Sql = "delete from smcs.tblAccountWhiteList where IndexName = '" .. IndexName .. "'"
	DB:ExeSql(Sql)
end


