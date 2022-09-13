-- 文件名　：hoe.lua
-- 创建者　：jiazhenwei
-- 创建时间：2010-03-15 15:01:45
-- 描  述  ：锄头
local tbHoe = Item:GetClass("tower_hoe");

function tbHoe:OnUse(nNpcId)
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		me.Msg("对不起，你没有目标是不能使用的！")
		return 0;
	end
	local tbPlayerTempTable = me.GetPlayerTempTable();	
	local tbMission = tbPlayerTempTable.tbMission;	
	
	if tbMission:IsOpen() ~= 1 then
		me.Msg("Chưa thể sử dụng!")
		return 0;
	end	
	
	local nFlag  =  tbMission:CheckTower(nNpcId, me.nId) ;
	local tbMsg ={
		 [0]="只有对植物才能使用该物！";
		 [1]="该植物是你们队伍的，做人不能连自己人的墙角都挖啊！";
		}
	if nFlag ~= 2 then
		me.Msg(tbMsg[nFlag]);
		return 0;
	end	
	local nMapId, nX, nY = pNpc.GetWorldPos();
	local _, nX2, nY2 = me.GetWorldPos();
	local nDistance = (nX2 - nX) * (nX2 - nX) + (nY2 - nY) * (nY2 - nY);
	if nDistance > 30 then
		me.Msg("要靠近植物才能使用哦");
		return;
	end
	if pNpc.nCurLife <= 30 then
		tbMission:DelTower(pNpc.dwId);
		me.Msg("你真坏，破坏掉对方一株植物！");
		return 1;
	end
	self:ChangeTowerLife(pNpc);
	return 1;
end

function tbHoe:OnClientUse()
	local pNpc = me.GetSelectNpc();
	if not pNpc then
		return 0;
	end
	return pNpc.dwId;
end

function tbHoe:ChangeTowerLife(pNpc)
	pNpc.CastSkill(1622, 2,-1,pNpc.nIndex);
end
