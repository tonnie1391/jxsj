-- 文件名　：201202_loverday_item.lua
-- 创建者　：zhangjunjie
-- 创建时间：2012-02-05 15:38:18
-- 描述：item

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


local tbRoseLoveItem = Item:GetClass("roselove_item");

function tbRoseLoveItem:InitGenInfo()
	local nRemainTime = Lib:GetDate2Time(tonumber(os.date("%Y%m%d",GetTime()))) + 24 * 60 * 60;	--到当天晚上24点消失
	it.SetTimeOut(0,nRemainTime);	--绝对时间
	return {};
end

function tbRoseLoveItem:OnUse()
	local nRet ,szError = self:CheckCanUse(it.dwId);
	if nRet ~= 1 then
		Dialog:Say(szError);
		return 0;
	end
	GeneralProcess:StartProcess("放置花坛中...", 5 * Env.GAME_FPS,{self.DropFlowerBase,self,it.dwId},nil,tbEvent);
end

function tbRoseLoveItem:DropFlowerBase(nItemId)
	local nRet ,szError = self:CheckCanUse(nItemId);
	if nRet ~= 1 then
		Dialog:Say(szError);
		return 0;
	end
	local pItem = KItem.GetObjById(nItemId);
	if me.DelItem(pItem,Player.emKLOSEITEM_USE) == 1 then
		local nMapId,nX,nY = me.GetWorldPos();	
		local pBase = KNpc.Add2(LoverDay2012.nFlowerBaseNpcTemplateId,1,-1,nMapId,nX,nY);
		if pBase then
			pBase.SetLiveTime(LoverDay2012.nFlowerBaseLiveTime);	--设置生存时间
			pBase.GetTempTable("SpecialEvent").tbBelong   = {};
			pBase.GetTempTable("SpecialEvent").tbTaskInfo = {};		--初始化任务
			pBase.GetTempTable("SpecialEvent").nCurrentTaskStep = 1;--初始化步骤
			local tbFlower = LoverDay2012.tbTaskNeedFlower;
			local tbCount  = LoverDay2012.tbTaskNeedFlowerCount;
			local tbMember = me.GetTeamMemberList();
			local tbName = {};
			for _,pPlayer in pairs(tbMember) do
				if pPlayer then
					Dialog:SendBlackBoardMsg(pPlayer,"花坛已摆放完成，请查看玫瑰采集任务！");
					table.insert(pBase.GetTempTable("SpecialEvent").tbBelong,pPlayer.szName);	--记录所属者
					table.insert(tbName,pPlayer.szName);
					pBase.GetTempTable("SpecialEvent").tbTaskInfo[pPlayer.szName] = {};	--初始化每个玩家对应的任务
					for i = 1,#tbFlower do
						local tbGdpl = tbFlower[MathRandom(#tbFlower)];
						local nCount = tbCount[MathRandom(#tbCount)];
						local nHasGiveCount = 0;
						local nIsFinish = 0;
						local tbInfo = {tbGdpl,nCount,nHasGiveCount,nIsFinish};
						table.insert(pBase.GetTempTable("SpecialEvent").tbTaskInfo[pPlayer.szName],tbInfo);	
					end
				end
			end
			pBase.szName = "";
			pBase.SetTitle(string.format("<color=yellow>%s<color>和<color=yellow>%s<color>的花坛",tbName[1],tbName[2]));
			pBase.Sync();
		else
			Dbg:WriteLog("SpecialEvent","LoverDay2012,Add FlowerBase Failed!",me.nId,me.szName);	
		end
	else
		Dbg:WriteLog("SpecialEvent","LoverDay2012,Delete RoseLove Item Failed!",me.nId,me.szName);	
	end
end



function tbRoseLoveItem:CheckCanUse(nItemId)
	local pItem = KItem.GetObjById(nItemId);
	if not pItem then
		return 0,"道具使用错误！";
	end
	if LoverDay2012:IsEventOpen() ~= 1 then
		return 0,"该活动已经结束！";
	end
	local szMapClass = GetMapType(me.nMapId) or "";
	if szMapClass ~= "city" then
		return 0,"花坛只能在城市放置。";
	end
	local nTeamId = me.nTeamId;
	if nTeamId <= 0 then
		return 0,"爱神说情人节不可以一个人，需要甜蜜拍档<color=yellow>组队<color>才有爱的祝福！";
	end
	local tbMemberId,nCount = KTeam.GetTeamMemberList(nTeamId);
	if nCount <= 1 or nCount > 2 then
		return 0,"好事成双，<color=yellow>必须两人队伍噢。<color>";
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
	local tbSex,nDiffSex = {},0;
	local szBelong = pItem.GetTaskBuff(2,1) or "";	--获取所属者
	local nIsBelong = 1;	--是否属于这个队伍
	for _,pPlayer in pairs(tbMember) do
		if pPlayer then
			table.insert(tbSex,pPlayer.nSex);
			if not string.find(szBelong,pPlayer.szName,1,1) then
				nIsBelong = 0;
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
	if nIsBelong ~= 1 then
		return 0,"请和与你一同接取任务的侠客摆放花坛，不要变心噢！";
	end
	local tbNpcList = KNpc.GetAroundNpcList(me,LoverDay2012.nDropFlowerRange);
	for _, pNpc in ipairs(tbNpcList) do
		if pNpc.nKind == 3 or pNpc.nTemplateId == LoverDay2012.nFlowerBaseNpcTemplateId then
			return 0,"这里貌似太过拥挤了，还是换一个地方试试吧！";
		end
	end
	return 1;
end


--采摘的玫瑰花
local tbRoseLoveRose = Item:GetClass("roselove_rose");

function tbRoseLoveRose:InitGenInfo()
	local nRemainTime = Lib:GetDate2Time(tonumber(os.date("%Y%m%d",GetTime()))) + 24 * 60 * 60;	--到当天晚上24点消失
	it.SetTimeOut(0,nRemainTime);	--绝对时间
	return {};
end


---戒指
local tbRing = Item:GetClass("loverday_ring");

function tbRing:InitGenInfo()
	local nRemainTime = GetTime() + LoverDay2012.nRingLiveTime;	--4个小时
	it.SetTimeOut(0,nRemainTime);	--绝对时间
	return {};
end


--红烛
local tbHongzhu = Item:GetClass("loverday_hongzhu");

function tbHongzhu:InitGenInfo()
	local nRemainTime = Lib:GetDate2Time(tonumber(os.date("%Y%m%d",GetTime()))) + 24 * 60 * 60;	--到当天晚上24点消失
	it.SetTimeOut(0,nRemainTime);	--绝对时间
	return {};
end

function tbHongzhu:OnUse()
	local nRet ,szError = self:CheckCanUse(it.dwId);
	if nRet ~= 1 then
		Dialog:Say(szError);
		return 0;
	end
	GeneralProcess:StartProcess("点燃蜡烛中...", 5 * Env.GAME_FPS,{self.DropHongzhu,self,it.dwId},nil,tbEvent);
end

function tbHongzhu:DropHongzhu(nItemId)
	local nRet ,szError = self:CheckCanUse(nItemId);
	if nRet ~= 1 then
		Dialog:Say(szError);
		return 0;
	end
	local pItem = KItem.GetObjById(nItemId);
	if me.DelItem(pItem,Player.emKLOSEITEM_USE) == 1 then
		local nMapId,nX,nY = me.GetWorldPos();	
		local pHongzhu = KNpc.Add2(LoverDay2012.nHongzhuNpcTemplateId,1,-1,nMapId,nX,nY);
		if pHongzhu then
			pHongzhu.SetLiveTime(LoverDay2012.nHongzhuLiveTime);	--设置生存时间
			local tbMember = me.GetTeamMemberList();
			local tbName = {};
			for _,pPlayer in pairs(tbMember) do
				if pPlayer then
					table.insert(tbName,pPlayer.szName);
				end
			end
			local tbGdpl = LoverDay2012.tbRingMatchPrize;
			local nCount = LoverDay2012.nRingMatchPrizeCountNormal;
			if (KPlayer.CheckRelation(tbName[1] or "", tbName[2] or "", Player.emKPLAYERRELATION_TYPE_COUPLE) == 1) then	--侠侣给的奖励
				nCount = LoverDay2012.nRoseLovePrizeCountCouple;
			end
			for _,pPlayer in pairs(tbMember) do
				if pPlayer then
					local tbInfo = tbGdpl[pPlayer.nSex];
					local nGiveCount = pPlayer.AddStackItem(tbInfo[1],tbInfo[2],tbInfo[3],tbInfo[4],nil,nCount);
					pPlayer.AddItem(unpack(LoverDay2012.tbYanhuaGdpl[MathRandom(#LoverDay2012.tbYanhuaGdpl)]));
					if nGiveCount ~= nCount then
						Dbg:WriteLog("SpecialEvent","LoverDay2012,Add Ring Match Prize Failed!",me.nId,me.szName,nGiveCount,nCount);
					else
						Dialog:SendBlackBoardMsg(pPlayer,"恭喜你，红烛已点燃，获得了丘比特的祝福！");
						local szFMsg = string.format("丘比特之箭，将Hảo hữu [<color=yellow>%s<color>]和队友甜蜜锁定，情缘红烛绽放爱的花火！",pPlayer.szName);
						local szKMsg = string.format("和队友被丘比特之箭甜蜜锁定，情缘红烛绽放爱的花火！");
						Player:SendMsgToKinOrTong(pPlayer,szKMsg,0);
						pPlayer.SendMsgToFriend(szFMsg);		
					end
				end
			end
			pHongzhu.szName = "";
			pHongzhu.SetTitle(string.format("<color=yellow>%s<color>和<color=yellow>%s<color>的红烛",tbName[1],tbName[2]));
			pHongzhu.Sync();
		else
			Dbg:WriteLog("SpecialEvent","LoverDay2012,Add Hongzhu Npc Failed!",me.nId,me.szName);	
		end
	else
		Dbg:WriteLog("SpecialEvent","LoverDay2012,Delete Hongzhu Item Failed!",me.nId,me.szName);	
	end
end


function tbHongzhu:CheckCanUse(nItemId)
	local pItem = KItem.GetObjById(nItemId);
	if not pItem then
		return 0,"道具使用错误！";
	end
	if LoverDay2012:IsEventOpen() ~= 1 then
		return 0,"该活动已经结束！";
	end
	local szMapClass = GetMapType(me.nMapId) or "";
	if szMapClass ~= "village" and szMapClass ~= "city" then
		return 0,"蜡烛只能在城市、新手村里点燃。";
	end
	local nTeamId = me.nTeamId;
	if nTeamId <= 0 then
		return 0,"爱神说情人节不可以一个人，需要甜蜜拍档<color=yellow>组队<color>才有爱的祝福！";
	end
	local tbMemberId,nCount = KTeam.GetTeamMemberList(nTeamId);
	if nCount <= 1 or nCount > 2 then
		return 0,"好事成双，<color=yellow>必须两人队伍噢。<color>";
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
	local tbSex,nDiffSex = {},0;
	local szBelong = pItem.GetTaskBuff(2,1) or "";	--获取所属者
	local nIsBelong = 1;	--是否属于这个队伍
	local nAllHasFree = 1;	--是否都有空间 
	for _,pPlayer in pairs(tbMember) do
		if pPlayer then
			table.insert(tbSex,pPlayer.nSex);
			if not string.find(szBelong,pPlayer.szName,1,1) then
				nIsBelong = 0;
			end
			if pPlayer.CountFreeBagCell() < 2 then
				nAllHasFree = 0;
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
	if nIsBelong ~= 1 then
		return 0,"请和与你配对的侠客点燃蜡烛，不要变心噢！";
	end
	if nAllHasFree ~= 1 then
		return 0,"请保证队伍中所有成员预留出<color=green>2<color>格背包空间！";	
	end
	local tbNpcList = KNpc.GetAroundNpcList(me,LoverDay2012.nHongzhuNeedRange);
	for _, pNpc in ipairs(tbNpcList) do
		if pNpc.nKind == 3 or pNpc.nTemplateId == LoverDay2012.nHongzhuNpcTemplateId then
			return 0,"这里貌似太过拥挤了，还是换一个地方试试吧！";
		end
	end
	return 1;
end



--祝福卡
local tbCard = Item:GetClass("loverday_card");

function tbCard:InitGenInfo()
	local nRemainTime = Lib:GetDate2Time(LoverDay2012.nGetPrizeEndTime) + 24 * 60 * 60;	--到19晚上24点消失
	it.SetTimeOut(0,nRemainTime);	--绝对时间
	return {};
end

function tbCard:OnUse()
	local szFrom = it.GetTaskBuff(2,1) or "";
	if #szFrom <= 0 then
		return 0;
	end
	local szMsg = string.format("    这是<color=yellow>%s<color>偷偷递给你的真爱誓约，在2月17日0：00-2月19日23：59之间，你必须同<color=yellow>%s<color>组队，点击卡片，领取一份<color=yellow>天长地久<color>的礼物！\n    现在可以向她暗送秋波，不要害羞，赶紧行动吧！",szFrom,szFrom);
	local tbOpt = {};
	tbOpt[#tbOpt + 1] = {string.format("向<color=yellow>%s<color>暗送秋波",szFrom),self.ChatTo,self,szFrom};
	if LoverDay2012:IsTimeCanGetPrize() == 1 then
		tbOpt[#tbOpt + 1] = {"领取奖励",self.GetPrize,self,it.dwId};
	end
	tbOpt[#tbOpt + 1] = {"Để ta suy nghĩ thêm"}
	Dialog:Say(szMsg,tbOpt);
end

function tbCard:ChatTo(szFrom)
	local szMsg = string.format("想要向<color=yellow>%s<color>说些什么呢？",szFrom);
	local tbOpt = {};
	for i = 1,#LoverDay2012.tbChatToFromMsg do
		table.insert(tbOpt,{LoverDay2012.tbChatToFromMsg[i],self.Chat,self,szFrom,LoverDay2012.tbChatToFromMsg[i]});		
	end
	tbOpt[#tbOpt + 1] = {"Để ta suy nghĩ thêm"}
	Dialog:Say(szMsg,tbOpt);
end

function tbCard:Chat(szFrom,szMsg)
	if not szFrom or #szFrom <= 0 then
		return 0;
	end
	KChatChannel.SendPrivateMsg(me.nId,szMsg,szFrom);
end

function tbCard:GetPrize(nItemId)
	local nRet ,szError = self:CheckCanGetPrize(nItemId);
	if nRet ~= 1 then
		Dialog:Say(szError);
		return 0;
	end
	local pItem = KItem.GetObjById(nItemId);
	local szBelong = pItem.GetTaskBuff(2,1) or "";	--获取所属者
	if me.DelItem(pItem,Player.emKLOSEITEM_USE) == 1 then
		local tbMember = me.GetTeamMemberList();
		local tbName = {};
		for _,pPlayer in pairs(tbMember) do
			if pPlayer then
				table.insert(tbName,pPlayer.szName);
			end
		end
		local tbGdpl = LoverDay2012.tbCardPrize;
		local nCount = LoverDay2012.nRingMatchPrizeCountNormal;
		if (KPlayer.CheckRelation(tbName[1] or "", tbName[2] or "", Player.emKPLAYERRELATION_TYPE_COUPLE) == 1) then	--侠侣给的奖励
			nCount = LoverDay2012.nRoseLovePrizeCountCouple;
		end
		StatLog:WriteStatLog("stat_info","valentine_2012","get_card",me.nId,szBelong,1);
		for _,pPlayer in pairs(tbMember) do
			if pPlayer then
				local nGiveCount = pPlayer.AddStackItem(tbGdpl[1],tbGdpl[2],tbGdpl[3],tbGdpl[4],nil,nCount);
				pPlayer.AddItem(unpack(LoverDay2012.tbYanhuaGdpl[MathRandom(#LoverDay2012.tbYanhuaGdpl)]));
				if nGiveCount ~= nCount then
					Dbg:WriteLog("SpecialEvent","LoverDay2012,Add Card Prize Failed!",me.nId,me.szName,nGiveCount,nCount);
				else
					Dialog:SendBlackBoardMsg(pPlayer,"恭喜你，获得了真爱誓约给予你们的祝福！");
				end
			end
		end
	else
		Dbg:WriteLog("SpecialEvent","LoverDay2012,Delete Card Item Failed!",me.nId,me.szName);	
	end
end

function tbCard:CheckCanGetPrize(nItemId)
	local pItem = KItem.GetObjById(nItemId);
	if not pItem then
		return 0,"道具使用错误！";
	end
	if LoverDay2012:IsTimeCanGetPrize() ~= 1 then
		return 0,"领奖的时间已经过了！";
	end
	local nTeamId = me.nTeamId;
	if nTeamId <= 0 then
		return 0,"爱神说情人节不可以一个人，需要甜蜜拍档<color=yellow>组队<color>才有爱的祝福！";
	end
	local tbMemberId,nCount = KTeam.GetTeamMemberList(nTeamId);
	if nCount <= 1 or nCount > 2 then
		return 0,"好事成双，<color=yellow>必须两人队伍噢。<color>";
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
	local szBelong = pItem.GetTaskBuff(2,1) or "";	--获取所属者
	local nIsBelong = 1;	--是否属于这个队伍
	local nAllHasFree = 1;	--是否都有空间 
	for _,pPlayer in pairs(tbMember) do
		if pPlayer then
			if pPlayer.CountFreeBagCell() < 2 then
				nAllHasFree = 0;
			end
			if pPlayer.szName ~= me.szName then
				if not string.find(szBelong,pPlayer.szName,1,1) then
					nIsBelong = 0;
				end
			end
		end
	end
	if nIsBelong ~= 1 then
		return 0,"请与给予你这张誓约的主人一起组队领取奖励！";
	end
	if nAllHasFree ~= 1 then
		return 0,"请保证队伍中所有成员预留出<color=green>2<color>格背包空间！";	
	end
	return 1;
end



----------通用宝箱
local tbCommonBox = Item:GetClass("loverday_box_common");

tbCommonBox.nMaxExtRand = 100000;

tbCommonBox.tbExtPrize = 
{
	--额外开出物品，gdpl，概率，范围
	{{1,26,40,1},  60,14 * 24 * 60 * 60},
	{{1,26,41,1},  60,14 * 24 * 60 * 60},
	{{1,1,101,2}, 89,30 * 24 * 60 * 60},
	{{1,26,38,1}, 119,14 * 24 * 60 * 60},
	{{1,26,39,1}, 119,14 * 24 * 60 * 60},
	{{1,1,101,1},447,30 * 24 * 60 * 60},
	{{1,13,174,10},536,14 * 24 * 60 * 60},
	{{1,13,175,10},536,14 * 24 * 60 * 60},
	{{1,13,172,10}, 536,14 * 24 * 60 * 60},
	{{1,13,173,10}, 536,14 * 24 * 60 * 60},
	{{1,12,60,4}, 715,14 * 24 * 60 * 60},
}

function tbCommonBox:OnUse()
	local nNeedCell = it.GetExtParam(3) or 0;
	if nNeedCell <= 0 then
		nNeedCell = 1;
	end
	if me.CountFreeBagCell() < nNeedCell then
		Dialog:Say(string.format("请保证留出<color=green>%s格<color>背包空间！",nNeedCell));
		return 0;
	end
	return self:OpenBox(it.dwId);
end

function tbCommonBox:OpenBox(nItemId)
	local pItem = KItem.GetObjById(nItemId);
	if not pItem then
		me.Msg("道具使用错误！")
		return 0;
	end
	local nRandIdOld = pItem.GetExtParam(1) or 0;
	local nRandIdNew = pItem.GetExtParam(2) or 0;
	if nRandIdNew <= 0 or nRandIdOld <= 0 then
		me.Msg("道具使用错误！")
		return 0;
	end
	local tbRandomItem = Item:GetClass("randomitem");
	local nOpenDay = TimeFrame:GetServerOpenDay();
	if nOpenDay < 146 then
		tbRandomItem:SureOnUse(nRandIdNew);
	else
		tbRandomItem:SureOnUse(nRandIdOld);
	end
	--额外奖品
	if not IpStatistics:IsStudioRole(me) then
		local nMax   = self.nMaxExtRand;
		local nRand = MathRandom(nMax);
		local nRateT = 0;
		for _,tbInfo in ipairs(self.tbExtPrize) do
			nRateT = nRateT + tbInfo[2];
			if nRand <= nRateT then
				local tbGdpl = tbInfo[1];
				local pExt = me.AddItem(unpack(tbGdpl));
				if pExt then
					StatLog:WriteStatLog("stat_info","valentine_2012","spe_item",me.nId,pExt.szName);
					local nRemainTime = tbInfo[3];
					pExt.SetTimeOut(0,GetTime() + nRemainTime);	--绝对时间
					pExt.Sync();
					local szMsg = string.format("%s打开%s获得一个<color=green>%s<color>,真是可喜可贺呀！",me.szName,pItem.szName,pExt.szName);
					local szFMsg = string.format("Hảo hữu [<color=yellow>%s<color>]打开%s获得一个%s,真是可喜可贺呀！",me.szName,pItem.szName,pExt.szName);
					local szKMsg = string.format("打开%s获得一个%s,真是可喜可贺呀！",pItem.szName,pExt.szName);
					Player:SendMsgToKinOrTong(me,szKMsg,0);
					me.SendMsgToFriend(szFMsg);		
					KDialog.NewsMsg(1,Env.NEWSMSG_NORMAL,szMsg);					
				end
				break;
			end
		end
	end
	return 1;
end



----------玫瑰
local tbRoseIbshop = Item:GetClass("loverrose_ibshop");

tbRoseIbshop.nRange = 15;

tbRoseIbshop.nNpcLiveTime = 20 * 60 * Env.GAME_FPS;

tbRoseIbshop.tbNpcTemplateId = {9927,9928,9929,9930,9931};

tbRoseIbshop.tbTitle = 
{
	{6,93,1,0},	
	{6,94,1,0},
	{6,93,1,0},	
	{6,94,1,0},	
	{6,94,1,0},
}

function tbRoseIbshop:IsNpcExist(nTemplateId)
	local nIsExist = 0;
	for _,nId in pairs(self.tbNpcTemplateId) do
		if nId == nTemplateId then
			nIsExist = 1;
			break;
		end
	end
	return nIsExist;
end

tbRoseIbshop.tbGBMsg =
{
	"<color=green>%s<color>向<color=green>%s<color>送出了<color=pink>999朵红玫瑰<color>，并真情的说：再艳丽的玫瑰也会凋谢，但我对你的宠爱一生一世直到永远心不移！",	
	"<color=green>%s<color>向<color=green>%s<color>送出了<color=pink>9999朵红玫瑰<color>，并真情的说：风雨之中，与你牵手前进；夕阳余晖，和你坐享黄昏；亲爱的，不管风雨我都会保护一辈子！",
	"<color=green>%s<color>向<color=green>%s<color>送出了<color=pink>999朵蓝玫瑰<color>，并真情的说：初识你，是缘分的天意，爱上你，是幸福的开始，拥有你，只愿一生不分离！",
	"<color=green>%s<color>向<color=green>%s<color>送出了<color=pink>9999朵蓝玫瑰<color>，并真情的说：我陪你一起分享着快乐与甜蜜。不管风多大，无论浪多高，我都永远和你在一起，不离不弃。",
	"<color=green>%s<color>向<color=green>%s<color>送出了<color=pink>真爱永恒的花海<color>，并真情的说：最真实的未来，是你的陪伴。最完全的付出，是我的坚守。真的爱你。",
}

function tbRoseIbshop:OnUse()
	local nRet ,szError = self:CheckCanUse(it.dwId);
	if nRet ~= 1 then
		Dialog:Say(szError);
		return 0;
	end
	self:UseRose(it.dwId);
end

function tbRoseIbshop:UseRose(nItemId)
	local tbMember = me.GetTeamMemberList();
	local szMyName = me.szName;
	local szMateName = (tbMember[1].szName ~= me.szName and tbMember[1].szName or tbMember[2].szName);
	local pItem = KItem.GetObjById(nItemId);
	local nIndex = pItem.GetExtParam(1) or 1;
	local szMsg = string.format("爱神已经降临，快去向<color=yellow>%s<color>表白吧！",szMateName);
	local tbOpt = {};
	tbOpt[#tbOpt + 1] = {"发出宣言",self.SendMsg,self,nIndex,nItemId,szMyName,szMateName};
	tbOpt[#tbOpt + 1] = {"Để ta suy nghĩ thêm"};
	Dialog:Say(szMsg,tbOpt);
end

function tbRoseIbshop:SendMsg(nIndex,nItemId,szMyName,szMateName)
	local nRet ,szError = self:CheckCanUse(nItemId);
	if nRet ~= 1 then
		Dialog:Say(szError);
		return 0;
	end
	if not nIndex or not nItemId or not szMyName or not szMateName then
		return 0;
	end
	local pItem = KItem.GetObjById(nItemId);
	if me.DelItem(pItem,Player.emKLOSEITEM_USE) == 1 then
		local szMsg = string.format(self.tbGBMsg[nIndex],szMyName,szMateName);
		KDialog.NewsMsg(1,Env.NEWSMSG_MARRAY,szMsg);
		local nTemplateId = self.tbNpcTemplateId[nIndex];
		if nTemplateId > 0 then
			local nMapId,nX,nY = me.GetWorldPos();
			local pNpc = KNpc.Add2(nTemplateId,1,-1,nMapId,nX,nY);
			if pNpc then
				pNpc.SetLiveTime(self.nNpcLiveTime);
			end
		end
		local tbMember = me.GetTeamMemberList();
		local pMate = (tbMember[1].szName ~= me.szName and tbMember[1] or tbMember[2]);
		if pMate then
			Dialog:SendBlackBoardMsg(pMate,string.format("<color=yellow>%s<color>被你的魅力所倾倒，送出了代表真爱的玫瑰花海！",me.szName));
			pMate.AddTitle(unpack(self.tbTitle[nIndex]));
			pMate.SetCurTitle(unpack(self.tbTitle[nIndex]));
		end
	else
		return 0;
	end 
end

function tbRoseIbshop:CheckCanUse(nItemId)
	local pItem = KItem.GetObjById(nItemId);
	if not pItem then
		return 0,"道具使用错误！";
	end
	local szMapClass = GetMapType(me.nMapId) or "";
	if szMapClass ~= "village" and szMapClass ~= "city" and szMapClass ~= "fight" then
		return 0,"该道具只能在城市、新手村和野外地图使用。";
	end
	local nTeamId = me.nTeamId;
	if nTeamId <= 0 then
		return 0,"爱神说玫瑰要送给心上人，需要甜蜜拍档<color=yellow>组队<color>才可以赠送！";
	end
	local tbMemberId,nCount = KTeam.GetTeamMemberList(nTeamId);
	if nCount <= 1 or nCount > 2 then
		return 0,"<color=yellow>必须两人队伍<color>，你的玫瑰才能赠送噢！";
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
	local tbSex,nDiffSex = {},0;
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
		return 0,"玫瑰只能送给<color=yellow>异性<color>哦！";
	end
	local tbNpcList = KNpc.GetAroundNpcList(me,self.nRange);
	for _, pNpc in ipairs(tbNpcList) do
		if pNpc.nKind == 3 or self:IsNpcExist(pNpc.nTemplateId) == 1 then
			return 0,"这里貌似太过拥挤了，还是换一个地方试试吧！";
		end
	end
	return 1;
end

