
Require("\\script\\kin\\kingame\\kingame_def.lua")

--怪物模版
KinGame.DifNpcTemplet = {};
--KinGame.DifNpcTemplet =
--{--模版等级
--	[1] = 
--	{	--房间号 = 怪物Id
--		[1] = npcId
--	}
--}

--怪物trap点
KinGame.DifTrap = {};
--KinGame.DifTrap =
--{
----房间号={怪物pos}
--	[1] = {{x,y},{x,y}}
--}

--固定点trap点
KinGame.FixTrap = {};
--KinGame.FixTrap = 
--{
----房间号
--	[1]=
--	{
--	--index={nNpcId=怪物Id，tbPos=pos点}
--		[1] = {nNpcId = npcid, tbPos = {{x,y},{x,y}}},
--	}
--}

--障碍npc
KinGame.ObstacleTrap = {};
--KinGame.ObstacleTrap = 
--{
----房间号
--	[1]=
--	{
--		{nNpcId=npcid,nPosX=x,nPosY=y},
--	}
--}

KinGame.CopyNpcTemplet = {};	--复制npc房间模版id

KinGame.WalkTrap = {}; --Trap返回点
--{
--	[roomid] = {[szTrapName]={x,y},}
--}

KinGame.MultipTemplet = {}; 	--人数对应 奖励加成，模版等级
--{
--	[nPlayerCount]{nAwardMtltip = nAwardMtltip, nTempletLevel = nTempletLevel};
--}

KinGame.LoadLevelBaseExp = {}; 	--等级基准经验

KinGame.MAXROOM = 30; --房间总数
KinGame.BASEPATH = "\\setting\\Kin\\kingame";

function KinGame:LoadDifNpcTemplet()
	self.DifNpcTemplet = {};
	for nRoomId = 1, self.MAXROOM do 
		local szRoom = string.format("%s\\room%0.2d\\difnpctemplet.txt",self.BASEPATH, nRoomId);
		local tbFile = Lib:LoadTabFile(szRoom);
		if tbFile ~= nil then
			for _, tbItem in pairs(tbFile) do
				local nLevel = tonumber(tbItem.TempletLevel);
				local nNpcId = tonumber(tbItem.NpcId);
				if self.DifNpcTemplet[nLevel] == nil then
					self.DifNpcTemplet[nLevel] = {}
				end
				self.DifNpcTemplet[nLevel][nRoomId] = nNpcId;
			end
		end
	end
end
KinGame:LoadDifNpcTemplet();

function KinGame:LoadDifTrap()
	self.DifTrap = {};
	for nRoomId = 1, self.MAXROOM do 
		local szRoom = string.format("%s\\room%0.2d\\diftrap.txt",self.BASEPATH, nRoomId);
		local tbFile = Lib:LoadTabFile(szRoom);
		if tbFile ~= nil then
			for _, tbItem in pairs(tbFile) do
				local nPosX = math.floor(tonumber(tbItem.TRPOSX) / 32);
				local nPosY = math.floor(tonumber(tbItem.TRPOSY) / 32);
				if self.DifTrap[nRoomId] == nil then
					self.DifTrap[nRoomId] = {}
				end
				table.insert(self.DifTrap[nRoomId], {nPosX, nPosY});
			end
		end
	end
end
KinGame:LoadDifTrap();

function KinGame:LoadFixTrap()
	self.FixTrap = {};
	for nRoomId = 1, self.MAXROOM do 
		local szRoom = string.format("%s\\room%0.2d\\fixindex.txt",self.BASEPATH, nRoomId);
		local tbFile = Lib:LoadTabFile(szRoom);
		if tbFile ~= nil then
			for _, tbItem in pairs(tbFile) do
				local nIndex = tonumber(tbItem.Index);
				local nNpcId = tonumber(tbItem.NpcId);
				local nPosX = math.floor(tonumber(tbItem.TRPOSX) / 32);
				local nPosY = math.floor(tonumber(tbItem.TRPOSY) / 32);
				if self.FixTrap[nRoomId] == nil then
					self.FixTrap[nRoomId] = {}
				end
				if self.FixTrap[nRoomId][nIndex] == nil then
					self.FixTrap[nRoomId][nIndex] = {};
				end
				self.FixTrap[nRoomId][nIndex].nNpcId = nNpcId;
				if self.FixTrap[nRoomId][nIndex].tbPos == nil then
					self.FixTrap[nRoomId][nIndex].tbPos = {};
				end
				table.insert(self.FixTrap[nRoomId][nIndex].tbPos, {nPosX, nPosY});
			end
		end
	end	
end
KinGame:LoadFixTrap();

function KinGame:LoadObstacleTrap()
	self.ObstacleTrap = {};
	for nRoomId = 1, self.MAXROOM do 
		local szRoom = string.format("%s\\room%0.2d\\obstacletrap.txt",self.BASEPATH, nRoomId);
		local tbFile = Lib:LoadTabFile(szRoom);
		if tbFile ~= nil then
			for _, tbItem in pairs(tbFile) do
				local nNpcId = tonumber(tbItem.NpcId);
				local nPosX = math.floor(tonumber(tbItem.TRPOSX) / 32);
				local nPosY = math.floor(tonumber(tbItem.TRPOSY) / 32);
				if self.ObstacleTrap[nRoomId] == nil then
					self.ObstacleTrap[nRoomId] = {};
				end
				table.insert(self.ObstacleTrap[nRoomId], {nNpcId=nNpcId, nPosX=nPosX, nPosY=nPosY});
			end
		end
	end
end
 KinGame:LoadObstacleTrap();

function KinGame:LoadCopyNpcTemplet()
	self.CopyNpcTemplet = {};
	local szRoom = string.format("%s\\copynpctemplet.txt",self.BASEPATH);
	local tbFile = Lib:LoadTabFile(szRoom);
	if tbFile ~= nil then
		for _, tbItem in pairs(tbFile) do
			local nFaction  = tonumber(tbItem.Faction);
			local nRouteId  = tonumber(tbItem.RouteId);
			local nMaleId 	= tonumber(tbItem.MaleId );
			local nFemaleId = tonumber(tbItem.FemaleId );
			local nManIndex 	 = nFaction*10 + nRouteId*2 + Env.SEX_MALE;
			local nFemaleIndex = nFaction*10 + nRouteId*2 + Env.SEX_FEMALE;
			self.CopyNpcTemplet[nManIndex] 		= nMaleId;
			self.CopyNpcTemplet[nFemaleIndex] = nFemaleId;
		end
	end
end
KinGame:LoadCopyNpcTemplet();

function KinGame:LoadWalkTrap()
	self.WalkTrap = {};
	local szRoom = string.format("%s\\walktrap.txt",self.BASEPATH);
	local tbFile = Lib:LoadTabFile(szRoom);
	if tbFile ~= nil then
		for _, tbItem in pairs(tbFile) do
			local nRoomId  		= tonumber(tbItem.RoomId);
			local szTrapName  = tbItem.TrapName;
			local nPosX 			= tonumber(tbItem.TRPOSX);
			local nPosY 			= tonumber(tbItem.TRPOSY);
			if self.WalkTrap[nRoomId] == nil then
				self.WalkTrap[nRoomId]	= {};
			end
			self.WalkTrap[nRoomId][szTrapName] = {nPosX,nPosY};
		end
	end	
end
KinGame:LoadWalkTrap();

function KinGame:LoadMultipTemplet()
	self.MultipTemplet = {};
	local szRoom = string.format("%s\\multiptemplet.txt",self.BASEPATH);
	local tbFile = Lib:LoadTabFile(szRoom);
	if tbFile ~= nil then
		for _, tbItem in pairs(tbFile) do
			local nPlayerCount  		= tonumber(tbItem.PlayerCount);
			local nAwardMultip 			= tonumber(tbItem.AwardMultip );
			local nTempletLevel 			= tonumber(tbItem.TempleLevel );
			if self.MultipTemplet[nPlayerCount] == nil then
				self.MultipTemplet[nPlayerCount]	= {};
			end
			self.MultipTemplet[nPlayerCount] = {nAwardMultip = nAwardMultip, nTempletLevel = nTempletLevel};
		end
	end	
end

KinGame:LoadMultipTemplet();

function KinGame:LoadLevelBaseExp()	--加载基准经验表
	local szPath	= "\\setting\\player\\attrib_level.txt";
	local tbFile	= Lib:LoadTabFile(szPath);
	if tbFile == nil then
		return 0;
	end
	self.LevelBaseExp = {};
	for i = 1, #tbFile do
		local nLevel		= tonumber(tbFile[i].LEVEL);
		local nBaseExp	= tonumber(tbFile[i].BASE_AWARD_EXP);
		if nLevel ~= nil then
			self.LevelBaseExp[nLevel] = nBaseExp;
		end
	end
end

KinGame:LoadLevelBaseExp();
