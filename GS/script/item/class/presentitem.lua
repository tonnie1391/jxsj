-------------------------------------------------------------------
-- 文件名　：presentitem.lua
-- 创建者　：zounan
-- 创建时间：2010-04-26 16:39:28
-- 描  述  ：礼包通用脚本
--第一个扩展参数代表[道具礼包]表中的第几组
-------------------------------------------------------------------

local tbItem = Item:GetClass("presentitem");
local SZITEMFILE = "\\setting\\item\\001\\other\\presentitem.txt";

function tbItem:CheckItem(pItem, pPlayer, tbitem)	
	if tbitem.nBindMoney ~= 0 and		
	   pPlayer.GetBindMoney() + tbitem.nBindMoney > pPlayer.GetMaxCarryMoney() then
		return 0, "您身上的绑定银两将达上限，请先整理身上的绑定银两。";
	end
	
	if tbitem.nMoney ~= 0 and
	   pPlayer.nCashMoney + tbitem.nMoney > pPlayer.GetMaxCarryMoney() then
		return 0, "您身上的银两将达上限，请先整理身上的银两。";
	end
	
	if tbitem.nGenre ~= 0 and tbitem.nDetailType ~= 0 and tbitem.nParticularType ~= 0 then		
		local tbItemInfo = {};
		local nNumber = tonumber(tbitem.szTimeLimit);
		tbItemInfo.bTimeOut = 1;	
		if nNumber then
			if nNumber == 0 then
				tbItemInfo.bTimeOut = nil;		
			elseif nNumber < 0 then
				local nItemTimeType, nItemTimeOut = pItem.GetTimeOut();
				if nItemTimeType == 0 and nItemTimeOut == 0 then
					tbItemInfo.bTimeOut = nil;
				end
			end
		end
		
		if tbitem.nBind > 0 then
			tbItemInfo.bForceBind = tbitem.nBind;
		end
		local nFreeCount = KItem.GetNeedFreeBag(tbitem.nGenre, tbitem.nDetailType, tbitem.nParticularType, tbitem.nLevel, tbItemInfo, tbitem.nAmount);
		if pPlayer.CountFreeBagCell() < nFreeCount then
			return 0,string.format("需要%s格背包空间,请先清理一下背包空间吧。",nFreeCount);
		end	
	end
	return 1;
end

function tbItem:GetItem(pItem, pPlayer, tbitem)
	if tbitem.nBindMoney ~= 0 then
		pPlayer.AddBindMoney(tbitem.nBindMoney, Player.emKBINDMONEY_ADD_PRESENTITEM);
		local szAnnouce = string.format("恭喜您获得了<color=yellow>%s<color>绑定银两", tbitem.nBindMoney);
		pPlayer.Msg(szAnnouce);
		KStatLog.ModifyAdd("bindjxb", "[产出]"..(tbitem.szDesc or "未知箱子"), "总量", tbitem.nBindMoney);
	end
	if tbitem.nMoney ~= 0 then
		local nAddMoney = pPlayer.Earn(tbitem.nMoney, Player.emKEARN_PRESENT_ITEM);
		local szAnnouce = string.format("恭喜您获得了<color=yellow>%s<color>两", tbitem.nMoney);
		pPlayer.Msg(szAnnouce);
		if nAddMoney == 1 then
			Dbg:WriteLog("[道具礼包]获得物品",  pPlayer.szName,  string.format("[道具礼包]获得了%s银两", tbitem.nMoney));
			KStatLog.ModifyAdd("jxb", "[产出]"..(tbitem.szDesc or "未知箱子"), "总量", tbitem.nMoney);
		else
			Dbg:WriteLog("[道具礼包]获得物品",  pPlayer.szName,  string.format("银两达到上限,[道具礼包]获得了%s银两失败", tbitem.nMoney));
		end
	end
	if tbitem.nCoin ~= 0 then
		local nAddCoin = pPlayer.AddBindCoin(tbitem.nCoin, Player.emKBINDCOIN_ADD_PRESENT_ITEM); -- 只会加绑金
		local szAnnouce = string.format("恭喜您获得了<color=yellow>%s<color>绑定%s", tbitem.nCoin, IVER_g_szCoinName);
		pPlayer.Msg(szAnnouce);
		if nAddCoin == 1 then
			KStatLog.ModifyAdd("bindcoin", "[产出]"..(tbitem.szDesc or "未知箱子"), "总量", tbitem.nCoin);
			Dbg:WriteLog("[道具礼包]获得物品",  pPlayer.szName,  string.format("[道具礼包]获得了%s绑定%s", tbitem.nCoin, IVER_g_szCoinName));
		else
			Dbg:WriteLog("[道具礼包]获得物品",  pPlayer.szName,  string.format("绑定%s达到上限,[道具礼包]获得了%s绑定%s失败", IVER_g_szCoinName, tbitem.nCoin, IVER_g_szCoinName));
		end
	end
	if tbitem.nGenre ~= 0 and tbitem.nDetailType ~= 0 and tbitem.nParticularType ~= 0 then
		local nCount = tonumber(tbitem.nAmount) or 1;		
		-- by zhangjinpin@kingsoft
		local tbItemInfo = {};
		tbItemInfo.nSeries = tbitem.nSeries;
		tbItemInfo.nEnhTimes = tbitem.nEnhTimes;

		local nItemTime = tonumber(tbitem.szTimeLimit);
		local nItemTimeType, nItemTimeOut = pItem.GetTimeOut();
		tbItemInfo.bTimeOut = 1;
		if nItemTime then
			if nItemTime == 0 then
				tbItemInfo.bTimeOut = nil;		
			elseif nItemTime < 0 then
				if nItemTimeType == 0 and nItemTimeOut == 0 then
					tbItemInfo.bTimeOut = nil;
				end
			end
		end		
		
		
		if tbitem.nBind > 0 then
			tbItemInfo.bForceBind = tbitem.nBind;
		end
		
		-- 道具产出途径，默认是活动产出，但如果道具礼包是从奇珍阁买出的，则开出的道具也要算奇珍阁产出
		local eItemAddWay = Player.emKITEMLOG_TYPE_JOINEVENT;
		if (pItem.IsIbItem() == 1) then
			eItemAddWay = 4;
		end
		
		if tbItemInfo.bTimeOut ~= 1 then
			local nAddCount = pPlayer.AddStackItem(tbitem.nGenre, tbitem.nDetailType, tbitem.nParticularType, tbitem.nLevel, tbItemInfo, nCount, eItemAddWay);
			if nAddCount > 0 then
				local szAnnouce = string.format("恭喜您获得了<color=yellow>%s<color>", tbitem.szName);
				pPlayer.Msg(szAnnouce);
				Dbg:WriteLog("[道具礼包]获得物品",  pPlayer.szName, string.format("[道具礼包]获得物品%s", tbitem.szName));
			else
				local szMsg = string.format("[道具礼包]获得物品失败，物品ID：%s,%s,%s", tbitem.nGenre, tbitem.nDetailType, tbitem.nParticularType);
				Dbg:WriteLog("[道具礼包]获得物品",  pPlayer.szName, szMsg);
				return 0;
			end
		else
			for i= 1, nCount do				
				local pItemEx = pPlayer.AddItemEx(tbitem.nGenre, tbitem.nDetailType, tbitem.nParticularType, tbitem.nLevel, tbItemInfo, eItemAddWay);
				if pItemEx then		
					if nItemTime and nItemTime < 0 then
						pItemEx.SetTimeOut(nItemTimeType, nItemTimeOut);
						pItemEx.Sync();
					elseif tbitem.szTimeLimit ~= "" then
						self:LimitTime(pPlayer, tbitem.szTimeLimit, pItemEx);
					end
					local szAnnouce = string.format("恭喜您获得了<color=yellow>%s<color>", pItemEx.szName);
					pPlayer.Msg(szAnnouce);
					Dbg:WriteLog("[道具礼包]获得物品",  pPlayer.szName, string.format("[道具礼包]获得物品%s", pItemEx.szName));
				else
					local szMsg = string.format("[道具礼包]获得物品失败，物品ID：%s,%s,%s", tbitem.nGenre, tbitem.nDetailType, tbitem.nParticularType);
					Dbg:WriteLog("[道具礼包]获得物品",  pPlayer.szName, szMsg);
					return 0;
				end
			end
		end
		-- end
	end
	
	if tbitem.nExp ~= 0 then
		pPlayer.AddExp(tbitem.nExp)
		local szAnnouce = string.format("恭喜您获得了<color=yellow>%s<color>经验",tbitem.nExp);
		pPlayer.Msg(szAnnouce);
		Dbg:WriteLog("[道具礼包]获得物品",  pPlayer.szName, string.format("[道具礼包]获得了%s经验", tbitem.nExp));
	end
	
	if tbitem.nBaseExp ~= 0 then
		pPlayer.AddExp(me.GetBaseAwardExp() * tbitem.nBaseExp);
		local szAnnouce = string.format("恭喜您获得了<color=yellow>%s<color>经验", me.GetBaseAwardExp() * tbitem.nBaseExp);
		pPlayer.Msg(szAnnouce);
		Dbg:WriteLog("[道具礼包]获得物品",  pPlayer.szName, string.format("[道具礼包]获得了%s经验", me.GetBaseAwardExp() * tbitem.nBaseExp));
	end
		
	if tbitem.nMKP ~= 0 then
		pPlayer.ChangeCurMakePoint(tbitem.nMKP)
		local szAnnouce = string.format("恭喜您获得了<color=yellow>%s<color>精力",tbitem.nMKP);
		pPlayer.Msg(szAnnouce);
		Dbg:WriteLog("[道具礼包]获得物品",  pPlayer.szName, string.format("[道具礼包]获得了%s精力", tbitem.nMKP));
	end
	
	if tbitem.nGTP ~= 0 then
		pPlayer.ChangeCurGatherPoint(tbitem.nGTP)
		local szAnnouce = string.format("恭喜您获得了<color=yellow>%s<color>活力",tbitem.nGTP);
		pPlayer.Msg(szAnnouce);
		Dbg:WriteLog("[道具礼包]获得物品",  pPlayer.szName, string.format("[道具礼包]获得了%s活力", tbitem.nGTP));		
	end

	if tbitem.nSkillId ~= 0 and tbitem.nSkillLevel ~= 0 and tbitem.nSkillTime ~= 0 then
		local bIsAddSkill = 1;
		local nSkillLevel, nTimeType, nTimeSec = pPlayer.GetSkillState(tbitem.nSkillId);
		if tonumber(nSkillLevel) == tonumber(tbitem.nSkillLevel) and tonumber(nTimeType) == 2 then
			if nTimeSec >= tbitem.nSkillTime*60*Env.GAME_FPS then
				pPlayer.Msg("你已经拥有该状态，并且该状态的有效期比现在获得的时间更久。");
				bIsAddSkill = 0;
				Dbg:WriteLog("[道具礼包]获得物品",  pPlayer.szName, string.format("[道具礼包]获得了技能BUFF因已有该状态失败：%s,%s,%s", tbitem.nSkillId,tbitem.nLevel,tbitem.nSkillTime));			
			end
		end
		if bIsAddSkill == 1 then
			pPlayer.AddSkillState(tbitem.nSkillId, tbitem.nSkillLevel, 1, tbitem.nSkillTime*60*Env.GAME_FPS, 1, 0, 1);
			Dbg:WriteLog("[道具礼包]获得物品",  pPlayer.szName, string.format("[道具礼包]获得了技能BUFF：%s,%s,%s", tbitem.nSkillId,tbitem.nLevel,tbitem.nSkillTime));		
		end
	end


	if tbitem.nAnnounce == 1 then
		local szMsg = string.format("%s打开%s获得一个%s,真是鸿运当头呀！", pPlayer.szName, tbitem.szDesc, tbitem.szName);
		KDialog.NewsMsg(1, Env.NEWSMSG_NORMAL, szMsg);
		Player:SendMsgToKinOrTong(pPlayer, "打开"..tbitem.szDesc.."获得了"..tbitem.szName.."。", 1);
	end
	
	if tbitem.nFriendMsg == 1 then
		pPlayer.SendMsgToFriend("Hảo hữu [<color=yellow>"..pPlayer.szName.."<color>]打开"..tbitem.szDesc..
			"获得了<color=yellow>"..tbitem.szName.."<color>。");		
	end

	return 1;
end


function tbItem:GetItemList()
	
	local tbsortpos = Lib:LoadTabFile(SZITEMFILE);
	local nLineCount = #tbsortpos;
	local tbClassItemList = {};
	
	for nLine=2, nLineCount do
		local nClassParamID = tonumber(tbsortpos[nLine].ClassParamID);
		local szName = tbsortpos[nLine].Name;
		local szDesc = tbsortpos[nLine].Desc;
		local nBindMoney = tonumber(tbsortpos[nLine].BindMoney) or 0;
		local nMoney = tonumber(tbsortpos[nLine].Money) or 0;
		local nGenre = tonumber(tbsortpos[nLine].Genre) or 0;
		local nDetailType = tonumber(tbsortpos[nLine].DetailType)or 0;
		local nParticularType = tonumber(tbsortpos[nLine].ParticularType) or 0;
		local nLevel = tonumber(tbsortpos[nLine].Level)or 0;
		local nSeries = tonumber(tbsortpos[nLine].Series) or 0;
		local nEnhTimes = tonumber(tbsortpos[nLine].EnhTimes) or 0;
		local nAmount = tonumber(tbsortpos[nLine].Amount) or 1;
		local nExp = tonumber(tbsortpos[nLine].Exp) or 0;
		local nBaseExp = tonumber(tbsortpos[nLine].BaseExp) or 0;
		local nMKP = tonumber(tbsortpos[nLine].MKP) or 0;
		local nGTP = tonumber(tbsortpos[nLine].GTP) or 0;
		local szTimeLimit = tbsortpos[nLine].TimeLimit or "";
		if szTimeLimit == "" then
			szTimeLimit = "-1" ;
		end
		local nBind = tonumber(tbsortpos[nLine].Bind) or 0;
		local nCoin = tonumber(tbsortpos[nLine].Coin) or 0;
		local nAnnounce = tonumber(tbsortpos[nLine].Announce) or 0;
		local nFriendMsg = tonumber(tbsortpos[nLine].FriendMsg) or 0;
		
		local nSkillId = tonumber(tbsortpos[nLine].SkillId) or 0;
		local nSkillLevel = tonumber(tbsortpos[nLine].SkillLevel) or 0;
		local nSkillTime = tonumber(tbsortpos[nLine].SkillTime) or 0;
		
		if tbClassItemList[nClassParamID] == nil then
			tbClassItemList[nClassParamID] = {};
		end
		local nPosNo = (#tbClassItemList[nClassParamID]+ 1);
		tbClassItemList[nClassParamID][nPosNo] = {};
		tbClassItemList[nClassParamID][nPosNo].szName = szName;
		tbClassItemList[nClassParamID][nPosNo].nBindMoney = nBindMoney;
		tbClassItemList[nClassParamID][nPosNo].nMoney = nMoney;
		tbClassItemList[nClassParamID][nPosNo].nGenre = nGenre;
		tbClassItemList[nClassParamID][nPosNo].nDetailType = nDetailType;
		tbClassItemList[nClassParamID][nPosNo].nParticularType = nParticularType;
		tbClassItemList[nClassParamID][nPosNo].nLevel = nLevel;
		tbClassItemList[nClassParamID][nPosNo].nSeries = nSeries;
		tbClassItemList[nClassParamID][nPosNo].nEnhTimes = nEnhTimes;
		tbClassItemList[nClassParamID][nPosNo].nAmount = nAmount;
		tbClassItemList[nClassParamID][nPosNo].nExp = nExp;
		tbClassItemList[nClassParamID][nPosNo].nBaseExp = nBaseExp;
		tbClassItemList[nClassParamID][nPosNo].nMKP = nMKP;
		tbClassItemList[nClassParamID][nPosNo].nGTP = nGTP;
		tbClassItemList[nClassParamID][nPosNo].szTimeLimit = szTimeLimit;
		tbClassItemList[nClassParamID][nPosNo].nBind = nBind;
		tbClassItemList[nClassParamID][nPosNo].nCoin = nCoin;
		tbClassItemList[nClassParamID][nPosNo].nAnnounce = nAnnounce;
		tbClassItemList[nClassParamID][nPosNo].nFriendMsg = nFriendMsg;
		tbClassItemList[nClassParamID][nPosNo].szDesc = szDesc;
		
		tbClassItemList[nClassParamID][nPosNo].nSkillId    = nSkillId;
		tbClassItemList[nClassParamID][nPosNo].nSkillLevel = nSkillLevel;
		tbClassItemList[nClassParamID][nPosNo].nSkillTime  = nSkillTime;
	end
	return tbClassItemList;
end



function tbItem:LimitTime(pPlayer, szParam, pItem)
	if szParam == nil then
		return 1;
	end
	if not pItem then
		return 0;
	end
	if tonumber(szParam) ~= nil then
		local szDate = os.date("%Y/%m/%d/%H/%M/%S", GetTime() + tonumber(szParam) * 60);
		pPlayer.SetItemTimeout(pItem,szDate);
	else
		local tbStr = Lib:SplitStr(szParam, "/");
		if #tbStr == 3 then
			--当天H:M:S消失
			local nNowDate = GetLocalDate("%Y/%m/%d");
			local szTime = string.format("%s/%s", nNowDate, szParam);
			pPlayer.SetItemTimeout(pItem,szTime);
		elseif #tbStr == 4 then
			--d天后H:M:S消失
			if tonumber(tbStr[1]) > 0 then
				local nNowDate = GetLocalDate("%Y/%m");
				local nHour = tonumber(GetLocalDate("%H"));
				local nMin = tonumber(GetLocalDate("%M"));
				local nSecond = tonumber(GetLocalDate("%S"));
				local nLastTime = 24 * 3600 - (nHour * 3600 + nMin *60 + nSecond);
				local nLastTime2 = tonumber(tbStr[2]) * 3600 + tonumber(tbStr[3]) * 60 + tonumber(tbStr[4]);
				local nLimitTime = nLastTime + ((tonumber(tbStr[1]) - 1)* 24 * 3600) + nLastTime2;
				local szDate = os.date("%Y/%m/%d/%H/%M/%S", GetTime() + nLimitTime);
				pPlayer.SetItemTimeout(pItem,szDate);
			else
				local nNowDate = GetLocalDate("%Y/%m/%d");
				local szTime = string.format("%s/%s/%s/%s", nNowDate, tonumber(tbStr[2]), tonumber(tbStr[3]), tonumber(tbStr[4]));
				pPlayer.SetItemTimeout(pItem,szTime);				
			end			
		elseif #tbStr == 6 then
			--Y-m-d H:M:S后消失
			pPlayer.SetItemTimeout(pItem,szParam);
		end
	end
	return 0;
end

function tbItem:OnUse()
	if not self.tbItemList  then
		self.tbItemList = self:GetItemList();
	end
	local nkind = tonumber(it.GetExtParam(1));
	if not self.tbItemList[nkind] then
		return;
	end	


	if #self.tbItemList[nkind] > 31 or #self.tbItemList[nkind] == 0 then
		print("{error},presentitem,tbItemList",#self.tbItemList[nkind]);
		return;
	end
	
	local tbOpt = {};
	local nIsUsed = it.GetGenInfo(1) or 0;
	local nTmp = 0;	
	
	for nIdx, tbItem in ipairs(self.tbItemList[nkind]) do		
		local szMsg  = tbItem.szName;
		tbItem.nAmount = tbItem.nAmount or 1;
		if tbItem.nAmount > 1 then
			szMsg = szMsg..string.format("(%d个)",tbItem.nAmount);
		end
		
		local bUsed = Lib:LoadBits(nIsUsed, nIdx - 1, nIdx - 1);
		if bUsed == 0 then
			table.insert(tbOpt, {szMsg,self.OnUseEx,self,it.dwId,nIdx,self.tbItemList[nkind]});
		else
			table.insert(tbOpt, {string.format("<color=gray>%s<color>",szMsg),self.OnUseEx,self,it.dwId,nIdx,self.tbItemList[nkind]});
		end			
	end
	table.insert(tbOpt,{"Để ta suy nghĩ thêm。"});
	Dialog:Say((it.szName or "")..",可以开出丰厚的奖励哦。",tbOpt);
	return;	
end

function tbItem:OnUseEx(nItemId, nIdx, tbItemList)
	local pItem = KItem.GetObjById(nItemId);
	if not pItem then
		return;
	end		
	local nIsUsed = pItem.GetGenInfo(1);	
	local bUsed = Lib:LoadBits(nIsUsed, nIdx - 1, nIdx -1);
	if bUsed ~= 0 then
		Dialog:Say("您已经领取过该项了。");
		return;
	end

	if not tbItemList[nIdx] then
		print("presentitem	tbItemList error",nIdx);
		return;
	end
	
	local nRes, varMsg = self:CheckItem(pItem,me, tbItemList[nIdx]);
	if nRes == 0 then
		Dialog:Say(varMsg);
		return;
	end
	self:GetItem(pItem,me, tbItemList[nIdx]);

	nIsUsed = Lib:SetBits(nIsUsed, 1, nIdx - 1, nIdx - 1);	
	pItem.SetGenInfo(1,nIsUsed);
	local nState = 0;
	for nIndex in ipairs(tbItemList) do
		if Lib:LoadBits(nIsUsed, nIndex - 1, nIndex - 1) == 0 then
			nState = 1;
			break;
		end		
	end

	if nState == 0 then   -- 没了东西就直接删了
		pItem.Delete(me);
	else
		pItem.Bind(1); -- 使用之后直接绑定
		pItem.Sync();  --要同步
	end
	return;
end

function tbItem:GetTip() 
	--return	(it.szName or "")..",可以开出丰厚的奖励哦";
	if not self.tbItemList  then
		self.tbItemList = self:GetItemList();
	end
	local nkind = tonumber(it.GetExtParam(1));
	local tbItem = self.tbItemList[nkind];
	if not tbItem then
		return "";
	end		
	
	local szMsg = "江湖大侠修炼武功必备，内有 ";

	local nIsUsed = it.GetGenInfo(1);	
	for nIdx, tbInfo in ipairs(tbItem) do
		local bUsed = Lib:LoadBits(nIsUsed, nIdx - 1, nIdx -1);
		if bUsed == 0 then	
			szMsg = szMsg.."\n"..tbInfo.szName;
			if tbInfo.nGenre ~= 0 then
				szMsg = string.format("%s<color=yellow>%d<color>个 ", szMsg,tbInfo.nAmount);
			end	
		end
	end
	szMsg = szMsg.." \n比单独购买便宜许多。\n<color=gold>注：从礼包取出物品后，礼包将变为绑定。<color>";
	return szMsg;
end

tbItem.tbItemList = tbItem:GetItemList();
