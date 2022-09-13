-- 领土战雕像
-- 2009-6-15 10:59:45
-- zhouchenfei

Require("\\script\\domainbattle\\statuary.lua");

local tbNpc = Npc:GetClass("statuary_npc");

tbNpc.MAX_ENDURE			= Domain.tbStatuary.MAX_ENDURE;
tbNpc.DEC_ENDURE_WORSHIP	= Domain.tbStatuary.DEC_ENDURE_WORSHIP;
tbNpc.DEC_ENDURE_SPIT		= Domain.tbStatuary.DEC_ENDURE_SPIT;
tbNpc.INC_REVERE			= Domain.tbStatuary.INC_REVERE;

tbNpc.AWARD_FUDAI			= 3;
--tbNpc.AWARD_EXP				= 300000;
tbNpc.STATE_TIME			= 30;
tbNpc.REPAIR_PRICE			= 5;
tbNpc.REVERE_AWARD			= 1500;

function tbNpc:OnDialog()
	local tbTempDate = Domain.tbStatuary:GetNpcTempTable(him)
	local nEventType = tbTempDate.nEventType or 0;
	local nEndure	= self:GetStatuaryEndure(him.dwId, nEventType);
	local nRevere	= self:GetStatuaryRevere(him.dwId, nEventType);

	local szStatName= self:GetNpcBelongWho(him.dwId, nEventType);
	if (not szStatName) then
		return;
	end
	local szMsg = "";
	if (nEventType == Domain.tbStatuary.TYPE_EVENT_NORMAL) then
		szMsg = string.format("朝廷为了表彰<color=green>%s<color>在捍卫宋国疆土的任务中作出的卓越贡献，特树立此雕像。", szStatName);
	else
		szMsg = string.format("朝廷为了表彰<color=green>%s<color>在跨服联赛中获得的优异成绩，特树立此雕像。", szStatName);
	end
	

	szMsg = string.format("%s\n\n当前崇敬度：<color=yellow>%d<color>\n\n雕像当前耐久度：<color=yellow>%d/%d<color>\n", szMsg, nRevere, nEndure, self.MAX_ENDURE);

	if (0 >= nEndure) then
		local nStateTime= self:GetStatuaryStateTime(him.dwId, nEventType);
		local nNowTime	= GetTime();
		local nDetDay	= self.STATE_TIME - (Lib:GetLocalDay(nNowTime) - Lib:GetLocalDay(nStateTime));
		szMsg = string.format("%s\n由于年久失修，已经完全损坏了……，若<color=yellow>%d<color>天之内没有被修理，该雕像就会被永久回收。", szMsg, nDetDay);
	elseif (nEndure > 0 and nEndure <= 3000) then
		szMsg = string.format("%s\n有了一些破损，失去了光泽……", szMsg);
	elseif (nEndure > 3000 and nEndure <= 6000) then
		szMsg = string.format("%s\n雕像积了一些灰尘，光芒淡化了许多！", szMsg);	
	elseif (nEndure > 6000) then
		szMsg = string.format("%s\n这是一座崭新的雕像，光芒万丈！", szMsg);	
	end
	
	if (me.GetTask(Domain.tbStatuary.TSKGROUPID, Domain.tbStatuary.TSKID_FUDAINOGIVE) > 0) then
		Dialog:Say("你还有奖励未领。", {
				{"现在领", self.OnGiveWorshiperAward, self, me.szName},
				{"先看看再说"},
			});
		return 0;
	end
	
	local tbOpt	= {};

	if (nEndure > 0) then
		table.insert(tbOpt, #tbOpt + 1, {"向雕像膜拜", self.OnChooseWorship, self, me.szName,him.dwId});
		table.insert(tbOpt, #tbOpt + 1, {"向雕像唾弃", self.OnChooseSpit, self, me.szName,him.dwId});
	end

	if (me.szName == szStatName) then
		table.insert(tbOpt, #tbOpt + 1, {"修理雕像", self.OnRepairStatuary, self, him.dwId});
	end
	
	--table.insert(tbOpt, #tbOpt + 1, {"领奖励", self.GiveRevereAward, self, me.szName});
	
	table.insert(tbOpt, #tbOpt + 1, {"只是来看看"});

	Dialog:Say(szMsg, tbOpt);
end

function tbNpc:OnChooseWorship(szSpitPlayer,nNpcId)
	if (szSpitPlayer ~= me.szName) then
		return;
	end
	
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		return;
	end
	
	local tbTempDate = Domain.tbStatuary:GetNpcTempTable(pNpc)
	local nEventType = tbTempDate.nEventType or 0;

	local nFlag, szMsg = self:CheckCanDoIt(me, pNpc.dwId, nEventType);
	if (0 == nFlag) then
		Dialog:Say(szMsg);
		return;
	end	

	local tbTempDate = Domain.tbStatuary:GetNpcTempTable(pNpc)
	local nEventType = tbTempDate.nEventType or 0;

	local szStaName = self:GetNpcBelongWho(pNpc.dwId, nEventType);
	if (not szStaName) then
		return;
	end

	local szMsg = string.format("你要膜拜<color=yellow>%s<color>的雕像吗？\n\n膜拜后，可以获得：\n<color=yellow>%d<color>个福袋，同时提升雕像的<color=yellow>%d<color>点崇敬度\n\n确定要膜拜雕像吗？", szStaName, self.AWARD_FUDAI, self.INC_REVERE);
	local tbOpt = {
			{"确定要膜拜雕像", self.OnChooseSpitOrWorship, self, szSpitPlayer, 1,nNpcId},
			{"Để ta suy nghĩ thêm"},
		};
	Dialog:Say(szMsg, tbOpt);
end

function tbNpc:OnChooseSpit(szSpitPlayer,nNpcId)
	if (szSpitPlayer ~= me.szName) then
		return;
	end
	
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		return;
	end
	
	local tbTempDate = Domain.tbStatuary:GetNpcTempTable(pNpc)
	local nEventType = tbTempDate.nEventType or 0;	

	local nFlag, szMsg = self:CheckCanDoIt(me, pNpc.dwId, nEventType);
	if (0 == nFlag) then
		Dialog:Say(szMsg);
		return;
	end	

	local tbTempDate = Domain.tbStatuary:GetNpcTempTable(pNpc)
	local nEventType = tbTempDate.nEventType or 0;

	local szStaName = self:GetNpcBelongWho(pNpc.dwId, nEventType);
	if (not szStaName) then
		return;
	end
	
	local szMsg = string.format("你要膜拜<color=yellow>%s<color>的雕像吗？\n\n唾弃后，没有任何奖励，但会降低雕像的耐久度。\n\n确定要唾弃雕像吗？\n", szStaName);
	local tbOpt = {
			{"确定要唾弃雕像", self.OnChooseSpitOrWorship, self, szSpitPlayer, 2,nNpcId},
			{"Để ta suy nghĩ thêm"},
		};
	Dialog:Say(szMsg, tbOpt);
end

function tbNpc:OnRepairStatuary(nNpcId)
	
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		return;
	end
	
	local tbTempDate = Domain.tbStatuary:GetNpcTempTable(pNpc)
	local nEventType = tbTempDate.nEventType or 0;

	local szStaName = self:GetNpcBelongWho(pNpc.dwId, nEventType);
	if (not szStaName) then
		return;
	end

	if (szStaName ~= me.szName) then
		Dialog:Say("不是自己的雕像不能修理");
		return;
	end
	
	local nEndure	= Domain.tbStatuary:GetEndure(szStaName, nEventType);
	local nRepairPrice = self.MAX_ENDURE - nEndure;
	if (nEndure >= Domain.tbStatuary.MAX_ENDURE) then
		Dialog:Say("雕像色泽艳丽光亮，不需要修理！");
		return;
	end
	
	if (szStaName ~= me.szName) then
		Dialog:Say("雕像只能靠雕像本人自己来修理！");
		return;
	end
	
	local szMsg = string.format("当前耐久度：%d/%d\n修理该雕像需要花费：<color=yellow>%d<color>个五行魂石\n如果雕像的耐久度为0，则雕像将无法被膜拜！\n\n确定要修理吗？", nEndure, self.MAX_ENDURE, nRepairPrice);
	local tbOpt = {
			{"我要修理", self.RepairStatuary, self,nNpcId},
			{"Để ta suy nghĩ thêm"},
		};
	Dialog:Say(szMsg, tbOpt);
end

function tbNpc:RepairStatuary(nNpcId)
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		return;
	end
	
	local tbTempDate = Domain.tbStatuary:GetNpcTempTable(pNpc)
	local nEventType = tbTempDate.nEventType or 0;

	local szStaName = self:GetNpcBelongWho(pNpc.dwId, nEventType);

	if (not szStaName) then
		return;
	end		
	
	local nEndure	= self.MAX_ENDURE - self:GetStatuaryEndure(pNpc.dwId, nEventType);
	if (szStaName ~= me.szName) then
		Dialog:Say("雕像只能由雕像的树立者才能修理！");
		return;
	end	
	local nStoneCount = me.GetItemCountInBags(18,1,205,1);
	if (nStoneCount < nEndure) then
		Dialog:Say("修理雕像所需的五行魂石不足！");
		return;
	end
	if (1 == me.ConsumeItemInBags2(nEndure, 18,1,205,1)) then
		self:WriteLog("RepairStatuary", string.format("%s use series stone %d failed!", me.szName, nEndure));
		return;
	end
	self:WriteLog("RepairStatuary", string.format("%s use series stone %d success!", me.szName, nEndure));
	Domain.tbStatuary:IncreaseEndure(szStaName, nEventType, self.MAX_ENDURE, 1);
end

function tbNpc:CheckCanDoIt(pPlayer, nNpcId, nEventType)
	if (pPlayer.nLevel < 90) then
		return 0, "你的等级还不够";
	end
	
	local nPrestige = KGblTask.SCGetDbTaskInt(DBTASK_COIN_EXCHANGE_PRESTIGE)
	
	if nPrestige == 0 then
		return 0, "系统尚未进行威望排序，目前不能膜拜或着唾弃雕像。";
	end
	
	if nPrestige > pPlayer.nPrestige then
		return 0, "您的威望排名不够不能膜拜或着唾弃雕像。\n只有威望排名前5000者，才有资格膜拜或唾弃雕像！";
	end
	
	local nDoFlag	= pPlayer.GetTask(Domain.tbStatuary.TSKGROUPID, Domain.tbStatuary.TSKID_FLAG);
	local nNowDay	= Lib:GetLocalDay(GetTime());
	local nLastDay	= Lib:GetLocalDay(nDoFlag); 
	if (nNowDay == nLastDay) then
		return 0, "你已经膜拜或者唾弃过雕像了";
	end
	
	local szStaName = self:GetNpcBelongWho(nNpcId, nEventType);
	if (not szStaName) then
		return 0, "";
	end
	
	if (pPlayer.szName == szStaName) then
		return 0, "不能对自己的雕像膜拜或者唾弃";
	end
	
	if (pPlayer.GetHonorLevel() <= 0) then
		return 0, "膜拜或唾弃雕像需要荣誉等级达到<color=yellow>超凡<color>以上";
	end
	
	return 1;
end

-- 雕像属于谁
function tbNpc:GetNpcBelongWho(nNpcId, nEventType)
	local szName = Domain.tbStatuary:GetNpcBelongWho(nNpcId, nEventType);
	return szName;
end

function tbNpc:OnChooseSpitOrWorship(szPlayerName, nChooseResult,nNpcId)
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		return;
	end	
	
	local tbTempDate = Domain.tbStatuary:GetNpcTempTable(pNpc)
	local nEventType = tbTempDate.nEventType or 0;
	
	if (szPlayerName ~= me.szName) then
		return;
	end

	local szMsg = "";
	local tbOpt	= {};
	
	if (1 == nChooseResult) then
		szMsg	= "准备膜拜";
		tbOpt	= {self.WorshipMe, self, me.szName, pNpc.dwId, nEventType}; 
	elseif (2 == nChooseResult) then
		szMsg = "准备唾弃";
		tbOpt	= {self.SpitAtMe, self, me.szName, pNpc.dwId, nEventType}; 
	else
		return;
	end

	local tbBreakEvent = 
	{
		Player.ProcessBreakEvent.emEVENT_MOVE,
		Player.ProcessBreakEvent.emEVENT_ATTACK,
		Player.ProcessBreakEvent.emEVENT_SIT,
		Player.ProcessBreakEvent.emEVENT_RIDE,
		Player.ProcessBreakEvent.emEVENT_USEITEM,
		Player.ProcessBreakEvent.emEVENT_ARRANGEITEM,
		Player.ProcessBreakEvent.emEVENT_DROPITEM,
		Player.ProcessBreakEvent.emEVENT_CHANGEEQUIP,
		Player.ProcessBreakEvent.emEVENT_SENDMAIL,		
		Player.ProcessBreakEvent.emEVENT_TRADE,
		Player.ProcessBreakEvent.emEVENT_CHANGEFIGHTSTATE,
		Player.ProcessBreakEvent.emEVENT_ATTACKED,
		Player.ProcessBreakEvent.emEVENT_DEATH,
		Player.ProcessBreakEvent.emEVENT_LOGOUT,
		Player.ProcessBreakEvent.emEVENT_REVIVE,
		Player.ProcessBreakEvent.emEVENT_CLIENTCOMMAND,
	}
	GeneralProcess:StartProcess(szMsg, 10 * Env.GAME_FPS, tbOpt, nil, tbBreakEvent);	
	return;
end

-- 唾弃,go to hell
function tbNpc:SpitAtMe(szSpitPlayer, nNpcId, nEventType)
	if (szSpitPlayer ~= me.szName) then
		return;
	end
	
	local nFlag, szMsg = self:CheckCanDoIt(me, nNpcId, nEventType);
	if (0 == nFlag) then
		Dialog:Say(szMsg);
		return;
	end
	
	local szStaName = self:GetNpcBelongWho(nNpcId, nEventType);
	assert(szStaName);

	Domain.tbStatuary:DecreaseEndure(szStaName, nEventType, self.DEC_ENDURE_SPIT);
	me.SetTask(Domain.tbStatuary.TSKGROUPID, Domain.tbStatuary.TSKID_FLAG, GetTime());
	me.Msg(string.format("降低了雕像的耐久度：%d点。", self.DEC_ENDURE_SPIT));
	local szSendMsg = string.format("[%s]唾弃了%s的雕像。", me.szName, szStaName);
	me.SendMsgToFriend(string.format("你的好友%s", szSendMsg));
	me.SendMsgToKinOrTong(1, string.format("帮会成员%s", szSendMsg));
	Dbg:WriteLogEx(Dbg.LOG_INFO, "Statuary_SpitAtMe", szStaName, me.szName);
end

-- 膜拜, 额滴神啊
function tbNpc:WorshipMe(szWorshipPlayer, nNpcId, nEventType)
	if (szWorshipPlayer ~= me.szName) then
		return;
	end

	local nFlag, szMsg = self:CheckCanDoIt(me, nNpcId, nEventType);
	if (0 == nFlag) then
		Dialog:Say(szMsg);
		return;
	end	

	local szStaName = self:GetNpcBelongWho(nNpcId, nEventType);

	assert(szStaName);

	Domain.tbStatuary:IncreaseRevere(szStaName, nEventType, self.INC_REVERE);
	Domain.tbStatuary:DecreaseEndure(szStaName, nEventType, self.DEC_ENDURE_WORSHIP);
	me.SetTask(Domain.tbStatuary.TSKGROUPID, Domain.tbStatuary.TSKID_FLAG, GetTime());
	me.Msg(string.format("提升了雕像的崇敬度：%d点，降低了雕像的耐久度：%d点。", self.INC_REVERE, self.DEC_ENDURE_WORSHIP));
	self:GiveWorshiperAward(me);
	local szSendMsg = string.format("[%s]膜拜了%s的雕像。", me.szName, szStaName);
	me.SendMsgToFriend(string.format("你的好友%s", szSendMsg));
	me.SendMsgToKinOrTong(1, string.format("帮会成员%s", szSendMsg));
	Dbg:WriteLogEx(Dbg.LOG_INFO, "Statuary_WorshipMe", szStaName, me.szName);
end

function tbNpc:GetStatuaryEndure(nNpcId, nEventType)
	local szStaName = self:GetNpcBelongWho(nNpcId, nEventType);
	if (not szStaName) then
		return;
	end
	local nEndure	= Domain.tbStatuary:GetEndure(szStaName, nEventType);
	return nEndure;
end

function tbNpc:GetStatuaryRevere(nNpcId, nEventType)
	local szStaName = self:GetNpcBelongWho(nNpcId, nEventType);
	if (not szStaName) then
		return;
	end
	local nRevere	= Domain.tbStatuary:GetRevere(szStaName, nEventType);
	return nRevere;
end

function tbNpc:GetStatuaryStateTime(nNpcId, nEventType)
	local szStaName = self:GetNpcBelongWho(nNpcId, nEventType);
	if (not szStaName) then
		return;
	end
	local nTime		= Domain.tbStatuary:GetStateTime(szStaName, nEventType);
	return nTime;
end

-- 给膜拜者奖励
function tbNpc:GiveWorshiperAward(pPlayer)
	if (pPlayer.CountFreeBagCell() < self.AWARD_FUDAI) then
		pPlayer.Msg("Hành trang không đủ chỗ trống，领取奖励失败");
		pPlayer.SetTask(Domain.tbStatuary.TSKGROUPID, Domain.tbStatuary.TSKID_FUDAINOGIVE, self.AWARD_FUDAI);
		return;
	end
	for i=1, self.AWARD_FUDAI do
		pPlayer.AddItem(18,1,80,1);
	end
	pPlayer.SetTask(Domain.tbStatuary.TSKGROUPID, Domain.tbStatuary.TSKID_FUDAINOGIVE, 0);
end

function tbNpc:OnGiveWorshiperAward(szName)
	local pPlayer = KPlayer.GetPlayerByName(szName);
	if (not pPlayer) then
		return;
	end
	local nCount = pPlayer.GetTask(Domain.tbStatuary.TSKGROUPID, Domain.tbStatuary.TSKID_FUDAINOGIVE);
	if (nCount <= 0) then
		return;
	end
	self:GiveWorshiperAward(pPlayer);
end

function tbNpc:WriteLog(...)
	if (MODULE_GAMESERVER) then
		Dbg:WriteLogEx(Dbg.LOG_INFO, "Domain", "Statuary_npc", unpack(arg));
	end
	if (MODULE_GAMECLIENT) then
		Dbg:Output("Domain", "Statuary_npc", unpack(arg));
	end
	if (MODULE_GC_SERVER) then
		Dbg:Output("Domain", "Statuary_npc", unpack(arg));
	end
end
