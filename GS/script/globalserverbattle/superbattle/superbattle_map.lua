-------------------------------------------------------
-- 文件名　 : supertbBattleMap.lua
-- 创建者　 : zhangjinpin@kingsoft
-- 创建时间 : 2011-06-02 15:33:15
-- 文件描述 :
-------------------------------------------------------

if not MODULE_GAMESERVER then
	return;
end

Require("\\script\\globalserverbattle\\superbattle\\superbattle_def.lua");

-- battle map
local tbBattleMap = SuperBattle.BattleMap or {};
SuperBattle.BattleMap = tbBattleMap;

function tbBattleMap:OnEnter2()
	
	local nCamp = 0;
	for _, tbInfo in pairs(SuperBattle.tbMissionPlayer or {}) do
		if tbInfo.szName == me.szName then
			nCamp = tbInfo.nCamp;
			break;
		end
	end
	
	if SuperBattle.tbMissionGame and SuperBattle.tbMissionGame:IsOpen() ~= 0 and nCamp > 0 then
		if not SuperBattle.tbPlayerData[me.szName] and SuperBattle.tbMissionGame.nWarState >= SuperBattle.WAR_ADMIRAL then
			SuperBattle:SendMessage(me, SuperBattle.MSG_BOTTOM, "Ngươi đến quá muộn, trận chiến sắp kết thúc!");
			Transfer:NewWorld2GlobalMap(me, SuperBattle.TRANS_POS);
			return 0;
		end
		SuperBattle.tbMissionGame:JoinPlayer(me, nCamp);
		me.SetLogoutRV(1);	
	else
		Transfer:NewWorld2GlobalMap(me, SuperBattle.TRANS_POS);
	end
	
	tbBattleMap:ClearInventory()
end

function tbBattleMap:ClearInventory()
	local tbBag = {
		Item.ROOM_EQUIP,	-- 装备着的
		Item.ROOM_EQUIPEX,	-- 装备切换空间
		Item.ROOM_MAINBAG,	-- 主背包			
		Item.ROOM_EXTBAG1,	-- 扩展背包1
		Item.ROOM_EXTBAG2,	-- 扩展背包2
		Item.ROOM_EXTBAG3,	-- 扩展背包3
		Item.ROOM_EXTBAGBAR,	-- 扩展背包放置栏
		};
	local tbEquit = {};
	local pItem = nil;
	for i = 1, #tbBag do 
		tbEquit = me.FindAllItem(tbBag[i]);	
		for _,nIndex in pairs(tbEquit) do 
			pItem = KItem.GetItemObj(nIndex);
			if pItem then
				pItem.Delete(me);
			end	
		end	
	end
	
	for i = 20, 3000 do
		me.DelFightSkill(i);
	end
	
	Partner:DoPartnerCallBack(me, 0);
	for i = me.nPartnerCount, 1, -1 do
		local pPartner = me.GetPartner(i - 1);
		if pPartner then
			me.DeletePartner(i - 1);
		end
	end
	
	me.ResetFightSkillPoint();	-- 重置技能点
	me.UnAssignPotential();		-- 重置潜能点
	
	me.AddStackItem(18, 1, 1209, 3, {bForceBind= 1}, 1)
	me.AddStackItem(18, 1, 1209, 4, {bForceBind= 1}, 1)
end

function tbBattleMap:OnLeave(szParam)
	if SuperBattle.tbMissionGame and SuperBattle.tbMissionGame:IsOpen() ~= 0 then
		SuperBattle.tbMissionGame:KickPlayer(me);
		me.SetLogoutRV(0);
	end
end
-- end

-- trap
local tbTrap = SuperBattle.Trap or {};
SuperBattle.Trap = tbTrap;

function tbTrap:OnPlayer()
	local nCamp = SuperBattle:GetPlayerTypeData(me, "nCamp");
	if self.nMapX and self.nMapY and self.nFightState and self.nCamp == nCamp then
		if self.nFightState == 1 then
			if SuperBattle.tbMissionGame.nWarState <= SuperBattle.WAR_INIT then
				SuperBattle:SendMessage(me, SuperBattle.MSG_BOTTOM, "Trận chiến chưa bắt đầu, vui lòng chờ đợi.");
				local nRand = MathRandom(1, #SuperBattle.CAMP_POS[nCamp]);
				local nMapX, nMapY = unpack(SuperBattle.CAMP_POS[nCamp][nRand]);
				me.NewWorld(me.nMapId, nMapX, nMapY);
				return 0;
			end
			Player:AddProtectedState(me, SuperBattle.SUPER_TIME);
			SuperBattle:SendMessage(me, SuperBattle.MSG_BOTTOM, "Tiến vào trận địa! Hãy cẩn thận!");
		else
			SuperBattle:SendMessage(me, SuperBattle.MSG_BOTTOM, "Đã về hậu doanh, hãy thư giãn.");
		end
		me.NewWorld(me.nMapId, self.nMapX, self.nMapY);
		me.SetFightState(self.nFightState);
	end
end
-- end

function SuperBattle:LinkMapTrap()
	for _, nMapId in pairs(self.BATTLE_MAP) do
		local tbMap = Map:GetClass(nMapId);
		for szFunMap, _ in pairs(self.BattleMap) do
			tbMap[szFunMap] = self.BattleMap[szFunMap];
		end
		for szTrapName, tbInfo in pairs(self.MAP_TRAP_POS) do
			local tbTrap = tbMap:GetTrapClass(szTrapName);
			tbTrap.nMapX = tbInfo[1];
			tbTrap.nMapY = tbInfo[2];
			tbTrap.nFightState = tbInfo[3];
			tbTrap.nCamp = tbInfo[4];
			for szFunTrap in pairs(self.Trap) do
				tbTrap[szFunTrap] = self.Trap[szFunTrap];
			end
		end
	end
end

SuperBattle:LinkMapTrap();
