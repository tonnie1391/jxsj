-- 文件名　：comcrystal.lua
-- 创建者　：jiazhenwei
-- 创建时间：2010-05-14 09:16:32
-- 描  述  ：越南6月合成结晶

--VN--
if  not MODULE_GAMESERVER then
	return;
end

Require("\\script\\event\\specialevent\\vn_201006\\comcrystal_def.lua");

SpecialEvent.tbComCrystal = SpecialEvent.tbComCrystal or {};
local tbComCrystal = SpecialEvent.tbComCrystal;

function tbComCrystal:ComCrystal(nFlag, nLevel)
	local szMsg = string.format("合成规则：\n  水晶裂片+煤+%s银两=1级水晶\n", self.nComMoney);
	for i = 1, 9 do
		szMsg = szMsg..string.format("  %s级水晶+煤+%s银两=%s级水晶 \n", i, self.nComMoney, i+1);
	end
	Dialog:OpenGift(szMsg, {"SpecialEvent.tbComCrystal:CheckGiftSwith"} ,{self.OnOpenGiftOk, self});
	if nFlag then
		me.CallClientScript({"SpecialEvent.tbComCrystal:AddItem", nLevel});
	else
		me.CallClientScript({"SpecialEvent.tbComCrystal:Refresh"});
	end
end

function tbComCrystal:OnOpenGiftOk(tbItemObj)
	local tbCrystalList = {};
	local nFlag, szMsg = self:ChechItem(tbItemObj, tbCrystalList);
	if (nFlag == 0) then
		me.Msg(szMsg or "存在不符合的物品或者数量超过限制!");
		me.CallClientScript({"SpecialEvent.tbComCrystal:Refresh"});
		return 0;
	end;
	-- 扣除物品
	for _, pItem in pairs(tbItemObj) do
		if me.DelItem(pItem[1], Player.emKLOSEITEM_CYSTAL_COMPOSE) ~= 1 then
			return 0;
		end
	end
	--扣钱
	me.CostMoney(self.nComMoney, 1);
	--扣煤
	me.ConsumeItemInBags2(1, self.tbLead[1], self.tbLead[2], self.tbLead[3], self.tbLead[4], nil, -1);
	--给合成的物品和奖励
	local nLevel = 0;
	for i, _ in pairs(tbCrystalList) do
		local nRate = Random(100);
		if nRate <= self.tbComRate[i] then
			me.Msg("恭喜您，水晶合成成功！");
			local pItem = me.AddItemEx(self.tbItem[1], self.tbItem[2], self.tbItem[3], i + 1, nil, Player.emKITEMLOG_TYPE_CYSTAL_COMPOSE);
			if pItem then
				nLevel = pItem.nLevel;				
				EventManager:WriteLog(string.format("[越南6月合成结晶]合成物品成功获得：%s", pItem.szName), me);
				me.PlayerLog(Log.emKPLAYERLOG_TYPE_JOINSPORT, string.format("[越南6月合成结晶]合成物品成功获得：%s", pItem.szName));
			end
		else
			me.Msg("很遗憾，水晶合成失败！");
			local pItem = me.AddItemEx(self.tbItem[1], self.tbItem[2], self.tbItem[3], 1, nil, Player.emKITEMLOG_TYPE_CYSTAL_COMPOSE);
			if pItem then
				nLevel = pItem.nLevel;				
				EventManager:WriteLog("[越南6月合成结晶]合成物品失败获得：水晶裂片", me);
				me.PlayerLog(Log.emKPLAYERLOG_TYPE_JOINSPORT, "[越南6月合成结晶]合成物品失败获得：水晶裂片");
			end
		end
	end
	me.CallClientScript({"SpecialEvent.tbComCrystal:Refresh"});
	Timer:Register(1, self.Open, self, nLevel);
	return 1;
end

function tbComCrystal:Open(nLevel)
	self:ComCrystal(1, nLevel);
	return 0;
end

--合水晶成功奖励
function tbComCrystal:GetAword(nNum)
	local pItemEx = nil;
	for _, tbAwordEx in ipairs(self.tbAword[nNum]) do
		local szLog = "[越南6月合成结晶]合成物品成功获得"
		if tbAwordEx[2] > 0 then
			for nNumOther = 1, tbAwordEx[2] do
				pItemEx = me.AddItem(unpack(tbAwordEx[1]));
				if pItemEx then
					pItemEx.SetTimeOut(0, GetTime() + 30* 24 * 3600);
					pItemEx.Sync();
				end
			end
			szLog = szLog..string.format("%s个%s,",tbAwordEx[2], pItemEx.szName);
		end
		
		if tbAwordEx[3] > 0 then
			me.Earn(tbAwordEx[3], 1);
			szLog = szLog..string.format("%s银两,",tbAwordEx[3]);
		end
		
		
		if tbAwordEx[4] > 0 then
			me.AddBindMoney(tbAwordEx[4]);
			szLog = szLog..string.format("%s绑定银两,",tbAwordEx[4]);
		end
		
		if tbAwordEx[5] > 0 then
			me.AddBindCoin(tbAwordEx[5]);
			szLog = szLog..string.format("%s绑定金币,",tbAwordEx[5]);
		end
		
		if tbAwordEx[6] > 0 and me.GetTask(self.TASKGID,self.TASK_GETEXPNUM) < self.nAwordExpMax then			
			me.AddExp(tbAwordEx[6]);
			me.SetTask(self.TASKGID,self.TASK_GETEXPNUM, me.GetTask(self.TASKGID,self.TASK_GETEXPNUM) + tbAwordEx[6]);
			szLog = szLog..string.format("%s经验,",tbAwordEx[6]);
		end		
		
		local nRateEx = Random(100);
		if nRateEx <= tbAwordEx[9] and tbAwordEx[8] > 0 then
			if nNum <= 10 then
				for nNumOther = 1, tbAwordEx[8] do
					pItemEx = me.AddItem(unpack(tbAwordEx[7]));
				end
				szLog = szLog..string.format("以及%s概率获得%s个%s,",tbAwordEx[9], tbAwordEx[8], pItemEx.szName);
			else
				if me.GetTask(self.TASKGID, self.TASK_ISGETHORSE) ~= 1 then
					GCExcute({"SpecialEvent.tbComCrystal:IsGetHorse", me.nId}); --有GC仲裁
				end
				szLog = nil;
			end
		end
		
		local nRateMask = Random(100);
		if nRateMask < 2 and nNum > 1 then
			local pItemMask = me.AddItem(unpack(self.tbMask));
			if pItemMask then
				pItemMask.SetTimeOut(0, GetTime() + 30* 24 * 3600);
				pItemMask.Sync();
				EventManager:WriteLog("[越南6月合成结晶]使用水晶获得世界杯面具", me);
				me.PlayerLog(Log.emKPLAYERLOG_TYPE_JOINSPORT, "[越南6月合成结晶]使用水晶获得世界杯面具");
			end
		end
		
--		if me.GetTask(tbComCrystal.TASKGID, tbComCrystal.TASK_GETMAXLEVELITEM) + 1 == self.nNumAwordHorse then
--			if me.GetTask(self.TASKGID, self.TASK_ISGETHORSE) ~= 1 then
--				GCExcute({"SpecialEvent.tbComCrystal:IsGetHorse", me.nId}); --有GC仲裁
--			end
--		end
		if szLog then
			EventManager:WriteLog(szLog, me);
			me.PlayerLog(Log.emKPLAYERLOG_TYPE_JOINSPORT, szLog);
		end
	end
end

-- 检测物品及数量是否符合
function tbComCrystal:ChechItem(tbItemObj, tbCrystalList)	
	if Lib:CountTB(tbItemObj) > 1 then
		return 0;
	end
	for _, pItem in pairs(tbItemObj) do		
		local szFollowCryStal 	= string.format("%s,%s,%s", unpack(self.tbItem));
		local szItem		= string.format("%s,%s,%s",pItem[1].nGenre, pItem[1].nDetail, pItem[1].nParticular);
		if szFollowCryStal ~= szItem then
			return 0;
		end;
		if pItem[1].nLevel >= 11 then
			return 0, "已经到最高级了，不能再合成了!";
		end
		
		tbCrystalList[pItem[1].nLevel] = 1;
	end
	local nNumCrystal = Lib:CountTB(tbCrystalList);
	if nNumCrystal ~= 1  then
		return 0;
	end
	
	--背包判断	
	if me.CountFreeBagCell() < 3 then		
		return 0, "请预留3格背包空间再来吧！";
	end
	
	--背包找煤
	local tbItem = me.FindItemInBags(unpack(self.tbLead));
	if #tbItem == 0 then		
		return 0, "请您确认您包裹里面是不是有煤！";
	end	
	
	--银两判断
	if me.nCashMoney <= self.nComMoney then
		return 0, string.format("您身上的银两不足%s两!", self.nComMoney);
	end
	return 1;
end;

function tbComCrystal:OnSpecialAward(nPlayerId)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		return;
	end	
	--领
	pPlayer.AddItem(unpack(self.tbHorse));
	pPlayer.SetTask(self.TASKGID, self.TASK_ISGETHORSE, 1);
	EventManager:WriteLog("[越南6月合成结晶]使用10级水晶获得120级马", pPlayer);
	pPlayer.PlayerLog(Log.emKPLAYERLOG_TYPE_JOINSPORT, "[越南6月合成结晶]使用10级水晶获得120级马");
	
end
