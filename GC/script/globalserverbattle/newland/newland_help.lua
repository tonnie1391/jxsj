-------------------------------------------------------
-- 文件名　：newland_help.lua
-- 创建者　：zhangjinpin@kingsoft
-- 创建时间：2010-09-03 15:41:55
-- 文件描述：
-------------------------------------------------------

Require("\\script\\globalserverbattle\\newland\\newland_def.lua");

-- 帮助锦囊
function Newland:UpdateHelpTable(szGroupName, szPlayerName, szGateway)
	
	local nAddTime = GetTime();
	local nEndTime = nAddTime + 60 * 60 * 24 * 30;
	
	local szMsg = string.format([[

<color=yellow>第<color=cyan>%s<color><color=yellow>届的跨服城战已结束！<bclr=red>%s<bclr>获胜！<color>

<color=green>铁浮城现任城主：<color>

    <bclr=red><color=yellow>%s<color><bclr><color=yellow>（%s）<color>

<color=green>城主专属：<color>
    <color=yellow>凌天披风--<color><item=1,17,13,9><item=1,17,13,10><item=1,17,14,9><item=1,17,14,10>
    <color=yellow>凌天神驹--<color><item=1,12,29,4>
    <color=yellow>城主雕像<color>

]], self:GetSession(), szGroupName, szPlayerName, ServerEvent:GetServerNameByGateway(szGateway));
	
	Task.tbHelp:AddDNews(Task.tbHelp.NEWSKEYID.NEWS_NEWLAND_RESULT, "跨服城战战报", szMsg, nEndTime, nAddTime);
end

-- 清除帮助锦囊
function Newland:ClearHelpTable()
	local nAddTime = GetTime();
	local nEndTime = nAddTime + 60 * 60 * 24 * 30;
	Task.tbHelp:AddDNews(Task.tbHelp.NEWSKEYID.NEWS_NEWLAND_RESULT, "跨服城战战报", "", nEndTime, nAddTime);
end
