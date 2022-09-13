-- 文件名　：snowman_gs.lua
-- 创建者　：zounan
-- 创建时间：2009-11-24 14:39:50
-- 描  述  ：

if not MODULE_GAMESERVER then
	return;
end

Require("\\script\\event\\jieri\\200812_xmas\\snowman\\snowman_def.lua");
local XmasSnowman = SpecialEvent.Xmas2008.XmasSnowman;

function XmasSnowman:CallSnowEx()	
	self:ClearSnowEx();
	self.nState = 1;
	-- 时间检查
	local nDate = tonumber(GetLocalDate("%Y%m%d"));	
	local nTmp = math.floor(nDate /10000);
	if nTmp == 2010 then        -- 12月31号 和1月1号不能在同一个城市刷
		nDate = nDate + 1;
	end
--	local nTime = tonumber(GetLocalDate("%H%M"));	
	for nIndex, tbPos in ipairs(self.SNOWMAN_POS) do
		if 	IsMapLoaded(tbPos.nMapId) == 1 and (tbPos.bOpen == nDate % 2) then
			local pNpc = KNpc.Add2(self.SNOWMAN_LEVEL[1].nClassId, 100, -1, tbPos.nMapId, tbPos.nX, tbPos.nY);
			if pNpc then
				self.tbSnowmanMgr[nIndex] =  pNpc.dwId;
				pNpc.GetTempTable("Npc").tbData = {nIndex = nIndex, nLevel = 1, nCount = 0,};
				local tbSnowball = self.SNOWBALL_POS[nIndex];
				for nPos ,tbPos2 in ipairs(tbSnowball) do
					local pNpc2 = KNpc.Add2(self.SNOWBALL_ID, 50, -1, tbPos.nMapId, tbPos2.nX, tbPos2.nY);
					if pNpc2 then
						self.tbSnowballMgr[nIndex] = self.tbSnowballMgr[nIndex] or {};
						self.tbSnowballMgr[nIndex][pNpc2.dwId] = nPos;
						pNpc2.GetTempTable("Npc").nIndex = nIndex;
					end
				end
			end
		end
	end	
end 

function XmasSnowman:ClearSnowEx()
	self.nState = 4;
	for _, nNpcId in pairs(self.tbSnowmanMgr) do
		local pNpc = KNpc.GetById(nNpcId);
		if pNpc then
			pNpc.Delete();
		end
	end	
	self.tbSnowmanMgr  = {};
	
	for _, tbNpc in pairs(self.tbSnowballMgr) do 
		for nNpcId  in pairs(tbNpc) do
			local pNpc = KNpc.GetById(nNpcId);	
			if pNpc then
				pNpc.Delete();
			end
		end
	end		
	self.tbSnowballMgr = {};
end

function XmasSnowman:ClearSnowball()
	for _, tbNpc in pairs(self.tbSnowballMgr) do 
		for nNpcId  in pairs(tbNpc) do
			local pNpc = KNpc.GetById(nNpcId);	
			if pNpc then
				pNpc.Delete();
			end
		end
	end		
	self.tbSnowballMgr = {};
end

function XmasSnowman:CallAwardEx()
	self.nState = 2;
	
	for nIndex, nNpcId in pairs(self.tbSnowmanMgr) do
		local pNpc = KNpc.GetById(nNpcId);
		if pNpc then
			if pNpc.GetTempTable("Npc").tbData then
				local nLevel = pNpc.GetTempTable("Npc").tbData.nLevel;
			end
		end
	end

	self.nChestCount  = 0;
	self.nYanhuaCount = 0;
	self:RefreshChest();
	Timer:Register(Env.GAME_FPS * 60 * self.CHEST_INTERVAL, self.RefreshChest, self);
end

function XmasSnowman:CallMaxSnowManEx()
	self:ClearSnowEx();
	self.nState = 5;
	for nIndex, tbPos in ipairs(self.SNOWMAN_POS) do
		if 	IsMapLoaded(tbPos.nMapId) == 1  then
			local pNpc = KNpc.Add2(self.SNOWMAN_LEVEL[#self.SNOWMAN_LEVEL].nClassId, 100, -1, tbPos.nMapId, tbPos.nX, tbPos.nY);
			if pNpc then
				self.tbSnowmanMgr[nIndex] =  pNpc.dwId;
			end
		end
	end		
end 

function XmasSnowman:RefreshChest()
	for nIndex, tbChest in pairs(self.tbChestMgr) do
		for _, nNpcId in pairs(tbChest) do
			local pNpc = KNpc.GetById(nNpcId);
			if pNpc then
				pNpc.Delete();
			end
		end
	end
	self.tbChestMgr = {};
	
	if self.nChestCount >= self.CHEST_COUNT then
		self.nChestCount = 0;
		self.nState = 3;
		return 0;
	end
	self.nChestCount = self.nChestCount + 1;
	local bChest = 0;
	for nIndex, nNpcId in pairs(self.tbSnowmanMgr) do
		local pNpc = KNpc.GetById(nNpcId);
		if pNpc then
			if pNpc.GetTempTable("Npc").tbData then	
				local nLevel = pNpc.GetTempTable("Npc").tbData.nLevel;
				if nLevel > 2 then
					bChest = 1;
					local tbChestPos =  self.CHEST_POS[nIndex];
					Lib:SmashTable(tbChestPos);
					local pNpc2 = nil;
					for i = 1, self.CHEST_NUMBER[nLevel - 2] do 
						pNpc2 = KNpc.Add2(self.CHEST_ID, 80, -1, pNpc.nMapId, tbChestPos[i].nX, tbChestPos[i].nY);
						if pNpc2 then
							pNpc2.SetLiveTime(self.CHEST_LIVETIME * 60 *  Env.GAME_FPS);
							self.tbChestMgr[nIndex] = self.tbChestMgr[nIndex] or {};
							table.insert(self.tbChestMgr[nIndex], pNpc2.dwId);
						end
					end
					
					pNpc2 = KNpc.Add2(self.EXP_NPC, 60, -1, pNpc.nMapId, self.SNOWSEED_POS[nIndex].nX, self.SNOWSEED_POS[nIndex].nY);
					if pNpc2 then
						--初始化数据：类型，持续时间，每次加经验时间，范围， 经验倍数 秒	
						Npc:GetClass("gouhuonpc"):InitGouHuo(pNpc2.dwId, 0,	self.EXP_TIME, self.EXP_INTERVAL, self.EXP_ROUND, self.EXP_RATE, 1, 0);
						Npc:GetClass("gouhuonpc"):StartNpcTimer(pNpc2.dwId);
					end			
				end
			end
		end
	end
	if bChest == 1 then
		Dialog:GlobalNewsMsg_GS("城市里的雪人周围出现了好多雪人果果，大家快去采啊！");
		self.nYanhuaCount = 0;
		local nRandom = MathRandom(1, #self.YANHUA_SKILLID);
		self:Yanhua(nRandom);
		Timer:Register(Env.GAME_FPS * self.YANHUA_INTERVAL, self.Yanhua, self, nRandom);
	end
end	

function XmasSnowman:Yanhua(nRandom)
	if self.nState >= 3 then
		return 0;
	end
	
	for nIndex, nNpcId in pairs(self.tbSnowmanMgr) do
		local pNpc = KNpc.GetById(nNpcId);
		if pNpc then
			if pNpc.GetTempTable("Npc").tbData then	
				local nLevel = pNpc.GetTempTable("Npc").tbData.nLevel;
				if nLevel > 2 then
					local nIndex = pNpc.GetTempTable("Npc").tbData.nIndex;		
					local tbSnowball = self.SNOWBALL_POS[nIndex];
					for _ ,tbPos in ipairs(tbSnowball) do
						pNpc.CastSkill(self.YANHUA_SKILLID[nRandom], 1, tbPos.nX * 32, tbPos.nY * 32);
					end
				end
			end
		end
	end
	
	self.nYanhuaCount = self.nYanhuaCount + 1;
	if self.nYanhuaCount >= self.YANHUA_COUNT  then
		self.nYanhuaCount = 0;
		return 0;
	end	
end

function XmasSnowman:CloseChestandYanhua()
	for nIndex, tbChest in pairs(self.tbChestMgr) do
		for _, nNpcId in pairs(tbChest) do
			local pNpc = KNpc.GetById(nNpcId);
			if pNpc then
				pNpc.Delete();
			end
		end
	end
	self.tbChestMgr = {};	
	self.nChestCount = self.CHEST_COUNT;
	self.nYanhuaCount = self.YANHUA_COUNT;
end


function XmasSnowman:StartSnow()
	local nDate = tonumber(GetLocalDate("%Y%m%d"));	
	if nDate < self.EVENT_START or nDate > self.MAXMAN_END then
		return;
	end
	if nDate == self.MAXMAN_END  then
		self:ClearSnowEx();
		return;
	end
	if nDate > self.EVENT_END then
		self:CallMaxSnowManEx();
	else		
		self:CallSnowEx();	
	end
end

function XmasSnowman:StartAward()
	local nDate = tonumber(GetLocalDate("%Y%m%d"));	
	if nDate < self.EVENT_START or nDate > self.EVENT_END then
		return;
	end
	self:CallAwardEx();
end

ServerEvent:RegisterServerStartFunc(XmasSnowman.StartSnow, XmasSnowman);


-------------test------------

function XmasSnowman:__debug_snowman()
	me.Msg("__output__雪人信息__BEGIN__");
	me.Msg("地图(id)".."   等级".."   堆积次数");
	for nIndex , nNpcId in pairs(self.tbSnowmanMgr) do
		local pNpc = KNpc.GetById(nNpcId);
		if pNpc then
			if pNpc.GetTempTable("Npc").tbData then
				local tbData = pNpc.GetTempTable("Npc").tbData;
				local szName = GetMapNameFormId(pNpc.nMapId);
				me.Msg(szName.."("..pNpc.nMapId..")".."   "..tbData.nLevel.."   "..tbData.nCount);
			end
		end 	
	end
	me.Msg("__output__雪人信息__END__");
end 
	
-- ?pl SpecialEvent.Xmas2008.XmasSnowman:__debug_snowman()