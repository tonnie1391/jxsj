-- 文件名　：weddingring.lua
-- 创建者　：furuilei
-- 创建时间：2009-12-10 11:59:56
-- 功能描述：结婚戒指
-- modify by zhangjinpin@kingsoft 2010-01-29

local tbItem = Item:GetClass("marry_weddingring");

--==========================================================


tbItem.KISS_DISTANCE = 50;	-- 使用接吻技能需要的最大距离

tbItem.LEVEL_PINGMIN = 1;
tbItem.LEVEL_GUIZU = 2;
tbItem.LEVEL_WANGHOU = 3;
tbItem.LEVEL_HUANGJIA = 4;

tbItem.tbExpRate = {120, 120, 120, 120};

--==========================================================

function tbItem:CanUse(pItem)
	
	if (not pItem or Marry:CheckState() == 0) then
		return 0;
	end

	local szErrMsg = "";
	if (me.IsMarried() == 0) then
		szErrMsg = "你还没有与心上人结成侠侣，怎么能使用信物呢？还是等你与心上人成为侠侣后再试吧！";
		return 0, szErrMsg;
	end
	
	local szCustom = pItem.szCustomString;
	local szCoupleName = me.GetCoupleName();
	if (not szCustom or szCustom == "" or not szCoupleName or "" == szCoupleName) then
		return 0, szErrMsg;
	end
	if (szCustom ~= szCoupleName) then
		szErrMsg = string.format("这件信物是你和<color=yellow>%s<color>情意的见证，不能用于和其他人之间。", szCustom);
		return 0, szErrMsg;
	end
	
	return 1;
end

function tbItem:OnUse()
	
	local bCanUse, szErrMsg = self:CanUse(it);
	if (0 == bCanUse) then
		if ("" ~= szErrMsg) then
			local tbOpt = 
			{
				{"放弃信物", self.BreakRing, self, me.nId, it.dwId},
				{"Ta hiểu rồi"},
			};
			Dialog:Say(szErrMsg, tbOpt);
		end
		return 0;
	end
	
	local szMsg = "侠侣信物，是你与心上人情意的见证。你可以通过它使用一些特殊的功能。";
	local tbOpt = self:GetChoice(it.nLevel) or {};
	Dialog:Say(szMsg, tbOpt);
end

function tbItem:GetChoice(nLevel)
	local tbOpt = {};
	if (not nLevel or nLevel < self.LEVEL_PINGMIN or nLevel > self.LEVEL_HUANGJIA) then
		return;
	end
	
	-- 亲吻技能，所有档次的都有
	table.insert(tbOpt, {"发送心心相印", self.CoupleKiss, self});
	
	-- 夫妻经验加成，所有档次都有
	if (0 == me.GetTask(Marry.TASK_GROUP_ID, Marry.TASK_EXP_RATE)) then
		table.insert(tbOpt, {"激活侠侣打怪经验加成", self.GetAddExpState, self, nLevel});
	else
		table.insert(tbOpt, {"<color=gray>激活侠侣打怪经验加成<color>", self.AlreadyUseDlg, self});
	end
	
	-- 夫妻传送，贵族以上档次的才有
	if (nLevel >= self.LEVEL_GUIZU) then
		table.insert(tbOpt, {"侠侣传送", self.Come2Couple, self});
	else
		table.insert(tbOpt, {"<color=gray>侠侣传送<color>", self.NeedUpdateRingDlg, self});
	end
	
	-- 新婚光环，王侯以上级别才有
	if (nLevel >= self.LEVEL_WANGHOU) then
		if (0 == me.GetTask(Marry.TASK_GROUP_ID, Marry.TASK_GET_WEDDING_TITLE)) then
			table.insert(tbOpt, {"侠侣光环", self.AddWeddingGuangHuan, self});
		else
			table.insert(tbOpt, {"<color=gray>侠侣光环<color>", self.AlreadyUseDlg, self});
		end
	else
		table.insert(tbOpt, {"<color=gray>侠侣光环<color>", self.NeedUpdateRingDlg, self});
	end
	
	-- 新婚坐骑，皇家以上档次才有
	if (nLevel >= self.LEVEL_HUANGJIA) then
		if (me.GetTask(Marry.TASK_GROUP_ID, Marry.TASK_GET_WEDDIGN_HORSE) == 0) then
			table.insert(tbOpt, {"获得侠侣坐骑", self.GetWeddingHorse, self});
		else
			table.insert(tbOpt, {"<color=gray>获得侠侣坐骑<color>", self.AlreadyUseDlg, self});
		end
	else
		table.insert(tbOpt, {"<color=gray>获得侠侣坐骑<color>", self.NeedUpdateRingDlg, self});
	end
	
	table.insert(tbOpt, {"放弃信物", self.BreakRing, self, me.nId, it.dwId});
	table.insert(tbOpt, {"Kết thúc đối thoại"});
	return tbOpt;
end

function tbItem:BreakRing(nPlayerId, dwItemId)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	local pItem = KItem.GetObjById(dwItemId);
	if pItem and pPlayer then
		local tbOpt = 
		{
			{"是的", self.OnBreak, self, nPlayerId, dwItemId},
			{"Để ta suy nghĩ thêm"},
		};
		Setting:SetGlobalObj(pPlayer);
		Dialog:Say("莫道萍踪随水逝，永留侠影在心田。开谢花、三生石，你要放弃这个信物么？", tbOpt);
		Setting:RestoreGlobalObj(pPlayer);
	end
end

function tbItem:OnBreak(nPlayerId, dwItemId)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	local pItem = KItem.GetObjById(dwItemId);
	if pItem and pPlayer then
		pItem.Delete(pPlayer);
	end
end

function tbItem:AlreadyUseDlg()
	Dialog:Say("您已经获得了该功能。");
	return;
end

function tbItem:NeedUpdateRingDlg()
	Dialog:Say("根据您的典礼档次，暂时还不能使用该功能。敬请期待……");
	return;
end

-- 增加新婚光环
function tbItem:AddWeddingGuangHuan()
	Marry:SetAdvTitle(me, me.nSex);
	me.SetTask(Marry.TASK_GROUP_ID, Marry.TASK_GET_WEDDING_TITLE, 1);
end

-- 夫妻经验加成
function tbItem:GetAddExpState(nLevel)
	local nExpRate = self.tbExpRate[nLevel];
	me.SetTask(Marry.TASK_GROUP_ID, Marry.TASK_EXP_RATE, nExpRate);
	local szMsg = string.format("您已经激活了该功能，以后和心上人打怪的时候，会获得<color=yellow>%s%%<color>的经验加成", nExpRate);
	Dialog:Say(szMsg);
end

-- 获取新婚坐骑
function tbItem:GetWeddingHorse()
	local bHaveGetHorse = me.GetTask(Marry.TASK_GROUP_ID, Marry.TASK_GET_WEDDIGN_HORSE);
	if (bHaveGetHorse ~= 0) then
		return;
	end
	
	if (me.CountFreeBagCell() < 1) then
		me.Msg("Hành trang không đủ chỗ trống，请清理出1格背包空间再来领取侠侣坐骑吧。");
		return;
	end
	
	local pItem = nil;
	if (me.nSex == 0) then
		pItem = me.AddItem(1, 12, 25, 4);
	else
		pItem = me.AddItem(1, 12, 26, 4);
	end
	if (pItem) then
		me.SetItemTimeout(pItem, 60 * 24 * 30 * 6, 0);
		pItem.Bind(1);
	end
	me.SetTask(Marry.TASK_GROUP_ID, Marry.TASK_GET_WEDDIGN_HORSE, 1);
	Dialog:Say("你已经获得了侠侣坐骑。");
	
	Dbg:WriteLog("Marry", "结婚系统", me.szName, me.szAccount, "获取了新婚坐骑");
end

-- KISS
function tbItem:CoupleKiss()
	if (me.IsMarried() == 0) then
		return;
	end
	local szCoupleName = me.GetCoupleName();
	if (not szCoupleName) then
		return;
	end
	local bIsNearby = 0;
	local tbPlayerList = KPlayer.GetAroundPlayerList(me.nId, 50);
	for _, pPlayer in pairs(tbPlayerList) do
		if (szCoupleName == pPlayer.szName) then
			bIsNearby = 1;
			break;
		end
	end
	if (0 == bIsNearby) then
		Dialog:Say("你和你的心上人没有站在一起，不能传达情意。");
		return;
	end
	
	me.CastSkill(1558, 1, -1, me.GetNpc().nIndex);
end

-- 夫妻传送
function tbItem:Come2Couple()
	if (me.IsMarried() == 0) then
		return;
	end
	local szCoupleName = me.GetCoupleName();
	if (not szCoupleName) then
		return;
	end
	local nCoupleId = KGCPlayer.GetPlayerIdByName(szCoupleName);
	local nOnline = KGCPlayer.OptGetTask(nCoupleId, KGCPlayer.TSK_ONLINESERVER);
	if (0 == nOnline) then
		Dialog:Say("对方不在线，不能使用侠侣传送。");
		return;
	end
	
	local nCanUse = KItem.CheckLimitUse(me.nMapId, "chuansong");
	if (not nCanUse or nCanUse == 0) then
		me.Msg("该道具禁止在本地图使用！");
		return;
	end
	
	-- 会中断延时的事件
	local tbEvent	= 
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
	};
	
	-- 玩家在非战斗状态下传送无延时正常传送
	if (0 == me.nFightState) then
		self:DoSelectMember(nCoupleId, me.nId)
		return 0;
	end
	
	-- 在战斗状态下需要nTime秒的延时	
	GeneralProcess:StartProcess(string.format("正在传送去[%s]那...", szCoupleName), 1 * Env.GAME_FPS, {self.DoSelectMember, self, nCoupleId, me.nId}, nil, tbEvent);
end

function tbItem:DoSelectMember(nCoupleId, nPlayerId)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId)
	local nOnline = KGCPlayer.OptGetTask(nCoupleId, KGCPlayer.TSK_ONLINESERVER);
	if nOnline <= 0 then
		Dialog:Say("对方已经下线，无法传送到对方身边。");
		return 0;
	end
	GCExcute({"Marry.tbFuQiChuanSongFu:SelectMemberPos", nCoupleId, nPlayerId});
end

