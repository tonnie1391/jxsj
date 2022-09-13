-- 文件名　：trap.lua
-- 创建者　：zhangjunjie
-- 创建时间：2011-10-27 17:36:07
-- 描述：龙门飞剑trap

TreasureMap2.MapTrapLongmenfeijian = {};

function TreasureMap2:LoadLongmenfeijianTrap()
	self.MapTrapLongmenfeijian = {};
	local szFile = "\\setting\\task\\treasuremap2\\longmenfeijian\\maptrap.txt";
	local tbFile = Lib:LoadTabFile(szFile);
	if tbFile then
		for _, tbItem in pairs(tbFile) do
			local nTrapId  		= tonumber(tbItem.TrapId);
			local szTrapName  = tbItem.TrapName;
			local nPosX 			= tonumber(tbItem.TRPOSX);
			local nPosY 			= tonumber(tbItem.TRPOSY);
			if self.MapTrapLongmenfeijian[nTrapId] == nil then
				self.MapTrapLongmenfeijian[nTrapId]	= {};
			end
			self.MapTrapLongmenfeijian[nTrapId][szTrapName] = {nPosX,nPosY};
		end
	end	
end


local tbMap = {};

function TreasureMap2:InitLongmenfeijianTrap(nMapId)
	local tbMapTrap = Map:GetClass(nMapId);
	for nTrapId, tbMapInfo in pairs(TreasureMap2.MapTrapLongmenfeijian) do
		for szClassName, tbPosInfo in pairs(tbMapInfo) do
			local tbTrap	= tbMapTrap:GetTrapClass(szClassName);
			tbTrap.nMapId = nMapId;
			tbTrap.nTrapId = nTrapId;
			tbTrap.nPosX = tbPosInfo[1];
			tbTrap.nPosY = tbPosInfo[2];
			for szFnc in pairs(tbMap) do		-- 复制函数
				tbTrap[szFnc] = tbMap[szFnc];
			end
		end
	end
end

-- 定义玩家Trap事件
function tbMap:OnPlayer()
	local pGame = TreasureMap2:GetInstancing(me.nMapId); --获得对象
	if not pGame then
		return 0;
	end
	local pRoom = pGame.tbRoom;
	if not pRoom then
		return 0;
	end
	if pGame:GetTrapOpenState(self.nTrapId) ~= 1 then
		Dialog:SendBlackBoardMsg(me,"Một thế lực bí ẩn đẩy bạn trả về!");
		me.NewWorld(me.nMapId, self.nPosX / 32, self.nPosY / 32);
	else
		return 0;
	end
end

TreasureMap2:LoadLongmenfeijianTrap();
TreasureMap2:InitLongmenfeijianTrap(2145);