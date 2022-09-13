-- 文件名　：201112_xmas_gamebase.lua
-- 创建者　：zhangjunjie
-- 创建时间：2011-12-22 19:59:53
-- 描述：圣诞关卡房间逻辑

Require("\\script\\event\\jieri\\201112_xmas\\201112_xmas_def.lua");

SpecialEvent.Xmas2011 =  SpecialEvent.Xmas2011 or {};

local Xmas2011 = SpecialEvent.Xmas2011;

Xmas2011.RoomXmas = {};

local RoomXmas = Xmas2011.RoomXmas;

RoomXmas.nEndGameTimeDelay = 15;	--游戏结束后关闭的

RoomXmas.nGameTime = 20 * 60;	--游戏时长

RoomXmas.tbBossStep1 = 
{   
	{
		9832,
		{51232/32,103168/32},
	},
};

RoomXmas.tbEnemyStep1 = 
{   
	{
		9834,
		{50624/32,103104/32},
		{50880/32,102880/32},
		{51104/32,102496/32},
		{50752/32,103520/32},
		{50944/32,103872/32},
		{51584/32,102688/32},
		{51360/32,102592/32},
		{51296/32,103744/32},
		{51552/32,103712/32},
		{51776/32,102944/32},
	},
}; 

RoomXmas.tbBossStep2 = 
{   
	{
		9833,
		{51232/32,103168/32},
	},
};

RoomXmas.tbEnemyStep2 = 
{   
	{
		9834,
		{50624/32,103104/32},
		{50880/32,102880/32},
		{51104/32,102496/32},
		{50752/32,103520/32},
		{50944/32,103872/32},
		{51584/32,102688/32},
		{51360/32,102592/32},
		{51296/32,103744/32},
		{51552/32,103712/32},
		{51776/32,102944/32},
	},
	{
		9835,
		{50656/32,103392/32},
		{50752/32,102912/32},
		{51040/32,102656/32},
		{50912/32,103744/32},
		{51168/32,103776/32},
		{51520/32,102624/32},
		{51264/32,102496/32},
		{51520/32,103872/32},
		{51648/32,103520/32},
		{51776/32,102784/32},
	}
};

RoomXmas.tbBossStep2PercentFunc = 
{
	[90] = {"AddEnemyStep2Percent",1,10};
	[80] = {"AddEnemyStep2Percent",1,10};
	[70] = {"AddEnemyStep2Percent",2,10};
	[60] = {"AddEnemyStep2Percent",2,10};
	[50] = {"AddEnemyStep2Percent",1,10};
	[40] = {"AddEnemyStep2Percent",2,10};
	[30] = {"AddEnemyStep2Percent",1,10};
	[20] = {"AddEnemyStep2Percent",2,10};
	[15] = {"AddEnemyStep2Percent",-1,8};
	[10] = {"AddEnemyStep2Percent",-1,8};
	[10] = {"AddEnemyStep2Percent",-1,8};
};

function RoomXmas:GetNpcLevel()
	local nOpenDay = TimeFrame:GetServerOpenDay();
	if nOpenDay <= 30 then
		return 2 * nOpenDay + 1;
	elseif nOpenDay > 30 and nOpenDay <= 150 then
		return math.ceil(nOpenDay / 4 + 52.5);
	elseif nOpenDay > 150 and nOpenDay <= 270 then
		return math.ceil(nOpenDay / 12 + 77.5);
	elseif nOpenDay > 270 and nOpenDay <= 360 then
		return math.ceil(nOpenDay / 9 + 70);
	else
		return 110;
	end
end


function RoomXmas:StartRoom(tbBase)
	self.tbBase = tbBase;
	self.tbBase:CreateTimer(Env.GAME_FPS * self.nGameTime,self.OnLoseGame,self);
	self.tbBase:CreateTimer(Env.GAME_FPS,self.OnWaringTime,self);
	self.nIsEnd = 0;
	self.nEnemyStep1Count = 0;
	self.nCurSec = 1;
	self:StartGame();
end

function RoomXmas:OnWaringTime()
	if self.nIsEnd == 1 then
		return 0;
	end
	if (not self.nCurSec) then
		self.nCurSec = 1;
	else
		self.nCurSec = self.nCurSec + 1;
	end
	if (self.nCurSec % 120 == 0) then
		self.tbBase:BlackMsg(-1,"Thời gian đóng sự kiện còn lại "..math.floor((self.nGameTime - self.nCurSec)/60).." phút.");
		self.tbBase:SendPlayerMsg(-1,"Thời gian đóng sự kiện còn lại "..math.floor((self.nGameTime - self.nCurSec)/60).." phút.");
	end
end

--游戏通关
function RoomXmas:EndGameOnBossDeath()
	ClearMapNpc(self.tbBase.nMapId);
	self.nIsEnd = 1;
	self.tbBase:CreateTimer(Env.GAME_FPS * self.nEndGameTimeDelay,self.EndRoom,self,1);
	self.tbBase:BlackMsg(-1, "挑战成功，15秒后将离开圣诞关卡");
end

function RoomXmas:OnLoseGame()
	if self.nIsEnd == 1 then
		return 0;
	end
	ClearMapNpc(self.tbBase.nMapId);
	self.nIsEnd = 1;
	self.tbBase:CreateTimer(Env.GAME_FPS * self.nEndGameTimeDelay,self.EndRoom,self,0);
	self.tbBase:BlackMsg(-1, "挑战失败，15秒后将离开圣诞关卡");
	return 0;
end

function RoomXmas:StartGame()
	self:AddBossStep1();
end

function RoomXmas:AddBossStep1()
	local nLevel = self:GetNpcLevel();
	local nDelayTime = 5 * Env.GAME_FPS;
	for _,tbInfo in pairs(self.tbBossStep1) do
		local nTemplateId = tbInfo[1];
		if nTemplateId then
			for _,tbPos in pairs(tbInfo) do
				if type(tbPos) == "table" then
					local pNpc = KNpc.Add2(nTemplateId,nLevel,-1,self.tbBase.nMapId,tbPos[1],tbPos[2]);
					if pNpc then
						self.nBossStep1 = pNpc.dwId;
					end
				end
			end
		end
	end
	self.tbBase:CreateTimer(nDelayTime,self.OnAddEnemyStep2,self);
end

function RoomXmas:OnAddEnemyStep2()
	local nLevel = self:GetNpcLevel();
	self.nEnemyStep1Count = 0;
	for _,tbInfo in pairs(self.tbEnemyStep1) do
		local nTemplateId = tbInfo[1];
		if nTemplateId then
			for _,tbPos in pairs(tbInfo) do
				if type(tbPos) == "table" then
					local pNpc = KNpc.Add2(nTemplateId,nLevel,-1,self.tbBase.nMapId,tbPos[1],tbPos[2]);
					if pNpc then
						Npc:RegPNpcOnDeath(pNpc,self.OnEnemyStep1Death,self); 
						self.nEnemyStep1Count = self.nEnemyStep1Count + 1;
					end
				end
			end
		end
	end
	return 0;
end

function RoomXmas:OnEnemyStep1Death()
	self.nEnemyStep1Count = self.nEnemyStep1Count - 1;
	if self.nEnemyStep1Count <= 0 then
		self:StartStep2();
	end
end

function RoomXmas:StartStep2()
	local pBossStep1 = KNpc.GetById(self.nBossStep1);
	if pBossStep1 then
		pBossStep1.Delete();
	end
	self:AddNpcStep2();
end

function RoomXmas:AddNpcStep2()
	local nLevel = self:GetNpcLevel();
	for _,tbInfo in pairs(self.tbBossStep2) do
		local nTemplateId = tbInfo[1];
		if nTemplateId then
			for _,tbPos in pairs(tbInfo) do
				if type(tbPos) == "table" then
					local pNpc = KNpc.Add2(nTemplateId,nLevel,-1,self.tbBase.nMapId,tbPos[1],tbPos[2]);
					if pNpc then
						self.nBossStep2 = pNpc.dwId;
						Npc:RegPNpcOnDeath(pNpc,self.OnBossStep2Death,self); 
						for nPercent,_ in pairs(self.tbBossStep2PercentFunc) do
							Npc:RegPNpcLifePercentReduce(pNpc,nPercent,self.OnBossStep2Percent,self); 
						end
					end
				end
			end
		end
	end
end

function RoomXmas:OnBossStep2Percent(nPercent)
	local pNpc = KNpc.GetById(self.nBossStep2);
	if not pNpc then
		return 0;
	end
	local tbFunc = self.tbBossStep2PercentFunc[nPercent];
	if not tbFunc then
		return 0;
	end
	local szFun = tbFunc[1];
	if szFun and self[szFun] then
		self[szFun](self,unpack(tbFunc,2));
	end
end

function RoomXmas:AddEnemyStep2Percent(nType,nCount)
	local nLevel = self:GetNpcLevel();
	if nType <= 0 then
		for nIndex,tbInfo in pairs(self.tbEnemyStep2) do
			local nTemplateId = tbInfo[1];
			local nAddCount = 0;
			if nTemplateId then
				for _,tbPos in pairs(tbInfo) do
					if type(tbPos) == "table" then
						if nAddCount < nCount then
							local pNpc = KNpc.Add2(nTemplateId,nLevel,-1,self.tbBase.nMapId,tbPos[1],tbPos[2]);
							if pNpc then
								nAddCount = nAddCount + 1;
							end
						end
					end
				end
			end
		end
	else
		local tbInfo = self.tbEnemyStep2[nType];
		if not tbInfo then
			return 0;
		end
		local nTemplateId = tbInfo[1];
		local nAddCount = 0;
		if nTemplateId then
			for _,tbPos in pairs(tbInfo) do
				if type(tbPos) == "table" then
					if nAddCount < nCount then
						local pNpc = KNpc.Add2(nTemplateId,nLevel,-1,self.tbBase.nMapId,tbPos[1],tbPos[2]);
						if pNpc then
							nAddCount = nAddCount + 1;
						end
					end
				end
			end
		end
	end
end

function RoomXmas:OnBossStep2Death(pKiller)
	local pPlayer = pKiller.GetPlayer();
	local nLevel = Xmas2011:GetPrizeLevel();
	local szFile = Xmas2011.tbNoramlDropFile[nLevel];
	local nCount = self.tbBase.nConsumeItemCount or 1;
	if nCount >= 12 then	
		nCount = 12;
	end
	if szFile then
		him.DropRateItem(szFile,nCount,-1,-1,0);	--boss掉落
	end
	local szStoneFile = Xmas2011.szStoneDropFile;
	if szStoneFile then
		him.DropRateItem(szStoneFile,nCount,-1,-1,0);	--必掉一个碎片
	end
	self:EndGameOnBossDeath();
end

function RoomXmas:EndRoom(nFlag)
	if nFlag == 1 then
		self:WriteLog(1);
		self.tbBase:GameWin();	--游戏完成
	else
		self:WriteLog(0);
		self.tbBase:GameLose();	
	end
	return 0;
end

function RoomXmas:WriteLog(nSucess)
	local tbName = {};
	local tbPlayer = self.tbBase:GetPlayerList();
	for _,pPlayer in pairs(tbPlayer) do
		if pPlayer then
			table.insert(tbName,pPlayer.szName);
		end
	end
	StatLog:WriteStatLog("stat_info","shengdanjie_2011","room_result",0,nSucess,unpack(tbName));
end