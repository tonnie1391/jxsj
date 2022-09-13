-------------------------------------------------------------------
--File: 	huadeng.lua
--Author: 	sunduoliang
--Date: 	2008-3-3 19:00
--Describe:	猜谜花灯
-------------------------------------------------------------------

local tbGuessGame = Npc:GetClass("huadengshizhe");

function tbGuessGame:OnDialog()
	self:StartDialog(him.dwId)
end

function tbGuessGame:StartDialog(nHimId)
		--local pHim = KNpc.GetById(nHimId)
		--if pHim == nil then
		--	return 0;
		--end
		if me.GetTiredDegree1() == 2 then
			Dialog:Say("您太累了，还是休息下吧！");
			return;
		end	
		tbGuessGame._tbBase = GuessGame;
		local pPlayer = me;
		local szSex = "Hiệp nữ";
		if pPlayer.nSex == Env.SEX_MALE then
			szSex = "Hiệp sĩ "
		end
		if self:CheckLimit(pPlayer) == 0 then
			Dialog:Say("Gia nhập môn phái và đạt cấp 30 mới được tham gia hoạt động.")
			return 0;
		end
		

		local nState = pPlayer.GetTask(self.TASK_GROUP_ID, self.TASK_STATE_ID);
		local nStopSec = pPlayer.GetTask(self.TASK_GROUP_ID, self.TASK_ATTEND_GAME_ID);
		self:ClearPlayerData(pPlayer);
		if pPlayer.GetTask(self.TASK_GROUP_ID, self.TASK_GET_AWARD_ID) > 0 then
			Dialog:Say("Bạn đã nhận phần thưởng, mỗi ngày chỉ nhận 1 lần.");
			return 0;
		end
		
		if nStopSec > 0 then
			if nStopSec >= GetTime() then
				Dialog:Say("Trả lời sai, tạm dừng một vài giây để suy nghĩ.");
				return 0;
			else
				self:StartGameAgain(pPlayer.nId)
			end
		end
		
		if self.nAnnouceCount ~= nState then
			pPlayer.SetTask(self.TASK_GROUP_ID, self.TASK_STATE_ID, self.nAnnouceCount);
			pPlayer.SetTask(self.TASK_GROUP_ID, self.TASK_SHARE_ID, 0);
			pPlayer.SetTask(self.TASK_GROUP_ID, self.TASK_COUNT_ID, 0);
		end
		
		if pPlayer.GetTask(self.TASK_GROUP_ID, self.TASK_ALLCOUNT_ID) == 0 and pPlayer.GetTask(self.TASK_GROUP_ID, self.TASK_WRONG_COUNT) == 0 and pPlayer.GetTask(self.TASK_GROUP_ID, self.TASK_WRONG_ID) == 0 then
			local szMsg = string.format("：我这里有几个灯谜，实在是猜不出了，%s帮我看看好不好？",szSex)
			self:ShowMovie(szMsg, self.CreateDialog, nHimId, pPlayer.nId)--to do 电影效果
			-- 记录参加次数
			local nNum = pPlayer.GetTask(StatLog.StatTaskGroupId , 5) + 1;
			pPlayer.SetTask(StatLog.StatTaskGroupId , 5, nNum);
			return 0;
		end
		self:CreateDialog(nHimId, pPlayer.nId)
end

function tbGuessGame:CreateDialog(nHimId, nPlayerId)
		local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
		--local pHim = KNpc.GetById(nHimId)
		if pPlayer == nil then
			return 0;
		end
	  
		if pPlayer.GetTask(self.TASK_GROUP_ID, self.TASK_ALLCOUNT_ID) >= self.GUESS_ALLCOUNT_MAX then --如果今天已答完30题
			Setting:SetGlobalObj(pPlayer);
			Dialog:Say(string.format("Đã đoán hết %s câu hỏi, hãy đến Lễ Quan nhận thưởng.", self.GUESS_ALLCOUNT_MAX));
			Setting:RestoreGlobalObj();	
			return 0;
		end
		
		if pPlayer.GetTask(self.TASK_GROUP_ID, self.TASK_COUNT_ID) >= self.GUESS_COUNT_MAX then --如果本轮已答完6题
			Setting:SetGlobalObj(pPlayer);
			Dialog:Say(string.format("Đã đoán %s câu đố, hãy đợi vòng sau tiếp tục.", self.GUESS_COUNT_MAX));
			Setting:RestoreGlobalObj();	
			return 0;
		end
		local tbNowQuestion = {};
		local nQquestionId = pPlayer.GetTask(self.TASK_GROUP_ID, self.TASK_WRONG_ID);
		if nQquestionId ~= 0 then
			tbNowQuestion = self.tbGuessQuestion[nQquestionId]
		else
			nQquestionId, tbNowQuestion = self:GetQuestion()
		end
		local tbOpt = {
			{tbNowQuestion.szAnswer, self.RightAnswer, self, nQquestionId, nHimId},
			{tbNowQuestion.szSelect1, self.WrongAnswer, self, nQquestionId, nHimId},
			{tbNowQuestion.szSelect2, self.WrongAnswer, self, nQquestionId, nHimId},
		}
		tbOpt = self:GetRandomTable(tbOpt, #tbOpt);
		table.insert(tbOpt, {"Kết thúc đối thoại"});
		pPlayer.SetTask(self.TASK_GROUP_ID, self.TASK_WRONG_ID, nQquestionId);
		Dialog:Say(tbNowQuestion.szQuestion, tbOpt);
end

function tbGuessGame:RightAnswer(nQquestionId, nHimId)
	local pPlayer = me;
	--local pHim = KNpc.GetById(nHimId)
	if pPlayer == nil then
		return 0;
	end
	--KStatLog.ModifyAdd("RoleWeeklyEvent", me.szName, "本周参加答题次数", 1);
		
	pPlayer.SetTask(self.TASK_GROUP_ID, self.TASK_COUNT_ID, pPlayer.GetTask(self.TASK_GROUP_ID, self.TASK_COUNT_ID) + 1 );
	pPlayer.SetTask(self.TASK_GROUP_ID, self.TASK_ALLCOUNT_ID, pPlayer.GetTask(self.TASK_GROUP_ID, self.TASK_ALLCOUNT_ID) + 1 );
	pPlayer.SetTask(self.TASK_GROUP_ID, self.TASK_WRONG_ID, 0 );
	pPlayer.SetTask(self.TASK_GROUP_ID, self.TASK_WRONG_COUNT, 0);
	self:ShareRightAnswer(pPlayer);
	pPlayer.AddBindMoney(10000);
	if pPlayer.GetTask(self.TASK_GROUP_ID, self.TASK_ALLCOUNT_ID) >= self.GUESS_ALLCOUNT_MAX then
		local szSex = "Tỉ tỉ";
		if pPlayer.nSex == Env.SEX_MALE then
			szSex = "Ca ca"
		end
		local szMsg = string.format(": %s, người đã hoàn thành hết tất cả câu đố hôm nay rồi!",szSex);
		self:ShowMovie(szMsg, 0, 0, pPlayer.nId)--to do 电影效果
		self:GetAchiemement(pPlayer);	-- 师徒成就：回答正确所有问题
		return 0;
	elseif pPlayer.GetTask(self.TASK_GROUP_ID, self.TASK_COUNT_ID) >= self.GUESS_COUNT_MAX then
		Dialog:Say("Chúc mừng bạn đã trả lời tất cả các câu hỏi ở vòng này!");
	else
		local tbOpt =
		{
			{"Tiếp tục trả lời", self.StartDialog, self, nHimId},
			{"Kết thúc đối thoại"},
		};
		Dialog:Say("Người có muốn tiếp tục không?",tbOpt);
	end
end

function tbGuessGame:ShareRightAnswer(pPlayer)
	if pPlayer == nil then
		return 0;
	end
	local tbTeamMemberList = pPlayer.GetTeamMemberList();
	if tbTeamMemberList == nil then
		pPlayer.SetTask(self.TASK_GROUP_ID,self.TASK_GRADE_ID, pPlayer.GetTask(self.TASK_GROUP_ID,self.TASK_GRADE_ID) + self.GUESS_MY_GRADE);
		pPlayer.Msg(string.format("Trả lời đúng, nhận <color=yellow>%s điểm<color> tích lũy.", self.GUESS_MY_GRADE))
	else
		for _, pMemPlayer in pairs(tbTeamMemberList) do
			local nGrade = self.GUESS_MY_GRADE;
			if self:CheckLimit(pMemPlayer) ~= 0 then --是否符合非白名玩家
				if pPlayer.nMapId == pMemPlayer.nMapId then --是否在同地图
					if pPlayer.nId ~= pMemPlayer.nId then			--是否是答对题目的玩家
						self:ClearPlayerData(pMemPlayer);
						if self.nAnnouceCount ~= pMemPlayer.GetTask(self.TASK_GROUP_ID, self.TASK_STATE_ID) then
							pMemPlayer.SetTask(self.TASK_GROUP_ID, self.TASK_STATE_ID, self.nAnnouceCount);
							pMemPlayer.SetTask(self.TASK_GROUP_ID, self.TASK_SHARE_ID, 0);
							pMemPlayer.SetTask(self.TASK_GROUP_ID, self.TASK_COUNT_ID, 0);
						end
						if pMemPlayer.GetTask(self.TASK_GROUP_ID, self.TASK_GET_AWARD_ID) <= 0 and pMemPlayer.GetTask(self.TASK_GROUP_ID, self.TASK_SHARE_ID) < self.GUESS_SHARE then
							nGrade =  self.GUESS_SHARE_GRADE;
							pMemPlayer.Msg(string.format("Đồng đội <color=yellow>%s<color> trả lời đúng, bạn nhận được <color=yellow>%s điểm<color> tích lũy. ", pPlayer.szName, nGrade))
							pMemPlayer.SetTask(self.TASK_GROUP_ID, self.TASK_SHARE_ID, pMemPlayer.GetTask(self.TASK_GROUP_ID, self.TASK_SHARE_ID) + 1);
						else
							nGrade = 0;
						end
					else
						pMemPlayer.Msg(string.format("Bạn trả lời chính xác, nhận <color=yellow>%s điểm<color> tích lũy. ", nGrade))
					end 
					if nGrade ~= 0 then
						pMemPlayer.SetTask(self.TASK_GROUP_ID,self.TASK_GRADE_ID, pMemPlayer.GetTask(self.TASK_GROUP_ID,self.TASK_GRADE_ID) + nGrade);
					end
				end
			end
		end	
	end
	return 0;
end

function tbGuessGame:WrongAnswer(nQquestionId, nHimId)
	local pPlayer = me;
	--local pHim = KNpc.GetById(nHimId)
	if pPlayer == nil then
		return 0;
	end
	pPlayer.SetTask(self.TASK_GROUP_ID, self.TASK_WRONG_ID, nQquestionId);
	pPlayer.SetTask(self.TASK_GROUP_ID, self.TASK_WRONG_COUNT, pPlayer.GetTask(self.TASK_GROUP_ID, self.TASK_WRONG_COUNT) + 1 );
	local nStopTime = self.GUESS_WRONG_ONE_TIME;
	local szMsg = string.format("Câu trả lời sai rồi, hãy suy nghĩ thêm %s giây nữa nhé!", nStopTime);
	if pPlayer.GetTask(self.TASK_GROUP_ID, self.TASK_WRONG_COUNT) >= self.GUESS_WRONG_MANY_COUNT then
		nStopTime = self.GUESS_WRONG_MANY_TIME;
		szMsg = string.format("Liên tục trả lời sai %s lần rồi, xem ra cần khá nhiều thời gian để tìm hiểu. Hãy tìm hiểu thêm %s giây rồi trả lời tiếp!", pPlayer.GetTask(self.TASK_GROUP_ID, self.TASK_WRONG_COUNT), nStopTime);
	end
	self:ShowStopTime(pPlayer, nStopTime)
	Dialog:Say(szMsg);
	return 0;
end

function tbGuessGame:ShowStopTime(pPlayer,nStopTime)
		if pPlayer == nil then
			return 0;
		end
		local nTimerId = Timer:Register(  nStopTime * Env.GAME_FPS,  self.StartGameAgain,  self, pPlayer.nId);
		local nLastFrameTime = tonumber(Timer:GetRestTime(nTimerId));
		local szMsgFormat = "<color=green>Thời gian còn lại: <color><color=white>%s<color>";
		pPlayer.SetTask(self.TASK_GROUP_ID, self.TASK_ATTEND_GAME_ID, (GetTime() + nStopTime));
		Dialog:SetBattleTimer(pPlayer,  szMsgFormat,  nLastFrameTime);
		Dialog:SendBattleMsg(pPlayer,  "\nKhông thể tiếp tục trả lời");
		Dialog:ShowBattleMsg(pPlayer,  1,  0); --开启界面
		return 0;
end

function tbGuessGame:StartGameAgain(nPlayerId)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if (not pPlayer) then
		return 0;
	end
	if pPlayer then
		pPlayer.SetTask(self.TASK_GROUP_ID, self.TASK_ATTEND_GAME_ID, 0);	
		Dialog:ShowBattleMsg(pPlayer,  0,  0); -- 关闭界面
	end
	return 0;
end

function tbGuessGame:ShowMovie(szMsg, szfun, nHimId, nPlayerId)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if pPlayer == nil then
		return 0;
	end
	local szMessage = string.format("<npc=%s>%s", self.NPC_ID, szMsg);
	Setting:SetGlobalObj(pPlayer);
	if szfun == 0 or szfun == nil then
		TaskAct:Talk(szMessage);
	else
		TaskAct:Talk(szMessage, szfun, self, nHimId, nPlayerId);
	end
	Setting:RestoreGlobalObj();	
	return 0;
end

function tbGuessGame:GetRandomTable(tbitem, nmax)
	for ni = 1, nmax do
		local p = Random(nmax) + 1;
		tbitem[ni], tbitem[p] = tbitem[p], tbitem[ni];
	end
	return tbitem;	
end

function tbGuessGame:GetQuestion()
	local nQId = Random(#self.tbGuessQuestion) + 1;
	return nQId, self.tbGuessQuestion[nQId];
end

-- 师徒成就：在一次猜灯谜活动中回答正确所有的问题
function tbGuessGame:GetAchiemement(pPlayer)
	if (not pPlayer) then
		return;
	end
	Achievement_ST:FinishAchievement(pPlayer.nId, Achievement_ST.DENGMI);
end
