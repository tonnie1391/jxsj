-- 文件名  : fightafter_public.lua
-- 创建者  : zounan
-- 创建时间: 2010-07-23 11:33:57
-- 描述    : 战后系统 GS GC公用



--增加一份活动到InstanceList中
function FightAfter:AddInstance(tbInstance)	
	if self.tbInstanceBuffer[tbInstance.szInstanceId] then
		print("[ERR]FightAfter:AddInstance: the Instance already exist",tbInstance.szInstanceId);
	end
	self:AddInstance2Player(tbInstance);	
	self.tbInstanceBuffer[tbInstance.szInstanceId] = tbInstance;	
end

function FightAfter:AddInstance2Player(tbInstance)
	for szPlayerName in pairs(tbInstance.tbNoAwardPlayer) do
		self.tbPlayerInstanceList[szPlayerName] =  self.tbPlayerInstanceList[szPlayerName] or {};
		self.tbPlayerInstanceList[szPlayerName][tbInstance.szInstanceId] = 1;
	end
end

--删除活动
function FightAfter:DelInstance(szInstanceId)
	local tbInstance = self.tbInstanceBuffer[szInstanceId];
	if not tbInstance then
		print("[ERR]FightAfter:DelInstance: the Instance not exist", szInstanceId);
		return;
	end
	
	for szPlayerName in pairs(tbInstance.tbNoAwardPlayer) do
		self.tbPlayerInstanceList[szPlayerName] =  self.tbPlayerInstanceList[szPlayerName] or {};
		self.tbPlayerInstanceList[szPlayerName][szInstanceId] = nil;
	end
	
	self.tbInstanceBuffer[szInstanceId] = nil;
end


--玩家领奖了 要清除
function FightAfter:DelPlayerAward(szPlayerName,szInstanceId)
	if self.tbPlayerInstanceList[szPlayerName] then
		self.tbPlayerInstanceList[szPlayerName][szInstanceId] = nil;
	end	

	local tbInstance = self.tbInstanceBuffer[szInstanceId];
	if not tbInstance then
		--print("[ERR]FightAfter:DelPlayerAward: the Instance not exist",szInstanceId);
		return;
	end
	
	if tbInstance.tbNoAwardPlayer[szPlayerName] then --会出现没有的情况吗？
		tbInstance.nNoAwardCount = tbInstance.nNoAwardCount - 1;
		tbInstance.tbNoAwardPlayer[szPlayerName] = nil;
		if tbInstance.nNoAwardCount < 0 then
			self:DelInstance(szInstanceId);
		end
	end
end


--检查这个活动是否有效
function FightAfter:CheckInstanceExpiry_base(szInstanceId)
	local tbInstance = self.tbInstanceBuffer[szInstanceId];
	if not tbInstance then
		return 0;
	end
	
	local nExpiry = GetTime() - tbInstance.nEndTime;
	if nExpiry >= self.EXPIRY_DATE then
		return 0;			
	end
	
	if tbInstance.nNoAwardCount <= 0 then
		return 0;
	end	
		
	return 1;
end
