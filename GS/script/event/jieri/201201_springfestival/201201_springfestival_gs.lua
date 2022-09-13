-- 文件名　：201201_springfestival_gs.lua
-- 创建者　：zhangjunjie
-- 创建时间：2011-12-26 09:25:36
-- 描述：2012春节活动

if  not MODULE_GAMESERVER then
	return;
end

Require("\\script\\event\\jieri\\201201_springfestival\\201201_springfestival_def.lua");

SpecialEvent.SpringFestival2012 = SpecialEvent.SpringFestival2012 or {};
local SpringFestival = SpecialEvent.SpringFestival2012;


----------活动npc对话接口
SpringFestival.tbEventFunction = --活动系统对应的函数接口
{
	[1] = "OnGiveBlessCard",--领拜年卡
	[2] = "OnGetYuanxiaoStuff",	--领汤圆材料
	[3] = "OnBuyNewYearKinSeed",	--购买新年种子
	[4] = "OnChangeIngotToLipao",	--元宝配对
	[5] = "OnChangeWordCardPrize",	--字卡换奖励
	[6] = "OnSpringFestivalLottery", --祈愿贺龙年
	[7] = "OpenNewYearShop",	--打开商店
	[8] = "OnDesLanternEvent",	--挂灯笼介绍
};


function SpringFestival:OnEventNpcDialog(nIndex)
	local szFun = self.tbEventFunction[nIndex];
	if szFun and self[szFun] then
		self[szFun](self);
	end
end


---------------拜年活动
function SpringFestival:OnGiveBlessCard()
	local szMsg = "    过年言好事，出口称吉祥，\n    辞旧迎新岁，情谊永相传。\n\n    2012年<color=green>1月15到1月30日<color>期间，玩家每天可从财神处<color=yellow>领取[拜年贴]<color>向队友拜年，对方将会收到礼物。每天<color=yellow>拜满5人<color>后可点击[拜年贴]领取奖励。活动期间每位玩家最多可领取<color=yellow>8张<color>拜年贴。\n    2012年<color=green>1月31日到2月6日<color>期间把你拜年得到的<color=yellow>字卡<color>交予财神可换取奖励，集的字卡越多奖励越丰厚哦！";
	local tbOpt = {};
	tbOpt[#tbOpt + 1] = {"领取拜年帖",self.GiveBlessCard,self};
	tbOpt[#tbOpt + 1] = {"字卡换奖励",self.OnChangeWordCardPrize,self};
	tbOpt[#tbOpt + 1] = {"Để ta suy nghĩ thêm"};
	Dialog:Say(szMsg,tbOpt);
end

function SpringFestival:CheckCanGetBlessCard()
	if self:IsEventStep1Open() ~= 1 then
		return 0,"对不起，现在已经不能领取拜年帖进行拜年了，请看看其他活动吧。";
	end
	if me.nLevel < self.nBlessBaseLevel then
		return 0,string.format(" 对不起，您的等级不足<color=green>%s级<color>，不能参加此活动！",self.nBlessBaseLevel);
	end
	local nTotalGetCardCount = me.GetTask(self.nTaskGroupId,self.nTotalGetBlessCardCountTaskId);
	if nTotalGetCardCount >= self.nCanGetBlessCardMaxCount then
		return 0,string.format("你领取的拜年贴总数已经到达上限，活动期间每人最多可以领取<color=green>%s张<color>拜年帖！",self.nCanGetBlessCardMaxCount);
	end
	local nLastGetCardTime = me.GetTask(self.nTaskGroupId,self.nLastGetBlessCardTimeTaskId);
	if os.date("%Y%m%d",GetTime()) == os.date("%Y%m%d",nLastGetCardTime) then
		return 0,"对不起，每人每天只能领取<color=green>1张<color>拜年帖，请明天再来吧！";
	end
	if me.CountFreeBagCell() < 1 then
		return 0,"需要<color=green>1格<color>背包空间，整理下再来！";
	end
	return 1;
end

function SpringFestival:GiveBlessCard()
	local nRet,szError = self:CheckCanGetBlessCard();
	if nRet ~= 1 then
		Dialog:Say(szError);
		me.Msg(szError);
		return 0;
	end
	local tbGdpl = self.tbBlessCardGdpl;
	local pItem = me.AddItem(unpack(tbGdpl));
	if not pItem then
		Dbg:WriteLog("SpecialEvent","SpringFestival2011,Give BlessCard Failed!",me.nId,me.szName);
	else
		me.SetTask(self.nTaskGroupId,self.nLastGetBlessCardTimeTaskId,GetTime());
		local nTotalGetCardCount = me.GetTask(self.nTaskGroupId,self.nTotalGetBlessCardCountTaskId);
		me.SetTask(self.nTaskGroupId,self.nTotalGetBlessCardCountTaskId,nTotalGetCardCount + 1);
		StatLog:WriteStatLog("stat_info","spring_2012","get_card",me.nId,1);
	end
end



--------------新年福袋
function SpringFestival:GiveSpringFestivalPrizeBag(pPlayer)
	if not pPlayer then
		return 0;
	end
	if pPlayer.nLevel < self.nGetExtPrizeBaseLevel then
		return 0;
	end
	Setting:SetGlobalObj(pPlayer);
	self:GiveExtFudai(6);	
	Setting:RestoreGlobalObj();
end


function SpringFestival:GiveExtFudai(nType)
	if not nType then
		return 0;
	end
	if me.nLevel < self.nGetFubiBaseLevel then
		return 0;
	end
	if me.CountFreeBagCell() < 1 then
		return 0;
	end
	local nGiveCount = self.tbExtFudaiCount[nType];
	if nGiveCount <= 0 then
		return 0;
	end
	local tbGdpl = self.tbExtFudaiGdpl;
	local nAddCount = me.AddStackItem(tbGdpl[1],tbGdpl[2],tbGdpl[3],tbGdpl[4],nil,nGiveCount);
	if nAddCount ~= nGiveCount then
		Dbg:WriteLog("SpecialEvent","SpringFestival2011,Give Ext Fudai Failed!",me.nId,me.szName,nAddCount,nCount);
	end
end


function SpringFestival:OnPlayerChangeFubi()
	if self:IsTimeCanChangeFubi() ~= 1 then
		return 0;
	end
	local tbGdpl = self.tbFubiCannotUseGdpl;
	local tbCanUseGdpl =  self.tbFubiCanUseGdpl;
	local tbFind = me.FindItemInAllPosition(unpack(tbGdpl));
	for _,tbItem in pairs(tbFind) do
		if tbItem.pItem then
			local nRet = tbItem.pItem.Regenerate(
				tbCanUseGdpl[1],
				tbCanUseGdpl[2],
				tbCanUseGdpl[3],
				tbCanUseGdpl[4],
				tbItem.pItem.nSeries,
				tbItem.pItem.nEnhTimes,			
				tbItem.pItem.nLucky,
				tbItem.pItem.GetGenInfo(),
				0,
				tbItem.pItem.dwRandSeed,
				0
			);
			if nRet ~= 1 then
				Dbg:WriteLog("SpecialEvent","SpringFestival2011,Change Fubi Failed!",me.nId,me.szName);	
			end
		end
	end
end

--注册福币兑换上线事件
if tonumber(os.date("%Y%m%d",GetTime())) <= SpringFestival.nFubiChangeEndTime then
	PlayerSchemeEvent:RegisterGlobalDailyEvent({SpringFestival.OnPlayerChangeFubi,SpringFestival});
end


----------------领汤圆材料
function SpringFestival:OnGetYuanxiaoStuff()
	if self:IsYuanxiaoOpen() ~= 1 then
		Dialog:Say("该活动还未开启！");
		return 0;
	end
	local szMsg = "    元宵佳节到，星月当空照，人间天上两逍遥，万家齐欢闹。\n\n    2012年<color=green>2月5日到2月7日<color>期间，玩家可在财神处领取汤圆食材，在<color=green>生活技能面板<color>中用加工生活技能将领取的食材加工成[包好的汤圆]，再用制作生活技能加工成[一桌热气腾腾的汤圆宴席]，在各大城镇摆放后召唤亲朋好友前来品尝。\n    品尝汤圆的玩家将会得到奖励，当宴席被5位朋友品尝完毕后，主人也可点击宴席领取丰厚奖励。";
	local tbOpt = {};
	tbOpt[#tbOpt + 1] = {"获得汤圆食材",self.GiveYuanxiaoStuff,self};
	tbOpt[#tbOpt + 1] = {"Để ta suy nghĩ thêm"};
	Dialog:Say(szMsg,tbOpt);
end

function SpringFestival:CheckCanGetYuanxiaoStuff()
	if me.nLevel < self.nGetStuffBaseLevel then
		return 0,string.format("等级未达到<color=green>%s级<color>的玩家无法领取汤圆材料！",self.nGetStuffBaseLevel);
	end
	local nLastGetStuffTime = me.GetTask(self.nTaskGroupId,self.nLastGetYuanxiaoStuffTimeTaskId);
	if os.date("%Y%m%d",GetTime()) == os.date("%Y%m%d",nLastGetStuffTime) then
		return 0,"你今天已经领取过一次汤圆材料，不能再领取了！";
	end
	if me.CountFreeBagCell() < self.nGetStuffNeedCell then
		return 0,string.format("需要<color=green>%s格<color>背包空间，整理下再来！",self.nGetStuffNeedCell);
	end
	return 1;
end

function SpringFestival:GiveYuanxiaoStuff()
	local nRet,szError = self:CheckCanGetYuanxiaoStuff();
	if nRet ~= 1 then
		Dialog:Say(szError);
		me.Msg(szError);
		return 0;
	end
	local tbInfo = self.tbYuanxiaoStuffInfo;
	for _,tbDet in pairs(tbInfo) do
		local tbGdpl = tbDet[1];
		local nCount = tbDet[2];
		local nGiveCount = me.AddStackItem(tbGdpl[1],tbGdpl[2],tbGdpl[3],tbGdpl[4],nil,nCount);
		if nGiveCount ~= nCount then
			Dbg:WriteLog("SpecialEvent","SpringFestival2011,Give Yuanxiao Stuff Failed!",me.nId,me.szName,unpack(tbGdpl));	
		end
	end
	me.SetTask(self.nTaskGroupId,self.nLastGetYuanxiaoStuffTimeTaskId,GetTime());	--标记今天已经领过
end

-------------------聚宝盆

function SpringFestival:OnChangeIngotToLipao()
	if SpringFestival:IsEventStep1Open() ~= 1 then
		return 0;
	end
	local szMsg = "    听说财神大仙正在收集各式宝物，如果你能找到你的有缘人，一同将你们的宝物交给财神并完成他的嘱托，相信他一定会重重的答谢你！\n\n    2012年1月15至1月30日的<color=green>12:00-14:00、20:00-22:00<color>期间，财神旁的聚宝盆中会出现各式各样的宝物。与和你有配对宝物的玩家组队后，由队长<color=yellow>领取新春炮竹<color>，放置后二人<color=yellow>同时点燃<color>，即可领取丰厚奖励。";
	local tbOpt = {};
	tbOpt[#tbOpt + 1] = {"领取炮竹",self.SureMatchIngot,self};
	tbOpt[#tbOpt + 1] =	{"Để ta suy nghĩ thêm"};
	Dialog:Say(szMsg,tbOpt);
end

function SpringFestival:SureMatchIngot()
	local nRet,szError = self:CheckCanMatchIngot();
	if nRet ~= 1 then
		Dialog:Say(szError);
		me.Msg(szError);
		return 0;
	end
	self:GiveLipao();
end

function SpringFestival:CheckCanMatchIngot()
	local nTeamId = me.nTeamId;
	if nTeamId <= 0 then
		return 0,"只有<color=green>组队<color>才能进行领取炮竹！";
	end
	local tbMemberId,nCount = KTeam.GetTeamMemberList(nTeamId);
	if nCount ~= self.nMatchIngotNeedMemberCount then
		return 0,string.format("只有<color=green>%s人组队<color>后，才能前来领取炮竹！",self.nMatchIngotNeedMemberCount);
	end
	if me.IsCaptain() ~= 1 then
		return 0,"对不起，炮竹只能由<color=green>队长领取<color>。";
	end
	local nNearby = 0;
	local tbPlayerList = KPlayer.GetAroundPlayerList(me.nId,self.nMatchIngotNeedRange) or {};
	for _, tbRound in pairs(tbPlayerList) do
		for _, nMemberId in pairs(tbMemberId) do
			local pMember = KPlayer.GetPlayerObjById(nMemberId);
			if pMember and pMember.szName == tbRound.szName then
				nNearby = nNearby + 1;
			end
		end
	end
	if nNearby ~= nCount then
		return 0,"对不起，你的队友离你太远了。";
	end
	local tbMember = me.GetTeamMemberList();
	local tbIngotGdp = self.tbIngotGdp;
	local nMyLastGetLevel = me.GetTask(self.nTaskGroupId,self.nLastGetIngotLevelTaskId);
	local tbMyIngot =  me.FindItemInBags(tbIngotGdp[1],tbIngotGdp[2],tbIngotGdp[3],nMyLastGetLevel);
	local tbTeammateIngot = {};	
	for _,pPlayer in pairs(tbMember) do
		if pPlayer then
			if pPlayer.nId ~= me.nId then
				local nLastGetLevel = pPlayer.GetTask(self.nTaskGroupId,self.nLastGetIngotLevelTaskId);
				tbTeammateIngot = pPlayer.FindItemInBags(tbIngotGdp[1],tbIngotGdp[2],tbIngotGdp[3],nLastGetLevel);
			end
		end
	end
	if #tbMyIngot <= 0 or #tbTeammateIngot <= 0 then
		return 0,"您的队伍中有成员背包不存在配对所需要的宝物！";
	end
	if self:IsIngotMatch(tbMyIngot[1].pItem.nLevel,tbTeammateIngot[1].pItem.nLevel) ~= 1 then
		return 0,"你和你的队友没有配对的宝物，再找找其他人吧！";
	end
	if me.CountFreeBagCell() < 1 then
		return 0,"请保证留出<color=green>1<color>格背包空间！";	
	end
	return 1;
end

function SpringFestival:IsIngotMatch(nLevel1,nLevel2)
	if not nLevel1 or not nLevel2 then
		return 0;
	end
	local nIsMatch = 0;
	for nL1,nL2 in pairs(self.tbMatchLevel) do
		if nL1 == nLevel1 and nL2 == nLevel2 then
			nIsMatch = 1;
			break;
		end
	end
	return nIsMatch;
end

function SpringFestival:GiveLipao()
	local tbMember = me.GetTeamMemberList();
	local tbIngotGdp = self.tbIngotGdp;
	local tbLipaoGdpl = self.tbLipaoGdpl;
	local nIsAllDelOk = 1;
	for _,pPlayer in pairs(tbMember) do
		if pPlayer then
			local nLastGetLevel = pPlayer.GetTask(self.nTaskGroupId,self.nLastGetIngotLevelTaskId);
			local tbIngot = pPlayer.FindItemInBags(tbIngotGdp[1],tbIngotGdp[2],tbIngotGdp[3],nLastGetLevel);
			if #tbIngot > 0 then
				if pPlayer.DelItem(tbIngot[1].pItem,Player.emKLOSEITEM_USE) ~= 1 then
					nIsAllDelOk = 0;
					Dbg:WriteLog("SpecialEvent","SpringFestival2011,Delete Ingot Failed!",pPlayer.nId,pPlayer.szName);	
				end
			end
		end
	end
	if nIsAllDelOk == 1 then
		local pItem = me.AddItem(unpack(tbLipaoGdpl));
		if pItem then
			local szBelong = "";
			szBelong = szBelong .. tbMember[1].szName .. "\n" .. tbMember[2].szName;	--记录这个道具属于哪两个玩家的
			pItem.SetTaskBuff(2,1,szBelong);
			StatLog:WriteStatLog("stat_info","spring_2012","treasures",0,tbMember[1].szName,tbMember[2].szName);
		else
			Dbg:WriteLog("SpecialEvent","SpringFestival2011,Give LiPao Failed!",me.nId,me.szName);	
		end
	end
end


-----------------字卡换奖励
function SpringFestival:OnChangeWordCardPrize()
	local nRet ,szError = self:CheckCanChangeWordCardPrize();
	if nRet ~= 1 then
		Dialog:Say(szError,{"Ta hiểu rồi"});
		me.Msg(szError);
		return 0;
	end
	local nValue = me.GetTask(self.nTaskGroupId,self.nGiveWordCardTaskId);
	local tbInfo = {};
	for _,tbGdpl in pairs(self.tbWordCardGdpl) do
		local nLevel = tbGdpl[4];	
		local nBegin,nEnd = nLevel * 3 - 2,nLevel * 3;
		local nIsLevelHasGet = Lib:LoadBits(nValue,nBegin,nEnd);
		if nIsLevelHasGet == nLevel then
			table.insert(tbInfo,string.format("<color=green>%s<color>:<color=green>1/1<color>",KItem.GetNameById(unpack(tbGdpl))));
		else
			table.insert(tbInfo,string.format("<color=green>%s<color>:<color=gray>0/1<color>",KItem.GetNameById(unpack(tbGdpl))));
		end
	end
	local szMsg = "你可以把收集的字卡交给我以换取奖励。以下是你的卡片上交情况：\n";
	for _,tbMsg in pairs(tbInfo) do
		szMsg = szMsg .. tbMsg .. "\n";	
	end
	Dialog:OpenGift(szMsg, nil, {self.OnInputWordCard,self});
end

function SpringFestival:OnInputWordCard(tbItemObj,bSure)
	local nRet ,szError = self:CheckCanChangeWordCardPrize();
	if nRet ~= 1 then
		Dialog:Say(szError,{"Ta hiểu rồi"});
		me.Msg(szError);
		return 0;
	end
	local nValue = me.GetTask(self.nTaskGroupId,self.nGiveWordCardTaskId);
	local nCount = 0;
	local tbCanDelItem = {};
	for _,pItem in pairs(tbItemObj) do
		local nBegin,nEnd = pItem[1].nLevel * 3 - 2,pItem[1].nLevel * 3;
		local nIsLevelHasGet = Lib:LoadBits(nValue,nBegin,nEnd);
		if pItem[1] and 
		nIsLevelHasGet ~= pItem[1].nLevel and 	--是否已经交过，以防万一
		self:CheckWordCardCanDel(pItem[1].SzGDPL()) == 1 and --防止放入其它物品
		not tbCanDelItem[pItem[1].SzGDPL()] then --以防万一，放入重复的字卡
			nCount = nCount + 1;
			tbCanDelItem[pItem[1].SzGDPL()] = 1;
		end
	end
	if not self.tbWordCardPrizeInfo[nCount] then
		return 0;
	end
	local tbGdpl = self.tbWordCardPrizeInfo[nCount][1];
	local nPrizeCount = self.tbWordCardPrizeInfo[nCount][2];
	if not bSure and nCount > 0 then
		if me.CountFreeBagCell() < 1 then
			Dialog:Say("需要<color=green>1格<color>背包空间，整理下再来！");
		end
		local szMsg = string.format("您确定要上交<color=green>%s<color>张字卡么？你可以得到<color=green>%s<color>个%s哦！\n ",nCount,nPrizeCount,KItem.GetNameById(unpack(tbGdpl)));
		local tbOpt = {};
		tbOpt[#tbOpt + 1] = {"确定上交",self.OnInputWordCard,self,tbItemObj,1};
		tbOpt[#tbOpt + 1] = {"我在想想",self.OnInputWordCard,self,tbItemObj,0};
		Dialog:Say(szMsg,tbOpt);
	end
	if bSure and bSure == 1 then
		local nDelCount = 0;
		local tbDelItem = {};
		for _,pItem in pairs(tbItemObj) do
			if pItem[1] and self:CheckWordCardCanDel(pItem[1].SzGDPL()) == 1 and not tbDelItem[pItem[1].SzGDPL()] then
				local nLevel = pItem[1].nLevel;
				local szGdpl = pItem[1].SzGDPL();
				if me.DelItem(pItem[1],Player.emKLOSEITEM_USE) == 1 then
					nDelCount = nDelCount + 1;
					local nValue = me.GetTask(self.nTaskGroupId,self.nGiveWordCardTaskId);
					nValue = Lib:SetBits(nValue,nLevel,nLevel*3 - 2 ,nLevel * 3);
					me.SetTask(self.nTaskGroupId,self.nGiveWordCardTaskId,nValue);
					tbDelItem[szGdpl] = 1;
				end
			end
		end
		self:GiveWordCardPrize(nDelCount);
	elseif bSure and bSure == 0 then
		return 0;
	end
end

function SpringFestival:GiveWordCardPrize(nDelCount)
	if not self.tbWordCardPrizeInfo[nDelCount] then
		return 0;
	end
	local tbGdpl = self.tbWordCardPrizeInfo[nDelCount][1];
	local nPrizeCount = self.tbWordCardPrizeInfo[nDelCount][2];
	local nCurCount = me.AddStackItem(tbGdpl[1],tbGdpl[2],tbGdpl[3],tbGdpl[4],nil,nPrizeCount);
	if nCurCount ~= nPrizeCount then
		Dbg:WriteLog("SpecialEvent","SpringFestival2011,Give WordCard Prize Failed!",me.nId,me.szName);			
	end
end

function SpringFestival:CheckWordCardCanDel(szGDPL)
	if not szGDPL or #szGDPL == 0 then
		return 0;
	end
	local bCanDel = 0;
	local tbNeed = self.tbWordCardGdpl;
	for _,tbGdpl in pairs(tbNeed) do
		if szGDPL == string.format("%s,%s,%s,%s",tbGdpl[1],tbGdpl[2],tbGdpl[3],tbGdpl[4]) then
			bCanDel = 1;
			break;
		end
	end
	return bCanDel;
end

function SpringFestival:CheckCanChangeWordCardPrize()
	if self:IsEventStep2Open() ~= 1 then
		return 0,"现在不是字卡兑换奖励的时间，请于2012年<color=green>1月31日到02月06日<color>期间前来兑换！";
	end
	if me.nLevel < self.nBlessBaseLevel then
		return 0,string.format("等级未达到<color=green>%s级<color>的玩家无法兑换奖励！",self.nBlessBaseLevel);
	end
	return 1;
end


----------------挂灯笼
function SpringFestival:GiveUnFireMatch()
	if self:IsEventStep1Open() ~= 1 then
		return 0;
	end
	if me.nLevel < self.nDropLanternBaseLevel then
		return 0;
	end
	local nLastGetTime = me.GetTask(self.nTaskGroupId,self.nLastGetMatchTimeTaskId);
	if os.date("%Y%m%d",nLastGetTime) ~= os.date("%Y%m%d",GetTime()) then
		me.SetTask(self.nTaskGroupId,self.nLastGetMatchTimeTaskId,GetTime());	--隔天清零
		me.SetTask(self.nTaskGroupId,self.nGetMatchCountTaskId,0);
	end
	if me.CountFreeBagCell() < 1 then
		return 0;
	end
	local nGetCount = me.GetTask(self.nTaskGroupId,self.nGetMatchCountTaskId);
	if nGetCount >= self.nGetMatchMaxCountPerDay then
		return 0;
	end
	local tbGdpl = self.tbMatchGdpl;
	local pItem = me.AddItem(unpack(tbGdpl));
	if pItem then
		me.SetTask(self.nTaskGroupId,self.nGetMatchCountTaskId,nGetCount + 1);
	else
		Dbg:WriteLog("SpecialEvent","SpringFestival2011,Give Match Failed!",me.nId,me.szName);
	end
end


function SpringFestival:AddLantern_GS()
	if self:IsEventOpen() ~= 1 then
		return 0;
	end
	if not self.nIsLanternAdded or self.nIsLanternAdded ~= 1 then
		self:AddLantern();
	end
end

--加灯笼
function SpringFestival:AddLantern()
	if not self.tbLanternPos then
		self:LoadLanternPos();
	end
	for nMapId,tbInfo in pairs(self.tbLanternPos) do
		if IsMapLoaded(nMapId) == 1 then
			for nTemplateId,tbPosInfo in pairs(tbInfo) do
				for _,tbPos in pairs(tbPosInfo) do
					local nX = tbPos[1];
					local nY = tbPos[2];
					local pNpc = KNpc.Add2(nTemplateId,1,-1,nMapId,nX,nY);
					if pNpc then
						pNpc.szName = "";
						pNpc.Sync();
					end
				end
			end
		end
	end
	self.nIsLanternAdded = 1;	--标记已经刷过花灯了
end

function SpringFestival:LoadLanternPos()
	if not self.tbLanternPos then
		self.tbLanternPos = {};
	end
	local tbFile = Lib:LoadTabFile(self.szLanternPosFile);
	if not tbFile then
		Dbg:WriteLog("SpecialEvent","SpringFestival2011,Load Lantern Pos Failed!",self.szLanternPosFile);
		return 0;
	end
	for _,tbInfo in ipairs(tbFile) do
		local nMapId = tonumber(tbInfo.MapId);
		local nTemplateId = tonumber(tbInfo.TemplateId);
		if not self.tbLanternPos[nMapId] then
			self.tbLanternPos[nMapId] = {};
		end
		if not self.tbLanternPos[nMapId][nTemplateId] then
			self.tbLanternPos[nMapId][nTemplateId] = {};
		end
		local tbTemp = {tonumber(tbInfo.PosX)/32,tonumber(tbInfo.PosY)/32};
		table.insert(self.tbLanternPos[nMapId][nTemplateId],tbTemp);
	end	
end
	
	
--服务器启动事件
function SpringFestival:OnServerStart()
	if self:IsEventOpen() ~= 1 then
		return 0;
	end
	self:AddLantern();	--加灯笼
end

--注册启动回调
if tonumber(os.date("%Y%m%d",GetTime())) <= SpringFestival.nStep2EndTime then 
	ServerEvent:RegisterServerStartFunc(SpringFestival.OnServerStart,SpringFestival);
end



------------新年种子
function SpringFestival:OnBuyNewYearKinSeed()
	Dialog:Say("    2012年<color=green>1月15到2月6日<color>期间，玩家可在吕丰年处购买新春特殊种子<color=green>[红包树种]<color>进行种植。\n    特殊种子成熟后的收益不仅比普通种子的高，在收成的时候还会有额外奖励哦！");
end


------------龙年祈愿
function SpringFestival:OnSpringFestivalLottery()
	if self:IsHopeOpen() == 1 then
		local szMsg = "    昨天一夜之间，在临安和汴京的广场上都长出了一颗奇特的神树，据说它能让你得到幸运之神的眷顾。如果你能帮它找到它想要的[祈愿卡]，我想它一定会很感激的。\n    2012年<color=green>1月15到1月30日<color>期间，玩家可在财神处获得[祈愿卡]，交予临安、汴京广场中央的祈愿树。祈愿树将返还<color=yellow>超额奖励和4张幸运奖券<color>。\n    在对应日期使用奖券后即可获得当天的抽奖资格。\n    本次抽奖的<color=yellow>中奖率可是100%哦<color>！";
		local tbOpt = {};
		tbOpt[#tbOpt + 1] = {"获得祈愿卡",self.BuyHopeCard,self};
		tbOpt[#tbOpt + 1] = {"Để ta suy nghĩ thêm"};
		Dialog:Say(szMsg,tbOpt);
	elseif self:IsLotteryOpen() == 1 then
		self:LotteryDialog();
	else
		return 0;
	end
end

function SpringFestival:BuyHopeCard()
	local szMsg = "2012年<color=green>1月15日到1月30日<color>期间，每位侠士可在我这里购买最多<color=green>4<color>张祈愿卡，你想做什么？";
	local tbOpt = {};
	local nOpenDay = TimeFrame:GetServerOpenDay();
	tbOpt[#tbOpt + 1]  = {string.format("花费<color=green>%s<color>金币购买1张祈愿卡",self.nHopeCardCost),self.BuyHopeCardByCoin,self};
	if nOpenDay >= 96 then
		szMsg = "2012年<color=green>1月15日到1月30日<color>期间，每位侠士可在我这里购买或兑换最多<color=green>4<color>张祈愿卡，你想做什么？";
		tbOpt[#tbOpt + 1] = {"使用1个月影之石兑换1张祈愿卡",self.ChangeHopeCardByMoonStone,self};
	end
	tbOpt[#tbOpt + 1] = {"Để ta suy nghĩ thêm"};
	Dialog:Say(szMsg,tbOpt);
end

function SpringFestival:BuyHopeCardByCoin()
	local nRet ,szError = self:CheckCanBuyHopeCard();
	if nRet ~= 1 then
		Dialog:Say(szError,{"Ta hiểu rồi"});
		me.Msg(szError);
		return 0;
	end
	local szMsg = string.format("每人最多可拥有<color=green>%s<color>张祈愿卡，确定要以<color=yellow>%s<color>金币购买么?",self.nMaxBuyHopeCardCount,self.nHopeCardCost);
	local tbOpt = {};
	tbOpt[#tbOpt + 1] = {"Xác nhận mua hàng",self.SureBuyHopeCard,self};
	tbOpt[#tbOpt + 1] = {"Để ta suy nghĩ thêm"};
	Dialog:Say(szMsg,tbOpt);
end


function SpringFestival:SureBuyHopeCard()
	local nRet ,szError = self:CheckCanBuyHopeCard();
	if nRet ~= 1 then
		Dialog:Say(szError,{"Ta hiểu rồi"});
		me.Msg(szError);
		return 0;
	end
	local bRet = me.ApplyAutoBuyAndUse(self.nHopeCardWareId,1,1);
	if (bRet == 1) then
		StatLog:WriteStatLog("stat_info","spring_2012","get_ticket",me.nId,1);
		local szMsg = "Giao dịch thành công.";
		local tbOpt = {};
		tbOpt[#tbOpt + 1] = {"继续购买",self.BuyHopeCardByCoin,self}
		tbOpt[#tbOpt + 1] = {"Để ta suy nghĩ thêm",}
		Dialog:Say(szMsg,tbOpt);
		return 1;
	else
		Dialog:Say("Giao dịch thất bại.");
		Dbg:WriteLog("New Server Event","Buy Call Boss Item Failed",me.szName);
		return 0;
	end
end

function SpringFestival:ChangeHopeCardByMoonStone()
	local nRet ,szError = self:CheckCanChangeHopeCard();
	if nRet ~= 1 then
		Dialog:Say(szError,{"Ta hiểu rồi"});
		me.Msg(szError);
		return 0;
	end
	local szMsg = string.format("每位侠士最多可拥有<color=green>%s<color>张祈愿卡，确定要以<color=yellow>%s个%s<color>进行兑换么?",self.nMaxBuyHopeCardCount,self.nNeedMoonStoneCount,KItem.GetNameById(unpack(self.tbMoonStoneGdpl)));
	local tbOpt = {};
	tbOpt[#tbOpt + 1] = {"确定兑换",self.SureChangeHopeCard,self};
	tbOpt[#tbOpt + 1] = {"Để ta suy nghĩ thêm"};
	Dialog:Say(szMsg,tbOpt);
end

function SpringFestival:SureChangeHopeCard()
	local nRet ,szError = self:CheckCanChangeHopeCard();
	if nRet ~= 1 then
		Dialog:Say(szError,{"Ta hiểu rồi"});
		me.Msg(szError);
		return 0;
	end
	local nConsumeMoonCount = me.ConsumeItemInBags(self.nNeedMoonStoneCount,unpack(self.tbMoonStoneGdpl));
	if nConsumeMoonCount == 0 then
		local pItem = me.AddItem(unpack(self.tbHopeCardGdpl));
		if not pItem then
			Dbg:WriteLog("SpecialEvent","SpringFestival2011,Add HopeCard Failed!",me.nId,me.szName);
			return 0;
		else
			local nGetCount = me.GetTask(SpringFestival.nTaskGroupId,SpringFestival.nBuyHopeCardTotalTaskId);
			me.SetTask(SpringFestival.nTaskGroupId,SpringFestival.nBuyHopeCardTotalTaskId,nGetCount + 1);
			StatLog:WriteStatLog("stat_info","spring_2012","get_ticket",me.nId,2);
			local szMsg = "兑换成功。";
			local tbOpt = {};
			tbOpt[#tbOpt + 1] = {"继续兑换",self.ChangeHopeCardByMoonStone,self}
			tbOpt[#tbOpt + 1] = {"Để ta suy nghĩ thêm",}
			Dialog:Say(szMsg,tbOpt);
			return 1;
		end
	else
		Dbg:WriteLog("SpecialEvent","SpringFestival2011,Delete MoonStone Failed!",me.nId,me.szName);
		return 0;
	end
end

function SpringFestival:CheckCanBuyHopeCard()
	if self:IsHopeOpen() ~= 1 then
		return 0,"现在不是购买祈愿卡的时间！";
	end
	if me.nLevel < self.nHopeBaseLevel then
		return 0,string.format("等级未达到<color=green>%s级<color>的玩家无法购买祈愿卡！",self.nHopeBaseLevel);
	end
	if me.IsAccountLock() ~= 0 then
		return 0,"Tài khoản đang bị khóa, không thể thao tác!";
	end
	local nGetCount = me.GetTask(self.nTaskGroupId,self.nBuyHopeCardTotalTaskId);
	if nGetCount >= self.nMaxBuyHopeCardCount then
		return 0,string.format("你已经拥有<color=green>%s<color>张祈愿卡了，活动期间每人最多可拥有<color=green>%s<color>张祈愿卡！",nGetCount,self.nMaxBuyHopeCardCount);
	end
	if me.nCoin < self.nHopeCardCost then
		return 0,string.format("您的金币不足<color=green>%s<color>，无法购买祈愿卡。",self.nHopeCardCost);		
	end
	if me.CountFreeBagCell() < 1 then
		return 0,"需要<color=green>1格<color>背包空间，整理下再来！";
	end
	return 1;
end

function SpringFestival:CheckCanChangeHopeCard()
	if self:IsHopeOpen() ~= 1 then
		return 0,"现在不是兑换祈愿卡的时间！";
	end
	if me.nLevel < self.nHopeBaseLevel then
		return 0,string.format("等级未达到%s级的玩家无法兑换祈愿卡！",self.nHopeBaseLevel);
	end
	if me.IsAccountLock() ~= 0 then
		return 0,"Tài khoản đang bị khóa, không thể thao tác!";
	end
	local nGetCount = me.GetTask(self.nTaskGroupId,self.nBuyHopeCardTotalTaskId);
	if nGetCount >= self.nMaxBuyHopeCardCount then
		return 0,string.format("你已经拥有<color=green>%s<color>张祈愿卡了，活动期间每人最多可拥有<color=green>%s<color>张祈愿卡！",nGetCount,self.nMaxBuyHopeCardCount);
	end
	local tbMoonFind = me.FindItemInBags(unpack(self.tbMoonStoneGdpl));
	if #tbMoonFind <= 0 then
		return 0,string.format("你的背包中没有<color=green>%s<color>，无法兑换祈愿卡！",KItem.GetNameById(unpack(self.tbMoonStoneGdpl)));
	end
	if me.CountFreeBagCell() < 1 then
		return 0,"需要<color=green>1格<color>背包空间，整理下再来！";
	end
	return 1;
end

function SpringFestival:LotteryDialog()
	Lottery:OnDialog();
end


function SpringFestival:OpenNewYearShop()
	local szMsg = "    2012年<color=green>1月15日到2月6日<color>期间，玩家可通过参加新春活动及逍遥谷、军营、白虎堂、宋金战场、藏宝图等日常活动积累<color=yellow>获得福币<color>。\n    2012年1月31日的00:00福币商店开启购买。";
	local tbOpt = {};
	tbOpt[#tbOpt + 1] = {"<color=yellow>打开福币商店<color>",self.SureOpenShop,self};
	tbOpt[#tbOpt + 1] =	{"Để ta suy nghĩ thêm"};
	Dialog:Say(szMsg,tbOpt);
end

--打开商店
function SpringFestival:SureOpenShop()
	me.OpenShop(227,3);
end

--花灯活动介绍
function SpringFestival:OnDesLanternEvent()
	local szMsg = "    2012年<color=green>1月15日到1月30日<color>期间，逍遥谷、军营、白虎堂、宋金战场、藏宝图等日常活动可产出道具<color=green>[火折子]<color>，可用<color=green>精活加工<color>成[燃着的火折子]。\n    拥有[燃着的火折子]的玩家可在各大城镇中<color=green>点燃灯笼<color>并获得丰厚奖励。";
	Dialog:Say(szMsg);
end


---------------摸宝世界公告
function SpringFestival:AnnounceIngotMsg()
	self:AnnounceMsg(self.szNotifyMsg);
	self.nAnnounceCount = 1;
	self.nNotifyTimer = Timer:Register(self.nNotifyTime,self.OnNotifyMsg,self);
end

function SpringFestival:OnNotifyMsg()
	self:AnnounceMsg(self.szNotifyMsg);
	self.nAnnounceCount = self.nAnnounceCount + 1;
	if self.nAnnounceCount >= self.nNotifyMaxCount then
		self.nNotifyTimer = 0;
		return 0;
	end
end

function SpringFestival:AnnounceMsg(szMsg)
	if not szMsg or #szMsg <= 0 then
		return 0;
	end
	KDialog.NewsMsg(0,Env.NEWSMSG_NORMAL,szMsg);
	KDialog.Msg2SubWorld(szMsg);
end