-- 文件名　：event_def.lua
-- 创建者　：jiazhenwei
-- 创建时间：2011-08-31 11:08:46
-- 功能    ：新服活动201109

SpecialEvent.tbNewGateEvent = SpecialEvent.tbNewGateEvent or {};
local tbNewGateEvent = SpecialEvent.tbNewGateEvent;
tbNewGateEvent.tbOldList = {};			--读文件
tbNewGateEvent.tbOldListBuff = {};		--buff

tbNewGateEvent.tbKinAward = {};			--家族拉人赛

tbNewGateEvent.TASK_GROUPID 			= 2176;	-- 任务变量组
tbNewGateEvent.TASK_BINDOLD			= 10;		-- 是否绑定老账号
tbNewGateEvent.TASK_BINDAWARD		= 11;		-- 充值绑定老玩家领奖
tbNewGateEvent.TASK_GRADE			= 12;		-- 开学有礼绑银领取
tbNewGateEvent.TASK_SMALLBAG			= 13;		-- 开学有礼小礼包
tbNewGateEvent.TASK_BAG				= 14;		-- 开学有礼礼包
tbNewGateEvent.TASK_BIGBAG			= 15;		-- 开学有礼大礼包
tbNewGateEvent.TASK_KINAWARD			= 16;		-- 家族招募赛个人领奖
tbNewGateEvent.TASK_BINDCOIN			= 17;		-- 100元绑金返还券
tbNewGateEvent.TASK_BACKCOIN			= 106;		-- 绑金返还名字（106-113）
tbNewGateEvent.TASK_BACKCOINFLAG		= 114;		-- 绑金返还数值和标志
tbNewGateEvent.TASK_BAIHUATIMES		= 115;		-- 白虎返还次数
tbNewGateEvent.TASK_BAIHUATIMESTAMP	= 116;		-- 上次白虎返还时间戳

tbNewGateEvent.nMoney = 500000;			--绑银奖励
tbNewGateEvent.tbItem = {18, 1, 251, 1};		--秘境地图奖励
tbNewGateEvent.nMinLevel = 60;			--等级要求
tbNewGateEvent.tbXingyunLiBao = {[2] = {18, 1, 1468, 2},[3] = {18, 1, 1468, 1},[4] = {18, 1, 1468, 4},};		--幸运礼包

tbNewGateEvent.nStartTime  	= 20111219	--百大威望赛开启时间
tbNewGateEvent.nEndTime1  	= 20111226	--百大威望赛结束时间	前一天
tbNewGateEvent.nEndTime2	= 1800		--百大威望赛结束时间	最后一天截止时间

tbNewGateEvent.nServerStarLimit  		= 20111122		--百大威望赛开服时间限制

tbNewGateEvent.nSeniorStartTime  	= 20111122	--师兄师姐待你闯江湖开启时间
tbNewGateEvent.nSeniorEndTime  		= 20111228	--师兄师姐待你闯江湖结束时间

tbNewGateEvent.nFriendBackStarTime  	= 20111122	--密友返还开启时间
tbNewGateEvent.nFriendBackEndTime  	= 20111222	--密友返还结束时间

tbNewGateEvent.szTitleName 	= "江湖新秀"		--新秀称号

--开学有礼奖励
tbNewGateEvent.tbStudentAward = {
	[2] = {[1] = {
			{1, {18, 1, 689, 1},30},
			{2, 200000, 30},
			{3, 1000, 30},
			{4, 16, 20},
		},
		[2] = {
			{2, 200000, 40},
			{3, 1000, 30},
			{4, 16, 30},
		},
	},
	[3] = {[1] = {
			{1, {18, 1, 1342, 2},20},
			{2, 300000, 30},
			{3, 1500, 20},
			{4, 24, 30},
		},
		[2] = {
			{2, 300000, 40},
			{3, 1500, 20},
			{4, 24, 40},
		},
	},
	[4] = {[1] = {
			{1, {18,1,1342,5},15},
			{2, 1000000, 30},
			{3, 5000, 20},
			{4, 80, 35},
		},
		[2] = {
			{2, 1000000, 35},
			{3, 5000, 20},
			{4, 80, 45},
		},
	},
};

--家族拉人赛奖励
tbNewGateEvent.tbKinMoneyAward = {[1] = 800000, [3] = 300000};
tbNewGateEvent.tbKinAwardEx = {
	[1] = {{1, 5000},
		  {2, 1000000},
		  {3, 50},
		  {4, {18, 1, 114, 7, 3}},
		  {5, "卓越家族族长"}},
	[2] = {{1, 1000},
		  {4, {18, 1 ,1352, 3, 1}},
		  {3, 10},
		  {4, {18, 1, 114, 7, 1}},
		  {5, "卓越家族成员"}},
	[3] = {{1, 3000},
		  {2, 500000},
		  {3, 35},
		  {4, {18, 1, 114, 7, 2}},
		  {5, "杰出家族族长"}},
	[4] = {{1,500},
		  {4, {18, 1, 1352, 3, 1}},
		  {3, 10},
		  {4, {18, 1, 114, 6, 3}},
		  {5, "杰出家族成员"}},
	[5] = {{1, 1000},
		  {2, 300000},
		  {3, 10},
		  {4, {18, 1, 114, 7, 1}},
		  {5, "优秀家族族长"}},
	[6] = {{1, 500},
		  {4, {18, 1, 1352, 3, 1}},
		  {4, {18, 1, 114, 6, 2}},
		  {5, "优秀家族成员"}},
};

tbNewGateEvent.tbItemType = {[2] = 2, [3] = 9, [4] = 12};	--拉新实物卡对应id

function tbNewGateEvent:Init()
	local tbWeek = {1, 0, 6, 5, 4, 3, 2} --日期矫正到周一
	local nServerStarTime = tonumber(KGblTask.SCGetDbTaskInt(DBTASD_SERVER_STARTTIME));
	local nServerStartDay = tonumber(os.date("%Y%m%d", nServerStarTime));
	if nServerStartDay >= self.nServerStarLimit then		--只有20111122之后的服务器才有这个东东
		--威望赛
		local nWeiwangStart = nServerStarTime + 25*24*3600;
		local nWeek = tonumber(os.date("%w", nWeiwangStart));
		self.nStartTime = tonumber(os.date("%Y%m%d", nWeiwangStart + tbWeek[nWeek + 1] * 24 * 3600));	--矫正到25天下个周一
		self.nEndTime1 = tonumber(os.date("%Y%m%d", nWeiwangStart + (tbWeek[nWeek + 1] + 7) * 24 * 3600));	--矫正到25天下下个周一
		--师兄师姐待你闯江湖开启时间
		self.nSeniorStartTime  		= nServerStartDay;
		self.nSeniorEndTime  		= tonumber(os.date("%Y%m%d", nServerStarTime + 36*24*3600));	--师兄师姐待你闯江湖结束时间
		--密友返还开启时间
		self.nFriendBackStarTime  	= nServerStartDay;
		self.nFriendBackEndTime  	= tonumber(os.date("%Y%m%d", nServerStarTime + 30*24*3600));	--密友返还结束时间
	end
end

if MODULE_GAMESERVER then
	ServerEvent:RegisterServerStartFunc(SpecialEvent.tbNewGateEvent.Init, SpecialEvent.tbNewGateEvent);
end

if MODULE_GC_SERVER then
	GCEvent:RegisterGCServerStartFunc(SpecialEvent.tbNewGateEvent.Init, SpecialEvent.tbNewGateEvent);
end
