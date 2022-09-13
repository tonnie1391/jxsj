------------------------------------------------------
-- 文件名　：boat2.lua
-- 创建者　：dengyong
-- 创建时间：2012-08-10 10:44:00
-- 描  述  ：又是一条船，可控制移动和释放技能
------------------------------------------------------
Require("\\script\\npc\\carrier\\stonethrower.lua");

local tbCarrier = Npc.tbCarrier or {};
local tbBoat2 = tbCarrier:GetClass("Boat2");
local tbCarrierShortCutSkill = Npc.tbCarrierShortCutSkill or {};

function tbBoat2:Init()
end

function tbBoat2:CanUseSkill(pPlayer, nSkill)
	if MODULE_GAMESERVER then
		local tbPassengers = him.GetCarrierPassengers();
		if Lib:CountTB(tbPassengers) == 1 then
			return 1;		-- 当船上只有一个人时，这个人可以放技能
		end		
		
		-- 0号位置才能释放技能
		if not tbPassengers or not tbPassengers[0] then
			return 0;
		end
		
		local passenger = tbPassengers[0];
		if passenger.nId ~= pPlayer.nId then
			return 0;
		end
	end
	
	return 1;
end

function tbBoat2:OnPlayerLandIn(pPlayer, nSeat)
	if MODULE_GAMESERVER then
		pPlayer.SetFightState(0);
		
		-- 安装快捷键
		tbCarrierShortCutSkill:Setup("Boat2", him, pPlayer, nSeat);
	end
end

function tbBoat2:LandInCarrier(pPlayer, nSeat)
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
	szAction = string.format("local pPlayer = ...;pPlayer.RideHorse(0);pPlayer.LandInCarrier(%d, %d);", him.nIndex, nSeat);
	table.insert(tbCmd, {nil, szAction, 0});	-- 逻辑登入
	
	Player:DoServerCmd(pPlayer, tbCmd);
end

function tbBoat2:OnPlayerLandOff(pPlayer, nSeat)
	if MODULE_GAMESERVER then
		--pPlayer.NewWorld(pPlayer.nMapId, x/32, y/32);
		local nMapId, nX, nY = pPlayer.GetWorldPos();
		local tbInstancing = TreasureMap2:GetInstancing(nMapId);
		if tbInstancing and tbInstancing.OnPlayerLeaveBoat then
			tbInstancing:OnPlayerLeaveBoat(pPlayer);
		end
	end
	tbCarrierShortCutSkill:Uninstall(pPlayer);
end