Require("\\script\\task\\treasuremap\\treasuremap.lua");
Require("\\script\\task\\treasuremap2\\treasuremap.lua");

local tbInstancing = TreasureMap2:GetInstancingBase(6);
tbInstancing.szName = "Long Môn Phi Kiếm";


tbInstancing.nTrapNpcTemplateId = 9548;	--障碍npc

tbInstancing.tbHorseGDPL = 
{
	{{1,12,52,2}, 10,14 * 24 * 60 * 60},	--黑色，只在1星产出
	{{1,12,51,4}, 2, 30 * 24 * 60 * 60},	--白色，2星产出
	{{1,12,51,4}, 2, 30 * 24 * 60 * 60},	--白色，3星产出
}

tbInstancing.tbTrapNpcPos = 
{
	{
		{50592/32,104032/32},
		{50624/32,104000/32},
		{50656/32,103968/32},
	}, 
	{  
		{48992/32,102144/32},
		{49024/32,102112/32},
		{49056/32,102080/32},
	}, 
	{  
		{47296/32,99776 /32},
		{47360/32,99712 /32},
		{47424/32,99648 /32},
	},  
	{  
		{46144/32,97984 /32},
		{46208/32,97920 /32},
		{46272/32,97856 /32},
		{46336/32,97792 /32},
	}, 
	{   
		{48032/32,91520 /32},
		{48064/32,91552 /32},
		{48096/32,91584 /32},
	},  
	{  
		{50016/32,92032 /32},
		{49984/32,92064 /32},
	},
};

tbInstancing.tbHoleSkillInfo = 
{
	[9788] = {2433,1,3},	--技能id，等级，时间延迟
	[9789] = {2434,8,1},
	[9790] = {2430,6,5},
	[9791] = {2432,6,4},
};

tbInstancing.tbEnemyHole = {
	{9788,0,
		{47264/32,101152/32},
		{47136/32,101696/32},
		{47840/32,99776 /32},
		{48480/32,100384/32},
		{48288/32,101856/32},
	}, 
	{9789,0,
		{47680/32,100736/32},
		{48384/32,101152/32},
    },  
	{9790,0, 
		{47680/32,100160/32},
		{48032/32,100576/32},
		{48224/32,99872 /32},
		{48480/32,101536/32},
		{47392/32,101152/32},
	}, 
	{9791,0,
		{47296/32,100352/32},
		{47968/32,101600/32},
		{48352/32,99616 /32},
		{48128/32,101056/32},
	},
};	--陷阱等机关


-- 第一次打开副本时调用，这个时候里面肯定没有别的队伍
function tbInstancing:OnNew()
	self:InitLogicRoom();
end

function tbInstancing:AfterJoin()
	Dialog:SendBlackBoardMsg(me,"Những kẻ đánh cắp Minh ước đã chia nhau ra, ta phải tìm hiểu thực hư");
end


function tbInstancing:InitLogicRoom()
	self.tbRoom = Lib:NewClass(self.tbLogicRoom);
	self.tbRoom:InitRoom(self);	
	self.tbRoom:StartRoom();
	--self:AddTrapNpc();
	self:AddHole();
	self.tbOpenBoxPlayer = {};	--记录开过箱子的情况
end


function tbInstancing:AddOpenBoxPlayer(nPlayerId)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		return 0;
	end
	if not self.tbOpenBoxPlayer then
		self.tbOpenBoxPlayer = {};
	end
	if not self.tbOpenBoxPlayer[nPlayerId] then
		self.tbOpenBoxPlayer[nPlayerId] = 0;
	end
	if self.tbOpenBoxPlayer[nPlayerId] >= self.tbRoom.nOpenBoxMaxCount then
		return 0;
	end
	self.tbOpenBoxPlayer[nPlayerId] = self.tbOpenBoxPlayer[nPlayerId] + 1;
end

function tbInstancing:AddTrapNpc()
	if not self.tbTrapNpc then
		self.tbTrapNpc = {};
	end
	for i = 1,#self.tbTrapNpcPos do
		if not self.tbTrapNpc[i] then
			self.tbTrapNpc[i] = {};
		end
		local tbInfo = self.tbTrapNpcPos[i];
		for _,tbPos in pairs(tbInfo) do
			local pNpc = KNpc.Add2(self.nTrapNpcTemplateId,10,-1,self.nMapId,tbPos[1],tbPos[2]);
			if pNpc then
				table.insert(self.tbTrapNpc[i],pNpc.dwId);
			end
		end
	end
end

function tbInstancing:DelTrapNpc(nIndex)
	if not self.tbTrapNpc or not self.tbTrapNpc[nIndex] then
		return 0;
	end
	for _,nId in pairs(self.tbTrapNpc[nIndex]) do
		local pNpc = KNpc.GetById(nId);
		if pNpc then
			pNpc.Delete();
		end
	end
end


function tbInstancing:AddHole()
	if not self.tbHoleNpc then
		self.tbHoleNpc = {};
	end
	for _,tbInfo in pairs(self.tbEnemyHole) do
		local nTemplateId = tbInfo[1];
		if nTemplateId then
			if not self.tbHoleNpc[nTemplateId] then
				self.tbHoleNpc[nTemplateId] = {};
			end
			for _,tbPos in pairs(tbInfo) do
				if type(tbPos) == "table" then
					local pNpc = KNpc.Add2(nTemplateId,100,-1,self.nMapId,tbPos[1],tbPos[2]);
					if pNpc then
						pNpc.szName = "";
						pNpc.Sync();
						table.insert(self.tbHoleNpc[nTemplateId],pNpc.dwId);
					end
				end
			end
		end
	end
	for nTemplateId,tbHole in pairs(self.tbHoleNpc) do
		local tbInfo = self.tbHoleSkillInfo[nTemplateId];
		if tbInfo then
			local nSkillId = tbInfo[1];
			local nLevel = tbInfo[2];
			local nDelayTime = tbInfo[3];
			if nDelayTime <= 0 then
				for _,nId in pairs(tbHole) do
					local pNpc = KNpc.GetById(nId);
					if pNpc then
						local _,nX,nY = pNpc.GetWorldPos();
						pNpc.CastSkill(nSkillId,nLevel,nX * 32,nY *32, 1);
					end
				end
			else
				self:CreateTimer(Env.GAME_FPS * nDelayTime, self.OnHoleCastSkill,self,nDelayTime,nTemplateId,nSkillId,nLevel);
			end
		end
	end
end


function tbInstancing:OnHoleCastSkill(nDelayTime,nTemplateId,nSkillId,nLevel)
	local tbNpc = self.tbHoleNpc[nTemplateId];
	if tbNpc then
		for _,nId in pairs(tbNpc) do
			local pNpc = KNpc.GetById(nId);
			if pNpc then
				local _,nX,nY = pNpc.GetWorldPos();
				pNpc.CastSkill(nSkillId,nLevel,nX * 32,nY * 32,1);
			end
		end
	end
	return nDelayTime * Env.GAME_FPS;
end


function tbInstancing:OnClose()
	for _,tbHole in pairs(self.tbHoleNpc) do
		for _,nId in pairs(tbHole) do
			local pNpc = KNpc.GetById(nId);
			if pNpc then
				pNpc.Delete();
			end
		end
	end
	self.tbHoleNpc = {};
	self.tbOpenBoxPlayer = {};
	self.tbTrapNpc = {};
	self.tbRoom:ClearRoom();
	self.tbRoom = nil;
end

function tbInstancing:DoLeave()
	if me.GetSkillState(2410) > 0 then	--如果掉线，清楚玩家身上buff
		me.RemoveSkillState(2410);
	end
	if me.GetSkillState(2407) > 0 then	--如果掉线，清楚玩家身上buff
		me.RemoveSkillState(2407);
	end
end

function tbInstancing:GetTrapOpenState(nTrapId)
	if not self.tbRoom then
		return 0;
	end
	return self.tbRoom.tbTrapOpenState[nTrapId] or 0;
end

function tbInstancing:GiveHorse(pNpc)
	if not pNpc then
		return 0;
	end
	local tbPlayer = KNpc.GetAroundPlayerList(pNpc.dwId,60);
	if not tbPlayer then
		return 0;
	end
	local pPlayer = tbPlayer[MathRandom(#tbPlayer)];
	if not pPlayer or IpStatistics:IsStudioRole(pPlayer) then
		return 0;
	end
	local nLevel = self.nTreasureLevel;
	if nLevel <= 1 then
		local tbInfo = self.tbHorseGDPL[nLevel];	
		if not tbInfo then
			return 0;
		end
		local tbGDPL = tbInfo[1];
		local nRate = tbInfo[2];
		local nTime = tbInfo[3];
		local nRand = MathRandom(100);
		if nRand <= nRate then
			local pItem = pPlayer.AddItem(unpack(tbGDPL));
			if not pItem then
				Dbg:WriteLog("treasuremap2", "Give Black Horse Faild!", pPlayer.szName);
			else
				pItem.SetTimeOut(0,GetTime() + nTime);
				pItem.Sync();
			end
		end
	else
		local nGenDate = KGblTask.SCGetDbTaskInt(DBTASK_TREASUREMAP_OUT_HORSE);
		local nNowDate = GetTime();
		if tonumber(os.date("%Y%m%d",nGenDate)) == tonumber(os.date("%Y%m%d",nNowDate)) then	--如果当天产出了，就不再产出
			return 0;
		end
		local tbInfo = self.tbHorseGDPL[nLevel];	
		if not tbInfo then
			return 0;
		end
		local tbGDPL = tbInfo[1];
		local nRate = tbInfo[2];
		local nTime = tbInfo[3];
		local nRand = MathRandom(100);
		if nRand <= nRate then
			local pItem = pPlayer.AddItem(unpack(tbGDPL));
			if not pItem then
				Dbg:WriteLog("treasuremap2", "Give White Horse Faild!", pPlayer.szName);
			else
				local szMsg = string.format("Chúc mừng <color=green>%s<color> tại <color=red>[Long Môn Phi Kiếm]<color> nhận được <color=purple>[%s]<color>",pPlayer.szName, pItem.szName);
				KDialog.NewsMsg(1, Env.NEWSMSG_NORMAL,szMsg);
				KDialog.MsgToGlobal(szMsg);
				pItem.SetTimeOut(0,GetTime() + nTime);
				pItem.Sync();
				GCExcute{"TreasureMap2:SetHorseGenDate"};
			end
		end
	end
end
