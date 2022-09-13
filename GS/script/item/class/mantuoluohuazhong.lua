-- zhouchenfei
-- 2012/8/22 20:32:16
-- 曼陀罗花种

local tbManHuaZhong = Item:GetClass("mantuoluohuazhong");

tbManHuaZhong.nLimitLevel = 60;
tbManHuaZhong.nBaseNum = 50;
tbManHuaZhong.nBaseJinghuo = 260;
tbManHuaZhong.tbManZhongZi = {18,1,1781,1};
tbManHuaZhong.tbManFlower = {18,1,1782,1};

function tbManHuaZhong:OnUse()
	local nFlag, szMsg = self:IsCanUse(me);
	if (nFlag == 0) then
		me.Msg(szMsg);
		return 0;
	end

	local nMaterialCount = me.GetItemCountInBags(unpack(self.tbManZhongZi));
	Dialog:AskNumber("请输入制作的数量：", nMaterialCount, self.MakeMantuoluoDlg, self);
end

function tbManHuaZhong:IsCanUse(pPlayer)
	if (Faction:IsOpenGumuFuXiuTask() == 0) then
		return 0, "现在不能散播曼佗罗之种哦！";
	end	
	
	if (pPlayer.nLevel < self.nLimitLevel) then
		return 0, string.format("您的等级未达到%s级，不能使用种子！", self.nLimitLevel);
	end
	
	if (pPlayer.nFaction <= 0) then
		return 0, "您还没加入门派，不能使用种子！";
	end

	if GetMapType(pPlayer.nMapId) ~= "city" and GetMapType(pPlayer.nMapId) ~= "village" and 
		GetMapType(pPlayer.nMapId) ~= "faction" then
		return 0, "该物品只能在各大新手村、城市和门派使用。";
	end

	return 1;
end

function tbManHuaZhong:IsCanMakeFlower(pPlayer, nCount)
	if (nCount <= 0) then
		return 0, "没有散播种子。";
	end

	local nMaterialCount = pPlayer.GetItemCountInBags(unpack(self.tbManZhongZi));
	if nMaterialCount < nCount then
		return 0, "您身上的曼佗罗之种不足！";
	end	
	
	local nNeedFreeBag = math.ceil(nCount / self.nBaseNum);

	if pPlayer.CountFreeBagCell() < nNeedFreeBag then
		return 0, string.format("需要<color=yellow>%s格<color>背包空间，请整理下再来吧！", nNeedFreeBag);
	end
	
	local nNeedJinghuo = self.nBaseJinghuo * nCount;
	if (pPlayer.dwCurGTP < nNeedJinghuo or pPlayer.dwCurMKP < nNeedJinghuo) then
		return 0, string.format("您的精活不足，散播%s颗种子需要消耗精力和活力各%s点。", nCount, nNeedJinghuo);
	end

	return 1;
end

function tbManHuaZhong:MakeMantuoluoDlg(nCount, nSure)
	if nCount <= 0 then
		return 0;
	end

	local nFlag, szMsg = self:IsCanUse(me);
	if (nFlag == 0) then
		Dialog:Say(szMsg);
		return 0;
	end
	
	local nRet, szErrMsg = self:IsCanMakeFlower(me, nCount);
	if nRet ~= 1 then
		Dialog:Say(szErrMsg);
		return 0;
	end
	if not nSure then
		local szMsg = string.format("散播%s粒花种需要消耗精力活力各%s点以及种子%s粒。\n\n确定散播吗？", nCount, nCount * self.nBaseJinghuo, nCount);
		local tbOpt = 
		{
			{"确定散播", self.MakeMantuoluoDlg, self, nCount, 1},
			{"Để ta suy nghĩ thêm"},	
		};
		Dialog:Say(szMsg, tbOpt);
		return 1;
	end
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
	}
	GeneralProcess:StartProcess("散播花种中", 5 * Env.GAME_FPS, 
		{self.MakeFlower, self, me.nId, nCount}, nil, tbEvent);
end

function tbManHuaZhong:MakeFlower(nPlayerId, nCount)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		return 0;
	end
	local nFlag, szMsg = self:IsCanUse(pPlayer);
	if (nFlag ~= 1) then
		pPlayer.Msg(szMsg);
		return 0;
	end
	
	local nFlag, szMsg = self:IsCanMakeFlower(pPlayer, nCount);
	if nFlag ~= 1 then
		pPlayer.Msg(szMsg);
		return 0;
	end
	
	local nRet = pPlayer.ConsumeItemInBags(nCount, self.tbManZhongZi[1], self.tbManZhongZi[2], self.tbManZhongZi[3], self.tbManZhongZi[4], -1);
	if (nRet ~= 0) then
		Dbg:WriteLog("Mantuoluozhizhong", "ConsumeItemInBags failed", pPlayer.szAccount, pPlayer.szName);
		return 0;
	end
	local nNeedGTPMKP = self.nBaseJinghuo * nCount;
	pPlayer.ChangeCurGatherPoint(-nNeedGTPMKP);
	pPlayer.ChangeCurMakePoint(-nNeedGTPMKP);
	local nAddCount = pPlayer.AddStackItem(self.tbManFlower[1], self.tbManFlower[2], self.tbManFlower[3], self.tbManFlower[4], nil, nCount);
	if nAddCount < nCount then
		Dbg:WriteLog("Mantuoluozhizhong", "MakeFlower failed", nAddCount, nCount, me.szName);
	else
		Dbg:WriteLog("Mantuoluozhizhong", "MakeFlower success", me.szName, nCount);
	end
	pPlayer.Msg(string.format("恭喜您成功收集了%s朵曼佗罗花，据说古墓派的苏清泠正在收集。", nAddCount));
	--StatLog:WriteStatLog("stat_info", "fishing", "item_proc", nPlayerId, 1, nAddCount);
	StatLog:WriteStatLog("stat_info", "gumu_fuxiu", "item_proc", nPlayerId, nCount);
	return 1;
end
