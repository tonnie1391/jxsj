
local tb	= Task:GetTarget("Send2NewWorld");
tb.szTargetName	= "Send2NewWorld";


-- 地图Id，地图X坐标，地图Y坐标，可传送次数。
function tb:Init(nMapId, nPosX, nPosY, nTotalTimes)
	self.nMapId			= nMapId;
	self.nPosX			= nPosX;
	self.nPosY			= nPosY;
	self.nTotalTimes	= nTotalTimes;
	self.szMapName		= Task:GetMapName(nMapId);
end;



--目标开启
function tb:Start()
	self.nCount		= 0;
end;

--目标保存
function tb:Save(nGroupId, nStartTaskId)
	local pPlayer = self:Base_GetPlayerObj();
	if not pPlayer then
		return;
	end
	self.tbSaveTask	= {	-- 这里保存下来，以后随时可以自行同步客户端
		nGroupId		= nGroupId,
		nStartTaskId	= nStartTaskId,
	};
	pPlayer.SetTask(nGroupId, nStartTaskId, self.nCount);
	
	return 1;
end;

--目标载入
function tb:Load(nGroupId, nStartTaskId)
	local pPlayer = self:Base_GetPlayerObj();
	if not pPlayer then
		return;
	end
	self.tbSaveTask	= {	-- 这里保存下来，以后随时可以自行同步客户端
		nGroupId		= nGroupId,
		nStartTaskId	= nStartTaskId,
	};
	self.nCount		= pPlayer.GetTask(nGroupId, nStartTaskId);
	
	return 1;
end;

--返回目标是否达成
function tb:IsDone()
	return 1;
end;

--返回目标进行中的描述（客户端）
function tb:GetDesc()
	return self:GetStaticDesc();
end;


--返回目标的静态描述，与当前玩家进行的情况无关
function tb:GetStaticDesc()
	return "";
end;

function tb:Close(szReason)
	
end;


----==== 以下是本目标所特有的函数定义，如有雷同，纯属巧合 ====----

-- 还可以传送多少次
function tb:GetLeaveTime()
	if (self.nTotalTimes < 0) then
		return 1;
	end
	
	return self.nTotalTimes - self.nCount;
end;

-- 传送
function tb:Send2NewWrold()
	local pPlayer = self:Base_GetPlayerObj();
	if not pPlayer then
		return;
	end
	if (self:GetLeaveTime() <= 0) then
		pPlayer.Msg("传送无效！");
		return 0;
	end

	pPlayer.NewWorld(self.nMapId, self.nPosX, self.nPosY, 0);
	self.nCount = self.nCount + 1;
	pPlayer.Msg("目前可传送次数为"..self:GetLeaveTime());
	
	return 1;
end;
