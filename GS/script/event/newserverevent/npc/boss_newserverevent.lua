-- 文件名　：boss_newserverevent.lua
-- 创建者　：zhangjunjie
-- 创建时间：2011-11-09 17:49:29
-- 描述：家族boss

SpecialEvent.NewServerEvent =  SpecialEvent.NewServerEvent or {};
local NewServerEvent = SpecialEvent.NewServerEvent;

local tbBoss = Npc:GetClass("boss_newserverevent");

function tbBoss:OnDeath()
	local nKinId = him.GetTempTable("SpecialEvent").nKinId or 0;
	local nMaxOpenCount = him.GetTempTable("SpecialEvent").nCanOpenMaxCount or 0;
	local nTemplateId = NewServerEvent.nBoxTemplateId;
	local nMapId,nX,nY = him.GetWorldPos();
	local nDelTimer = him.GetTempTable("SpecialEvent").nDeleteTimer;	--关闭计时器
	if nDelTimer and nDelTimer > 0 then 
		Timer:Close(nDelTimer);
	end
	him.DropRateItem("\\setting\\npc\\droprate\\newserverevent\\boss.txt", 2);
	local pNpc = KNpc.Add2(nTemplateId,10,-1,nMapId,nX,nY);
	if pNpc then
		local cKin = KKin.GetKin(nKinId);
		if cKin then
			pNpc.szName = "";
			pNpc.SetTitle(string.format("Gia tộc <color=yellow>%s<color>",cKin.GetName()));
			pNpc.Sync();
		end
		pNpc.GetTempTable("SpecialEvent").nKinId = nKinId;
		pNpc.GetTempTable("SpecialEvent").tbHasGetPlayer = {};	--记录谁已经开启过
		--计时器，宝箱的存在时间
		pNpc.GetTempTable("SpecialEvent").nDeleteTimer = Timer:Register(NewServerEvent.nKinBoxExistDelay,Npc:GetClass("box_newserverevent").OnDelete,Npc:GetClass("box_newserverevent"),pNpc.dwId);
	else
		Dbg:WriteLog("New Server Event","Call Box Failed",me.szName);
	end
end

function tbBoss:OnDelete(nId)
	local pNpc = KNpc.GetById(nId);
	if pNpc then
		pNpc.Delete();
	end
	return 0;
end

--------------------------宝箱
local tbBox  = Npc:GetClass("box_newserverevent");

function tbBox:OnDialog()
	local cKin = KKin.GetKin(me.dwKinId);
	if not cKin then
		Dialog:Say("你没有家族！");
		return 0;
	end
	if not him.GetTempTable("SpecialEvent").tbHasGetPlayer then	--标记已经拿过奖励的玩家的id
		 him.GetTempTable("SpecialEvent").tbHasGetPlayer = {};
	end
	local nKinId = him.GetTempTable("SpecialEvent").nKinId or 0;
	if me.dwKinId ~= nKinId then
		Dialog:Say("这个宝箱不是你们家族的，无法领取！");
		return 0;
	else
		local nLastGetTime  = tonumber(os.date("%Y%m%d",me.GetTask(NewServerEvent.nTaskId,NewServerEvent.nPlayerOpenBoxTimeGroupId)));	
		if nLastGetTime ~= tonumber(os.date("%Y%m%d",GetTime())) then
			me.SetTask(NewServerEvent.nTaskId,NewServerEvent.nPlayerOpenBoxCountGroupId,0);
			me.SetTask(NewServerEvent.nTaskId,NewServerEvent.nPlayerOpenBoxTimeGroupId,GetTime());
		end
		local nHasGetCount  = me.GetTask(NewServerEvent.nTaskId,NewServerEvent.nPlayerOpenBoxCountGroupId);	
		if nHasGetCount >= NewServerEvent.nMaxOpenBoxCount then
			Dialog:Say(string.format("你今天已经开启过%s次宝箱了，不要太贪心了",NewServerEvent.nMaxOpenBoxCount));
			return 0;
		else
			if him.GetTempTable("SpecialEvent").tbHasGetPlayer and him.GetTempTable("SpecialEvent").tbHasGetPlayer[me.nId] == 1 then
				Dialog:Say("这个宝箱你已经开启过了！");
				return 0;	
			else
				local nRemainFrame = tonumber(Timer:GetRestTime(him.GetTempTable("SpecialEvent").nDeleteTimer or 0));
				local szRemainTime = Lib:FrameTimeDesc(nRemainFrame);
				local szMsg = string.format("这是你们家族的战利宝箱，赶快领取吧！宝箱剩余时间<color=yellow>%s<color>",szRemainTime);
				local tbOpt = {};
				tbOpt[#tbOpt + 1] = {"Lãnh nhận",self.GivePrize,self,him.dwId};
				tbOpt[#tbOpt + 1] = {"Để ta suy nghĩ thêm"};
				Dialog:Say(szMsg,tbOpt);
				return 1;
			end
		end
	end
end

function tbBox:GivePrize(nNpcId)
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		return 0;
	end
	if me.CountFreeBagCell() < 1 then
		local szMsg = "Hành trang không đủ <color=yellow>1 ô<color> trống!";
		Dialog:Say(szMsg);
		me.Msg(szMsg);
		return 0;
	end
	local pItem = me.AddItem(unpack(NewServerEvent.tbBoxGDPL));
	if pItem then
		local nCount = me.GetTask(NewServerEvent.nTaskId,NewServerEvent.nPlayerOpenBoxCountGroupId);
		me.SetTask(NewServerEvent.nTaskId,NewServerEvent.nPlayerOpenBoxCountGroupId,nCount + 1);
		pNpc.GetTempTable("SpecialEvent").tbHasGetPlayer[me.nId] = 1;
		SpecialEvent.tbGoldBar:AddTask(me, 7);		--金牌联赛家族挑战boss成功
	else
		return 0;
	end
end

function tbBox:OnDelete(nId)
	local pNpc = KNpc.GetById(nId);
	if pNpc then
		pNpc.Delete();
	end
	return 0;
end


--------------------------对话小龙女
local tbNpcEx  = Npc:GetClass("newserverevent");

function tbNpcEx:OnDialog()
	local szMsg = "喜迎服务器开放之际，我给大家送上无尽祝福，组队来我这里可以领取特殊的祝福，队伍人数越多获得的奖励越多哦，快快召集你的好友来参加吧。"
	Dialog:Say(szMsg, {{"我要领取", self.OnDialogEx, self, him.dwId}, {"Để ta suy nghĩ thêm"}});
	return;
end

function tbNpcEx:OnDialogEx(nId)
	local pNpc = KNpc.GetById(nId);
	if not pNpc then
		return;
	end
	if me.nLevel < SpecialEvent.NewServerEvent.nWelFareBaseLevel then
		Dialog:Say(string.format("您的等级太低了，需要%s级才能领取奖励。", SpecialEvent.NewServerEvent.nWelFareBaseLevel));
		return 0;
	end
	if me.nFaction <= 0 then
		Dialog:Say("你怎么还是个小白，请先加入门派。");
		return 0;
	end
	if me.nTeamId <= 0 then
		Dialog:Say("组队才有奖励的哟，快找些侠士一起来吧。");
		return 0;
	end
	if me.GetBindMoney() + 40000 > me.GetMaxCarryMoney() then
		Dialog:Say("您携带的绑银将达上线，请整理下再来领取。");
		return 0;
	end
	local nRet = Player:CheckTask(SpecialEvent.NewServerEvent.nTaskId, SpecialEvent.NewServerEvent.TASK_GETITEM_DATE, "%Y%m%d", SpecialEvent.NewServerEvent.TASK_GETITEM, SpecialEvent.NewServerEvent.nMaxGetItemDay);	
	if nRet == 0 then
		Dialog:Say("您今天已经领取了10次祝福，请下次活动再来吧！");
		return 0;
	end
	pNpc.GetTempTable("Npc").tbGetAwardList = pNpc.GetTempTable("Npc").tbGetAwardList or {};
	if pNpc.GetTempTable("Npc").tbGetAwardList[me.szName] then
		Dialog:Say("你太贪心了吧，每个人只能领取一次的。");
		return 0;
	end
	local nRate = MathRandom(SpecialEvent.NewServerEvent.nMaxRate);
	local tbAward = nil;
	for i, tb in pairs(SpecialEvent.NewServerEvent.tbAwardList) do
		if nRate < i and nRate >= tb[3] then
			tbAward = tb;
			break;
		end
	end
	local nMapId, nX, nY = me.GetWorldPos();
	local tbPlayerList = KTeam.GetTeamMemberList(me.nTeamId);
	local nTeamCount = 0;
	for i, nId in ipairs(tbPlayerList) do
		local pPlayer = KPlayer.GetPlayerObjById(nId);
		if pPlayer and pPlayer.szName ~= me.szName then
			local nMapId2, nX2, nY2 = pPlayer.GetWorldPos();
			if nMapId2 == nMapId and (nX - nX2) * (nX - nX2) + (nY - nY2) * (nY - nY2) <= 400 then
				nTeamCount = nTeamCount + 1;
			end
		end
	end
	if tbAward[1] =="bindcoin" then
		me.AddBindCoin(tbAward[2] * (1 + nTeamCount /10));
	elseif tbAward[1] == "bindmoney" then
		me.AddBindMoney(tbAward[2] * (1 + nTeamCount /10));
	elseif tbAward[1] == "Exp" then
		me.AddExp(me.GetBaseAwardExp() * tbAward[2] * (1 + nTeamCount /10));
	end
	local nCount = me.GetTask(SpecialEvent.NewServerEvent.nTaskId, SpecialEvent.NewServerEvent.TASK_GETITEM) + 1;
	local szMsg = string.format("目前队伍中有<color=yellow>%s<color>人在附近，奖励提升为<color=yellow>%s<color>%%，恭喜您获得了第<color=yellow>%s<color>次小龙女的祝福。", nTeamCount, nTeamCount * 10, nCount);
	me.Msg(szMsg);
		
	pNpc.GetTempTable("Npc").tbGetAwardList[me.szName] = 1;
	me.SetTask(SpecialEvent.NewServerEvent.nTaskId, SpecialEvent.NewServerEvent.TASK_GETITEM, nCount);
end
