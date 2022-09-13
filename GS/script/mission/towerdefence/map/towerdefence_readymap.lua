--竞技赛(准备场)
--孙多良
--2008.12.25
do return end
Require("\\script\\mission\\towerdefence\\towerdefence_def.lua");


local tbMap = {};

-- 定义玩家进入事件
function tbMap:OnEnter()
	if TowerDefence.nReadyTimerId > 0 then
		TowerDefence:OnEnterReady(me);
		GlobalExcute{"TowerDefence:OnJoinReady", me.nId};
		GCExcute{"TowerDefence:OnJoinReady", me.nId};
		local nLastFrameTime = Timer:GetRestTime(TowerDefence.nReadyTimerId);
		if TowerDefence.nReadyState == 0 then
			nLastFrameTime = nLastFrameTime + TowerDefence.DEF_READY_TIME2;
		end
		TowerDefence:OpenSingleUi(me, TowerDefence.DEF_READY_MSG, nLastFrameTime);
		TowerDefence:UpdateMsgUi(me, "");	
		return 0;
	end
	local nLeaveMapId, nLeavePosX, nLeavePosY = TowerDefence:GetLeavePos();
	me.NewWorld(nLeaveMapId, nLeavePosX, nLeavePosY);
end

-- 定义玩家离开事件
function tbMap:OnLeave()
	--不是离线退出,直接return
	if not TowerDefence.tbPlayerLists[me.nId] or TowerDefence.tbPlayerLists[me.nId][3] > 0 then
		return 0;
	end
	me.TeamApplyLeave();			--离开队伍
	TowerDefence:OnLeaveReady(me);
	TowerDefence:CloseSingleUi(me);	
	GCExcute{"TowerDefence:LeaveGroupList", me.nId};
	GlobalExcute{"TowerDefence:LeaveGroupList", me.nId};
end

for _, nMapId in pairs(TowerDefence.DEF_READY_MAP) do
	local tbBattleMap = Map:GetClass(nMapId);
	for szFnc in pairs(tbMap) do
		tbBattleMap[szFnc] = tbMap[szFnc];
	end
end
