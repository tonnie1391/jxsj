-- 文件名  : zhaohuanjuanzhou.lua
-- 创建者  : jiazhenwei
-- 创建时间: 2010-12-08 11:51:56
-- 描述    : 召唤卷轴

local tbItem = Item:GetClass("zhaohuanjuanzhou");

function tbItem:OnUse()
	local nTime = tonumber(GetLocalDate("%Y%m%d"));
	if nTime < DaTaoSha.nStatTime or nTime > DaTaoSha.nEndTime then
		me.Msg("Không thể sử dụng vật phẩm.");
		return 0;
	end
	local nLimitTime = me.GetTask(DaTaoSha.TASKID_GROUP, DaTaoSha.TASKID_LIMIT_TIMES);
	local nAllTimes = GetPlayerSportTask(me.nId,DaTaoSha.GBTSKG_DATAOSHA, DaTaoSha.GBTASKID_ATTEND_ALLNUM) or 0;
	local nTickets = me.GetTask(DaTaoSha.TASKID_GROUP, DaTaoSha.TASKID_TICKETS);
	local nGlobalBatch = GetPlayerSportTask(me.nId,DaTaoSha.GBTSKG_DATAOSHA, DaTaoSha.GBTASKID_BATCH) or 0;	
	if nGlobalBatch ~= DaTaoSha.nBatch then
		nAllTimes = 0;
	end
	if me.nLevel < DaTaoSha.PLAYER_ATTEND_LEVEL  then
		me.Msg(string.format("Đẳng cấp chưa đạt %s, không thể sử dụng.",DaTaoSha.PLAYER_ATTEND_LEVEL));
		return 0;
	end
	if me.nFaction <= 0 then
		me.Msg("Chưa gia nhập môn phái, không thể sử dụng.");
		return 0;
	end
	
	if nAllTimes >= DaTaoSha.nMaxTime then
		local szMsg = string.format("Số lượt tham gia đã đạt giới hạn <color=yellow>%s lần<color> và không thể tiếp tục tham gia.", DaTaoSha.nMaxTime);
		me.Msg(szMsg);
		Dialog:SendInfoBoardMsg(me, szMsg);
		return 0;
	end
	
	if nTickets >= DaTaoSha.nMaxTime then
		me.Msg(string.format("Trong thời gian diễn ra, bạn chỉ có thể nhận tối đa <color=yellow>%s lần<color>, bạn đã đạt giới hạn tối đa.", DaTaoSha.nMaxTime));
		return 0;
	end
	if nTickets >= nLimitTime then
		local szMsg = "Tư cách tham gia đã đạt giới hạn trong ngày.";
		me.Msg(szMsg);
		Dialog:SendInfoBoardMsg(me, szMsg);
		return 0;		
	end
	me.SetTask(DaTaoSha.TASKID_GROUP, DaTaoSha.TASKID_TICKETS, nTickets + 1);
	me.Msg("Nhận được 1 lượt tư cách tham gia Di tích Hàn Vũ.")
	Dialog:SendBlackBoardMsg(me, "Nhận được 1 lượt tư cách tham gia Di tích Hàn Vũ.");	
	return 1;
end