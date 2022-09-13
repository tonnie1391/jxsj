-- 文件名　：ladder_gs.lua
-- 创建者　：zhouchenfei
-- 创建时间：2008-03-19 22:10:21
----------------------------------
if (not MODULE_GAMESERVER) then
	return;
end

Require("\\script\\ladder\\define.lua")

if (not Ladder.tbLadderList) then
	Ladder.tbLadderList = {};
end

function Ladder:SetPlayerHonor(nPlayerId, nHonorId, nNewValue)
	GCExcute({"Ladder:gc_SyncPlayerHonor", nPlayerId, nHonorId, nNewValue});
end

function Ladder:gs_OnSyncPlayerHonor(nPlayerId, nHonorId, nNewValue)
	KGCPlayer.SetHonorTask(nPlayerId, nHonorId, nNewValue);
end

-- nMode = 1: 经典模式
-- nMode = 2: 列表模式
function Ladder:TranslateResult(tbPlayerList, nLadderType, nMode)
	--联赛信息解析
	local nClassLadderType, nClassType, nType, nNum = Ladder:GetClassByType(nLadderType);
	if (nClassLadderType == 0 and nClassType == Ladder.LADDER_CLASS_WLLS and nType ~= 3) or
	   (nClassLadderType == 0 and nClassType == Ladder.LADDER_CLASS_WLDH) then
		if nMode == 1 and tbPlayerList.tbLadder then
			for _, tbPlayer in pairs(tbPlayerList.tbLadder) do
				if string.sub(tbPlayer.szContext, 1, 14) ~= "<color=yellow>" then
					local tbContext = Lib:SplitStr(tbPlayer.szContext, "\n");
					local sztext = "  " .. Lib:StrFillL("Thành viên bang hộ",17) .. " võ lâm".."\n\n<color=yellow>";
					for _, szStr1 in ipairs(tbContext) do
						sztext = sztext .. "  ";
						local tbText = Lib:SplitStr(szStr1, "|");
						for nTextId, szStr2 in ipairs(tbText) do
							if nTextId == 1 then
								sztext = sztext .. Lib:StrFillL(szStr2, 17);
							else
								sztext = sztext .. szStr2;
							end
						end
						sztext = sztext .."\n";
					end
					tbPlayer.szContext = sztext;
				end
			end
		end
	elseif nClassLadderType == 0 and 
			nClassType == Ladder.LADDER_CLASS_LADDER and 
			nType == self.LADDER_TYPE_LADDER_ACTION and 
			nNum == self.LADDER_TYPE_LADDER_ACTION_XOYOGAME then -- 逍遥收集榜
		if tbPlayerList.tbLadder then
			for _, tbPlayer in pairs(tbPlayerList.tbLadder) do
				if nMode == 1 then
					local nPoints = tonumber(tbPlayer.szContext) or 0;
					local szContext, szTxt1 = XoyoGame.XoyoChallenge:GetLadderDesc(nPoints);
					tbPlayer.szContext = szContext
					tbPlayer.szTxt1 = szTxt1;
				end
				
				if nMode == 2 then
					tbPlayer.dwValue = XoyoGame.XoyoChallenge:Point2CardNum(tbPlayer.dwValue);
				end
			end
		end
	elseif nClassLadderType == 0 and 
			nClassType == Ladder.LADDER_CLASS_LADDER and 
			nType == self.LADDER_TYPE_LADDER_ACTION and 
			nNum == self.LADDER_TYPE_LADDER_ACTION_LADDER1 then -- 寒武遗迹
		if tbPlayerList.tbLadder then
			for _, tbPlayer in pairs(tbPlayerList.tbLadder) do
				if nMode == 1 then
					if not tbPlayer.szTxt1 then
						break;
					end
					local nPoints = tonumber(string.sub(tbPlayer.szTxt1, 1, string.len(tbPlayer.szTxt1) - string.len("分"))) or 0;
					local nGrade = math.floor(nPoints/10000);
					local nKillCount = math.fmod(nPoints, 10000);
					local szContext, szTxt1 = string.format("Điểm: %s cần để hạ gục %s\Nhấn vào danh sách để có thể tìm kiếm thứ hạng của mình và người chơi khác.", nGrade, nKillCount), string.format("%s phút", nGrade);
					tbPlayer.szContext = szContext;
					tbPlayer.szTxt1 = szTxt1;
				elseif nMode == 2 then
					tbPlayer.dwLadderKey = math.floor(tbPlayer.dwLadderKey/10000);
					tbPlayer.dwValue = math.floor(tbPlayer.dwValue/10000);
				end
			end
		end
	end
	return tbPlayerList;
end
	
function Ladder:OnApplyLadder(nLadderType, nLastSaveTime)
	if (nLadderType <= 0) then
		return;
	end
	
	if (not self.tbLadderList or not self.tbLadderList.nSaveTime) then
		return;
	end
	
	if (nLastSaveTime ~= self.tbLadderList.nSaveTime) then
		self:SyncLadderName();
		return;
	end
	
	local tbLadder, szName, szContext = GetShowLadder(nLadderType);
	if (not tbLadder or #tbLadder <= 0) then
		return;
	end
	local tbPlayerList 	= {};
	tbPlayerList.nLadderType	= nLadderType;
	tbPlayerList.szContext		= szContext;
	tbPlayerList.szName			= szName;
	tbPlayerList.tbLadder		= tbLadder;	
	me.CallClientScript({"Ladder:OnSyncLadder", self:TranslateResult(tbPlayerList, nLadderType, 1)});
end

function Ladder:OnApplyList(nLadderType, nPage)
	if (nLadderType <= 0) then
		return;
	end
	local _, nClass, nType, nNum = self:GetClassByType(nLadderType);
	-- 这里是特定为排行榜列表寻找指定的排行榜一段，20名为一段
	local nStart	= (nPage - 1) * 20 + 1;
	
	local tbLadder		= {};
	local nMaxLadder	= 0;
	if (self.LADDER_CLASS_WLLS == nClass and self.LADDER_TYPE_WLLS_HONOR ~= nType) then
		tbLadder, nMaxLadder = Wlls:GetLadderPart(nLadderType, nStart, 20);
	elseif (self.LADDER_CLASS_LADDER == nClass and self.LADDER_TYPE_LADDER_KINREPUTE == nType) then
		tbLadder, nMaxLadder = HomeLand:GetLadderPart(nLadderType, nStart, 20);
	elseif (self.LADDER_CLASS_LADDER == nClass and self.LADDER_TYPE_LADDER_EVENTPLANT == nType and self.LADDER_TYPE_LADDER_EVENTPLANT_CURTEAM == nNum) then
		tbLadder, nMaxLadder = NewEPlatForm:GetLadderPart(nLadderType, nStart, 20);
	else
		tbLadder = GetHonorLadderPart(nLadderType, nStart, 20);
	end

	if (not tbLadder or #tbLadder <= 0) then
		return ;
	end
	if (self.LADDER_CLASS_WLLS ~= nClass or self.LADDER_TYPE_WLLS_HONOR == nType) and not (self.LADDER_CLASS_LADDER == nClass and self.LADDER_TYPE_LADDER_KINREPUTE == nType)
	and not (self.LADDER_CLASS_LADDER == nClass and self.LADDER_TYPE_LADDER_EVENTPLANT == nType and self.LADDER_TYPE_LADDER_EVENTPLANT_CURTEAM == nNum) then
		nMaxLadder	= GetTotalLadderMaxNum(nLadderType);
	end	
	local _, _, szContext = GetShowLadder(nLadderType);
	local tbPlayerList = {};
	tbPlayerList.szContext		= szContext;
	tbPlayerList.nLadderType	= nLadderType;
	tbPlayerList.nPage			= nPage;
	tbPlayerList.tbLadder		= tbLadder;
	tbPlayerList.nMaxLadder		= nMaxLadder;	
	me.CallClientScript({"Ladder:OnSyncList", self:TranslateResult(tbPlayerList, nLadderType, 2)});
end

function Ladder:OnApplySearchResult(nLadderType, szName, nSearchType)
	if (nLadderType <= 0) then
		return;
	end
	
	if (not szName) then
		return;
	end
	local szDesc = szName;
	local nRank	= 0;
	local _, nClass, nType, nNum = self:GetClassByType(nLadderType);
	-- 这里是特定为排行榜列表寻找指定的排行榜一段，20名为一段
	if (self.LADDER_CLASS_WLLS == nClass and self.LADDER_TYPE_WLLS_HONOR ~= nType) then
		nRank	= Wlls:GetWllsLadderRankByName(nLadderType, szName, nSearchType);
	elseif (self.LADDER_CLASS_LADDER == nClass and self.LADDER_TYPE_LADDER_KINREPUTE == nType) then
		nRank, szDesc = HomeLand:GetLadderRankByPlayerName(nLadderType, szName, nSearchType);
	elseif (self.LADDER_CLASS_LADDER == nClass and self.LADDER_TYPE_LADDER_EVENTPLANT == nType and self.LADDER_TYPE_LADDER_EVENTPLANT_CURTEAM == nNum) then
		nRank, szDesc = NewEPlatForm:GetLadderRankByPlayerName(nLadderType, szName, nSearchType);
	else
		nRank	= GetTotalLadderRankByName(nLadderType, szName);
	end
	if (nRank <= 0) then
		Dialog:Say(string.format("Không tìm thấy thứ hạng của: %s", szDesc));
		return;
	end
	self:SearchLadderByRank(nLadderType, nRank - 1);
end

function Ladder:SearchLadderByRank(nLadderType, nRank)
	if (nLadderType <= 0) then
		return 0;
	end

	local _, nClass, nType, nNum = self:GetClassByType(nLadderType);
	local nPage		= math.floor(nRank / 20) + 1;
	local nStart	= (nPage - 1) * 20 + 1;
	
	local tbLadder		= {};
	local nMaxLadder	= 0;
	if (self.LADDER_CLASS_WLLS == nClass and self.LADDER_TYPE_WLLS_HONOR ~= nType) then
		tbLadder, nMaxLadder = Wlls:GetLadderPart(nLadderType, nStart, 20);
	elseif (self.LADDER_CLASS_LADDER == nClass and self.LADDER_TYPE_LADDER_KINREPUTE == nType) then
		tbLadder, nMaxLadder = HomeLand:GetLadderPart(nLadderType, nStart, 20);	
	elseif (self.LADDER_CLASS_LADDER == nClass and self.LADDER_TYPE_LADDER_EVENTPLANT == nType and self.LADDER_TYPE_LADDER_EVENTPLANT_CURTEAM == nNum) then
		tbLadder, nMaxLadder = NewEPlatForm:GetLadderPart(nLadderType, nStart, 20);	
	else
		tbLadder = GetHonorLadderPart(nLadderType, nStart, 20);
	end
	if (not tbLadder or #tbLadder <= 0) then
		return 0;
	end

	if (self.LADDER_CLASS_WLLS ~= nClass or self.LADDER_TYPE_WLLS_HONOR == nType) and not (self.LADDER_CLASS_LADDER == nClass and self.LADDER_TYPE_LADDER_KINREPUTE == nType) 
	and not (self.LADDER_CLASS_LADDER == nClass and self.LADDER_TYPE_LADDER_EVENTPLANT == nType and self.LADDER_TYPE_LADDER_EVENTPLANT_CURTEAM == nNum) then
		nMaxLadder	= GetTotalLadderMaxNum(nLadderType);
	end

	local nIndex		= math.fmod(nRank, 20) + 1;
	if (nIndex > #tbLadder) then
		return 0;
	end
	
	local tbPlayerList = {};
	tbPlayerList.nLadderType	= nLadderType;
	tbPlayerList.nPage			= nPage;
	tbPlayerList.tbLadder		= tbLadder;
	tbPlayerList.nMaxLadder		= nMaxLadder;
	local szName	= tbLadder[nIndex].szPlayerName;
	me.CallClientScript({"Ladder:OnSyncSearchResult", self:TranslateResult(tbPlayerList, nLadderType, 2), szName});
	return 1;
end

function Ladder:GetExContext(nClass, nType)
	local szTxt			= "";
	local tbSettting	= {};
	local nLadderType	= 0;
	if (self.LADDER_CLASS_WULIN == nClass and self.LADDER_TYPE_WULIN_HONOR_WULIN == nType) then
		tbSettting = PlayerHonor.tbHonorLevelInfo["wulin"];
		nLadderType	= self:GetType(0, self.LADDER_CLASS_WULIN, self.LADDER_TYPE_WULIN_HONOR_WULIN, 0);
	elseif (self.LADDER_CLASS_LINGXIU == nClass and self.LADDER_TYPE_LINGXIU_HONOR_LINGXIU == nType) then
		tbSettting = PlayerHonor.tbHonorLevelInfo["lingxiu"];
		nLadderType	= self:GetType(0, self.LADDER_CLASS_LINGXIU, self.LADDER_TYPE_LINGXIU_HONOR_LINGXIU, 0);
	elseif (self.LADDER_CLASS_MONEY == nClass and self.LADDER_TYPE_MONEY_HONOR_MONEY == nType) then
		tbSettting = PlayerHonor.tbHonorLevelInfo["money"];
		nLadderType	= self:GetType(0, self.LADDER_CLASS_MONEY, self.LADDER_TYPE_MONEY_HONOR_MONEY, 0);
	end
	if (not tbSettting.tbLevel) then
		return szTxt;
	end	
	
	for nLevel, tbInfo in ipairs(tbSettting.tbLevel) do
		local nRank 	= tbInfo.nMaxRank;
		local nHonor	= tbInfo.nMinValue;
		local tbDate	= GetHonorLadderInfoByRank(nLadderType, nRank);
		if (tbDate and tbDate.nHonor and tbDate.nHonor > 0) then
			if (nHonor < tbDate.nHonor) then
				nHonor = tbDate.nHonor;
			end
		end
		szTxt = string.format("%4d    <color=yellow>%10d<color>    <color=green>%10d<color> \n", nLevel, nRank, nHonor) .. szTxt;
	end
	szTxt = "Đánh giá    Xếp hạng thấp nhất    Điểm vinh dự thấp nhất\n" .. szTxt;
	return szTxt;
end

function Ladder:OnApplyAdvSearch(nClass, nType, nSmall, szLadderName)
	local szMsg = string.format("%s Tìm xếp hạng\n", szLadderName);
	szMsg = szMsg .. self:GetExContext(nClass, nType);
	local tbOpt = 
	{
		{"Xếp hạng khác", self.SearchPlayerByRank, self, me, nClass, nType, nSmall},
		{"Xếp hạng của tôi", self.SearchPlayerByName, self, me, nClass, nType, nSmall},
		{"Kết thúc đối thoại"},
	};
	if (self.LADDER_CLASS_LADDER == nClass and self.LADDER_TYPE_LADDER_KINREPUTE == nType)
	or (self.LADDER_CLASS_LADDER == nClass and self.LADDER_TYPE_LADDER_EVENTPLANT == nType and self.LADDER_TYPE_LADDER_EVENTPLANT_CURTEAM == nNum) then
		tbOpt = 
		{
			{"Xếp hạng khác", self.SearchKinReputeByRank, self, me, nClass, nType, nSmall},
			{"Xếp hạng của tôi", self.SearchKinReputebyName, self, me, nClass, nType, nSmall},
			{"Kết thúc đối thoại"},	
		};
	end
	if (self.LADDER_CLASS_WLLS == nClass and (self.LADDER_TYPE_WLLS_CUR_PRIMAY == nType or self.LADDER_TYPE_WLLS_CUR_ADV == nType)) then
		table.insert(tbOpt, 3, {"Kiểm tra chiến đội", self.SearchWllsLadderTeamByTeamName, self, me, nClass, nType, nSmall});
	end
	Dialog:Say(szMsg, tbOpt);
end

function Ladder:SearchPlayerByRank(pPlayer, nClass, nType, nSmall, nFlag, nRank)
	local szType = "Bảng xếp hạng";

	if not nFlag then
		Dialog:AskNumber(string.format("Nhập tên cần tìm %s：",szType), 10000, self.SearchPlayerByRank, self, pPlayer, nClass, nType, nSmall, 1);
		return
	end
	
	nRank = tonumber(nRank);
	--名字合法性检查
	if (type(nRank) ~= "number") then
		Dialog:Say(string.format("%s của bạn không hợp lệ.", szType));
		return 0;		
	end
	
	if (nRank <= 0) then
		Dialog:Say(string.format("%s của bạn phải lớn hơn 0.", szType));
		return 0;		
	end
	
	local nLadderType = self:GetType(0, nClass, nType, nSmall);
	if (self:SearchLadderByRank(nLadderType, nRank - 1) == 0) then
		Dialog:Say(string.format("Người chơi bạn tìm không tồn tại."));
		return 0;			
	end
end


function Ladder:SearchKinReputeByRank(pPlayer, nClass, nType, nSmall, nFlag, nRank)
	local szType = "Xếp hạng Gia tộc";
	if not nFlag then
		Dialog:AskNumber(string.format("Nhập tên cần tìm %s:",szType), 100000, self.SearchKinReputeByRank, self, pPlayer, nClass, nType, nSmall, 1);
		return
	end
	nRank = tonumber(nRank);
		--名字合法性检查
	if (type(nRank) ~= "number") then
		Dialog:Say(string.format("%s của bạn không hợp lệ", szType));
		return 0;		
	end
	
	if (nRank <= 0) then
		Dialog:Say(string.format("%s của bạn phải lớn hơn 0.", szType));
		return 0;		
	end
	
	local nLadderType = self:GetType(0, nClass, nType, nSmall);
	if (self:SearchLadderByRank(nLadderType, nRank - 1) == 0) then
		Dialog:Say(string.format("Gia tộc bạn tìm không tồn tại."));
		return 0;			
	end
end

function Ladder:SearchWllsLadderTeamByTeamName(pPlayer, nClass, nType, nSmall, nFlag, szText)
	local szType = "Tên đội";

	if not nFlag then
		Dialog:AskString(string.format("Xin vui lòng nhập %s:",szType), 16, self.SearchWllsLadderTeamByTeamName, self, pPlayer, nClass, nType, nSmall, 1);
		return
	end
	--名字合法性检查
	local nLen = GetNameShowLen(szText);
	if nLen < 4 or nLen > 16 then
		Dialog:Say(string.format("%s của bạn không đáp ứng đủ yêu cầu.", szType));
		return 0;
	end
	
	--是否允许的单词范围
	if KUnify.IsNameWordPass(szText) ~= 1 then
		Dialog:Say(string.format("%s của bạn chứa ký tự không hợp lệ.", szType));
		return 0;
	end
	
	--是否包含敏感字串
	if IsNamePass(szText) ~= 1 then
		Dialog:Say(string.format("%s của bạn tên nhân vật không hợp lệ.", szType));
		return 0;
	end
	local nLadderType = self:GetType(0, nClass, nType, nSmall);

	self:OnApplySearchResult(nLadderType, szText, self.SEARCHTYPE_WLLSTEAMNAME);
end

function Ladder:SearchPlayerByName(pPlayer, nClass, nType, nSmall, nFlag, szText)
	local szType = "Chọn tên người chơi";
	
	if not nFlag then
		Dialog:AskString(string.format("Xin vui lòng nhập %s:",szType), 16, self.SearchPlayerByName, self, pPlayer, nClass, nType, nSmall, 1);
		return
	end
	--名字合法性检查
	local nLen = GetNameShowLen(szText);
	if nLen < 4 or nLen > 16 then
		Dialog:Say(string.format("%s của bạn không đáp ứng yêu cầu.", szType));
		return 0;
	end
	
	--是否允许的单词范围
	if KUnify.IsNameWordPass(szText) ~= 1 then
		Dialog:Say(string.format("%s của bạn chứa ký tự bất hợp pháp.", szType));
		return 0;
	end
	
	--是否包含敏感字串
	if IsNamePass(szText) ~= 1 then
		Dialog:Say(string.format("%s của bạn không hợp lệ.", szType));
		return 0;
	end
	local nLadderType = self:GetType(0, nClass, nType, nSmall);

	self:OnApplySearchResult(nLadderType, szText, self.SEARCHTYPE_PLAYERNAME);

end

function Ladder:SearchKinReputebyName(pPlayer, nClass, nType, nSmall, nFlag, szText)
	local szType = "Chọn tên Gia tộc";
	if not nFlag then
		Dialog:AskString(string.format("Xin vui lòng nhập %s",szType), 16, self.SearchKinReputebyName, self, pPlayer, nClass, nType, nSmall, 1);
		return
	end
	--名字合法性检查
	local nLen = GetNameShowLen(szText);
	if nLen < 4 or nLen > 16 then
		Dialog:Say(string.format("%s của bạn không đáp ứng đủ yêu cầu.", szType));
		return 0;
	end
	
	--是否允许的单词范围
	if KUnify.IsNameWordPass(szText) ~= 1 then
		Dialog:Say(string.format("%s của bạn chứa ký tự bất hợp pháp.", szType));
		return 0;
	end
	
	--是否包含敏感字串
	if IsNamePass(szText) ~= 1 then
		Dialog:Say(string.format("%s của bạn không hợp lệ.", szType));
		return 0;
	end
	local nLadderType = self:GetType(0, nClass, nType, nSmall);

	self:OnApplySearchResult(nLadderType, szText, self.SEARCHTYPE_KINNAME);
end

function Ladder:GetType(nLadderType, nClass, nType, nNum3)
	if (nClass == 4 and nType == 3) then -- 因为不能移植联赛排行榜，所以干脆就做特殊处理
		nClass = 3;
	end
	if (7 == nClass and 4 == nType) then -- 战斗力排行榜中的等级排行榜沿用老的
		nClass	= 2;
		nType	= 1;
	end
	nLadderType = KLib.SetByte(nLadderType, 3, nClass);
	nLadderType = KLib.SetByte(nLadderType, 2, nType);
	nLadderType = KLib.SetByte(nLadderType, 1, nNum3);
	return nLadderType;
end

function Ladder:GetClassByType(nLadderType)
	local nClass 		= KLib.GetByte(nLadderType, 3);
	local nType 		= KLib.GetByte(nLadderType, 2);
	local nNum  		= KLib.GetByte(nLadderType, 1);
	local nClassType 	= nLadderType - nClass*2^16 - nType*2^8 - nNum;
	return nClassType, nClass, nType, nNum;
end

function Ladder:_PRINT(tbLadder, szContext)
	if (not tbLadder) then
		return;
	end
	print("---------------------------------");
	print("szContext = ", szContext);
	for key, value in pairs(tbLadder) do
		print(key);
		if (value) then
			for ke, pv in pairs(value) do
				print(ke, pv);
			end
		end
	end
	print("---------------------------------");
end

function Ladder:InitLadderName()
	local tbData		= Lib:LoadTabFile("\\setting\\player\\ladderid.txt");
	if (not tbData) then
		return;
	end
	local tbPList		= {};
	for _, tbRow in ipairs(tbData) do
		local nHugeId	= tonumber(tbRow.HUGE_ID);
		local tbHuge	= tbPList[nHugeId];
		if (not tbHuge) then
			tbHuge = {};
			tbPList[nHugeId] = tbHuge;
		end
		local nMidId 		= tonumber(tbRow.MID_ID);
		local nSmallId 		= tonumber(tbRow.SMALL_ID);
		local szLadderName	= tostring(tbRow.LADDER_NAME);
		local szUnit		= tostring(tbRow.LADDER_UNIT);
		local nMode			= tonumber(tbRow.SEARCHMOD);
		local nIsable		= tonumber(tbRow.ISABLE);
		
		if (not tbPList[nHugeId][nMidId]) then
			tbPList[nHugeId][nMidId] = {};
		end
		
		if (not tbPList[nHugeId][nMidId][nSmallId]) then
			tbPList[nHugeId][nMidId][nSmallId] = {};
		end
		tbPList[nHugeId][nMidId][nSmallId].szShowName	= szLadderName;
		tbPList[nHugeId][nMidId][nSmallId].nShowFlag	= 0;
		tbPList[nHugeId][nMidId][nSmallId].nIsable		= nIsable;
	
		if (0 == nSmallId) then
			tbPList[nHugeId][nMidId][nSmallId].nShowFlag	= 1;
		end	
		
	end
	self.tbLadderList.tbLadder = tbPList;
end

function Ladder:RefreshLadderName()
	local nNowTime	= GetTime();
	self.tbLadderList.nSaveTime	= nNowTime;
end

function Ladder:OnLogin()
	self:SyncLadderName();
end

function Ladder:SyncLadderName()
	local tbSendName	= {};
	local tbShowNameFlag= {};
	local tbPList = self.tbLadderList.tbLadder;
	for nHugeId, tbHugeList in pairs(tbPList) do
		for nMidId, tbMidList in pairs(tbHugeList) do
			for nSmallId, tbSmallList in pairs(tbMidList) do
				if (type(nSmallId) == "number" and nSmallId > 0) then
					local nLadderType		= self:GetType(0, nHugeId, nMidId, nSmallId);
					local szName			= GetShowLadderName(nLadderType);
					if (szName and string.len(szName) > 0 and tbSmallList.nIsable == 1) then
						local nType = Ladder:GetType(0, nHugeId, nMidId, nSmallId);
						tbShowNameFlag[#tbShowNameFlag + 1] = nType;
						if (tbSmallList.szShowName and tbSmallList.szShowName ~= szName) then
							tbSendName[nType] = szName;
						end
					end
				end
			end
		end
	end

	me.CallClientScript({"Ladder:OnSyncLadderName", tbSendName});	
	me.CallClientScript({"Ladder:OnSyncLadderNameShowFlag", tbShowNameFlag, self.tbLadderList.nSaveTime, 1});
end

function Ladder:ClearTotalLadderData(nLadderType,nDataClass, nDataType, bAddNew)
	ClearTotalLadderData(nLadderType,nDataClass, nDataType, bAddNew);
end

function Ladder:SearchEPlatReputeByRank(pPlayer, nClass, nType, nSmall, nFlag, nRank)
	local szType = "Xếp hạng Hội";
	if not nFlag then
		Dialog:AskNumber(string.format("Xin vui lòng nhập %s：",szType), 100000, self.SearchKinReputeByRank, self, pPlayer, nClass, nType, nSmall, 1);
		return
	end
	nRank = tonumber(nRank);
		--名字合法性检查
	if (type(nRank) ~= "number") then
		Dialog:Say(string.format("%s của bạn không đáp ứng đủ yêu cầu.", szType));
		return 0;		
	end
	
	if (nRank <= 0) then
		Dialog:Say(string.format("% của bạn phải lớn hơn 0.", szType));
		return 0;		
	end
	
	local nLadderType = self:GetType(0, nClass, nType, nSmall);
	if (self:SearchLadderByRank(nLadderType, nRank - 1) == 0) then
		Dialog:Say(string.format("%s của bạn không tồn tại."));
		return 0;			
	end
end

function Ladder:SearchEPlatReputebyName(pPlayer, nClass, nType, nSmall, nFlag, szText)
	local szType = "Xếp hạng Hội";
	if not nFlag then
		Dialog:AskString(string.format("Xin vui lòng nhập %s",szType), 16, self.SearchEPlatReputebyName, self, pPlayer, nClass, nType, nSmall, 1);
		return
	end
	--Ļؖۏרєݬө
	local nLen = GetNameShowLen(szText);
	if nLen < 4 or nLen > 16 then
		Dialog:Say(string.format("%s của bạn không đáp ứng đủ yêu cầu.", szType));
		return 0;
	end
	
	--ˇرՊѭքեՊ׶Χ
	if KUnify.IsNameWordPass(szText) ~= 1 then
		Dialog:Say(string.format("%s của bạn chứa ký tự bất hợp pháp.", szType));
		return 0;
	end
	
	--ˇرѼڬĴِؖԮ
	if IsNamePass(szText) ~= 1 then
		Dialog:Say(string.format("%s của bạn chứa ký tự nhạy cảm.", szType));
		return 0;
	end
	local nLadderType = self:GetType(0, nClass, nType, nSmall);

	self:OnApplySearchResult(nLadderType, szText, self.SEARCHTYPE_KINNAME);
end

Ladder:InitLadderName();
ServerEvent:RegisterServerStartFunc(Ladder.RefreshLadderName, Ladder);
PlayerEvent:RegisterGlobal("OnLoginOnly", Ladder.OnLogin, Ladder);

--?pl DoScript("\\script\\ladder\\ladder_gs.lua")
