-- 文件名  : zhaiguoshi_gs.lua
-- 创建者  : jiazhenwei
-- 创建时间: 2010-11-18 10:48:39
-- 描述    : 

--VN--
if not MODULE_GAMESERVER then
	return;
end
Require("\\script\\event\\specialevent\\vn_201012\\zhaiguoshi_def.lua");

SpecialEvent.tbZaiGuoShi = SpecialEvent.tbZaiGuoShi or {};
local tbZaiGuoShi = SpecialEvent.tbZaiGuoShi;

--到点触发
function tbZaiGuoShi:StartPlant()
	local nCurDate = tonumber(GetLocalDate("%Y%m%d"));
	if nCurDate < self.nStartTime or nCurDate > self.nEndTime then
		return 0;
	end
	if not self.MissionList then
		self.MissionList = {};
	end
	self.MissionList = Lib:NewClass(self.Mission);
	self.MissionList:StartGame();
end

--对话接任务
function tbZaiGuoShi:OnDialog()
	local nCurDate = tonumber(GetLocalDate("%Y%m%d"));
	if nCurDate < self.nStartTime or nCurDate > self.nEndTime then
		Dialog:Say("不在活动期！", {{"Ta hiểu rồi"}});
		return 0;
	end
	local nCount = self.nMaxCount - me.GetTask(self.TASKGID, self.TASK_COUNT);
	local nNowData = tonumber(GetLocalDate("%y%m%d"));
	local nLastData = math.floor(me.GetTask(self.TASKGID, self.TASK_DATA)/ 10000);
	if nNowData ~= nLastData then
		nCount = self.nMaxCount;
	end
	local szMsg = string.format("我这里有个很有趣的活动，你要不要参加下？\n你今天还有<color=yellow>%s<color>次机会！", nCount);
	local tbOpt = {
		{"参加活动", self.OnDialogEx, self},
		{"查询桃子和酒食用情况", self.QuaryUseItem, self},
		{"了解下这个活动", self.About, self},
		{"Để ta suy nghĩ thêm"},
		};
	Dialog:Say(szMsg, tbOpt);
end

function tbZaiGuoShi:OnDialogEx()
	local nFlag, szMsg = self:CheckPlayer();
	if nFlag == 0 then
		Dialog:Say(szMsg, {{"Ta hiểu rồi"}});
		return;
	end
	local nNowData = tonumber(GetLocalDate("%y%m%d%H%M"));	
	me.SetTask(self.TASKGID, self.TASK_DATA, nNowData);
	me.SetTask(self.TASKGID, self.TASK_COUNT, me.GetTask(self.TASKGID, self.TASK_COUNT) + 1);
	
	local nNowTime = tonumber(GetLocalDate("%H%M"));	
	local nLeaveTime = 0;
	for i, nTime in ipairs(self.tbTime) do
		if nTime <= nNowTime and nNowTime < nTime + self.nTime then
			nLeaveTime = nTime + self.nTime - nNowTime;
			break;
		end
	end
	me.AddSkillState(self.SkillId, 1, 1, nLeaveTime * 60 * Env.GAME_FPS, 1, 0, 1);
	me.Msg("赶紧去摘果实吧！");
end

function tbZaiGuoShi:QuaryUseItem()
	local nPeachData = me.GetTask(self.TASKGID, self.TASK_DATA_PEACH);
	local nPeackCount = me.GetTask(self.TASKGID, self.TASK_COUNT_PEACH);
	local nOldWineData = me.GetTask(self.TASKGID, self.TASK_DATA_OLDWINE);
	local nOldWineCount = me.GetTask(self.TASKGID, self.TASK_COUNT_OLDWINE);
	local nGoodWineData = me.GetTask(self.TASKGID, self.TASK_DATA_GOODWINE);
	local nGoodWineCount = me.GetTask(self.TASKGID, self.TASK_COUNT_GOODWINE);
	local nNowDate = tonumber(GetLocalDate("%Y%m%d"));
	if nPeachData ~= nNowDate then
		nPeackCount = 0;
	end
	if nOldWineData ~= nNowDate then
		nOldWineCount = 0;
	end
	if nGoodWineData ~= nNowDate then
		nGoodWineCount = 0;
	end
	local szMsg = string.format("  今天你已经食用了<color=yellow>%s<color>个桃子，喝了<color=yellow>%s<color>瓶陈年桃酒和<color=yellow>%s<color>瓶上等桃酒。", nPeackCount, nOldWineCount, nGoodWineCount);
	local tbOpt = {
		{"Ta hiểu rồi"}
		};
	Dialog:Say(szMsg, tbOpt);
end

function tbZaiGuoShi:About()
	local szMsg = [[
			<color=green>欢乐果实活动：<color>
	<color=red>【活动时间】<color>
		%s到%s 24h00
	<color=red>【参加条件】<color>
		达到69级的玩家可参加此活动。
	<color=red>【玩法】<color>
		在活动期间，风陵渡、太行古径、嘉峪关三张地图将会刷出果树。每天每玩家可以有3次摘果子的机会。在江津村，找到树园老板与其对话领取任务，摘取桃子。用 “桃子”与“酒壶” (奇珍阁出售)会有机会获得 “陈年桃酒” 与  “上等桃酒”。
	
	<color=red>【果树刷新时间】<color>
		每天有6次摘果时间，每次果树刷出时间为45分钟
		10:00 – 10:45
		12:00 – 12:45
		14:00 – 14:45
		16:00 – 16:45
		18:00 – 18:45
		22:00 – 22:45
	]];
	szMsg = string.format(szMsg, os.date("%Y-%m-%d", Lib:GetDate2Time(self.nStartTime)), os.date("%Y-%m-%d", Lib:GetDate2Time(self.nEndTime)));
	Dialog:Say(szMsg, {{"Ta hiểu rồi"}});
end

--检查玩家参加条件
function tbZaiGuoShi:CheckPlayer()
	local nNowDate = tonumber(GetLocalDate("%y%m%d"));
	if me.nLevel < 69 then
		return 0, "你的等级不足69级，不能参加这个活动的！";
	end
	if me.nFaction <= 0 then		
		return 0, "你无门无派，还是先入了门派再来找我吧。";
	end
	--检查当天次数
	local nNowData = tonumber(GetLocalDate("%y%m%d"));
	local nNowTime = tonumber(GetLocalDate("%H%M"));
	local nLastData = math.floor(me.GetTask(self.TASKGID, self.TASK_DATA)/ 10000);
	local nLastTime = math.fmod(me.GetTask(self.TASKGID, self.TASK_DATA), 10000);
	local nCount = me.GetTask(self.TASKGID, self.TASK_COUNT);
	local nFinshTime = me.GetTask(self.TASKGID, self.TASK_TIME);	
	if nNowData ~= nLastData then
		--me.SetTask(self.TASKGID, self.TASK_DATA, tonumber(GetLocalDate("%y%m%d%H%M")));
		me.SetTask(self.TASKGID, self.TASK_COUNT, 0);
	else
--		if nFinshTime >= nLastTime and nFinshTime < nLastTime + self.nTime then
--			return 0, "我想这次任务你已经完成了，还是下个时间点再来吧！";
--		end
		if nLastTime <= nNowTime and nNowTime < nLastTime + self.nTime then
			return 0, "你正在进行这次的活动呢，不要重复接了！";
		end
		if nCount >= self.nMaxCount then
			return 0, "你今天参加的已经足够多了，机会还是留给其他人吧！";
		end
	end
	local nCanJoin = 0;
	for _, nTime in ipairs(self.tbTime) do
		if nNowTime >= nTime and nNowTime < nTime + self.nTime then
			nCanJoin =  1;
			break;
		end
	end
	if nCanJoin == 0 then
		return 0, "好像这个时间点活动还没有开始吧！";
	end
	return 1;
end

function tbZaiGuoShi:CheckCanGaterSeed()
	local nNowDate = tonumber(GetLocalDate("%y%m%d"));
	if me.nLevel < 69 then
		return 0, "您的等级不足69级！";
	end
	if me.nFaction <= 0 then		
		return 0, "你无门无派，还是先入了门派再来找我吧。";
	end	
	 if me.CountFreeBagCell() < 1 then
	  	return 0,"包裹空间不足1格，请整理下！";
	end
	local nNowData = tonumber(GetLocalDate("%y%m%d"));
	local nNowTime = tonumber(GetLocalDate("%H%M"));
	local nLastData = math.floor(me.GetTask(self.TASKGID, self.TASK_DATA)/ 10000);
	local nLastTime = math.fmod(me.GetTask(self.TASKGID, self.TASK_DATA), 10000);
	local nFinshTime = me.GetTask(self.TASKGID, self.TASK_TIME);
	if nNowData ~= nLastData then
		return 0, "你没有接到摘果实的任务，不能摘果实的。";
	else
		for _, nTime in ipairs(self.tbTime) do
			if nNowTime >= nTime and nNowTime < nTime + self.nTime then
				if nLastTime < nTime or nLastTime >= nTime + self.nTime then
					return 0, "你接的任务已经过期了，还是重新接了再来吧！";
				end
--				if nFinshTime >= nTime and nFinshTime <= nTime + self.nTime then
--					return 0, "任务已经完成了，你还是等下一次再接任务吧！";
--				end
			end
		end
	end
	return 1;
end
