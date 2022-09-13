
-- 检测到客户端有非法的行为时调用到的服务器脚本

-- 记录玩家客户端的非法行为
-- 每个玩家对应SelfProtect.tbPlayerStatus表中的一个字表
-- 字表的key表示非法行为

if not MODULE_GAMESERVER then
	return
end

Require("\\script\\misc\\serverevent.lua");
Require("\\script\\player\\playerevent.lua");

SelfProtect.tbPlayerStatus = SelfProtect.tbPlayerStatus or {}

-- 判定指定名字玩家的指定类型的状态的值有没有改变
function SelfProtect:HasChanged(szName, szType, bIllegal)
	if not self.tbPlayerStatus[szName] then
		return true
	end

	return self.tbPlayerStatus[szName][szType] ~= bIllegal
end

-- GC调用来更改指定名字玩家指定类型的状态的值
function SelfProtect:SynStatusItem(szName, szType, bIllegal)
	if type(szName) ~= "string" or type(szType) ~= "string" or type(bIllegal) ~= "boolean" then
		return
	end

	if not self:HasChanged(szName, szType, bIllegal) then
		return
	end

	self.tbPlayerStatus[szName] = self.tbPlayerStatus[szName] or {}
	self.tbPlayerStatus[szName][szType] = bIllegal;


	if szType == "InvalidModules" then
		local pPlayer = KPlayer.GetPlayerByName(szName)
		if not pPlayer then
			return
		end

		if bIllegal then
			pPlayer.nHaveIllegalDLL = 1;
			DeRobot:AddPlayerWG({pPlayer}, 4)
		else
			pPlayer.nHaveIllegalDLL = 0;
		end

	end
end


-- 判断指定名字的玩家是不是在当前这次GS运行过程中调试了客户端
function SelfProtect:IsDebugging(szName)
	if not szName then
		return false
	end

	local tbStatus = self.tbPlayerStatus[szName]
	if not tbStatus then
		return false
	end

	return tbStatus["Debugging"]
end


-- 判断指定名字的玩家是不是在当前这次GS运行过程中使用过加载了非法模块的DLL
function SelfProtect:HasInvalidModules(szName)
	if not szName then
		return false
	end

	local tbStatus = self.tbPlayerStatus[szName]
	if not tbStatus then
		return false
	end

	return tbStatus["InvalidModules"]
end

-- 供GC调用，用于将GC中的数据传到GS上
function SelfProtect:SynData(nServerId, tbData)
	if nServerId ~= GetServerId() then
		return
	end
	self.tbPlayerStatus = tbData
end


-- 检测到非法行为
function SelfProtect:IllegalDetected(szType, szArg)
	if type(szType) ~= "string" or type(szArg) ~= "string" then
		return
	end

	local szIp = self:GetIP(me)
	GCExecute({"SelfProtect:IllegalDetected", me.szName, szType, szArg, szIp});
end

-- 客户端反外挂模块调用过来改变指定玩家的状态
function SelfProtect:UpdateIllegalStatus(szType, bIllegal)
	if type(szType) ~= "string" or type(bIllegal) ~= "boolean" then
		return
	end

	if not self:HasChanged(me.szName, szType, bIllegal) then
		return
	end
	GCExecute({"SelfProtect:UpdateIllegalStatus", me.szName, szType, bIllegal});
end

function SelfProtect:GetIP(pPlayer)
	local szIp = pPlayer.GetPlayerIpAddress(); -- 这个还带端口的
	if not szIp then
		return
	end

	local nIndex = string.find(szIp, ":")
	if not nIndex then
		return
	end

	szIp = string.sub(szIp, 1, nIndex - 1)

	return szIp
end


-- 注册服务器启动时的回调，回调函数从GC请求已经记录的数据
if not SelfProtect.bRegisterServerStartCallback then
	function SelfProtect:OnServerStart()
		GCExecute({"SelfProtect:RequrestData", GetServerId()})
	end
	ServerEvent:RegisterServerStartFunc(SelfProtect.OnServerStart, SelfProtect);
	SelfProtect.bRegisterServerStartCallback = true
end


-- 检测到非法行为,且需要记录额外信息，如果没有额外信息记录，使用UpdateIllegalStatus
function c2s:IllegalDetected(szType, szArg)
	-- SelfProtect:IllegalDetected(szType, szArg)
end

-- 更新相关状态
-- bIllegal true:有非法行为, false:无非法行为
function c2s:UpdateIllegalStatus(szType, bIllegal)
	-- SelfProtect:UpdateIllegalStatus(szType, bIllegal)
end

function SelfProtect:OnLogin()
	if (not SelfProtect:HasInvalidModules(me.szName)) then
		me.nHaveIllegalDLL = 0;
	else
		me.nHaveIllegalDLL = 1;
	end
end

-- PlayerEvent:RegisterGlobal("OnLogin", SelfProtect.OnLogin, SelfProtect);
