-------------------------------------------------------
-- 文件名　：viptransfer_def.lua
-- 创建者　：zhangjinpin@kingsoft
-- 创建时间：2009-11-19 11:17:44
-- 文件描述：
-------------------------------------------------------

Require("\\script\\misc\\serverlist.lua");

local tbVipTransfer = VipPlayer.VipTransfer or {};
VipPlayer.VipTransfer = tbVipTransfer;

tbVipTransfer.TASK_GROUP_ID 		= 2108;		-- 任务变量组
tbVipTransfer.TASK_QUALIFICATION	= 1;		-- 有申请转服资格
tbVipTransfer.TASK_TRANS_APPLY		= 2;		-- 申请过转服
tbVipTransfer.TASK_TRANS_GETAWARD	= 3;		-- 领取过转服奖励
tbVipTransfer.TASK_TRANS_ACCOUNT	= 17;		-- 指定账号(17-24);
tbVipTransfer.TASK_TRANS_GATEWAY	= 25;		-- 指定网关(25-32);

-- 保留声望
tbVipTransfer.TASK_REPUTE = 
{
	[1] = 12, 	-- 腰带声望
	[2] = 13, 	-- 逍遥声望
	[3] = 14, 	-- 祈福声望
	[4] = 4, 	-- 联赛声望
	[5] = 5, 	-- 领土声望
	[6] = 6, 	-- 秦陵声望
	[7] = 7, 	-- 武器声望
	[8] = 8, 	-- 民族声望
	[9] = 9,	-- 武林大会声望
	[10] = 15,	-- 跨服联赛声望
	[11] = 16,	-- 项链声望
};

-- 绑银和银两
tbVipTransfer.TASK_BIND_MONEY		= 10;
tbVipTransfer.TASK_MONEY			= 11;

-- tbApplyOut[szPlayerName] = 
-- {szNewAccount = "", nNewGateId = 0, nBindValue = 0, nNoBindValue = 0, tbRepute = {}}

-- tbApplyIn[szAccount] = 
-- {nNewGateId, nBindCoin = 0, nBindMoney = 0, nMoney = 0, tbRepute = {}};
tbVipTransfer.tbGlobalBuffer = 
{
	tbApplyOut = {},	-- 申请转出的
	tbApplyIn = {},		-- 申请转入的
};		

-- 保留的声望类型 {nCamp, nClass}
tbVipTransfer.tbRepute =
{
	[1] = {5, 2},	-- 腰带声望
	[2] = {5, 3},	-- 逍遥声望
	[3] = {5, 4},	-- 祈福声望
	[4] = {7, 1},	-- 联赛声望
	[5] = {8, 1},	-- 领土声望
	[6] = {9, 1},	-- 秦陵声望
	[7] = {9, 2}, 	-- 武器声望
	[8] = {10, 1},	-- 民族声望
	[9] = {11, 1},	-- 武林大会声望
	[10] = {12, 1},	-- 跨服联赛声望
	[11] = {5, 5},	-- 项链声望
};

-- 声望名字索引
tbVipTransfer.tbReputeName = 
{
	[1] = {"2008盛夏活动声望", 30},
	[2] = {"逍遥谷声望", 30},
	[3] = {"祈福声望", 60},
	[4] = {"武林联赛声望", 140},
	[5] = {"领土争夺声望", 70},
	[6] = {"秦始皇陵·官府声望", 150},
	[7] = {"秦始皇陵·发丘门声望", 150},
	[8] = {"民族大团圆声望", 140},
	[9] = {"武林大会声望", 70},
	[10] = {"跨服联赛声望", 70},
	[11] = {"2010盛夏声望", 70},
};

-- 提升等级对时间轴
tbVipTransfer.tbTimeLevel = 
{
	[1] = {450, 125},
	[2] = {420, 124},
	[3] = {390, 123},
	[4] = {360, 122},
	[5] = {330, 121},
	[6] = {300, 120},
	[7] = {260, 118},
	[8] = {220, 115},
	[9] = {190, 112},
	[10] = {160, 109},
	[11] = {130, 106},
	[12] = {110, 103},
};

-- 计算的玄晶类型
tbVipTransfer.tbXuanjing =
{
	{18, 1, 1, 9},
	{18, 1, 1, 10},
	{18, 1, 1, 11},
	{18, 1, 1, 12},
	{18, 1, 114, 9},
	{18, 1, 114, 10},
	{18, 1, 114, 11},
	{18, 1, 114, 12},
};

-- 返回声望类型索引
function tbVipTransfer:GetReputeIndex(nCamp, nClass)
	for nIndex, tbInfo in pairs(self.tbRepute) do
		if tbInfo[1] == nCamp and tbInfo[2] == nClass then
			return nIndex;
		end
	end
	return 0;
end

-- 检测玄晶
function tbVipTransfer:CheckXuanjing(pItem)
	for _, tbItemId in pairs(self.tbXuanjing) do
		if pItem.nGenre == tbItemId[1] and pItem.nDetail == tbItemId[2] and pItem.nParticular == tbItemId[3] and pItem.nLevel == tbItemId[4] then
			return 1;
		end
	end
	return 0;
end

-- 检测内部账号
function tbVipTransfer:CheckSepcailAccount(pPlayer)
	if jbreturn:IsPermitIp(pPlayer) ~= 1 then
		return 0;
	end
	if jbreturn:GetMonLimit(pPlayer) <= 0 then
		return 0;
	end
	return 1;
end

-- 区服列表(需要等服务器列表初始化完后，服务器启好了，才能读取列表配置文件)
function tbVipTransfer:ServerListInit()
	local tbServerName = {}
	local tbGlobalServer = ServerEvent:GetServerGateList();
	for szGateId, tbGate in pairs(tbGlobalServer or {}) do
		local nGate = tonumber(string.sub(szGateId, 5, 8));
		local nIndex = math.floor(nGate / 100);
		if not tbServerName[nIndex] then
			tbServerName[nIndex] = {szZoneName = tbGate.ZoneName};
		end
		tbServerName[nIndex][szGateId] = tbGate.ServerName;
	end
	self.tbServerName = tbServerName;
end

if MODULE_GC_SERVER then
	GCEvent:RegisterGCServerStartFunc(VipPlayer.VipTransfer.ServerListInit, VipPlayer.VipTransfer);
end
if not MODULE_GC_SERVER then
	ServerEvent:RegisterServerStartFunc(VipPlayer.VipTransfer.ServerListInit, VipPlayer.VipTransfer);
end
