-------------------------------------------------------------------
--File: 	helpquestion.lua
--Author: 	sunduoliang
--Date: 	2008-3-6 16:30:24
--Describe:	帮助问答
-------------------------------------------------------------------

HelpQuestion.tbGroup = {};
HelpQuestion.QUESTION_CONFIG = "\\setting\\event\\helpquestion\\question.txt";
HelpQuestion.GROUP_CONFIG = "\\setting\\event\\helpquestion\\group.txt";
HelpQuestion.tbPlayerIdList = {};
HelpQuestion.RIGHT = 1;
HelpQuestion.WRONG = 0;
HelpQuestion.TASK_GROUP_ID = 2021;
function HelpQuestion:GetTitleTable(pPlayer)
	if pPlayer == nil then
		return 0;
	end
	local tbTitle = {};
	if self.tbGroup == nil or #self.tbGroup == 0 then
		self:LoadGroup();
	end
	local nCount = 0;
	for nGroupId, tbGroupInfo in pairs(self.tbGroup) do
		if self:CheckLimit(pPlayer, nGroupId) == 1 then
			tbTitle[nGroupId] = tbGroupInfo.szTitle;
			nCount = nCount + 1;
		end 
	end
	return tbTitle, nCount;
end

--自己指令测试使用(打开题库)
--function HelpQuestion:TestTable(pPlayer)
--	local tb = self:GetTitleTable(pPlayer)
--	local tbopt = {}
--	for x, y in pairs(tb) do
--		tbopt[#tbopt+1] = {y,self.StartGame,self,pPlayer,x}
--	end
--	Dialog:Say("题组,单服测试用.",tbopt);
--end

function HelpQuestion:StartGame(pPlayer, nGroupId)
	if pPlayer == nil then
		return 0;
	end
	if self:CheckLimit(pPlayer, nGroupId) == 0 then
		return 0;
	end
	local szAwardMsg = "";
	local nSign = 0;
	if self.tbGroup[nGroupId].nAwardMoney ~= 0 then
		szAwardMsg = string.format("<color=yellow>%s两<color>奖励", self.tbGroup[nGroupId].nAwardMoney);
		nSign = 1;
	end
	if nSign == 1 then
		szAwardMsg = szAwardMsg .. "和";
	end
	if self.tbGroup[nGroupId].nAwardCoin ~= 0 then
		szAwardMsg = string.format("%s<color=yellow>%s个<color>绑定%s奖励", szAwardMsg, self.tbGroup[nGroupId].nAwardCoin, IVER_g_szCoinName);
	end
	local szNeedMoney = "";
	nSign = 0;
	if self.tbGroup[nGroupId].nMoney > 0 then
		szNeedMoney = string.format("<color=yellow>%s两<color>", self.tbGroup[nGroupId].nMoney);
		nSign = 1;
	end
	if nSign == 1 then
		szNeedMoney = szNeedMoney .. "和";
	end
	
	if self.tbGroup[nGroupId].nBindMoney > 0 then
		szNeedMoney = string.format("<color=yellow>%s绑定银两<color>", self.tbGroup[nGroupId].nBindMoney);
	end
	
	local szMsg = string.format("    欢迎来到非常剑侠有奖问答，您只需交纳%s就可以参加本次有奖答题，只要您能回答正确<color=yellow>%s个<color>关于剑侠世界的小问题，就会获得%s，如果中途答错或者自己选择退出，不仅没有奖励，您交纳的%s也不会退还。怎么样，要参加吗？", szNeedMoney, self.tbGroup[nGroupId].nQuestionMax, szAwardMsg, szNeedMoney);
	local tbOpt =
	{
		{"当然要参加！", self.AppleGoOnGame, self, pPlayer, nGroupId},
		{"我还没准备好，待会再来吧。"},
	}
	Dialog:Say(szMsg,tbOpt);
end

function HelpQuestion:AppleGoOnGame(pPlayer, nGroupId)
	if pPlayer == nil then
		return 0;
	end
	if self:CheckLimit(pPlayer, nGroupId) == 0 then
		return 0;
	end
	if pPlayer.nCashMoney < self.tbGroup[nGroupId].nMoney then
		Dialog:Say("唉呀～您带的钱好像不够哦，很抱歉不能让您参加答题了。","我去凑够报名费再过来。");
		return 0;
	end
	if pPlayer.GetBindMoney() < self.tbGroup[nGroupId].nBindMoney then
		Dialog:Say("唉呀～您带的钱好像不够哦，很抱歉不能让您参加答题了。","我去凑够报名费再过来。");
		return 0;
	end	
	if self.tbGroup[nGroupId].nMoney > 0 then
		if pPlayer.CostMoney(self.tbGroup[nGroupId].nMoney, Player.emKPAY_HELP_QUESTION) == 0 then
			return 0;
		end
	end
	if self.tbGroup[nGroupId].nBindMoney > 0 then
		if pPlayer.CostBindMoney(self.tbGroup[nGroupId].nBindMoney, Player.emKBINDMONEY_COST_HELP_QUESTION) == 0 then
			return 0;
		end
	end	
	self.tbPlayerIdList[pPlayer.nId] = 0;
	self:DoStartGame(pPlayer, nGroupId);
end

function HelpQuestion:DoStartGame(pPlayer, nGroupId)
	if pPlayer == nil then
		return 0;
	end
	if self:CheckLimit(pPlayer, nGroupId) == 0 then
		return 0;
	end
	self.tbPlayerIdList[pPlayer.nId] = self.tbPlayerIdList[pPlayer.nId] + 1;
	local nNowQId = self.tbPlayerIdList[pPlayer.nId];
	if self.tbGroup[nGroupId].tbQuestion == nil or #self.tbGroup[nGroupId].tbQuestion == 0 then
		self:LoadQuestion()
	end
	if nNowQId > #self.tbGroup[nGroupId].tbQuestion then
		self:Award(pPlayer, nGroupId)
		return 1;
	end
	
	local szQuestion = self.tbGroup[nGroupId].tbQuestion[nNowQId].szQuestion;
	local tbAnswser = {};
	tbAnswser[1] = {self.tbGroup[nGroupId].tbQuestion[nNowQId].szAnswer, self.CheckAnswer, self, pPlayer, nGroupId, self.RIGHT};
	
	for nQ = 1, 3 do 
		local szSelect = self.tbGroup[nGroupId].tbQuestion[nNowQId].tbSelect[nQ]
		if szSelect ~= nil and szSelect ~= "" then
			tbAnswser[#tbAnswser+1] = {self.tbGroup[nGroupId].tbQuestion[nNowQId].tbSelect[nQ], self.CheckAnswer, self, pPlayer, nGroupId, self.WRONG};
		end
	end
	tbAnswser = self:GetRandomTable(tbAnswser, #tbAnswser);
	table.insert(tbAnswser, {"以后再答"});
	Dialog:Say(szQuestion, tbAnswser);
end

function HelpQuestion:CheckAnswer(pPlayer, nGroupId, nIsRight)
	if pPlayer == nil then
		return 0;
	end
	if nIsRight == self.WRONG then
		local tbOpt =
		{
			{"重新挑战。", self.StartGame, self, pPlayer, nGroupId},
			{"先不答了，待会再来。"},
		}
		Dialog:Say("唉呀，这道题答错了哟，重新来过吧。",tbOpt);
		return 0;
	end
	if nIsRight == self.RIGHT then
		self:DoStartGame(pPlayer, nGroupId);
	end
end

function HelpQuestion:Award(pPlayer, nGroupId)
	if self.tbGroup[nGroupId].nAwardMoney ~= 0 then
		pPlayer.Earn(self.tbGroup[nGroupId].nAwardMoney, Player.emKEARN_HELP_QUESTION);
		KStatLog.ModifyAdd("jxb", "[产出]剑侠词典", "总量", self.tbGroup[nGroupId].nAwardMoney);
	end
	
	if self.tbGroup[nGroupId].nAwardCoin ~= 0 then
		pPlayer.AddBindCoin(self.tbGroup[nGroupId].nAwardCoin, Player.emKBINDCOIN_ADD_HELP_QUESTION);
		pPlayer.Msg(string.format("恭喜你获得了<color=yellow>%s<color>个绑定%s",self.tbGroup[nGroupId].nAwardCoin, IVER_g_szCoinName));
		KStatLog.ModifyAdd("bindcoin", "[产出]剑侠词典", "总量", self.tbGroup[nGroupId].nAwardCoin);
	end
	pPlayer.SetTaskBit(HelpQuestion.TASK_GROUP_ID,nGroupId,1);
	Dialog:Say("恭喜您全部回答正确！奖励已经发给您了哟。");
	
	-- 完成师徒成就
	Achievement_ST:FinishAchievement(pPlayer.nId, Achievement_ST.JXCIDIAN);
end

function HelpQuestion:CheckLimit(pPlayer,nGroupId)
	if pPlayer == nil then
		return 0;
	end
	if not self.tbGroup[nGroupId] then
		return 0;
	end
	if pPlayer.nLevel < self.tbGroup[nGroupId].nLevel then
		--Dialog:Say("您的等级不够，不能参加本组答题。");
		return 0;
	end
	if pPlayer.GetTaskBit(HelpQuestion.TASK_GROUP_ID,nGroupId) ~= 0 then
		--Dialog:Say("您已经答过该题。");
		return 0;
	end
	return 1;
end

function HelpQuestion:GetRandomTable(tbitem, nmax)
	for ni = 1, nmax do
		local p = Random(nmax) + 1;
		tbitem[ni], tbitem[p] = tbitem[p], tbitem[ni];
	end
	return tbitem;	
end

function HelpQuestion:LoadQuestion()
	if self.tbGroup == nil or #self.tbGroup == 0 then
		self:LoadGroup();
	end
	local tbQuestionFile = Lib:LoadTabFile(self.QUESTION_CONFIG);
	if tbQuestionFile == nil then
		return 0;
	end
	local nLineCount = #tbQuestionFile;	--加载题库信息
	for nLine=1, nLineCount do
		local nGroupId  = tonumber(tbQuestionFile[nLine].GROUPID);
		--local nId = tonumber(tbQuestionFile[nLine].QID);
		local szQuestion = tbQuestionFile[nLine].QUESTION;
		local szAnswer = tbQuestionFile[nLine].ANSWER;
		local szSelect1 = tbQuestionFile[nLine].SELECT1;
		local szSelect2 = tbQuestionFile[nLine].SELECT2;
		local szSelect3 = tbQuestionFile[nLine].SELECT3;
		if self.tbGroup[nGroupId].tbQuestion == nil then
			self.tbGroup[nGroupId].tbQuestion = {};
		end
		local nId = #self.tbGroup[nGroupId].tbQuestion + 1;
		self.tbGroup[nGroupId].tbQuestion[nId] = {};
		self.tbGroup[nGroupId].tbQuestion[nId].szQuestion = szQuestion;
		self.tbGroup[nGroupId].tbQuestion[nId].szAnswer = szAnswer;
		self.tbGroup[nGroupId].tbQuestion[nId].tbSelect = {}
		self.tbGroup[nGroupId].tbQuestion[nId].tbSelect[1] = szSelect1;
		self.tbGroup[nGroupId].tbQuestion[nId].tbSelect[2] = szSelect2;
		self.tbGroup[nGroupId].tbQuestion[nId].tbSelect[3] = szSelect3;
		self.tbGroup[nGroupId].nQuestionMax = self.tbGroup[nGroupId].nQuestionMax + 1;
	end
end

function HelpQuestion:LoadGroup()		--加载题组信息
	self.tbGroup = {};
	local tbQuestionFile = Lib:LoadTabFile(self.GROUP_CONFIG);
	if tbQuestionFile == nil then
		return 0;
	end
	local nLineCount = #tbQuestionFile;
	for nLine=1, nLineCount do
		local nGroupId  = tonumber(tbQuestionFile[nLine].GROUPID);
		local nLevel = tonumber(tbQuestionFile[nLine].LEVEL) or 0;
		--local nGouHuo = tonumber(tbQuestionFile[nLine].GOUHUO) or 0;
		local nMoney = tonumber(tbQuestionFile[nLine].MONEY) or 0;
		local nBindMoney = tonumber(tbQuestionFile[nLine].BINDMONEY) or 0;
		local nAwardMoney = tonumber(tbQuestionFile[nLine].AWARD_MONEY) or 0;
		
		local nAwardCoin = tonumber(tbQuestionFile[nLine].AWARD_COIN) or 0;
		local szTitle = tbQuestionFile[nLine].TITLE;
		self.tbGroup[nGroupId] = {};
		self.tbGroup[nGroupId].nLevel = nLevel;
		--self.tbGroup[nGroupId].nGouHuo = nGouHuo;
		self.tbGroup[nGroupId].szTitle = szTitle;
		self.tbGroup[nGroupId].nMoney = nMoney;
		self.tbGroup[nGroupId].nBindMoney = nBindMoney;
		self.tbGroup[nGroupId].nAwardMoney = nAwardMoney;
		self.tbGroup[nGroupId].nAwardCoin = nAwardCoin;
		self.tbGroup[nGroupId].nQuestionMax = 0;
	end
end

if HelpQuestion.tbGroup == nil or #HelpQuestion.tbGroup == 0 then
	HelpQuestion:LoadGroup();
	HelpQuestion:LoadQuestion();
end
