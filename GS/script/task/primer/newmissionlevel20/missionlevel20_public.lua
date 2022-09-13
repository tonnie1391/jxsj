-- 文件名　：missionlevel20_public.lua
-- 创建者　：jiazhenwei
-- 创建时间：2012-07-26 15:16:19
-- 功能    ：

Task.NewPrimerLv20 = Task.NewPrimerLv20 or {};
local NewPrimerLv20 = Task.NewPrimerLv20;

function NewPrimerLv20:SysApplyInfo(nServerId, nPlayerId, nUseMapId, nStartTime, bOtherServer)
	if MODULE_GAMESERVER then
		if bOtherServer <= 0 then		--如果是其他服务器的玩家，这里需要解开玩家，把玩家new到对应地图上去
			local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
			if pPlayer then
				local tbEnterPos = self:GetEnterPos(pPlayer)
				if tbEnterPos then
					pPlayer.AddWaitGetItemNum(-1);
					pPlayer.NewWorld(nUseMapId, unpack(tbEnterPos));
				end
			end
		end
		if nServerId == GetServerId() then
			return;
		end
	end
	--记录玩家信息和对应的玩家地图开启情况
	self.tbManagerList[nPlayerId] = {};
	self.tbManagerList[nPlayerId].nUseMapId = nUseMapId;
	self.tbManagerList[nPlayerId].nStartTime = nStartTime;
	--记录整个gs信息
	self.tbServerInfo[nServerId] = self.tbServerInfo[nServerId] or {};
	self.tbServerInfo[nServerId].nUseCount = (self.tbServerInfo[nServerId].nUseCount or 0) + 1;
	if MODULE_GC_SERVER then
		GlobalExcute{"Task.NewPrimerLv20:SysApplyInfo", nServerId, nPlayerId, nUseMapId, nStartTime, bOtherServer};
	end
end

function NewPrimerLv20:SysCloseInfo(nServerId, nPlayerId, nUseMapId)
	if MODULE_GAMESERVER and self.tbMapList[nUseMapId]  then
		self.tbMapList[nUseMapId].bUsed = 0;	--gs需要把地图置为可用
	end
	if not nPlayerId or not nServerId then
		print("NewPrimerLv20:SysApplyInfo", "参数传递错误", nServerId, nPlayerId, nUseMapId);
		return;
	end
	self.tbManagerList[nPlayerId] = nil;
	--记录整个gs信息
	self.tbServerInfo[nServerId] = self.tbServerInfo[nServerId] or {};
	if not self.tbServerInfo[nServerId].nUseCount or self.tbServerInfo[nServerId].nUseCount <= 0 then
		print("新手副本申请地图异常！！！");
		return;
	end
	self.tbServerInfo[nServerId].nUseCount = self.tbServerInfo[nServerId].nUseCount - 1;
	if MODULE_GC_SERVER then
		GlobalExcute{"Task.NewPrimerLv20:SysCloseInfo", nServerId, nPlayerId, nUseMapId};
	end
end

--获取当前时间每台服务器最大地图数
function NewPrimerLv20:GetServerMaxMCount()
	local nOpenDay =  TimeFrame:GetServerOpenDay();
	for i, tb in ipairs(self.tbMaxPlayer) do
		if nOpenDay <= tb[1] then
			return tb[2]
		end
	end
	return self.tbMaxPlayer[#self.tbMaxPlayer][2];
end

