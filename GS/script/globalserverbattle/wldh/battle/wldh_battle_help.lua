-------------------------------------------------------
-- 文件名　：wldh_battle_help.lua
-- 创建者　：zhangjinpin@kingsoft
-- 创建时间：2009-10-14 20:20:05
-- 文件描述：
-------------------------------------------------------

Require("\\script\\globalserverbattle\\wldh\\battle\\wldh_battle_def.lua");

local tbBattle = Wldh.Battle;

function tbBattle:UpdateFinalHelp(nStep)
	
	local nKey = Wldh.LADDER_ID[5][5];
	local szTitle = Wldh.LADDER_ID[5][1].."决赛战报";
	local nAddTime = GetTime();
	local nEndTime = nAddTime + 3600 * 24 * 30;
	
	local szMsg = "";
	if not self.tbFinalList then
		return 0;
	end

	if self.tbFinalList and #self.tbFinalList > 0 then
		szMsg = szMsg .. "<color=yellow>四强对阵表<color>\n\n";
		for i = 1, 2 do
			local szName  = "<color=gray>无参赛队伍<color>";
			local szVsName  = "<color=gray>无参赛队伍<color>";
			
			if self.tbFinalList[1][i] then
				szName = "<color=pink>" .. self.tbFinalList[1][i][1] .. "<color>";
				szVsName ="<color=pink>" .. self.tbFinalList[1][i][2] .. "<color>";
			end
			szMsg = szMsg .. Lib:StrFillR(szName, 37) .. Lib:StrFillC("对阵", 8) .. szVsName .. "\n";
		end
		
		szMsg = szMsg .. "\n";
		
		if nStep >= 2 then
			szMsg = szMsg .. "<color=yellow>决赛对阵表<color>\n\n";
			
			local szName  = "<color=gray>无参赛队伍<color>";
			local szVsName  = "<color=gray>无参赛队伍<color>";
			
			if self.tbFinalList[2] then
				szName = "<color=pink>" .. self.tbFinalList[2][1] .. "<color>";
				szVsName ="<color=pink>" .. self.tbFinalList[2][2] .. "<color>";
			end
			szMsg = szMsg .. Lib:StrFillR(szName, 37) .. Lib:StrFillC("对阵", 8) .. szVsName .. "\n";
		end
		
		szMsg = szMsg .. "\n";
		
		if nStep >= 3 then
			szMsg = szMsg .. "<color=yellow>冠军队伍：<color>\n";
			
			local szName  = "<color=gray>无参赛队伍<color>";
			
			if self.tbFinalList[3] then
				szName = "<color=pink>" .. self.tbFinalList[3][1] .. "<color>";
			end
			szMsg = szMsg .. Lib:StrFillR(szName, 37) .. "\n";
		end
	end
	
	Task.tbHelp:AddDNews(nKey, szTitle, szMsg, nEndTime, nAddTime);
end
