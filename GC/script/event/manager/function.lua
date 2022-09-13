-------------------------------------------------------------------
--File: 	function.lua
--Author: 	sunduoliang
--Date: 	2008-4-15
--Describe:	活动管理系统.公用函数类
--InterFace1:InsertDialog(tbDialog, tbNpcDialog, nSort)	
--InterFace1:插入对话.把tbNpcDialog合并tbDialog,返回tbDialog,按nSort顺序插入,0为插到底端,1插到顶端;
--InterFace2:MergeDialog(tbDialogA, tbSelfClass)				
--InterFace2:合并对话.把自身npc类对话合并tbDialogA,返回tbDialogA
--InterFace3:CheckParam(tbParam) --检查限制参数条件,返回1表示条件不符合,返回0表示条件符合
--InterFace4:ExeParam(tbParam) 	 --执行参数
-------------------------------------------------------------------
Require("\\script\\event\\manager\\define.lua");

local tbFun = EventManager.tbFun;

local function fnStrValue(szVal)
	local varType = loadstring("return "..szVal)();
	if type(varType) == 'function' then
		return varType();
	else
		return varType;
	end
end

function tbFun:StrVal(szMsg)
	local szListText = "";
	if szMsg then
		szListText = string.gsub(szMsg, "<%%(.-)%%>", fnStrValue);
	end
	return szListText;
end

function tbFun:GetParam(tbPartParam, szPartParam, nFlag)
	--返回参数
	--nFlag不为空 预先读取，可能读取字段为空。不做错误判断
	local tbParam = {};
	if tbPartParam == nil then
		return tbParam;
	end
	for nParam, szParam in pairs(tbPartParam) do
		
		local nSit = string.find(szParam, ":");
		if nSit ~= nil then
			local szFlag = string.sub(szParam, 1, nSit - 1);
			local szContent = string.sub(szParam, nSit + 1, string.len(szParam));
			if szFlag == szPartParam then
				tbParam[#tbParam + 1] = szContent;
			end
		end
	end
	if #tbParam == 0 and nFlag == nil then
		print("【活动系统出错】 找不到该参数字段:",szPartParam);
	end
	return tbParam;
end

-- 获得Key和参数字符串
function tbFun:GetParamKey(szParam)
	local szFlag = nil;
	local szContent = nil;
	local nSit = string.find(szParam, ":");
	if nSit ~= nil then
		szFlag = string.sub(szParam, 1, nSit - 1);
		szContent = string.sub(szParam, nSit + 1, string.len(szParam));
	end
	return szFlag, szContent;
end

-- 读取所有的param并解析
function tbFun:GetParamEx(tbPartParam,nFlag)
	--返回参数
	--nFlag不为空 预先读取，可能读取字段为空。不做错误判断
	local tbParam = {};
	if tbPartParam == nil then
		return tbParam;
	end
	for nParam, szParam in pairs(tbPartParam) do		
		local nSit = string.find(szParam, ":");
		if nSit ~= nil then
			local szFlag = string.sub(szParam, 1, nSit - 1);
			local szContent = string.sub(szParam, nSit + 1, string.len(szParam));
			local t = self:SplitStr(szContent);
			tbParam[#tbParam + 1] = {szFlag,t};
		end
	end
	if #tbParam == 0 and nFlag == nil then
		print("【活动系统出错】 GetParamEx找不到该参数字段:",szPartParam);
	end
	return tbParam;
end

function tbFun:SplitStr(szParam)
	 if not szParam then
		 return {};
	 end
	 local nAssert = 0;
	 local t = {};
	 while self:SplitStrMatch(szParam) and nAssert < 100000 do
	    nAssert = nAssert + 1;
	    t[#t+1], szParam = self:SplitStrMatch(szParam)
	 end
     return t;
end

function tbFun:SplitStrMatch(szParam)
	szParam = string.gsub(szParam, "\\\"","<doublequ>");
	local nStart_n, nEnd_n, szRet_n, sz_n =  string.find(szParam, "(-?%d+)(.*)")
    local nStart_sz, nEnd_sz, szR_sz, sz_sz =  string.find(szParam, "(%b\"\")(.*)")
    if nStart_n and (nStart_sz and nStart_n < nStart_sz or not nStart_sz) then
    	return tonumber(szRet_n), sz_n
    else
    	if szR_sz then
    		szR_sz = string.gsub(szR_sz, "\"(.*)\"", "%1")
    		szR_sz = string.gsub(szR_sz,"<doublequ>", "\"");
    	end

    	return szR_sz, sz_sz
    end
end


function tbFun:GetSelfParam(szPartParam)
	--返回参数
	--nFlag不为空 预先读取，可能读取字段为空。不做错误判断
	local tbParam = {};
	if self.tbEventPart.tbParam == nil then
		return tbParam;
	end
	for nParam, szParam in pairs(self.tbEventPart.tbParam) do
		
		local nSit = string.find(szParam, ":");
		if nSit ~= nil then
			local szFlag = string.sub(szParam, 1, nSit - 1);
			local szContent = string.sub(szParam, nSit + 1, string.len(szParam));
			if szFlag == szPartParam then
				tbParam[#tbParam + 1] = szContent;
			end
		end
	end
	if #tbParam == 0 then
		print("【活动系统出错】 找不到该参数字段:",szPartParam);
	end
	return tbParam;
end

--插入对话
function tbFun:InsertDialog(tbDialog, tbNpcDialog, nSort, nType)
	if tbDialog == nil then
		tbDialog = {};
	end

	--如果该选项已存在则直接返回
	for nSelect, tbSelect in ipairs(tbDialog) do
		if tbSelect[1] == tbNpcDialog[1] and tbSelect[2] == tbNpcDialog[2] and tbSelect[3] == tbNpcDialog[3] then
			return tbDialog;
		end
	end
	local tbSelect = Lib:CopyTB1(tbNpcDialog)
	if nType and nType == 1 and tbNpcDialog[3] and tbNpcDialog[3].tbEventPart and tbNpcDialog[3].tbEventPart.tbParam then
		local nFlag, szMsg = EventManager.tbFun:CheckParam(tbSelect[3].tbEventPart.tbParam, 1);
		if nFlag and nFlag ~= 0 and nFlag ~= 2 then
			tbSelect[1] = self:SetGrayColor(tbSelect[1]);
		end		
	end
	
	if nSort == nil or nSort == 0 then
		table.insert(tbDialog, tbSelect);
	else
		table.insert(tbDialog, nSort, tbSelect);
	end
	
	return tbDialog;
end

--整合对话,活动系统使用,加入活动系统对话选项.
function tbFun:MergeDialog(tbDialogA, tbSelfClass)
	local nReturn = 0;
	local tbDialogB = tbSelfClass.tbEventDialog;
	if tbDialogB == nil then
		return nReturn;
	end
	for _, tbitem in ipairs(tbDialogB) do
		if tbitem[1] ~= EventManager.DIALOG_CLOSE and self:IsCheckEffect(tbitem[5]) == 1 then
			table.insert(tbDialogA, tbitem);
			nReturn = 1;
		end
	end
	return nReturn;
end

function tbFun:IsCheckEffect(tbItemEvent)
	local nSec = GetTime();
	if not tbItemEvent then
		return 1;
	end
	for _, tbTime in pairs(tbItemEvent) do
		if nSec >=tbTime[1] and (nSec < tbTime[2] or tbTime[2] == 0) then
			return 1;
		end
	end
	return 0;
end

function tbFun:SetGrayColor(szSelect)
	szSelect = string.gsub(szSelect, "<color=%a+>", "")
	szSelect = string.gsub(szSelect, "<color>", "")
	return string.format("<color=gray>%s<color>",szSelect);
end

--删除对话
function tbFun:DelDialog(tbDialog, tbNpcDialog)
	for nSelect, tbSelect in ipairs(tbDialog) do
		if tbSelect[2] == tbNpcDialog[2] and tbSelect[3] == tbNpcDialog[3] then
			table.remove(tbDialog, nSelect);
		end
	end

	if #tbDialog == 1 and tbDialog[1][1] == EventManager.DIALOG_CLOSE then
		table.remove(tbDialog, 1);
	end
	
	return tbDialog;
end

--预先加载
function tbFun:LoadTxtAward()
	self.AwardList = {};
	local tbParam = {};
	if (MODULE_GAMESERVER) then
		
	--tbParam = self:GetParam(tbPartParam, "AwardPath", 1);
	local tbAward = Lib:LoadTabFile(EventManager.EVENT_BASE_PATH.."eventaward.txt");
	if not tbAward then
		return 0;
	end
	
	for i, tbItem in pairs(tbAward) do
		if i >= 2 then
			local nId = tonumber(tbItem.Id);
			self.AwardList[nId] = self.AwardList[nId] or {tbAward = {}, tbMareial = {}, nMaxProb = 0};
			local nKind = tonumber(tbItem.Kind) or 0;
			local tbTemp = "tbMareial";
			if nKind ~= EventManager.AWARD_TYPE_MAREIAL then
				tbTemp = "tbAward";
			end
			local nCount = #self.AwardList[nId][tbTemp] + 1;
			self.AwardList[nId][tbTemp][nCount] = {};
			self.AwardList[nId][tbTemp][nCount].nJxMoney 		= tonumber(tbItem.JxMoney) or 0;
			self.AwardList[nId][tbTemp][nCount].nJxBindMoney 	= tonumber(tbItem.JxBindMoney) or 0;
			self.AwardList[nId][tbTemp][nCount].nJxCoin 		= tonumber(tbItem.JxCoin) or 0;
			self.AwardList[nId][tbTemp][nCount].nExp			= tonumber(tbItem.Exp) or 0;
			self.AwardList[nId][tbTemp][nCount].nExpBase 		= tonumber(tbItem.ExpBase) or 0;
			self.AwardList[nId][tbTemp][nCount].nGenre 			= tonumber(tbItem.Genre) or 0;
			self.AwardList[nId][tbTemp][nCount].nDetail 		= tonumber(tbItem.Detail) or 0;
			self.AwardList[nId][tbTemp][nCount].nParticular 	= tonumber(tbItem.Particular) or 0;
			self.AwardList[nId][tbTemp][nCount].nLevel 			= tonumber(tbItem.Level) or 1;
			self.AwardList[nId][tbTemp][nCount].nSeries 		= tonumber(tbItem.Series) or -1;
			self.AwardList[nId][tbTemp][nCount].nAmount 		= tonumber(tbItem.Amount) or 1;
			self.AwardList[nId][tbTemp][nCount].nRandRate 		= tonumber(tbItem.RandRate) or 0;
			self.AwardList[nId][tbTemp][nCount].nBind 			= tonumber(tbItem.Bind) or 0;
			self.AwardList[nId][tbTemp][nCount].szTimeLimit 	= self:ClearString(tbItem.TimeLimit);
			self.AwardList[nId][tbTemp][nCount].szName 			= self:ClearString(tbItem.Name);
			self.AwardList[nId][tbTemp][nCount].nAnnouce 		= tonumber(tbItem.Annouce) or 0;
			self.AwardList[nId][tbTemp][nCount].nFriendMsg 		= tonumber(tbItem.FriendMsg) or 0;
			self.AwardList[nId][tbTemp][nCount].nKinTongMsg 	= tonumber(tbItem.KinTongMsg) or 0;
			self.AwardList[nId][tbTemp][nCount].szDesc 			= self:ClearString(tbItem.Desc);
			self.AwardList[nId][tbTemp][nCount].nNeedBagFree 	= tonumber(tbItem.NeedBagFree) or 0;
			if nKind ~= EventManager.AWARD_TYPE_MAREIAL then
				self.AwardList[nId].nMaxProb = self.AwardList[nId].nMaxProb + self.AwardList[nId][tbTemp][nCount].nRandRate;
			end
		end
	end
	
	self.DropItemList = {};
	local tbDropItem = Lib:LoadTabFile(EventManager.EVENT_BASE_PATH.."eventdropitem.txt");
	if not tbDropItem then
		return 0;
	end
	
	for i,tbItem in pairs(tbDropItem) do
		if i >= 2 then
			local nId = tonumber(tbItem.Id);
			self.DropItemList[nId] = self.DropItemList[nId] or {nMaxProb = 1000000, tbItem = {}};
			local nCount = #self.DropItemList[nId].tbItem + 1;
			self.DropItemList[nId].tbItem[nCount] = {};
			self.DropItemList[nId].tbItem[nCount].nGenre 		= tonumber(tbItem.Genre) or 0;
			self.DropItemList[nId].tbItem[nCount].nDetail 		= tonumber(tbItem.Detail) or 0;
			self.DropItemList[nId].tbItem[nCount].nParticular 	= tonumber(tbItem.Particular) or 0;
			self.DropItemList[nId].tbItem[nCount].nLevel 		= tonumber(tbItem.Level) or 1;
			self.DropItemList[nId].tbItem[nCount].nSeries 		= tonumber(tbItem.Series) or 0;
			self.DropItemList[nId].tbItem[nCount].nRandRate 	= tonumber(tbItem.RandRate) or 0;
			self.DropItemList[nId].tbItem[nCount].szName 		= tbItem.Name or "";
			--self.DropItemList[nId].nMaxProb = self.DropItemList[nId].nMaxProb + self.DropItemList[nId].tbItem[nCount].nRandRate;
		end
	end	
	
	end
	
	self.CallNpcList = {};
	local tbCallNpcList = Lib:LoadTabFile(EventManager.EVENT_BASE_PATH.."eventcallnpc.txt");
	if not tbCallNpcList then
		return 0;
	end
	
	for i, tbItem in pairs(tbCallNpcList) do
		if i >= 2 then
			local nId = tonumber(tbItem.Id);
			self.CallNpcList[nId] = self.CallNpcList[nId] or {nMaxProb = 0, tbNpc = {}};
			local nCount = #self.CallNpcList[nId].tbNpc + 1;
			self.CallNpcList[nId].tbNpc[nCount] = {};
			self.CallNpcList[nId].tbNpc[nCount].nLevel 		= tonumber(tbItem.Level) or 1;
			self.CallNpcList[nId].tbNpc[nCount].nRandRate 	= tonumber(tbItem.RandRate) or 0;
			self.CallNpcList[nId].tbNpc[nCount].szName 		= self:ClearString(tbItem.Name);
			self.CallNpcList[nId].tbNpc[nCount].szAnnouce 	= self:ClearString(tbItem.AnnouceContent);
			self.CallNpcList[nId].tbNpc[nCount].nMapId 		= tonumber(tbItem.MapId) or 0;
			self.CallNpcList[nId].tbNpc[nCount].nPosX 		= tonumber(tbItem.PosX) or 0;
			self.CallNpcList[nId].tbNpc[nCount].nPosY 		= tonumber(tbItem.PosY) or 0;
			self.CallNpcList[nId].tbNpc[nCount].nSeries 	= tonumber(tbItem.Series) or -1;
			self.CallNpcList[nId].tbNpc[nCount].nNpcId	 	= tonumber(tbItem.NpcId) or 0;
			self.CallNpcList[nId].nMaxProb = self.CallNpcList[nId].nMaxProb + self.CallNpcList[nId].tbNpc[nCount].nRandRate;
		end
	end	
	
	return 0;
end

--时间判断
function tbFun:DateFormat(nStartDate, nEndDate)
		if tonumber(nStartDate) or nStartDate == "" then
			nStartDate = tonumber(nStartDate);
		else
			local tbStr = Lib:SplitStr(nStartDate, "/");
			if #tbStr == 3 then
				local szYear = tbStr[1];
				local szMonth = self:Date2NumFormat(tbStr[2]);
				local szDay = self:Date2NumFormat(tbStr[3]);
				nStartDate = string.format("%s%s%s0000", tostring(szYear), tostring(szMonth), tostring(szDay));
			elseif #tbStr == 5 then
				local szYear = tbStr[1];
				local szMonth = self:Date2NumFormat(tbStr[2]);
				local szDay = self:Date2NumFormat(tbStr[3]);
				local szHour = self:Date2NumFormat(tbStr[4]);
				local szMin = self:Date2NumFormat(tbStr[5]);
				nStartDate = string.format("%s%s%s%s%s", tostring(szYear), tostring(szMonth), tostring(szDay), tostring(szHour), tostring(szMin));
			else
				print("【活动系统出错】时间格式出错:", nStartDate);
				return 1,nil;
			end
			nStartDate = tonumber(nStartDate);
		end	
		
		if tonumber(nEndDate) or nEndDate == "" then
			nEndDate = tonumber(nEndDate);
		else
			local tbStr = Lib:SplitStr(nEndDate, "/");
			if #tbStr == 3 then 
				local szYear = tbStr[1];
				local szMonth = self:Date2NumFormat(tbStr[2]);
				local szDay = self:Date2NumFormat(tbStr[3]);
				nEndDate = string.format("%s%s%s2400", tostring(szYear), tostring(szMonth), tostring(szDay));
			elseif #tbStr == 5 then
				local szYear = tbStr[1];
				local szMonth = self:Date2NumFormat(tbStr[2]);
				local szDay = self:Date2NumFormat(tbStr[3]);
				local szHour = self:Date2NumFormat(tbStr[4]);
				local szMin = self:Date2NumFormat(tbStr[5]);				
				nEndDate = string.format("%s%s%s%s%s", tostring(szYear), tostring(szMonth), tostring(szDay), tostring(szHour), tostring(szMin));
			else
				print("【活动系统出错】时间格式出错:", nEndDate);
				return 1,nil;
			end
			nEndDate = tonumber(nEndDate);
		end
		
		if nStartDate == nil or nEndDate == nil then
				print("【活动系统出错】时间格式出错:", nStartDate, nEndDate);
				return 1,nil;
		end
		return nStartDate, nEndDate;
end

function tbFun:Date2NumFormat(szStr)
	local szTip = szStr;
	if tonumber(szStr) < 10 then
		szTip = "0"..tonumber(szStr)
	end
	return szTip;
end

--判断一个TableA里面是否存在和tableParam一样的项,如果存在返回 1,否则返回0
function tbFun:CheckTableEqual(tableA, tableParam)
	for _, nItem in pairs(tableA) do
		local nFlag = 0;
		local nSum = 0;
		for n, nItem2 in pairs(tableParam) do
			nSum = nSum + 1;
			if nItem[n] == nItem2 then
				nFlag = nFlag + 1;
			end
		end
		if nFlag == nSum and nFlag ~= 0 then
			return 1;
		end
	end
	return 0;
end

--把带有""的字符串的""号去掉
function tbFun:ClearString(szParam)
	if szParam == nil then
		szParam = "";
	end
	if string.len(szParam) > 1 then
		local nSit = string.find(szParam, "\"");
		if nSit ~= nil and nSit == 1 then
			local szFlag = string.sub(szParam, 2, string.len(szParam));
			local szLast = string.sub(szParam, string.len(szParam), string.len(szParam));
			szParam = szFlag;
			if szLast == "\"" then
				szParam = string.sub(szParam, 1, string.len(szParam)-1);
			end
		end
	end
	
	szParam = string.gsub(szParam, "\\\"","<doublequ>");
	--szParam = string.gsub(szParam, "\"\"", "\"");
	szParam = string.gsub(szParam, "<doublequ>","\\\"");

	return szParam;
end

function tbFun:Date2Time(nDate)
	local nDateTemp = nDate;
	local nMin = math.mod(nDateTemp, 100);
	local nHour= math.mod(math.floor(nDateTemp/100), 100);
	local nDay = math.mod(math.floor(nDateTemp/10000),100);
	local nMon = math.mod(math.floor(nDateTemp/1000000),100);
	local nYear = math.mod(math.floor(nDateTemp/100000000),10000);
	local tbData = {year=nYear, month=nMon, day=nDay, hour=nHour, min=nMin};
	local nSec = Lib:GetSecFromNowData(tbData)
	if nSec == nil then
		print("【活动系统出错】时间转换秒出错:", nDate);
	end
	return nSec;
end

function tbFun:TimerOutCheck(szParam)
	if szParam == nil then
		return 0;
	end
	if tonumber(szParam) ~= nil then
		if tonumber(szParam) > 0 then
			return 1;
		end
	else
		local nStartTime = self:DateFormat(szParam, 0);
		if nStartTime > 0 then
			return 1;
		end
	end
	return 0;
end

function tbFun:CheckItemClassEventIsEffect(szClass, nType)
	local nEffect = 0;
	if nType == 1 then
		local tbClass = EventManager:GetItemClass(szClass);
		
		for nEventId, tbPart in pairs(tbClass) do
			for nPartId, tbEvent in pairs(tbPart) do
				if self:CheckItemPartEventIsEffect(tbEvent) == 1 then
					nEffect = 1;
					break;	
				end
			end
		end
	end
	
	if nType == 2 then
		local tbClass = EventManager:GetItemIdClass(szClass);
		for nEventId, tbPart in pairs(tbClass) do
			for nPartId, tbEvent in pairs(tbPart) do
				if self:CheckItemPartEventIsEffect(tbEvent) == 1 then
					nEffect = 1;
					break;	
				end
			end
		end
	end	
	return nEffect;
end

function tbFun:CheckItemPartEventIsEffect(tbEvent)
	local tbParam = {};
	tbParam[1] = string.format("CheckGDate:%s,%s",tbEvent.tbEventPart.nStartDate, tbEvent.tbEventPart.nEndDate);
	local nFlag, szMsg = EventManager.tbFun:CheckParam(tbParam, 2);
	if not nFlag or nFlag == 0 then
		return 1;
	end
	return 0;
end

function tbFun:LoadTabFile(szFile, tbNumColName)
	local szFile = KIo.ReadTxtFile(szFile)
	szFile = string.gsub(szFile, "\r\n", "\n");
	local tbFile = Lib:SplitStr(szFile, "\n");
	local tbData = {};
	for nId, szData in ipairs(tbFile) do
		if szData and szData ~= "" then
			local tbS = Lib:SplitStr(szData, "\t");
			if #tbS > 0 then
				table.insert(tbData, tbS);
			end
		end
	end

	tbNumColName	= tbNumColName or {};
	local tbColName	= tbData[1];
	tbData[1]	= nil;
	local tbRet	= {};
	for nRow, tbDataRow in pairs(tbData) do
		local tbRow	= {}
		tbRet[nRow - 1]	= tbRow;
		for nCol, szName in pairs(tbColName) do
			if (tbNumColName[szName]) then
				tbRow[szName]	= tonumber(tbDataRow[nCol]) or 0;
			else
				tbRow[szName]	= tbDataRow[nCol];
			end
		end;
	end;

	return tbRet;	
end

tbFun:LoadTxtAward();

--时间轴要求的时间比现在的时间比较，比现在时间长返回1，否则返回0
function tbFun:CheckTimeFrameEx(szData)
	local tbData = Lib:SplitStr(szData, ":");
	local nStartSever = tonumber(KGblTask.SCGetDbTaskInt(DBTASD_SERVER_STARTTIME));
	local nNowDate = GetTime();	
	if nNowDate - nStartSever < (tonumber(tbData[1]) - 1) * 3600 *24 + tonumber(tbData[2])/100 * 3600 then
		return 1;
	end
	return 0;
end

function tbFun:CheckTime(szData)
	if szData == "" or szData == nil then
		return 0,0;
	end
	local tb = Lib:SplitStr(szData, "/");
	local tbData1 = Lib:SplitStr(tb[1], ":");
	local tbData2 = Lib:SplitStr(tb[2], ":");
	local nStartSever = tonumber(KGblTask.SCGetDbTaskInt(DBTASD_SERVER_STARTTIME));
	local nNowDate = GetTime();
	local nTime1 = 0;
	local nTime2 = 0;
	if tonumber(tbData1[1]) ~= 0 and self:CheckTimeFrameEx(tb[1]) == 1 then
		nTime1 =  nStartSever + (tonumber(tbData1[1]) - 1) * 86400 + tonumber(tbData1[2])/100 * 3600  - nNowDate;		
		if nTime1 < EventManager.TIME_MAX_MAINTAIN then
			return 1, nTime1;
		end
		return 1, 0;
	elseif tonumber(tbData2[1]) ~= 0 and self:CheckTimeFrameEx(tb[2]) == 0 then
		return 2, 0;
	end
	if tonumber(tbData2[1]) == 0 then
		return 0, 0;
	end
	nTime2 = nStartSever + (tonumber(tbData2[1]) - 1) * 86400 + tonumber(tbData2[2])/100 * 3600  - nNowDate;
	if nTime2 < EventManager.TIME_MAX_MAINTAIN then
		return 0, nTime2;
	end
	return 0, 0;	
end

--
--参数类别:具体参看\setting\event\manager\readme\

