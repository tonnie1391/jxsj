-- 文件名　：201201_springfestival_item.lua
-- 创建者　：zhangjunjie
-- 创建时间：2011-12-26 16:29:15
-- 描述：新年活动item

Require("\\script\\event\\jieri\\201201_springfestival\\201201_springfestival_def.lua");

SpecialEvent.SpringFestival2012 = SpecialEvent.SpringFestival2012 or {};
local SpringFestival = SpecialEvent.SpringFestival2012;

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


--拜年卡
local tbBlessCard = Item:GetClass("blesscard_sf2012");

function tbBlessCard:InitGenInfo()
	local nRemainTime = Lib:GetDate2Time(tonumber(os.date("%Y%m%d",GetTime()))) + 24 * 60 * 60;	--到当天晚上24点消失
	it.SetTimeOut(0,nRemainTime);	--绝对时间
	return {};
end

function tbBlessCard:OnUse()
	if me.nLevel < SpringFestival.nBlessBaseLevel then
		return 0,string.format("等级未达到<color=green>%s级<color>的玩家无法进行拜年活动！",SpringFestival.nBlessBaseLevel);
	end
	local nLastBlessTime = me.GetTask(SpringFestival.nTaskGroupId,SpringFestival.nLastBlessToTimeTaskId);
	if os.date("%Y%m%d",GetTime()) ~= os.date("%Y%m%d",nLastBlessTime) then
		me.SetTask(SpringFestival.nTaskGroupId,SpringFestival.nLastBlessToTimeTaskId,GetTime());
		me.SetTask(SpringFestival.nTaskGroupId,SpringFestival.nBlessToCountTaskId,0);
	end
	local nBlessCount = me.GetTask(SpringFestival.nTaskGroupId,SpringFestival.nBlessToCountTaskId);
	if nBlessCount < SpringFestival.nBlessToMaxCountPerDay then
		self:OnUseNotReachMaxCount(it.dwId);
	else
		self:OnUseReachMaxCount(it.dwId);
	end
end

function tbBlessCard:OnUseNotReachMaxCount(nItemId)
	local pItem = KItem.GetObjById(nItemId);
	if not pItem then
		return 0;
	end
	local szMsg = "    我可是一张有神奇魔力的拜年卡。选择你想拜年的人，我就会帮你送出新年礼物和神秘祝福。想要我帮你做什么呢？";
	local tbOpt = {};
	tbOpt[#tbOpt + 1] = {"向队友拜年",self.BlessToTeamMember,self,nItemId};
	tbOpt[#tbOpt + 1] = {"查看今天的拜年情况",self.ViewBlessToPlayer,self,nItemId};
	tbOpt[#tbOpt + 1] = {"Để ta suy nghĩ thêm"};
	Dialog:Say(szMsg,tbOpt);
end

function tbBlessCard:OnUseReachMaxCount(nItemId)
	local pItem = KItem.GetObjById(nItemId);
	if not pItem then
		return 0;
	end
	local szMsg = "    您的拜年卡已经收集了5位好友的祝福，快快兑换领奖吧！";
	local tbOpt = {};
	tbOpt[#tbOpt + 1] = {"查看今天的拜年情况",self.ViewBlessToPlayer,self,nItemId};
	tbOpt[#tbOpt + 1] = {"<color=green>兑换奖励<color>",self.ChangeBlessCard,self,nItemId};
	tbOpt[#tbOpt + 1] = {"Để ta suy nghĩ thêm"};
	Dialog:Say(szMsg,tbOpt);
end

function tbBlessCard:ViewBlessToPlayer(nItemId)
	local pItem = KItem.GetObjById(nItemId);
	if not pItem then
		return 0;
	end
	local szList = pItem.GetTaskBuff(2,1);
	if not szList or #szList <= 0 then
		Dialog:Say("你还没有向任何好友拜过年，快去向好友拜年送祝福吧！",{"Ta hiểu rồi"});
		return 0;
	end
	local szMsg = "以下是你今天拜过年的好友名字：\n";
	szMsg = szMsg .. "<color=green>" .. szList .. "<color>";
	Dialog:Say(szMsg,{"Ta hiểu rồi"});
	return 0;
end

function tbBlessCard:BlessToTeamMember(nItemId)
	local pItem = KItem.GetObjById(nItemId);
	if not pItem then
		return 0;
	end
	local tbMemberId,nCount = KTeam.GetTeamMemberList(me.nTeamId);
	if nCount < 2 then
		Dialog:Say("你没有队伍或者队伍人数小于两个人，无法进行拜年！");
		return 0;
	end
	local szMsg = "你想向谁拜年呢？ ";
	local tbOpt = {};
	for i = 1,nCount do
		local nId = tbMemberId[i];
		local szName = KGCPlayer.GetPlayerName(nId);
		if szName and #szName > 0 and szName ~= me.szName then
			table.insert(tbOpt,{"向<color=green>" .. szName .. "<color>拜年",self.BlessToPlayer,self,nItemId,nId,szName});
		end
	end
	tbOpt[#tbOpt + 1] = {"最近穷的叮当响，我看还是走吧！"};
	Dialog:Say(szMsg,tbOpt);
end

function tbBlessCard:BlessToPlayer(nItemId,nId,szName)
	local pItem = KItem.GetObjById(nItemId);
	if not pItem then
		return 0;
	end
	local nRet,szError = self:CheckCanBlessToPlayer(nItemId,nId,szName);
	if nRet ~= 1 then
		Dialog:Say(szError);
		return 0;
	end
	local pPlayer = KPlayer.GetPlayerObjById(nId);
	local tbGdpl = SpringFestival.tbBlessFromPrize;
	local pPrize = pPlayer.AddItem(unpack(tbGdpl));
	if not pPrize then
		Dbg:WriteLog("SpecialEvent","SpringFestival2011,Give BlessFrom Prize Failed!",pPlayer.nId,pPlayer.szName);		
	end
	local tbMsg = SpringFestival.tbBlessMsg;
	local szToMsg = me.szName .. tbMsg[MathRandom(#tbMsg)];
	pPlayer.CallClientScript({"UiManager:OpenWindow","UI_NEWYEARBLESS",szToMsg});	--弹出界面
	Dialog:SendBlackBoardMsg(me,pPlayer.szName .. "接受了你的新年礼物，并在你的拜年贴上写下了祝福。");
	local szList = pItem.GetTaskBuff(2,1) or "";
	szList = szList .. pPlayer.szName .. "\n";
	pItem.SetTaskBuff(2,1,szList);
	local nBlessFromCount = pPlayer.GetTask(SpringFestival.nTaskGroupId,SpringFestival.nBlessFromCountTaskId);
	pPlayer.SetTask(SpringFestival.nTaskGroupId,SpringFestival.nBlessFromCountTaskId,nBlessFromCount + 1);
	local nBlessCount = me.GetTask(SpringFestival.nTaskGroupId,SpringFestival.nBlessToCountTaskId);
	me.SetTask(SpringFestival.nTaskGroupId,SpringFestival.nBlessToCountTaskId,nBlessCount + 1);
	if nBlessCount + 1 >= SpringFestival.nBlessToMaxCountPerDay then
		Dialog:SendBlackBoardMsg(me,"您的拜年卡已经收集了5位好友的祝福，快快点击拜年帖领奖吧！");
	end
end

function tbBlessCard:CheckCanBlessToPlayer(nItemId,nId,szName)
	local pItem = KItem.GetObjById(nItemId);
	if not pItem then
		return 0,"道具使用错误！";
	end
	local szMapClass = GetMapType(me.nMapId) or "";
	if szMapClass ~= "village" and szMapClass ~= "city" then
		return 0,"只能在城市、新手村内才能进行拜年。";
	end
	local nBlessCount = me.GetTask(SpringFestival.nTaskGroupId,SpringFestival.nBlessToCountTaskId);
	if nBlessCount >= SpringFestival.nBlessToMaxCountPerDay then
		return 0,string.format("你今天已经进行过<color=green>%s<color>次拜年了，无法再拜年了！",SpringFestival.nBlessToMaxCountPerDay);
	end
	local pPlayer = KPlayer.GetPlayerObjById(nId);
	if not pPlayer then
		return 0,string.format("<color=green>%s<color>不在你身边，无法进行拜年！",szName);
	end
	if pPlayer.nLevel < SpringFestival.nBlessBaseLevel then
		return 0,string.format("<color=green>%s<color>等级未达到<color=green>%s<color>级，无法进行拜年！",szName,SpringFestival.nBlessBaseLevel);
	end
	if KPlayer.CheckRelation(me.szName,szName,Player.emKPLAYERRELATION_TYPE_BIDFRIEND) ~= 1 then
		return 0,string.format("<color=green>%s<color>还不是你的好友，这么拜年未免太唐突了吧！",szName);
	end
	local nNearby = 0;
	local tbPlayerList = KPlayer.GetAroundPlayerList(me.nId,SpringFestival.nBlessNeedRange) or {};
	local tbMemberId,nCount = KTeam.GetTeamMemberList(me.nTeamId);
	local nIsPlayerNear = 0;
	for _, tbRound in pairs(tbPlayerList) do
		if pPlayer and pPlayer.szName == tbRound.szName then
			nIsPlayerNear = 1;
			break;
		end
	end
	if nIsPlayerNear ~= 1 then
		return 0,string.format("<color=green>%s<color>离你太远了，无法进行拜年！",szName);
	end
	local nLastBlessFromTime = pPlayer.GetTask(SpringFestival.nTaskGroupId,SpringFestival.nLastBlessFromTimeTaskId);
	if os.date("%Y%m%d",GetTime()) ~= os.date("%Y%m%d",nLastBlessFromTime) then
		pPlayer.SetTask(SpringFestival.nTaskGroupId,SpringFestival.nLastBlessFromTimeTaskId,GetTime());
		pPlayer.SetTask(SpringFestival.nTaskGroupId,SpringFestival.nBlessFromCountTaskId,0);
	end
	local szList = pItem.GetTaskBuff(2,1) or "";
	local nIsPlayerBlessFrom = 0;	--是否向这个玩家拜过年了
	if string.find(szList,szName,1,1) then
		nIsPlayerBlessFrom = 1;
	end
	if nIsPlayerBlessFrom == 1 and SpringFestival.nCanRepeatBlessToOne == 1 then
		return 0,string.format("<color=green>%s<color>已经接受过你的拜年了，还是再找找其他人吧！",szName);
	end
	local nBlessFromCount = pPlayer.GetTask(SpringFestival.nTaskGroupId,SpringFestival.nBlessFromCountTaskId);
	if nBlessFromCount >= SpringFestival.nBlessFromMaxCountPerDay then
		return 0,string.format("<color=green>%s<color>今天已经接受了<color=green>%s<color>次拜年了，还是再找找其他人吧！",szName,SpringFestival.nBlessFromMaxCountPerDay);
	end
	if pPlayer.CountFreeBagCell() < 1 then
		return 0,string.format("请<color=green>%s<color>整理出<color=green>1格<color>背包空间！",szName);
	end
	return 1;
end

function tbBlessCard:ChangeBlessCard(nItemId)
	local pItem = KItem.GetObjById(nItemId);
	if not pItem then
		return 0;
	end
	if me.CountFreeBagCell() < 2 then
		Dialog:Say("请整理出<color=green>2格<color>背包空间！");
		return 0;
	end
	if me.DelItem(pItem,Player.emKLOSEITEM_USE) ~= 1 then
		Dbg:WriteLog("SpecialEvent","SpringFestival2011,Delete BlessCard Failed!",me.nId,me.szName);
	else
		local tbGdplInfo = SpringFestival.tbWordCardGdpl;
		local tbGdpl = tbGdplInfo[MathRandom(#tbGdplInfo)];
		local nLevel = tbGdpl[4];
		local nRet = self:CheckCanChangeCard(nLevel);
		if nRet == 1 then
			local pItem = me.AddItem(unpack(tbGdpl));
			if pItem then
				local nValue = me.GetTask(SpringFestival.nTaskGroupId,SpringFestival.nGetWordCardTaskId);
				nValue = Lib:SetBits(nValue,nLevel,nLevel*3 - 2 ,nLevel * 3);
				me.SetTask(SpringFestival.nTaskGroupId,SpringFestival.nGetWordCardTaskId,nValue);
				Dialog:SendBlackBoardMsg(me,string.format("你收集了一张<color=green>%s<color>，真是太给力了！",KItem.GetNameById(unpack(tbGdpl))));
			else
				Dbg:WriteLog("SpecialEvent","SpringFestival2011,Change BlessCard Failed!",me.nId,me.szName);
			end
		else
			Dialog:SendBlackBoardMsg(me,string.format("你收集了一张<color=green>%s<color>，但你已经有了这张卡，请继续努力吧！",KItem.GetNameById(unpack(tbGdpl))));
		end
		local tbPrize = SpringFestival.tbBlessFromPrize;
		local nCount = SpringFestival.nBlessToPrizeCount;
		local nGiveCount = me.AddStackItem(tbPrize[1],tbPrize[2],tbPrize[3],tbPrize[4],nil,nCount);
		if nGiveCount ~= nCount then
			Dbg:WriteLog("SpecialEvent","SpringFestival2011,Change BlessCard Prize Failed!",me.nId,me.szName);		
		else
			--家族好友公告
			local szFMsg = string.format("Hảo hữu [<color=yellow>%s<color>]收到了5位好友的诚挚祝福，换取到一份丰厚的奖励和一张%s，真是可喜可贺！",me.szName,KItem.GetNameById(unpack(tbGdpl)));
			local szKMsg = string.format("收到了5位好友的诚挚祝福，换取到一份丰厚的奖励和一张%s，真是可喜可贺！",KItem.GetNameById(unpack(tbGdpl)));
			Player:SendMsgToKinOrTong(me,szKMsg,0);
			me.SendMsgToFriend(szFMsg);		
			StatLog:WriteStatLog("stat_info","spring_2012","use_card",me.nId,1);
		end
	end
end

function tbBlessCard:CheckCanChangeCard(nLevel)
	if not nLevel then
		return 0;
	end
	local nValue = me.GetTask(SpringFestival.nTaskGroupId,SpringFestival.nGetWordCardTaskId);
	local nBegin,nEnd = nLevel * 3 - 2,nLevel * 3;
	local nIsLevelHasGet = Lib:LoadBits(nValue,nBegin,nEnd);
	if nIsLevelHasGet > 0 then
		return 0;
	else
		return 1;
	end
end


---福禄康乐寿卡
local tbWordCard = Item:GetClass("wordcard_sf2012");

function tbWordCard:InitGenInfo()
	local nRemainTime = Lib:GetDate2Time(SpringFestival.nStep2EndTime) + 24 * 60 * 60;	
	it.SetTimeOut(0,nRemainTime);	--绝对时间
	return {};
end

-----------元宝
local tbIngot = Item:GetClass("ingot_sf2012");

function tbIngot:InitGenInfo()
	local nRemainTime = GetTime() + SpringFestival.nIngotLiveTime;	
	it.SetTimeOut(0,nRemainTime);	--绝对时间
	return {};
end

-----------礼炮
local tbLipao = Item:GetClass("lipaoitem_sf2012");

function tbLipao:InitGenInfo()
	local nRemainTime = GetTime() + SpringFestival.nLipaoItemLiveTime;	
	it.SetTimeOut(0,nRemainTime);	--绝对时间
	return {};
end

function tbLipao:OnUse()
	local nCanUse,szError = self:CheckCanUse(it.dwId);
	if nCanUse ~= 1 then
		Dialog:Say(szError);
		me.Msg(szError);
		return 0;
	end
	GeneralProcess:StartProcess("安置炮竹中...", 5 * Env.GAME_FPS,{self.DropLipao,self,it.dwId},nil,tbEvent);
end

function tbLipao:CheckCanUse(nItemId)
	local pItem = KItem.GetObjById(nItemId);
	if not pItem then
		return 0,"道具使用错误！";
	end
	if SpringFestival:IsEventStep1Open() ~= 1 then
		return 0,"该活动已经结束！";
	end
	local szMapClass = GetMapType(me.nMapId) or "";
	if szMapClass ~= "village" and szMapClass ~= "city" then
		return 0,"炮竹只能在城市、新手村放置。";
	end
	local nTeamId = me.nTeamId;
	if nTeamId <= 0 then
		return 0,"只有<color=green>组队<color>才能放置炮竹！";
	end
	local tbMemberId,nCount = KTeam.GetTeamMemberList(nTeamId);
	if nCount ~= SpringFestival.nMatchIngotNeedMemberCount then
		return 0,string.format("只有<color=green>%s人队伍<color>才能放置炮竹！",SpringFestival.nMatchIngotNeedMemberCount);
	end
	if me.IsCaptain() ~= 1 then
		return 0,"只有<color=green>队长<color>才能放置炮竹！";
	end
	local nNearby = 0;
	local tbPlayerList = KPlayer.GetAroundPlayerList(me.nId,SpringFestival.nMatchIngotNeedRange) or {};
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
	local szBelong = pItem.GetTaskBuff(2,1) or "";	--获取所属者
	local nAllHasFree = 1;	--是否都有空间 
	local nIsBelong = 1;	--是否属于这个队伍
	local tbMember = me.GetTeamMemberList();
	for _,pPlayer in pairs(tbMember) do
		if pPlayer then
			if not string.find(szBelong,pPlayer.szName,1,1) then
				nIsBelong = 0;
			end
			if pPlayer.CountFreeBagCell() < 1 then
				nAllHasFree = 0;
			end
		end
	end
	if nIsBelong ~= 1 then
		return 0,"这个炮竹不属于你们队伍，请确定队伍成员为领取炮竹时的成员！";
	end
	if nAllHasFree ~= 1 then
		return 0,"请保证队伍中所有成员预留出<color=green>1<color>格背包空间！";	
	end
	local tbNpcList = KNpc.GetAroundNpcList(me,SpringFestival.nLipaoDropRange);
	for _, pNpc in ipairs(tbNpcList) do
		if pNpc.nKind == 3 or pNpc.nTemplateId == SpringFestival.nLipaoNpcTemplateId then
			return 0,"这里貌似太过拥挤了，还是换一个地方试试吧！";
		end
	end
	return 1;
end

function tbLipao:DropLipao(nItemId)
	local nCanUse,szError = self:CheckCanUse(nItemId);
	if nCanUse ~= 1 then
		Dialog:Say(szError);
		me.Msg(szError);
		return 0;
	end
	local pItem = KItem.GetObjById(nItemId);
	if me.DelItem(pItem,Player.emKLOSEITEM_USE) == 1 then
		local nMapId,nX,nY = me.GetWorldPos();	
		local pLipao = KNpc.Add2(SpringFestival.nLipaoNpcTemplateId,1,-1,nMapId,nX,nY);
		if pLipao then
			pLipao.SetLiveTime(SpringFestival.nLipaoNpcLiveTime);	--设置生存时间
			pLipao.GetTempTable("SpecialEvent").tbBelong = {};
			pLipao.GetTempTable("SpecialEvent").nIsFired = 0;
			pLipao.GetTempTable("SpecialEvent").tbFireList = {};
			local tbMember = me.GetTeamMemberList();
			local tbName = {};
			for _,pPlayer in pairs(tbMember) do
				if pPlayer then
					table.insert(pLipao.GetTempTable("SpecialEvent").tbBelong,pPlayer.szName);	--记录所属者
					table.insert(tbName,pPlayer.szName);
				end
			end
			pLipao.szName = "";
			pLipao.Sync();
		else
			Dbg:WriteLog("SpecialEvent","SpringFestival2011,Add Lipao Npc Failed!",me.nId,me.szName);	
		end
	else
		Dbg:WriteLog("SpecialEvent","SpringFestival2011,Delete Lipao Item Failed!",me.nId,me.szName);	
	end
end


----------火折子
local tbMatch = Item:GetClass("unfirematch_sf2012");

function tbMatch:InitGenInfo()
	local nRemainTime = Lib:GetDate2Time(tonumber(os.date("%Y%m%d",GetTime()))) + 24 * 60 * 60;	--到当天晚上24点消失
	it.SetTimeOut(0,nRemainTime);	--绝对时间
	return {};
end

function tbMatch:OnUse()
	local szName = KItem.GetNameById(unpack(SpringFestival.tbFireMatchGdpl));
	local szMsg = string.format("您可以消耗<color=green>精活%s点<color>，加工成一个<color=green>%s<color>。\n\n确定制作么？",SpringFestival.nMakeFireMatchNeedGTMK,szName);
	local tbOpt = 
	{
		{"确定制作",self.MakeMatch,self,it.dwId},
		{"Để ta suy nghĩ thêm"},	
	};
	Dialog:Say(szMsg, tbOpt);
	return 0;
end

function tbMatch:MakeMatch(nItemId)
	local pItem = KItem.GetObjById(nItemId);
	if not pItem then
		return 0;
	end
	local bCanMake,szError = self:CheckCanMake();
	if bCanMake ~= 1 then
		Dialog:Say(szError);
		return 0;
	end
	GeneralProcess:StartProcess("加工中...", 1 * Env.GAME_FPS, {self.DoMake,self,nItemId},nil,tbEvent);
end

function tbMatch:DoMake(nItemId)
	local pItem = KItem.GetObjById(nItemId);
	if not pItem then
		return 0;
	end
	local bCanMake,szError = self:CheckCanMake();
	if bCanMake ~= 1 then
		Dialog:Say(szError);
		return 0;
	end
	local tbGdpl = SpringFestival.tbFireMatchGdpl;
	local nNeedGTPMKP = SpringFestival.nMakeFireMatchNeedGTMK;
	if me.DelItem(pItem,Player.emKLOSEITEM_USE) ~= 1 then
		Dbg:WriteLog("SpecialEvent","SpringFestival2011,Delete Unfire Match Failed!",me.nId,me.szName);	
		return 0;
	end
	me.ChangeCurGatherPoint(-nNeedGTPMKP);
	me.ChangeCurMakePoint(-nNeedGTPMKP);
	local pItem = me.AddItem(unpack(tbGdpl));
	if not pItem then
		Dbg:WriteLog("SpecialEvent","SpringFestival2011,Add Fire Match Failed!",me.nId,me.szName);	
	else
		Dialog:SendBlackBoardMsg(me,"恭喜你得到了一个[燃着的火折子]，可以去各大城市中点燃彩灯了!");
		StatLog:WriteStatLog("stat_info","spring_2012","get_stick",me.nId,1);
	end
end


function tbMatch:CheckCanMake()
	if me.nLevel < SpringFestival.nDropLanternBaseLevel then
		return 0,string.format("等级未达到<color=green>%s<color>级的玩家无法加工火折子！",SpringFestival.nDropLanternBaseLevel);
	end
	if GetMapType(me.nMapId) ~= "city" and GetMapType(me.nMapId) ~= "village" then
		return 0, "该物品只能在各大新手村和城市使用";
	end
	if me.CountFreeBagCell() < 1 then
		return 0, "请保证留出<color=green>1格<color>背包空间！";
	end
	local nNeedGTPMKP = SpringFestival.nMakeFireMatchNeedGTMK;
	if me.dwCurGTP < nNeedGTPMKP or me.dwCurMKP < nNeedGTPMKP then
		local szName = KItem.GetNameById(unpack(SpringFestival.tbFireMatchGdpl));
		return 0,string.format("你的精活不足，制作<color=green>%s<color>需要消耗精活<color=green>%s点<color>。",szName,nNeedGTPMKP);
	end
	return 1;
end

------------燃烧的火折子
local tbFireMatch = Item:GetClass("firematch_sf2012");

function tbFireMatch:InitGenInfo()
	local nRemainTime = Lib:GetDate2Time(tonumber(os.date("%Y%m%d",GetTime()))) + 24 * 60 * 60;	--到当天晚上24点消失
	it.SetTimeOut(0,nRemainTime);	--绝对时间
	return {};
end


--------------新年通用宝箱
local tbCommonPrize = Item:GetClass("prizebox_sf2012");

tbCommonPrize.tbExtPrize = 
{
	{{22,1,81,1},500,100000},	--额外开出物品，gdpl，概率，范围
	{{22,1,81,1},194,100000},	--额外开出物品，gdpl，概率，范围
	{{22,1,81,1},100,100000},	--额外开出物品，gdpl，概率，范围
}

function tbCommonPrize:OnUse()
	local nExtFudaiType = it.GetExtParam(3) or 0;
	local nNeedCell = it.GetExtParam(5) or 0;
	if nNeedCell <= 0 then
		nNeedCell = 1;
	end
	if me.CountFreeBagCell() < nNeedCell then
		Dialog:Say(string.format("请保证留出<color=green>%s格<color>背包空间！",nNeedCell));
		return 0;
	end
	return self:OpenBox(it.dwId);
end

function tbCommonPrize:OpenBox(nItemId)
	local pItem = KItem.GetObjById(nItemId);
	if not pItem then
		me.Msg("道具使用错误！")
		return 0;
	end
	local nExtFudaiType = pItem.GetExtParam(3) or 0;
	local nRandIdOld = pItem.GetExtParam(1) or 0;
	local nRandIdNew = pItem.GetExtParam(2) or 0;
	local nExtPrizeIndex = pItem.GetExtParam(4) or 0;
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
	if nExtPrizeIndex > 0 and self.tbExtPrize[nExtPrizeIndex] then
		if not IpStatistics:IsStudioRole(me) then
			local tbInfo = self.tbExtPrize[nExtPrizeIndex];
			local tbGdpl = tbInfo[1];
			local nRate = tbInfo[2];
			local nRand = tbInfo[3];
			if MathRandom(nRand) <= nRate then
				me.AddItem(unpack(tbGdpl));
				local szMsg = string.format("%s打开%s获得一个%s,真是可喜可贺呀！",me.szName,pItem.szName,KItem.GetNameById(unpack(tbGdpl)));
				local szFMsg = string.format("Hảo hữu [<color=yellow>%s<color>]打开%s获得一个%s,真是可喜可贺呀！",me.szName,pItem.szName,KItem.GetNameById(unpack(tbGdpl)));
				local szKMsg = string.format("打开%s获得一个%s,真是可喜可贺呀！",pItem.szName,KItem.GetNameById(unpack(tbGdpl)));
				Player:SendMsgToKinOrTong(me,szKMsg,0);
				me.SendMsgToFriend(szFMsg);		
				KDialog.NewsMsg(1, Env.NEWSMSG_NORMAL,szMsg);
			end
		end
	end
	if nExtFudaiType > 0 then	--给额外新年福袋
		SpringFestival:GiveExtFudai(nExtFudaiType);
	end
	return 1;
end


------------新年福袋
local tbExtFudai = Item:GetClass("extfudai_sf2012");

function tbExtFudai:OnUse()
	if me.CountFreeBagCell() < 1 then
		Dialog:Say("请保证留出<color=green>1格<color>背包空间！");
		return 0;
	end
	return self:OpenBox(it.dwId);	
end

function tbExtFudai:OpenBox(nItemId)
	local pItem = KItem.GetObjById(nItemId);
	if not pItem then
		me.Msg("道具使用错误！")
		return 0;
	end
	local nRandIdCannotUse = pItem.GetExtParam(1) or 0;
	local nRandIdCanUse = pItem.GetExtParam(2) or 0;
	if nRandIdCannotUse <= 0 or nRandIdCannotUse <= 0 then
		me.Msg("道具使用错误！")
		return 0;
	end
	local tbRandomItem = Item:GetClass("randomitem");
	local nDate = tonumber(os.date("%Y%m%d",GetTime()));
	if nDate < SpringFestival.nStep2BeginTime then
		tbRandomItem:SureOnUse(nRandIdCannotUse);
	else
		tbRandomItem:SureOnUse(nRandIdCanUse);
	end
	return 1;
end


------------新年祈愿卡，自动使用道具
local tbHopeCardIb = Item:GetClass("hopecard_ibshop");

function tbHopeCardIb:OnUse()
	local pItem = me.AddItem(unpack(SpringFestival.tbHopeCardGdpl));
	if not pItem then
		Dbg:WriteLog("SpecialEvent","SpringFestival2011,Add HopeCard Failed!",me.nId,me.szName);
		return 0;
	else
		local nGetCount = me.GetTask(SpringFestival.nTaskGroupId,SpringFestival.nBuyHopeCardTotalTaskId);
		me.SetTask(SpringFestival.nTaskGroupId,SpringFestival.nBuyHopeCardTotalTaskId,nGetCount + 1);
		return 1;
	end
end

--------------祈愿卡
local tbHopeCard = Item:GetClass("hopecard_sf2012");

function tbHopeCard:InitGenInfo()
	local nRemainTime = Lib:GetDate2Time(SpringFestival.nHopeEndDate) + 24 * 60 * 60;	
	it.SetTimeOut(0,nRemainTime);	--绝对时间
	return {};
end


--------------抽奖卡
local tbLotterCard = Item:GetClass("lotterycard_sf2012");

function tbLotterCard:InitGenInfo()
	local nExtParam = tonumber(it.GetExtParam(1)) or 0;
	local tbUseDate = SpringFestival.tbLotterCardUseTime[nExtParam];
	if not tbUseDate then
		return {};
	end
	local nEndDate = Lib:GetDate2Time(tbUseDate[2]);
	local nRemainTime = Lib:GetDate2Time(tonumber(os.date("%Y%m%d",nEndDate))) + 24 * 60 * 60;	
	it.SetTimeOut(0,nRemainTime);	--绝对时间
	return {};
end

function tbLotterCard:OnUse()
	local nRet ,szError = self:CheckCanUse(it.dwId);
	if nRet ~= 1 then
		Dialog:Say(szError,{"Ta hiểu rồi"});
		me.Msg(szError);
		return 0;
	end
	Lottery:UseTicket(me.szName, me.nId);
	return 1;
end

function tbLotterCard:CheckCanUse(nItemId)
	local pItem = KItem.GetObjById(nItemId);
	if not pItem then
		return 0,"道具使用出错！";
	end
	local nExtParam = tonumber(pItem.GetExtParam(1)) or 0;
	local tbUseDate = SpringFestival.tbLotterCardUseTime[nExtParam];
	if not tbUseDate then
		return 0,"道具使用出错！";
	end
	local nNowTime = tonumber(os.date("%Y%m%d%H%M",GetTime()));
	if nNowTime < tbUseDate[1] or nNowTime >= tbUseDate[2] then
		local nBeginTime = Lib:GetDate2Time(tbUseDate[1]);
		local nEndTime = Lib:GetDate2Time(tbUseDate[2]);
		local szBeginDate = string.format("%s年%s月%s日%s点",os.date("%Y",nBeginTime),os.date("%m",nBeginTime),os.date("%d",nBeginTime),os.date("%H",nBeginTime));
		local szEndDate = string.format("%s年%s月%s日%s点",os.date("%Y",nEndTime),os.date("%m",nEndTime),os.date("%d",nEndTime),os.date("%H",nEndTime));
		return 0,string.format("现在还不是使用该道具的时间，请于<color=green>%s<color>至<color=green>%s<color>之间使用！",szBeginDate,szEndDate);
	end
	return 1;
end

--------外装箱子
local tbClothBox = Item:GetClass("newyear_cloth_box");

tbClothBox.tbItem = 
{
	[Player.MALE] = {{1,26,44,1},{1,25,42,1}},	
	[Player.FEMALE] = {{1,26,45,1},{1,25,43,1}},
}

tbClothBox.nClothTime = 30 * 24 * 60 * 60;

function tbClothBox:OnUse()
	local nSex = me.nSex;
	local tbInfo = self.tbItem[nSex];
	if not tbInfo then
		Dialog:Say("道具使用出错！");
		return 0;
	end	
	local nNeedCell = #tbInfo;
	if me.CountFreeBagCell() < nNeedCell then
		Dialog:Say(string.format("请保证留出<color=green>%s格<color>背包空间！",nNeedCell));
		return 0;
	end
	for _,tbGdpl in pairs(tbInfo) do
		local pItem = me.AddItem(unpack(tbGdpl));
		if pItem then
			pItem.SetTimeOut(0,GetTime() + self.nClothTime);
			pItem.Sync();
		end		
	end
	return 1;	
end