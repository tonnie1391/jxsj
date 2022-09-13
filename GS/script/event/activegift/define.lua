-- 文件名　：define.lua
-- 创建者　：jiazhenwei
-- 创建时间：2011-11-01 09:20:06
-- 功能    ：

SpecialEvent.ActiveGift = SpecialEvent.ActiveGift or {};
local ActiveGift = SpecialEvent.ActiveGift;

ActiveGift.nOpen		= 1;		--开关

ActiveGift.nMaxMonthActive	= 2000;	--最大累计1310点活跃度
ActiveGift.nMaxActiveGrade	= 150;		--最大累计75点活跃度

ActiveGift.nTaskGroupId		= 2182;	--任务组
ActiveGift.nActiveTime 		= 5000;	--记录每天累计的时间
ActiveGift.nActiveGrade		= 5001;	--记录每天累计的活跃度
ActiveGift.nMonthActiveTime 	= 5002;	--记录月累计的时间
ActiveGift.nMonthActiveGrade	= 5003;	--记录月累计的活跃度
ActiveGift.nActiveAwardTime 	= 5004;	--记录领取活跃度的日期
ActiveGift.nActiveAwardNum	= 5005;	--记录领取活跃度的奖励
ActiveGift.nMonthAwardTime	= 5006;	--记录领取月累计的时间
ActiveGift.nMonthAwardNum 	= 5007;	--记录领取月累计的奖励


ActiveGift.tbNameWeek = {[1] = "Thứ Hai", [2] = "Thứ Ba", [3] = "Thứ Tư", [4] = "Thứ Năm", [5] = "Thứ Sáu", [6] = "Thứ Bảy", [7] = "Chủ Nhật", };
ActiveGift.szFileName 		= "\\setting\\event\\activegift\\activegift.txt";			--活跃度表
ActiveGift.szActiveAwardFile	= "\\setting\\event\\activegift\\activeaward.txt";		--活跃度奖励表
ActiveGift.szMonthAwardFile	= "\\setting\\event\\activegift\\monthaward.txt";		--月累计奖励表

ActiveGift.tbAwardName = {[3] = "Bạch Ngân Bảo Rương", [4] = "Hoàng Kim Bảo Rương", [5] = "Phỉ Thúy Bảo Rương"};
--数据表
ActiveGift.tbActiveInfo = ActiveGift.tbActiveInfo or {};				--活跃度信息
ActiveGift.tbActiveAward = ActiveGift.tbActiveAward or {};	--活跃度奖励表
ActiveGift.tbMonthAward = ActiveGift.tbMonthAward or {};			--活跃度每月奖励



function ActiveGift:LoadActiveFile()
	local tbInfo = Lib:LoadTabFile(self.szFileName);
	if not tbInfo then
		print("File không tồn tại:"..self.szFileName);
		return;
	end
	for nRow, tbRowData in pairs(tbInfo) do
		local tbTemp = {};
		tbTemp.nActiveId		= tonumber(tbRowData["nActiveId"]) or 0;
		tbTemp.nSubId			= tonumber(tbRowData["nSubId"]) or 0;
		tbTemp.nMaxCount		= tonumber(tbRowData["nMaxCount"]) or 0;			
		tbTemp.tbWeek			= self:SplitTable(tbRowData["nWeek"]);
		tbTemp.nDownLevel		= tonumber(tbRowData["nDownLevel"]) or 0;	
		tbTemp.nUpLevel		= tonumber(tbRowData["nUpLevel"]) or 0;
		tbTemp.nTimerFrame	= tonumber(tbRowData["nTimerFrame"]) or 0;
		tbTemp.szInfo			= tostring(tbRowData["szInfo"]) or "";
		tbTemp.szName		= tostring(tbRowData["szName"]) or "";
		tbTemp.nGrade			= tonumber(tbRowData["nGrade"]) or 0;
		tbTemp.bOneOff		= tonumber(tbRowData["bOneOff"]) or 0;
		tbTemp.Unable		= tonumber(tbRowData["unable"]) or 0;
		self.tbActiveInfo[nRow] 	= tbTemp;
	end
end

function ActiveGift:LoadActiveAwardFile()	
	local tbInfo = Lib:LoadTabFile(self.szActiveAwardFile);
	if not tbInfo then
		print("File không tồn tại:"..self.szActiveAwardFile);
		return;
	end
	for nRow, tbRowData in pairs(tbInfo) do		
		local nId			= tonumber(tbRowData.nId) or 0;
		local nActive		= tonumber(tbRowData.nActive) or 0;
		local szInfor		= tostring(tbRowData.szInfor) or "";
		self.tbActiveAward[nRow] = self.tbActiveAward[nRow] or {};
		self.tbActiveAward[nRow].nActive = nActive;
		self.tbActiveAward[nRow].szInfor = szInfor;
		local tbParam = {};
		for i =1, 15 do
			local szAward = tbRowData["nParam"..i];
			if szAward and szAward ~= "" then
				local szType, Value = self:GetSplitValue(szAward);			
				table.insert(tbParam, {szType, Value});
			end
		end
		self.tbActiveAward[nRow].tbParam = tbParam;
	end
end

function ActiveGift:LoadMonthAwardFile()
	local tbInfo = Lib:LoadTabFile(self.szMonthAwardFile);
	if not tbInfo then
		print("File không tồn tại:"..self.szMonthAwardFile);
		return;
	end
	for nRow, tbRowData in pairs(tbInfo) do		
		local nId		= tonumber(tbRowData.nId) or 0;
		local nActive		= tonumber(tbRowData.nActive) or 0;
		local szInfor	= tostring(tbRowData.szInfor) or "";
		self.tbMonthAward[nRow] = self.tbMonthAward[nRow] or {};
		self.tbMonthAward[nRow].nActive = nActive;
		self.tbMonthAward[nRow].szInfor = szInfor;
		local tbParam = {};
		for i =1, 15 do
			local szAward = tbRowData["nParam"..i];
			if szAward and szAward ~= "" then
				local szType, Value = self:GetSplitValue(szAward);
				table.insert(tbParam, {szType, Value});
			end
		end
		self.tbMonthAward[nRow].tbParam = tbParam;
	end
end

--检查活跃度条件
function ActiveGift:CheckCanAddActive(nId)
	local tbActive = self.tbActiveInfo[nId];
	if not tbActive then
		return 0, "Hoạt động này không tồn tại";
	end
	if tbActive.Unable > 0 then
		return -1, "Bỏ";
	end
	local nNowDate = tonumber(GetLocalDate("%Y%m%d"));
	local nDate = me.GetTask(self.nTaskGroupId, tbActive.nActiveId);
	local nTimes = me.GetTask(self.nTaskGroupId, tbActive.nSubId);
	if nNowDate == nDate and nTimes  >= tbActive.nMaxCount then		
		return 2, "Đã hoàn thành";
	end
	if me.nLevel > tbActive.nDownLevel and tbActive.nDownLevel > 0 then		
		return 0, "Cấp độ lớn hơn"..tbActive.nDownLevel.."cấp";
	end
	if me.nLevel < tbActive.nUpLevel and tbActive.nUpLevel > 0 then		
		return 0, "cấp độ không đủ"..tbActive.nUpLevel.."cấp";
	end
	local nNowWeek = tonumber(GetLocalDate("%w"));
	if nNowWeek == 0 then
		nNowWeek = 7;
	end
	local nFlagWeek = 0;
	local szWeekErrorMsg =  "Thời gian"
	for _, nWeek in pairs(tbActive.tbWeek) do
		if nWeek > 0 and nWeek == nNowWeek then
			nFlagWeek = 1;
		elseif nWeek > 0 then			
			szWeekErrorMsg = szWeekErrorMsg .. self.tbNameWeek[nWeek];
		end 
	end
	if #tbActive.tbWeek <= 0 then
		nFlagWeek = 1;
	end
	szWeekErrorMsg = szWeekErrorMsg;
	if  nFlagWeek == 0 then
		return 0, szWeekErrorMsg;
	end
	if TimeFrame:GetServerOpenDay() < tbActive.nTimerFrame and tbActive.nTimerFrame > 0 then
		return 0, "Thiếu các server mở"..tbActive.nTimerFrame.."ngày"
	end
	return 1;
end

--获得自定义奖励类型
function ActiveGift:GetCustomItem(pPlayer, value)
	local nFaction = pPlayer.nFaction;
	local nRoute = pPlayer.nRouteId;
	local nSex = pPlayer.nSex;
	nFaction = math.max(nFaction, 1);
	nRoute = math.max(nRoute, 1);
	if not Task.tbCustomEquip[value] or not Task.tbCustomEquip[value][nFaction] or 
	not Task.tbCustomEquip[value][nFaction][nRoute] or not Task.tbCustomEquip[value][nFaction][nRoute][nSex] then
		return;
	end
	return Task.tbCustomEquip[value][nFaction][nRoute][nSex];
end

function ActiveGift:GetActiveNum()
	local nNowDate = tonumber(GetLocalDate("%Y%m%d"));
	local nDate = me.GetTask(self.nTaskGroupId, self.nActiveTime);
	local nTotalGrade = me.GetTask(self.nTaskGroupId, self.nActiveGrade);
	if nDate ~= nNowDate then
		nTotalGrade = 0;
	end
	return nTotalGrade;
end

function ActiveGift:GetMonthActive()
	local nMonth = me.GetTask(self.nTaskGroupId, self.nMonthActiveTime);
	local nMonthActiveGrade = me.GetTask(self.nTaskGroupId, self.nMonthActiveGrade);
	local nNowMonth = tonumber(GetLocalDate("%m"));
	if nMonth ~= nNowMonth then
		nMonthActiveGrade = 0;
	end
	return nMonthActiveGrade;
end

function ActiveGift:CheckCanGetAward(nType, nId)
	if nType == 1 then		--检查活跃度
		local nAwardTimes = me.GetTask(self.nTaskGroupId, self.nActiveAwardTime);
		local nGetIndex = me.GetTask(self.nTaskGroupId, self.nActiveAwardNum);
		local nNowDate = tonumber(GetLocalDate("%Y%m%d"));
		if nNowDate ~= nAwardTimes then
			nGetIndex = 0;
		end
		local nDate = me.GetTask(self.nTaskGroupId, self.nActiveTime);
		local nTotalGrade = me.GetTask(self.nTaskGroupId, self.nActiveGrade);
		if nDate ~= nNowDate then
			nTotalGrade = 0;
		end
		if not self.tbActiveAward[nId] then
			return 0, "Không tồn tại giải thưởng"
		end
		if self:CheckBit(nGetIndex, nId) then
			return 0, "Bạn được nhận giải thưởng này"
		end
		if self.tbActiveAward[nId].nActive > nTotalGrade then
			return 0, "Năng động chưa đạt <color=yellow>"..self.tbActiveAward[nId].nActive.."<color>điểm";
		end
	else		
		local nMonth = me.GetTask(self.nTaskGroupId, self.nMonthActiveTime);
		local nMonthActiveGrade = me.GetTask(self.nTaskGroupId, self.nMonthActiveGrade);
		local nNowMonth = tonumber(GetLocalDate("%m"));
		if nMonth ~= nNowMonth then
			nMonthActiveGrade = 0;
		end
		local nAwardMTime = me.GetTask(self.nTaskGroupId, self.nMonthAwardTime);
		local nGetIndex = me.GetTask(self.nTaskGroupId, self.nMonthAwardNum);
		if nAwardMTime ~= nNowMonth then
			nGetIndex = 0;
		end
		if not self.tbMonthAward[nId] then
			return 0, "Không tồn tại giải thưởng";
		end
		if self:CheckBit(nGetIndex, nId) then
			return 0, "Bạn được nhận giải thưởng này"
		end
		if self.tbMonthAward[nId].nActive > nMonthActiveGrade then
			return 0, "Năng động tháng chưa đạt <color=yellow>"..self.tbMonthAward[nId].nActive.."<color> điểm.";
		end
	end
	return 1;
end

function ActiveGift:CheckBit(nIndex, nId)
	return math.fmod(nIndex, math.pow(10, nId)) >= math.pow(10, nId - 1);
end

function ActiveGift:GetSplitValue(szStr)
	szStr = Lib:ClearStrQuote(szStr);
	local nSit = string.find(szStr, "=");
	if nSit ~= nil then
		local szFlag = string.sub(szStr, 1, nSit - 1);
		local szContent = string.sub(szStr, nSit + 1, string.len(szStr));
		if tonumber(szContent) then
			return szFlag, tonumber(szContent);
		elseif szFlag == "titlename" then	--titlename特殊处理
			return szFlag, szContent;
		end
		local tbLit = Lib:SplitStr(szContent, ",");
		for nId, nNum in ipairs(tbLit) do
			tbLit[nId] = tonumber(nNum);
		end
		return szFlag, tbLit;
	end
	return "", "";
end

function ActiveGift:SplitTable(szTable)
	local tbType = Lib:SplitStr(szTable);
	local tb = {};
	for i, nInfo in ipairs(tbType) do
		if nInfo ~= "" then
			table.insert(tb, tonumber(nInfo) or 0);
		end
	end
	return tb;
end

if not MODULE_GC_SERVER then
	ActiveGift:LoadActiveFile();
	ActiveGift:LoadActiveAwardFile();
	ActiveGift:LoadMonthAwardFile();
end
