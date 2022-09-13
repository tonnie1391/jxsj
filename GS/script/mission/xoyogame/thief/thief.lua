-- 飞贼
Require("\\script\\mission\\xoyogame\\room_base.lua");
Require("\\script\\mission\\xoyogame\\thief\\thief_def.lua");
XoyoGame.RoomThief = Lib:NewClass(XoyoGame.BaseRoom);
local RoomThief = XoyoGame.RoomThief;

function RoomThief:OnInitRoom()
	self.szThiefMsgColor = "red";
	self.szVaseMsgColor = "red";
	self.szName = "RoomThief";
end

function RoomThief:OnBeforeStart()
	local tbPos = XoyoGame.RoomThiefDef.tbPos;
	local nNum = #tbPos;
	for i = 5005, 5044 do
		assert(nNum >= 1)
		local nIndex = MathRandom(nNum);
		local pNpc = assert(KNpc.Add2(i, 80, 0, self.nMapId, tbPos[nIndex][1]/32, tbPos[nIndex][2]/32));
		self:AddNpcInGroup(pNpc, "deheng");
		tbPos[nIndex], tbPos[nNum] = tbPos[nNum], tbPos[nIndex];
		nNum = nNum - 1;
	end
	assert(nNum == 0);
end

function RoomThief:AddThief()
	local pThief = Npc:GetClass("xoyonpc_thief"):CreateChild(self.nMapId, 1600, 3784, self);
	self:AddNpcInGroup(pThief, "thief");
end

function RoomThief:OnPlayerTrap(szTrapClassName)
	local m,x,y=me.GetWorldPos(); -- 龙舟技能
	me.CastSkill(1384, 11, x*32, y*32);	
end

-- 玩家拿到青花瓷
function RoomThief:PlayerGotVase()
	self.nPlayerGotVase = 1;
	self.szVaseMsgColor = "green";
	self:UpdateMsg();
	self:CheckWin();
end

-- 飞贼到达终点
function RoomThief:ThiefFinish()
	if self.nThiefFinish ~= 1 then
		self.nThiefFinish = 1;
		self.szThiefMsgColor = "green";
		self:DelNpc("thief");
		self:MovieDialog(-1, "人算不如天算，还是被官府捕快抓住了！");
		self:UpdateMsg();
		self:CheckWin();
	end
end

function RoomThief:UpdateMsg()
	local szMsg = string.format("<color=%s>将飞贼赶入官府的埋伏圈<color>\n<color=%s>找出张德恒夺回青花瓷瓶<color>", 
		self.szThiefMsgColor, self.szVaseMsgColor);
	self:SetTagetInfo(-1, szMsg);
end

function RoomThief:CheckWin()
	if self:IsWin() == 1 and not self.nHasGouHuo then
		self:AddGouHuo(10, 150, "gouhuo", {2023,3289});
		self.nHasGouHuo = 1;
	end
	if self:IsWin() == 1 and self.nHasGouHuo == 1 then
		self:RoomLevelUp();
	end
end

function RoomThief:IsWin()
	if self.nPlayerGotVase == 1 and self.nThiefFinish == 1 then
		self.tbTeam[1].bIsWiner = 1;
		return 1;
	else
		return 0;
	end
end

function RoomThief:OnPlayerLeaveRoom(nPlayerId)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if pPlayer then
		local tbFind = pPlayer.FindItemInBags(unpack(XoyoGame.RoomThiefDef.tbVase));
		for _, data in ipairs(tbFind) do
			data.pItem.Delete(pPlayer);
		end
	end
end