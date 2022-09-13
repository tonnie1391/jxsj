
Require("\\script\\player\\player.lua");
if (MODULE_GAMECLIENT) then
	-- C
	-- 开始切磋
	function Player:StartExerciseMsg(szName)
		local szMsg = "Ngươi đã thiết lập quan hệ tỷ thí với <color=yellow>"..szName.."<color>."
		UiManager:OpenWindow(Ui.UI_INFOBOARD, szMsg);
	end

	-- C
	-- 准备仇杀
	function Player:PreEnmityMsg(szName)
		local szMsg = "<color=yellow>"..szName.."<color> sau 10 giây sẽ thiết lập quan hệ cừu sát với ngươi!"
		UiManager:OpenWindow(Ui.UI_INFOBOARD, szMsg);
	end
	
	-- 开始仇杀
	function Player:StartEnmityMsg(szName)
		local szMsg = "Ngươi đã thiết lập quan hệ tỷ thí với <color=yellow>"..szName.."<color>."
		UiManager:OpenWindow(Ui.UI_INFOBOARD, szMsg);
	end
end



--S
if (MODULE_GAMESERVER) then
	-- 切磋结束
	function Player:CloseExerciseMsg(pWinPlayer, pLosePlayer)
		local szMsg = "Hoàn tất quan hệ tỷ thí, ngươi đã thắng <color=yellow>"..pLosePlayer.szName.."<color>"
		Dialog:SendInfoBoardMsg(pWinPlayer, szMsg);
		
		local szMsg = "Hoàn tất quan hệ tỷ thí, ngươi đã thua <color=yellow>"..pWinPlayer.szName.."<color>";
		Dialog:SendInfoBoardMsg(pLosePlayer, szMsg);
	end
	
	function Player:SucStealState(pLauncher, pTarget, nSkillId, nSkillLevel)
		local szMsg = " từ "..pTarget.szName.." lấy được cấp "..nSkillLevel.."<color=yellow>"..FightSkill:GetSkillName(nSkillId).."<color>";
		Dialog:SendInfoBoardMsg(pLauncher, szMsg);
	end
	
	function Player:StealStateTimeOut()
		
	end
	
	function Player:StealFailed(pLauncher)
		local szMsg = " lấy thất bại!";
		Dialog:SendInfoBoardMsg(pLauncher, szMsg);
	end
end




