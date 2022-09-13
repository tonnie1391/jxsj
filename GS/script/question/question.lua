-- 文件名　：question.lua
-- 创建者　：furuilei
-- 创建时间：2010-05-17 14:22:43
-- 功能描述：通用的答题系统

Question.szQuestionFile = "\\setting\\question\\question.txt";
Question.tbQuestion = {};
Question.MAX_NUM = 100;

--================================

-- 加载question文件
function Question:LoadQuestion()
	local tbQuestionSetting = Lib:LoadTabFile(self.szQuestionFile);
	self.tbQuestion = {};
	
	local nLastGroup = -1;
	local nQuestionId = 0;
	for nRow, tbRowData in pairs(tbQuestionSetting) do

		local nGroupId = tonumber(tbRowData["GroupId"]);
		if (nLastGroup ~= nGroupId) then
			nLastGroup = nGroupId;
			nQuestionId = 0;
		end
		nQuestionId = nQuestionId + 1;
		local nAnswerId = tonumber(tbRowData["AnswerId"]);
		
		if (not self.tbQuestion[nGroupId]) then
			self.tbQuestion[nGroupId] = {};
		end
		if (not self.tbQuestion[nGroupId][nQuestionId]) then
			self.tbQuestion[nGroupId][nQuestionId] = {};
		end
		
		local tbTemp = self.tbQuestion[nGroupId][nQuestionId];
		local szQuestion = tostring(tbRowData["Question"]) or "你太有才了！";
		tbTemp.nAnswerId = nAnswerId;
		tbTemp.szQuestion = szQuestion;
		tbTemp.tbChoice = {};
		for i = 1, Question.MAX_NUM do
			local szKey = "Choice_" .. i;
			local szChoice = tostring(tbRowData[szKey]);
			if (not szChoice or szChoice == "nil") then
				break;
			end
			tbTemp.tbChoice[i] = szChoice;
		end
	end
	-- Lib:ShowTB(Question.tbQuestion);
end

Question:LoadQuestion();

--================================

-- 根据groupid和quesitonid获取某一个问题的具体信息
function Question:GetQuestionInfo(nGroupId, nQuestionId)
	if (not nGroupId or not nQuestionId) then
		return;
	end
	
	local tbQuestion = self.tbQuestion;
	if (not tbQuestion) then
		return;
	end
	if (not tbQuestion[nGroupId]) then
		return;
	end
	return tbQuestion[nGroupId][nQuestionId];
end

-- 获取随机的题目id
function Question:GetRandomQuestionId(nTotalNum, nRandomNum)
	if (not nTotalNum or not nRandomNum or nTotalNum <= 0 or nRandomNum <= 0) then
		return;
	end
	
	local tbRet = {};
	if (nTotalNum <= nRandomNum) then
		for i = 1, nTotalNum do
			table.insert(tbRet, i);
		end
		return tbRet;
	end
	
	local tbTempRecord = {};
	for i = 1, nRandomNum do
		local nRandom = MathRandom(1, nTotalNum);
		while (tbTempRecord[nRandom]) do
			nRandom = MathRandom(1, nTotalNum);
		end
		tbTempRecord[nRandom] = nRandom;
	end
	for nRandom, _ in pairs(tbTempRecord) do
		table.insert(tbRet, nRandom);
	end
	return tbRet;
end

-- 为外界提供的调用接口
-- 回答在nGroupId下的nNum 个题目
-- szFun 一个回调函数，如果全部题目回答正确回调的时候参数为1，否则参数为0
function Question:Ask_Smash(nGroupId, nNum, szFun)
	if (not nGroupId or not nNum or not szFun) then
		return;
	end
	
	if (not self.tbQuestion or not self.tbQuestion[nGroupId]) then
		return;
	end
	
	local nTotalQuestionNum = Lib:CountTB(self.tbQuestion[nGroupId]);
	local tbQuestionId = self:GetRandomQuestionId(nTotalQuestionNum, nNum);
	local tbQuestion = {};
	for _, nQuestionId in pairs(tbQuestionId) do
		local tbSpeQuestion = self:GetQuestionInfo(nGroupId, nQuestionId);
		if (tbSpeQuestion) then
			table.insert(tbQuestion, tbSpeQuestion);
		end
	end
	
	self:Ask(tbQuestion, 1, szFun);
end

-- 为外界提供的调用接口
-- 回答nGroupId 下面所有的题目
-- szFun 一个回调函数，如果全部题目回答正确回调的时候参数为1，否则参数为0
function Question:Ask_Group(nGroupId, szFun)
	if (not nGroupId or not szFun) then
		return;
	end
	
	local tbQuestion = self.tbQuestion[nGroupId] or {};
	
	self:Ask(tbQuestion, 1, szFun);
end

-- 为外界提供的调用接口
-- 回答nGroupId, nQuestionId 唯一指定的一个题目
-- szFun 一个回调函数，如果全部题目回答正确回调的时候参数为1，否则参数为0
function Question:Ask_Special(nGroupId, nQuestionId, szFun)
	if (not nGroupId or not szFun) then
		return;
	end
	
	local tbSpeQuestion = self:GetQuestionInfo(nGroupId, nQuestionId);
	if (not tbSpeQuestion) then
		return;
	end
	
	local tbQuestion = {};
	table.insert(tbQuestion, tbSpeQuestion);
	
	self:Ask(tbQuestion, 1, szFun);
end

-- 判断是否已经答完了所有题目
function Question:IsAnswerAllQue(tbQuestion, nQuestionIndex)
	if (not tbQuestion or not nQuestionIndex) then
		return 1;
	end
	if (tbQuestion[nQuestionIndex]) then
		return 0;
	end
	return 1;
end

-- 为外界提供的调用接口
-- 回答在nGroupId下的nNum个题目
-- szFun一个回调函数，回调参数为答对题目的数量
function Question:Ask_Stream(nGroupId, nNum, szFun)
	
	if (not nGroupId or not nNum or not szFun) then
		return;
	end
	
	if (not self.tbQuestion or not self.tbQuestion[nGroupId]) then
		return;
	end
	
	local nTotalQuestionNum = Lib:CountTB(self.tbQuestion[nGroupId]);
	local tbQuestionId = self:GetRandomQuestionId(nTotalQuestionNum, nNum);
	local tbQuestion = {};
	for _, nQuestionId in pairs(tbQuestionId) do
		local tbSpeQuestion = self:GetQuestionInfo(nGroupId, nQuestionId);
		if (tbSpeQuestion) then
			table.insert(tbQuestion, tbSpeQuestion);
		end
	end
	
	self:Ask2(tbQuestion, 1, szFun, 0);
end

--==============================

function Question:Ask(tbQuestion, nQuestionIndex, szFun)
	if (not tbQuestion or not szFun) then
		return;
	end
	
	local tbSpeQuestion = tbQuestion[nQuestionIndex];
	if (not tbSpeQuestion) then
		return;
	end
	
	local nRightAnswer = tbSpeQuestion.nAnswerId;
	local szQuestion = tbSpeQuestion.szQuestion;
	local tbChoice = tbSpeQuestion.tbChoice;
	local tbOpt = {};
	for nIndex, szChoice in ipairs(tbChoice) do
		table.insert(tbOpt, {szChoice, self.Answer, self, tbQuestion, nIndex, nRightAnswer, nQuestionIndex, szFun});
	end
	Dialog:Say(szQuestion, tbOpt);
end

function Question:Answer(tbQuestion, nIndex, nRightAnswer, nQuestionIndex, szFun)
	if (not nIndex or not nRightAnswer or not nQuestionIndex or not szFun) then
		return;
	end
	
	if (nIndex ~= nRightAnswer) then
		loadstring(szFun .. "(0)")();
		return;
	end
	
	nQuestionIndex = nQuestionIndex + 1;
	local bIsAnswerAllQue = self:IsAnswerAllQue(tbQuestion, nQuestionIndex);
	if (1 == bIsAnswerAllQue) then
		loadstring(szFun .. "(1)")();
		return;
	else
		self:Ask(tbQuestion, nQuestionIndex, szFun);
		return;
	end
end

--=============================================

function Question:Ask2(tbQuestion, nQuestionIndex, szFun, nRight)
	
	if (not tbQuestion or not szFun) then
		return;
	end
	
	local tbSpeQuestion = tbQuestion[nQuestionIndex];
	if (not tbSpeQuestion) then
		return;
	end
	
	local nRightAnswer = tbSpeQuestion.nAnswerId;
	local szQuestion = tbSpeQuestion.szQuestion;
	local tbChoice = tbSpeQuestion.tbChoice;
	local tbOpt = {};
	for nIndex, szChoice in ipairs(tbChoice) do
--		if nIndex == nRightAnswer then
--			table.insert(tbOpt, {"<color=yellow>" .. szChoice .. "<color>", self.Answer2, self, tbQuestion, nIndex, nRightAnswer, nQuestionIndex, szFun, nRight});
--		else
			table.insert(tbOpt, {szChoice, self.Answer2, self, tbQuestion, nIndex, nRightAnswer, nQuestionIndex, szFun, nRight});
--		end
	end
	Dialog:Say(szQuestion, tbOpt);
end

function Question:Answer2(tbQuestion, nIndex, nRightAnswer, nQuestionIndex, szFun, nRight)
	
	if (not nIndex or not nRightAnswer or not nQuestionIndex or not szFun or not nRight) then
		return;
	end
	
	local nCurRight = nRight;
	
	if (nIndex == nRightAnswer) then
		nCurRight = nCurRight + 1;
	end
	
	nQuestionIndex = nQuestionIndex + 1;
	local bIsAnswerAllQue = self:IsAnswerAllQue(tbQuestion, nQuestionIndex);
	if (1 == bIsAnswerAllQue) then
		loadstring(szFun .. string.format("(%s)", nCurRight))();
		return;
	else
		self:Ask2(tbQuestion, nQuestionIndex, szFun, nCurRight);
		return;
	end
end

--=============================================
