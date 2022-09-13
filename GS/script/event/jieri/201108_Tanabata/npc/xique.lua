-- 文件名　：xique.lua
-- 创建者　：zhangjunjie
-- 创建时间：2011-07-22 14:40:47
-- 描述：喜鹊

local tbNpc = Npc:GetClass("QX_xique");

SpecialEvent.Tanabata201108 =  SpecialEvent.Tanabata201108 or {};
local Tanabata201108 = SpecialEvent.Tanabata201108;


function tbNpc:OnDialog()
	if Tanabata201108:CheckEventOpen() ~= 1 then
		Dialog:Say("喜鹊:"..me.szName..", xin chào!");
		return 0;
	end
	local szMsg = "    纤云弄巧，飞星传恨，银汉迢迢暗度。金风玉露一相逢，便胜却、人间无数。 柔情似水，佳期如梦。忍顾鹊桥归路！两情若是久长时，又岂在、朝朝暮暮 。\n    8月4日--8月8日期间，每天8：00--23：50分，你可以把这一天收集到的书卷交给我，所收集到的不重复书卷越多，我所给你馈赠就越丰厚，书卷每天只能上交一次哦。";
	local tbOpt = {};
	for i = 1,#Tanabata201108.tbTaskMap do
		tbOpt[#tbOpt + 1] = {"送我去玉露村" .. tostring(i),self.OnTransfer,self,i};
	end
	tbOpt[#tbOpt + 1] = {"<color=yellow>用书卷兑换奖励<color>",self.ChangePrize,self,him.dwId};
	tbOpt[#tbOpt + 1] = {"Để ta suy nghĩ thêm"};
	Dialog:Say(szMsg,tbOpt);
end

function tbNpc:OnTransfer(nIndex)
	if me.nLevel < 60 then
		Dialog:Say("对不起，你的等级不满60级，无法前往玉露村。");
		return 0;
	end
	local nTeamId = me.nTeamId;
	if nTeamId <= 0 then
		Dialog:Say("对不起，必须要组队前往玉露村。");
		return 0;
	end
	local tbMemberId,nCount = KTeam.GetTeamMemberList(nTeamId);
	if nCount <= 1 or nCount > 2 then
		Dialog:Say("对不起，只有两人队伍才能进入。");
		return 0;
	end
	if me.IsCaptain() ~= 1 then
		Dialog:Say("对不起，只有队长才能带领进入。");
		return 0;
	end
	local nNearby = 0;
	local tbPlayerList = KPlayer.GetAroundPlayerList(me.nId, 50);
	for _, tbRound in pairs(tbPlayerList or {}) do
		for _, nMemberId in pairs(tbMemberId) do
			local pMember = KPlayer.GetPlayerObjById(nMemberId);
			if pMember and pMember.szName == tbRound.szName then
				nNearby = nNearby + 1;
			end
		end
	end
	if nNearby ~= nCount then
		Dialog:Say("对不起，你的队友离你太远了。");
		return 0;
	end
	local tbMember = me.GetTeamMemberList();
	local tbSex = {};
	local nDiffSex = 0;
	for _,pPlayer in pairs(tbMember) do
		if pPlayer then
			table.insert(tbSex,pPlayer.nSex);
		end
	end
	if tbSex[1] and tbSex[2] then
		if tbSex[1] ~= tbSex[2] then
			nDiffSex = 1;
		end
	end
	if nDiffSex ~= 1 then
		Dialog:Say("对不起，必须和异性组队才能进入。");
		return 0;
	end
	local nFlag = 0;
	local szWarnning = "";
	for _, nMemberId in pairs(tbMemberId) do
		local pMember = KPlayer.GetPlayerObjById(nMemberId);
		if pMember then
			local bHasTask = Task:GetPlayerTask(pMember).tbTasks[473];
			if not bHasTask then
				szWarnning = szWarnning .. string.format("<color=yellow>%s<color>没有接取同心情缘任务\n", pMember.szName);
				nFlag = 1;
			end
		end
	end
	if nFlag == 1  then
		Dialog:Say(szWarnning);
		return 0;
	end
	local tbPos = Tanabata201108.tbTaskMap[nIndex];
	local nOk, szError = Map:CheckTagServerPlayerCount(tbPos[1]);
	if nOk ~= 1 then
		Dialog:Say(szError);
		return 0;
	end
	for _, nMemberId in pairs(tbMemberId) do
		local pMember = KPlayer.GetPlayerObjById(nMemberId);
		if pMember then
			pMember.SetFightState(1);
			pMember.NewWorld(unpack(tbPos));
		end
	end
end


function tbNpc:ChangePrize(nNpcId)
	local nTime = tonumber(GetLocalDate("%H%M%S"));
	if nTime < Tanabata201108.nChangePrizeStartTime or nTime > Tanabata201108.nChangePrizeEndTime then
		Dialog:Say("现在还不是兑奖的时间哦！");
		return 0;
	end
	if tonumber(os.date("%Y%m%d",me.GetTask(Tanabata201108.TASK_GROUP ,Tanabata201108.CHANGE_PRIZE_TIME))) < tonumber(os.date("%Y%m%d",GetTime())) then
		me.SetTask(Tanabata201108.TASK_GROUP ,Tanabata201108.CHANGE_PRIZE_TIME,GetTime());
		me.SetTask(Tanabata201108.TASK_GROUP ,Tanabata201108.CHANGE_PRIZE,0);
	end
	if me.GetTask(Tanabata201108.TASK_GROUP ,Tanabata201108.CHANGE_PRIZE) == 1 then
		Dialog:Say("每人一天只能换取一次奖励，你今天已经换取过了，请明天再来吧!");
		return 0;
	end
	local szMsg = "请放入你所收集到书卷。放入3本、5本、7本、9本、10本、11本、12本不同的书卷，会得到不同档次的奖励！每人每天只能兑换一次哦！";
	Dialog:OpenGift(szMsg, nil, {self.OnInputBook, self,nNpcId});
end


function tbNpc:OnInputBook(nNpcId,tbItemObj,bSure)
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		return 0;
	end
	local nCanChange,szError = self:CheckCanChange(tbItemObj);
	if nCanChange ~= 1 then
		Dialog:Say(szError);
		return 0;
	end
	local nCount = #tbItemObj;
	local tbPrizeInfo = {};
	if TimeFrame:GetServerOpenDay() <= 60 then
		tbPrizeInfo = Tanabata201108.tbPrizeInfo_NewServer[nCount];
	else
		tbPrizeInfo = Tanabata201108.tbPrizeInfo[nCount];
	end
	if not tbPrizeInfo then
		return 0;
	end
	if not bSure then
		local szMsg = string.format("您确定要上交<color=yellow>%s<color>本书卷进行奖励兑换么？每人每天只能兑换一次奖励，上交的书卷越多获得奖励越丰厚。",nCount);
		local tbOpt = {};
		tbOpt[#tbOpt + 1] = {"确定兑换",self.OnInputBook,self,nNpcId,tbItemObj,1};
		tbOpt[#tbOpt + 1] = {"我在想想",self.OnInputBook,self,nNpcId,tbItemObj,0};
		Dialog:Say(szMsg,tbOpt);
	end
	if bSure and bSure == 1 then
		for _,pItem in pairs(tbItemObj) do
			if pItem[1] then
				me.DelItem(pItem[1],0);
			end
		end
		for _,tbInfo in pairs(tbPrizeInfo) do
			local pItem = me.AddItem(unpack(tbInfo));
			if pItem then
				me.SetTask(Tanabata201108.TASK_GROUP ,Tanabata201108.CHANGE_PRIZE,1);	--标记已经领取过奖励了
				StatLog:WriteStatLog("stat_info", "qixi_2011","change_award", me.nId,nCount);
				if nCount == 12 then	--产出了技能宝石，则不再产出
					GCExcute{"SpecialEvent.Tanabata201108:SetStoneBorn",1};
				end
			else
				Dbg:WriteLog("SpecialEvent.Tanabata201108","Item generate error",me.szName,me.nId);
			end
		end
	elseif bSure and bSure == 0 then
		return 0;
	end
end


function tbNpc:CheckCanChange(tbItemObj)
	local nTime = tonumber(GetLocalDate("%H%M%S"));
	if nTime < Tanabata201108.nChangePrizeStartTime or nTime > Tanabata201108.nChangePrizeEndTime then
		return 0,"现在还不是兑奖的时间哦！";
	end
	if not tbItemObj or #tbItemObj == 0 then
		return 0,"请放入要进行兑换的书卷。";
	end
	local nHasPrize = 0;
	local nItemCount = #tbItemObj;
	for nCount , tbInfo in pairs(Tanabata201108.tbPrizeInfo) do
		if nCount == nItemCount then
			nHasPrize = 1;
			break;
		end	
	end
	if nHasPrize ~= 1 then
		return 0,"您放入的书卷数量没有对应的奖励！放入3本、5本、7本、9本、10本、11本、12本不同的书卷，会得到不同档次的奖励！每人每天只能兑换一次奖励，上交的书卷越多获得奖励越丰厚。";
	end
	local tbItem = {};
	local nHasSame = 0;	--是否有相同的书
	local nHasOtherItem = 0; --是否有其它的物品
	for _,tbObj in pairs(tbItemObj) do
		table.insert(tbItem,{tbObj[1].nGenre,tbObj[1].nDetail,tbObj[1].nParticular,tbObj[1].nLevel});	
	end
	for i = 1 ,#tbItem do
		for j = i + 1,#tbItem do
			if string.format("%s%s%s%s",tbItem[i][1],tbItem[i][2],tbItem[i][3],tbItem[i][4]) == 
					string.format("%s%s%s%s",tbItem[j][1],tbItem[j][2],tbItem[j][3],tbItem[j][4]) then
				nHasSame = 1;
			end
		end
	end
	if nHasSame == 1 then
		return 0,"您放入的书卷中有重复的书卷，无法兑换奖励！";
	end
	for i = 1 ,#tbItem do
		if string.format("%s,%s,%s",tbItem[i][1],tbItem[i][2],tbItem[i][3],tbItem[i][4]) ~= Tanabata201108.szBookGDP then
			nHasOtherItem = 1;
		end
	end
	if nHasOtherItem == 1 then
		return 0,"您放入的物品中存在其它不是书卷的道具，无法进行兑换！";
	end
	return 1;
end
