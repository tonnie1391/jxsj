-- 文件名　：gmitem.lua
-- 创建者　：furuilei
-- 创建时间：2010-01-29 11:16:29
-- 功能描述：结婚系统道具（gm到场道具）

local tbItem = Item:GetClass("marry_gmitem");

--===================================================

-- 结婚面具gdpl（用的是司仪面具）
tbItem.MASK_GDPL = {1, 13, 41, 1};

-- gm可以选择的祝福
tbItem.TB_ZHUFU = {
	[1] = "百年好合，五世其昌。",
	[2] = "龙腾凤翔，玉树琼枝。",
	[3] = "喜成连理，百年好合。",
	[4] = "笙磬同谐，心心相印。",
	[5] = "典礼大喜，百年好合。",
	[6] = "天赐良缘，百年好合。",
	[7] = "百年嘉偶，珠联璧合。",
	[8] = "情深意重，感天动地。",
	};

-- 撒钱技能的特效及范围
tbItem.SKILL_INFO = {nSkillId = 1559, nRange = 60, tbAddMoney = {1314, 5218, 6666, 8888, 9999, 16888, 18888, 25666, 27888}};
tbItem.INTERVAL = 20;

--===================================================

function tbItem:OnUse()
	local szMsg = "GM道具：GM可以凭借此道具执行一些特殊操作。";
	local tbOpt = {};
	table.insert(tbOpt, {"送上典礼祝福", self.SendZhufuDlg, self});
	table.insert(tbOpt, {"获得情花", self.GetQingHuaDlg, self});
	table.insert(tbOpt, {"给附近玩家撒钱", self.ThrowMoney, self});
	
	if (self:CheckGotMask(it.dwId) ~= 1) then
		table.insert(tbOpt, 1, {"获得典礼面具", self.GetWeddingMask, self, it.dwId});
	end
	table.insert(tbOpt, {"Kết thúc đối thoại"});
	
	Dialog:Say(szMsg, tbOpt);
end

--========================================================================

-- 检查是否已经领取过结婚面具
function tbItem:CheckGotMask(dwItemId)
	local bHasGotMask = 0;
	local pItem = KItem.GetObjById(dwItemId);
	if (pItem) then
		local tbItemDate = pItem.GetTempTable("Marry");
		if (tbItemDate and tbItemDate.bHasGotMask and tbItemDate.bHasGotMask == 1) then
			bHasGotMask = 1;
		end
	end
	return bHasGotMask;
end

-- 获取结婚面具
function tbItem:GetWeddingMask(dwItemId)
	local pItem = KItem.GetObjById(dwItemId);
	if (not pItem) then
		return 0;
	end
	
	if (me.CountFreeBagCell() < 1) then
		Dialog:Say("请清理出1格背包空间再来吧。");
		return 0;
	end
	
	me.AddItem(unpack(self.MASK_GDPL));
	local tbItemDate = pItem.GetTempTable("Marry");
	tbItemDate.bHasGotMask = 1;
	return 1;
end

--========================================================================
-- 送出祝福
function tbItem:SendZhufuDlg()
	local szMsg = "你可以从下面的祝福里面选择一条送给二位侠侣。";
	local tbOpt = {};
	for nIndex, szZhufuMsg in ipairs(self.TB_ZHUFU) do
		table.insert(tbOpt, {szZhufuMsg, self.SendZhufu, self, nIndex});
	end
	Dialog:Say(szMsg, tbOpt);
end

function tbItem:SendZhufu(nIndex)
	local szZhufuMsg = self.TB_ZHUFU[nIndex];
	if (not szZhufuMsg) then
		return 0;
	end
	
	szZhufuMsg = string.format("<color=orange>【GM：%s】<color>为二位侠侣送上祝福：%s", me.szName, szZhufuMsg);
	
	local tbPlayerList = Marry:GetAllPlayers(me.nMapId);
	for _, pPlayer in pairs(tbPlayerList or {}) do
		Dialog:SendInfoBoardMsg(pPlayer, szZhufuMsg);
	end
end

--========================================================================
-- 获得情花
function tbItem:GetQingHuaDlg()
	Dialog:AskNumber("请输入情花数量：", 10000, self.GetQingHua, self);
end

function tbItem:GetQingHua(nNum)
	if (not nNum or nNum <= 0) then
		Dialog:Say("您输入的数字有误，请重新输入。");
		return 0;
	end
	
	if (me.CountFreeBagCell() < 1) then
		Dialog:Say("请清理出1格背包空间再来吧。");
		return 0;
	end
	
	me.AddStackItem(Marry.ITEM_QINGHUA_ID[1], Marry.ITEM_QINGHUA_ID[2], Marry.ITEM_QINGHUA_ID[3],
		Marry.ITEM_QINGHUA_ID[4], {bForceBind = 1}, nNum);
	
	Dbg:WriteLog("Marry", "结婚系统", me.szName, me.szAccount, string.format("GM取出情花数量%s", nNum));
end

--========================================================================
-- 撒钱
function tbItem:ThrowMoney()
	local nTime = me.GetTask(Marry.TASK_GROUP_ID, Marry.TASK_GM_INTELVAL);
	if GetTime() - nTime < self.INTERVAL then
		me.Msg("每隔20秒才能使用一次发钱功能，请等等再试。");
		return 0;
	end
	me.SetTask(Marry.TASK_GROUP_ID, Marry.TASK_GM_INTELVAL, GetTime());
	me.CastSkill(self.SKILL_INFO.nSkillId, 1, -1, me.GetNpc().nIndex);
	local tbPlayerList = KPlayer.GetAroundPlayerList(me.nId, self.SKILL_INFO.nRange);
	local nSum = 0;
	local nAddMoney = 0;
	for _, pPlayer in pairs(tbPlayerList or {}) do
		if (pPlayer) then
			nAddMoney = self.SKILL_INFO.tbAddMoney[MathRandom(1, #self.SKILL_INFO.tbAddMoney)];
			pPlayer.AddBindMoney(nAddMoney, Player.emKBINDMONEY_ADD_MARRY);
			Dialog:SendBlackBoardMsg(pPlayer, string.format("恭喜您，获得GM发放的绑银：<color=yellow>%s两<color>", nAddMoney));
			nSum = nSum + nAddMoney;
		end
	end
	Dbg:WriteLog("Marry", "结婚系统", me.szName, me.szAccount, string.format("GM发放绑银：%s", nSum));
end
