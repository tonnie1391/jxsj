-- 文件名　：playerpray.lua
-- 创建者　：zhouchenfei
-- 创建时间：2008-09-02 09:29:06

--1.effect	奖励状态，			(nid,nlevel)状态id，状态等级
--2.money	奖励金钱，			(nmoney)金钱数
--3.item	奖励物品，			物品具体id
--4.exp		奖励经验，			具体经验量
--5.playertitle 玩家称号
--6.achievement 玩家成就		成就id

local tbPlayerPray	= Task.tbPlayerPray or {};	-- 支持重载
Task.tbPlayerPray	= tbPlayerPray;

tbPlayerPray.TSKGROUP				= 2049;		-- 祈福任务变量
tbPlayerPray.TSK_SAVEELEMENT		= 1;		-- 保存祈福结果 一个整数保存五个结果
tbPlayerPray.TSK_PRAYCOUNT			= 2;		-- 记录玩家今日系统送的祈福次数,默认为0
tbPlayerPray.TSK_INDIRAWARDFLAG		= 3;		-- 有物品奖励没领的记录
tbPlayerPray.TSK_EXPRAYCOUNT		= 4;		-- 记录玩家使用道具加上的祈福次数
tbPlayerPray.TSK_TODAYUSEDCOUNT		= 5;		-- 记录玩家已经祈福的次数
tbPlayerPray.TSK_USEDPRAYITEMFLAG	= 6;		-- 记录上一次使用祈福令牌时间
tbPlayerPray.TSK_GIVECOUNT			= 7;		-- 充值赠送次数，或者其他赠送奖励
tbPlayerPray.TSK_IFGETEXTRACOUNT	= 8;		-- 合服子服务器玩家是否领取过额外祈福次数
tbPlayerPray.TSK_CLOSEPRAY			= 200;		-- 关闭开启祈福功能按钮

tbPlayerPray.CLOSEPRAYSYS			= 0;		-- 关闭祈福功能的标志，默认为0，表示不关闭，1为关闭
tbPlayerPray.SYSGIVECOUNT			= 1;		-- 系统每天给予的免费祈福次数

-- by zhangjinpin@kingsoft
tbPlayerPray.TASK_INTERVAL			= 9;		-- 处理协议时间间隔
tbPlayerPray.MAX_INTERVAL			= 1;		-- 1秒间隔

tbPlayerPray.DEF_MAX_AWARD_NUM		= EventManager.IVER_nPrayAwardNum;
tbPlayerPray.tbCountAchievement		= {
	--	已经祈福的次数  成就id
		[1]		= 87,
		[100]	= 88,
		[1000]	= 89,
	};		-- 因祈福次数而获得的成就
	
tbPlayerPray.DEF_COZONE_COMPOSE_MINDAY = 7;


function tbPlayerPray:init()
	self.CLOSEPRAYSYS = 0;
	
	if (GLOBAL_AGENT) then
		self:ClosePraySystem();
	end;
end

function tbPlayerPray:ClosePraySystem()
	self.CLOSEPRAYSYS = 1;
end

-- 获取祈福奖励配置表
function tbPlayerPray:LoadPraySetting()
	local tbAwardList = {};
	local tbData = Lib:LoadTabFile("\\setting\\task\\help\\playerpray.txt");
	for _, tbRow in ipairs(tbData) do
		local tbSubData = tbAwardList;
		local tbPreData	= nil;
		for i=1, 5 do
			local nElement = tonumber(tbRow["PRAY_" .. i]);
			if (0 >= nElement) then
				break;
			end
			if (not tbSubData[nElement]) then
				tbSubData[nElement] = {};
				tbSubData[nElement].tbAward		= {};
				tbSubData[nElement].tbSubData	= {};
				tbSubData[nElement].szPrayWords	= "";
				tbSubData[nElement].szPrayThing	= "";
			end
			
			tbPreData = tbSubData[nElement];
			tbSubData = tbSubData[nElement].tbSubData;
		end
		
		if (tbPreData) then
			local tbAward		= {};
			local tbEffect		= {};
			local nPrayAgain	= 0;
			for i=1, self.DEF_MAX_AWARD_NUM do
				local szType	= tbRow["AWARD_TYPE_" .. i];
				local szAward	= tbRow["AWARD_VALUE_" .. i];
				if (szType and string.len(szType) > 0) then
					local tbTemp = {};
					if (string.find(szAward, "\"")) then
						szAward = Lib:StrTrim(szAward, "\"")
					end
					tbTemp.szType	= szType;
					tbTemp.szAward	= szAward;
					tbAward[#tbAward + 1]	= tbTemp;
				end
			end
			tbPreData.szPrayWords	= tbRow["PRAYWORDS"];
			tbPreData.szPrayThing	= tbRow["PRAYTHING"];
			tbPreData.tbAward		= tbAward;
			tbPreData.nPrayAgain	= nPrayAgain;
		end
	end
	self.tbAwardList = tbAwardList;
end

-- 获得某一次的五行属性 第几轮祈福
function tbPlayerPray:GetPrayElement(pPlayer, nRound)
	local nAllElement	= pPlayer.GetTask(self.TSKGROUP, self.TSK_SAVEELEMENT);
	local nBegin		= (nRound - 1) * 3;
	local nElement		= Lib:LoadBits(nAllElement, nBegin, nBegin + 2);
	return nElement;
end

-- 保存五行属性
function tbPlayerPray:SetPrayElement(pPlayer, nRound, nElement)
	local nAllElement	= pPlayer.GetTask(self.TSKGROUP, self.TSK_SAVEELEMENT);
	local nBegin		= (nRound - 1) * 3;
	nAllElement			= Lib:SetBits(nAllElement, nElement, nBegin, nBegin + 2);
	pPlayer.SetTask(self.TSKGROUP, self.TSK_SAVEELEMENT, nAllElement);
	--self:WriteLog("SetPrayElement", string.format("Player %s set pray %d round element %d", pPlayer.szName, nRound, nElement));
end

-- 获得祈福记录中已经祈福的个数
function tbPlayerPray:GetPrayResultCount(pPlayer)
	local nRound = 0;
	for i=1, 5 do
		local nEle = self:GetPrayElement(pPlayer, i);
		if (nEle <= 0) then
			break;
		end
		nRound = nRound + 1;
	end
	return nRound;
end

function tbPlayerPray:DirGetAward(pPlayer)
	local tbElement = {};
	for i=1, 5 do
		tbElement[#tbElement + 1] = self:GetPrayElement(pPlayer, i);
	end

	return self:GetAward(pPlayer, tbElement);
end

function tbPlayerPray:CheckAllowGetAward(pPlayer)
	if (1 == self.CLOSEPRAYSYS) then
		return 1;
	end
	
	local nTskIndirFlag = pPlayer.GetTask(self.TSKGROUP, self.TSK_INDIRAWARDFLAG);
	if (1 ~= nTskIndirFlag) then
		--self:WriteLog("CheckAllowGetAward", string.format("There is no pray award for Player %s!", pPlayer.szName));
		return 1;
	end

	local tbAward = self:DirGetAward(pPlayer);

	if (#tbAward <= 0) then
		--self:WriteLog("CheckAllowGetAward", "There is no pray award!", pPlayer.szName, pPlayer.GetTask(self.TSKGROUP, self.TSK_SAVEELEMENT));
		return 1;
	end
	
	if (1 == self:CheckBag(pPlayer, tbAward)) then
		return 2;
	end	
	
	return 0;
end

-- 奖励祈福物品或者金钱或者其他需要领取的奖励
function tbPlayerPray:GiveAward(pPlayer)
	local nAwardFlag = self:CheckAllowGetAward(pPlayer);
	if (0 < nAwardFlag) then
		if (2 == nAwardFlag) then
			pPlayer.Msg("Túi không đủ chỗ trống, không thể tặng phần thưởng");
		end
		--self:WriteLog("GiveAward", string.format("Player %s is not allowed to get award!!", pPlayer.szName));
		return;
	end
	
	local tbAward = self:DirGetAward(pPlayer);
	for i=1, #tbAward do
		self:GiveDetailAward(pPlayer, tbAward[i]);
	end

	pPlayer.SetTask(self.TSKGROUP, self.TSK_INDIRAWARDFLAG, 0);

	self:GivePrayAnnouns(pPlayer, tbAward);	
	SpecialEvent.ActiveGift:AddCounts(pPlayer, 3);		--祈福活跃度
	SpecialEvent.tbGoldBar:AddTask(pPlayer, 3);		--金牌联赛祈福
end

-- 判断背包中是否有剩余空间
function tbPlayerPray:CheckBag(pPlayer, tbAward)
	local nCount = 0;
	for i=1, #tbAward do
		if (tbAward[i].szType == "item") then
			nCount = nCount + 1;
		end
	end
	if (pPlayer.CountFreeBagCell() < nCount) then
		return 1;
	end
	return 0;
end

-- 通过给定的五行获取相应奖励
function tbPlayerPray:GetAward(pPlayer, tbElement)
	local tbAwardList	= self.tbAwardList;
	local tbAward		= {};
	
	for i=1, #tbElement do
		local nElement	= tbElement[i];
		if (nElement <= 0) then
			break;
		end
		
		if (not tbAwardList[nElement]) then
			if (nElement > 0) then
				self:WriteLog("Player Pray error at element, round", pPlayer.szName, nElement, i);
			end
			break;
		end

		if (tbAwardList[nElement].tbAward) then
			tbAward = tbAwardList[nElement].tbAward;
		end

		tbAwardList = tbAwardList[nElement].tbSubData;	
	end
	return tbAward;
end

-- 获取奖励中效果奖励部分
function tbPlayerPray:GetEffect(pPlayer, tbElement)
	local tbAward	= self:GetAward(pPlayer, tbElement);
	local tbEffect	= {};
	for i=1, #tbAward do
		if ("effect" == tbAward[i].szType) then
			tbEffect[#tbEffect + 1] = tbAward[i];
		end
	end
	return tbEffect;
end

-- 获得祈福文字说明
function tbPlayerPray:GetPrayWords(pPlayer, tbElement)
	local tbAwardList	= self.tbAwardList;
	local tbWords		= {};
	tbWords.szPrayWords = "";
	tbWords.szPrayThing = "";

	for i=1, #tbElement do
		local nElement	= tbElement[i];
		if (nElement <= 0) then
			break;
		end

		if (not tbAwardList[nElement]) then
			if (nElement > 0) then
				self:WriteLog("Player Pray error at element, round", pPlayer.szName, nElement, i);
			end
			break;
		end

		tbWords.szPrayWords = tbAwardList[nElement].szPrayWords;
		tbWords.szPrayThing = tbAwardList[nElement].szPrayThing;

		tbAwardList = tbAwardList[nElement].tbSubData;	
	end
	return tbWords;
end

-- 具体奖励物品细节
function tbPlayerPray:GiveDetailAward(pPlayer, tbOneAward)
	local szType	= tbOneAward.szType;
	local szAward	= tbOneAward.szAward;
	local tbValue	= Lib:SplitStr(szAward, ",");
	if (not tbValue or #tbValue <= 0) then
		self:WriteLog("GiveDetailAward", "Award error szType, szAward", pPlayer.szName, szType, szAward);
		return;
	end
	self:WriteLog("GiveDetailAward", "Give player award", pPlayer.szName, szType, szAward);
	local tbNum = {};
	for i=1, #tbValue do
		tbNum[i] = tonumber(tbValue[i]);
	end
	if ("money" == szType) then
		pPlayer.Earn(tbNum[1], Player.emKEARN_BAI_QIU_LIN);
	elseif ("item" == szType) then
		local pItem = pPlayer.AddItem(unpack(tbNum));
		if (pItem) then
			pItem.Bind(1);
		end
	elseif ("exp" == szType) then
		pPlayer.AddExp(tbNum[1]);
	elseif ("effect" == szType) then
		pPlayer.AddSkillState(unpack(tbNum));
	elseif ("playertitle" == szType) then
		local nSex = tbNum[5];
		tbNum[5] = nil;
		if (nSex == 2) then
			pPlayer.AddTitle(unpack(tbNum));
		elseif (nSex == pPlayer.nSex) then
			pPlayer.AddTitle(unpack(tbNum));
		end
	elseif ("repute" == szType) then
		local nReputeExt = Item:GetClass("reputeaccelerate"):GetAndUseExtRepute(pPlayer, tbNum[1], tbNum[2], tbNum[3], 1);
		pPlayer.AddRepute(tbNum[1], tbNum[2], tbNum[3] + nReputeExt);
	else
		self:WriteLog("GiveDetailAward", "The type is no define or exist!", pPlayer.szName, szType, szAward);
	end
end

-- 申请获得祈福结果
function tbPlayerPray:OnApplyGetResult()
	local nInterval = me.GetTask(self.TSKGROUP, self.TASK_INTERVAL);
	if GetTime() - nInterval < self.MAX_INTERVAL then
		return 0;
	end
	
	me.SetTask(self.TSKGROUP, self.TASK_INTERVAL, GetTime());
	self:GivePrayResult();
end

function tbPlayerPray:EnablePray(pPlayer)
	pPlayer.SetTask(self.TSKGROUP, self.TSK_CLOSEPRAY, 0);
end

function tbPlayerPray:DisablePray(pPlayer)
	pPlayer.SetTask(self.TSKGROUP, self.TSK_CLOSEPRAY, 1);
end

-- 检查是否允许继续祈福
function tbPlayerPray:CheckAllowPray(pPlayer)
	if (1 == self.CLOSEPRAYSYS) then
		return 3;
	end
	
	if (me.nLevel < 50) then
		--self:WriteLog("CheckAllowPray", "Stop pray system by level!!!!!!!");		
		return 1;
	end

	local nClosFlag		= pPlayer.GetTask(self.TSKGROUP, self.TSK_CLOSEPRAY);
	if (nClosFlag == 1) then
		--self:WriteLog("CheckAllowPray", "Stop pray system by system forbid!!!!!!!");
		return 2;
	end

	-- 有奖未领的时候，不能祈福
	local nValue = pPlayer.GetTask(self.TSKGROUP, self.TSK_INDIRAWARDFLAG);
	if (1 == nValue) then
		--self:WriteLog("CheckAllowPray", string.format("Player %s have no pray", me.szName));
		return 3;
	end
	
	-- 没有祈福机会了
	local nPray = self:GetPrayCount(pPlayer);
	if (nPray <= 0) then
		--self:WriteLog("CheckAllowPray", string.format("Player %s have no chance for pray!", me.szName));
		return 3;
	end
	
	return 0;
end

-- 当玩家按确定的时候
function tbPlayerPray:GivePrayResult()
	local pPlayer		= me;
	
	-- 做祈福判断
	local nPrayFlag		= self:CheckAllowPray(pPlayer);
	if (0 < nPrayFlag) then
		if (1 == nPrayFlag) then
			pPlayer.Msg("Bạn chưa đạt cấp 50, không thể chúc phúc!!");
		elseif (2 == nPrayFlag) then
			pPlayer.Msg("Do lỗi server, hiện đã ngưng chức năng chúc phúc!!");			
		end	
		--self:WriteLog("GivePrayResult", string.format("Player %s is not allowed to pray!", pPlayer.szName));
		return;
	end

	-- 判断是否重新把元素变量清空
	local tbElement = {};
	for i=1, 5 do
		tbElement[#tbElement + 1] = self:GetPrayElement(pPlayer, i);
	end
	local tbAward		= self:GetAward(pPlayer, tbElement);
	if (#tbAward > 0) then
		pPlayer.SetTask(self.TSKGROUP, self.TSK_SAVEELEMENT, 0);
	end

	local nRound		= self:GetPrayResultCount(pPlayer);
	local nEleResult	= Random(5) + 1; -- 因为五行元素从1开始标记，所以要加1
	-- 一轮祈福次数超过了五次
	if (nRound >= 5) then
		--self:WriteLog("CheckAllowPray", string.format("Error!! Player %s pray time more then 5 times!", me.szName));
		return;
	end
	self:SetPrayElement(pPlayer, nRound + 1, nEleResult);
	
	-- 获取间接给的物品
	tbElement = {};
	for i=1, 5 do
		tbElement[#tbElement + 1] = self:GetPrayElement(pPlayer, i);
	end

	tbAward		= self:GetAward(pPlayer, tbElement);
	-- 当有了明确的奖励后就将完成一次祈福的变量设置为1
	if (#tbAward > 0) then
		
		-- 在这做减少次数的目的是为了
		--self:WriteLog("GivePrayResult", string.format("DecParyCount 1 time!!"));
		self:DecPrayCount(pPlayer);

		--self:WriteLog("GivePrayResult", "The pray have the result!!");
		pPlayer.SetTask(self.TSKGROUP, self.TSK_INDIRAWARDFLAG, 1);
		self:ProcessPrayAchievement(pPlayer);
	end

	pPlayer.CallClientScript({"Ui:ServerCall", "UI_PLAYERPRAY", "OnRecPrayResult", nEleResult});
end

-- 给予成就的函数
-- 这里可以考虑放在领取奖励的时候，而不是这样自动给，避免刷成就
function tbPlayerPray:ProcessPrayAchievement(pPlayer)
	-- 次数成就统计
	for _, nAchievementId in pairs(self.tbCountAchievement) do
		Achievement:FinishAchievement(pPlayer, nAchievementId);
	end
	
	local tbElement = {};
	for i=1, 5 do
		tbElement[#tbElement + 1] = self:GetPrayElement(pPlayer, i);
	end

	local tbAward		= self:GetAward(pPlayer, tbElement);
	if (not tbAward) then
		print("[Error] ProcessPrayAchievement there is no tbAward!!!");
		return 0;
	end
	for i=1, #tbAward do
		if (tbAward[i].szType == "achievement") then
			local szAward	= tbAward[i].szAward;
			local tbValue	= Lib:SplitStr(szAward, ",");
			if (not tbValue or #tbValue <= 0) then
				print("[Error] tbPlayerPray ProcessPrayAchievement", "Award error szType, szAward", pPlayer.szName, szType, szAward);
				return;
			end
			local nAchievementId = tonumber(tbValue[1]);
			Achievement:FinishAchievement(pPlayer, nAchievementId)
		end
	end	
end

function tbPlayerPray:GivePrayAnnouns(pPlayer, tbAward)
	-- 获取间接给的物品
	local tbElement = {};
	for i=1, 5 do
		tbElement[#tbElement + 1] = self:GetPrayElement(pPlayer, i);
	end
	
	local nFirstEle = tbElement[1];
	local nCnt		= 0;
	for i = 2, #tbElement do
		if (nFirstEle ~= tbElement[i]) then
			break;
		end
		nCnt = nCnt + 1;
	end
	-- 表示没有5个相同
	if (4 ~= nCnt) then
		return;
	end
	
	local szMsg = "";
	local szPopupMessage = "";
	local szTweet = "";

	for i=1, #tbAward do
		if (tbAward[i].szType == "playertitle") then
			szPopupMessage = "Ồ, hôm nay ngươi thật <color=yellow>may mắn<color>! <color=yellow>Chụp hình<color> lại tin này để chia sẻ cùng bạn bè nhé!";
			szMsg, szTweet = self:GetAnnounsMsg(pPlayer, nFirstEle);	
			break;
		end
	end
	if (string.len(szMsg) <= 0) then
		return;
	end
	KDialog.NewsMsg(0, Env.NEWSMSG_NORMAL, pPlayer.szName .. szMsg);
	if (pPlayer) then
		pPlayer.SendMsgToFriend("[" .. pPlayer.szName .. "]" .. szMsg);
		Player:SendMsgToKinOrTong(pPlayer, szMsg, 0);
		
		--向该玩家推送SNS通知
		Sns:NotifyClientNewTweet(pPlayer, szPopupMessage, szTweet);
	end
	return;
end

function tbPlayerPray:GetAnnounsMsg(pPlayer, nElement)
	local szTitle	= "";
	local szMsg		= "";
	local szTweet	= "";
	if (1 == nElement) then
		szMsg = " Chúc phúc được 5 Kim! Nhận danh hiệu <color=255,181,0>[Độc Cô Cầu Bại]<color>";
		szTweet = [["#Kiếm Thế# Chúc phúc 5 chữ Kim! Còn được danh hiệu "Độc Cô Cầu Bại"!
]];
	elseif (2 == nElement) then
		szMsg = " Chúc phúc được 5 Mộc! Nhận danh hiệu <color=255,181,0>[Thiên Hạ Vô Song]<color>";
		szTweet = [[#Kiếm Thế# Chúc phúc 5 chữ Mộc! Còn được danh hiệu "Thiên Hạ Vô Song"!
]];
	elseif (3 == nElement) then
		szMsg = " Chúc phúc được 5 Thủy!";
		if (pPlayer.nSex == 0) then
			szMsg = szMsg .. "và danh hiệu <color=255,181,0>[Phong Nam]<color> ";
			szTweet = [[#Kiếm Thế# Chúc phúc 5 chữ Thủy! Còn được danh hiệu "Phong Nam"!
]];
		elseif (pPlayer.nSex == 1) then
			szMsg = szMsg .. "và danh hiệu <color=255,181,0>[Tuyệt Đại Phương Hoa]<color> ";
			szTweet = [[#Kiếm Thế# Chúc phúc 5 chữ Thủy! Còn được danh hiệu "Tuyệt Đại Phương Hoa"!
]];
		end
	elseif (4 == nElement) then
		szMsg = " Chúc phúc được 5 Hỏa!";
		if (pPlayer.nSex == 0) then
			szMsg = szMsg .. "và danh hiệu <color=255,181,0>[Hiệp Khách Cuối Cùng Trên Giang Hồ]<color> ";
			szTweet = [[#Kiếm Thế# Chúc phúc 5 chữ Hỏa! Còn được danh hiệu "Hiệp Khách Cuối"!
]];
		elseif (pPlayer.nSex == 1) then
			szMsg = szMsg .. "và <color=255,181,0>[Hiệp Nữ Cuối Cùng Trên Giang Hồ]<color>";
			szTweet = [[#Kiếm Thế# Chúc phúc 5 chữ Hỏa! Còn được danh hiệu "Hiệp Nữ Cuối"!
]];
		end
	elseif (5 == nElement) then
		szMsg = " Chúc phúc được 5 Thổ!";
		if (pPlayer.nSex == 0) then
			szMsg = szMsg .. "và danh hiệu <color=255,181,0>[Thiên Chi Kiêu Tử]<color> ";
			szTweet = [[#Kiếm Thế# Chúc phúc 5 chữ Thổ! Còn được danh hiệu "Thiên Chi Kiêu Tử"!
]];
		elseif (pPlayer.nSex == 1) then
			szMsg = szMsg .. "và danh hiệu <color=255,181,0>[Thiên Chi Kiêu Nữ]<color> ";
			szTweet = [[#Kiếm Thế# Chúc phúc 5 chữ Thổ! Còn được danh hiệu "Thiên Chi Kiêu Nữ"!
]];
		end
	end
	return szMsg, szTweet;
end

function tbPlayerPray:DecPrayCount(pPlayer)
	local nUsedPray	= pPlayer.GetTask(self.TSKGROUP, self.TSK_PRAYCOUNT);
	local nDailyResetCount = self:GetDailyResetPrayCount(pPlayer);
	local nPray		= nDailyResetCount - nUsedPray;
	local nExPray	= pPlayer.GetTask(self.TSKGROUP, self.TSK_EXPRAYCOUNT);
	local nTodayUsed= pPlayer.GetTask(self.TSKGROUP, self.TSK_TODAYUSEDCOUNT);
	self:WriteLog("DecPrayCount", string.format("Player %s OrgSysPrayCount %d, OrgExPrayCount %d !!", pPlayer.szName, nPray, nExPray));
	if (nPray > 0) then
		nUsedPray = nUsedPray + 1;
		if (nUsedPray > nDailyResetCount) then
			nUsedPray = nDailyResetCount;
		end
		pPlayer.SetTask(self.TSKGROUP, self.TSK_PRAYCOUNT, nUsedPray);
		nTodayUsed = nTodayUsed + 1;
		pPlayer.SetTask(self.TSKGROUP, self.TSK_TODAYUSEDCOUNT, nTodayUsed);
		self:WriteLog("DecPrayCount", string.format("Player %s NowSysPrayCount %d, NowExPrayCount %d !!", pPlayer.szName, nDailyResetCount - nUsedPray, nExPray));
		return 1;
	end
	
	if (nExPray > 0) then
		nExPray = nExPray - 1;
		if (nExPray < 0) then
			nExPray = 0;
		end
		pPlayer.SetTask(self.TSKGROUP, self.TSK_EXPRAYCOUNT, nExPray);
		nTodayUsed = nTodayUsed + 1;
		pPlayer.SetTask(self.TSKGROUP, self.TSK_TODAYUSEDCOUNT, nTodayUsed);
		self:WriteLog("DecPrayCount", string.format("Player %s NowSysPrayCount %d, NowExPrayCount %d !!", pPlayer.szName, nDailyResetCount - nUsedPray, nExPray));
		return 1;	
	end
	
	return 0;
end

function tbPlayerPray:GetPrayCount(pPlayer)
	local nPray, nExPray = self:GetPrayDetailCount(pPlayer);
	return nPray + nExPray;
end

function tbPlayerPray:GetPrayDetailCount(pPlayer)
	local nUsedPray		= pPlayer.GetTask(self.TSKGROUP, self.TSK_PRAYCOUNT);
	local nPray			= self:GetDailyResetPrayCount(pPlayer) - nUsedPray;
	local nExPray		= pPlayer.GetTask(self.TSKGROUP, self.TSK_EXPRAYCOUNT);
	return nPray, nExPray;
end

function tbPlayerPray:OnApplyGetAward()
	
	local nInterval = me.GetTask(self.TSKGROUP, self.TASK_INTERVAL);
	if GetTime() - nInterval < self.MAX_INTERVAL then
		return 0;
	end
	
	--me.SetTask(self.TSKGROUP, self.TASK_INTERVAL, GetTime());
	
	self:GiveAward(me);
	me.CallClientScript({"Ui:ServerCall", "UI_PLAYERPRAY", "OnUpdatePrayState"});
	
	-- 师徒成就：祈福
	Achievement_ST:FinishAchievement(me.nId, Achievement_ST.QIFU);
	
	SpecialEvent.BuyOver:AddCounts(me, SpecialEvent.BuyOver.TASK_CHUCPHUC);
end

function tbPlayerPray:WriteLog(...)	
	if (MODULE_GAMESERVER) then
		Dbg:WriteLogEx(Dbg.LOG_INFO, "Help", "PlayerPray", unpack(arg));	
	end
	
	if (MODULE_GAMECLIENT) then
		Dbg:Output("Help", "PlayerPray", unpack(arg));
	end
end

function tbPlayerPray:_StaticPray(nMaxCount, tbEle)
	local pPlayer		= me;
	local nStatElement	= 0;
	for i=1, 5 do
		local nElement	= tbEle[i];
		local nBegin	= (i - 1) * 3;
		nStatElement	= Lib:SetBits(nStatElement, nElement, nBegin, nBegin + 2);
	end
	local nCount		= 0;
	local nStatCount	= 0;
	local nAllElement 	= 0;
	local nRound		= 0;
	local tbElement		= {};
	while nCount < nMaxCount do
		local nEleResult	= Random(5) + 1;
		tbElement[#tbElement + 1] = nEleResult;	
		local tbAward		= self:GetAward(pPlayer, tbElement);
		local tbEffect		= self:GetEffect(pPlayer, tbElement);		
		if (#tbAward > 0 or #tbEffect > 0) then
			local nStatEle	= 0;
			for i=1, #tbElement do
				local nElement	= tbElement[i];
				local nBegin	= (i - 1) * 3;
				nStatEle		= Lib:SetBits(nStatEle, nElement, nBegin, nBegin + 2);
			end
			if (nStatEle == nStatElement) then
				nStatCount = nStatCount + 1;
			end
			nAllElement = 0;
			nRound		= 0;
			tbElement	= {};
			nCount		= nCount + 1;			
		end
	end
	print(string.format("nCount = %d, nMaxCount = %d", nStatCount, nMaxCount));
end

function tbPlayerPray:GM_Refresh()
	self:ResetElementRound();
	me.SetTask(self.TSKGROUP, self.TSK_INDIRAWARDFLAG, 0);
end

-- 每天会重置祈福次数
function tbPlayerPray:ResetElementRound()
	self:ResetGiveCount(me);
	me.SetTask(self.TSKGROUP, self.TSK_PRAYCOUNT, 0);
	me.SetTask(self.TSKGROUP, self.TSK_TODAYUSEDCOUNT, 0);
end

function tbPlayerPray:Pray_OnLogin()
	self:ResetGiveCount(me);
end

function tbPlayerPray:ResetGiveCount(pPlayer)
	local nMoney = pPlayer.GetExtMonthPay();
	local nCount = 0;
	
	if Task.IVER_nResetGive == 1 then
		if (nMoney >= IVER_g_nPayLevel2 and pPlayer.nLevel >= 50) then
			nCount = 1;
		end	
	end
	
	-- *******合服优惠，合服7天后过期*******
	local nCoZoneTime	= KGblTask.SCGetDbTaskInt(DBTASK_COZONE_TIME);
	if GetTime() < nCoZoneTime + 7 * 24 * 60 * 60 and pPlayer.nLevel >= 50 then
			nCount = nCount + 1;
	end
	-- *************************************
	
	-- *******合服优惠，子服务器玩家可以获得额外祈福次数*******
	if (pPlayer.GetTask(self.TSKGROUP, self.TSK_IFGETEXTRACOUNT) < nCoZoneTime and 
		GetTime() < nCoZoneTime + 10 * 24 * 60 * 60 and pPlayer.nLevel >= 50) then
		
		local nExtraCount = self.DEF_COZONE_COMPOSE_MINDAY;
		
		if (pPlayer.IsSubPlayer() == 1) then
			nExtraCount = math.max(nExtraCount, math.floor(KGblTask.SCGetDbTaskInt(DBTASK_SERVER_STARTTIME_DISTANCE) / (24 * 3600)));
		end
		
		if (nExtraCount >= 0) then
			self:AddExPrayCount(pPlayer, nExtraCount);
		end
		pPlayer.SetTask(self.TSKGROUP, self.TSK_IFGETEXTRACOUNT, GetTime());
	end
	-- ********************************************************
	pPlayer.SetTask(self.TSKGROUP, self.TSK_GIVECOUNT, nCount);
end

-- 判断今天是否使用过祈福令牌，1表示今天已经使用过了，0表示没有用过
function tbPlayerPray:CheckLingPaiUsed(pPlayer, nNowTime)
	local nUsedTime = pPlayer.GetTask(self.TSKGROUP, self.TSK_USEDPRAYITEMFLAG);
	local nLastDay	= Lib:GetLocalDay(nUsedTime);
	local nNowDay	= Lib:GetLocalDay(nNowTime);
	if (nLastDay >= nNowDay) then
		return 1;
	end
	return 0;
end

function tbPlayerPray:AddCountByLingPai(pPlayer, nCount)
	self:AddExPrayCount(pPlayer, nCount);
	pPlayer.CallClientScript({"Ui:ServerCall", "UI_PLAYERPRAY", "OnUpdatePrayState"});
end

function tbPlayerPray:GetDailyResetPrayCount(pPlayer)
	local nMoneyPray = pPlayer.GetTask(self.TSKGROUP, self.TSK_GIVECOUNT);
	return self.SYSGIVECOUNT + nMoneyPray;
end

function tbPlayerPray:AddExPrayCount(pPlayer, nCount)
	local nLastCount = pPlayer.GetTask(self.TSKGROUP, self.TSK_EXPRAYCOUNT);
	nLastCount = nLastCount + nCount;
	pPlayer.SetTask(self.TSKGROUP, self.TSK_EXPRAYCOUNT, nLastCount);
	self:WriteLog("tbPlayerPray:AddExPrayCount", string.format("Player %s have add %d counts pray times!", pPlayer.szName, nCount));
end

function tbPlayerPray:SetLingPaiUsedTime(pPlayer, nTime)
	pPlayer.SetTask(self.TSKGROUP, self.TSK_USEDPRAYITEMFLAG, nTime);
end

if (MODULE_GAMESERVER) then
	tbPlayerPray:LoadPraySetting();
	PlayerSchemeEvent:RegisterGlobalDailyEvent({tbPlayerPray.ResetElementRound, tbPlayerPray});
	PlayerEvent:RegisterGlobal("OnLogin", tbPlayerPray.Pray_OnLogin, tbPlayerPray);
end

if (MODULE_GAMECLIENT) then
	tbPlayerPray:LoadPraySetting();
end

tbPlayerPray:init();
