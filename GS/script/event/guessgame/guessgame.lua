-------------------------------------------------------------------
--File: 	guessgame.lua
--Author: 	sunduoliang
--Date: 	2008-2-28 17:30:24
--Describe:	猜灯谜，触发
-------------------------------------------------------------------
if MODULE_GC_SERVER then
	return 0;
end

local BEGIN = 1;
local START = 2;
local GAMEOVER=3;
if EventManager.IVER_bGuessGame == 0 then
GuessGame.ANNOUCE_STATE_TRANS =
	{
		--标志 ， 时间 ， 次数 ， 执行函数， 定时公告
		{BEGIN,		1 * 60 * Env.GAME_FPS , 5 , "WaitGame" , "“Đoán Hoa Đăng” sẽ bắt đầu lúc 20:30 tại 8 Tân Thủ Thôn."},
		{START,		1 * 60 * Env.GAME_FPS , 30 , "StartGame", "“Đoán Hoa Đăng” đang diễn ra tại 8 Tân Thủ Thôn."},
		{GAMEOVER,	0 * 60 * Env.GAME_FPS , 1  , "GameOver" , "“Đoán Hoa Đăng” đã kết thúc rồi!"},
	}
else
GuessGame.ANNOUCE_STATE_TRANS =
	{
		--标志 ， 时间 ， 次数 ， 执行函数， 定时公告
		{BEGIN,		1 * 60 * Env.GAME_FPS , 10 , "WaitGame" , "“Đoán Hoa Đăng”全民同乐。“Đoán Hoa Đăng”活动开始时间为中午12:30。届时请侠士侠女们前往8大新手村寻找花灯，破解灯谜，展示你们的机智与博学。详情请到礼官处查询。"},
		{START,		5 * 60 * Env.GAME_FPS , EventManager.IVER_nGuessGameNum , "StartGame", string.format("“Đoán Hoa Đăng”活动（12:30 - %s）正在火热进行中，请前往8大新手村参加。", EventManager.IVER_szGuessGameEndTime)},
		{GAMEOVER,	0 * 60 * Env.GAME_FPS , 1  , "GameOver" , string.format("“Đoán Hoa Đăng”活动（12:30 - %s）已经结束。", EventManager.IVER_szGuessGameEndTime)},
	}
end
GuessGame.nAnnouceState = 0;	--阶段
GuessGame.nAnnouceCount = 0;	--每个阶段的每轮
GuessGame.TBCONFIG = 	--灯谜trap点 [地图ID] = "trap.txt"
{
	[1] = "\\setting\\event\\guessgame\\npctrap\\yunzhongzhen.txt",
	[2] = "\\setting\\event\\guessgame\\npctrap\\longmenzhen.txt",
	[3] = "\\setting\\event\\guessgame\\npctrap\\yonglezhen.txt",
	[4] = "\\setting\\event\\guessgame\\npctrap\\daoxiangcun.txt",
	[5] = "\\setting\\event\\guessgame\\npctrap\\jiangjincun.txt",
	[6] = "\\setting\\event\\guessgame\\npctrap\\shiguzhen.txt",
	[7] = "\\setting\\event\\guessgame\\npctrap\\longquncun.txt",
	[8] = "\\setting\\event\\guessgame\\npctrap\\balinjun.txt",
}
GuessGame.TBWEIWANG =
{--积分，威望，贡献
	GRADE   = {100, 150, 200, 250, 300},
	WEIWANG = {  2,   3,   4,   5,   6},
	GONGXIAN= {	 20,  25,  30,  35,  40},
}

GuessGame.NPC_CHAT = {
	"Cùng nhau Đoán Hoa Đăng nào!!!",
	"Ta có nhiều câu hỏi khó, có ai giải được không?",
	};
GuessGame.NPC_ID = 2703;	--刷npc的模版ID
GuessGame.NPC_AI_ID = 3633;	--刷AInpc模版ID
GuessGame.NPC_LEVEL = 1;		--刷npc的等级
GuessGame.NPC_SERIES = Env.SERIES_NONE; --刷npc的五行属性
GuessGame.TASK_GROUP_ID = 2012;		--任务变量，记录任务group
GuessGame.TASK_ALLCOUNT_ID = 1;		--任务变量，记录个人答题总题数
GuessGame.TASK_DATE_ID 	= 2;			--任务变量，记录答题日期
GuessGame.TASK_COUNT_ID = 3;			--任务变量，记录个人一轮答题题数
GuessGame.TASK_STATE_ID = 4;			--任务变量，记录玩家参加今天的第几轮
GuessGame.TASK_WRONG_ID = 5;			--任务变量，记录答题错误题号ID
GuessGame.TASK_WRONG_COUNT = 6;		--任务变量，记录连续答错题目次数
GuessGame.TASK_SHARE_ID = 7;			--任务变量，记录分享给队员次数
GuessGame.TASK_GRADE_ID = 8;			--任务变量，记录个人所得积分
GuessGame.TASK_ATTEND_GAME_ID = 9;			--任务变量，记录个人是否允许答题
GuessGame.TASK_GET_AWARD_ID = 10;			--任务变量，记录个人是否领取奖励

GuessGame.GUESS_COUNT_MAX = 6;		--一人一轮最多答题数
GuessGame.GUESS_ALLCOUNT_MAX = 60;--一人一天最多答题数
GuessGame.GUESS_SHARE = 30;				--一人最多共享队员次数
GuessGame.GUESS_MY_GRADE = 5;				--自己答对一题所得积分;
GuessGame.GUESS_SHARE_GRADE = 1;			--自己答对一题所得积分;
GuessGame.GUESS_WRONG_ONE_TIME = 5;		--自己答错一题提秒数;
GuessGame.GUESS_WRONG_MANY_TIME = 30;	--自己答错多题所停秒数;
GuessGame.GUESS_WRONG_MANY_COUNT = 3;	--自己答错所达到的多题数;		

GuessGame.BASEEXP_CONFIG = "\\setting\\player\\attrib_level.txt"        --基准奖励文件
GuessGame.QUESTION_CONFIG = "\\setting\\event\\guessgame\\question.txt";--题库
GuessGame.tbNpcPos = {};				--灯谜npc trap表
GuessGame.tbNpcIdList = {};			--灯谜npc ID
GuessGame.tbGuessQuestion = {};	--题库表
GuessGame.tbBaseAwardExp = {}		--奖励基准经验表

function GuessGame:StartGuessGame()	--开启游戏
	--print("GuessGame**********");
	self.nAnnouceState = 1;
	self.nAnnouceCount = 0;
	KDialog.NewsMsg(0, Env.NEWSMSG_NORMAL, self.ANNOUCE_STATE_TRANS[self.nAnnouceState][5]);
	self:GameStateOpen();
end

function GuessGame:GameStateOpen()	--定时开启
		if self.ANNOUCE_STATE_TRANS[self.nAnnouceState][2] == 0 or self.ANNOUCE_STATE_TRANS[self.nAnnouceState][2] == nil then
			return 0;
		end
		self.nTimerId = Timer:Register( self.ANNOUCE_STATE_TRANS[self.nAnnouceState][2] ,  self.GameSingleStateOpen,  self);
end

function GuessGame:GameSingleStateOpen()			--阶段轮次进程
	--print(self.nAnnouceState,self.nAnnouceCount)
	self.nAnnouceCount = self.nAnnouceCount + 1;
	local nTime = self.ANNOUCE_STATE_TRANS[self.nAnnouceState][2];
	--如果该阶段结束
	if self.nAnnouceCount >= self.ANNOUCE_STATE_TRANS[self.nAnnouceState][3] then 
		self.nAnnouceState = self.nAnnouceState + 1;
		self.nAnnouceCount = 0;
		if self.nAnnouceState == GAMEOVER then
			nTime = 0;
		end
	end
	self:CloseGame();
	KDialog.NewsMsg(0, Env.NEWSMSG_NORMAL, self.ANNOUCE_STATE_TRANS[self.nAnnouceState][5]);
	self:TimerStart(self.ANNOUCE_STATE_TRANS[self.nAnnouceState][4]); --一轮结束
	--print(self.ANNOUCE_STATE_TRANS[self.nAnnouceState][5]);    			 --开启新一轮
	return nTime;
end

function GuessGame:WaitGame()		--等待准备时间
	return 0;
end

function GuessGame:StartGame()
	if #self.tbNpcIdList ~= 0 then
		return;
	end
	self:AddNpc();
end

function GuessGame:CloseGame()		--关闭单轮游戏
	if self.tbNpcIdList ~= nil or #self.tbNpcIdList ~= 0 then 
		for nNpcNo=1, #self.tbNpcIdList do
			local pNpc = KNpc.GetById(self.tbNpcIdList[nNpcNo]);
			if pNpc ~= nil then
				pNpc.Delete();
			end
		end
	end

	self.tbNpcIdList = {};
end

function GuessGame:GameOver()			--游戏结束
	GuessGame.nAnnouceState = 0;
	GuessGame.nAnnouceCount = 0;
end

function GuessGame:TimerStart(szFunction)	--定时程序执行
	local nRet;
	if szFunction then
		local fncExcute = self[szFunction];
		if fncExcute then
			nRet = fncExcute(self);
			if nRet and nRet == 0 then	
				self:CloseGame();	-- 关闭活动
				return 0;
			end
		end
	end
end

function GuessGame:AddNpc()			--加载npc
	if self.tbNpcPos == nil or #self.tbNpcPos == 0 then
		self:LoadNpcPos();
	end
	for nMapId, tbAllPos in pairs(self.tbNpcPos) do
		local nWorldIdx = SubWorldID2Idx(nMapId);
		if (nWorldIdx >= 0) then	--如果在该组服务器上;
			local tbPos = tbAllPos[Random(#tbAllPos) + 1]
			local nMaxSec = math.floor(self.ANNOUCE_STATE_TRANS[2][2] / Env.GAME_FPS);
			-- Npc:OnSetFreeAI(nMapId, tbPos.nX, tbPos.nY, self.NPC_AI_ID, 5, 2, nMaxSec, 1000, self.NPC_ID, 15, self.NPC_CHAT)
			local pNPC = KNpc.Add2(self.NPC_ID, self.NPC_LEVEL, self.NPC_SERIES, nMapId * 1, math.floor(tbPos.nX / 32), math.floor(tbPos.nY / 32), 0, 0, 0);
			if pNPC == nil then
				-- print("猜迷题，召唤npc失败。");
				Dbg:WriteLog("猜迷题",  "召唤npc失败。");
			else
				-- print(nMapId,math.floor(tbPos.nX/32),math.floor(tbPos.nY/32))
				self.tbNpcIdList[#self.tbNpcIdList + 1] = pNPC.dwId;
			end	
		end
	end
end


function GuessGame:CheckLimit(pPlayer)	--条件判断
	if pPlayer == nil then
		return 0;
	end
	if pPlayer.nLevel < 30 or pPlayer.GetCamp() == 0 then
		return 0;
	end
	return 1;
end

local function fnStrValue(szVal)
	local varType = loadstring("return "..szVal)();
	if type(varType) == 'function' then
		return varType();
	else
		return varType;
	end
end

function GuessGame:StrVal(szParam)	--加载题库
	local szText = string.gsub(szParam, "<%%(.-)%%>", fnStrValue);
	return szText;
end

--加载数据------------------------
function GuessGame:LoadGuessQuestion()	--加载题库
	self.tbGuessQuestion = {};
	local tbsortpos = Lib:LoadTabFile(self.QUESTION_CONFIG);
	local nLineCount = #tbsortpos;
	for nLine=1, nLineCount do
		local nId  = #self.tbGuessQuestion + 1;
		local szQuestion = tbsortpos[nLine].Question;
		local szAnswer = tbsortpos[nLine].Answer;
		local nUseAble = tonumber(tbsortpos[nLine].Use) or 0;
		local szSelect1 = tbsortpos[nLine].Select1;
		local szSelect2 = tbsortpos[nLine].Setect2;
		if nUseAble == 0 then
			self.tbGuessQuestion[nId] = {};
			self.tbGuessQuestion[nId].szQuestion = self:StrVal(Lib:ClearStrQuote(szQuestion));
			self.tbGuessQuestion[nId].szAnswer 	= self:StrVal(Lib:ClearStrQuote(szAnswer));
			self.tbGuessQuestion[nId].szSelect1 = self:StrVal(Lib:ClearStrQuote(szSelect1));
			self.tbGuessQuestion[nId].szSelect2 = self:StrVal(Lib:ClearStrQuote(szSelect2));
		end
	end
end

function GuessGame:LoadNpcPos()		--从配置文件获得npc的trap
	for nMapId, szConfig in pairs(self.TBCONFIG) do 
		--print(nMapId,szConfig)
		local tbsortpos = Lib:LoadTabFile(szConfig);
		local nLineCount = #tbsortpos;
		self.tbNpcPos[nMapId] = {};
		for nLine=1, nLineCount do
			local nTrapX = tonumber(tbsortpos[nLine].TRAPX);
			local nTrapY = tonumber(tbsortpos[nLine].TRAPY);
			self.tbNpcPos[nMapId][nLine] = {};
			self.tbNpcPos[nMapId][nLine].nX = nTrapX;
			self.tbNpcPos[nMapId][nLine].nY = nTrapY;
		end
	end
end

--礼官对话------------------------

function GuessGame:OnDialog()
	local szTitle = "Hoạt động “Đoán Hoa Đăng” diễn ra ở khắp các Tân Thủ Thôn.";
	local tbOpt = 
	{
		{"Nhận phần thưởng", self.GetAward, self},
		{"Hướng dẫn", self.AboutGame, self},
		{"Kết thúc đối thoại"},
	};
	Dialog:Say(szTitle,tbOpt);
end

function GuessGame:GetAward()
		local pPlayer = me;
		local szSex = "Nữ hiệp";
		if pPlayer.nSex == Env.SEX_MALE then
			szSex = "Đại hiệp"
		end
		if self:CheckLimit(pPlayer) == 0 then
			Dialog:Say(string.format("Chỉ những %s đã gia nhập môn phái và cấp 30 trở lên mới có thể tham gia hoạt động này",szSex))
			return 0;
		end
		self:ClearPlayerData(pPlayer);
		
		if pPlayer.GetTask(self.TASK_GROUP_ID, self.TASK_GET_AWARD_ID) > 0 then
			Dialog:Say("Bạn đã nhận phần thưởng, mỗi ngày chỉ có thể nhận 1 lần.");
			return 0;
		end
		
		if pPlayer.GetTask(self.TASK_GROUP_ID, self.TASK_ALLCOUNT_ID) <= 0 then
			Dialog:Say("Bạn chưa tham gia hoạt động hôm nay.");
			return 0;			
		end
		
		if pPlayer.GetTask(self.TASK_GROUP_ID, self.TASK_ALLCOUNT_ID) < self.GUESS_ALLCOUNT_MAX then
			if self.nAnnouceState > 0 and self.nAnnouceState < GAMEOVER then
				if self.nAnnouceCount < self.ANNOUCE_STATE_TRANS[self.nAnnouceState][3] then
					local tbOpt = 
					{
						{"Xác nhận", self.SureGetAward, self, pPlayer},
						{"Ta muốn tiếp tục trả lời"},
					}; 
					Dialog:Say("Bạn có thể tiếp tục trả lời hoa đăng để nhận nhiều điểm hơn. Mỗi ngày chỉ có thể nhận thưởng 1 lần thôi đó.", tbOpt);
					return 0;		
				end
			end
		end
		self:SureGetAward(pPlayer)

end

function GuessGame:SureGetAward(pPlayer)
	if pPlayer == nil then
		return 0;
	end
	local nGrade = pPlayer.GetTask(self.TASK_GROUP_ID, self.TASK_GRADE_ID);
	
	local nFreeCount, tbExecute = SpecialEvent.ExtendAward:DoCheck("GuessGame", pPlayer, nGrade);
	if me.CountFreeBagCell() < nFreeCount then
		me.Msg(string.format("Hành trang không đủ <color=yellow>%s ô<color> trống.", nFreeCount));
		return 0;
	end
	SpecialEvent.ExtendAward:DoExecute(tbExecute);
	
	local nAddExp = math.floor( (nGrade / 200) * 120 * pPlayer.GetBaseAwardExp() );
	if nAddExp > 5000000 then
		nAddExp = 5000000;
	end
	local nAddExpReal = pPlayer.AddExp2(nAddExp,"guessgame");   -- mod zounan 修改经验接口
	local szMsg = string.format("Bạn có <color=yellow>%s<color> phần thưởng kinh nghiệm.", nAddExp);
	local nAddWeiWang = 0;
	local nAddGongXian=0;
	for nId = #self.TBWEIWANG.GRADE, 1, -1 do
		if nGrade >= self.TBWEIWANG.GRADE[nId] then
			nAddWeiWang = self.TBWEIWANG.WEIWANG[nId];
			nAddGongXian = self.TBWEIWANG.GONGXIAN[nId];
			break;
		end
	end
	if nAddWeiWang ~= 0 then
		pPlayer.AddKinReputeEntry(nAddWeiWang);	
	end
	if nAddGongXian ~= 0 then
	end
	pPlayer.SetTask(self.TASK_GROUP_ID, self.TASK_GET_AWARD_ID, 1);
	if nAddExpReal > 0 then
		pPlayer.Msg(szMsg);	
	end
	
	-- 记录玩家参加猜灯谜活动的次数
	Stats.Activity:AddCount(pPlayer, Stats.TASK_COUNT_GUESS, 1);
	
	Player:AddJoinRecord_DailyCount(pPlayer, Player.EVENT_JOIN_RECORD_DENGMI, 1);
	
	SpecialEvent.ActiveGift:AddCounts(pPlayer, 16);		--猜灯谜领奖活跃度
end

function GuessGame:AboutGame()
	local szTime = EventManager.IVER_szGuessGameEndTime;

	local szMsg = string.format("Mỗi ngày từ 20:30 đến 21:30, sẽ có những Hoa đăng cần sự giúp đỡ của mọi người.\n\n<color=yellow>Vị trí xuất hiện:<color> Các Tân Thủ Thôn\n<color=yellow>Yêu cầu tham gia:<color> Đã vào môn phái và cấp 30 trở lên\n<color=yellow>Phần thưởng:<color> Trước 23:59 cùng ngày, nhận thưởng tại Lễ Quan, điểm tích lũy sẽ không được cộng dồn khi qua ngày mới.");
	Dialog:Say(szMsg);
end

function GuessGame:ClearPlayerData(pPlayer)
	local nDate = pPlayer.GetTask(self.TASK_GROUP_ID, self.TASK_DATE_ID);
	local nNowDate = tonumber(GetLocalDate("%y%m%d"));		
	if nDate ~= nNowDate then
		pPlayer.SetTask(self.TASK_GROUP_ID, self.TASK_DATE_ID, nNowDate);
		pPlayer.SetTask(self.TASK_GROUP_ID, self.TASK_COUNT_ID, 0);
		pPlayer.SetTask(self.TASK_GROUP_ID, self.TASK_SHARE_ID, 0);
		pPlayer.SetTask(self.TASK_GROUP_ID, self.TASK_WRONG_ID, 0);
		pPlayer.SetTask(self.TASK_GROUP_ID, self.TASK_WRONG_COUNT, 0);
		pPlayer.SetTask(self.TASK_GROUP_ID, self.TASK_STATE_ID, 0);
		pPlayer.SetTask(self.TASK_GROUP_ID, self.TASK_ALLCOUNT_ID, 0);
		pPlayer.SetTask(self.TASK_GROUP_ID, self.TASK_GRADE_ID, 0);
		pPlayer.SetTask(self.TASK_GROUP_ID, self.TASK_ATTEND_GAME_ID, 0);
		pPlayer.SetTask(self.TASK_GROUP_ID, self.TASK_GET_AWARD_ID, 0);
	end
end

--帮助锦囊接口
function GuessGame:GetAnswerCount(pPlayer)
	if self:CheckLimit(pPlayer) == 0 then
		return 0, 0;
	end
	self:ClearPlayerData(pPlayer);
	local nGetAward = pPlayer.GetTask(self.TASK_GROUP_ID, self.TASK_GET_AWARD_ID);
	local nAllCount = pPlayer.GetTask(self.TASK_GROUP_ID, self.TASK_ALLCOUNT_ID);
	return nGetAward, nAllCount;
end
-----

--服务端专用
if (MODULE_GAMESERVER) then
	if GuessGame.tbNpcPos == nil or #GuessGame.tbNpcPos == 0 then
		GuessGame:LoadNpcPos();	--读取npc trap点
	end
	
	if GuessGame.tbGuessQuestion == nil or #GuessGame.tbGuessQuestion == 0 then
		GuessGame:LoadGuessQuestion();	--读取题库
	end
	
end
