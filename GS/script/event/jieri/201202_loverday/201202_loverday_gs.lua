-- 文件名　：201202_loverday_gs.lua
-- 创建者　：zhangjunjie
-- 创建时间：2012-02-02 15:37:10
-- 描述：gs

if  not MODULE_GAMESERVER then
	return;
end

Require("\\script\\event\\jieri\\201202_loverday\\201202_loverday_def.lua");

SpecialEvent.LoverDay2012 = SpecialEvent.LoverDay2012 or {};
local LoverDay2012 = SpecialEvent.LoverDay2012;


--------玫瑰情缘活动
function LoverDay2012:OnRoseLoveEvent()
	local nRet , szError = self:CheckCanGetRoseLoveTask();
	if nRet ~= 1 then
		Dialog:Say(szError);
		return 0;
	end
	local szMsg = 	"    <color=pink>浪漫情人节，花香飘四方。<color>携一束浪漫的玫瑰，表一片诚挚的真心。\n    2月14日-2月16日期间，每天<color=yellow>19:00-22:00<color>,与异性组队接取玫瑰情缘任务,并根据任务提示在各大城市采摘玫瑰点缀春色撩人的花坛，将有爱神为你们送上<color=red>爱的祝福<color>。更有<color=yellow>稀有面具、尊贵坐骑、华丽翅膀<color>等惊喜礼物！\n    情人陪伴享时光，朋友相伴一起玩，情人节快乐！";
	local tbOpt = {};
	tbOpt[#tbOpt + 1] = {"<color=yellow>领取春色撩人的花坛点缀<color>",self.GiveRoseLoveItem,self}
	tbOpt[#tbOpt + 1] = {"Để ta suy nghĩ thêm"}
	Dialog:Say(szMsg,tbOpt);
end

function LoverDay2012:GiveRoseLoveItem()
	local nRet , szError = self:CheckCanGetRoseLoveTask();
	if nRet ~= 1 then
		Dialog:Say(szError);
		return 0;
	end
	local tbGdpl = self.tbRoseLoveItem;
	local pItem = me.AddItem(unpack(tbGdpl));
	if pItem then
		local tbMember = me.GetTeamMemberList();
		local szBelong = "";
		for _,pPlayer in pairs(tbMember) do
			if pPlayer then
				pPlayer.SetTask(self.nTaskGroupId,self.nLastGetRoseLoveTimeTaskId,GetTime());
				pPlayer.SetTask(self.nTaskGroupId,self.nHasGetRoseLovePrizeTaskId,0);	--接取过任务就清空奖励
				szBelong = szBelong .. pPlayer.szName .. "\t";
				StatLog:WriteStatLog("stat_info","valentine_2012","get_rose_task",pPlayer.nId,1);
				Dialog:SendBlackBoardMsg(pPlayer,"成功接取玫瑰情缘任务，请队长摆放花坛！");
			end
		end
		pItem.SetTaskBuff(2,1,szBelong);
	else
		Dbg:WriteLog("SpecialEvent","Loverday2012,Give RoseLove Item Failed!",me.nId,me.szName);		
	end
end

function LoverDay2012:CheckCanGetRoseLoveTask()
	if self:IsEventOpen() ~= 1 then 
		return 0,string.format("%s：对不起，该活动已经结束！",me.szName);
	end
	if self:IsTimeRoseLoveBegin() ~= 1 then
		return 0,"    现在还未到活动的时间！2月14日-2月16日期间，每天<color=yellow>19:00-22:00<color>,可以与异性组队接取玫瑰情缘任务！";
	end
	if me.nLevel < self.nJoinEventBaseLevel then
		return 0,"对不起，你的等级未达到50级！";
	end
	local nTeamId = me.nTeamId;
	if nTeamId <= 0 then
		return 0,"爱神说情人节不可以一个人，需要甜蜜拍档<color=yellow>组队<color>才有爱的祝福！";
	end
	local tbMemberId,nCount = KTeam.GetTeamMemberList(nTeamId);
	if nCount <= 1 or nCount > 2 then
		return 0,"好事成双，<color=yellow>必须两人队伍噢。<color>";
	end
	if me.IsCaptain() ~= 1 then
		return 0,"只有<color=yellow>队长<color>才能接取任务噢！";
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
		return 0,"<color=yellow>你的队友离你太远了<color>，靠近一点，在靠近一点！";
	end
	local tbMember = me.GetTeamMemberList();
	local tbSex = {};
	local nIsPlayerNotReachLevel = 0;	--等级是否都达到
	local nIsPlayerHasGetTask = 0;	--是否都未接取任务
	local nDiffSex = 0;
	for _,pPlayer in pairs(tbMember) do
		if pPlayer then
			table.insert(tbSex,pPlayer.nSex);
			local nLastGetTime = pPlayer.GetTask(self.nTaskGroupId,self.nLastGetRoseLoveTimeTaskId);
			if os.date("%Y%m%d",GetTime()) == os.date("%Y%m%d",nLastGetTime) then
				nIsPlayerHasGetTask = 1;
			end
			if pPlayer.nLevel < self.nJoinEventBaseLevel then
				nIsPlayerNotReachLevel = 1;
			end	
		end
	end
	if tbSex[1] and tbSex[2] then
		if tbSex[1] ~= tbSex[2] then
			nDiffSex = 1;
		end
	end
	if nDiffSex ~= 1 then
		return 0,"爱神说只能与<color=yellow>异性<color>组队才有爱的祝福！";
	end
	if nIsPlayerNotReachLevel == 1 then
		return 0,"队伍中有玩家等级未达到50级，快去升级吧，亲！";
	end
	if nIsPlayerHasGetTask == 1 then
		return 0,"队伍中有玩家今天已经接取过任务了，不要贪心噢，每人一天只能接取<color=yellow>1次<color>任务！";
	end
	if me.CountFreeBagCell() < 1 then
		return 0,"需要<color=green>1格<color>背包空间，整理下再来！";
	end
	return 1;
end



----------爱情对对碰
function LoverDay2012:OnLoveRingMatch()
	local nLastGetTime = me.GetTask(self.nTaskGroupId,self.nLastGetRingTimeTaskId);
	local nNowTime = GetTime();
	if tonumber(os.date("%Y%m%d",nLastGetTime)) ~= tonumber(os.date("%Y%m%d",nNowTime)) then	--隔天会把领取次数和时间清零
		me.SetTask(self.nTaskGroupId,self.nLastGetRingTimeTaskId,0);
		me.SetTask(self.nTaskGroupId,self.nGetRingCountStep1TaskId,0);
		me.SetTask(self.nTaskGroupId,self.nGetRingCountStep2TaskId,0);
	end
	local szMsg = "    情人节日，双双对对；若还单身，是你不对。\n    2月14日-2月16日<color=yellow>11:00-14:00、19:00-21:00<color>，每个时间段内，男侠客可领取<color=yellow>1枚<color>钻戒，女侠客可领取<color=yellow>2枚<color>钻戒！领取真爱钻戒后寻找与自己钻戒相同的异性侠客，并进行配对，队长获得<color=red>情缘红烛<color>，点燃后可获得<color=red>丘比特的祝福<color>，更有真爱誓约让二人相守相随。赶快行动，找人约会，手捧玫瑰，真心表白吧！";
	local tbOpt = {};
	tbOpt[#tbOpt + 1] = {"<color=yellow>领取真爱钻戒<color>",self.GetRing,self};
	tbOpt[#tbOpt + 1] = {"<color=pink>钻戒配对<color>",self.RingMatch,self};
	tbOpt[#tbOpt + 1] = {"<color=yellow>真爱誓约介绍<color>",self.CardDescription,self};
	tbOpt[#tbOpt + 1] = {"Để ta suy nghĩ thêm"}
	Dialog:Say(szMsg,tbOpt);
end

function LoverDay2012:CardDescription()
	local szMsg = "    <color=pink>真爱誓约<color>是组队的妹妹偷偷塞给你的定情信物。\n    <color=yellow>2月17日0:00-2月19日23:39<color>之间，凭<color=pink>真爱誓约<color>并与给你誓约的女士<color=yellow>一起组队即可领取到一份天长地久的奖励。<color>\n    你也可以拿誓约卡随时向对方表达最真挚的想念，发送爱的密语。\n    柳梢头，黄昏后，浪漫相约小村口。问世间，情何物，未见伊人愁上愁。移星座，转北斗，有情有义天地久。情无尽，爱不够，抱定痴爱永相守。<color=red>情人节快乐！<color>";
	Dialog:Say(szMsg,{"Ta hiểu rồi"});
end

function LoverDay2012:CheckCanGetGetRing()
	if self:IsEventOpen() ~= 1 then
		return 0,string.format("%s：对不起，该活动已经结束！",me.szName);
	end
	local nTime = tonumber(os.date("%H%M",GetTime()));
	if (nTime < self.nLoveMatchBeginTimeDay or 
		nTime >= self.nLoveMatchEndTimeDay) and
		(nTime < self.nLoveMatchBeginTimeNight or 
		nTime >= self.nLoveMatchEndTimeNight) then
		return 0,"    请在指定时间来领取真爱钻戒！\n    领取时间为2月14日-2月16日<color=yellow>11:00-14:00、19:00-21:00<color>，在时间段内，男侠客可领取<color=yellow>1枚<color>钻戒，女侠客可领取<color=yellow>2枚<color>钻戒！";		
	end
	if me.nLevel < self.nJoinEventBaseLevel then
		return 0,string.format("等级未达到<color=green>%s级<color>的侠客无法参加！",self.nJoinEventBaseLevel);
	end
	local nLastGetTime = tonumber(os.date("%H%M",me.GetTask(self.nTaskGroupId,self.nLastGetRingTimeTaskId)));
	if nTime >= self.nLoveMatchBeginTimeDay and 
		nTime <= self.nLoveMatchEndTimeDay and
		nLastGetTime >= self.nLoveMatchBeginTimeDay and 
		nLastGetTime <= self.nLoveMatchEndTimeDay then
		local nGetCount = me.GetTask(self.nTaskGroupId,self.nGetRingCountStep1TaskId);
		if nGetCount >= self.tbCanGetMaxRing[me.nSex] then
			return 0,string.format("每个时间段只能领%s枚钻戒，请等待下一个阶段再来领取钻戒！",self.tbCanGetMaxRing[me.nSex]);
		end		
	end
	if nTime >= self.nLoveMatchBeginTimeNight and 
		nTime <= self.nLoveMatchEndTimeNight and
		nLastGetTime >= self.nLoveMatchBeginTimeNight and 
		nLastGetTime <= self.nLoveMatchEndTimeNight then
		local nGetCount = me.GetTask(self.nTaskGroupId,self.nGetRingCountStep2TaskId);
		if nGetCount >= self.tbCanGetMaxRing[me.nSex] then
			return 0,string.format("每个时间段只能领%s枚钻戒，请等待下一个阶段再来领取钻戒！",self.tbCanGetMaxRing[me.nSex]);
		end	
	end
	if me.CountFreeBagCell() < 1 then
		return 0,"需要<color=green>1格<color>背包空间，整理下再来！";
	end
	return 1;
end

function LoverDay2012:GetRing()
	local nRet,szError = self:CheckCanGetGetRing();
	if nRet ~= 1 then
		Dialog:Say(szError);
		return 0;
	end
	local tbRing = self.tbRingGdpl;
	local tbGdpl = tbRing[MathRandom(#tbRing)];
	local pItem = me.AddItem(unpack(tbGdpl));
	if not pItem then
		Dbg:WriteLog("SpecialEvent","Loverday2012,Give Ring Item Failed!",me.nId,me.szName);	
	else
		--记录领取的次数和时间
		local nTime = tonumber(os.date("%H%M",GetTime()));
		if nTime >= self.nLoveMatchBeginTimeDay and nTime <= self.nLoveMatchEndTimeDay then
			local nGetCount = me.GetTask(self.nTaskGroupId,self.nGetRingCountStep1TaskId);
			me.SetTask(self.nTaskGroupId,self.nGetRingCountStep1TaskId,nGetCount + 1);
			me.SetTask(self.nTaskGroupId,self.nLastGetRingTimeTaskId,GetTime());
		else
			local nGetCount = me.GetTask(self.nTaskGroupId,self.nGetRingCountStep2TaskId);
			me.SetTask(self.nTaskGroupId,self.nGetRingCountStep2TaskId,nGetCount + 1);
			me.SetTask(self.nTaskGroupId,self.nLastGetRingTimeTaskId,GetTime());
		end
		StatLog:WriteStatLog("stat_info","valentine_2012","get_ring",me.nId,1);
		local szMsg = string.format("Bạn nhận được một <color=green>%s<color>！",pItem.szName);
		Dialog:SendBlackBoardMsg(me,szMsg);
	end
end

function LoverDay2012:RingMatch()
	local nRet,szError = self:CheckCanMatchRing();
	if nRet ~= 1 then
		Dialog:Say(szError);
		me.Msg(szError);
		return 0;
	end
	local nRet,tbRingGdpl = self:CheckTeamCanMatchRing();
	if nRet ~= 1 then
		return 0;
	end
	local tbMember = me.GetTeamMemberList();
	local nIsAllDelOk = 1;
	for _,pPlayer in pairs(tbMember) do
		if pPlayer then
			local tbFind = pPlayer.FindItemInBags(unpack(tbRingGdpl));
			if #tbFind > 0 then
				if pPlayer.DelItem(tbFind[1].pItem,Player.emKLOSEITEM_USE) ~= 1 then
					nIsAllDelOk = 0;
					Dbg:WriteLog("SpecialEvent","Loverday2012,Delete Ring Item Failed!",pPlayer.nId,pPlayer.szName);	
				end
			end
		end
	end
	if nIsAllDelOk == 1 then
		local tbName = {};
		for _,pPlayer in pairs(tbMember) do
			if pPlayer then
				Dialog:SendBlackBoardMsg(pPlayer,"丘比特已将你与队友甜蜜锁定，请队长点燃红烛！");
				table.insert(tbName,pPlayer.szName);
			end
		end
		StatLog:WriteStatLog("stat_info","valentine_2012","T_ring",0,tbName[1] or "",tbName[2] or "");
		local pItem = me.AddItem(unpack(self.tbRingMatchItemGdpl));
		if pItem then
			local szBelong = "";
			szBelong = szBelong .. tbMember[1].szName .. "\n" .. tbMember[2].szName;	--记录这个道具属于哪两个玩家的
			pItem.SetTaskBuff(2,1,szBelong);
			if MathRandom(self.tbGetCardRate[2]) == self.tbGetCardRate[1] then
				local pCard = me.AddItem(unpack(self.tbCardGdpl));
				if not pCard then
					Dbg:WriteLog("SpecialEvent","Loverday2012,Add Card Item Failed!",me.nId,me.szName);	
				else
					local szFrom = (tbMember[1].szName ~= me.szName and tbMember[1].szName or tbMember[2].szName);
					pCard.SetTaskBuff(2,1,szFrom); --记录是谁祝福的
					StatLog:WriteStatLog("stat_info","valentine_2012","get_card",me.nId,szFrom,0);
					Dialog:SendBlackBoardMsg(me,string.format("<color=yellow>%s<color>偷偷塞给你了一张真爱誓约！",szFrom));
				end
			end
		else
			Dbg:WriteLog("SpecialEvent","Loverday2012,Add Hongzhu Item Failed!",me.nId,me.szName);	
		end
	end
end


function LoverDay2012:CheckCanMatchRing()
	if self:IsEventOpen() ~= 1 then
		return 0,string.format("%s：对不起，该活动已经结束！",me.szName);
	end
	local nTeamId = me.nTeamId;
	if nTeamId <= 0 then
		return 0,"爱神说情人节不可以一个人，需要甜蜜拍档<color=yellow>组队<color>才有爱的祝福！";
	end
	local tbMemberId,nCount = KTeam.GetTeamMemberList(nTeamId);
	if nCount ~= 2 then
		return 0,"好事成双，<color=yellow>必须两人队伍噢。<color>";
	end
	if me.IsCaptain() ~= 1 then
		return 0,"只有<color=yellow>队长<color>才能前来完成配对噢！";
	end
	if me.nSex ~= Player.MALE then
		return 0,"只有<color=green>男侠客做为队长<color>才能完成配对噢！";
	end
	local nNearby = 0;
	local tbPlayerList = KPlayer.GetAroundPlayerList(me.nId,30) or {};
	for _, tbRound in pairs(tbPlayerList) do
		for _, nMemberId in pairs(tbMemberId) do
			local pMember = KPlayer.GetPlayerObjById(nMemberId);
			if pMember and pMember.szName == tbRound.szName then
				nNearby = nNearby + 1;
			end
		end
	end
	if nNearby ~= nCount then
		return 0,"<color=yellow>你的队友离你太远了<color>，靠近一点，在靠近一点！";
	end
	local tbMember = me.GetTeamMemberList();
	local tbSex = {};
	local nIsPlayerNotReachLevel = 0;	--等级是否都达到
	local nDiffSex = 0;
	for _,pPlayer in pairs(tbMember) do
		if pPlayer then
			table.insert(tbSex,pPlayer.nSex);
			if pPlayer.nLevel < self.nJoinEventBaseLevel then
				nIsPlayerNotReachLevel = 1;
			end	
		end
	end
	if tbSex[1] and tbSex[2] then
		if tbSex[1] ~= tbSex[2] then
			nDiffSex = 1;
		end
	end
	if nDiffSex ~= 1 then
		return 0,"爱神说只能与<color=yellow>异性<color>组队才有爱的祝福！";
	end
	if nIsPlayerNotReachLevel == 1 then
		return 0,"队伍中有玩家等级未达到50级，快去升级吧，亲！";
	end
	local nRet,tbGdpl = self:CheckTeamCanMatchRing();
	if nRet ~= 1 then
		return 0,"队友和你没有可以配对的钻戒，去寻找正确的那个人吧！";	
	end
	if me.CountFreeBagCell() < 1 then
		return 0,"请保证留出<color=green>1<color>格背包空间！";	
	end
	return 1;
end

--检测是否能配对
function LoverDay2012:CheckTeamCanMatchRing()
	local tbMember = me.GetTeamMemberList();
	local tbMyGdpl = nil;
	local tbMateGdpl = nil;
	if me.nSex == Player.FEMALE then
		for _,pMember in pairs(tbMember) do
			if pMember.szName ~= me.szName then
				for _,tbGdpl in pairs(self.tbRingGdpl) do
					local tbFind = pMember.FindItemInBags(unpack(tbGdpl));
					if #tbFind > 0 then
						tbMateGdpl = tbGdpl;
						break;
					end					
				end
			end			
		end
		if not tbMateGdpl then
			return 0;
		end
		local tbFind = me.FindItemInBags(unpack(tbMateGdpl));
		if #tbFind > 0 then
			return 1,tbMateGdpl;
		else
			return 0;
		end	
	else
		for _,tbGdpl in pairs(self.tbRingGdpl) do
			local tbFind = me.FindItemInBags(unpack(tbGdpl));
			if #tbFind > 0 then
				tbMyGdpl = tbGdpl;
				break;
			end					
		end
		if not tbMyGdpl then
			return 0;
		end
		for _,pMember in pairs(tbMember) do
			if pMember.szName ~= me.szName then
				local tbFind = pMember.FindItemInBags(unpack(tbMyGdpl));
				if #tbFind > 0 then
					return 1,tbMyGdpl;
				else
					return 0;
				end	
			end			
		end
	end
end

-------------刷npc
function LoverDay2012:AddNpc_GS()
	if self:IsEventOpen() ~= 1 then
		return 0;
	end
	if not self.nIsNpcAdded or self.nIsNpcAdded ~= 1 then
		self:AddNpc();
	end
end

-------------加npc
function LoverDay2012:AddNpc()
	if not self.tbNpcPos then
		self:LoadNpcPos();
	end
	for nMapId,tbInfo in pairs(self.tbNpcPos) do
		if IsMapLoaded(nMapId) == 1 then
			for nTemplateId,tbPosInfo in pairs(tbInfo) do
				for _,tbPos in pairs(tbPosInfo) do
					local nX = tbPos[1];
					local nY = tbPos[2];
					local pNpc = KNpc.Add2(nTemplateId,1,-1,nMapId,nX,nY);
				end
			end
		end
	end
	self.nIsNpcAdded = 1;	--标记已经刷过了
end

function LoverDay2012:LoadNpcPos()
	if not self.tbNpcPos then
		self.tbNpcPos = {};
	end
	local tbFile = Lib:LoadTabFile(self.szNpcPosFile);
	if not tbFile then
		Dbg:WriteLog("SpecialEvent","Loverday2012,Load Npc Pos Failed!",self.szNpcPosFile);
		return 0;
	end
	for _,tbInfo in ipairs(tbFile) do
		local nMapId = tonumber(tbInfo.MapId);
		local nTemplateId = tonumber(tbInfo.TemplateId);
		if not self.tbNpcPos[nMapId] then
			self.tbNpcPos[nMapId] = {};
		end
		if not self.tbNpcPos[nMapId][nTemplateId] then
			self.tbNpcPos[nMapId][nTemplateId] = {};
		end
		local tbTemp = {tonumber(tbInfo.PosX),tonumber(tbInfo.PosY)};
		table.insert(self.tbNpcPos[nMapId][nTemplateId],tbTemp);
	end	
end
	
	
--服务器启动事件
function LoverDay2012:OnServerStart()
	if self:IsEventOpen() ~= 1 then
		return 0;
	end
	self:AddNpc();	
end

--注册启动回调
if tonumber(os.date("%Y%m%d",GetTime())) <= LoverDay2012.nEndTime then 
	ServerEvent:RegisterServerStartFunc(LoverDay2012.OnServerStart,LoverDay2012);
end



---------活动公告
function LoverDay2012:NotifyRoseLoveMsg_GS()
	self:AnnounceMsg(self.szRoseLoveNotify);
	self.nRoseLoveNotifyCount = 1;
	self.nRoseLoveNotifyTimer = Timer:Register(self.nRoseLoveNotifyTime,self.OnRoseLoveNotifyMsg,self);
end

function LoverDay2012:OnRoseLoveNotifyMsg()
	self:AnnounceMsg(self.szRoseLoveNotify);
	self.nRoseLoveNotifyCount = self.nRoseLoveNotifyCount + 1;
	if self.nRoseLoveNotifyCount >= self.nRoseLoveNotifyMaxCount then
		self.nRoseLoveNotifyTimer = 0;
		return 0;
	end
end

function LoverDay2012:NotifyMatchMsg_GS()
	self:AnnounceMsg(self.szMatchNotify);
	self.nMatchNotifyCount = 1;
	self.nMatchNotifyTimer = Timer:Register(self.nMatchNotifyTime,self.OnMatchNotifyMsg,self);
end

function LoverDay2012:OnMatchNotifyMsg()
	self:AnnounceMsg(self.szMatchNotify);
	self.nMatchNotifyCount = self.nMatchNotifyCount + 1;
	if self.nMatchNotifyCount >= self.nMatchNotifyMaxCount then
		self.nMatchNotifyTimer = 0;
		return 0;
	end
end

function LoverDay2012:AnnounceMsg(szMsg)
	if not szMsg or #szMsg <= 0 then
		return 0;
	end
	KDialog.NewsMsg(0,Env.NEWSMSG_NORMAL,szMsg);
	KDialog.Msg2SubWorld(szMsg);
end


---test--------------
function LoverDay2012:TestBox()
	local tbGdpl = {
	 	{18,1,1647,1},	
	 	{18,1,1652,1},	
	 	{18,1,1654,1},
	 	{18,1,1661,1},	
	};
	local nCount = 1000;
	for _,tb in pairs(tbGdpl) do
		local tbFind = me.FindItemInBags(unpack(tb));
		if #tbFind > 0 then
			for i = 1,nCount do
				local pItem = tbFind[1].pItem;
				Setting:SetGlobalObj(me,nil,pItem);
				local nRet,nExt = Item:GetClass("loverday_box_common"):OnUse();
				Setting:RestoreGlobalObj();
			end
		end
	end
end