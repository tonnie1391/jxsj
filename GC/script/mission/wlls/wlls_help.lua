--武林联赛帮助锦囊
--孙多良
--2008.10.15

Wlls.NEWS_OPEN = {
	nKey = 16,
	sztitle = "武林联赛即将开放",
	szMsg = "本服务器将在<color=yellow>%s月01日<color>开放武林联赛。",
}

function Wlls:SetOpenNews()
	local nTime = GetTime();
	local nOpenTime = KGblTask.SCGetDbTaskInt(DBTASD_SERVER_SETMAXLEVEL150);
	if nOpenTime <= 0 then
		return 0;
	end
	local nYear = tonumber(os.date("%Y",nOpenTime));
	local nMonth = tonumber(os.date("%m",nOpenTime));
	local nNextMonth = nMonth + 1;
	if nNextMonth > 12 then
		nNextMonth = 1;
		nYear = nYear + 1;
	end
	local nEndDate = tonumber( tostring(nYear * 100 + nNextMonth) .. "010000");
	local nEndTime = Lib:GetDate2Time(nEndDate);
	if nTime < nEndTime then
		local szMsg = string.format(self.NEWS_OPEN.szMsg, nNextMonth);
		Task.tbHelp:SetDynamicNews(self.NEWS_OPEN.nKey, self.NEWS_OPEN.sztitle, szMsg, nEndTime, nTime);
	end
end
