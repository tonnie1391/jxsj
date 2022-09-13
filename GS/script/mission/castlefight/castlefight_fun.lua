-- 文件名  : castlefight_fun.lua
-- 创建者  : zounan
-- 创建时间: 2010-11-11 16:36:36
-- 描述    : 一些函数


Require("\\script\\mission\\castlefight\\castlefight_def.lua");


--离线或宕机恢复
function CastleFight:LogOutRV()
	if me.GetSkillState(CastleFight.TRANSFORM_SKILL_ID) > 0 then
		me.RemoveSkillState(CastleFight.TRANSFORM_SKILL_ID);
	end
	
	if me.IsHaveSkill(CastleFight.FINAL_SKILL_ID) == 1 then
		me.DelFightSkill(CastleFight.FINAL_SKILL_ID);
	end	
	
--	if me.IsHaveSkill(CastleFight.WUDI_SKILL_ID) == 1 then
--		me.DelFightSkill(CastleFight.WUDI_SKILL_ID);
--	end	
	
	CastleFight:ClearPlayerItem(me);
	CastleFight:SetPlayerMoney(me, 0);	
	CastleFight:SetFinalSkillTimes(me,0);	
end


--清除掉比赛场买的道具
function CastleFight:ClearPlayerItem(pPlayer)
	for _, tbInfo in ipairs(self.ITEM_LIST) do	
		local tbFind = pPlayer.FindItemInAllPosition(unpack(tbInfo));
		for _,tbItem in ipairs (tbFind) do
			tbItem.pItem.Delete(pPlayer);
		end
	end
end

function CastleFight:AddPlayerItem(pPlayer)
	self:ClearPlayerItem(pPlayer);
	for _, tbInfo in ipairs(self.ITEM_LIST) do	
		local pItem = pPlayer.AddItem(unpack(tbInfo));
		if pItem then
			pItem.Bind(1);
		end
	end	
end


-- NPC的所属
function CastleFight:SetNpcOwner(pNpc, nPlayerId)
	pNpc.GetTempTable("Npc").nPlayerId = nPlayerId;
end

function CastleFight:GetNpcOwnerId(pNpc)
	local nId = pNpc.GetTempTable("Npc").nPlayerId or 0;
	if nId == 0 then
		print("【ERR】 CastleFight: GetNpcOwnerId nId is nil", pNpc.nTemplateId);
	end
	return nId;	
end

-- 是否在建造
function CastleFight:SetBuildingUpdate(pBuilding)
	self:SetNpcFrame(pBuilding,0); -- 建造的时候把NPC nFrame置0？
	pBuilding.GetTempTable("Npc").bUpdate = 1;
end

function CastleFight:IsBuildingUpdate(pBuilding)
	pBuilding.GetTempTable("Npc").bUpdate = pBuilding.GetTempTable("Npc").bUpdate or 0;
	return pBuilding.GetTempTable("Npc").bUpdate;
end

function CastleFight:ExitBuildingUpdate(pBuilding)
	self:SetNpcFrame(pBuilding,0);
	pBuilding.GetTempTable("Npc").bUpdate = 0;
end

-- BUILDING id 配置表里面的索引ID
function CastleFight:GetNpcId(pNpc)
	local nId = pNpc.GetTempTable("Npc").nId or 0;
	if nId == 0 then
		print("【ERR】 CastleFight: GetNpcId nId is nil", pNpc.nTemplateId);
	end
	return nId;
end

function CastleFight:SetNpcId(pNpc, nId)
	pNpc.GetTempTable("Npc").nId = nId;
end

-- NPC cd FRAME 
function CastleFight:GetNpcFrame(pNpc)
	return pNpc.GetTempTable("Npc").nFrame or 0;
end

function CastleFight:SetNpcFrame(pNpc,nFrame)
	pNpc.GetTempTable("Npc").nFrame = nFrame;
end

function CastleFight:AddNpcFrame(pNpc, nAddFrame)
	pNpc.GetTempTable("Npc").nFrame = self:GetNpcFrame(pNpc) + nAddFrame;
end


function CastleFight:GetNpcCamp(pNpc)
	return pNpc.GetTempTable("Npc").nCamp;
end

-- Player 钱数
function CastleFight:GetPlayerMoney(pPlayer)
	return pPlayer.GetTask(CastleFight.TSK_GROUP, CastleFight.TSK_MONEY);		
end

function CastleFight:SetPlayerMoney(pPlayer, nMoney)
	pPlayer.SetTask(CastleFight.TSK_GROUP, CastleFight.TSK_MONEY,nMoney);	
end

function CastleFight:AddPlayerMoney(pPlayer, nMoney)
	local nCurMoney = self:GetPlayerMoney(pPlayer);
	self:SetPlayerMoney(pPlayer,nCurMoney + nMoney);
end


function CastleFight:GetPlayerTempTable(pPlayer)
	local tbPlayerTempTable = pPlayer.GetPlayerTempTable();
	tbPlayerTempTable.tbCastleFight = tbPlayerTempTable.tbCastleFight or {};
	return 	tbPlayerTempTable.tbCastleFight;
end

function CastleFight:ClearPlayerTempTable(pPlayer)
	local tbPlayerTempTable = pPlayer.GetPlayerTempTable();
	tbPlayerTempTable.tbCastleFight = nil;
end


-- 大招次数
function CastleFight:GetFinalSkillTimes(pPlayer)
	local tbPlayerTempTable = CastleFight:GetPlayerTempTable(pPlayer);
	return tbPlayerTempTable.nSkillTimes or 0;
end

function CastleFight:SetFinalSkillTimes(pPlayer,nTimes)
	local tbPlayerTempTable = CastleFight:GetPlayerTempTable(pPlayer);
	tbPlayerTempTable.nSkillTimes = nTimes;
end

function CastleFight:AddFinalSkillTimes(pPlayer, nAddTimes)
	local nCurTimes = self:GetFinalSkillTimes(pPlayer);
	self:SetFinalSkillTimes(pPlayer,nCurTimes + nAddTimes);
end

--- COLOR----
CastleFight.COLOR_LIST = 
{
	[1] = "<color=orange>%s<color>",
	[2] = "<color=purple>%s<color>",
	[3] = "<color=yellow>%s<color>",
	[4] = "<color=yellow>%s<color>",
	[5] = "<color=yellow>%s<color>",
	[6] = "<color=yellow>%s<color>",
	[7] = "<color=yellow>%s<color>",
	[8] = "<color=yellow>%s<color>",
	[9] = "<color=gray>%s<color>"					
};

function CastleFight:AddStrColor(str,nId, nOnLine)
	if nOnLine and nOnLine == 0 then
		nId = 9;
	end
	return string.format(CastleFight.COLOR_LIST[nId],str);
end


--NPC move 扔这里
CastleFight.NPC_MOVE_RAD = 2; -- NPC MOVE 范围
function CastleFight:SetNpcMoveAI(pNpc,nCamp, nDirect)
	pNpc.AI_ClearPath();
	for i, tbMovePos in ipairs(CastleFight.NPC_MOVE[nCamp][nDirect]) do
		-- 可以考虑随机一下
		local nRanX = self.NPC_MOVE_RAD - MathRandom(self.NPC_MOVE_RAD * 2);
		local nRanY = self.NPC_MOVE_RAD - MathRandom(self.NPC_MOVE_RAD * 2);
		pNpc.AI_AddMovePos(tbMovePos[1] + nRanX * 32, tbMovePos[2] + nRanY * 32);	
		--pNpc.AI_AddMovePos((tbMovePos[1]), (tbMovePos[2]));
	end
end