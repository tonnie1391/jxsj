-------------------------------------------------------
-- 文件名　：wldh_qualification_gs.lua
-- 创建者　：zhangjinpin@kingsoft
-- 创建时间：2009-09-08 10:37:48
-- 文件描述：
-------------------------------------------------------

Require("\\script\\globalserverbattle\\wldh\\qualification\\wldh_qualification_def.lua");

if (not MODULE_GAMESERVER) then
	return 0;
end

local tbQualification = Wldh.Qualification;

function tbQualification:LoadMember(szPlayerName, tbMemberInfo)
	self.tbGblBuf_Member[szPlayerName] = tbMemberInfo;
end

function tbQualification:ClearBuffer_GS()
	self.tbGblBuf_Member = {};
end

function tbQualification:Broadcast_GS(nState, szCaptainName1, szCaptainName2)
	
	if nState == 1 then
		local szMsg = "本服参加武林大会的前100名选手已产生！详情请查阅修炼珠";
		KDialog.NewsMsg(0, Env.NEWSMSG_COUNT, szMsg);
	
	elseif nState == 2 then
		local szMsg = "英雄帖收集活动结束，产生了50名参加武林大会的选手！详情请查阅修炼珠";
		KDialog.NewsMsg(0, Env.NEWSMSG_COUNT, szMsg);
	
	elseif nState == 3 then
		local szMsg = string.format("恭喜<color=green>%s<color>、<color=green>%s<color>当选为本服的武林盟主，带领本服选手征战武林大会！", szCaptainName1, szCaptainName2);
		KDialog.NewsMsg(0, Env.NEWSMSG_COUNT, szMsg);
	end
end

-- 0-没资格, 1-队员, 2-队长
function tbQualification:CheckMember(pPlayer)
			
	local tbMemberInfo = self.tbGblBuf_Member[pPlayer.szName];
	
	-- 不在名单中
	if not tbMemberInfo then
		return 0;
	end
	
	-- 判断是否队长
	if tbMemberInfo.nCaptain == 1 then
		return 2;
	end
	
	return 1;
end

function tbQualification:Check_Yingxiong()
	
	if self:CheckServer() ~= 1 then
		return 0;
	end
	
	-- 判断资格
	if self:CheckMember(me) ~= 0 then
		return 0;
	end
	
	-- 判断时间
	local nNowDate = tonumber(GetLocalDate("%Y%m%d%H%M"));
	if nNowDate < self.MEMBER_STATE[1] or nNowDate > self.MEMBER_STATE[2] then
		return 0;
	end
	
	return 1;
end

-- 修炼珠对话框
function tbQualification:Yingxiong_Dialog()
	
	local nCount = me.GetTask(self.TASK_GROUP_ID, self.TASK_YINXIONGTIE);
	local nRank = PlayerHonor:GetPlayerHonorRankByName(me.szName, PlayerHonor.HONOR_CLASS_PRETTYGIRL, 0);
	
	if nRank > 0 then
		Dialog:Say(string.format("你已经收集了<color=yellow>%d<color>个英雄帖，在英雄榜中当前排名为<color=yellow>%d<color>。必须要排名到前50名，才会获得参加武林大会的资格哦！", nCount, nRank));
	else
		Dialog:Say(string.format("你已经收集了<color=yellow>%d<color>个英雄帖，尚未进入排行榜。必须要排名到前50名，才会获得参加武林大会的资格哦！", nCount));
	end
end

function tbQualification:Check_Vote()

	if self:CheckServer() ~= 1 then
		return 0;
	end
		
	-- 判断资格
	if self:CheckMember(me) == 0 then
		return 0;
	end

	-- 判断时间
	local nNowDate = tonumber(GetLocalDate("%Y%m%d%H%M"));
	if nNowDate < self.CAPTAIN_STATE[1] or nNowDate > self.CAPTAIN_STATE[2] then
		return 0;
	end
	
	return 1;
end

function tbQualification:Check_Query()

	if self:CheckServer() ~= 1 then
		return 0;
	end
		
	-- 判断时间
	local nNowDate = tonumber(GetLocalDate("%Y%m%d%H%M"));
	if nNowDate < self.MEMBER_STATE[1] or nNowDate > 200910302400 then
		return 0;
	end
	
	return 1;
end

-- 投票对话框
function tbQualification:Vote_Dialog(nFrom)
	
	local nVote = me.GetTask(self.TASK_GROUP_ID, self.TASK_VOTE);
	if nVote > 0 then
		return self:ViewResult();
	end
	
	-- 排序
	local tbSort = {};
	for szPlayerName, tbMemberInfo in pairs(self.tbGblBuf_Member) do
		table.insert(tbSort, {szPlayerName, tbMemberInfo});
	end
	table.sort(tbSort, self._Sort);
	
	local tbOpt = {};
	local nCount = 15;
	local nLast = nFrom or 0;
	
	for _, tbMember in next, tbSort, nFrom do
		
		if nCount <= 0 then
			tbOpt[#tbOpt + 1] = {"Trang sau", self.Vote_Dialog, self, nLast};
			break;
		end
		
		local szTxt = Lib:StrFillL(string.format("<color=yellow>%s<color>：", tbMember[1]), 40);	
		local szMsg = szTxt .. string.format("<color=green>%d票<color>", tbMember[2].nVote);
		
		tbOpt[#tbOpt + 1] = {szMsg, self.DoVote, self, tbMember[1]};
		nCount = nCount - 1;
		nLast = nLast + 1;
	end
	
	tbOpt[#tbOpt + 1] = {"Kết thúc đối thoại"};
	Dialog:Say("你想投给哪一位选手：", tbOpt);
end

function tbQualification:ViewResult()
	
	if not self.tbGblBuf_Member[me.szName] then
		return;
	end
	
	-- 排序
	local tbSort = {};
	for szPlayerName, tbMemberInfo in pairs(self.tbGblBuf_Member) do
		table.insert(tbSort, {szPlayerName, tbMemberInfo});
	end
	table.sort(tbSort, self._Sort);

	local szMsg = "你已经投过票了。\n";
	local nMyVote = self.tbGblBuf_Member[me.szName].nVote;
	szMsg = szMsg .. string.format("你当前收到别人的投票为：<color=yellow>%d<color>\n\n", nMyVote);
	
	local tbOpt = {};
	local nCount = 0;
	
	for _, tbMember in pairs(tbSort) do
		
		if nCount >= 10 then
			break;
		end
		
		nCount = nCount + 1;
		local szTxt = Lib:StrFillL(string.format("第%d名：<color=yellow>%s<color>", nCount, tbMember[1]), 44);	
		szMsg = szMsg .. szTxt .. string.format("- <color=green>%d票<color>\n", tbMember[2].nVote);	
	end
	
	tbOpt[#tbOpt + 1] = {"Kết thúc đối thoại"};
	Dialog:Say(szMsg, tbOpt);
end

function tbQualification:DoVote(szPlayerName)
	
	if not self.tbGblBuf_Member[szPlayerName] then
		return;
	end
	
	self.tbGblBuf_Member[szPlayerName].nVote = self.tbGblBuf_Member[szPlayerName].nVote + 1;
	me.SetTask(self.TASK_GROUP_ID, self.TASK_VOTE, 1);
	
	me.Msg(string.format("你已经成功投票给<color=yellow>%s<color>", szPlayerName));
	
	GCExcute({"Wldh.Qualification:DoVote_GC", szPlayerName});
end

function tbQualification:GetHelpMember()
	
	local szMember = "\n  ";
	local nCount = 0;
	
	for szName, _ in pairs(self.tbGblBuf_Member) do
		szMember = szMember .. Lib:StrFillL(szName, 16);
		nCount = nCount + 1;
		if nCount >= 4 then
			szMember = szMember .. "\n  ";
			nCount = nCount - 4;
		end
	end
	
	return szMember .. "\n";
end

-- only for test
function tbQualification:ClearHelpTable()
	
	local nAddTime = GetTime();
	local nEndTime = nAddTime + 5;
	
	Task.tbHelp:AddDNews(Task.tbHelp.NEWSKEYID.NEWS_WLDH_PROSSESSION, "五秒钟后就消失了", "", nEndTime, nAddTime);
end

-- npc查询名单
function tbQualification:ShowMemberDialog(nFrom)
	
	local tbCaptainName = {};
	local tbMember = {};
	
	for szName, tbMemberInfo in pairs(self.tbGblBuf_Member) do
		if tbMemberInfo.nCaptain == 1 then
			table.insert(tbCaptainName, szName);
		end
		table.insert(tbMember, {szName, tbMemberInfo});
	end
	
	local szMsg = string.format("武林盟主：<color=yellow>%s\n          %s<color>\n\n武林大会选手名单：\n\n", tbCaptainName[1] or "<尚未选出>", tbCaptainName[2] or "<尚未选出>");
	
	local tbOpt = {};
	local nCount = 24;
	local nLast = nFrom or 0;
	
	for _, tbMemberInfo in next, tbMember, nFrom do
		
		if nCount <= 0 then
			tbOpt[#tbOpt + 1] = {"Trang sau", self.ShowMemberDialog, self, nLast};
			break;
		end
		
		szMsg = szMsg .. "<color=green>" .. Lib:StrFillL(tbMemberInfo[1], 17) .. "<color>";
		nCount = nCount - 1;
		nLast = nLast + 1;
		
		if math.mod(nCount, 2) == 0 then
			szMsg = szMsg .. "\n";
		end
	end
	
	tbOpt[#tbOpt + 1] = {"Kết thúc đối thoại"};
	Dialog:Say(szMsg, tbOpt);
end

function tbQualification:CheckChangeBack()	
	local nNowDate = tonumber(GetLocalDate("%Y%m%d%H%M"));
	if nNowDate < self.CAPTAIN_STATE[1] or nNowDate > 200910042400 then
		return 0;
	end
	return 1;
end

function tbQualification:ChangeBackDialog()
	local tbOpt = 
	{
		{"英雄帖兑换绑金", self.GiftChangeBack, self},
		{"领取英雄帖使用返还", self.DirChangeBack, self},
	}
	Dialog:Say("这里可以将你手中剩余的英雄帖兑换成相应的绑金，对于已经使用的英雄帖，如果你没有入围武林大会，则可领到相应的绑金返还。", tbOpt);
end

function tbQualification:DirChangeBack()
	
	if self:CheckMember(me) ~= 0 then
		Dialog:Say("对不起，你已经成功入围武林大会，使用的英雄帖无法兑换绑金");
		return;
	end
	
	local nCount = me.GetTask(self.TASK_GROUP_ID, self.TASK_YINXIONGTIE);
	if nCount <= 0 then
		Dialog:Say("对不起，你没有使用过英雄帖，或者已经兑换完了。");
		return;
	end
	
	me.AddBindCoin(nCount * 500, Player.emKBINDCOIN_ADD_EVENT);
	me.SetTask(self.TASK_GROUP_ID, self.TASK_YINXIONGTIE, 0);
end

function tbQualification:GiftChangeBack()
	local szMsg = "我要将英雄帖兑换为绑金：<color=yellow>1张英雄贴可以兑换500绑金<color>";
	Dialog:OpenGift(szMsg, nil, {Wldh.Qualification.OnGiftChangeBack, Wldh.Qualification});
end

function tbQualification:OnGiftChangeBack(tbItem)
	
	local tbType = {18, 1, 471, 1};
	
	local nExCount = 0;
	for _, tbItem in pairs(tbItem) do
		local pItem = tbItem[1];
		local szKey = string.format("%s,%s,%s,%s", pItem.nGenre, pItem.nDetail, pItem.nParticular, pItem.nLevel)
		
		if szKey == string.format("%s,%s,%s,%s", unpack(tbType)) then
			nExCount = nExCount + pItem.nCount;
		end
	end
	
	if nExCount <= 0 then
		Dialog:Say("请放入正确的物品。");
		return 0;
	end
	
	local nExTempCount = 0;
	for _, tbItem in pairs(tbItem) do
		local pItem = tbItem[1];
		local szKey = string.format("%s,%s,%s,%s", pItem.nGenre, pItem.nDetail, pItem.nParticular, pItem.nLevel)
		if szKey == string.format("%s,%s,%s,%s", unpack(tbType)) then
			me.DelItem(pItem);
			nExTempCount = nExTempCount + pItem.nCount;
		end
		if nExTempCount >= nExCount then
			break;
		end
	end
		
	me.AddBindCoin(nExCount * 500, Player.emKBINDCOIN_ADD_EVENT);
	me.SetTask(self.TASK_GROUP_ID, self.TASK_YINXIONGTIE, 0);
end