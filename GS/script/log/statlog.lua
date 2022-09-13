-------------------------------------------------------------------
--File: statlog.lua
--Author: lbh
--Date: 2008-3-18 15:31:26
--Describe: 统计Log
-------------------------------------------------------------------


-- 防止全包外客户端报错
if (MODULE_GAMECLIENT) then
	return;
end


-- 默认的不存在信息的替代字符
StatLog.SZ_DEFAULT_NONEWORD = "NONE";
StatLog.SZ_DEFAULT_KEYWORD	= "stat_info";

-- gs 向log\stat\datarecord\日期\gs_stat_info_XXX 写入log
-- gc 向log\gamecenter\日期\gc_stat_info_XXX 写入log
function StatLog:WriteStatLog(szKeyWord, szBigType, szSubType, nPlayerId, ...)
	if (not nPlayerId or not szKeyWord or not szBigType or not szSubType) then
		return;
	end
	
	local szAccount, szName = self:__WriteStatLog_GetAccName(nPlayerId);
	local szLog = string.format("%s\t%s\t", szAccount, szName);
	local szArgLog = "";
	for nIndex, szInfo in ipairs(arg) do
		if (nIndex ~= 1) then
			szArgLog = szArgLog .. ",";
		end
		szArgLog = szArgLog .. szInfo;
	end
	szLog = szLog .. szArgLog;
	
	if (MODULE_GAMESERVER) then
		WriteStatLog(szKeyWord, szBigType, szSubType, szLog);
	end
	if (MODULE_GC_SERVER) then
		WriteStatLog_GC(szKeyWord, szBigType, szSubType, szLog);
	end
end

function StatLog:__WriteStatLog_GetAccName(nPlayerId)
	local szAccount = self.SZ_DEFAULT_NONEWORD;
	local szName = self.SZ_DEFAULT_NONEWORD;
	
	if (nPlayerId and nPlayerId > 0) then
		if (MODULE_GAMESERVER) then
			local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
			if (pPlayer) then
				szAccount = pPlayer.szAccount;
				szName = pPlayer.szName;
			end
		end
		
		if (MODULE_GC_SERVER) then
			szAccount = KGCPlayer.GetPlayerAccount(nPlayerId);
			szName = KGCPlayer.GetPlayerName(nPlayerId);
		end
	end
	
	return szAccount, szName;
end





--KStatLog.ModifyField(szTable, szKey, szField, value)
--KStatLog.ModifyMax(szTable, szKey, szField, nValue)
--KStatLog.ModifyMin(szTable, szKey, szField, nValue)
--KStatLog.ModifyAdd(szTable, szKey, szField, nValue)
-- 类型：0普通，1Daily，2Weekly, 3DailyBackup

StatLog.StatTaskGroupId = 2048;

-- [表名必须全部小写]
local aTableDefine = {
	["roleinfo"] 	= {"角色名", 3},
	["jxb"] 		= {"途径", 1},
	["ibshop"] 		= {"道具名称", 1},
	["ibitem"] 		= {"道具名称", 3},
	["mixstat"]	 	= {"项目", 1},
--	["tifu"] = {"项目", 1}, --90级技能体服Log
	["armycamp"] 	= {"军营", 3},
	--["zhongqiu"] 	= {"道具名称", 1},	--中秋log
	--["ui"] 		= {"点击数据统计", 3},
	["xoyogame"] 	= {"逍遥谷", 1},
	["wlls"] 		= {"联赛级别", 1}, --武林联赛
	["kinweeklytask"] 	= {"周活动项目", 2},	-- 帮会家族周活动数据分析（家族）
	["personweeklytask"]= {"周活动项目", 2}, -- 帮会家族周活动数据分析（成员）
	["playercount"] = {"时间点和地图", 3},	-- 黄金时段玩家行为统计
	["bindcoin"] 	= {"途径", 1},	--绑定金币
	["bindjxb"] 	= {"途径", 1},	--绑定银两
	["coin"] 	= {"途径", 1},	--金币
};

local function AddTable()
	for szTable, aTableInfo in pairs(aTableDefine) do
		
		KStatLog.AddTable(szTable, aTableInfo[1], aTableInfo[2]);
	end
end

AddTable();
