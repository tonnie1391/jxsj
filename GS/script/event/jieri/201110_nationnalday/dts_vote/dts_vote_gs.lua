-- 文件名　：dts_vote_gs.lua
-- 创建者　：jiazhenwei
-- 创建时间：2011-09-07 20:25:16
-- 功能    ：

if not MODULE_GAMESERVER then
	return;
end

Require("\\script\\event\\jieri\\201110_nationnalday\\dts_vote\\dts_vote_def.lua");

local tbDtsVote = SpecialEvent.Dts_Vote;

function tbDtsVote:GetGblBuf()
	self.tbGblBuf = self.tbGblBuf or {};
	return self.tbGblBuf;
end

function tbDtsVote:OnRecConnectMsg(szName, tbInfo)	
	if not self.tbGblBuf then
		self.tbGblBuf = {};
	end
	self.tbGblBuf[szName] = tbInfo;
end

function tbDtsVote:OnRecRank(nIndex, tbInfo)
	self.tbRankBuffer = self.tbRankBuffer or {};
	self.tbRankBuffer[nIndex] = tbInfo;	
end

function tbDtsVote:VoteTicketsEx(szName)
	if self:GetState() ~= self.emVOTE_STATE_SIGN then
		Dialog:Say("投票已经结束了。");
		return 0;
	end
	if not KGCPlayer.GetPlayerIdByName(szName) then
		Dialog:Say("请确认您输入的侠士名字是否正确。");
		return 0;
	end
	
	local nUseTask, nNews = self:GetTaskGirlVoteId(szName);
	if nUseTask == 0 then
		Dialog:Say("你已经给10个侠士投过票了，不能再给其他侠士投票");	
		return 0;
	elseif nUseTask > 0 and nNews == 0 then
		Dialog:Say("你已经给该侠士投过票了，还是选其他侠士吧。");
		return 0;
	end
	
	local nCount = tonumber(me.GetItemCountInBags(unpack(self.ITEM_VOTE))) or 0;
	if nCount == 0 then
		Dialog:Say("您还没有祝福卡。");
		return;
	end
	local bRet = me.ConsumeItemInBags(1, unpack(self.ITEM_VOTE));

	if bRet ~= 0 then
		me.Msg("扣除祝福卡失败，投票失败");
		return 0;
	end
	
	local nGroupId = self.TSK_GROUP;
	me.SetTaskStr(nGroupId, nUseTask, szName);
	local tbFans = {
		szName = me.szName, 
		nTickets = 1,
	};
	
	GCExcute({"SpecialEvent.Dts_Vote:BufVoteTicket", szName, 1, tbFans});
	me.Msg(string.format("你成功给<color=yellow>%s<color>投票。", szName));
	local szKinMsg = string.format("在寒武大猜想活动中为[%s]送上了一次鼓励和祝福。", szName);
	Player:SendMsgToKinOrTong(me, szKinMsg, 1);
	Player:SendMsgToKinOrTong(me, szKinMsg, 0);
	StatLog:WriteStatLog("stat_info", "mid_autumn2011", "card_send", me.nId, szName);
	me.AddBindCoin(self.tbBaseCoin1);
end

--提示
function tbDtsVote:OnVoteTickest(szPlayerName, szFansName,nTickets)
	local nPlayerId = KGCPlayer.GetPlayerIdByName(szPlayerName);
	if nPlayerId and nPlayerId ~= 0 then
		local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
		if pPlayer then
			pPlayer.Msg(string.format("<color=yellow>%s<color>给你投了寒武祝福卡，赶快向他道谢吧。", szFansName));
		end
	end
end

function tbDtsVote:GetTaskGirlVoteId(szName)
	local nGroupId = self.TSK_GROUP;
	local nUseTask = nil;
	local nNew = 0;
	for nTask = self.TSKSTR_FANS_NAME[1], self.TSKSTR_FANS_NAME[2] - self.DEF_TASK_SAVE_FANS, self.DEF_TASK_SAVE_FANS do
		if me.GetTaskStr(nGroupId, nTask) == szName then
			nUseTask = nTask;
			break;
		end
		if me.GetTaskStr(nGroupId, nTask) == "" then
			nUseTask = nUseTask or nTask;
			nNew = 1;
			break;
		end
	end
	return (nUseTask or 0), nNew;
end

function tbDtsVote:Loadbuff()
	local tbBuf = GetGblIntBuf(GBLINTBUF_Dts_Vote2, 0);
	if tbBuf and type(tbBuf)=="table"  then
		self.tbAwardList = tbBuf;
	end
end

if tbDtsVote:GetState() == tbDtsVote.emVOTE_STATE_AWARD then
	ServerEvent:RegisterServerStartFunc(SpecialEvent.Dts_Vote.Loadbuff, SpecialEvent.Dts_Vote);
end
