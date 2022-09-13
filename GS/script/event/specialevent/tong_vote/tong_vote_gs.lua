-- 文件名　：tong_vote_gs.lua
-- 创建者　：zounan
-- 创建时间：2010-03-30 17:44:50
-- 描  述  ：

Require("\\script\\event\\specialevent\\tong_vote\\tong_vote_def.lua");
SpecialEvent.Tong_Vote = SpecialEvent.Tong_Vote or {};
local tbTong = SpecialEvent.Tong_Vote;

function tbTong:IsOpen()
	local nDate = tonumber(GetLocalDate("%Y%m%d"));
	if nDate < self.TIME_START or nDate > self.TIME_END then
		return 0;
	end
	return 1;
end

function tbTong:GetGblBuf()
	return self.tbGblBuf or {};
end


function tbTong:OnRecConnectMsg(szName, tbInfo)
	if not self.tbGblBuf then
		self.tbGblBuf = {};
	end
--	if not self.tbGblBuf[szName] then
	self.tbGblBuf[szName] = tbInfo;
--	end
end


function tbTong:VoteTickets(szName)

--	if KGblTask.SCGetDbTaskInt(DBTASK_Tong_Vote_MAX) >= 100000 then
--		Dialog:Say("本服务器报名人数太多了,已达上限,请和游戏管理员联系.");
--		return 0;
--	end
	if self:IsOpen() ~= 1 then
		Dialog:Say("投票已经结束了");
		return 0;
	end
	
	if not KTong.FindTong(szName)  then
		Dialog:Say("好像没有这个帮会啊");
		return 0;
	end

	local nCount = tonumber(me.GetItemCountInBags(unpack(tbTong.ITEM_VOTE))) or 0;
	if nCount == 0 then
		Dialog:Say("没有选票，不能进行投票。");
		return 0;
	end
	
	local szInput = "输入票数";	
	Dialog:AskNumber(szInput, nCount, self.VoteTickets2, self, szName);
end

function tbTong:VoteTickets2(szName, nTickets)
	if nTickets <= 0 then
		return 0;
	end

	
	local nCount = me.GetItemCountInBags(unpack(tbTong.ITEM_VOTE));
	if nCount < nTickets then
		Dialog:Say("你身上没有那么多选票。");
		return 0;
	end
--	local nFreeCount = KItem.GetNeedFreeBag(self.ITEM_AWARD[1], self.ITEM_AWARD[2], self.ITEM_AWARD[3], self.ITEM_AWARD[4], {bForceBind=1}, nTickets)
--	if me.CountFreeBagCell() < nFreeCount then
--		Dialog:Say(string.format("需要%s格背包空间，才能进行投票！",nFreeCount));
--		return 0;
--	end	
	
	--扣除选票
	local bRet = me.ConsumeItemInBags(nTickets, unpack(tbTong.ITEM_VOTE));

	if bRet ~= 0 then
		me.Msg("扣除选票失败，投票失败");
		return 0;
	end
	
	local nVoteCount = me.GetTask(self.TSK_GROUP, self.TSK_VOTE_COUNT);
	me.SetTask(self.TSK_GROUP, self.TSK_VOTE_COUNT, nVoteCount + nTickets);
	
	if nVoteCount < self.AWARD_LIMIT then
		local nAddMoneyCount =  math.min(nTickets, self.AWARD_LIMIT - nVoteCount);
		me.AddBindMoney(self.MOENY_AWARD * nAddMoneyCount);
		if nVoteCount + nAddMoneyCount == self.AWARD_LIMIT then
			me.AddSkillState(892, 1, 1, 24 *3600*18, 1, 0, 1);
			me.Msg("恭喜您投票达到100次，获得强化优惠奖励。");
		end
	end
--	local nAddCount = me.AddStackItem(self.ITEM_AWARD[1],self.ITEM_AWARD[2],self.ITEM_AWARD[3],self.ITEM_AWARD[4], nil, nTickets);
	
	GCExcute({"SpecialEvent.Tong_Vote:BufVoteTicket", szName, nTickets, me.szName});
	Dialog:Say(string.format("你成功给%s投了%s票。", szName, nTickets));
end
