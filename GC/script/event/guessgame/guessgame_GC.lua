-------------------------------------------------------------------
--File: 	guessgame_GC.lua
--Author: 	sunduoliang
--Date: 	2008-2-28 17:30:24
--Describe:	猜灯谜，触发
if (not MODULE_GC_SERVER) then
	return 0;
end

function GuessGame:StartGuessGame()
	--之前周1,周3,周5  晚上20:30触发
	-- 现在改成每日中午12:30 -- 13:30
	local nNowWeek = tonumber(GetLocalDate("%w"));
	if EventManager.IVER_bGuessGame == 1 or (nNowWeek == 1 or nNowWeek == 3 or nNowWeek == 4) then
		GlobalExcute({"GuessGame:StartGuessGame"});
	end
end
