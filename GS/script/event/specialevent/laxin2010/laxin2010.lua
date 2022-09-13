-- author: zhaoyu 2010/9/14 17:08:52

SpecialEvent.tbLaXin2010 = SpecialEvent.tbLaXin2010 or {};

local tbLaXin2010 = SpecialEvent.tbLaXin2010;
tbLaXin2010.tbCardInfo = tbLaXin2010.tbCardInfo or
{
	["tbUsed"]			= {},
	["tbUnused"]		= {},
	["tbLostPlayer"]	= {},
};

tbLaXin2010.DEF_TYPE_MAX = 15;

tbLaXin2010.tbClass2Type = 
{
	["laxin2010_taobao20"]	= 1,
	["laxin2010_qq10"]		= 2,
	["laxin2010_qq30"]		= 3,
	["laxin2010_mobile50"]	= 4,
	["laxin2010_taobao5"]	= 5,
	["laxin2010_taobao10"]	= 6,
	["laxin2010_yintai50"] 	= 7,
	["laxin2011_mobile10"] 	= 8,
	["laxin2011_kingsoft15"] 	= 9,
	["laxin2011_mobile30"] 	= 10,	
	["laxin2011_kingsoft100"] 	= 11,
	["laxin2011_kingsoft50"] 	= 12,
	["laxin2011_mobile"] 	= 13,	
	["laxin2011_video"] 	= 14,
	["laxin2011_compute"] 	= 15,
};

tbLaXin2010.tbCardName = 
{
	[1] = "20元淘宝代金券";
	[2] = "10元Q币卡";
	[3] = "30元Q币卡";
	[4] = "50元移动充值卡";
	[5] = "5元淘宝红包";
	[6] = "10元淘宝红包";
	[7] = "50元银泰现金券";
	[8] = "10元移动充值卡";
	[9] = "15元金山一卡通";
	[10] = "30元移动充值卡";	
	[11] = "100元金山一卡通";
	[12] = "50元金山一卡通";
	[13] = "智能手机";	
	[14] = "数码摄像机";
	[15] = "笔记本电脑";
};

local szMailTemplate = "您在剑侠世界新手体验活动中获得<color=red>%type<color>，请登录网站页面，您的活动认证码为<color=yellow>【卡号:%card / 密码:%pass】<color>，按照提示进行操作，即可获得奖励。感谢您的参与。\n\n剑侠世界运营团队";

local szMailTemplateShiwu =  "您在剑侠世界新手体验活动中获得<color=red>%type<color>，请登录网站页面，您的活动认证码为<color=yellow>【卡号:%card / 密码:%pass】<color>，请到下面地址去填写个人信息，客服会根据您的信息联系您，邮寄奖品。感谢您的参与。\n<link=http://hd.xoyo.com/research/versions/622/565>\n\n剑侠世界运营团队";

tbLaXin2010.tbMailTemplate =
{
	[1] = szMailTemplate;
	[2] = szMailTemplate;
	[3] = szMailTemplate;
	[4] = szMailTemplate;
	[5] = szMailTemplate;
	[6] = szMailTemplate;
	[7] = szMailTemplate;
	[8] = szMailTemplate;
	[9] = szMailTemplate;
	[10] = szMailTemplate;
	[11] = szMailTemplate;
	[12] = szMailTemplate;
	[13] = szMailTemplateShiwu;
	[14] = szMailTemplateShiwu;
	[15] = szMailTemplateShiwu;
};



tbLaXin2010.TASK_GROUP		= 1022; 
tbLaXin2010.TASK_ACTIVE		= 226; -- 是否激活
tbLaXin2010.TASK_AWARD_TYPE	= 227; -- 奖励类型
tbLaXin2010.nStartTime		= 20101010; -- 活动开启时间
tbLaXin2010.nItemTimeout	= 3600*24*3; -- 宝箱过期时间3天，1285925286

function tbLaXin2010:SaveBuffer()	
	SetGblIntBuf(GBLINTBUF_LAXIN2010, 0, 1, self.tbCardInfo);
end

function tbLaXin2010:LoadBuffer()
	self.tbCardInfo = GetGblIntBuf(GBLINTBUF_LAXIN2010, 0) or self.tbCardInfo;
end

function tbLaXin2010:GetItemTimeout()
	local nItemTimeout = self.nItemTimeout;
	local nTimeOut = tonumber(it.GetExtParam(1)) or 0;
	if nTimeOut > 0 then		
		nItemTimeout = nTimeOut * 3600 * 24;
	end
	return GetTime() + nItemTimeout;
end

function tbLaXin2010:InsertCard(tbData)
	-- ??? 需要判断id重复吗？
	Lib:ShowTB(tbData);
	local tbUnused = tbLaXin2010.tbCardInfo.tbUnused;
	local tbCard;
	local nType;
	for _, tbRow in pairs(tbData) do
		tbCard =
		{
			["szCardId"]	= tbRow.szCardId,
			["szCardPass"]	= tbRow.szCardPass,
		};
		nType = tonumber(tbRow.nType);
		if nType then
			print("LaXin2010", "InsertCard", nType, tbRow.szCardId, tbRow.szCardPass)
			if (tbUnused[nType] == nil) then
				tbUnused[nType] = {};
			end
			table.insert(tbUnused[nType], tbCard);
		end
	end
	self:GiveLostAward();
	self:SaveBuffer();
end

function tbLaXin2010:ReadCard(szFileName)
	local tbFile = Lib:LoadTabFile(szFileName);
	if not tbFile then
		print("【在线领取】读取文件错误，文件不存在",szFileName);
		return;
	end
	tbLaXin2010:InsertCard(tbFile);
end

function tbLaXin2010:GiveLostAward()
	for nType, tbPlayerList in pairs(self.tbCardInfo.tbLostPlayer) do
		local tbDelKey = {};
		for nKey, szName in pairs(tbPlayerList) do
			local tbCard = self:UseCard(nType);
			if tbCard then
				self:TellCard_GC(KGCPlayer.GetPlayerIdByName(szName), nType, tbCard);
				table.insert(tbDelKey, nKey);
				print("LaXin2010", "GiveLost", szName, nType, tbCard.szCardId, szCardPass);
			else
				break;
			end
		end
		for _, nKey in pairs(tbDelKey) do
			self.tbCardInfo.tbLostPlayer[nType][nKey] = nil;
		end
	end
end

function tbLaXin2010:UseCard(nType)
	local tbUnusedCardList = self.tbCardInfo.tbUnused[nType];
	local tbUsedCardList = self.tbCardInfo.tbUsed[nType];
	if (tbUnusedCardList == nil or self:GetTableItemCount(tbUnusedCardList) == 0) then
		return;
	end
	for nIndex, tbCard in pairs(tbUnusedCardList) do
		if (tbUsedCardList == nil) then
			self.tbCardInfo.tbUsed[nType] = {};
			tbUsedCardList = self.tbCardInfo.tbUsed[nType];
		end
		tbUnusedCardList[nIndex] = nil;
		table.insert(tbUsedCardList, tbCard);
		return tbCard;
	end
end

function tbLaXin2010:DelCard(nType, nCount)
	local tbUnusedCardList = self.tbCardInfo.tbUnused[nType];
	if (tbUnusedCardList == nil or self:GetTableItemCount(tbUnusedCardList) == 0) then
		return {};
	end
	local tbDelList = {};
	local nDelCount = 0;
	for nIndex, tbCard in pairs(tbUnusedCardList) do
		if (nDelCount == nCount) then
			break;
		end
		tbDelList[nIndex] = tbCard;
		nDelCount = nDelCount + 1;
	end
	
	for nIndex, _ in pairs(tbDelList) do
		print("LaXin2010", "DelCard", nType, tbUnusedCardList[nIndex].szCardId, tbUnusedCardList[nIndex].szCardPass);
		tbUnusedCardList[nIndex] = nil;
	end
	self:SaveBuffer();
	return tbDelList, nDelCount;
end

function tbLaXin2010:GetTableItemCount(tbTable)
	local nCount = 0;
	for _,_ in pairs(tbTable) do
		nCount = nCount + 1;
	end
	return nCount;
end

function tbLaXin2010:GetCardInfo()
	local tbInfo = { tbUsed = {}, tbUnused = {}, tbLostPlayer = {} };
	for nType, tbCardList in pairs(self.tbCardInfo.tbUnused) do
		tbInfo.tbUnused[nType] = self:GetTableItemCount(tbCardList);
	end
	for nType, tbCardList in pairs(self.tbCardInfo.tbUsed) do
		tbInfo.tbUsed[nType] = self:GetTableItemCount(tbCardList);
	end
	for nType, tbPlayerList in pairs(self.tbCardInfo.tbLostPlayer) do
		tbInfo.tbLostPlayer[nType] = self:GetTableItemCount(tbPlayerList);
	end
	return tbInfo;
end

function tbLaXin2010:PrintCardInfo()
	local tbInfo = self:GetCardInfo();
	local szInfo = "";
	szInfo = szInfo .. "未使用：\n";
	for i = 1, self.DEF_TYPE_MAX do
		szInfo = szInfo .. string.format("[类型%d]:%d\n", i, tbInfo.tbUnused[i] or 0);
	end
	szInfo = szInfo .. "已消耗：\n";
	for i = 1, self.DEF_TYPE_MAX do
		szInfo = szInfo .. string.format("[类型%d]:%d\n", i, tbInfo.tbUsed[i] or 0);
	end
	szInfo = szInfo .. "缺货：\n";
	for i = 1, self.DEF_TYPE_MAX do
		szInfo = szInfo .. string.format("[类型%d]:%d\n", i, tbInfo.tbLostPlayer[i] or 0);
	end
	return szInfo;
end

function tbLaXin2010:ApplyCard(nPlayerId, szClass)
	local nType = self.tbClass2Type[szClass];
	local tbCard = self:UseCard(nType);
	local nOnlineServer = GCGetPlayerOnlineServer(KGCPlayer.GetPlayerName(nPlayerId));
	if (tbCard == nil) then
		self:NoStock_GC(nPlayerId, nType);
	else
		self:TellCard_GC(nPlayerId, nType, tbCard);
	end
	self:SaveBuffer();
end

function tbLaXin2010:NoStock_GC(nPlayerId, nType)
	local szName = KGCPlayer.GetPlayerName(nPlayerId);
	local nOnlineServer = GCGetPlayerOnlineServer(szName);
	if szName then
		if self.tbCardInfo.tbLostPlayer[nType] == nil then
			self.tbCardInfo.tbLostPlayer[nType] = {};
		end
		table.insert(self.tbCardInfo.tbLostPlayer[nType], szName);
	end
	if (nOnlineServer > 0) then
		GSExecute(nOnlineServer, {"SpecialEvent.tbLaXin2010:NoStock_GS", nPlayerId});
	end
end

function tbLaXin2010:NoStock_GS(nPlayerId)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		return;
	end
	KPlayer.SendMail(pPlayer.szName, "您的奖品", "您好，今天的奖品已经全部发完了，明天奖品会自动补发给您，请注意查收邮件。");
end

function tbLaXin2010:TellCard_GC(nPlayerId, nType, tbCard)
	local szName = KGCPlayer.GetPlayerName(nPlayerId);
	local nOnlineServer = GCGetPlayerOnlineServer(szName);
	if GSExecute(nOnlineServer, {"SpecialEvent.tbLaXin2010:TellCard_GS", nPlayerId, nType, tbCard}) == 1 then
		return;
	end
	for i = 1, 16 do
		if GSExecute(i, {"SpecialEvent.tbLaXin2010:TellCard_GS", nPlayerId, nType, tbCard}) == 1 then
			print("LaXin2010", "SendCard", szName, tbCard.szCardId, tbCard.szCardPass);
			return;
		end
	end
	Dbg:WriteLog("Send Award Card Failed:", KGCPlayer.GetPlayerName(nPlayerId), nType, tbCard.szCardId, tbCard.szCardPass);	
end

function tbLaXin2010:TellCard_GS(nPlayerId, nType, tbCard)
	local szName = KGCPlayer.GetPlayerName(nPlayerId);
	local szTxt = self.tbMailTemplate[nType];
	szTxt = "尊敬的<color=green>" .. szName .. "<color>:\n" .. szTxt;
	szTxt = string.gsub(szTxt, "%%type", self.tbCardName[nType]);
	szTxt = string.gsub(szTxt, "%%card", tbCard.szCardId);
	szTxt = string.gsub(szTxt, "%%pass", tbCard.szCardPass);
	if szName then
		KPlayer.SendMail(szName, "您的奖品", szTxt);
	end	
end

function tbLaXin2010:UseItem(nPlayerId, pItem)
	Dialog:Say("感谢您参与抽奖活动，您的奖品已经以邮件的形式发送到您的游戏信箱，请打开收件箱查收。");
	GCExecute({"SpecialEvent.tbLaXin2010:ApplyCard", nPlayerId, pItem.szClass});
	return 1;
end

function tbLaXin2010:OnActive()
	if (me.GetTask(self.TASK_GROUP, self.TASK_ACTIVE) == 1) then
		Dialog:Say("您已经激活过了该奖励，不能再次激活了。")
	elseif (me.GetRoleCreateDate() < self.nStartTime) then
		Dialog:Say("您已经是老江湖了，不能享受新手体验奖励。")
	else
		PresendCard:OnDialogCard();
	end
end

function tbLaXin2010:OnGCStart()
	self:LoadBuffer();
end

if GCEvent ~= nil and GCEvent.RegisterGCServerStartFunc ~= nil then
	GCEvent:RegisterGCServerStartFunc(tbLaXin2010.OnGCStart, tbLaXin2010);
end










