------------------------------------------------------
-- 文件名　：basecarrier.lua
-- 创建者　：dengyong
-- 创建时间：2012-05-09 10:21:31
-- 描  述  ：
------------------------------------------------------

-- 载具基类，所有类别的载具都是由该类派生
local tbCarrierBase = {}

function tbCarrierBase:Init()
end

function tbCarrierBase:CanUseSkill(pPlayer, nSkillId)
	return 1;
end

function tbCarrierBase:CanOperate(nOpeSeq)
	return 0;
end

function tbCarrierBase:Operate(nOpeSeq)
	if (self:PreOperate(nOpeSeq) ~= 1) then
		return 0;
	end	
	return self:PostOperate(nOpeSeq);
end


function tbCarrierBase:PreOperate(nOpeSeq)
	return 0;
end

function tbCarrierBase:PostOperate(nOpeSeq)
	return 0;
end

-- 真心不想加这个东西，这会使得tbCarrier的定义很混乱，纠结！
function tbCarrierBase:OnDeath()
	if MODULE_GAMESERVER then
		local tbPlayers = him.GetCarrierPassengers();
		for _,pPlayer in pairs(tbPlayers) do
			if pPlayer then 
				pPlayer.LandOffCarrier();
			end
		end	
	end
end

function tbCarrierBase:OnPlayerLandIn(pPlayer, nSeat)
	--pPlayer.Msg("登陆载具光荣！座位号："..nSeat);
end

function tbCarrierBase:OnPlayerLandOff(pPlayer, nSeat)
	--pPlayer.Msg("离开载具可耻！原座位号："..nSeat)
end

function tbCarrierBase:LandInCarrier(pPlayer, nSeat)	
	pPlayer.LandInCarrier(him.nIndex, nSeat);
end

function tbCarrierBase:LandOffCarrier(pPlayer, nSeat)
	pPlayer.LandOffCarrier();
end

function tbCarrierBase:OnAttachNpc()
end

-- 这个也不想加
function tbCarrierBase:OnPlayerLeaveTeam(pPlayer)
end

function tbCarrierBase:IsFullyLoad()
	local tbPassengers, nLoad = him.GetCarrierPassengers();
	if Lib:CountTB(tbPassengers) >= nLoad then
		return 1;
	end
	
	return 0;
end

function tbCarrierBase:BroadCastMsg(szMsg)
	print("tbCarrierBase:BroadCastMsg", szMsg);
	-- 对所有乘客，调用pPlayer.Msg(szMsg);
	-- 客户端貌似不太好操作呀。。。
	if MODULE_GAMESERVER then
		local tbPassengers = him.GetCarrierPassengers();
		for _, pPassenger in pairs(tbPassengers) do
			pPassenger.Msg(szMsg);		
		end
	else
		--me.CallServerScript();		-- 这样？
	end
end

----------------------------------------------------------------------------
-- 载具控制器，主要处理载具消息派发，提供外部调用接口
local tbCarrier = Npc.tbCarrier or {};
Npc.tbCarrier = tbCarrier;

-- 载具登入距离限制
tbCarrier.LAND_IN_MAX_DISTANCE	= 15;		-- 15个格子

if not tbCarrier.tbClass then
	tbCarrier.tbClass = { ["base"] = tbCarrierBase };
end

function tbCarrier:Init(szTemplate)
	local tbClass = self.tbClass[szTemplate] or tbCarrierBase;
	if not tbClass then
		return 0;
	end

	return tbClass:Init();
end

function tbCarrier:CanUseSkill(szTemplate, pPlayer, nSkillId)
	local tbClass = self.tbClass[szTemplate] or tbCarrierBase;
	if not tbClass then
		return 0;
	end
	
	return tbClass:CanUseSkill(pPlayer, nSkillId);
end

function tbCarrier:OnDeath(szTemplate)
	local tbClass = self.tbClass[szTemplate] or tbCarrierBase;
	if not tbClass then
		return 0;
	end
	
	return tbClass:OnDeath();
end

function tbCarrier:CanOperate(szTemplate, nOpeSeq)
	local tbClass = self.tbClass[szTemplate] or tbCarrierBase;
	if not tbClass then
		return 0;
	end

	return tbClass:CanOperate(nOpeSeq);
end

function tbCarrier:Operate(szTemplate, nOpeSeq)
	local tbClass = self.tbClass[szTemplate] or tbCarrierBase;
	if not tbClass then
		return 0;
	end
	
	return tbClass:Operate(nOpeSeq);
end

function tbCarrier:OnPlayerLandIn(szTemplate, pPlayer, nSeat)
	local tbClass = self.tbClass[szTemplate] or tbCarrierBase;
	if not tbClass then
		return 0;
	end
	return tbClass:OnPlayerLandIn(pPlayer, nSeat);
end

function tbCarrier:OnPlayerLandOff(szTemplate, pPlayer, nSeat)
	local tbClass = self.tbClass[szTemplate] or tbCarrierBase;
	if not tbClass then
		return 0;
	end
	return tbClass:OnPlayerLandOff(pPlayer, nSeat);
end

function tbCarrier:GetClass(szTemplate)
	if not self.tbClass[szTemplate] then
		local tbClass = Lib:NewClass(tbCarrierBase);
		self.tbClass[szTemplate] = tbClass;
	end
	
	return self.tbClass[szTemplate];
end

-- 带表现的载具登入方式
function tbCarrier:LandInCarrier(pCarrier, pPlayer, nSeat)
	local szTemplate = pCarrier.GetCarrierTemplate();
	if not szTemplate then
		return 0;
	end
	
	local tbClass = self.tbClass[szTemplate] or tbCarrierBase;
	if not tbClass then
		return 0;
	end
	
	if pPlayer.IsInCarrier() == 1 then
		return 0;
	end
	
	if not nSeat then
		nSeat = -1;
	end
	--判断与载具的距离
	local nMapId1, nPosX1, nPosY1 = pPlayer.GetWorldPos();
	local nMapId2, nPosX2, nPosY2 = pCarrier.GetWorldPos();
	local nDis	= ((nPosX1-nPosX2)^2 + (nPosY1-nPosY2)^2)^0.5;
	if nMapId1 ~= nMapId2 or nDis > self.LAND_IN_MAX_DISTANCE then
		pPlayer.Msg("距离太远了，无法乘坐载具。");
		return;
	end
		
	Setting:SetGlobalObj(nil, pCarrier);
	local nRet = tbClass:LandInCarrier(pPlayer, nSeat);
	Setting:RestoreGlobalObj();
	
	return nRet;
end

function tbCarrier:OnAttachNpc(szTemplate)
	local tbClass = self.tbClass[szTemplate] or tbCarrierBase;
	if not tbClass then
		return;
	end
	
	tbClass:OnAttachNpc();
end

function tbCarrier:LandOffCarrier(pCarrier, pPlayer, nSeat)
	local szTemplate = pCarrier.GetCarrierTemplate();
	if not szTemplate then
		return 0;
	end
	
	local tbClass = self.tbClass[szTemplate] or tbCarrierBase;
	if not tbClass then
		return 0;
	end
	
	Setting:SetGlobalObj(nil, pCarrier);
	local nRet = tbClass:LandOffCarrier(pPlayer, nSeat);
	Setting:RestoreGlobalObj();
	
	return nRet;
end

function tbCarrier:OnPlayerLeaveTeam(pCarrier, pPlayer)
	local szTemplate = pCarrier.GetCarrierTemplate();
	if not szTemplate then
		return;
	end
	
	local tbClass = self.tbClass[szTemplate] or tbCarrierBase;
	if not tbClass then
		return;
	end
	
	Setting:SetGlobalObj(nil, pCarrier);
	tbClass:OnPlayerLeaveTeam(pPlayer);
	Setting:RestoreGlobalObj();
end

function tbCarrier:LoadAiSetting(szTemplate)
	local tbClass = self.tbClass[szTemplate] or tbCarrierBase;
	if not tbClass then
		return 0;
	end
	
	return tbClass:LoadAiSetting();
end

----------------------------------------------------------------------------
-- 船，最简单的载具。。。
local tbBoat = tbCarrier:GetClass("Boat");
function tbBoat:Init()
	self.MOVE_POS_INT_ID	= 1;
		
	self.tbMovePos = 
	{
		[1] =		-- 路程1  镇子—渡头
		{
			{1958 * 32, 3484 * 32},
			{1946 * 32, 3496 * 32},
			{1924 * 32, 3518 * 32},
			{1906 * 32, 3534 * 32},
			{1883 * 32, 3559 * 32},
			{1866 * 32, 3562 * 32},
			{1849 * 32, 3540 * 32},
			{1823 * 32, 3551 * 32},
			{1812 * 32, 3566 * 32},
		},
		[2] =		-- 路程2 渡头—水寨
		{
			--{1771 * 32, 3569 * 32},
			{1757 * 32, 3592 * 32},
			{1750 * 32, 3627 * 32},
			{1729 * 32, 3657 * 32},
			{1704 * 32, 3675 * 32},
			{1686 * 32, 3694 * 32},
			{1677 * 32, 3706 * 32},
		},
		[3] = 		-- 路程3 水寨--渡头
		{
			--{1677 * 32, 3706 * 32},
			{1686 * 32, 3694 * 32},
			{1704 * 32, 3675 * 32},
			{1729 * 32, 3657 * 32},
			{1750 * 32, 3627 * 32},
			{1757 * 32, 3592 * 32},
			{1771 * 32, 3569 * 32},	
		},
		[4] =			-- 青螺岛，码头到得月舫 
		{
			--{1670 * 32, 3739 * 32},
			--{1665 * 32, 3745 * 32},
			{1668 * 32, 3758 * 32},
			{1671 * 32, 3770 * 32},
			{1674 * 32, 3796 * 32},
			{1671 * 32, 3803 * 32},
		},
		[5] = 			-- 花灯乱，新手副本
		{
			--{1769 * 32, 3573 * 32},
			{1766 * 32, 3577 * 32},
			{1764 * 32, 3592 * 32},
			{1782 * 32, 3605 * 32},
			{1794 * 32, 3606 * 32},
			{1817 * 32, 3608 * 32},
			{1831 * 32, 3614 * 32},
		}
	}
	
	self.tbDestPos =
	{
		-- 地图ID为nil, 表示在当前地图内的传送
		[1] = {nil, 1805 * 32, 3556 * 32},
		[2] = {nil, 1673 * 32, 3712 * 32},
		[3] = {nil, 1777 * 32, 3560 * 32},
		[4] = {nil, 53376, 121984},
		[5] = "local pPlayer = ...;Task.NewPrimerLv20:LeaveGame(pPlayer.nId);",		
		--[5] = {"local nLine = GetServerId();if nLine >= 1 and nLine <= 7 then return 55 else return 55 end ", 1676 * 32, 3721 * 32},
	}
	
	self.tbSailTimer = 
	{
		[5] = {18 * 7, Task.OnHuaDengLuanBoatTimer, Task};
	}
end

-- 开船啦。。
function tbBoat:SetSail()
	-- 船的AI是自动移动AI
	him.AI_ClearPath();
	
	-- 增加自动移动过程中的关键点
	local nMovePosIdx = him.GetCarrierIntData(self.MOVE_POS_INT_ID);
	if nMovePosIdx <= 0 or nMovePosIdx > #self.tbMovePos then
		print("set sail failed!", nMovePosIdx)
		return;
	end	

	local tbMovePos = self.tbMovePos[nMovePosIdx];
	for _, tbPos in pairs(tbMovePos) do
		him.AI_AddMovePos(unpack(tbPos));
	end	
	
	him.SetNpcAI(9, 0, 1, -1, 25, 25, 25, 0, 0, 0, 0);
	him.GetTempTable("Npc").tbOnArrive = {self.OnArrive, self, him.dwId};
	him.AddSkillState(2927, 1, 1, 3600 * 18);		-- 1个小时，足够长了！
end

function tbBoat:OnArrive(dwBoadId)
	local pBoat = KNpc.GetById(dwBoadId);
	if not pBoat then
		return;
	end
	
	Setting:SetGlobalObj(nil, pBoat);
	pBoat.AI_ClearPath();
	pBoat.SetNpcAI(100,0,0,0,0,0,0,0,0,0,0);
	pBoat.RemoveSkillState(2927);
	Setting:RestoreGlobalObj();
	
	local tbPassengers = pBoat.GetCarrierPassengers();
	if not tbPassengers or Lib:CountTB(tbPassengers) == 0 then
		pBoat.Delete();
	else
		self:LandOffCarrier(tbPassengers[0]);
	end
end

function tbBoat:LandInCarrier(pPlayer, nSeat)
	if (him.IsCarrier() == 0) then
		return;
	end
	
	-- 前逻辑判断，队伍人数不能满，战车位置不能满
	if self:IsFullyLoad() == 1 then
		pPlayer.Msg("载具位置已满！");
		return;
	end
	
	nSeat = nSeat or -1;	-- -1表示系统指定座位号
	
	-- 表现操作，执行服务端CMD，玩家在期间失去控制，由服务端控制完成某些操作，操作完成交回控制权
	local tbCmd = {};
	table.insert(tbCmd, {nil, nil, 8});		-- 插入一条空指令，作延迟效果
	local szAction = string.format([[local pPlayer = ...;
		local _, x, y = %d, %d, %d;
		pPlayer.DoCommand(4, x * 32, y * 32, 600);]],
		him.GetWorldPos());
	table.insert(tbCmd, {nil, szAction, 20});	-- 用轻功跳到载具处
	szAction = string.format("local pPlayer = ...;pPlayer.LandInCarrier(%d, %d);", him.nIndex, nSeat);
	table.insert(tbCmd, {nil, szAction, 0});	-- 逻辑登入
	
	Player:DoServerCmd(pPlayer, tbCmd);
end

function tbBoat:OnPlayerLandIn(pPlayer, nSeat)
	if MODULE_GAMESERVER then
		pPlayer.SetFightState(0);
		pPlayer.SetTask(2000, 6, 1);
		pPlayer.SendSyncData();
		self:SetSail();
		
		local nLine = him.GetCarrierIntData(self.MOVE_POS_INT_ID);
		if self.tbSailTimer[nLine] then
			local tb = {unpack(self.tbSailTimer[nLine])};
			table.insert(tb, pPlayer.nId)
			Timer:Register(unpack(tb));
		end
	end
end

function tbBoat:OnPlayerLandOff(pPlayer, nSeat)
	if MODULE_GAMESERVER then
		local nMovePosIdx = him.GetCarrierIntData(self.MOVE_POS_INT_ID);
		local var = self.tbDestPos[nMovePosIdx];
		
		if type(var) == "string" then
			local pfn = loadstring(var);
			if pfn then
				pfn(pPlayer);
			end			
		elseif type(var) == "table" then
			local m, x, y = unpack(var);
			if type(m) == "string" then
				local pfn = loadstring(m);
				if pfn then
					m = pfn();
				end
			end
			
			pPlayer.NewWorld(m or pPlayer.nMapId, x/32, y/32);
		end
		pPlayer.SetTask(2000, 6, 0);
		pPlayer.SetTask(1025, 83, 0);
		pPlayer.SendSyncData();
		him.Delete();
	end
end

----------------------------------------------------------------------------
-- 青螺岛任务里用到的战车
local tbTaskChariot = tbCarrier:GetClass("StoneThrowerTask");

function tbTaskChariot:OnPlayerLandOff(pPlayer, nSeat)
	if MODULE_GAMESERVER then
		pPlayer.SetTask(2000, 6, 0);	-- 去掉隐藏周围玩家
		pPlayer.SendSyncData();
		
		him.Delete();
	end
end

function tbTaskChariot:OnPlayerLandIn(pPlayer, nSeat)
	if MODULE_GAMESERVER then
		pPlayer.SetTask(2000, 6, 1);	-- 隐藏周围玩家
		pPlayer.SendSyncData();
	end
end