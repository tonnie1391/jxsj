-- 文件名　：201202_loverday_npc.lua
-- 创建者　：zhangjunjie
-- 创建时间：2012-02-02 14:59:52
-- 描述：2012情人节npc

SpecialEvent.LoverDay2012 = SpecialEvent.LoverDay2012 or {};
local LoverDay2012 = SpecialEvent.LoverDay2012;


local tbEvent = 
{
	Player.ProcessBreakEvent.emEVENT_MOVE,
	Player.ProcessBreakEvent.emEVENT_ATTACK,
	Player.ProcessBreakEvent.emEVENT_SITE,
	Player.ProcessBreakEvent.emEVENT_USEITEM,
	Player.ProcessBreakEvent.emEVENT_ARRANGEITEM,
	Player.ProcessBreakEvent.emEVENT_DROPITEM,
	Player.ProcessBreakEvent.emEVENT_SENDMAIL,
	Player.ProcessBreakEvent.emEVENT_TRADE,
	Player.ProcessBreakEvent.emEVENT_CHANGEFIGHTSTATE,
	Player.ProcessBreakEvent.emEVENT_CLIENTCOMMAND,
	Player.ProcessBreakEvent.emEVENT_LOGOUT,
	Player.ProcessBreakEvent.emEVENT_DEATH,
	Player.ProcessBreakEvent.emEVENT_ATTACKED,
}


--活动npc
local tbEventNpc = Npc:GetClass("loverday_npc_2012");

function tbEventNpc:OnDialog()
	local szMsg = "    <color=yellow>执子之手，与子偕老。<color> 一朵玫瑰代表一份简单纯洁的爱情，一束玫瑰代表一段狂热冲动的爱情，一团玫瑰则代表一句一生一世的承诺！<color=pink>愿各位有情人终成眷属，情人节快乐！<color>"
	local tbOpt = {};
	tbOpt[#tbOpt + 1] = {"<color=pink>玫瑰情缘<color>",LoverDay2012.OnRoseLoveEvent,LoverDay2012};
	tbOpt[#tbOpt + 1] = {"<color=yellow>爱神对对碰<color>",LoverDay2012.OnLoveRingMatch,LoverDay2012};
	tbOpt[#tbOpt + 1] = {"Để ta suy nghĩ thêm"};
	Dialog:Say(szMsg,tbOpt);
end



----花坛，采花的
local tbRoseBase = Npc:GetClass("loverday_npc_rosebase");

function tbRoseBase:OnDialog()
	if LoverDay2012:IsEventOpen() ~= 1 then
		return 0;
	end
	local nRet ,szError = self:CheckCanGet();
	if nRet ~= 1 then
		Dialog:Say(szError);
		return 0;
	end
	GeneralProcess:StartProcess("羞答答的玫瑰悄悄开...", 2 * Env.GAME_FPS,{self.GetRose,self,him.nTemplateId},nil,tbEvent);
end

function tbRoseBase:CheckCanGet()
	if me.CountFreeBagCell() < 1 then
		return 0,"需要<color=green>1格<color>背包空间，整理下再来！";
	end
	return 1;
end

function tbRoseBase:GetRose(nTemplateId)
	local nRet ,szError = self:CheckCanGet();
	if nRet ~= 1 then
		Dialog:Say(szError);
		return 0;
	end
	if not nTemplateId then
		return 0;
	end
	local tbGdpl = LoverDay2012.tbRoseBaseMatchRose[nTemplateId];
	if not tbGdpl then
		return 0;
	end
	me.AddItem(unpack(tbGdpl));
	return 1;
end


----活动的花坛
local tbFlowerBase = Npc:GetClass("loverday_npc_flowerbase");

function tbFlowerBase:OnDialog()
	local nRet ,szError = self:CheckCanDoTask(him.dwId);
	if nRet ~= 1 then
		Dialog:Say(szError);
		return 0;
	end
	local szMsg = "    浪漫情人节，花香飘四方。携一束浪漫的玫瑰，表一片诚挚的真心。<color=yellow>情人陪伴享时光，朋友相伴一起玩，情人节快乐！<color> ";
	local tbOpt = {};
	tbOpt[#tbOpt + 1] = {"查看采集玫瑰任务",self.ViewMateTask,self,him.dwId};
	tbOpt[#tbOpt + 1] = {"<color=yellow>上交玫瑰点缀花坛<color>",self.GiveRose,self,him.dwId};
	tbOpt[#tbOpt + 1] = {"Để ta suy nghĩ thêm"};
	Dialog:Say(szMsg,tbOpt);
end

function tbFlowerBase:ViewMateTask(nNpcId)
	local nRet ,szError = self:CheckCanDoTask(nNpcId);
	if nRet ~= 1 then
		Dialog:Say(szError);
		return 0;
	end
	local pNpc = KNpc.GetById(nNpcId);
	local tbTaskInfo = pNpc.GetTempTable("SpecialEvent").tbTaskInfo;
	local nCurStep = pNpc.GetTempTable("SpecialEvent").nCurrentTaskStep;
	local tbGdpl = nil;
	local szMateName = "";
	local nCount = 0;
	local nHasGiveCount = 0;
	for szName,tbInfo in pairs(tbTaskInfo) do
		if szName ~= me.szName then
			local tbCurTask = tbInfo[nCurStep];
			tbGdpl = tbCurTask[1];
			nCount = tbCurTask[2];
			nHasGiveCount = tbCurTask[3];
			szMateName = szName;
		end		
	end
	if not tbGdpl then
		return 0;
	end
	local szMsg = string.format("当前接取了<color=yellow>第%s步<color>采集玫瑰花任务，请你的队友<color=yellow>%s<color>采摘<color=yellow>%s朵%s<color>上交点缀花坛，已经上交过<color=yellow>%s<color>朵！",nCurStep,szMateName,nCount,KItem.GetNameById(unpack(tbGdpl)),nHasGiveCount);
	Dialog:Say(szMsg);
end


function tbFlowerBase:GiveRose(nNpcId)
	local nRet ,szError = self:CheckCanDoTask(nNpcId);
	if nRet ~= 1 then
		Dialog:Say(szError);
		return 0;
	end
	local pNpc = KNpc.GetById(nNpcId);
	local tbTaskInfo = pNpc.GetTempTable("SpecialEvent").tbTaskInfo[me.szName];
	local nCurStep = pNpc.GetTempTable("SpecialEvent").nCurrentTaskStep or 1;
	if tbTaskInfo[nCurStep][4] == 1 then
		local szMsg = string.format("当前接取了<color=yellow>第%s步<color>采集玫瑰花任务，已经上交<color=yellow>%s朵<color>点缀过花坛了。",nCurStep,tbTaskInfo[nCurStep][3]);
		Dialog:Say(szMsg);
		return 0;
	else
		local szMsg = string.format("请与你的队友交谈，了解采集玫瑰花的任务信息。");
		Dialog:OpenGift(szMsg, nil, {self.OnInputRose,self,nNpcId});
		return 1;
	end
end


function tbFlowerBase:OnInputRose(nNpcId,tbItemObj,bSure)
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		return 0;
	end
	local nRet ,szError = self:CheckCanDoTask(nNpcId);
	if nRet ~= 1 then
		Dialog:Say(szError);
		return 0;
	end
	local tbTaskInfo = pNpc.GetTempTable("SpecialEvent").tbTaskInfo[me.szName];
	local nCurStep = pNpc.GetTempTable("SpecialEvent").nCurrentTaskStep or 1;
	local tbCurTask = tbTaskInfo[nCurStep];
	local tbGdpl = tbCurTask[1];
	local nNeedCount = tbCurTask[2];
	local nHasGive = tbCurTask[3];
	local nCount = 0;
	for _,pItem in pairs(tbItemObj) do
		if pItem[1] and self:CheckCanDel(pItem[1].SzGDPL(),tbGdpl) == 1 then	--防止放入其它东西
			nCount = nCount + 1;
			if nCount >= nNeedCount - nHasGive then
				break;
			end
		end
	end
	if not bSure and nCount > 0 then
		local szMsg = string.format("确定要将<color=yellow>%s朵<color>用来点缀花坛么？",KItem.GetNameById(unpack(tbGdpl)));
		local tbOpt = {};
		tbOpt[#tbOpt + 1] = {"<color=yellow>确定，点缀漂亮花坛<color>",self.OnInputRose,self,nNpcId,tbItemObj,1};
		tbOpt[#tbOpt + 1] = {"我在想想",self.OnInputRose,self,nNpcId,tbItemObj,0};
		Dialog:Say(szMsg,tbOpt);
	elseif not bSure and nCount <= 0 then
		Dialog:SendBlackBoardMsg(me,"请用当前步骤所需的玫瑰花来进行点缀！");
	end
	if bSure and bSure == 1 then
		local nDelCount = 0;
		for _,pItem in pairs(tbItemObj) do
			if pItem[1] and self:CheckCanDel(pItem[1].SzGDPL(),tbGdpl) == 1 then
				if me.DelItem(pItem[1],Player.emKLOSEITEM_USE) == 1 then
					nDelCount = nDelCount + 1;
					if nDelCount >= nNeedCount - nHasGive then
						break;
					end
				end
			end
		end
		self:ProcessGiveRose(nNpcId,nDelCount);
	elseif bSure and bSure == 0 then
		return 0;
	end
end

function tbFlowerBase:ProcessGiveRose(nNpcId,nDelCount)
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		return 0;
	end
	local nRet ,szError = self:CheckCanDoTask(nNpcId);
	if nRet ~= 1 then
		Dialog:Say(szError);
		return 0;
	end
	local tbTaskInfo = pNpc.GetTempTable("SpecialEvent").tbTaskInfo[me.szName];
	local nCurStep = pNpc.GetTempTable("SpecialEvent").nCurrentTaskStep;
	local tbCurTask = tbTaskInfo[nCurStep];
	local nNeedCount = tbCurTask[2];
	tbCurTask[3] = tbCurTask[3] + nDelCount;
	if tbCurTask[3] >= nNeedCount then
		tbCurTask[4] = 1;
	end
	self:ProcessCurStep(nNpcId);	--处理当前步骤
end


function tbFlowerBase:ProcessCurStep(nNpcId)
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		return 0;
	end
	local nRet ,szError = self:CheckCanDoTask(nNpcId);
	if nRet ~= 1 then
		Dialog:Say(szError);
		return 0;
	end
	local tbTaskInfo = pNpc.GetTempTable("SpecialEvent").tbTaskInfo;
	local nCurStep = pNpc.GetTempTable("SpecialEvent").nCurrentTaskStep;
	local nIsCurStepFinish = 1;
	for _,tbInfo in pairs(tbTaskInfo) do
		local tb = tbInfo[nCurStep];
		if tb[4] ~= 1 then
			nIsCurStepFinish = 0;
			break;
		end		
	end
	if nIsCurStepFinish == 1 then
		pNpc.GetTempTable("SpecialEvent").nCurrentTaskStep = pNpc.GetTempTable("SpecialEvent").nCurrentTaskStep + 1;
		local tbMember = me.GetTeamMemberList();
		local tbName = {};
		for _,pPlayer in pairs(tbMember) do
			if pPlayer then
				table.insert(tbName,pPlayer.szName);
				Dialog:SendBlackBoardMsg(pPlayer,"当前采摘玫瑰任务完成，继续采摘让花坛更漂亮！");
			end
		end
		StatLog:WriteStatLog("stat_info","valentine_2012","rose_task_end",0,tbName[1] or "",tbName[2] or "",nCurStep);
	end
	if self:IsAllStepFinish(nNpcId) == 1 then
		pNpc.Delete();
		local nMapId,nX,nY = me.GetWorldPos();
		local pFlower = KNpc.Add2(LoverDay2012.nFlowerFinishNpcTemplateId,1,-1,nMapId,nX,nY);		
		if pFlower then
			pFlower.SetLiveTime(LoverDay2012.nFlowerBaseLiveTime);	--设置生存时间
			pFlower.GetTempTable("SpecialEvent").tbBelong   = {};
			local tbMember = me.GetTeamMemberList();
			local tbName = {};
			for _,pPlayer in pairs(tbMember) do
				if pPlayer then
					table.insert(pFlower.GetTempTable("SpecialEvent").tbBelong,pPlayer.szName);	--记录所属者
					table.insert(tbName,pPlayer.szName);
					Dialog:SendBlackBoardMsg(pPlayer,"恭喜，花坛开满了五颜六色的玫瑰！");
					local szFMsg = string.format("Hảo hữu [<color=yellow>%s<color>]和队友完成了玫瑰情缘任务，五颜六色的玫瑰芳香四溢，获得了爱神最真挚的祝福！",pPlayer.szName);
					local szKMsg = string.format("和队友完成了玫瑰情缘任务，五颜六色的玫瑰芳香四溢，获得了爱神最真挚的祝福！");
					Player:SendMsgToKinOrTong(pPlayer,szKMsg,0);
					pPlayer.SendMsgToFriend(szFMsg);		
				end
			end
			pFlower.szName = "";
			pFlower.SetTitle(string.format("<color=yellow>%s<color>和<color=yellow>%s<color>的玫瑰花",tbName[1],tbName[2]));
			pFlower.Sync();
		else
			Dbg:WriteLog("SpecialEvent","LoverDay2012,Add Flower Finish Failed!",me.nId,me.szName);
		end
	end
end

--是否是要删除的东西
function tbFlowerBase:CheckCanDel(szGDPL,tbNeedGdpl)
	if not szGDPL or #szGDPL == 0 then
		return 0;
	end
	local bCanDel = 0;
	local tbNeed = tbNeedGdpl;
	if szGDPL == string.format("%s,%s,%s,%s",tbNeed[1],tbNeed[2],tbNeed[3],tbNeed[4]) then
		bCanDel = 1;
	end
	return bCanDel;
end


function tbFlowerBase:CheckIsBelong(nNpcId,szName)
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		return 0;
	end
	local tbBelong = pNpc.GetTempTable("SpecialEvent").tbBelong or {};
	local nIsBelong = 0;
	for _,szRec in pairs(tbBelong) do
		if szRec == szName then
			nIsBelong = 1;
			break;
		end
	end
	return nIsBelong;
end

function tbFlowerBase:CheckCanDoTask(nNpcId)
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		return 0,"NPC错误！";
	end
	if LoverDay2012:IsEventOpen() ~= 1 then
		return 0,"该活动已经结束！";
	end	
	if self:CheckIsBelong(nNpcId,me.szName) ~= 1 then
		return 0,"这个花坛不属于你，请找到队伍专属的花坛并用玫瑰点缀。";
	end
	local nTeamId = me.nTeamId;
	if nTeamId <= 0 then
		return 0,"爱神说情人节不可以一个人，需要甜蜜拍档<color=yellow>组队<color>才有爱的祝福！";
	end
	local tbMemberId,nCount = KTeam.GetTeamMemberList(nTeamId);
	if nCount <= 1 or nCount > 2 then
		return 0,"好事成双，<color=yellow>必须两人队伍噢。<color>";
	end
	local nIsNearby = 1;
	for _, nMemberId in pairs(tbMemberId) do
		local pMember = KPlayer.GetPlayerObjById(nMemberId);
		if not pMember then
			nIsNearby = 0;
		end
	end
	if nIsNearby == 0 then
		return 0,"<color=yellow>你的队友离你太远了<color>，靠近一点，在靠近一点！";
	end
	local nIsBelong = 1;	--是否属于这个队伍
	local tbMember = me.GetTeamMemberList();
	for _,pPlayer in pairs(tbMember) do
		if pPlayer then
			if self:CheckIsBelong(nNpcId,pPlayer.szName) ~= 1 then
				nIsBelong = 0;
			end
		end
	end
	if nIsBelong ~= 1 then
		return 0,"这个不是你们的专属花坛！";
	end
	return 1;
end

--是否都完成了
function tbFlowerBase:IsAllStepFinish(nNpcId)
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		return 0;
	end
	local tbTaskInfo = pNpc.GetTempTable("SpecialEvent").tbTaskInfo;
	local nIsAllFinish = 1;
	for _,tbInfo in pairs(tbTaskInfo) do
		for _,tb in pairs(tbInfo) do
			if tb[4] ~= 1 then
				nIsAllFinish = 0;
				break;
			end			
		end
	end
	return nIsAllFinish;
end



---任务完成后的花坛
local tbFlowerFinish = Npc:GetClass("loverday_npc_flowerbase_finish");

function tbFlowerFinish:OnDialog()
	local nRet ,szError = self:CheckCanGetPrize(him.dwId);
	if nRet ~= 1 then
		Dialog:Say(szError);
		return 0;
	end
	local szMsg = "    浪漫情人节，花香飘四方。携一束浪漫的玫瑰，表一片诚挚的真心，<color=yellow>情人陪伴享时光，朋友相伴一起玩，情人节快乐！<color>  ";
	local tbOpt = {};
	tbOpt[#tbOpt + 1] = {"领取<color=pink>玫瑰情缘奖励<color>",self.GetPrize,self,him.dwId};
	tbOpt[#tbOpt + 1] = {"Để ta suy nghĩ thêm"};
	Dialog:Say(szMsg,tbOpt);
end


function tbFlowerFinish:CheckCanGetPrize(nNpcId)
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		return 0,"NPC错误！";
	end
	if LoverDay2012:IsEventOpen() ~= 1 then
		return 0,"该活动已经结束！";
	end	
	if self:CheckIsBelong(nNpcId,me.szName) ~= 1 then
		return 0,"这个不是你们的专属花坛！";
	end
	if me.GetTask(LoverDay2012.nTaskGroupId,LoverDay2012.nHasGetRoseLovePrizeTaskId) ~= 0 then
		return 0,"你今天已经领取过奖励了！";
	end
	if me.CountFreeBagCell() < 2 then
		return 0,"请保证预留出<color=green>2<color>格背包空间！";	
	end
	return 1;
end

function tbFlowerFinish:GetPrize(nNpcId)
	local nRet ,szError = self:CheckCanGetPrize(him.dwId);
	if nRet ~= 1 then
		Dialog:Say(szError);
		return 0;
	end
	local pNpc = KNpc.GetById(nNpcId);
	local tbBelong = pNpc.GetTempTable("SpecialEvent").tbBelong or {};
	local tbGdpl = LoverDay2012.tbRoseLovePrize;
	local nCount = LoverDay2012.nRoseLovePrizeCountNormal
	if (KPlayer.CheckRelation(tbBelong[1] or "", tbBelong[2] or "", Player.emKPLAYERRELATION_TYPE_COUPLE) == 1) then	--侠侣给的奖励
		nCount = LoverDay2012.nRoseLovePrizeCountCouple;
	end
	local nGiveCount = me.AddStackItem(tbGdpl[1],tbGdpl[2],tbGdpl[3],tbGdpl[4],nil,nCount);
	if nGiveCount ~= nCount then
		Dbg:WriteLog("SpecialEvent","LoverDay2012,Add Flower Finish Prize Failed!",me.nId,me.szName,nGiveCount,nCount);	
	else
		me.SetTask(LoverDay2012.nTaskGroupId,LoverDay2012.nHasGetRoseLovePrizeTaskId,1);	--标记今天已经领取过奖励了
		Dialog:SendBlackBoardMsg(me,"恭喜你，获得玫瑰情缘爱的祝福！");
	end
	me.AddItem(unpack(LoverDay2012.tbYanhuaGdpl[MathRandom(#LoverDay2012.tbYanhuaGdpl)]));	--给烟花
	StatLog:WriteStatLog("stat_info","valentine_2012","rose_task_award",me.nId,1);
end

function tbFlowerFinish:CheckIsBelong(nNpcId,szName)
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		return 0;
	end
	local tbBelong = pNpc.GetTempTable("SpecialEvent").tbBelong or {};
	local nIsBelong = 0;
	for _,szRec in pairs(tbBelong) do
		if szRec == szName then
			nIsBelong = 1;
			break;
		end
	end
	return nIsBelong;
end