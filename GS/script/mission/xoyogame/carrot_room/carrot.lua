-- 拔萝卜
Require("\\script\\mission\\xoyogame\\room_base.lua")

XoyoGame.RoomCarrotDef = {};
local RoomCarrotDef = XoyoGame.RoomCarrotDef;
RoomCarrotDef.TIME_FORBID_PICK_CARROT = 10; --重生10秒内不能捡萝卜
RoomCarrotDef.TIME_REFRESH_INTERVAL = 15; --刷萝卜时间间隔（秒）
RoomCarrotDef.CARROT_NUM = 2;
RoomCarrotDef.SKILL_NUM = 3;
RoomCarrotDef.tbCarrotItem = {20,1,574,1};
RoomCarrotDef.DAMAGE_CONTROL_INTERVAL = 0.5 * Env.GAME_FPS;

XoyoGame.RoomCarrot = Lib:NewClass(XoyoGame.BaseRoom);
local RoomCarrot = XoyoGame.RoomCarrot;

function RoomCarrot:__get_temp_table(pPlayer)
	local tbTemp = pPlayer.GetTempTable("XoyoGame");
	if not tbTemp.RoomCarrot then
		tbTemp.RoomCarrot = {};
	end
	return tbTemp.RoomCarrot;
end

function RoomCarrot:OnInitRoom()
	self.szName = "RoomCarrot";
	self.nBeginPick = 0;
end

function RoomCarrot:OnBeforeStart()
	self.tbTeam[1].nCount = 0;
	self.tbTeam[2].nCount = 0;
	self:GroupPlayerExcute(self.DeleteCarrotInBag);
end

function RoomCarrot:Phrase1Logic()
	local f = function(pPlayer)
		pPlayer.SetForbidUseItem(1);
		pPlayer.RemoveSkillState(476); --不准吃菜
		pPlayer.StartDamageCounter();
	end
	
	self:GroupPlayerExcute(f);
	self.nDamageTimerId = Timer:Register(1, self.DamageControl, self);
end

-- 为防止阵法，打坐等回血，每隔一段时间同步一次伤害量
function RoomCarrot:DamageControl()
	local f = function(pPlayer)
		if pPlayer.nFightState == 0 then
			return;
		end
		
		local nDamage = pPlayer.GetDamageCounter();
		local nCurLife = 15 - nDamage;
		if nCurLife > 15 then nCurLife = 15 end
		if nCurLife < 1 then nCurLife = 1 end
		
		pPlayer.ReduceLife2Value(nCurLife);
		
		if nDamage >= 15 then
			self:PlayerDeathLogic(pPlayer);
		end
	end
	
	self:GroupPlayerExcute(f);
	
	return RoomCarrotDef.DAMAGE_CONTROL_INTERVAL;
end

function RoomCarrot:SetPlayerLife() -- 也不知道是哪里把血加回去了~~~
	local f = function(pPlayer)
		pPlayer.ReduceLife2Value(15);
	end
	self:GroupPlayerExcute(f);
end

function RoomCarrot:PlayerDeathLogic(pPlayer)
	if pPlayer.nFightState == 0 then
		return;
	end
	
	pPlayer.StopDamageCounter(); -- 清零
	pPlayer.StartDamageCounter();
	assert(pPlayer.GetDamageCounter()==0)
	
	pPlayer.ReviveImmediately(1);
	pPlayer.ReduceLife2Value(15);
	
	-- 战斗状态
	pPlayer.SetFightState(0);
	local nRefightId = self:__get_temp_table(pPlayer).nRefightId;
	if nRefightId then
		Timer:Close(nRefightId);
	end
	
	self:TransformChild(pPlayer);
	self:PlayerLostCarrot(pPlayer);
	self:SetPlayerPickCarrot(pPlayer, GetTime()+RoomCarrotDef.TIME_FORBID_PICK_CARROT);
	self:__get_temp_table(pPlayer).nRefightId = Timer:Register(RoomCarrotDef.TIME_FORBID_PICK_CARROT*Env.GAME_FPS, self.ReFight, self, pPlayer.nId);
end

function RoomCarrot:PlayerDeath()
	self:PlayerDeathLogic(me);
end

-- 死后10秒重新可以拔萝卜和打架
function RoomCarrot:ReFight(nPlayerId)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if pPlayer then
		pPlayer.SetFightState(1);
		self:__get_temp_table(pPlayer).nRefightId = nil;
	end
	
	return 0;
end

-- 设置玩家在什么时间之后才能否捡地上的萝卜
function RoomCarrot:SetPlayerPickCarrot(pPlayer, nTime)
	self:__get_temp_table(pPlayer).nPickCarrotTime = nTime;
end

function RoomCarrot:CanPlayerPickCarrot(pPlayer)
	local nPickCarrotTime = self:__get_temp_table(pPlayer).nPickCarrotTime or 0;
	if self.nBeginPick == 1 and GetTime() >= nPickCarrotTime then
		return 1; -- 可以把萝卜
	else
		return 0; -- 不可把萝卜
	end
end

function RoomCarrot:BeginPick()
	self.nBeginPick = 1;
end

function RoomCarrot:PlayerGotCarrot(pPlayer, pNpc, nNoAddItem)
	local nPlayerId = pPlayer.nId;
	local tbPlayerInfo = assert(self.tbPlayer[nPlayerId]);
	
	local nTeam = tbPlayerInfo.nTeam;
	self.tbTeam[nTeam].nCount =  math.max(0, self.tbTeam[nTeam].nCount + 1);
	
	if not nNoAddItem then
		pPlayer.AddItem(unpack(RoomCarrotDef.tbCarrotItem));
	end
	
	pPlayer.AddSkillState(1450, 1, 0, 0);
	self:UpdateTargetinfo();
	if pNpc then
		pPlayer.DropRateItem("\\setting\\npc\\droprate\\xoyogame\\xoyogame_lv4_baoxiang.txt", 3, 10, -1, pNpc);
	end
end

-- 返回萝卜数
function RoomCarrot.DeleteCarrotInBag(pPlayer)
	local tbFind = pPlayer.FindItemInBags(unpack(RoomCarrotDef.tbCarrotItem));
	local nCarrotNum = 0;
	for _, data in ipairs(tbFind) do
		nCarrotNum = nCarrotNum + data.pItem.nCount;
		data.pItem.Delete(pPlayer);
	end
	return nCarrotNum;
end

function RoomCarrot:PlayerLostCarrot(pPlayer)
	local nPlayerId = pPlayer.nId;
	local tbPlayerInfo = assert(self.tbPlayer[nPlayerId]);
	local nCarrotNum = self.DeleteCarrotInBag(pPlayer);
	
	-- 地上掉萝卜
	local nMapId, x, y = pPlayer.GetWorldPos();
	for i = 1, nCarrotNum do
		KItem.AddItemInPos(nMapId, x + MathRandom(10) - 5, y + MathRandom(10) - 5, unpack(RoomCarrotDef.tbCarrotItem));
	end
	
	local nTeam = tbPlayerInfo.nTeam;
	self.tbTeam[nTeam].nCount = math.max(0, self.tbTeam[nTeam].nCount - nCarrotNum);
	self:UpdateTargetinfo();
	pPlayer.RemoveSkillState(1450);
end

function RoomCarrot:UpdateTargetinfo()
	self:SetTagetInfo(1, 
		string.format("我们有%d个萝卜\n他们有%d个萝卜", self.tbTeam[1].nCount, self.tbTeam[2].nCount));

	self:SetTagetInfo(2, 
		string.format("我们有%d个萝卜\n他们有%d个萝卜", self.tbTeam[2].nCount, self.tbTeam[1].nCount));
end
	
function RoomCarrot:OnPlayerLeaveRoom(nPlayerId)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if pPlayer then
		local nRefightId = self:__get_temp_table(pPlayer).nRefightId;
		if nRefightId then
			Timer:Close(nRefightId);
		end
		pPlayer.SetForbidUseItem(0);
		pPlayer.RemoveSkillState(1418);
		pPlayer.StopDamageCounter();
		self.DeleteCarrotInBag(pPlayer);
	end
end

function RoomCarrot:FinishMsg()
	if self.tbTeam[1].nCount == self.tbTeam[2].nCount then
		self:MovieDialog(-1, "旗鼓相当，平分秋色。");
		return
	end
	
	local nWinTeam = 1;
	local nLoseTeam = 2;
	if self.tbTeam[1].nCount < self.tbTeam[2].nCount then
		nWinTeam = 2;
		nLoseTeam = 1;
	end
	
	self:MovieDialog(nWinTeam, "我们果然是技高一筹。");
	self:MovieDialog(nLoseTeam, "虽败犹荣，下次继续努力。");
end

function RoomCarrot:CanUseMedicine()
	return 0;
end

function RoomCarrot:OnClose()
	if self.nDamageTimerId then
		Timer:Close(self.nDamageTimerId);
	end
	self.nDamageTimerId = nil;
end