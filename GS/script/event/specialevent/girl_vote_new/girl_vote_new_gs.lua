-- 文件名  : girl_vote_new_gs.lua
-- 创建者  : zounan
-- 创建时间: 2010-09-21 11:39:21
-- 描述    : 

Require("\\script\\event\\specialevent\\girl_vote_new\\girl_vote_new_def.lua");

local tbGirl = SpecialEvent.Girl_Vote_New;

function tbGirl:GetGblBuf()
	self.tbGblBuf = self.tbGblBuf or {};
	return self.tbGblBuf;
end


function tbGirl:OnRecConnectMsg(szName, tbInfo)
	if not self.tbGblBuf then
		self.tbGblBuf = {};
	end
--	if not self.tbGblBuf[szName] then
	self.tbGblBuf[szName] = tbInfo;
--	end
end

function tbGirl:OnRecRank(nIndex, tbInfo)
	self.tbRankBuffer = self.tbRankBuffer or {};
	self.tbRankBuffer[nIndex] = tbInfo;	
end

function tbGirl:IsHaveGirl(szName)
	local tbBuf = self:GetGblBuf();
	if tbBuf[szName] then
		return 1;
	end
	return 0;
end

function tbGirl:OnSignUp(nPlayerId,nRet)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		return;
	end
	Setting:SetGlobalObj(pPlayer);
	me.AddTitle(unpack(self.TITLE_JOIN));
	me.SetCurTitle(unpack(self.TITLE_JOIN));
	if nRet == 1 then
		Dialog:Say("报名成功。");
	else
		Dialog:Say("本服务器报名人数太多了,已达上限,请和游戏管理员联系.");
	end
	Setting:RestoreGlobalObj();
end

function tbGirl:VoteTickets(szName)
	if self:GetState() ~= self.emVOTE_STATE_SIGN then
		Dialog:Say("投票已经结束了。");
		return 0;
	end		
	
	if self:IsHaveGirl(szName) == 0 then
		Dialog:Say("好像这个美女没有报名呀，先叫她来报名吧。");
		return 0;
	end
	
	local nUseTask, nNews = self:GetTaskGirlVoteId(szName);
	if nUseTask == 0 then
		Dialog:Say("你已经给25个美女投过票了，不能再给其他美女投票。去投给你自己的那25个美女吧。");	
		return 0;
	end
	
	local nCount = tonumber(me.GetItemCountInBags(unpack(self.ITEM_VOTE))) or 0;
	if nCount == 0 then
		Dialog:Say("您还没有金珠玉翠哦，可以打开奇珍阁购买，或者参加活动获得。");
		return;
	end	
	
	if me.CountFreeBagCell() < 2 then
		Dialog:Say("需要2格背包空间，才能进行投票！");
		return 0;
	end	
	local szInput = string.format("输入票数", szName);

	Dialog:AskNumber(szInput, nCount, self.VoteTickets2, self, szName);		
end

function tbGirl:VoteTickets2(szName, nTickets)
	if nTickets <= 0 then
		return 0;
	end

	if self:GetState() ~= self.emVOTE_STATE_SIGN then
		Dialog:Say("投票已经结束了。");
		return 0;
	end			

	if me.CountFreeBagCell() < 2 then
		Dialog:Say("需要2格背包空间，才能进行投票！");
		return 0;
	end	
	
	local nCount = me.GetItemCountInBags(unpack(self.ITEM_VOTE));
	if nCount < nTickets then
		Dialog:Say("你身上没有那么多的金珠玉翠。");
		return 0;
	end
	
	local nUseTask, nNews = self:GetTaskGirlVoteId(szName);
	if nUseTask == 0 then
		Dialog:Say("你已经给25个美女投过票了，不能再给其他美女投票。去投给你自己的那25个美女吧。");	
		return 0;
	end	
	
	--扣除选票
	local bRet = me.ConsumeItemInBags(nTickets, unpack(self.ITEM_VOTE));

	if bRet ~= 0 then
		me.Msg("扣除金珠玉翠失败，投票失败");
		return 0;
	end
	
	for i=1, nTickets do
		local nCurR = MathRandom(1,100);
		if nCurR == 1 then
			local pItem = me.AddItem(unpack(self.ITEM_AWARD));
			if pItem then
				pItem.Bind(1);
				pItem.Sync();
			end
		end
	end	
	
	local nGroupId = self.TSK_GROUP;
	local nTotleTickets = me.GetTask(nGroupId, (nUseTask + (self.DEF_TASK_SAVE_FANS - 1)));
	if nNews == 1 then
		me.SetTaskStr(nGroupId, nUseTask, szName);
	end	
	
	me.SetTask(nGroupId, (nUseTask + (self.DEF_TASK_SAVE_FANS - 1)), (nTotleTickets + nTickets));
	self:AddTotalTickets(me,nTickets);
	local tbFans = {
		szName = me.szName, 
		nTickets = nTotleTickets + nTickets,
	}
	
	GCExcute({"SpecialEvent.Girl_Vote_New:BufVoteTicket", szName, nTickets, tbFans});
	me.Msg(string.format("你成功给<color=yellow>%s<color>投了<color=yellow>%s<color>票。", szName, nTickets));
end

function tbGirl:OnVoteTickest(szPlayerName, szFansName,nTickets)
	local nPlayerId = KGCPlayer.GetPlayerIdByName(szPlayerName);
	if nPlayerId and nPlayerId ~= 0 then
		local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
		if pPlayer then
			pPlayer.Msg(string.format("<color=yellow>%s<color>给你投了<color=yellow>%s<color>个金珠玉翠，赶快向他道谢吧。", szFansName, nTickets));
		end
	end
end

function tbGirl:GetTaskGirlVoteId(szName)
	local nGroupId = self.TSK_GROUP;
	local nUseTask = nil;
	local nNew = 0;
	for nTask = self.TSKSTR_FANS_NAME[1], self.TSKSTR_FANS_NAME[2], self.DEF_TASK_SAVE_FANS do
		if me.GetTaskStr(nGroupId, nTask) == szName then
			nUseTask = nTask;
			break;
		end
		if me.GetTaskStr(nGroupId, nTask) == "" then
			nUseTask = nUseTask or nTask;
			nNew = 1;
		end
	end
	return (nUseTask or 0), nNew;
end

function tbGirl:AddTotalTickets(pPlayer, nTickets)
	local nCurTickets = pPlayer.GetTask(self.TSK_GROUP, self.TSK_TOTAL_TICKETS);
	pPlayer.SetTask(self.TSK_GROUP,self.TSK_TOTAL_TICKETS,nCurTickets + nTickets);	
end

function tbGirl:GetTotalTickets(pPlayer)
	return pPlayer.GetTask(self.TSK_GROUP, self.TSK_TOTAL_TICKETS);
end