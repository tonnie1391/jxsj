-------------------------------------------------------------------
--File: kinevent.lua
--Author: lbh
--Date: 2007-7-9 18:02
--Describe: 游戏流程事件的家族事务（启动，退出， 日常活动等）
-------------------------------------------------------------------
if not Kin then --调试需要
	Kin = {}
	print(GetLocalDate("%Y\\%m\\%d  %H:%M:%S").." build ok ..")
end

--启动，家族初始化
function Kin:Init()
	if MODULE_GAMESERVER then
		return self:Init_GS()
	elseif MODULE_GC_SERVER then
		return self:Init_GC()
	end
end

--退出，反初始化
function Kin:UnInit()
	if MODULE_GAMESERVER then
		return self:UnInit_GS()
	elseif MODULE_GC_SERVER then
		return self:UnInit_GC()
	end
end


if MODULE_GC_SERVER then
----------------------------------------------------------------------
function Kin:Init_GC()
	local itor = KKin.GetKinItor()
	if not itor then
		return 0
	end
	local nKinId = itor.GetCurKinId()
end

function Kin:UnInit_GC()

end
----------------------------------------------------------------------
end


if MODULE_GAMESERVER then
----------------------------------------------------------------------
function Kin:Init_GS()

end

function Kin:UnInit_GS()
	--同步缓存的总江湖威望价值量
	for nKinId, aKinData in pairs(self.aKinData) do
		if aKinData.nTotalReputeValue > self.CONF_VALUE2REPUTE then
			KKin.ApplyAddKinTask(nKinId, 6, math.floor(aKinData.nTotalReputeValue / self.CONF_VALUE2REPUTE))
		end
	end
end
----------------------------------------------------------------------
end
