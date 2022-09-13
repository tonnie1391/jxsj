-- 文件名　：kinplant_def.lua
-- 创建者　：jiazhenwei
-- 创建时间：2011-09-08 20:18:05
-- 功能    ：

KinPlant.IS_OPEN =	1;		--开关

KinPlant.TASKGID 				= 2176;
KinPlant.TASK_PLANT_NUM1		= 117;	--1号坑位
KinPlant.TASK_PLANT_NUM2		= 118;	--2号坑位
KinPlant.TASK_PLANT_NUM3		= 119;	--3号坑位
KinPlant.TASK_DATE			= 120;	--种果子日期
KinPlant.TASK_COUNT			= 121;	--种果子数目
KinPlant.TASK_DATE_GET		= 122;	--摘果子日期
KinPlant.TASK_COUNT_GET		= 123;	--摘果子数目
KinPlant.TASK_FINISHTASK		= 124;	--任务完成的周数
KinPlant.TASK_GETTASK			= 125;	--获得种子的周数
KinPlant.TASK_COZONE_FLAG		= 126;	--从服玩家合服后修复随机任务


KinPlant.tbPlantTask = {KinPlant.TASK_PLANT_NUM1, KinPlant.TASK_PLANT_NUM2, KinPlant.TASK_PLANT_NUM3};

KinPlant.nAttendMinLevel 		= 20;	--参加等级
KinPlant.nMaxPlantCount			= 3;		--每个人同一时间最大种植量
KinPlant.nDayMaxGet			= 20;	--每天可摘别人果子20个
KinPlant.nTempNpc				= 9872;	--土壤
KinPlant.tbWeeklyNpcId			= {9888, 9889};

KinPlant.tbPlantTime			= {{0900,2300}};
KinPlant.tbWeatherTime			= {0900, 1000, 1100, 1200,1300, 1400, 1500, 1600, 1700, 1800, 1900, 2000, 2100, 2200};
KinPlant.tbMsg2Wolrd			= {0910, 0940, 1010, 1040, 1110, 1140, 1210,1240,1310, 1340, 1410, 1440, 1510, 1540, 1610,1640,1710, 1740, 1810, 1840,1910,1940,2010,2040,2110,2140,2210,2240};
KinPlant.tbTypeName			= {"<color=yellow>[Đơn đặt hàng lương thực]<color>", "<color=yellow>[Đơn đặt hàng hoa quả]<color>", "<color=yellow>[Đơn đặt hàng hoa tươi]<color>"};
KinPlant.tbMyRepute			= {0,375,800,1275,1800};	--个人专精每个等级的累积经验
KinPlant.tbChangRate			= {{53125, 0},{78000, 4},{90625, 8},{96875, 16},{100000, 32}};	--个人专精每个等级的累积经验
KinPlant.nPreValue				= 148.15;	--基础价值量
KinPlant.tbValueType			= {{5 / 7, 1 / 7, 1 / 7},{1 / 7, 5 / 7, 1 / 7},{1 / 7, 1 / 7, 5 / 7}};
KinPlant.tbAward				= {33.60, 16923.08, 5000}	--每种奖励的换算

KinPlant.tbXuanJingValue		= {100, 360, 1296,4665,16796,60466,217678,783641,2821109,10155995,36565762,131636744};	--玄晶价值量

KinPlant.tbWeeklySeed			= {18,1,1586,1};		--周末活动种子

KinPlant.tbWeeklyDate			= {[0] = 1, [6] = 1};		--福禄活动时间周日和周六
KinPlant.tbWeaklyMap			= {[24] = 1, [27] = 1};	--24凤翔府27成都府
KinPlant.nWeeklyTempNpcId		= 9887;				--福禄之树id
KinPlant.nMaxStepCount			= 2;		--福禄活动每轮上交数目
KinPlant.tbHealthTitile			= {{"Khỏe mạnh-", "white"},{"Căng tròn-", "green"},{"Tươi ngon-", "blue"}, {"Năng suất cao-", "yellow"},{"Chất lượng cao-", "pink"}}
KinPlant.tbTitileIndex			= {[0] = 1, [4] = 2, [8] =3, [16]= 4, [32]=5};
KinPlant.nNum_KinPlant		= 0;		--统计正在进行的家族
--天气随即	
KinPlant.nRandTotal			= 100;	--天气随即的值
KinPlant.nRateWeather			= 50;	--天气产生的时机50%
KinPlant.nRateTime				= 55;		--随即时间（天气开始时间，1-55分钟之间，持续5分钟）
KinPlant.nWeatherTime			= 5;		--天气持续5分钟
KinPlant.nWeatherType			= 3;		--3种类型的天气

--任务
KinPlant.nTaskFreshDay			= 1;		--每周一0点更新任务

KinPlant.nKinMaxTreeWeekly		= 100;	--每周最大收获数，可参加周末活动

KinPlant.nTimes	= 1;		--奖励翻倍（获取果子的翻倍）

KinPlant.tbWeeklyAward			= {
	{5, {18,1,1591,1}},
	{6, {18,1,1591,1}},
	{7, {18,1,1591,1}},
	{4, {18,1,1592,1}},
	{5, {18,1,1592,1}},
	{3, {18,1,1593,1}},
	}

--时间轴
KinPlant.tbTimerFrame 			= {{100,1}, {250,2.5},{1200,4.1}};

--成就
KinPlant.tbAcheveMent	= {
	["18,1,1569,1"] = 454,
	["18,1,1571,1"] = 455,
	["18,1,1573,1"] = 456,
	["18,1,1575,1"] = 457,
	["18,1,1577,1"] = 458,
	["18,1,1579,1"] = 459,
	["18,1,1581,1"] = 460,
	["18,1,1583,1"] = 461, 
	["18,1,1585,1"] = 462};

--date table
KinPlant.tbPlantInfo 		= KinPlant.tbPlantInfo or {};		--种树标志{[nServerId]= {[szName] = 1}}
KinPlant.tbPlantNpcInfo 		= KinPlant.tbPlantNpcInfo or {};	--树信息
KinPlant.tbPlantFruit 		= KinPlant.tbPlantFruit or {};		--果实反索引
KinPlant.tbKinInfo 			= KinPlant.tbKinInfo or {};		--gs记录加载家族npc标志
KinPlant.tbPlantLevel 		= KinPlant.tbPlantLevel or {};		--家园等级
KinPlant.tbPlantKinRate		= KinPlant.tbPlantKinRate or {};	--家园等级加成
KinPlant.tbNpcPoint 		= KinPlant.tbNpcPoint or {};		--种植点

KinPlant.tbWeeklyEvent 		= KinPlant.tbWeeklyEvent or {};	--周末种植活动
KinPlant.tbWeeklyNpcPoint 	= KinPlant.tbWeeklyNpcPoint or {};		--种植点
KinPlant.tbManagerNpc 		= KinPlant.tbManagerNpc or {};	--周末种植活动npc管理

--insert table
KinPlant.tbPlantWeekTask	= {};		--任务

--获得当前状态
function KinPlant:GetState()
	return self.IS_OPEN;
end

--土壤点
function KinPlant:LoadPos()	
	local szFileName = "\\setting\\kin\\kinplant\\plantpos.txt";
	local tbFile = Lib:LoadTabFile(szFileName);
	if not tbFile then
		print("Tập tin [Trồng trọt gia tộc] không tồn tại",szFileName);
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

--树信息
function KinPlant:LoadPlantInfo()	
	local szFileName = "\\setting\\kin\\kinplant\\plant.txt";
	local tbFile = Lib:LoadTabFile(szFileName);
	if not tbFile then
		print("Tập tin [Trồng trọt gia tộc] không tồn tại",szFileName);
		return;
	end
	for nId, tbParam in ipairs(tbFile) do
		if nId > 1 then
			local nId 		= tonumber(tbParam.nId) or 0;
			local szItem 	= tbParam.Item or "";
			local szFruitItem 	= tbParam.FruitItem or "";
			local nType		= tonumber(tbParam.Type) or 0;
			local nGrade1 		= tonumber(tbParam.Grade1) or 0;
			local nGrade2 		= tonumber(tbParam.Grade2) or 0;
			local nGrade3		= tonumber(tbParam.Grade3) or 0;
			local nExp1 		= tonumber(tbParam.Exp1) or 0;
			local nExp2 		= tonumber(tbParam.Exp2) or 0;
			local nExp3 		= tonumber(tbParam.Exp3) or 0;
			local nKinExp 		= tonumber(tbParam.KinExp) or 0;
			local nMaxAwardCount 	= tonumber(tbParam.MaxAwardCount) or 0;
			local nMaxGetOther 	= tonumber(tbParam.MaxGetOther) or 0;
			local nPerGetOther 		= tonumber(tbParam.PerGetOther) or 0;
			local nWeather1 		= tonumber(tbParam.Weather1) or 0;
			local nWeather2 		= tonumber(tbParam.Weather2) or 0;
			local nWeather3 		= tonumber(tbParam.Weather3) or 0;
			local nDredging 		= tonumber(tbParam.Dredging) or 0;
			local tbTempNpcId 		= {};
			local tbTime 			= {};
			for i = 1, 10 do
				local nTempNpcId = tonumber(tbParam["TempNpcId"..i]) or 0;
				local nTime = tonumber(tbParam["Time"..i]) or 0;				
				if nTime > 0 and nTempNpcId > 0 then
					table.insert(tbTempNpcId, nTempNpcId);
					table.insert(tbTime, nTime);
				end
			end
			self.tbPlantFruit[szFruitItem] = {szItem = szItem, nId = nId};
			self.tbPlantNpcInfo[nId] = {szItem = szItem, szFruitItem = szFruitItem, nType = nType, tbGrade = {nGrade1, nGrade2, nGrade3}, tbExp = {nExp1, nExp2, nExp3}, nKinExp = nKinExp, nMaxAwardCount = nMaxAwardCount, 
				nMaxGetOther = nMaxGetOther, nPerGetOther = nPerGetOther, tbWeather = {nWeather1, nWeather2, nWeather3}, nDredging = nDredging, tbTempNpcId = tbTempNpcId,
				tbTime = tbTime};
		end
	end
end

--土壤点
function KinPlant:LoadPlantLevel()	
	local szFileName = "\\setting\\kin\\kinplant\\plantexp.txt";
	local tbFile = Lib:LoadTabFile(szFileName);
	if not tbFile then
		print("Tập tin [Trồng trọt gia tộc] không tồn tại",szFileName);
		return;
	end
	for nId, tbParam in ipairs(tbFile) do
		local nLevel = tonumber(tbParam.nLevel) or -1;
		local nExp = tonumber(tbParam.nExp) or -1;
		local nRate = tonumber(tbParam.nRate) or 1;
		if nLevel >= 0 and nExp > 0 then
			self.tbPlantLevel[nLevel] = nExp;
			self.tbPlantKinRate[nLevel] = nRate;
		end
	end
end

--任务
function KinPlant:LoadPlantTask()	
	local szFileName = "\\setting\\kin\\kinplant\\planttask.txt";
	local tbFile = Lib:LoadTabFile(szFileName);
	if not tbFile then
		print("Tập tin [Trồng trọt gia tộc] không tồn tại",szFileName);
		return;
	end
	for nId, tbParam in ipairs(tbFile) do
		if nId > 1 then
			local nType = tonumber(tbParam.nType) or 0;	
			local szMsg = tbParam.szMsg or "";
			local tbFruit = {};
			for i =1, 5 do
				local szItem = tbParam["Item"..i] or "";
				local nCount = tonumber(tbParam["nCount"..i]) or 0;
				local nSeedCount = tonumber(tbParam["nSeedCount"..i]) or 0;
				if szItem ~= "" and nCount > 0 then
					tbFruit[i] = {szItem, nCount, nSeedCount};
				end
			end
			if nType >= 1 and nType <= 3 and szMsg ~= "" then
				self.tbPlantWeekTask[nType] = self.tbPlantWeekTask[nType] or {};
				table.insert(self.tbPlantWeekTask[nType], {tbFruit, szMsg});
			end
		end
	end
end

KinPlant:LoadPos();
KinPlant:LoadPlantInfo();
KinPlant:LoadPlantLevel();
KinPlant:LoadPlantTask();
