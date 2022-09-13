-- 文件名　：dayplayerback_gs.lua
-- 创建者　：jiazhenwei
-- 创建时间：2012-07-02 14:58:22
-- 功能    ：日常回流

SpecialEvent.tbDayPlayerBack = SpecialEvent.tbDayPlayerBack or {};
local tbDayPlayerBack = SpecialEvent.tbDayPlayerBack or {};

function tbDayPlayerBack:CheckIsBackPlayer(pPlayer)
	local nLastTime = pPlayer.GetTask(2063,16);
	local nLoginTime = pPlayer.GetTask(2063,2);
	if pPlayer.nLevel < self.nLevelLimit then
		return 0, string.format("Ngươi nhỏ hơn cấp %s.", self.nLevelLimit);
	end
	if pPlayer.nFaction <= 0 then
		return 0, "Ngươi chưa gia nhập môn phái.";
	end
	if IpStatistics:CheckStudioRole(pPlayer) == 1 then
		return 0, "Ngươi không đủ điều kiện.";
	end
	if nLoginTime - nLastTime >= self.nTimeLimit and nLastTime > 0 then
		if tonumber(GetLocalDate("%Y%m%d")) >= self.tbChangeTime[1] and tonumber(GetLocalDate("%Y%m%d")) <= self.tbChangeTime[2] then 
			return math.floor((nLoginTime - nLastTime) / self.nTimeLimit * self.tbChangeTime[3]);
		else
			return math.floor((nLoginTime - nLastTime) / self.nTimeLimit);
		end
	end
	return 0, "Ngươi không đủ điều kiện.";
end

function tbDayPlayerBack:InitEventList()
	local tbFind = me.FindItemInAllPosition(unpack(self.tbLing));
	for _, tbItem in ipairs(tbFind) do
		tbItem.pItem.Delete(me);
	end
	for _, tb in ipairs(self.tbEventList)  do
		me.SetTask(self.TASK_GID, tb[4], 0);
		me.SetTask(self.TASK_GID, tb[5], 0);
	end
end

function tbDayPlayerBack:DoParam(szParam, nTaskId, nTaskGetTime, nIndex, nTaskIdEx, varValue, nFlag)
	local nRet, szErrorMsg = self:CheckIsBackPlayer(me);
	if nRet <= 0 then
		Dialog:Say(szErrorMsg or "Ngươi không đủ điều kiện để nhận thưởng.");
		return;
	end
	local nBatch = me.GetTask(self.TASK_GID, self.TASK_ID_BATCH);
	local nGetTime = me.GetTask(self.TASK_GID, nTaskGetTime);
	local nGetBatch = me.GetTask(self.TASK_GID, nTaskId);
	if nGetBatch == nBatch then
		Dialog:Say("Ngươi đã nhận thưởng rồi.");
		return;
	end
	if nIndex == 1 then	--征战江湖令需要提示覆盖操作
		if not nFlag and GetTime() - nGetTime < 30*24*3600 then
			Dialog:Say("Lệnh Chinh Chiến đợt trước vẫn chưa nhận thưởng. Nếu nhận lại sẽ mất hết phần thưởng. Bạn chắc chứ?", {{"Xác nhận", self.DoParam, self,szParam, nTaskId, nTaskGetTime, nIndex, nTaskIdEx, varValue,1},{"Để ta suy nghĩ lại"}});
			return;
		end
		self:InitEventList();
		me.SetTask(self.TASK_GID, self.TASK_RATE_BACK, nRet);
	end
	local nSit = string.find(szParam, ":");
	if nSit and nSit > 0 then
		local szFlag = string.sub(szParam, 1, nSit - 1);
		local szContent = string.sub(szParam, nSit + 1, string.len(szParam));
		if EventManager.tbFun.tbLimitParamFun[szFlag] ~= nil then
			local fncExcute = EventManager.tbFun[EventManager.tbFun.tbLimitParamFun[szFlag]];
			if fncExcute then
				local nFlag, szMsg = fncExcute(EventManager.tbFun, szContent);
				if nFlag and nFlag ~= 0 then--条件不符合.
					Dialog:Say(szMsg);
					return;
				end
			end
		end
		if EventManager.tbFun.tbExeParamFun[szFlag] ~= nil then
		local fncExcute = EventManager.tbFun[EventManager.tbFun.tbExeParamFun[szFlag]];
			if fncExcute then
				local nFlag, szMsg = fncExcute(EventManager.tbFun, szContent);
				if nFlag == 0 then
					me.SetTask(self.TASK_GID, nTaskId, nBatch);
					me.SetTask(self.TASK_GID, nTaskGetTime, GetTime());
					if self:CheckIsFinish() == 1 then
						me.CallClientScript({"UiManager:CloseWindow", "UI_AWORDONLINE_BACK"});
					end
					if nIndex == 7 and self.tbNameTreasure[nTaskIdEx] then
						me.Msg(string.format("Nhận được <color=yellow>%s<color> <color=yellow>%s<color>", varValue, self.tbNameTreasure[nTaskIdEx]));
					end
				end
			end
		end
	end
end

function tbDayPlayerBack:OnDialog()
	if GLOBAL_AGENT then
		return;
	end
	if GetMapType(me.nMapId) ~= "city" and GetMapType(me.nMapId) ~= "village" then
		Dialog:SendBlackBoardMsg(me, "Phần thưởng chỉ có thể nhận ở Thành Thị và Tân Thủ Thôn");
		return;
	end
	local nRet, szErrorMsg = self:CheckIsBackPlayer(me);
	if nRet <= 0 then
		Dialog:Say(szErrorMsg or "Ngươi không đủ điều kiện để nhận thưởng.");
		return;
	end
	local tbOpt = {};
	local nBatch = me.GetTask(self.TASK_GID, self.TASK_ID_BATCH);
	local nCount = 0;
	for i, tb in ipairs(self.tbAwardList) do
		if (not tb[5] or tonumber(GetLocalDate("%Y%m%d")) <= tb[5]) and (not tb[8] or tonumber(GetLocalDate("%Y%m%d")) >= tb[8]) then
			local nGetBatch = me.GetTask(self.TASK_GID, tb[6]);
			if nGetBatch ~= nBatch then
				local varValue = math.min(nRet * tb[2], tb[3]);
				if i == 1 then	--征战江湖令
					table.insert(tbOpt, {tb[1], self.DoParam, self, tb[4], tb[6], tb[7], i});
				elseif i == 7 then	--藏宝图令牌
					local nGroupId, nTaskId = TreasureMap2:GetTodayTaskID(me.nLevel);
					table.insert(tbOpt, {tb[1],  self.DoParam, self, string.format(tb[4], nGroupId, nTaskId, varValue), tb[6], tb[7], i, nTaskId, varValue});
				elseif i == 8 then	--侠客印鉴
					local nP = me.nSeries + 5;
					table.insert(tbOpt, {tb[1], self.DoParam, self, string.format(tb[4], nP, varValue), tb[6], tb[7],  i});
				else
					table.insert(tbOpt, {tb[1],  self.DoParam, self, string.format(tb[4], varValue), tb[6], tb[7],  i});
				end 
				nCount = nCount + 1;
			end
		end
	end
	table.insert(tbOpt, {"Để ta suy nghĩ lại"});
	if nCount > 0 then
		Dialog:Say("Hãy mang theo Lệnh bài khi tham gia các hoạt động để nhận được phần thưởng tăng tốc.", tbOpt);
	end
	return;
end

function tbDayPlayerBack:CheckIsFinish()
	local nBatch = me.GetTask(self.TASK_GID, self.TASK_ID_BATCH);
	for i, tb in ipairs(self.tbAwardList) do
		if (not tb[5] or tonumber(GetLocalDate("%Y%m%d")) <= tb[5]) and (not tb[8] or tonumber(GetLocalDate("%Y%m%d")) >= tb[8]) then
			local nGetBatch = me.GetTask(self.TASK_GID, tb[6]);
			if nBatch ~= nGetBatch then
				return 0;
			end
		end
	end
	return 1;
end

--玩家上线事件
function tbDayPlayerBack:PlayerLogIn()
	if (not GLOBAL_AGENT) then
		local nRet = self:CheckIsBackPlayer(me);
		local nBatch = me.GetTask(self.TASK_GID, self.TASK_ID_BATCH);
		local nGetTime = me.GetTask(self.TASK_GID, self.TASK_TIME_BATCH);
		local bGetFinish = self:CheckIsFinish();
		if nRet > 0 and GetTime() - nGetTime > 24*3600 then
			me.SetTask(self.TASK_GID, self.TASK_ID_BATCH, nBatch + 1);
			me.SetTask(self.TASK_GID, self.TASK_TIME_BATCH, GetTime());
			me.AddTitle(5, 3, 1, 6);
			me.SetCurTitle(5, 3, 1, 6);
			local nLastTime = me.GetTask(2063,16);
			local nLoginTime = me.GetTask(2063,2);
			StatLog:WriteStatLog("stat_info", "roleback", "back", me.nId, math.ceil((nLoginTime - nLastTime) / 24/3600));
			local szMail = "  Vì đại hiệp đã mai danh ẩn tích đã lâu, nên hệ thống gửi tặng đại hiệp Túi quà đẹp để tiếp tục du hành Kiếm Thế.\n\nHãy nhấp vào Túi quà đẹp trên giao diện để nhận: Thời gian luyện công, phiếu giảm giá,... Đặc biệt là Lệnh Chinh Chiến Giang Hồ giúp tăng phần thưởng hoạt động.\n<color=red>Lưu ý: Trong vòng 24h, Túi quà đẹp sẽ biến mất, hãy nhận càng sớm càng tốt.<color>";
			KPlayer.SendMail(me.szName, "Túi quà đẹp", szMail);
			Dialog:SendBlackBoardMsg(me, "Chúc mừng bạn nhận được Túi quà đẹp. Xem thư để biết chi tiết.");
			me.CallClientScript({"UiManager:OpenWindow", "UI_AWORDONLINE_BACK"});
		end
		if nRet > 0 and GetTime() - nGetTime <= 24*3600 and bGetFinish == 0 then
			me.CallClientScript({"UiManager:OpenWindow", "UI_AWORDONLINE_BACK"});
		end
	end
end

PlayerEvent:RegisterOnLoginEvent(SpecialEvent.tbDayPlayerBack.PlayerLogIn, SpecialEvent.tbDayPlayerBack)
--PlayerEvent:RegisterGlobal("OnLogin", SpecialEvent.tbDayPlayerBack.PlayerLogIn, SpecialEvent.tbDayPlayerBack);
