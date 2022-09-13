-- 文件名　：test.lua
-- 创建者　：sunduoliang
-- 创建时间：2009-05-15 17:54:02
-- 描  述  ：开关类
-- 具体可参考龙舟写法\script\mission\dragonboat\console.lua


local DEF_TEST = 0;
local Test = Console:New(DEF_TEST);

GM.testConcole	= Test;

--GC开启
function Test:InitGame()
	self.tbCfg ={
		--[准备场Id] = {tbInPos={进入准备场的点},tbOutPos={离开准备场到的地图和点}}; 没有tbOutPos为默认本服务器新手村车夫随机传送点
		tbMap 		= {[1]={tbInPos={1450, 3110},tbOutPos={1, 1450,3110}}}; 	
		nDynamicMap	= 2;						--动态地图模版Id
		nMaxDynamic = 1;				 		--比赛场动态地图加载数量;
		nMaxPlayer  = 20;						--每个准备场人数上限;
		nReadyTime	= 60*18;					--准备场时间(秒);
	};
	
end
--Test:InitGame();

--GC开启报名
function Test:OnStartGame()
	self:StartSignUp()
end

--GS开启报名回调
function Test:OnMySignUp()
	print("StartSignUp");
end

--GC
function GM.testConcole:OnStart()
	GlobalExcute{"GM.testConcole:Start"};
	self:Start()
end

--GS玩家报名入场：
function GM.testConcole:SignUp()
	Console:ApplySignUp(DEF_TEST, {me.nId});
end


--进入活动场地后
function Test:OnJoin()
	print("OnJoin", me.szName)
end

--离开活动场地后
function Test:OnLeave()
	print("OnLeave", me.szName)
end

--进入准备场后
function Test:OnJoinWaitMap()
	print("OnJoinWaitMap", me.szName)
end

--离开准备场后
function Test:OnLeaveWaitMap()
	print("OnLeaveWaitMap", me.szName)
end

--分组逻辑
--tbCfg = {tbGroupLists={{PlayerId1,...},...}, nDyMapIndex = 1}
--6队一组；
function Test:GroupLogic(tbCfg)
	local nGroupDivide  = 0;
	for nGroup, tbGroup in ipairs(tbCfg.tbGroupLists) do
		for _, nPlayerId in pairs(tbGroup) do
			local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
			--对象，分配动态地图索引，组号；
			if pPlayer then
				self:OnDyJoin(pPlayer, tbCfg.nDyMapIndex, nGroup);
				nGroupDivide = nGroupDivide + 1;
			end
		end
		if nGroupDivide >= 6 then
			nGroupDivide = 0;
			tbCfg.nDyMapIndex = tbCfg.nDyMapIndex + 1;
		end
	end
	print("GroupLogic");
end

--开始活动场；
function Test:OnMyStart(tbCfg)
	print("OnMyStart")
	local nWaitMapId	= tbCfg.nWaitMapId;		--准备场Id
	local nDyMapId 	 	= tbCfg.nDyMapId;		--活动场Id
	local tbGroupLists 	= tbCfg.tbGroupLists;	--队伍列表
	print(nWaitMapId, nDyMapId, tbGroupLists);
end
