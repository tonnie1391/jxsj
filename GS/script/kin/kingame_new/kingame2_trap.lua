-- 文件名　：kingame2_trap.lua
-- 创建者　：zhangjunjie
-- 创建时间：2011-06-19 20:56:33
-- 描述：新家族关卡的trap点

Require("\\script\\kin\\kingame_new\\table_def.lua")

local tbMap = {};

--初始化地图trap，没有特殊的trap点，通用处理
function KinGame2:InitTrap(nMapId)
	local tbMapTrap = Map:GetClass(nMapId);
	for nRoomId, tbMapInfo in pairs(KinGame2.MapTrap) do
		for szClassName, tbPosInfo in pairs(tbMapInfo) do
			local tbTrap	= tbMapTrap:GetTrapClass(szClassName);
			tbTrap.nMapId = nMapId;
			tbTrap.nRoomId = nRoomId;
			tbTrap.nPosX = tbPosInfo[1];
			tbTrap.nPosY = tbPosInfo[2];
			tbTrap.nDirection = tbPosInfo[3];	--加上这个trap的方向，区分左右房间，0表示无区分，1表示左，2表示右
			for szFnc in pairs(tbMap) do		-- 复制函数
				tbTrap[szFnc] = tbMap[szFnc];
			end
		end
	end
end

-- 定义玩家Trap事件
function tbMap:OnPlayer()
	local pGame =  KinGame2:GetGameObjByMapId(me.nMapId) --获得对象
	if pGame == nil then
		return 0;
	end
	local pRoom = pGame.tbRoom[self.nRoomId];
	if self.nRoomId == 1 and pRoom:IsRoomStart() == 1 then --入口
		if me.nFightState == 0 then
			me.SetFightState(1)
			me.NewWorld(me.nMapId, KinGame2.FIGHTSTATE_POS[1], KinGame2.FIGHTSTATE_POS[2]);
			return 0;
		else
			me.SetFightState(0)
			me.NewWorld(me.nMapId, self.nPosX / 32, self.nPosY /32);
		end
	end
	--4,5,6房间分为左右两个trap,开启一侧的npc，另一侧的才能open
	if self.nRoomId == 4 or self.nRoomId == 5 or self.nRoomId == 6 then
		if self.nDirection == 1 and pRoom.nIsLeftOpen == 1 and pRoom:IsRoomStart() == 1 then
			return 0;
		elseif self.nDirection == 2 and pRoom.nIsRightOpen == 1 and pRoom:IsRoomStart() == 1 then
			return 0;
		else
			Dialog:SendBlackBoardMsg(me, "需要开启两边的机关才能进入");
			me.NewWorld(me.nMapId, self.nPosX / 32, self.nPosY / 32);
			return 0;
		end
	end
	if pRoom:IsRoomStart() == 1 then
		return 0;
	end
	me.NewWorld(me.nMapId, self.nPosX / 32, self.nPosY / 32);
end

KinGame2:InitTrap(KinGame2.MAP_TEMPLATE_ID);