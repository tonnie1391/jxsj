-- 文件名　：gril_vote_gs.lua
-- 创建者　：sunduoliang
-- 创建时间：2009-06-05 11:36:22
-- 描  述  ：
if (MODULE_GC_SERVER) then
	return 0;
end
SpecialEvent.Girl_Vote = SpecialEvent.Girl_Vote or {};
local tbGirl = SpecialEvent.Girl_Vote;

function tbGirl:GetRose(pPlayer, nNum)
	if self:IsOpen() ~= 1 then
		return 0;
	end
	local tbItemInfo = {};
	for i=1, nNum do
		local pItem = pPlayer.AddItemEx(self.ITEM_MEIGUI[1], self.ITEM_MEIGUI[2], self.ITEM_MEIGUI[3], self.ITEM_MEIGUI[4], tbItemInfo, Player.emKITEMLOG_TYPE_JOINEVENT);
		if pItem then
			--local nSec = math.floor((Lib:GetDate2Time(self.STATE[6]) - GetTime() / 60));
			--if nSec > 0 then
			--	pPlayer.SetItemTimeout(pItem, nSec, 0);			
			--end
			Dbg:WriteLog("SpecialEvent.Girl_Vote", pPlayer.szName.."获得物品："..pItem.szName);
		end
	end
end

function tbGirl:OnRecConnectMsg(szName, tbInfo)
	if not self.tbGblBuf then
		self.tbGblBuf = {};
	end
	if not self.tbGblBuf[szName] then
		self.tbGblBuf[szName] = tbInfo;
	end
end

function tbGirl:State1VoteTickets1(szName, nExTicket)
	--if szName == me.szName then
	--	Dialog:Say("不能自己给自己投票哦!");
	--	return 0;
	--end
	if self:CheckState(2, 4) ~= 1 then
		Dialog:Say("3月5日至3月16日是初选投票，3月19日至3月31日0点是决赛投票，现在不在投票期间。");
		return 0;
	end
	if KGblTask.SCGetDbTaskInt(DBTASK_GIRL_VOTE_MAX) >= 100000 then
		Dialog:Say("本服务器报名人数太多了,已达上限,请和游戏管理员联系.");
		return 0;
	end
	
	if SpecialEvent.Girl_Vote:IsHaveGirl(szName) == 0 then
		Dialog:Say("好像这个美女没有报名呀，你可以先叫她来报名，组队投票还能获得20%的额外票数加成哦。");
		return 0;
	end
	local nUseTask, nNews = self:GetTaskGirlVoteId(szName);
	if nUseTask == 0 then
		Dialog:Say("你已经给25个美女投过票了，不能再给其他美女投票。去投给你自己的那25个美女吧。");	
		return 0;
	end
	if me.CountFreeBagCell() < 2 then
		Dialog:Say("需要2格背包空间，才能进行投票！");
		return 0;
	end	
	local szInput = "输入票数";
	
	if nExTicket == 1  or nExTicket == 2  then
		szInput =  "输入票数<color=yellow>(+20%)<color>";
	end
	local nCount = tonumber(me.GetItemCountInBags(unpack(SpecialEvent.Girl_Vote.ITEM_MEIGUI))) or 0;
	local nCount_K = tonumber(me.GetItemCountInBags(unpack(SpecialEvent.Girl_Vote.ITEM_MEIGUI_KING))) or 0;
	Dialog:AskNumber(szInput, nCount + nCount_K, self.State1VoteTickets2, self, szName, (nExTicket or 0), nCount);
end

function tbGirl:State1VoteTickets2(szName, nExTicket, nCount_S, nTickets)
	if nTickets <= 0 then
		return 0;
	end
	if self:CheckState(2, 4) ~= 1 then
		Dialog:Say("3月5日至3月16日是初选投票，3月19日至3月31日0点是决赛投票，现在不在投票期间。");
		return 0;
	end
	if me.CountFreeBagCell() < 2 then
		Dialog:Say("需要2格背包空间，才能进行投票！");
		return 0;
	end
	--判断身上的玫瑰数够不够；
	local nCount = me.GetItemCountInBags(unpack(SpecialEvent.Girl_Vote.ITEM_MEIGUI));
	local nCount_K = tonumber(me.GetItemCountInBags(unpack(SpecialEvent.Girl_Vote.ITEM_MEIGUI_KING))) or 0;
	if nCount + nCount_K < nTickets then
		Dialog:Say("你身上没有那么多玫瑰。");
		return 0;
	end
	
	local nUseTask, nNews = self:GetTaskGirlVoteId(szName);
	if nUseTask == 0 then
		Dialog:Say("你已经给25个美女投过票了，不能再给其他美女投票。去投给你自己的那25个美女吧。");	
		return 0;
	end
	local nConsumeCount = math.min(nCount_S, nTickets);
	local nConsumeCount_K = nTickets - nConsumeCount;
	--扣除玫瑰；
	local bRet = 1;
	if nConsumeCount > 0 then
		bRet = me.ConsumeItemInBags(nConsumeCount, unpack(SpecialEvent.Girl_Vote.ITEM_MEIGUI));
	end
	local bRet_K = 1;
	if nConsumeCount_K > 0 then
		bRet_K = me.ConsumeItemInBags(nConsumeCount_K, unpack(SpecialEvent.Girl_Vote.ITEM_MEIGUI_KING));
	end
	--增加投票
	if bRet ~= 0 and bRet_K ~= 0 then
		me.Msg("扣除玫瑰失败，投票失败");
		return 0;
	end
	
	for i=1, nTickets do
		local nCurR = 0;
		if i <= nConsumeCount then
			nCurR = MathRandom(1,100);
		else
			nCurR = MathRandom(1,1000);	--扣除内部的时候概率1/1000
		end
		if nCurR == 1 then
			if TimeFrame:GetState("OpenLevel150") == 0 then
				me.AddItem(unpack(SpecialEvent.Girl_Vote.ITEM_MEIGUI_REBACK));
			else
				me.AddItem(unpack(SpecialEvent.Girl_Vote.ITEM_MEIGUI_REBACK_Old));
			end
		end
	end
	
	local nGroupId = SpecialEvent.Girl_Vote.TSK_GROUP;
	local nTotleTickets = me.GetTask(nGroupId, (nUseTask + (SpecialEvent.Girl_Vote.DEF_TASK_SAVE_FANS - 1)));
	if nNews == 1 then
		me.SetTaskStr(nGroupId, nUseTask, szName);
	end
	--组队送：加特效，小仙子送：特殊奖励
	local pPlayer = KPlayer.GetPlayerByName(szName);
	if pPlayer and nTickets >= 9 then
		if nExTicket == 1 then
			pPlayer.CastSkill(self.nSkillVote, 1, 1, 1);
		end
		if nTickets < self.nMinWorldMsg then
			Player:SendMsgToKinOrTong(pPlayer, "收到了<color=yellow>神秘人物<color>赠送的一束玫瑰。", 1);
			Player:SendMsgToKinOrTong(pPlayer, "收到了<color=yellow>神秘人物<color>赠送的一束玫瑰。", 0);
			pPlayer.SendMsgToFriend("Hảo hữu ["..pPlayer.szName.."]收到了<color=yellow>神秘人物<color>赠送的一束玫瑰。");
		end
	end
	--每次送超过99朵，又一次发送世界公告的机会
	if nTickets >= self.nMinWorldMsg then
		self:RandSendMsgWorld(szName, me.szName, 1, nTickets);
	end
	local nOldnTickets = nTickets;	
	--票数加成
	if nExTicket == 1 or nExTicket == 2  then
		nTickets = math.floor(nTickets * 1.2);
	end
	me.SetTask(nGroupId, (nUseTask + (SpecialEvent.Girl_Vote.DEF_TASK_SAVE_FANS - 1)), (nTotleTickets + nTickets));
	local tbFans = {
		szFansName = me.szName, 
		nFansSex   = me.nSex, 
		nTotleTickets = nTotleTickets,
	}
	GCExcute({"SpecialEvent.Girl_Vote:BufVoteTicket", szName, nTickets, tbFans});	
	StatLog:WriteStatLog("stat_info", "prety_lady", "vote_rose", me.nId, GetGatewayName(), szName, nOldnTickets, nTickets);
	Dialog:Say(string.format("你成功给%s投了%s票。", szName, nTickets));
end

function tbGirl:GetTaskGirlVoteId(szName)
	local nGroupId = SpecialEvent.Girl_Vote.TSK_GROUP;
	local nUseTask = nil;
	local nNew = 0;
	for nTask = SpecialEvent.Girl_Vote.TSKSTR_FANS_NAME[1], SpecialEvent.Girl_Vote.TSKSTR_FANS_NAME[2], SpecialEvent.Girl_Vote.DEF_TASK_SAVE_FANS do
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

function tbGirl:GetAward(pPlayer, nType, szMsg)
	if not self.DEF_AWARD_LIST[nType] then
		return 0;
	end
	
	if pPlayer.CountFreeBagCell() < self.DEF_AWARD_LIST[nType].freebag then
		Dialog:Say(string.format("Hành trang không đủ ，需要%s格背包空间。", self.DEF_AWARD_LIST[nType].freebag));
		return 0;
	end
	
	for szType, tbTmp in pairs(self.DEF_AWARD_LIST[nType]) do
		if szType == "mask" then
			local pItem = pPlayer.AddItem(tbTmp[1], tbTmp[2], tbTmp[3], tbTmp[4]);
			if pItem then
				pItem.Bind(1);
				pPlayer.SetItemTimeout(pItem, tbTmp[5], 0);
				Dbg:WriteLog("SpecialEvent.Girl_Vote", pPlayer.szName.."获得物品："..pItem.szName);
				pPlayer.PlayerLog(Log.emKPLAYERLOG_TYPE_JOINSPORT, "【美女评选】获得"..pItem.szName);
			end
		end
		
		if szType == "skill" then
			pPlayer.AddSkillState(unpack(tbTmp[1]));
			local nOffset = 0;
			if tbTmp[2] == 2 then
				nOffset = 5;
			end
			pPlayer.SetTask(SpecialEvent.Girl_Vote.TSK_GROUP, SpecialEvent.Girl_Vote.TSK_Award_Buff + nOffset, GetTime());
			pPlayer.SetTask(SpecialEvent.Girl_Vote.TSK_GROUP, SpecialEvent.Girl_Vote.TSK_Award_Buff_Level + nOffset, tbTmp[2]);
			Dbg:WriteLog("SpecialEvent.Girl_Vote", pPlayer.szName.."获得技能Buf："..tostring(tbTmp[1][1])..tostring(tbTmp[1][2]));
			pPlayer.PlayerLog(Log.emKPLAYERLOG_TYPE_JOINSPORT, "【美女评选】获得技能Buf："..tostring(tbTmp[1][1])..tostring(tbTmp[1][2]));
		end
		
		if szType == "title" then
			pPlayer.AddTitle(unpack(tbTmp));
			pPlayer.SetCurTitle(unpack(tbTmp));
			Dbg:WriteLog("SpecialEvent.Girl_Vote", pPlayer.szName.."获得称号："..tostring(tbTmp[1])..tostring(tbTmp[2])..tostring(tbTmp[3]));
			pPlayer.PlayerLog(Log.emKPLAYERLOG_TYPE_JOINSPORT, "【美女评选】获得称号："..tostring(tbTmp[1])..tostring(tbTmp[2])..tostring(tbTmp[3]));			
		end
		
		if szType == "item" then
			pPlayer.AddStackItem(unpack(tbTmp));
			Dbg:WriteLog("SpecialEvent.Girl_Vote", pPlayer.szName.."获得物品：10玄晶个数："..tostring(tbTmp[6]));
			pPlayer.PlayerLog(Log.emKPLAYERLOG_TYPE_JOINSPORT, "【美女评选】获得物品：10玄晶个数："..tostring(tbTmp[6]));						
		end
		if szType == "equip" then
			pPlayer.AddStackItem(unpack(tbTmp));
			Dbg:WriteLog("SpecialEvent.Girl_Vote", pPlayer.szName.."获得物品：美女活动声望物品个数："..tostring(tbTmp[6]));
			pPlayer.PlayerLog(Log.emKPLAYERLOG_TYPE_JOINSPORT, "【美女评选】获得物品：美女活动声望物品个数："..tostring(tbTmp[6]));	
		end
		if szType == "output" then
			for _, tbTmpEx in ipairs(tbTmp) do
				local pItem = pPlayer.AddItem(tbTmpEx[1], tbTmpEx[2], tbTmpEx[3], tbTmpEx[4]);
				if pItem then
					pItem.Bind(1);
					pPlayer.SetItemTimeout(pItem, tbTmpEx[5], 0);
					Dbg:WriteLog("SpecialEvent.Girl_Vote", pPlayer.szName.."获得物品：外装："..pItem.szName);
					pPlayer.PlayerLog(Log.emKPLAYERLOG_TYPE_JOINSPORT, "【美女评选】获得物品：外装："..pItem.szName);
				end
			end
		end		
	end
	Dialog:Say(szMsg);
	return 1;
end

