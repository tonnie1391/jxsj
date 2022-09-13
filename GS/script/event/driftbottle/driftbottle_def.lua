-------------------------------------------------------
-- 文件名　：driftbottle_def
-- 创建者　：zhangjinpin@kingsoft
-- 创建时间：2010-11-30 15:16:24
-- 文件描述：
-------------------------------------------------------

-- 系统开关
DriftBottle.IS_OPEN 				= 	1;							-- 系统状态
DriftBottle.START_TIME				= 	20101221;					-- 开启时间
DriftBottle.END_TIME				= 	20110102;					-- 截止时间

-- 任务变量
DriftBottle.TASK_GID 				= 	2149;						-- 任务变量组
DriftBottle.TASK_VOW_TIMES			= 	1;							-- 角色每日许愿次数
DriftBottle.TASK_PICK_TIMES			= 	2;							-- 角色每日摘取次数
DriftBottle.TASK_MASK_LIST			= 	{6, 7, 8, 9, 10};			-- 角色关注列表

-- 常量定义
DriftBottle.SYSTEM_MSG_COUNT 		= 	20;							-- 系统默认帖子数
DriftBottle.MAX_TEXT_LENGTH			=	100;						-- 帖子最长字节
DriftBottle.MIN_TEXT_LENGTH			=	8;							-- 帖子最短字节
DriftBottle.MAX_REPLY_LENGTH		=	60;							-- 回复最长字节
DriftBottle.MAX_DAILY_VOW			= 	2;							-- 每日最大许愿次数
DriftBottle.MAX_DAILY_PICK			= 	10;							-- 每日最大摘取次数
DriftBottle.MAX_REPLY_TIMES			= 	10;							-- 帖子最大回复次数
DriftBottle.MAX_BUFFER_LENGTH		=	5000;						-- 每个buffer最多存5000贴
DriftBottle.TREE_ID					= 	7257;						-- 圣诞树id

-- buffer列表
DriftBottle.BUFFER_LIST =
{
	[1] = {nIndex = GBLINTBUF_DRIFT_BOTTLE1, szBuffer = "tbMsgBuffer1"},
	[2] = {nIndex = GBLINTBUF_DRIFT_BOTTLE2, szBuffer = "tbMsgBuffer2"},
	[3] = {nIndex = GBLINTBUF_DRIFT_BOTTLE3, szBuffer = "tbMsgBuffer3"},
};

-- npc坐标
DriftBottle.MAP_LIST =
{
	[23] = {1580, 3100},
	[24] = {1780, 3540},
	[25] = {1652, 3161},
	[26] = {1596, 3196},
	[27] = {1629, 3221},
	[28] = {1504, 3270},
	[29] = {1642, 3944},
}

-- 帖子列表
-- tbMsgBuffer = {[1] = {szType = "system", szWriter = "zjpwxh", szHead = "....", tbReply = {[1] = "..."}}};
for nIndex, tbInfo in pairs(DriftBottle.BUFFER_LIST) do
	DriftBottle[tbInfo.szBuffer] = DriftBottle[tbInfo.szBuffer] or {};
end

-- 系统默认帖子
-- tbSystemMsg = {[1] = "...", [2] = "..."};
DriftBottle.tbSystemMsg = DriftBottle.tbSystemMsg or {};

-- 许愿树id
DriftBottle.tbTreeId = DriftBottle.tbTreeId or {};

-- 配置表路径
DriftBottle.SYSTEM_MSG_PATH = "\\setting\\event\\driftbottle\\systemlist.txt";

-- 系统开关
function DriftBottle:CheckIsOpen()
	local nDate = tonumber(GetLocalDate("%Y%m%d"));
	if nDate < self.START_TIME or nDate > self.END_TIME then
		return 0;
	end
	return self.IS_OPEN;
end

-- 计算buffer长度和可用索引
function DriftBottle:CalcBufferLength()
	local nCount = 0;
	for nIndex, tbInfo in pairs(self.BUFFER_LIST) do
		for nKey, tbValue in pairs(self[tbInfo.szBuffer]) do
			nCount = nCount + 1;
		end
	end
	local nFree = math.floor(nCount / self.MAX_BUFFER_LENGTH) + 1;
	if nFree > #self.BUFFER_LIST then
		nFree = 0;
	end
	return nCount, nFree;
end

-- 获取buffer值
function DriftBottle:GetInfoByIndex(nIndex)
	if nIndex <= 0 or nIndex > self:CalcBufferLength() then
		return nil;
	end
	local nFree = math.floor(nIndex / self.MAX_BUFFER_LENGTH) + 1;
	if self.BUFFER_LIST[nFree] then
		return self[self.BUFFER_LIST[nFree].szBuffer][nIndex];
	end
	return nil;
end

-- 获取buffer段
function DriftBottle:GetBufferByIndex(nIndex)
	if nIndex <= 0 or nIndex > #self.BUFFER_LIST then
		return nil;
	end
	if self.BUFFER_LIST[nIndex] then
		return self[self.BUFFER_LIST[nIndex].szBuffer];
	end
	return nil;
end
