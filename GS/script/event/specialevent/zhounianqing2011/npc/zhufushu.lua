-- 文件名  : zhufushu.lua
-- 创建者  : zhongjunqi
-- 创建时间: 2011-06-17 09:52:57
-- 描述    : 三周年庆 祝福树

if  not MODULE_GAMESERVER then
	return;
end

local tbNpc = Npc:GetClass("zhufushu");

--=======================================================
SpecialEvent.ZhouNianQing2011 = SpecialEvent.ZhouNianQing2011 or {};
local ZhouNianQing2011 = SpecialEvent.ZhouNianQing2011;

local tbZhuFuCaiDai = {18, 1, 1326, 1};	-- 祝福彩带的gdpl
local tbActiveTime = {
		{10, 14},
		{19, 23}
	};
local tbZhuFuMsg = {
	"恭喜剑侠世界三岁了，我们一起走过的那些日子，永远不忘。",
	"三年的剑世之路充满着回忆和喜悦，继续向前方迈进，因为我们是剑世玩家。",
	"大地知道天空的真诚，因为有雨滋润；我知道你的真诚，因为有剑侠世界。",
	"是朋友，星移斗转情不改；感谢剑侠世界，感谢我永远的朋友们！",
	"是知音，天涯海角记心怀；感谢剑侠世界，感谢我永远的朋友们！",
	};
local tbAward = {			-- todo抽奖奖励
	[99] = {18,1,1,8},
	[199] = {18,1,1,9},
	[299] = {18,1,1,10},
	[399] = {18,1,1,8},
	[499] = {18,1,1,9},
	[599] = {18,1,1,10},
	[699] = {18,1,1,8},
	[799] = {18,1,1,9},
	[899] = {18,1,1,10},
	[999] = {18,1,1,10},
};

-- 身上是否有祝福彩带
local function HasZhuFuCaiDai()
	local tbItems = me.FindItemInBags(unpack(tbZhuFuCaiDai));
	if (#tbItems > 0) then
		return 1;
	else
		return 0;
	end
end

-- 检查是否有祝福的资格
function tbNpc:CheckCanZhuFu()
		-- 检测活动状态
	if (ZhouNianQing2011.bIsOpen ~= 1) then
		return 0, "活动没有开启";
	end
	if (ZhouNianQing2011:CheckTime() ~= 1) then
		return 0, "活动没有开启。";
	end
	-- 检查活动时间
	if (self:IsActiveTime() == 0) then
		return 0, "不在活动时间，请在6月28日～7月4日的10点～14点或者19点～23点之间来祝福。";
	end
	-- 角色限制
	if (me.nLevel < ZhouNianQing2011.nPlayerLevelLimit or me.nFaction <= 0) then
		return 0, "只有达到60级并且加入门派的玩家才能使用。";
	end

	local nFlag = Player:CheckTask(ZhouNianQing2011.TASKGID, ZhouNianQing2011.TASK_ZHUFU_DATE, "%Y%m%d", 
									ZhouNianQing2011.TASK_ZHUFUCOUNT, 3);
	if (nFlag == 0) then
		return 0, "每天只能祝福3次。";
	end

	-- 检查是否有称号
	local tbCurTitle = {me.GetCurTitle()};
	tbCurTitle[5] = nil;			-- 去除过期时间
	if (self:IsTableEqual(tbCurTitle, ZhouNianQing2011.tb3YearTitle) == 0) then
		if (self:IsTableEqual(tbCurTitle, ZhouNianQing2011.tbHappyTitle) == 0) then
			return 0, "请先激活周年庆的称号再来祝福。如果没有称号，您可以从<color=yellow>修炼珠<color>领取。";
		end
	end
	-- 检查身上是否有彩带
	if (HasZhuFuCaiDai() == 0) then
		return 0, "你身上没有真挚的祝福，通过参加逍遥谷、宋金战场、白虎堂和军营副本可获得。";
	end
	
	if (me.CountFreeBagCell() < 1) then
		return 0, "请确保有1格的背包空间。";			-- 背包空间不足
	end

	return 1;
end

function tbNpc:OnDialog()
	-- 检查活动状态
	local bRet, szMsg = self:CheckCanZhuFu();
	if (bRet == 0) then
		Dialog:Say(szMsg);
		return;
	end
	
	-- 显示选项
	local tbOpt = {};
	local nRandBegin = MathRandom(1, #tbZhuFuMsg);			-- 随机祝福话语的顺序
	for i = 1, #tbZhuFuMsg do
		local nIndex = (nRandBegin + i) % #tbZhuFuMsg + 1;
		table.insert(tbOpt, {tbZhuFuMsg[nIndex], self.OnSelectMsg, self, nIndex});
	end
	table.insert(tbOpt, {"我只是路过", self.OnSelectMsg, self, 0});
	Dialog:Say("时光荏苒，一晃三年，我们在青葱的岁月里寻梦于剑侠世界。寻梦三载，一路有你，请送上你的祝福吧：", tbOpt);
		
end

-- 选择了祝福话语
function tbNpc:OnSelectMsg(nMsgIndex)
	if (nMsgIndex == 0) then			-- 没想好的
		return;
	end
	local szMsg = "您选择了祝福语：<color=yellow>" .. tbZhuFuMsg[nMsgIndex] .. "<color>";
	local tbOpt = {
			{"不发送公告", self.ConfirmSel, self, 0, nMsgIndex},
			{"发送到家族帮会频道", self.ConfirmSel, self, 1, nMsgIndex},
			{"返回", self.OnDialog, self},
		};
		
	Dialog:Say(szMsg, tbOpt);
end

-- 确认选择及公告
function tbNpc:ConfirmSel(bSendAnnounce, nMsgIndex)
	-- 检测活动状态
	local bRet, szMsg = self:CheckCanZhuFu();
	if (bRet == 0) then
		Dialog:Say(szMsg);
		return;
	end
	-- 如果天数为nil，尝试从存盘数据里面读取，如果读出来时0，这认为是第一天可以本地读取，否则做比较
	local tbNpcData = him.GetTempTable("SpecialEvent");
	local nNowDate = tonumber(GetLocalDate("%Y%m%d"));

	local nDbDate = KGblTask.SCGetDbTaskInt(DBTASK_ZHUFUSHU_DATE);
	if (nDbDate ~= 0) then
		tbNpcData.nZhuFuDate = nDbDate;									-- 不是第一次启动，读取日期
	else
		KGblTask.SCSetDbTaskInt(DBTASK_ZHUFUSHU_DATE, nNowDate);		-- 第一天，存盘
	end	
	
	-- 如果换天了
	if (not tbNpcData.nZhuFuDate or tbNpcData.nZhuFuDate ~= nNowDate) then
		-- 重置奖励计数
		tbNpcData.nZhuFuDate = nNowDate;
		tbNpcData.nZhuFu1Count = 0;
		tbNpcData.nZhuFu2Count = 0;
		KGblTask.SCSetDbTaskInt(DBTASK_ZHUFUSHU_DATE, nNowDate);
		KGblTask.SCSetDbTaskInt(DBTASK_ZHUFUSHU_STEP1, 0);
		KGblTask.SCSetDbTaskInt(DBTASK_ZHUFUSHU_STEP2, 0);
	end
	
	if (tbNpcData.nZhuFu1Count == nil) then		-- 0，意味着重启了或者第一次
		tbNpcData.nZhuFu1Count = KGblTask.SCGetDbTaskInt(DBTASK_ZHUFUSHU_STEP1);
	end
	if (tbNpcData.nZhuFu2Count == nil) then		-- 0，意味着重启了或者第一次
		tbNpcData.nZhuFu2Count = KGblTask.SCGetDbTaskInt(DBTASK_ZHUFUSHU_STEP2);
	end
		
	if (me.ConsumeItemInBags(1, unpack(tbZhuFuCaiDai)) ~= 0) then
		Dialog:Say("你身上没有真挚的祝福，通过参加逍遥谷、宋金战场、白虎堂和军营副本可获得。");
		return;
	end
	
	-- 发公告
	if (bSendAnnounce == 1) then
		-- 发送公告到帮会家族频道
		local szMsg = me.szName.."祝福了剑侠世界："..tbZhuFuMsg[nMsgIndex];
		Player:SendMsgToKinOrTong(me, szMsg, 0);
		Player:SendMsgToKinOrTong(me, szMsg, 1);
	end
	-- 给奖励
	me.AddExp(math.floor(me.GetBaseAwardExp() * 60));		-- 经验
	local nRnd = MathRandom(1, 100);
	if (nRnd <= 40) then					-- 绑银
		me.AddBindMoney(20000, Player.emKITEMLOG_TYPE_JOINEVENT);
		StatLog:WriteStatLog("stat_info", "cele_3year", "award", me.nId, 2, 20000);
	else
		me.AddBindCoin(150, Player.emKITEMLOG_TYPE_JOINEVENT);
		StatLog:WriteStatLog("stat_info", "cele_3year", "award", me.nId, 1, 150);
	end
	-- 记录任务变量
	me.SetTask(ZhouNianQing2011.TASKGID, ZhouNianQing2011.TASK_ZHUFUCOUNT, 
				me.GetTask(ZhouNianQing2011.TASKGID, ZhouNianQing2011.TASK_ZHUFUCOUNT) + 1);
	StatLog:WriteStatLog("stat_info", "cele_3year", "join", me.nId, 1);
	-- 抽奖
	local nCount = 0;					-- 第几个祝福
	local _, _, _, nHour = LocalTime(4);
	if (nHour >= tbActiveTime[1][1] and nHour < tbActiveTime[1][2]) then	-- 第一步
		tbNpcData.nZhuFu1Count = tbNpcData.nZhuFu1Count + 1;
		nCount = tbNpcData.nZhuFu1Count;
		KGblTask.SCSetDbTaskInt(DBTASK_ZHUFUSHU_STEP1, nCount);
	elseif (nHour >= tbActiveTime[2][1] and nHour < tbActiveTime[2][2]) then -- 第二步
		tbNpcData.nZhuFu2Count = tbNpcData.nZhuFu2Count + 1;
		nCount = tbNpcData.nZhuFu2Count;
		KGblTask.SCSetDbTaskInt(DBTASK_ZHUFUSHU_STEP2, nCount);
	end
	
	if (nCount ~= 0) then
		local tbBonus = tbAward[nCount];
		if (tbBonus) then				-- 中奖了
			local pItem = me.AddItemEx(tbBonus[1], tbBonus[2], tbBonus[3], tbBonus[4],
										{bForceBind = 1}, Player.emKITEMLOG_TYPE_JOINEVENT);
			local szLog = string.format("%s,%d,%d,%d,%d,%d", me.szName, nCount, unpack(tbBonus));
			if (not pItem) then
				-- 记录日志
				Dbg:WriteLogEx(Dbg.LOG_ERROR, "SpecialEvent", "祝福中奖异常", szLog);
				return;
			else
				Dbg:WriteLogEx(Dbg.LOG_INFO, "SpecialEvent", "祝福中奖", szLog);				
			end
			StatLog:WriteStatLog("stat_info", "cele_3year", "award", me.nId, 4, tbBonus[4]);
			-- 世界广播
			local szMsg = me.szName.."第"..nCount.."次为剑侠世界送上祝福："..tbZhuFuMsg[nMsgIndex].." 获得了"..pItem.szName;
			KDialog.NewsMsg(1, Env.NEWSMSG_NORMAL, szMsg);
		end
	end
end

function tbNpc:IsActiveTime()
	local _, _, _, nHour = LocalTime(4);
	if (nHour >= tbActiveTime[1][1] and nHour < tbActiveTime[1][2]) then
		return 1;
	elseif (nHour >= tbActiveTime[2][1] and nHour < tbActiveTime[2][2]) then
		return 1;
	else
		return 0;
	end
end

-- 判断两个表的值是否一样，一样返回1，否则0
function tbNpc:IsTableEqual(tb1, tb2)
	if (Lib:CountTB(tb1) ~= Lib:CountTB(tb2)) then
		return 0;
	end
	for i, v in pairs(tb1) do
		if (v ~= tb2[i]) then
			return 0;
		end
	end
	return 1;
end


