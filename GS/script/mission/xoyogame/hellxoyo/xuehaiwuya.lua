-- 文件名　：xuhaiwuya.lua
-- 创建者　：zhangjunjie
-- 创建时间：2011-03-22 14:37:57
-- 描述：学海无涯--逍遥谷

local tbHanDan = Npc:GetClass("xoyo_handan");

tbHanDan.tbSkillId = 
{
	["hongdoushengnanguo"] = 2091, --全屏秒杀
	["yuanjunduocaixie"] = 2093, --随机两个的debuff
	["ciwuzuixiangsi"] = 2095, --全所有人
}

tbHanDan.nHandanId = 7334;	--韩丹id
tbHanDan.nChildId = 7337;	--影子id

tbHanDan.nObserverDelayFrame = 3;	--检测玩家距离的时间间隔
tbHanDan.nLimitDistance = 2*2;	-- 两个玩家之间距离小于2个格子时，buff取消

tbHanDan.nObserverCastDelay = 40;	--放出影子后40s的等待时间
tbHanDan.nCastDelay = 5;	--红豆生南国的间隔时间

tbHanDan.tbChildPos = 	--影子出生的位置
{
	[1] = {50816,103360},
	[2] = {51072,104064},
	[3] = {51200,102720},
	[4] = {51648,103328},
}
tbHanDan.tbHanDanPos = {51200,103264};	--韩丹出生位置

tbHanDan.tbBloodPercent = {
	[90] = "AddChildren",
	[85] = "PlayerSufferDebuff",
	[80] = "NpcCastCWZXS",
	[75] = "PlayerSufferDebuff",
	[65] = "NpcCastCWZXS",
	[60] = "AddChildren",
	[55] = "PlayerSufferDebuff",
	[50] = "NpcCastCWZXS",
	[45] = "PlayerSufferDebuff",
	[40] = "NpcCastCWZXS",
	[30] = "AddChildren",
	[15] = "PlayerSufferDebuff",
	[10] = "NpcCastCWZXS",
};	--血量注册



function tbHanDan:Reset()
	tbHanDan.nObserverTimerId = 0; --玩家中了2093技能后的检测计时器
	tbHanDan.nObserverCastTimerId = 0; --放出影子后40s，如果影子没有打死，释放秒杀技能
	tbHanDan.nCastSkillTimerId = 0;	
	tbHanDan.tbSufferDebuffPlayer = {};	--记录当前中了debuff的两个玩家
	tbHanDan.nChildrenCount = 0;
	tbHanDan.nMapId = 0;
	tbHanDan.nNpcId = 0;
	tbHanDan.nLevel = 0;
end


--增加影子
function tbHanDan:AddChildren(nNpcId)
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		return 0;
	end
	local tbRoom = pNpc.GetTempTable("XoyoGame").tbRoom;
	if not tbRoom then
		return 0;
	end
	local nCount = 4;	--一次放出4个影子
	if pNpc then
		for i = 1 ,nCount do
			local pChild = KNpc.Add2(self.nChildId,tbRoom.nLevel or 100,-1,tbRoom.nMapId,self.tbChildPos[i][1] / 32, self.tbChildPos[i][2] / 32,0);
			tbRoom.nChildrenCount = tbRoom.nChildrenCount + 1;
			Npc:RegPNpcOnDeath(pChild, self.OnDeath_Shadow, self,tbRoom);
		end
		if tbRoom.nObserverCastTimerId <= 0 then
			tbRoom.nObserverCastTimerId = Timer:Register(	--40秒后检测
								self.nObserverCastDelay * Env.GAME_FPS, 
								self.ObserverCastSkill, 
								self,tbRoom);
		end
	end
end

function tbHanDan:OnDeath_Shadow(tbRoom)
	if not tbRoom then
		return 0;
	end
	tbRoom.nChildrenCount = tbRoom.nChildrenCount - 1;
	if tbRoom.nChildrenCount <= 0 then
		tbRoom.nChildrenCount = 0;
		if tbRoom.nObserverCastTimerId > 0 then
			Timer:Close(tbRoom.nObserverCastTimerId);
			tbRoom.nObserverCastTimerId = 0;
		end
		if tbRoom.nCastSkillTimerId > 0 then
			Timer:Close(tbRoom.nCastSkillTimerId);
			tbRoom.nCastSkillTimerId = 0;
		end
	end
end


--40秒后检测
function tbHanDan:ObserverCastSkill(tbRoom)
	if not tbRoom then
		return 0;
	end
	tbRoom.nCastSkillTimerId  = Timer:Register(	
					self.nCastDelay * Env.GAME_FPS, 
					self.CastFinalSkill, 
					self,tbRoom);
	tbRoom.nObserverCastTimerId = 0;
	return 0;
end

--boss释放秒杀技能
function tbHanDan:CastFinalSkill(tbRoom)
	if not tbRoom then
		tbRoom.nCastSkillTimerId = 0;
		return 0;
	end
	local pNpc = KNpc.GetById(tbRoom.nNpcId);
	if pNpc then
		if tbRoom.nChildrenCount > 0 then
			local _,x,y = pNpc.GetWorldPos();
			pNpc.CastSkill(self.tbSkillId["hongdoushengnanguo"],10,x*32,y*32,1);
		else
			tbRoom.nCastSkillTimerId = 0;
			return 0;
		end
	else
		tbRoom.nCastSkillTimerId = 0;
		return 0;
	end
end

--创建npc
function tbHanDan:Create(nMapId,nLevel,tbRoom)
	local pNpc = KNpc.Add2(self.nHandanId,nLevel,-1,nMapId, self.tbHanDanPos[1] / 32, self.tbHanDanPos[2] / 32,0);
	if not pNpc then
		return;
	end
	pNpc.GetTempTable("XoyoGame").tbRoom = tbRoom;
	tbRoom.nChildrenCount = 0;
	tbRoom.nMapId = nMapId;
	tbRoom.nNpcId = pNpc.dwId; --记录韩丹的id
	tbRoom.nLevel = nLevel;	 --记录怪物平均等级
	tbRoom.tbSufferDebuffPlayer = {};	--记录当前中了debuff的两个玩家
	tbRoom.nObserverTimerId = 0; --玩家中了2093技能后的检测计时器
	tbRoom.nObserverCastTimerId = 0; --放出影子后40s，如果影子没有打死，释放秒杀技能
	tbRoom.nCastSkillTimerId = 	0;
	for nIndex,tbFun in pairs(self.tbBloodPercent) do
		if tbFun then
			Npc:RegPNpcLifePercentReduce(pNpc, nIndex, self[tbFun],self,pNpc.dwId); --注册血量回调
		end
	end
	return pNpc;
end


--随机两个玩家中debuff
function tbHanDan:PlayerSufferDebuff(nNpcId)
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		return 0;
	end
	local tbRoom = pNpc.GetTempTable("XoyoGame").tbRoom;
	if not tbRoom then
		return;
	end
	local tbGroup = tbRoom.tbPlayerGroup;
	local tbPlayerTemp = {};
	for nGroupId, tbCurGroup in pairs(tbGroup) do
		for _, nPlayerId in pairs(tbCurGroup) do
			if tbRoom.tbPlayer[nPlayerId] then 
				local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
				table.insert(tbPlayerTemp,pPlayer);
			end
		end
	end
	if #tbPlayerTemp <= 1 or #tbRoom.tbSufferDebuffPlayer ~= 0 then
		return;
	end
	for i = 1 , 2 do	-- 随机2个玩家
		local nPos = MathRandom(#tbPlayerTemp);
		local pPlayer = tbPlayerTemp[nPos];
		local _,x,y = pPlayer.GetWorldPos();
		pPlayer.CastSkill(self.tbSkillId["yuanjunduocaixie"],6,x,y,1);
		table.insert(tbRoom.tbSufferDebuffPlayer,pPlayer.nId);
		table.remove(tbPlayerTemp,nPos);
	end
	self.nObserverTimerId = Timer:Register(	--检测距离
					self.nObserverDelayFrame, 
					self.Observer, 
					self,
					tbRoom);
end


--检测玩家距离
function tbHanDan:Observer(tbRoom)
	if not tbRoom then
		return 0;
	end
	local tbPos = {};
	local bStateDisapper = 0;
	for nIndex,nId in pairs(tbRoom.tbSufferDebuffPlayer) do
		if nId then
			if tbRoom.tbPlayer[nId] then 
				local pPlayer = KPlayer.GetPlayerObjById(nId);
				local _,x,y = pPlayer.GetWorldPos();
				tbPos[nIndex] = {x,y};
			end
		end
	end
	if #tbPos ~= 2 then	--其中一个玩家已经死亡，则清除中buff的表
		tbRoom.tbSufferDebuffPlayer = {};
		return 0;
	end
	local nDistance = (tbPos[2][1] - tbPos[1][1])^2 + (tbPos[2][2] - tbPos[1][2])^2;
	for i = 1,#tbRoom.tbSufferDebuffPlayer do
		if tbRoom.tbPlayer[tbRoom.tbSufferDebuffPlayer[i]] then 
			local pPlayer = KPlayer.GetPlayerObjById(tbRoom.tbSufferDebuffPlayer[i]);
			if pPlayer.GetSkillState(self.tbSkillId["yuanjunduocaixie"]) <= 0 then	
				bStateDisapper = 1;	--状态消失了，从buff表中清除
				break;
			end
		end
	end
	if bStateDisapper == 1 then
		tbRoom.tbSufferDebuffPlayer = {};
		return 0;
	end
	--两者走到一起
	if nDistance <= self.nLimitDistance then
		for i = 1,#tbRoom.tbSufferDebuffPlayer do
			local pPlayer = KPlayer.GetPlayerObjById(tbRoom.tbSufferDebuffPlayer[i]);
			pPlayer.RemoveSkillState(self.tbSkillId["yuanjunduocaixie"]);
		end
		tbRoom.tbSufferDebuffPlayer = {};
		return 0;
	end 
end


--npc释放此物最相思
function tbHanDan:NpcCastCWZXS(nNpcId)
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		return 0;
	end
	local tbRoom = pNpc.GetTempTable("XoyoGame").tbRoom;
	if not tbRoom then
		return;
	end
	local tbGroup = tbRoom.tbPlayerGroup;
	for nGroupId, tbCurGroup in pairs(tbGroup) do
		for _, nPlayerId in pairs(tbCurGroup) do
			if tbRoom.tbPlayer[nPlayerId] then 
				local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
				local _,x,y = pPlayer.GetWorldPos();
				pPlayer.CastSkill(self.tbSkillId["ciwuzuixiangsi"],4,x,y,1);
			end
		end
	end
end


--血量回调
function tbHanDan:OnLifePercentReduce(nPercent,nNpcId)
	local tbFun = self.tbBloodPercent[nPercent];
	if tbFun then
		self[tbFun[1]](self,nNpcId);
	end
end


function tbHanDan:OnDeath(pKiller)
	local tbRoom = him.GetTempTable("XoyoGame").tbRoom;
	XoyoGame:NpcUnLock(him);
	XoyoGame.XoyoChallenge:KillNpcForCard(pKiller.GetPlayer(), him);
	local pPlayer = pKiller.GetPlayer();
	if pPlayer then
		Achievement:FinishAchievement(pPlayer, 200);
	end
	if tbRoom then
		tbRoom:End();
	end
end


---------------房间逻辑---------------------------
Require("\\script\\mission\\xoyogame\\room_base.lua");

XoyoGame.RoomXueHaiWuYa = Lib:NewClass(XoyoGame.BaseRoom);

local RoomXueHaiWuYa = XoyoGame.RoomXueHaiWuYa;

function RoomXueHaiWuYa:CreateNpc()
	local nLevel = self:GetAverageLevel();
	nLevel = self:GetMonsterLevel(nLevel);
	local pNpc = Npc:GetClass("xoyo_handan"):Create(self.nMapId,nLevel,self);
	self:AddNpcInGroup(pNpc, "boss");
end


function RoomXueHaiWuYa:Clear()
	self:RemovePlayerGroupEffect(-1,Npc:GetClass("xoyo_handan").tbSkillId["ciwuzuixiangsi"]);
	self:RemovePlayerGroupEffect(-1,Npc:GetClass("xoyo_handan").tbSkillId["yuanjunduocaixie"]);
	if self.tbTeam[1].bIsWiner ~= 1 then
		self:DelNpc("boss");
	end
	ClearMapNpcWithName(self.nMapId,"韩丹的影子");
end

function RoomXueHaiWuYa:OnInitRoom()
	ClearMapObj(self.nMapId);
end

function RoomXueHaiWuYa:End()
	self:Clear();
	self:MovieDialog(-1, "<npc=7334>:红豆...红豆....呃......");
	self.tbTeam[1].bIsWiner = 1;
	self:CloseInfo(-1);
	self:SetTagetInfo(-1,"任务完成");
	self:AddGouHuo(2, 150, "gouhuo", "84_gouhuo_lv6");
	self:ChangeFight(-1,0,Player.emKPK_STATE_PRACTISE);
	self:RoomLevelUp();
end

function RoomXueHaiWuYa:OnClose()
	self:Clear();
end