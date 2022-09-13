-------------------------------------------------------------------
--File: newchongzhievent.lua
--Author: zhouchenfei
--Date: 2012/3/3 11:38:57
--Describe: 新充值活动
-------------------------------------------------------------------

EventManager.tbChongZhiEvent = EventManager.tbChongZhiEvent or {};
local tbChongZhiEvent = EventManager.tbChongZhiEvent;
tbChongZhiEvent.tbChongZhiAward = {};
tbChongZhiEvent.CFG_FILE = "\\setting\\event\\manager\\chongzhiaward.txt";
tbChongZhiEvent.TYPE_AWARD_BASE			= 1;	-- 充值活动类型：基本奖励
tbChongZhiEvent.TYPE_AWARD_MULCHOOSE	= 2;	-- 充值活动类型：多选一奖励
tbChongZhiEvent.TYPE_AWARD_BUY			= 3;	-- 充值活动类型：购买资格
tbChongZhiEvent.TYPE_AWARD_BACKBINDCOIN = 4;	-- 充值活动类型：绑金返还
tbChongZhiEvent.nOpenFlag				= 1;

tbChongZhiEvent.PROT_ACTIVE			= 1;
tbChongZhiEvent.PROT_UPDATEMONEY	= 2;
tbChongZhiEvent.PROT_UPDATEDATA		= 3;
tbChongZhiEvent.PROT_PROCESS_AWARD	= 4;
tbChongZhiEvent.PROT_OPEN_WND		= 5;
tbChongZhiEvent.PROT_CHANGE_YUEGUI	= 6;
tbChongZhiEvent.PROT_CHANGE_PUTI	= 7;
tbChongZhiEvent.PROT_BINCOIN_BACK	= 8;
tbChongZhiEvent.PROT_LOTTORY		= 9;
tbChongZhiEvent.PROT_MAX			= 10;

tbChongZhiEvent.tbAwardType = {
		"AddItem",
		"AddSkillBuff",
		"AddExBindCoinByPay",
		"SetPayAction",
		"CoinBuyItem",
	};

function tbChongZhiEvent:LoadCfgFile()
	local tbsortpos = Lib:LoadTabFile(self.CFG_FILE);
	local nLineCount = #tbsortpos;
	local tbClassItemList = {};
	
	for nLine=2, nLineCount do
		local nClassParamID	= tonumber(tbsortpos[nLine].ClassId);
		local nType			= tonumber(tbsortpos[nLine].TypeId);
		local nTypePartId	= tonumber(tbsortpos[nLine].TypePartId);
		local nEventType	= tonumber(tbsortpos[nLine].EventType);
		local nEventId		= tonumber(tbsortpos[nLine].EventId);
		local nPartId		= tonumber(tbsortpos[nLine].PartId);
		local nMonthPay		= tonumber(tbsortpos[nLine].MonthPay);
		local szName		= tbsortpos[nLine].Name;
		local szDesc		= tbsortpos[nLine].Desc;
		local szAward		= tbsortpos[nLine].Award
		local szAwardType	= tbsortpos[nLine].AwardType
		local szTip			= tbsortpos[nLine].Tip;
		local szImgItem		= tbsortpos[nLine].ImgItem;
		
		if tbClassItemList[nClassParamID] == nil then
			tbClassItemList[nClassParamID] = {};
			tbClassItemList[nClassParamID].szDesc = szDesc;
			tbClassItemList[nClassParamID].nMonthPay = nMonthPay;
			tbClassItemList[nClassParamID].tbAwardList = {};
		end
		
		if (nType and nType > 0) then
			local tbAwardList = tbClassItemList[nClassParamID].tbAwardList[nType];
			if (not tbAwardList) then
				tbAwardList = {};
				tbAwardList.tbList = {};
				tbAwardList.tbAwardEventType = {};
				tbClassItemList[nClassParamID].tbAwardList[nType] = tbAwardList;
			end
			
			local tbAwardEventType = tbAwardList.tbAwardEventType[nEventType];
			
			if (not tbAwardEventType) then
				tbAwardEventType = {};
				tbAwardEventType.nEventId = nEventId;
				tbAwardEventType.nPartId = nPartId;
				tbAwardList.tbAwardEventType[nEventType] = tbAwardEventType;
			end

			local tbAward = {};
			tbAward.szName		= szName;
			tbAward.szAward		= szAward;
			tbAward.szAwardType	= szAwardType;
			tbAward.szTip		= szTip;
			tbAward.nEventType	= nEventType;
			tbAward.TypePartId	= TypePartId;
			tbAward.szImgItem	= szImgItem;
			table.insert(tbAwardList.tbList, tbAward);
		end

	end
	self.tbChongZhiAward = tbClassItemList;
end

EventManager.tbChongZhiEvent:LoadCfgFile();

