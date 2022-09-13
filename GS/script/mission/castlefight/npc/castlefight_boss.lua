-- 文件名  : castlefight_soldier.lua
-- 创建者  : zounan
-- 创建时间: 2010-11-11 10:17:53
-- 描述    : 

local tbNpc = Npc:GetClass("castlefight_boss");

function tbNpc:OnDeath(pKiller)
	local tbMission = him.GetTempTable("Npc").tbMission;
	
	if not tbMission or tbMission:IsPlaying() == 0 then
		return;
	end
	tbMission:OnBossDeath(him, pKiller);
end

function tbNpc:OnDialog()
	self:OnDialogEx(him.dwId);
end


function tbNpc:OnDialogEx(nNpcId, nOpt ,nSure)
	nOpt = nOpt or 0;
	nSure = nSure or 0;
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		return;
	end	
	
	local tbMission = pNpc.GetTempTable("Npc").tbMission;
	
	if not tbMission or tbMission:IsPlaying() == 0 then
		return;
	end
	
	local tbPlayerTempTable = CastleFight:GetPlayerTempTable(me); 
	if pNpc.GetCurCamp() ~= tbPlayerTempTable.nCamp then
		return;
	end
	
	local nCurMoney = CastleFight:GetPlayerMoney(me);
	
	if nOpt ~= 0 then
		if nCurMoney < CastleFight.BUFF_LIST[nOpt].nNeedMoney then
			me.Msg("Không đủ tiền.");
			return;
		end
		tbMission:AddNpcBuff(pNpc.GetCurCamp(),nOpt);
		return;
	end
	local tbOpt = {};
	local szInfo = nil;
	for i, tbInfo in ipairs(CastleFight.BUFF_LIST) do
		szInfo = tbInfo.szName;
		table.insert(tbOpt,{szInfo, self.OnDialogEx,self,nNpcId,i});
	end
	table.insert(tbOpt,{szInfo, "Để ta suy nghĩ thêm"});
	
	--	[1] = {nId = 1, nLevel = 2 , nSec = 5, nNeedMoney = 0,szName = "", szDesc = "",},
	return;
end
