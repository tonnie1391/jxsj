
if not MODULE_GC_SERVER then
	return
end


SelfProtect.tbPlayerStatus = SelfProtect.tbPlayerStatus or {}

-- 记录与非法行为相关的状态
function SelfProtect:LogStatus(szName, szType, bIllegal)
	if not bIllegal then
		return
	end

	local nPlayerId = KGCPlayer.GetPlayerIdByName(szName)
	local szAccount = KGCPlayer.GetPlayerAccount(nPlayerId)
	local szMsg = string.format("SelfProtect\tStatus\t%s\t%s\t%s\t%s", tostring(szAccount), tostring(szName), tostring(szType), tostring(bIllegal))
	Dbg:WriteLogEx(Dbg.LOG_INFO, szMsg) -- 只记录非法的
end

-- 记录非法行为具体的信息
function SelfProtect:Log(szName, szType, szArg, szIp)
	local nPlayerId = KGCPlayer.GetPlayerIdByName(szName)
	local szAccount = KGCPlayer.GetPlayerAccount(nPlayerId)

	if szType == "InvalidModules" and szArg then
		for w in string.gfind(szArg, "[^,]+") do
			if string.len(w) < 200 then -- 太长了，导入数据库会失败
				StatLog:WriteStatLog("stat_info", "gongzuoshi", "feifachajian", nPlayerId, w, szIp or "unknow ip");
			end
		end
	end

	local szMsg = string.format("SelfProtect\tInfo\t%s\t%s\t%s\t%s", tostring(szAccount), tostring(szName), tostring(szType), tostring(szArg))
	Dbg:WriteLogEx(Dbg.LOG_INFO, szMsg) -- 有一些非法行为有额外的信息，在这里记录下
end

function SelfProtect:HasChanged(szName, szType, bIllegal)
	if not self.tbPlayerStatus[szName] then
		return true
	end

	return self.tbPlayerStatus[szName][szType] ~= bIllegal
end

-- 检测到指定玩家有非法行为
function SelfProtect:IllegalDetected(szName, szType, szArg, szIp)
	if type(szName) ~= "string" or type(szType) ~= "string" or type(szArg) ~= "string" then
		return
	end

	self:Log(szName, szType, szArg, szIp)
	self:UpdateIllegalStatus(szName, szType, true)
end

function SelfProtect:UpdateIllegalStatus(szName, szType, bIllegal)
	if type(szName) ~= "string" or type(szType) ~= "string" or type(bIllegal) ~= "boolean" then
		return
	end

	if not self:HasChanged(szType, bIllegal) then
		return
	end

	self.tbPlayerStatus[szName] = self.tbPlayerStatus[szName] or {}
	self.tbPlayerStatus[szName][szType] = bIllegal;

	if bIllegal then
		self:LogStatus(szName, szType, bIllegal)
	end

	GlobalExecute({"SelfProtect:SynStatusItem", szName, szType, bIllegal})
end


function SelfProtect:RequrestData(nServerId)
	GlobalExecute({"SelfProtect:SynData", nServerId, self.tbPlayerStatus})
end
