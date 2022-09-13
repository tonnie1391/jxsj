-- 杂项数值设定

-- 根据玩家级别，计算经验值
-- 此函数在GameServer启动时自动调用，用于建立挂机经验数值表
function Setting:GetHangExpValue(nLevel)	
	local nExp = 0;
	-- 一小时挂机经验：e={3.5w+math.floor[(lv-50)/5]*0.5w}*1.2
	if (nLevel == 50) then 	-- 50
		nExp = 700; -- 每分钟获得的经验值
	elseif (nLevel < 100) then 	-- 51~99
		nExp = 700 + math.floor((nLevel - 50)/5)*100; -- 每分钟获得的经验值
	else -- 100级及100级以上
		nExp = 1700; -- 每分钟获得的经验值[700 + math.floor((100 - 50)/5)*100]
	end
	
	return nExp * 10;	-- 10分钟获得的经验值
end;

Setting.nCheckStackOpen = 2;
Setting.nMaxStack  = 10;
Setting.nStackTime = 30*60;	--报堆栈间隔（秒）
Setting.nSaveTime  = 0;		--存储报警堆栈时间。
Setting.tbGolbalObjStack = {};
Setting.nMaxObj	= 5000;		--最多允许存储的Obj堆栈。超过自动清理一半。

--注意！！！！：该函数禁止在线重载，重载会导致玩家对象错乱。目前未找到重载为何会错乱，但是每次重载都会出现问题。
function Setting:SetGlobalObj(pPlayer, pNpc, pItem)
	self:ClearGlobalObj();
	local szTrackback = "";
	if #self.tbGolbalObjStack > 5 and #self.tbGolbalObjStack <= 10 then
		szTrackback=debug.traceback(); 	--只记录从第5个开始溢出的堆栈，避免效率问题。
	end
	self.tbGolbalObjStack[#self.tbGolbalObjStack + 1] = {pPlayer = me, pNpc = him, pItem = it, szTrackback=szTrackback};
	if (#self.tbGolbalObjStack >= self.nMaxStack and self.nCheckStackOpen > 0) then
		if (self.nCheckStackOpen == 2 and ((GetTime() - self.nSaveTime) > self.nStackTime) ) then
			print("[Warring] GlobalObjStack too much: "..#self.tbGolbalObjStack, "\nNo.1 GlobalObjStack:",self.tbGolbalObjStack[1].szTrackback);
			self.nSaveTime = GetTime();
		end
	end

	me = pPlayer or me;

	him = pNpc or him;

	it = pItem or it;
end

function Setting:RestoreGlobalObj()
	local tb = self.tbGolbalObjStack[#self.tbGolbalObjStack];
	if (not tb) then
		assert(false);
	end	
	me = tb.pPlayer or me;
	him = tb.pNpc or him;
	it = tb.pItem or it;
	self.tbGolbalObjStack[#self.tbGolbalObjStack] = nil;
end

--清除一半垃圾堆栈
function Setting:ClearGlobalObj()
	if #self.tbGolbalObjStack > self.nMaxObj then
		for i=1, math.floor(#self.tbGolbalObjStack/2) do
			table.remove(self.tbGolbalObjStack, 1);
		end
	end
end
