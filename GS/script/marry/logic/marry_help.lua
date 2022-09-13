-------------------------------------------------------
-- 文件名　：marry_help.lua
-- 创建者　：zhangjinpin@kingsoft
-- 创建时间：2010-01-27 18:44:31
-- 文件描述：
-------------------------------------------------------

Require("\\script\\marry\\logic\\marry_def.lua");

if (not MODULE_GAMESERVER) then
	return 0;
end

-- 皇家婚礼
function Marry:UpdateHelpSuper(nDay)
	
	local nRet, szMaleName, szFemaleName, _, szDate = Marry:GetCurWeekSuperInfo(nDay);	
	
	if nRet then
		
		local nAddTime = GetTime();
		local nEndTime = nAddTime + 60 * 60 * 24 * 30;
		local nKinIdMale = KKin.GetPlayerKinMember(KGCPlayer.GetPlayerIdByName(szMaleName));
		local nKinIdFemale = KKin.GetPlayerKinMember(KGCPlayer.GetPlayerIdByName(szFemaleName));
		local pKinMale = KKin.GetKin(nKinIdMale);
		local pKinFemale = KKin.GetKin(nKinIdFemale);
		
		local szMaleKin = "Vô";
		local szFemaleKin = "Vô";
		
		if pKinMale then
			szMaleKin = pKinMale.szName;
		end
		
		if pKinFemale then
			szFemaleKin = pKinFemale.szName;
		end
		
		szMaleKin = szMaleKin .. " 家族";
		szFemaleKin= szFemaleKin .. " 家族";
		
		local szMsg = string.format([[
	
<bclr=red><color=yellow>本周举办【皇家典礼】的是：<color><bclr>
	
<color=yellow>    %s<color>
	
<bclr=red>%s<bclr>  <pic=49>  <bclr=red>%s<bclr>
<color=gold>%s<color>       <color=gold>%s<color>

<color=yellow>    如果一生中只能实现一个愿望，那么我愿给我最珍惜人以最真的情意！典礼的礼乐已经奏响，在这烟火灿烂的每一个瞬间，我们的整个世界都将变得绚丽、新奇！<color>
            <pic=\image\effect\fightskill\public\jiehun\qw.spr>

]], szDate, Lib:StrFillR(szMaleName, 30), Lib:StrFillL(szFemaleName, 30), Lib:StrFillR(szMaleKin, 30), Lib:StrFillL(szFemaleKin, 30));
		
		Task.tbHelp:AddDNews(Task.tbHelp.NEWSKEYID.NEWS_MARRY_SUPER, "本周举办的【皇家典礼】", szMsg, nEndTime, nAddTime);
	end
end

-- 每日婚礼
function Marry:UpdateHelpDaily(nDate)
	
	local tbMsg = {[1] = "", [2] = "", [3] = "", [4] = ""};
	local nCurrDate = nDate or tonumber(GetLocalDate("%Y%m%d"));	
	for nWeddingLevel, tbMap in pairs(self.tbGlobalBuffer) do
		local tbRow = tbMap[nCurrDate];
		if tbRow then
			if nWeddingLevel <= 2 then
				for nIndex, tbInfo in pairs(tbRow) do
					tbMsg[nWeddingLevel] = tbMsg[nWeddingLevel] 
						.. string.format("<color=yellow>%s<color>", Lib:StrFillR(tbInfo[1], 16)) 
						.. " 和 "
						.. string.format("<color=yellow>%s<color>", Lib:StrFillL(tbInfo[2], 16));
					if math.mod(#tbMsg[nWeddingLevel], 2) == 0 then
						tbMsg[nWeddingLevel] = tbMsg[nWeddingLevel] .. "\n";
					end
				end
			else
				tbMsg[nWeddingLevel] = string.format("<color=yellow>%s<color>", Lib:StrFillR(tbRow[1], 16))
				.. " 和 " .. string.format("<color=yellow>%s<color>", Lib:StrFillL(tbRow[2], 16));
			end
		end
	end
	
	local nAddTime = GetTime();
	local nEndTime = nAddTime + 60 * 60 * 24 * 30;
		
	local szMsg = string.format([[
<color=yellow>今日举办的典礼名单：<color>

<bclr=red><color=yellow>皇家典礼<color><bclr>
    %s

<bclr=blue><color=yellow>王侯典礼<color><bclr>
    %s

<color=gold>贵族典礼<color>
    %s

<color=green>侠士典礼<color>
    %s
]], tbMsg[4], tbMsg[3], tbMsg[2], tbMsg[1]);
		
	Task.tbHelp:AddDNews(Task.tbHelp.NEWSKEYID.NEWS_MARRY_DAILY, "今日举办的【典礼名单】", szMsg, nEndTime, nAddTime);
end
