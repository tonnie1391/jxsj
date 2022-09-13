
local tb	= Task:GetTarget("AnsewerTheQuestion_A");
tb.szTargetName	= "AnsewerTheQuestion_A";

tb.szColName_QId		= "Id"
tb.szColName_QContent	= "QuestionContent";	
tb.szColName_QAnswerA	= "Answer_A";
tb.szColName_QAnswerB	= "Answer_B";
tb.szColName_QAnswerC	= "Answer_C";
tb.szColName_QAnswerD	= "Answer_D";
tb.szColName_QCorrectIdx= "CorrectIdx";
tb.szColName_QPic		= "QuestionPic";


function tb:Init(nNpcTempId, nMapId, szOption, szPreDialog, szSuccDialog, szFailDialog, nErrorLimit, nPassNumber, szQLib, szRepeatMsg, bRandomMode, szBeforePop, szLaterPop, nCostMoney)
	self:OnIni();
	self.nNpcTempId		= nNpcTempId;
	self.szNpcTitle		= self:RemoveTitleColor(KNpc.GetTitleByTemplateId(nNpcTempId));
	self.szNpcName		= KNpc.GetNameByTemplateId(nNpcTempId);
	self.nMapId			= nMapId;
	self.szMapName		= Task:GetMapName(nMapId);
	self.szOption		= szOption;
	self.szPreDialog	= szPreDialog;
	self.szSuccDialog 	= szSuccDialog;
	self.szFailDialog 	= szFailDialog;
	self.nErrorLimit	= nErrorLimit;
	self.nPassNumber	= nPassNumber;
	self.tbQLib			= self:ParseQLib(szQLib);
	if (szRepeatMsg ~= "") then
		self.szRepeatMsg	= szRepeatMsg;
	end;
	self.bRandomMode	= bRandomMode;
	self.szBeforePop	= szBeforePop;
	self.szLaterPop		= szLaterPop;
	self.nCostMoney		= tonumber(nCostMoney);
	if (not self.nCostMoney) then
		self.nCostMoney = 0;
	end
end;

function tb:RemoveTitleColor(szTitle)
	if (not szTitle) then
		return "";
	end
	
	return string.gsub(szTitle, "<color([^>]*)>", "");
end

function tb:OnIni()
	self.tbQLibFile = Lib:NewClass(Lib.readTabFile, "\\setting\\task\\task_question_lib.txt");
end;

function tb:ParseQLib(szQLib)
	local tbQIdSet 	= Lib:SplitStr(szQLib, ",");
	
	local tbQLib = {};
	for i = 1, #tbQIdSet do
		local tbItem = {};
		tbItem.nId 					= self.tbQLibFile:GetCell(self.szColName_QId, 		tbQIdSet[i]-1);
		tbItem.szQuestionContent	= self.tbQLibFile:GetCell(self.szColName_QContent,	tbQIdSet[i]-1);
		tbItem.szAnswer_A			= self.tbQLibFile:GetCell(self.szColName_QAnswerA,	tbQIdSet[i]-1);
		tbItem.szAnswer_B			= self.tbQLibFile:GetCell(self.szColName_QAnswerB,	tbQIdSet[i]-1);
		tbItem.szAnswer_C			= self.tbQLibFile:GetCell(self.szColName_QAnswerC,	tbQIdSet[i]-1);
		tbItem.szAnswer_D			= self.tbQLibFile:GetCell(self.szColName_QAnswerD,	tbQIdSet[i]-1);
		tbItem.nCorrectIdx			= tonumber(self.tbQLibFile:GetCell(self.szColName_QCorrectIdx,tbQIdSet[i]-1));
		tbItem.szPic				= self.tbQLibFile:GetCell(self.szColName_QPic,		tbQIdSet[i]-1);
		
		tbQLib[i] = tbItem;
	end
	
	return tbQLib;
end;



function tb:Start()
	self.bDone		= 0;
	self:Register();
end;

function tb:Save(nGroupId, nStartTaskId)
	local pPlayer = self:Base_GetPlayerObj();
	if not pPlayer then
		return;
	end
	self.tbSaveTask	= {	-- 这里保存下来，以后随时可以自行同步客户端
		nGroupId		= nGroupId,
		nStartTaskId	= nStartTaskId,
	};
	pPlayer.SetTask(nGroupId, nStartTaskId, self.bDone);
	return 1;
end;

function tb:Load(nGroupId, nStartTaskId)
	local pPlayer = self:Base_GetPlayerObj();
	if not pPlayer then
		return;
	end
	self.tbSaveTask	= {	-- 这里保存下来，以后随时可以自行同步客户端
		nGroupId		= nGroupId,
		nStartTaskId	= nStartTaskId,
	};
	self.bDone		= pPlayer.GetTask(nGroupId, nStartTaskId);
	if (not self:IsDone() or self.szRepeatMsg) then	-- 本目标是一旦达成后不会失效的
		self:Register();
	end;

	return 1;
end;

function tb:IsDone()
	return self.bDone == 1;
end;

function tb:GetDesc()
	return self:GetStaticDesc();
end;

function tb:GetStaticDesc()
	local szMsg	= "回答";
	if (self.nMapId ~= 0) then
		szMsg	= szMsg..self.szMapName.."";
	end;
	szMsg	= szMsg..string.format("%s的问题", self.szNpcTitle..self.szNpcName);
	return szMsg;
end;

function tb:Close(szReason)
	self:UnRegister();
end;


function tb:Register()
	self.tbTask:AddNpcMenu(self.nNpcTempId, self.nMapId, self.szOption, self.OnTalkNpc, self);
end;

function tb:UnRegister()
	self.tbTask:RemoveNpcMenu(self.nNpcTempId);
end;


function tb:OnTalkNpc()
	local pPlayer = self:Base_GetPlayerObj();
	if not pPlayer then
		return;
	end
	if (self.nMapId ~= 0 and self.nMapId ~= pPlayer.GetMapId()) then
		Setting:SetGlobalObj(pPlayer);
		TaskAct:Talk("你要找的不是本地图的"..self.szNpcName.."请前往"..self.szMapName)
		Setting:RestoreGlobalObj();
		return;
	end;
	if (self:IsDone()) then
		if (self.szRepeatMsg) then
			Setting:SetGlobalObj(pPlayer);
			TaskAct:Talk(self.szRepeatMsg);
			Setting:RestoreGlobalObj();
		end;
		return;
	end;

	if (self.bRandomMode == 1) then
		Lib:SmashTable(self.tbQLib);
	end
	
	self:StartAnswer();
end;

-- 从第一题开始，逐个回答。
function tb:StartAnswer()
	local pPlayer = self:Base_GetPlayerObj();
	if not pPlayer then
		return;
	end
	self.nError 	= 0;
	self.nCurQIdx 	= 1;
	local szMsg = self.szPreDialog;
	szMsg = Lib:ParseExpression(szMsg);
	szMsg = Task:ParseTag(szMsg);
	if (self.nCostMoney > 0) then
		if (pPlayer.CostMoney(self.nCostMoney, Player.emKPAY_ANSWER) ~= 1) then
			pPlayer.Msg("你没有"..self.nCostMoney.."两银子，无法进入答题");
			return;
		end
	end
	
	Dialog:Say(szMsg,
				{
					{"开始答题", self.AnswerQuestion, self, 1}
				});
end;

-- 第二个参数表示是否需要标记出正确答案
function tb:AnswerQuestion(nIdx, bNeedMark)
	local szMsg = Lib:ParseExpression(self.tbQLib[nIdx].szQuestionContent);
	local szMsg = Task:ParseTag(szMsg);
	local szMsg = "<pic:"..self.tbQLib[nIdx].szPic..">"..szMsg;
	local szMsg = "<head:"..self:GetNpcPic()..">"..szMsg;
	
	local szAnswer_A = self.tbQLib[nIdx].szAnswer_A;
	local szAnswer_B = self.tbQLib[nIdx].szAnswer_B;
	local szAnswer_C = self.tbQLib[nIdx].szAnswer_C;
	local szAnswer_D = self.tbQLib[nIdx].szAnswer_D;
	if (bNeedMark and 1 == bNeedMark) then
		local nRightIndex = self.tbQLib[nIdx].nCorrectIdx;
		if (1 == nRightIndex) then
			szAnswer_A = string.format("<color=gold>%s<color>", self.tbQLib[nIdx].szAnswer_A);
		elseif (2 == nRightIndex) then
			szAnswer_B = string.format("<color=gold>%s<color>", self.tbQLib[nIdx].szAnswer_B);
		elseif (3 == nRightIndex) then
			szAnswer_C = string.format("<color=gold>%s<color>", self.tbQLib[nIdx].szAnswer_C);
		elseif (4 == nRightIndex) then
			szAnswer_D = string.format("<color=gold>%s<color>", self.tbQLib[nIdx].szAnswer_D);
		end
	end
	
	Dialog:Say(szMsg,
				{
				   {szAnswer_A, tb.OnSelect, self, 1, nIdx},
				   {szAnswer_B, tb.OnSelect, self, 2, nIdx},
				   {szAnswer_C, tb.OnSelect, self, 3, nIdx},
				   {szAnswer_D, tb.OnSelect, self, 4, nIdx},
				   {"以后再答", tb.OnSelect, self, -1, nIdx},
				});
end;



function tb:OnSelect(nAnswer, nIdx)
	local pPlayer = self:Base_GetPlayerObj();
	if not pPlayer then
		return;
	end
	if (nAnswer < 0) then
		return;
	end
	local bError = false;
	if (self.tbQLib[nIdx].nCorrectIdx ~= nAnswer) then
		self.nError = self.nError + 1;
		bError = true;
	end
	
	if (self.nError >= self.nErrorLimit) then
		Setting:SetGlobalObj(pPlayer);
		TaskAct:Talk(self.szFailDialog);
		Setting:RestoreGlobalObj();
		return;
	end
	
	-- 及格了
	if ((self.nPassNumber <= nIdx) and (not bError)) then
		Setting:SetGlobalObj(pPlayer);
		TaskAct:Talk(self.szSuccDialog, self.PassQuestion, self);
		Setting:RestoreGlobalObj();
		return;
	end
	
	if (bError) then
		self:AnswerQuestion(nIdx, 1);
		pPlayer.Msg("回答错误，请继续回答 ");
	else
		self:AnswerQuestion(nIdx + 1);
	end
end;

function tb:PassQuestion()
	local pPlayer = self:Base_GetPlayerObj();
	if not pPlayer then
		return;
	end
	self.bDone	= 1;
	local tbSaveTask	= self.tbSaveTask;
	if (MODULE_GAMESERVER and tbSaveTask) then	-- 自行同步到客户端，要求客户端刷新
		pPlayer.SetTask(tbSaveTask.nGroupId, tbSaveTask.nStartTaskId, self.bDone, 1);
		KTask.SendRefresh(pPlayer, self.tbTask.nTaskId, self.tbTask.nReferId, tbSaveTask.nGroupId);
	end;
	
	pPlayer.Msg("Mục tiêu: "..self:GetStaticDesc());
	
	if (not self.szRepeatMsg) then
		self:UnRegister()	-- 本目标是一旦达成后不会失效的
	end;

	self.tbTask:OnFinishOneTag();
end

-- 根据Npc模板获得它的图片
function tb:GetNpcPic(nTempId)
	return ""
end;


