-- 文件名　：weekendfish_gc.lua
-- 创建者　：huangxiaoming
-- 创建时间：2011-08-05 1:48:10
-- 描  述  ：

if not MODULE_GC_SERVER then
	return;
end

Require("\\script\\task\\weekendfish\\weekendfish_def.lua")

function WeekendFish:RefreshTask_GC(nSeg)	-- 每星期六随一次
	local nWeek = tonumber(GetLocalDate("%W"));
	local nTaskWeek = KGblTask.SCGetDbTaskInt(DBTASK_WEEKENDFISH_WEEK);
	local nWeekDay = tonumber(GetLocalDate("%w"));
	local nDate = tonumber(GetLocalDate("%m%d"));
	if (nWeekDay == 6 and nTaskWeek ~= nWeek) -- 正常的星期六刷新
		or (nWeekDay == 6 and nTaskWeek == 0 and nWeek == 0)-- 新服第一次钓鱼刚好在新年第一周
		or (nWeekDay == 0 and nTaskWeek ~= nWeek and nDate ~= 101) then -- 意外情况星期六没有刷新，星期天刷新，剔除星期天刚好是1月1日的情况
		local tbRandRes = self:RandFixTask();
		KGblTask.SCSetDbTaskInt(DBTASK_WEEKENDFISH_WEEK, nWeek);
		KGblTask.SCSetDbTaskInt(DBTASK_WEEKENDFISH_TASK_ID1, tbRandRes[1]);
		KGblTask.SCSetDbTaskInt(DBTASK_WEEKENDFISH_TASK_ID2, tbRandRes[2]);
		KGblTask.SCSetDbTaskInt(DBTASK_WEEKENDFISH_TASK_ID3, tbRandRes[3]);
		-- 清空排行榜
		self:ClearLuckFishRank_GC();
	end
end

-- 随机3种今日固定的鱼,5个区域选3个，每个区域随一个
function WeekendFish:RandFixTask()
	local tbRandIndex = self:GetSmashTable(1, #self.AREA_INDEX);
	local tbRes = {};
	for i = 1, self.RANK_FISH_KIND_NUM do
		local nRand = MathRandom(1, #self.AREA_INDEX[tbRandIndex[i]]);
		tbRes[i] = self.AREA_INDEX[tbRandIndex[i]][nRand];
	end
	return tbRes;
end

-- 领取幸运鱼排行榜奖励
function WeekendFish:GetLuckFishAward_GC(nPlayerId, nType)
	local szPlayerName = KGCPlayer.GetPlayerName(nPlayerId);
	local nTaskWeek = KGblTask.SCGetDbTaskInt(DBTASK_WEEKENDFISH_WEEK);
	if nTaskWeek >= 0 and nTaskWeek ~= self.nDataVer then
		GlobalExcute{ "WeekendFish:GetLuckFishAward_GS2", -1, nPlayerId, nType};
		return 0;
	end
	if not self.nOpenLuckRankAward or self.nOpenLuckRankAward ~= 1 then
		GlobalExcute{ "WeekendFish:GetLuckFishAward_GS2", -1, nPlayerId, nType};
		return 0;
	end
	for i = 1, self.MAX_LUCKFISH_AWARD_RANK do
		if self.tbLuckFishRank[nType] and self.tbLuckFishRank[nType][i] and self.tbLuckFishRank[nType][i][1] and 
		self.tbLuckFishRank[nType][i][1] == szPlayerName and self.tbLuckFishRank[nType][i][4] ~= 1 then
			self.tbLuckFishRank[nType][i][4] = 1;
			self:SaveLuckFishRank_GC();
			GlobalExcute{ "WeekendFish:GetLuckFishAward_GS2", 1, nPlayerId, nType, i, 1};
			return 1;
		end
	end

	for i = 1, self.MAX_LUCKFISH_AWARD_RANK do
		if self.tbLuckFishRank_Ex[nType] and self.tbLuckFishRank_Ex[nType][i] and self.tbLuckFishRank_Ex[nType][i][1] 
		and self.tbLuckFishRank_Ex[nType][i][1] == szPlayerName and self.tbLuckFishRank_Ex[nType][i][4] ~= 1 then
			self.tbLuckFishRank_Ex[nType][i][4] = 1;
			self:SaveLuckFishRank_Ex_GC();
			GlobalExcute{ "WeekendFish:GetLuckFishAward_GS2", 1, nPlayerId, nType, i, 2};
			return 1;
		end
	end

	GlobalExcute{ "WeekendFish:GetLuckFishAward_GS2", -1, nPlayerId, nType};
	return 0;
end

-- 启动时候检查
function WeekendFish:StartEvent()
	self:LoadLuckFishRank()
	self:RefreshTask_GC();
	self:RefreshFish_GC(); -- 在刷鱼期间重启直接把鱼刷出来
end

-- 更新每周幸运鱼的排行
function WeekendFish:ClearLuckFishRank_GC()
	local nTaskWeek = KGblTask.SCGetDbTaskInt(DBTASK_WEEKENDFISH_WEEK);
	if self.nDataVer ~= nTaskWeek then
		self.nDataVer = nTaskWeek;
		self.nOpenLuckRankAward = 0;
		self.tbLuckFishRank = {};
		self.tbLuckFishRank[1] = {};
		self.tbLuckFishRank[2] = {};
		self.tbLuckFishRank[3] = {};
		self:SaveLuckFishRank_GC();
		GlobalExcute{"WeekendFish:LoadLuckFishRank"};
	end
end

-- 玩家交鱼加分数
function WeekendFish:UpdateLuckFishRank_GC(nType, szPlayerName, nWeight)
	local nWeek = tonumber(GetLocalDate("%W"));
	local nWeekDay = tonumber(GetLocalDate("%w"));
	local nDate = tonumber(GetLocalDate("%m%d")); -- 星期天刚好是一月一号也可以交
	if self.nOpenLuckRankAward == 0 and (nWeek == self.nDataVer or (nWeekDay == 0 and nDate == 101)) then	-- 排行榜领奖未开启，且数据是本周的
		self:UpdateLuckFishRank(nType, szPlayerName, nWeight);
		GlobalExcute{"WeekendFish:UpdateLuckFishRank", nType, szPlayerName, nWeight};
	end
end

-- 存盘
function WeekendFish:SaveLuckFishRank_GC()
	local tbData = {};
	tbData.nDataVer = self.nDataVer;
	tbData.nOpenLuckRankAward = self.nOpenLuckRankAward;
	tbData.tbLuckFishRank = self.tbLuckFishRank;
	SetGblIntBuf(GBLINTBUF_WEEKEND_FISH, 0, 1, tbData);
end

function WeekendFish:SaveLuckFishRank_Ex_GC()
	local tbData = {};
	tbData.nDataVer = self.nDataVer;
	tbData.nOpenLuckRankAward = self.nOpenLuckRankAward;
	tbData.tbLuckFishRank = self.tbLuckFishRank_Ex;
	SetGblIntBuf(GBLINTBUF_WEEKEND_FISH_EX, 0, 1, tbData);
end

-- 刷鱼
function WeekendFish:RefreshFish_GC(nSeg, nForce)
	if self:CheckOpen() ~= 1 then
		return 0;
	end
	if nForce ~= 1  and self:CheckFishTime() ~= 1 then
		return 0;
	end
	if not self.tbFishPos then
		local tbTempFile = Lib:LoadTabFile(self.FILE_FISH_POS_PATH);
		if not tbTempFile or #tbTempFile == 0 then
			Dbg:WriteLog("WeekendFish", "load fish file failure");
			return 0;
		end
		self.tbFishPos = {};
		self.tbAreaMapPosNum = {};
		for i = 1, #self.AREA_INDEX do
			self.tbFishPos[i] = {};	-- 每个区域的鱼点单独表
			self.tbAreaMapPosNum[i] = {}; -- 每个区域的地图的点的个数
			self.tbAreaMapPosNum[i].nMapNum = 0;	-- 区域内的地图数
		end
		
		for i = 1, #tbTempFile do
			local tbTemp = {};
			local nIndex = tonumber(tbTempFile[i]["AREAID"]);
			tbTemp[1] = tonumber(tbTempFile[i]["MAPID"]);
			tbTemp[2] = tonumber(tbTempFile[i]["POSX"]) / 32;
			tbTemp[3] = tonumber(tbTempFile[i]["POSY"]) / 32;
			if nIndex > 0 and nIndex <= #self.AREA_INDEX then
				table.insert(self.tbFishPos[nIndex], tbTemp);
				if not self.tbAreaMapPosNum[nIndex][tbTemp[1]] then
					self.tbAreaMapPosNum[nIndex].nMapNum = self.tbAreaMapPosNum[nIndex].nMapNum + 1;
					self.tbAreaMapPosNum[nIndex][tbTemp[1]] = 0;
				end
				self.tbAreaMapPosNum[nIndex][tbTemp[1]] = self.tbAreaMapPosNum[nIndex][tbTemp[1]] + 1;
			end
		end
	end
	self.tbRefreshFishSort = {};-- 地图对应的鱼类型
	for nAreaId = 1, #self.AREA_INDEX do -- 每个区域单独随机
		local nQuo = math.floor(self.tbAreaMapPosNum[nAreaId].nMapNum, #self.AREA_INDEX[nAreaId]);
		local nRes = math.mod(self.tbAreaMapPosNum[nAreaId].nMapNum, #self.AREA_INDEX[nAreaId]);
		local tbOrder = {};
		for i = 1, nQuo do
			local tbRand = self:GetSmashTable(1, #self.AREA_INDEX[nAreaId]);
			for j = 1, #tbRand do
				tbOrder[#tbOrder + 1] = {tbRand[math.mod(j, #tbRand) + 1], tbRand[math.mod(j+1, #tbRand) + 1]}; -- 随机鱼群序列 
			end
		end
		local tbRand = self:GetSmashTable(1, #self.AREA_INDEX[nAreaId]);
		for j = 1, nRes do
			tbOrder[#tbOrder + 1] = {tbRand[math.mod(j, #tbRand) + 1], tbRand[math.mod(j+1, #tbRand) + 1]}
		end
		local nIndex = 1;
		for nMapId, _ in pairs(self.tbAreaMapPosNum[nAreaId]) do-- 将鱼类型序列赋值给地图
			if type(nMapId) == "number" then -- table中多了nmapnum
				self.tbRefreshFishSort[nMapId] = {self.AREA_INDEX[nAreaId][tbOrder[nIndex][1]], self.AREA_INDEX[nAreaId][tbOrder[nIndex][2]]};
				nIndex = nIndex + 1;
			end
		end
	end
	GlobalExcute({"WeekendFish:RefreshFish_GS", self.tbRefreshFishSort});	-- gs不用关心鱼在哪个区域，以后刷鱼只在地图内变换
	Dialog:GlobalNewsMsg_GC("Hoạt động câu cá cuối tuần đang diễn ra, các loại cá có ở khắp vùng Kiếm Thế. Mau đến gặp Tần Oa để nhận nhiệm vụ.");
	Dialog:GlobalMsg2SubWorld_GC("Hoạt động câu cá cuối tuần đang diễn ra, các loại cá có ở khắp vùng Kiếm Thế. Mau đến gặp Tần Oa để nhận nhiệm vụ.");
	Timer:Register(self.NOTICE_PROMPT_TIME, self.NoticeTimer, self);
end

function WeekendFish:NoticeTimer()
	if self:CheckFishTime() ~= 1 then
		return 0;
	end
	Dialog:GlobalNewsMsg_GC("Hoạt động câu cá cuối tuần đang diễn ra sôi nổi,\ncác hiệp sĩ đã tham gia chưa?");
	Dialog:GlobalMsg2SubWorld_GC("Hoạt động câu cá cuối tuần đang diễn ra sôi nổi, các hiệp sĩ đã tham gia chưa?");
	return;
end

-- 清鱼
function WeekendFish:ClearFish_GC(nSeg, nForce)
	if self:CheckOpen() ~= 1 then
		return 0;
	end
	local nWeekDay = tonumber(GetLocalDate("%w"));
	if nForce ~= 1 then
		local nClearFlag = 0;
		for _, nTemp in pairs(WeekendFish.TB_ACCEPTTASKWEEKDAY) do
			if nTemp == nWeekDay then
				nClearFlag = 1;
				break;
			end
		end
		if nClearFlag ~= 1 then
			return 0;
		end
	end
	self.tbRefreshFishSort = nil;
	GlobalExcute({"WeekendFish:ClearAllFish_GS"});
	self:ClearFishNotice(nSeg);
end

function WeekendFish:ClearFishNotice(nSeg)
	local nWeekDay = tonumber(GetLocalDate("%w"));
	if nWeekDay == 6 then
		if nSeg == 1 then
			Dialog:GlobalNewsMsg_GC("Cá đã biến mất thời gian xuất hiện tiếp theo của cá là từ 16h - 20h hôm nay, các hiệp sĩ hãy chú ý.");
			Dialog:GlobalMsg2SubWorld_GC("Cá đã biến mất thời gian xuất hiện tiếp theo của cá là từ 16h - 20h hôm nay, các hiệp sĩ hãy chú ý.");
		elseif nSeg == 2 then
			Dialog:GlobalNewsMsg_GC("Cá đã biến mất, lần tiếp theo cá xuất hiện là từ 10h00 đến 14h00 ngày mai, các hiệp sĩ hãy nhanh chóng đến Tần Oa để đổi phần thưởng câu cá hôm nay nhé.");
			Dialog:GlobalMsg2SubWorld_GC("Cá đã biến mất, lần tiếp theo cá xuất hiện là từ 10h00 đến 14h00 ngày mai, các hiệp sĩ hãy nhanh chóng đến Tần Oa để đổi phần thưởng câu cá hôm nay nhé.");
		end
	elseif nWeekDay == 0 then
		if nSeg == 1 then
			Dialog:GlobalNewsMsg_GC("Cá đã biến mất thời gian xuất hiện tiếp theo của cá là từ 16h - 20h hôm nay, các hiệp sĩ hãy chú ý.");
			Dialog:GlobalMsg2SubWorld_GC("Cá đã biến mất thời gian xuất hiện tiếp theo của cá là từ 16h - 20h hôm nay, các hiệp sĩ hãy chú ý.");
		elseif nSeg == 2 then
			Dialog:GlobalNewsMsg_GC("Hoạt động câu cá của tuần này đã kết thúc. Vui lòng đến Tần Oa kịp thời để đổi phần thưởng câu cá của ngày hôm nay.");
			Dialog:GlobalMsg2SubWorld_GC("Hoạt động câu cá của tuần này đã kết thúc. Vui lòng đến Tần Oa kịp thời để đổi phần thưởng câu cá của ngày hôm nay.");
		end
	end
end

-- 定时更新鱼排行榜
function WeekendFish:UpdateLunckRankAward_GC(nSeg)
	local nWeek = tonumber(GetLocalDate("%W"));
	local nWeekDay = tonumber(GetLocalDate("%w"));
	if nWeekDay == self.LUCKRANK_OPEN_WEEKDAY then
		self.nOpenLuckRankAward = 1;
		self:SaveLuckFishRank_GC();
		GlobalExcute{"WeekendFish:LoadLuckFishRank"};
	elseif nWeekDay == self.LUCKRANK_CLOSE_WEEKDAY then
		self.nOpenLuckRankAward = 0;
		self:SaveLuckFishRank_GC();
		self:ClearSubBuf();
		GlobalExcute{"WeekendFish:LoadLuckFishRank"};
	end
end

function WeekendFish:ClearSubBuf()
	self.tbLuckFishRank_Ex = {};
	SetGblIntBuf(GBLINTBUF_WEEKEND_FISH_EX, 0, 1, self.tbLuckFishRank_Ex);
end

function WeekendFish:CozoneWeekFishBuffer(tbSubBuf)
	WeekendFish:LoadLuckFishRank();

	local nWeek = tonumber(GetLocalDate("%W"));
	local nWeekDay = tonumber(GetLocalDate("%w"));
	local nDate = tonumber(GetLocalDate("%m%d"));
	-- 如果主服，从服都还开着钓鱼活动那么久合并buf
	if self.nOpenLuckRankAward == 0 and (nWeek == self.nDataVer or (nWeekDay == 0 and nDate == 101)) then	-- 排行榜领奖未开启，且数据是本周的
		if (tbSubBuf.nOpenLuckRankAward and tbSubBuf.nOpenLuckRankAward == 0) then
			local tbSubRank = tbSubBuf.tbLuckFishRank;
			if (tbSubRank) then
				for nType, tbRank in pairs(tbSubRank) do
					for nIndex, tbInfo in pairs(tbRank) do
						self:UpdateLuckFishRank(nType, tbInfo[1], tbInfo[2]);
					end
				end
			end
			return 0;
		end
	end
	
	-- 否则就保存到备份buf里
	self.tbLuckFishRank_Ex = tbSubBuf;
	SetGblIntBuf(GBLINTBUF_WEEKEND_FISH_EX, 0, 1, tbSubBuf);
end

-- gs连接上来
function WeekendFish:OnRecConnectEvent(nConnectId)
	if not self.tbRefreshFishSort then
		return 0;
	end
	--GSExcute(nConnectId, {"WeekendFish:RefreshFish_GS", self.tbRefreshFishSort});
	GlobalExcute({"WeekendFish:RefreshFish_GS", self.tbRefreshFishSort});
end

GCEvent:RegisterGCServerStartFunc(WeekendFish.StartEvent, WeekendFish);
GCEvent:RegisterGCServerShutDownFunc(WeekendFish.SaveLuckFishRank_GC, WeekendFish);
GCEvent:RegisterGS2GCServerStartedFunc(WeekendFish.OnRecConnectEvent, WeekendFish);