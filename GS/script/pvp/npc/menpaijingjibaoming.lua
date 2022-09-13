-------------------------------------------------------------------
--File: 	menpaizhanbaomingdian.lua
--Author: 	zhengyuhua
--Date: 	2008-1-9 9:32
--Describe:	门派战报名点端脚本
-------------------------------------------------------------------

local tbNpc = Npc:GetClass("menpaijingjibaoming");

function tbNpc:OnDialog()
	local nFaction = tonumber(him.GetSctiptParam());
	local tbData = FactionBattle:GetFactionData(nFaction);
	if not tbData then
		Dialog:Say("Hiện không có thi đấu môn phái",
			{
				{"Ta muốn rời khỏi trận đấu", FactionBattle.LeaveMap, FactionBattle, nFaction},
				{"Để ta suy nghĩ đã"}
			}
		);
		return 0;
	end
	local nCount = tbData:GetAttendPlayuerCount()
	local tbOpt = 
	{
			{"Ta muốn báo danh thi đấu môn phái", FactionBattle.SignUp, FactionBattle, nFaction},
			{"Ta muốn rời khỏi trận đấu", FactionBattle.LeaveMap, FactionBattle, nFaction},
			{"Ta muốn suy nghĩ lại"}
	}
	if tbData.nState == FactionBattle.SIGN_UP then
		table.insert(tbOpt, 2, {"Ta muốn hủy báo danh", FactionBattle.CancelSignUp, FactionBattle, nFaction});
	end
	
	if FactionBattle._MODEL_NEW == FactionBattle.FACTIONBATTLE_MODLE then
		table.insert(tbOpt, #tbOpt - 1, {"Tân thi đấu chế nói rõ", FactionBattle.DescribNewModel, FactionBattle, nFaction});
	end
	
	Dialog:Say("Hiện số người báo danh là "..nCount.." người", tbOpt);
end
