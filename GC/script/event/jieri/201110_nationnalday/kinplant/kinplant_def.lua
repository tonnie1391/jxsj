-- 文件名　：kinplant_def.lua
-- 创建者　：jiazhenwei
-- 创建时间：2011-09-08 20:18:05
-- 功能    ：

SpecialEvent.tbKinPlant_2011 = SpecialEvent.tbKinPlant_2011 or {};
local tbKinPlant_2011 = SpecialEvent.tbKinPlant_2011;

tbKinPlant_2011.IS_OPEN =	1;		--开关

tbKinPlant_2011.nStartTime = 20110927;	--开始时间
tbKinPlant_2011.nEndTime = 20111011;		--结束时间	
tbKinPlant_2011.nAwardTime = 20111012;	--最后一天0点触发时
tbKinPlant_2011.nGetAwardTime = 20111015;	--最后一天0点触发时

tbKinPlant_2011.TASKGID 	= 2176;
tbKinPlant_2011.TASK_DATE				= 101;	--浇水日期
tbKinPlant_2011.TASK_COUNT_PLANT	= 102;	--每天浇水的数目
tbKinPlant_2011.TASK_GETITEM		 	= 103;	--获得道具的时间
tbKinPlant_2011.TASK_DATE_GET		= 104;	--摘果子日期
tbKinPlant_2011.TASK_COUNT_GET		= 105;	--摘果子数目

tbKinPlant_2011.nAttendMinLevel 		= 60;	--参加等级
tbKinPlant_2011.nMaxPlant			= 51;		--每天每人可以种植50个希望之种子
tbKinPlant_2011.nMinLevelForMsg		= 5;		--最低多少层发送家族好友公告
tbKinPlant_2011.nTeamPlantNum		= 3;		--组队种树需要几个人
tbKinPlant_2011.tbAwardItem 		= {18, 1, 1472, 1};		--果实
tbKinPlant_2011.tbWaterItem 		= {18, 1, 1471, 1};		--水
tbKinPlant_2011.nMaxAwardCoun		= 30;	--一棵树最大产出
tbKinPlant_2011.nMinAwardCount		= 20;	--最少剩余30个果子
tbKinPlant_2011.nDayMaxWater		= 20;	--每天最多浇水10次
tbKinPlant_2011.nPerGetOther		= 2;		--每次偷果子数
tbKinPlant_2011.nDayMaxGet			= 10;		--每天最大偷果子次数

tbKinPlant_2011.nTempNpc			= 9681;	--丰收使者
tbKinPlant_2011.tbTempNpcPos		= {1641, 3199};		--丰收使者位置

--种树npc
tbKinPlant_2011.tbTempNpc = {
	[1] = 9683,	--土
	[2] = 9684, 	--幸运之中
	[3] = 9685, 	--丰硕之果
	[4] = 9686, 	--快乐之果	
};

tbKinPlant_2011.nMaxIndex = #tbKinPlant_2011.tbTempNpc;
tbKinPlant_2011.tbXiWangZhiZhong = {18,1,1197,1};	--希望之种

--date table
tbKinPlant_2011.tbPlantInfo = tbKinPlant_2011.tbPlantInfo or {};		--种树标志{[nServerId]= {[szName] = 1}}
tbKinPlant_2011.tbPlantNpcInfo = tbKinPlant_2011.tbPlantNpcInfo or {};
tbKinPlant_2011.tbKinInfo = tbKinPlant_2011.tbKinInfo or {};	--gs记录加载家族npc标志
tbKinPlant_2011. tbNpcPoint = {};

--获得当前状态
function tbKinPlant_2011:GetState()
	if self.IS_OPEN == 0 then
		return 0;
	end
	
	local nDate = tonumber(GetLocalDate("%Y%m%d"));	
	if nDate >= self.nStartTime and nDate <= self.nEndTime then
		return 1;
	end
	return 0;
end

--土壤点
function tbKinPlant_2011:LoadPos()	
	local szFileName = "\\setting\\event\\jieri\\201110_nationnalday\\plantpos.txt";
	local tbFile = Lib:LoadTabFile(szFileName);
	if not tbFile then
		print("【在线领取】读取文件错误，文件不存在",szFileName);
		return;
	end
	for nId, tbParam in ipairs(tbFile) do
		if nId >= 1 then
			local nX = math.floor(tonumber(tbParam.TRAPX) / 32);
			local nY = math.floor(tonumber(tbParam.TRAPY) / 32);			
			table.insert(self.tbNpcPoint, {nX, nY});
		end
	end
end

tbKinPlant_2011:LoadPos();

