---
-- 逍遥谷猜谜NPC
---

local XoyoNpc_Guess = Npc:GetClass("xoyonpc_guess");

function XoyoNpc_Guess:OnDialog(bConfirm)
	if not him then
		return 0;
	end
	local tbTmp = him.GetTempTable("XoyoGame")
	if not tbTmp then
		return 0;
	end
	if not tbTmp.tbRoom then
		return 0;
	end
	local nTeamId = me.nTeamId;
	local nPlayerId = tbTmp.tbRoom:GetTeamGuessPlayer(nTeamId);
	local tbMemberList, nCount = KTeam.GetTeamMemberList(nTeamId);
	local tbOpt = {}
	local szMsg = {};
	if me.nId == tbMemberList[1] then
		if not bConfirm or bConfirm ~= 1 then
			local szMsg = "Đội trưởng phải sẵn sàng trả lời câu hỏi. Rất dễ dàng, trả lời 30 câu trong thời gian còn lại. Vâng, tôi đưa ra câu hỏi, các thành viên trong đội có thể biết, đội trưởng có thể tham khảo ý kiến rồi đưa ra đáp án.";
			local tbTeamInfo = tbTmp.tbRoom:GetTeamInfo(nTeamId);
			if not tbTeamInfo then
				return ;
			end
			if tbTeamInfo.nQuestCount and tbTeamInfo.nQuestCount < XoyoGame.GUESS_QUESTIONS then
				szMsg = "Ngươi phải trả lời 30 câu hỏi của ta, ngươi có sẵn sàng trả lời hết?"
			elseif 	tbTeamInfo.nQuestCount and tbTeamInfo.nQuestCount >= XoyoGame.GUESS_QUESTIONS then
				tbTmp.tbRoom:AskQuestion(nTeamId, him.dwId);
				return 0;
			end
			Dialog:Say(szMsg,
				{
					{"Sẵn sàng!", self.OnDialog, self, 1},
					{"Tôi cần chuẩn bị chút nữa"},
				});
			return 0;
		end
		tbTmp.tbRoom:AskQuestion(nTeamId, him.dwId);
	else
		Dialog:Say("Hãy bảo đội trưởng của ngươi đến gặp ta");
		return 0;
	end
end
