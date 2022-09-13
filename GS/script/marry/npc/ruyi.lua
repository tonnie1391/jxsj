-- 文件名　：ruyi.lua
-- 创建者　：furuilei
-- 创建时间：2009-12-07 11:09:35
-- 功能描述：结婚npc，如意

local tbNpc = Npc:GetClass("marry_ruyi");

--===================================================
tbNpc.MAXNUM_LIST 		= 10000;
tbNpc.MAX20E 			= 2000000000;

tbNpc.OPT_NONOTIFY		= 1;		
tbNpc.OPT_SYSNOTIFY		= 2;
tbNpc.OPT_WORLDNOTIFY	= 3;
tbNpc.tbInfo = {
	[tbNpc.OPT_NONOTIFY]	= {nCost = 0, szInfo = ""},
	[tbNpc.OPT_SYSNOTIFY]	= {nCost = 2, szInfo = "系统公告"},
	[tbNpc.OPT_WORLDNOTIFY]	= {nCost = 5, szInfo = "世界公告"},
	};
	
tbNpc.TB_MSG_ZHUFU = {
	[1] = "好事连连，好梦圆圆！",
	[2] = "永结同心，百年好合！",
	[3] = "鸾凤和鸣，永浴爱河！",
	[4] = "恩意如岳，知音百年！",
	[5] = "白首偕老，天长地久！",
	[6] = "幸福快乐，龙凤呈祥！",
	[7] = "花好月圆，并蒂荣华！",
	[8] = "福禄鸳鸯，百年琴瑟！",
	};

--===================================================

function tbNpc:InitRecordList()
	
	if (not Marry.tbList) then
		Marry.tbList = {};
	end
	
	local nMapId = me.nMapId;
	if (not Marry.tbList[nMapId]) then
		Marry.tbList[nMapId] = {};
	end
end

function tbNpc:OnDialog()
	if (Marry:CheckState() == 0) then
		return 0;
	end
	self:InitRecordList();
	local szMsg = "在这喜庆的日子，谨祝这对侠侣百年好合，执手偕老！宾客们可以在我这里为侠侣送上礼金，为他们送上最真挚的祝福。送出的所有礼金将在典礼场地关闭后邮寄给两位侠侣。\n"..
	              "【系统公告】需要额外支付：<color=yellow>"..self.tbInfo[self.OPT_SYSNOTIFY].nCost.."朵情花<color>\n"..
	              "【世界公告】需要额外支付：<color=yellow>"..self.tbInfo[self.OPT_WORLDNOTIFY].nCost.."朵情花<color>\n";
	local tbOpt = {
		{"送礼金【不公告】", self.GiveGiftDlg, self, self.OPT_NONOTIFY},
		{"送礼金【系统公告】", self.GiveGiftDlg, self, self.OPT_SYSNOTIFY},
		{"送礼金【世界公告】", self.GiveGiftDlg, self, self.OPT_WORLDNOTIFY},
		{"看看谁送了多少礼金", self.ShowGift, self},
		--{"返回江津", self.Transfer, self},
		{"Kết thúc đối thoại"},
		};
		
	local tbCoupleName = Marry:GetWeddingOwnerName(me.nMapId);
	if (tbCoupleName and #tbCoupleName == 2 and
		(me.szName ~= tbCoupleName[1] and me.szName ~= tbCoupleName[2])) then
		table.insert(tbOpt, 1, {"【送祝福】", self.SendZhufuDlg, self});
	end
	
	Dialog:Say(szMsg, tbOpt);
end

function tbNpc:Transfer()
	Marry.tbMissionList[me.nMapId]:KickPlayer(me, 1);
	me.SetLogoutRV(0);
end

-- 获取玩家当前有多少情花
function tbNpc:GetCurQinghuaCount()
	return me.GetItemCountInBags(unpack(Marry.ITEM_QINGHUA_ID));
end

-- 从玩家身上扣除情花
function tbNpc:CostQinghua(nCost)
	local bCostSuccess = 0;
	if (me.ConsumeItemInBags2(nCost, unpack(Marry.ITEM_QINGHUA_ID)) == 0) then
		bCostSuccess = 1;
	end
	return bCostSuccess;
end

-- 为新人送祝福
function tbNpc:SendZhufuDlg()
	local szMsg = "你可以缴纳<color=yellow>1朵<color>情花，从以下贺词当中选择一条，以公告的形式为二位侠侣送上祝福。";
	local tbOpt = {};
	for nIndex, szZhufuMsg in ipairs(self.TB_MSG_ZHUFU) do
		table.insert(tbOpt, {szZhufuMsg, self.SendZhufu, self, nIndex});
	end
	table.insert(tbOpt, {"我还是再想想吧"});
	Dialog:Say(szMsg, tbOpt);
end

function tbNpc:SendZhufu(nIndex)
	local nQinghuaCount = self:GetCurQinghuaCount();
	if (nQinghuaCount < 1) then
		Dialog:Say("发送祝福需要<color=red>1朵<color>情花，你还是带够了再来吧。");
		return 0;
	end
	
	local szZhufuMsg = self.TB_MSG_ZHUFU[nIndex];
	if (not szZhufuMsg) then
		return 0;
	end
	szZhufuMsg = string.format("<color=green>[%s]<color><color=yellow>为新人送上祝福：%s<color>", me.szName, szZhufuMsg);
	
	if (self:CostQinghua(1) == 1) then
		local tbPlayerList = Marry:GetAllPlayers(me.nMapId);
		for _, pPlayer in pairs(tbPlayerList) do
			Dialog:SendInfoBoardMsg(pPlayer, szZhufuMsg);
		end
	end
end

function tbNpc:GiveGiftDlg(nOpt)
	local nCurMoney = self:GetCurQinghuaCount();
	local nCost = self.tbInfo[nOpt].nCost;
	if (nCurMoney < nCost) then
		Dialog:Say("您当前的情花不足以支付公告费用！");
		return 0;
	end
	local nMaxCanSend = me.nCashMoney;
	if (nMaxCanSend <= 0) then
		Dialog:Say("你身上没有银两，不能送礼金。");
		return 0;
	end
	Dialog:AskNumber("请输入送出的礼金：", nMaxCanSend, self.OnCostMoney, self, nOpt, 0);
end

function tbNpc:OnCostMoney(nOpt, bSure, nNum)

	if (nNum <= 0) then
		Dialog:Say("您输入的数字有误，请重新输入。",
			{
			{"重新输入", self.GiveGiftDlg, self, nOpt},
			{"我还是一会再来吧。"},
			});
		return 0;
	end
	
	local bCanSendMoney, szErrMsg = self:CanSendMoney(nNum);
	if (0 == bCanSendMoney) then
		if ("" ~= szErrMsg) then
			Dialog:Say(szErrMsg);
		end
		return 0;
	end
	
	local nCost = self.tbInfo[nOpt].nCost;
	local szMsg = "";
	if (0 == bSure) then
		szMsg = string.format("你送给二位侠侣的礼金为：<color=yellow>%s两<color>。确定吗？", nNum);
		local szInfo = self.tbInfo[nOpt].szInfo;
		if ("" ~= szInfo) then
			szMsg = szMsg .. string.format("【您的祝福信息将发布<color=yellow>%s<color>，会额外收取您<color=yellow>%s<color>朵情花】。",
				szInfo, nCost);
		end
		Dialog:Say(szMsg, {
			{"送出礼金和祝福", self.OnCostMoney, self, nOpt, 1, nNum},
			{"我还是一会再来吧"}
			});
		-- return 1;
	elseif (1 == bSure) then
		if (nNum > me.nCashMoney) then
			return 0;
		end
		
		local bCostQinghuaSuccess = 1;
		if (nCost > 0) then
			bCostQinghuaSuccess = self:CostQinghua(nCost);
			if (bCostQinghuaSuccess == 1) then
				me.Msg(string.format("您已经送出礼金，扣除情花<color=yellow>%s朵<color>。", nCost));
			end
		end
		if (bCostQinghuaSuccess == 1) then
			me.CostMoney(nNum, Player.emKPAY_EVENT);
			self:AddRecord(nNum);
			self:SendNotify(nOpt, nNum);
		end
	end
end

function tbNpc:SendNotify(nOpt, nNum)
	local tbCoupleName = Marry:GetWeddingOwnerName(me.nMapId);
	local szNotify = string.format("<color=green>[%s]<color>为[%s]和[%s]的典礼祝福，送上礼金<color=orange>%s<color>两。",
		me.szName, tbCoupleName[1], tbCoupleName[2], nNum);
	local szTongMsg = string.format("为[%s]和[%s]的典礼祝福，送上礼金<color=orange>%s<color>两。",
		tbCoupleName[1], tbCoupleName[2], nNum);
	if (nOpt == self.OPT_NONOTIFY) then
		me.Msg(string.format("你送出了<color=yellow>%s<color>两礼金。", nNum));
		return;
	end
	if (nOpt == self.OPT_SYSNOTIFY) then
		me.Msg(string.format("你送出了<color=yellow>%s<color>两礼金。", nNum));
		KDialog.MsgToGlobal(szNotify);
	end
	if (nOpt == self.OPT_WORLDNOTIFY) then
		me.Msg(string.format("你送出了<color=yellow>%s<color>两礼金。", nNum));
		KDialog.NewsMsg(1, Env.NEWSMSG_COUNT, szNotify, 20);
		Player:SendMsgToKinOrTong(me, szTongMsg, 1);
	end
end

function tbNpc:AddRecord(nNum)
	if (not Marry.tbList) then
		Marry.tbList = {};
	end
	if (not Marry.tbList[me.nMapId]) then
		Marry.tbList[me.nMapId] = {};
	end
	local tbList = Marry.tbList[me.nMapId];
	for i, v in pairs(tbList) do
		if (v.szName == me.szName) then
			v.nSum = v.nSum + nNum;
			self:WriteLijinLog(me.nMapId, me.szName, nNum);
			self:AddLijin_S2G(me.nMapId, nNum);
			return 1;
		end
	end
	local tbRecord = {};
	tbRecord.szName = me.szName;
	tbRecord.nSum = nNum;
	table.insert(tbList, tbRecord);
	self:WriteLijinLog(me.nMapId, me.szName, nNum);
	self:AddLijin_S2G(me.nMapId, nNum);
	return 1;
end

function tbNpc:AddLijin_S2G(nMapId, nNum)
	local tbCoupleName = Marry:GetWeddingOwnerName(nMapId);
	if (not tbCoupleName or #tbCoupleName ~= 2) then
		return;
	end
	GCExcute({"Marry:AddLijin_GC", tbCoupleName[1], tbCoupleName[2], nNum, GetServerId()});
end

function tbNpc:WriteLijinLog(nMapId, szName, nNum)
	if (not nNum) then
		return;
	end
	if (nNum >= 200000) then
		self:__Writelog_Local(nMapId, szName, nNum);
	end
	if (nNum >= 100000) then
		self:__Writelog_Playerlog(nMapId, szName, nNum);
	end
end

function tbNpc:__Writelog_Local(nMapId, szName, nNum)
	if not Marry.tbList then
		return 0;
	end 
	local nSum = 0;
	local tbList = Marry.tbList[nMapId];
	for i, v in pairs(tbList or {}) do
		nSum = nSum + v.nSum;
	end
	if (nSum <= 0) then
		return;
	end
	local tbCoupleName = Marry:GetWeddingOwnerName(nMapId);
	if (not tbCoupleName or #tbCoupleName ~= 2) then
		return;
	end
	
	local szLog = string.format("%s和%s的婚礼\t%s送上礼金%s\t当前礼金总数%s", tbCoupleName[1], tbCoupleName[2], szName, nNum, nSum);
	Dbg:WriteLog("Marry", "结婚系统", szLog);
end

function tbNpc:__Writelog_Playerlog(nMapId, szName, nNum)
	local tbCoupleName = Marry:GetWeddingOwnerName(nMapId);
	if (not tbCoupleName or #tbCoupleName ~= 2) then
		return;
	end
	
	local pPlayer = KPlayer.GetPlayerByName(szName);
	if (not pPlayer) then
		return;
	end
	
	local szLog = string.format("为%s和%s的婚礼送上礼金%s", tbCoupleName[1], tbCoupleName[2], nNum);
	pPlayer.PlayerLog(Log.emKPLAYERLOG_TYPE_JOINSPORT, szLog);
end

local _Sort = function(a, b)
	return a.nSum > b.nSum;
end

function tbNpc:GetTopRecordList()
	if (not Marry.tbList) then
		Marry.tbList = {};
	end
	if (not Marry.tbList[me.nMapId]) then
		Marry.tbList[me.nMapId] = {};
	end
	local tbList = Marry.tbList[me.nMapId];
	table.sort(tbList, _Sort);
	local tbRecord = {};
	for i = 1, self.MAXNUM_LIST do
		if (tbList[i]) then
			table.insert(tbRecord, tbList[i]);
		else
			break;
		end
	end
	return tbRecord;
end

function tbNpc:ShowGift(nFrom)
	local tbRecordList = self:GetTopRecordList();
	if (0 == #tbRecordList) then
		Dialog:Say("现在还没有宾客送出礼金。");
		return;
	end
	local nMyselfCost = 0;
	if (not Marry.tbList) then
		Marry.tbList = {};
	end
	if (not Marry.tbList[me.nMapId]) then
		Marry.tbList[me.nMapId] = {};
	end
	local tbList = Marry.tbList[me.nMapId];
	for i, v in pairs(tbList) do
		if (v.szName == me.szName) then
			nMyselfCost = v.nSum;
			break;
		end
	end
	
	local tbOpt = {"Ta hiểu rồi"};
	local szMsg = string.format("您当前送给二位侠侣的礼金一共是%s两。以下是送出礼金宾客列表。\n\n", nMyselfCost);
	
	local nBegin = nFrom or 0;
	local nLeft = #tbRecordList - nBegin;
	local nLength = (nLeft <= 10) and nLeft or 10;
	
	for i = nBegin, nBegin + nLength do 
		if tbRecordList[i] then
			szMsg = szMsg .. string.format("<color=yellow>%s<color>送来礼金<color=yellow>%s<color>两\n", tbRecordList[i].szName, tbRecordList[i].nSum);
		end
	end
	
	if nLeft > 10 then
		table.insert(tbOpt, 1, {"<color=yellow>下一页<color>", self.ShowGift, self, nBegin + nLength + 1});
	end
	
	Dialog:Say(szMsg, tbOpt);
end

-- 在婚礼结束的时候，把礼金分别发送给新人
function tbNpc:SendGift2Couple(szMaleName, szFemaleName, nMapId)
	if not Marry.tbList then
		return 0;
	end 
	Marry.tbList[nMapId] = nil;
	do return; end
	
	-- furuilei 后续送礼金的操作改到其他地方执行，这里注释掉
	local nSum = 0;
	local tbList = Marry.tbList[nMapId];
	for i, v in pairs(tbList or {}) do
		nSum = nSum + v.nSum;
	end
	if nSum <= 0 then
		return 0;
	end
	local nSendMoney = math.floor(nSum / 2);
	local szTitle = "典礼礼金";
	local szDate = tostring(os.date("%Y年%m月%d日", GetTime()));
	local szContent = string.format("在<color=green>%s<color>的典礼中，来宾共送来礼金<color=yellow>%s<color>两，这些礼金将由二位分别收取。请查收邮件。\n",
									szDate, nSum);
	szContent = szContent .. "   这是一场盛大的典礼，这是一个美满幸福的回忆。随信的礼金谨代表我们送上了的祝福，祝您们幸福快乐，百年好合，执手偕老。";
	KPlayer.SendMail(szMaleName, szTitle, szContent, 0, nSendMoney);
	KPlayer.SendMail(szFemaleName, szTitle, szContent, 0, nSendMoney);
	Marry.tbList[nMapId] = nil;
	
	Dbg:WriteLog("Marry", "结婚系统", string.format("%s跟%s的典礼礼金总额：%s", szMaleName, szFemaleName, nSum));
end


function tbNpc:CanSendMoney(nSendMoney)
	local szErrMsg = "";
	local nMySendSum = self:GetMyselfRecord();
	if (nMySendSum >= self.MAX20E) then
		szErrMsg = string.format("我只能接受每个人<color=yellow>%s<color>礼金，您的心意我们已经知道了，谢谢。", self.MAX20E);
		return 0, szErrMsg;
	elseif (nMySendSum + nSendMoney > self.MAX20E) then
		szErrMsg = string.format("我只能接受每个人<color=yellow>%s<color>礼金，您已经赠送了<color=yellow>%s<color>礼金，不能再送这么多了，谢谢。",
			self.MAX20E, nMySendSum);
		return 0, szErrMsg;
	end
	
	local nAllPlayerSendSum = self:GetTotalGift();
	if (nAllPlayerSendSum >= 2 * self.MAX20E) then
		szErrMsg = string.format("我最多只能代替二位侠侣接受<color=yellow>%s<color>礼金，现在新人的亲朋好友已经赠送这么多了，您的心意我已经知道了，不用再送了",
			self.MAX20E * 2);
		return 0, szErrMsg;
	elseif (nAllPlayerSendSum + nSendMoney > self.MAX20E * 2) then
		szErrMsg = string.format("我最多只能代替二位侠侣接受<color=yellow>%s<color>礼金，现在他们的亲朋好友已经赠送了<color=yellow>%s<color>礼金了，不能再送这么多了。",
			self.MAX20E * 2, nAllPlayerSendSum);
		return 0, szErrMsg;
	end
	
	return 1;
end

-- 获取自己礼金记录的总额
function tbNpc:GetMyselfRecord()
	local nMyselfRecord = 0;
	if (not Marry.tbList) then
		Marry.tbList = {};
	end
	if (not Marry.tbList[me.nMapId]) then
		Marry.tbList[me.nMapId] = {};
	end
	local tbList = Marry.tbList[me.nMapId];
	for i, v in pairs(tbList) do
		if (v.szName == me.szName) then
			nMyselfRecord = v.nSum;
		end
	end
	return nMyselfRecord;
end

-- 获取总共的礼金数额
function tbNpc:GetTotalGift()
	local nSum = 0;
	if (not Marry.tbList) then
		Marry.tbList = {};
	end
	if (not Marry.tbList[me.nMapId]) then
		Marry.tbList[me.nMapId] = {};
	end
	local tbList = Marry.tbList[me.nMapId];
	for i, v in pairs(tbList or {}) do
		nSum = nSum + v.nSum;
	end
	return nSum;
end
