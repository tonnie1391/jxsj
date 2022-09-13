-------------------------------------------------------
-- 文件名　：qingren_2011_gs.lua
-- 创建者　：zhangjinpin@kingsoft
-- 创建时间：2011-01-06 17:43:34
-- 文件描述：
-------------------------------------------------------

if not MODULE_GAMESERVER then
	return;
end

Require("\\script\\event\\jieri\\201102_qingren\\qingren_2011_def.lua");

local tbQingren_2011 = SpecialEvent.Qingren_2011;

-- buffer
function tbQingren_2011:LoadBuffer_GS()
	local tbBuffer = GetGblIntBuf(GBLINTBUF_QINGREN2011, 0);
	if tbBuffer and type(tbBuffer) == "table" then
		self.tbBuffer = tbBuffer;
	end
end

-- point
function tbQingren_2011:AddPoint(pPlayer, nPoint)
	if not pPlayer or not nPoint then
		return 0;
	end
	local nTmpPoint = pPlayer.GetTask(self.TASK_GID, self.TASK_POINT) + nPoint;
	pPlayer.SetTask(self.TASK_GID, self.TASK_POINT, nTmpPoint);
	GCExcute({"SpecialEvent.Qingren_2011:UpdateBuffer_GC", pPlayer.szName, nTmpPoint});
end

-- 是否可以送玫瑰花
function tbQingren_2011:CheckSendRose(pSender, pReciver)
	
	if not pSender or not pReciver then
		return 0;
	end
	
	if pSender.nMapId == 255 or pReciver.nMapId == 255 then
		return 0;
	end
	
	if self:CheckIsOpen() ~= 1 then
		Dialog:Say("对不起，活动已经结束，无法再赠送玫瑰花。您可将其卖给商人。");
		return 0;
	end
	
	-- 同性
	if pSender.nSex == pReciver.nSex then
		Dialog:Say("你太幽默了，还是把礼物送给异性吧。");
		return 0;
	end
	
	-- 未满60级
	if pReciver.nLevel < 60 then
		Dialog:Say("你的送礼对象太小了，必须找达到60级的玩家才能赠送哦。");
		return 0;
	end
	
	-- 未加入门派
	if pSender.nFaction <= 0 then
		Dialog:Say("你还没加入门派哟。");
		return 0;
	end
	
	if pReciver.nFaction <= 0 then
		Dialog:Say("你的送礼对象还没加入门派哟。");
		return 0;
	end
	
	-- 送过此门派
	local nFlag = 0;	
	local nFliter = self.SEX_FLITER[me.nSex];
	for _, tbLine in ipairs(tbQingren_2011.TASK_FACTION) do
		for _, tbTaskId in ipairs(tbLine) do
			if tbTaskId[1] ~= nFliter then
				if me.GetTask(self.TASK_GID, tbTaskId[1]) == 1 then
					if tbTaskId[1] == pReciver.nFaction then
						Dialog:Say("爱神卡里已经有了这个门派了，还是另觅良缘吧。");
						return 0;
					end
					nFlag = nFlag + 1;
				end
			end
		end
	end
	
	-- 集齐11个门派
	if nFlag >= self.MAX_FACTION then
		Dialog:Say("你的爱神卡已经全部点亮了，无需再送了。");
		return 0;
	end
	
	-- 被送过5次
	if pReciver.GetTask(self.TASK_GID, self.TASK_RECV_TIMES) >= self.MAX_RECV_TIMES then
		Dialog:Say("你的朋友太受欢迎了，已被赠送了5束玫瑰，还是另作选择吧。");
		return 0;
	end
	
	-- 间隔未到
	local nIntelval = pReciver.GetTask(self.TASK_GID, self.TASK_RECV_INTERVAL);
	if GetTime() - nIntelval <= self.MIN_RECV_INTERVAL then
		Dialog:Say("你的朋友太受欢迎了，刚刚接受过鲜花，请过一会儿再送吧。");
		return 0;
	end
		
	return 1;
end

-- 赠送玫瑰
function tbQingren_2011:SendRose(pSender, pReciver, dwItemId)
	
	if self:CheckSendRose(pSender, pReciver) ~= 1 then
		return 0;
	end
	
	-- 没卡册发一个
	if me.GetTask(self.TASK_GID, self.TASK_GET_CARD) ~= 1 then
		if me.CountFreeBagCell() < 1 then
			Dialog:Say("请留出1格背包空间。");
			return 0;
		end
		local pItem = me.AddItem(unpack(self.CARD_ID));
		if pItem then
			local nSec = Lib:GetDate2Time(20110222);
			pItem.SetTimeOut(0, nSec);
			pItem.Sync();
			me.SetTask(self.TASK_GID, self.TASK_GET_CARD, 1);
		end
	end
	
	local nFliter = self.SEX_FLITER[me.nSex];
	for _, tbLine in ipairs(tbQingren_2011.TASK_FACTION) do
		for _, tbTaskId in ipairs(tbLine) do
			if tbTaskId[1] ~= nFliter then
				if tbTaskId[1] == pReciver.nFaction and me.GetTask(self.TASK_GID, tbTaskId[1]) == 0 then
					me.SetTask(self.TASK_GID, tbTaskId[1], 1);
					break;
				end
			end
		end
	end
	
	-- point
	local nFavor = pSender.GetFriendFavor(pReciver.szName);
	if nFavor > 0 then
		self:AddPoint(pSender, nFavor);
		Dialog:SendBlackBoardMsg(pSender, "成功送出玫瑰，您<color=yellow>点亮<color>了爱神卡上的1个门派，累积了亲密度点数");
	else
		Dialog:SendBlackBoardMsg(pSender, "成功送出玫瑰，您<color=yellow>点亮<color>了爱神卡上的1个门派");
	end
	
	-- item
	local pItem = KItem.GetObjById(dwItemId);
	if pItem then
		pItem.Delete(pSender);
	end
	
	pReciver.AddBindCoin(100);
	Dialog:SendBlackBoardMsg(pReciver, string.format("<color=green>[%s]<color>送给您一束盛开的玫瑰，您获得<color=yellow>100绑定金币<color>。", pSender.szName));
	pReciver.SetTask(self.TASK_GID, self.TASK_RECV_TIMES, pReciver.GetTask(self.TASK_GID, self.TASK_RECV_TIMES) + 1);
	pReciver.SetTask(self.TASK_GID, self.TASK_RECV_INTERVAL, GetTime());
	
	-- log
	StatLog:WriteStatLog("stat_info", "chunjie2011", "lover", pSender.nId, pReciver.nFaction, pReciver.szAccount, pReciver.szName);
	Dbg:WriteLog("qingren_2011", "2011情人节", pSender.szAccount, pSender.szName, pReciver.szAccount, pReciver.szName, "赠送玫瑰花", string.format("增加积分：%s", nFavor));
end

function tbQingren_2011:OnNpcDialog()
	local szMsg = "在这深情的季节里，让爱神的祝福环绕着你。\n<color=green>活动日：<color><color=gold>2月12日-2月14日<color>\n<color=green>领奖日：<color><color=gold>2月15日-2月21日<color>\n请于活动日赠送玫瑰，被赠送的玩家可获得<color=yellow>绑金<color>。截止领奖日前积分排名前<color=yellow>100<color>的侠士还有机会参加<color=yellow>实物抽奖<color>！";
	local tbOpt = 
	{
		{"购买玫瑰花", self.BuyRose, self},
		{"查询排行榜", self.QueryBuffer, self},
		{"领取奖励", self.GetAward, self},
		{"Ta hiểu rồi"},
	};
	Dialog:Say(szMsg, tbOpt);
end

-- 查询排行榜
function tbQingren_2011:QueryBuffer(nFrom)
	if #self.tbBuffer <= 0 then
		Dialog:Say("对不起，排行榜中还没有任何记录。");
		return 0;
	end
	local szMsg = string.format("\n<color=cyan>%s%s%s<color>\n\n", Lib:StrFillL("", 4), Lib:StrFillL("姓名", 18), Lib:StrFillL("亲密点", 6));
	local tbOpt = {{"Ta hiểu rồi"}};
	local nCount = 8;
	local nLast = nFrom or 1;
	for i = nLast, #self.tbBuffer do
		szMsg = szMsg .. string.format("<color=cyan>%s<color=yellow>%s%s<color>\n", 
			Lib:StrFillL(i..".", 4),
			Lib:StrFillL(self.tbBuffer[i].szPlayerName, 18),
			Lib:StrFillL(self.tbBuffer[i].nPoint, 6)
		);
		nCount = nCount - 1;
		nLast = nLast + 1;
		if nCount <= 0 and nLast < #self.tbBuffer then
			table.insert(tbOpt, 1, {"Trang sau", self.QueryBuffer, self, nLast});
			break;
		end
	end
	Dialog:Say(szMsg, tbOpt);
end

-- buy
function tbQingren_2011:BuyRose()
	if self:CheckIsOpen() ~= 1 then
		Dialog:Say("对不起，活动已经结束，无法再购买玫瑰花。");
		return 0;
	end
	if me.nLevel < 60 then
		Dialog:Say("你太小了，必须要达到60级才能购买玫瑰哦。");
		return 0;
	end
	if me.nFaction <= 0 then
		Dialog:Say("你还没加入门派哟。");
		return 0;
	end
	me.OpenShop(187, 1);
end

function tbQingren_2011:CheckAllFaction(pPlayer)
	local nCount = 0;	
	local nFliter = self.SEX_FLITER[pPlayer.nSex];
	for _, tbLine in ipairs(tbQingren_2011.TASK_FACTION) do
		for _, tbTaskId in ipairs(tbLine) do
			if tbTaskId[1] ~= nFliter then
				if pPlayer.GetTask(self.TASK_GID, tbTaskId[1]) == 1 then
					nCount = nCount + 1;
				end
			end
		end
	end
	if nCount >= self.MAX_FACTION then
		return 1;
	end
	return 0;
end

function tbQingren_2011:GetPlayerSort(pPlayer)
	for nIndex, tbInfo in ipairs(self.tbBuffer) do
		if tbInfo.szPlayerName == pPlayer.szName then
			return nIndex;
		end
	end
	return 0;
end

-- award
function tbQingren_2011:GetAward(nSure)
	
	if self:CheckIsOpen() ~= 2 then
		Dialog:Say("对不起，现在不是领奖时间，请稍后再来。\n<color=green>领奖日：<color><color=gold>2月15日-2月21日<color>");
		return 0;
	end

	if me.GetTask(self.TASK_GID, self.TASK_GET_AWARD) == 1 then
		Dialog:Say("对不起，你已经领取过奖励了。");
		return 0;
	end
	
	if self:CheckAllFaction(me) ~= 1 then
		Dialog:Say("对不起，你没有集齐卡册，无法领取任何奖励。");
		return 0;
	end
	
	if not nSure then
		local szMsg = "";
		local nSort = self:GetPlayerSort(me);
		if nSort == 1 then
			szMsg = "恭喜您，可以领取：\n<color=yellow>12玄1个、雪魂坐骑1匹、特殊称号、爱神宝箱1个<color>\n\n确定领取么？";
		elseif nSort > 0 and nSort <= 10 then
			szMsg = "恭喜您，可以领取：\n<color=yellow>10玄1个、爱神宝箱1个<color>\n\n确定领取么？";
		else
			szMsg = "恭喜您，可以领取：\n<color=yellow>爱神宝箱1个<color>\n\n确定领取么？";
		end
		local tbOpt =
		{
			{"我要领取", self.GetAward, self, 1},
			{"Để ta suy nghĩ thêm"},	
		};
		Dialog:Say(szMsg, tbOpt);
		return 0;
	end
	
	local nSort = self:GetPlayerSort(me);
	local nNeed = (nSort > 0 and nSort <= 10) and 3 or 1;
	if me.CountFreeBagCell() < nNeed then
		Dialog:Say(string.format("请留出%s格背包空间。", nNeed));
		return 0;
	end
	
	-- 宝箱
	me.AddItem(unpack(self.BOX_ID));
	
	local szMsg = string.format("%s在爱神的祝福活动中集满了爱神卡，获得了一个爱神宝箱！", me.szName);
	me.SendMsgToFriend(szMsg);

	-- 称号、12玄、10玄
	if nSort > 0 then
		if nSort == 1 then
			me.AddItem(unpack(self.XUAN12_ID));
			me.AddTitle(unpack(self.TITLE_ID));
			local pItem = me.AddItem(unpack(self.HORSE_ID));
			if pItem then
				local nSec = Lib:GetDate2Time(20110222);
				pItem.SetTimeOut(0, GetTime() + 3600 * 24 * 90);
				pItem.Sync();
			end
			local szMsg = string.format("%s在爱神的祝福活动中获得第1名，领取奖励：12玄1个、雪魂坐骑、特殊光环！", me.szName);
			KDialog.NewsMsg(1, Env.NEWSMSG_NORMAL, szMsg);
		elseif nSort <= 10 then
			me.AddItem(unpack(self.XUAN10_ID));
		end
	end
	
	me.SetTask(self.TASK_GID, self.TASK_GET_AWARD, 1);
	
	local tbFind = me.FindItemInAllPosition(unpack(self.CARD_ID));
	for _,tbItem in ipairs (tbFind) do
		tbItem.pItem.Delete(me);
	end
	
	-- log
	local nPoint = me.GetTask(self.TASK_GID, self.TASK_POINT);
	Dbg:WriteLog("qingren_2011", "2011情人节", me.szAccount, me.szName, "领取爱神卡奖励", string.format("排名：%s", nSort), string.format("积分：%s", nPoint));
end

-- 每日事件
function tbQingren_2011:DailyEvent_GS()
	me.SetTask(self.TASK_GID, self.TASK_RECV_TIMES, 0);
end

ServerEvent:RegisterServerStartFunc(SpecialEvent.Qingren_2011.LoadBuffer_GS, SpecialEvent.Qingren_2011);
PlayerSchemeEvent:RegisterGlobalDailyEvent({SpecialEvent.Qingren_2011.DailyEvent_GS, SpecialEvent.Qingren_2011});
