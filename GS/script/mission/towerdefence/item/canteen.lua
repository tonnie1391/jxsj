-- 文件名　：canteen.lua
-- 创建者　：jiazhenwei
-- 创建时间：2010-03-15 15:01:53
-- 描  述  ：水壶脚本

local tbCanteen = Item:GetClass("tower_canteen");

function tbCanteen:OnUse(nNpcId)
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
		 [2]="该植物不是你们队伍的，肥水不流外人田啊！";
		}
	if nFlag ~= 1 then
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
	if pNpc.nCurLife  < pNpc.nMaxLife then
		self:ChangeTowerLife(pNpc);
		return 1;
	end
	me.Msg("该植物已经满血了，还是不要浪费水壶了");
	return ;
end

function tbCanteen:OnClientUse()
	local pNpc = me.GetSelectNpc();
	if not pNpc then
		return 0;
	end
	return pNpc.dwId;
end

function tbCanteen:ChangeTowerLife(pNpc)
	pNpc.CastSkill(1621,1,-1,pNpc.nIndex);
end
