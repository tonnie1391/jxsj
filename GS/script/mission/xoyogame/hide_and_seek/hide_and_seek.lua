Require("\\script\\mission\\xoyogame\\room_base.lua")

XoyoGame.RoomHideAndSeekDef = {};
local RoomHideAndSeekDef = XoyoGame.RoomHideAndSeekDef;
RoomHideAndSeekDef.CATCH_COUNT = 3; --捉住3个小孩才能过关
RoomHideAndSeekDef.ROUND_TIME = 60; --一轮的时间（秒）
RoomHideAndSeekDef.WAIT_TIME = 10; -- 休息时间
RoomHideAndSeekDef.TOTAL_ROUND = 4; -- 一共捉4轮

RoomHideAndSeekDef.tbNpcTemplateId = {4474, 4476, 4478, 4480};
RoomHideAndSeekDef.tbSkill = {
	{1418, "这么累，休息一下再追吧！"},
	{1419, "你跑的太快了，会抓到我们的！"},
	{1423, "你要小心了，我附近有很危险的东西哦！"},
};

XoyoGame.RoomHideAndSeek = Lib:NewClass(XoyoGame.BaseRoom);
local RoomHideAndSeek = XoyoGame.RoomHideAndSeek;

function RoomHideAndSeek:OnInitRoom()
	self.nCatchCount = 0;
	self.nRoundTimerId = nil;
	self.nInNewRound = 0; -- 是否能捉小偷，可以的话为1，捉到了或者在休息就设为0
	self.tbTemplateId2Name = {};
	
	local pDialogNpc1 = KNpc.Add2(4472, 1, -1, self.nMapId, 1880, 3447);
	local pDialogNpc2 = KNpc.Add2(4473, 1, -1, self.nMapId, 1717, 3611);
	self:AddNpcInGroup(pDialogNpc1, "dialog_child");
	self:AddNpcInGroup(pDialogNpc2, "dialog_child");
	
	self.nDialogNpcId = pDialogNpc1.dwId;
	self.nDialogNpcId1 = pDialogNpc1.dwId;
	self.nDialogNpcId2 = pDialogNpc2.dwId;
	
	self.nTotalWeight1, self.tbItemWeight1 = self:InitAward("\\setting\\npc\\droprate\\xoyogame\\xoyogame_lv4_baoxiang.txt");
	self.nTotalWeight2, self.tbItemWeight2 = self:InitAward("\\setting\\npc\\droprate\\xoyogame\\xoyogame_lv5_baoxiang.txt");
end

function RoomHideAndSeek:WinRule()
	if self.nCatchCount >= RoomHideAndSeekDef.CATCH_COUNT then
		return {self.tbTeam[1].nTeamId}, {};
	else
		return {}, {self.tbTeam[1].nTeamId};
	end
end

function RoomHideAndSeek:ChoseTargetChild()
	local nIndex = MathRandom(#RoomHideAndSeekDef.tbNpcTemplateId);
	self.nTargetTemplateId = RoomHideAndSeekDef.tbNpcTemplateId[nIndex];
	self.szTargetNpcName = self.tbTemplateId2Name[self.nTargetTemplateId];
end

function RoomHideAndSeek:DialogNpcOnDialog(pNpc)	
	if pNpc.dwId ~= self.nDialogNpcId1 and pNpc.dwId ~= self.nDialogNpcId2 then
		return;
	end
	
	if not self.szTargetNpcName or self.nInNewRound ~= 1 then
		local szMsg = "等下一次捉小偷开始后再告诉你，呵呵。";
		if self.nCaughtThisRound == 1 then
			szMsg = "你真的把那个捣蛋鬼给捉到啦？真厉害！" .. szMsg;
		end
		Dialog:Say(szMsg);
		return;
	end
	
	if pNpc.dwId ~= self.nDialogNpcId then
		local nOtherNpcId = self.nDialogNpcId1;
		if pNpc.dwId == self.nDialogNpcId1 then
			nOtherNpcId = self.nDialogNpcId2;
		end
		local pOtherNpc = KNpc.GetById(nOtherNpcId);
		if pOtherNpc then
			Dialog:Say(string.format("这一次我要休息一下，你问%s去吧。", pOtherNpc.szName));
		end
	else
		Dialog:Say(string.format("现在的小偷是%s", self.szTargetNpcName));
	end
end

function RoomHideAndSeek:__wait()
	self:DelNpc("child");
	local f = function(pPlayer)
		Dialog:SetBattleTimer(pPlayer, "<color=green>我还在找地方呢：%s<color>", RoomHideAndSeekDef.WAIT_TIME * Env.GAME_FPS);
		Dialog:SendBlackBoardMsg(pPlayer, "小捣蛋们正在找地方躲起来，马上就好");
	end
	
	self:GroupPlayerExcute(f, -1);	
end

function RoomHideAndSeek:GetDeathMsg(pPlayer)
	return "知道小捣蛋们的\"很危险的东西\"的滋味了吧！下次要小心哦！";
end

function RoomHideAndSeek:__play()
	-- 刷npc
	local tbNpc = Npc:GetClass("xoyo_child_hide_and_seek");
	for i, id in ipairs(RoomHideAndSeekDef.tbNpcTemplateId) do
		local pNpc = tbNpc:CreateChild(id, self.nMapId, nil, nil, self);
		self.tbTemplateId2Name[pNpc.nTemplateId] = pNpc.szName;
		self:AddNpcInGroup(pNpc, "child");
	end
	
	self:ChoseTargetChild();
	
	-- 换对话npc
	if self.nDialogNpcId == self.nDialogNpcId1 then
		self.nDialogNpcId = self.nDialogNpcId2;
	else
		self.nDialogNpcId = self.nDialogNpcId1;
	end
	
	local nTotalTime = tonumber(Timer:GetRestTime(self.tbLock[2].nTimerId));
	local nRoundTime = RoomHideAndSeekDef.ROUND_TIME;
	
	local f = function(pPlayer)
		Dialog:SetBattleTimer(pPlayer, "<color=green>Thời gian bắt trộm: %s\nThời gian vòng này: %s\n<color>" , nTotalTime, nRoundTime*Env.GAME_FPS);
		Dialog:SendBlackBoardMsg(pPlayer, "Vòng mới bắt đầu!");
	end
	
	self:GroupPlayerExcute(f, -1);
	self:SetTagetInfo(1, string.format("本轮捉到了0/1个捣蛋鬼\n一共捉到了%d/%d个捣蛋鬼\n", 
		self.nCatchCount, RoomHideAndSeekDef.CATCH_COUNT));
end

function RoomHideAndSeek:NewRound()	
	if not self.nNewRoundTimerId then
		self.nNewRoundTimerId = Timer:Register(RoomHideAndSeekDef.ROUND_TIME * Env.GAME_FPS, self.NewRound, self);	
		self.nState = "play";
		self.nPlayTimes = 0; --现在第几轮
	end
	
	if self.nState == "wait" then
		self.nInNewRound = 0;	
		if self.nPlayTimes == RoomHideAndSeekDef.TOTAL_ROUND then
			self:DelNpc("child");
			local nTotalTime = tonumber(Timer:GetRestTime(self.tbLock[2].nTimerId));
			local f = function(pPlayer)
				Dialog:SetBattleTimer(pPlayer, "<color=green>Thời gian bắt trộm: %s" , nTotalTime);
			end
			
			self:GroupPlayerExcute(f, -1);
			self:SetTagetInfo(1, "大家都累了吧？先休息一下吧。");
			self:AddGouHuo(10, 150, "gouhuo", {1715, 3614});
			self:AddGouHuo(10, 150, "gouhuo", {1877, 3443});
			
			self.nNewRoundTimerId = nil;
			return 0;
		else
			self:__wait();
			self.nState = "play";
			return RoomHideAndSeekDef.WAIT_TIME * Env.GAME_FPS;
		end
	else
		self.nPlayTimes = self.nPlayTimes + 1;
		self:__play();
		self.nCaughtThisRound = 0;
		self.nInNewRound = 1;	
		self.nState = "wait";
		return RoomHideAndSeekDef.ROUND_TIME * Env.GAME_FPS;
	end
end

function RoomHideAndSeek:OnClose()
	if self.nNewRoundTimerId then
		Timer:Close(self.nNewRoundTimerId);
		self.nNewRoundTimerId = nil;
	end
	
	if self.nDelNpcTimerId then
		Timer:Close(self.nDelNpcTimerId);
		self.nDelNpcTimerId = nil;
	end
end

function RoomHideAndSeek:IsTargetChild(pNpc)
	if pNpc.nTemplateId == self.nTargetTemplateId then
		return 1;
	else
		return 0;
	end
end

function RoomHideAndSeek:CanCatchChild()
	return self.nInNewRound;
end

function RoomHideAndSeek:DelChild()
	self:DelNpc("child");
	self.nDelNpcTimerId = nil;
	return 0;
end

function RoomHideAndSeek:CaughtChild(pPlayer, pNpc)
	self.nCatchCount = self.nCatchCount + 1;
	self:SetTagetInfo(1, string.format("<color=green>本轮捉到了1/1个捣蛋鬼<color>\n一共捉到了%d/%d个捣蛋鬼\n", 
		self.nCatchCount, RoomHideAndSeekDef.CATCH_COUNT)); 
	self.nCaughtThisRound = 1;
	self.nInNewRound = 0;
	self.nDelNpcTimerId = Timer:Register(2*Env.GAME_FPS, self.DelChild, self);
	self:GiveAward(self.tbPlayerGroup[1], self.nTotalWeight1, self.tbItemWeight1);
	if self.nCatchCount > RoomHideAndSeekDef.CATCH_COUNT then
		self:GiveAward(self.tbPlayerGroup[1], self.nTotalWeight2, self.tbItemWeight2);
	end
	if self.nCatchCount == RoomHideAndSeekDef.CATCH_COUNT then
		if self.nNewRoundTimerId then
			Timer:Close(self.nNewRoundTimerId);
			self.nNewRoundTimerId = nil;
		end
		self:DelNpc("child");
		self:AddGouHuo(10, 150, "gouhuo", {1715, 3614});
		self:AddGouHuo(10, 150, "gouhuo", {1877, 3443});
		self:RoomLevelUp();
	end
end

-- 返回npc对应的技能id
function RoomHideAndSeek:GetSkillId(pNpc)
	local tbSkill = RoomHideAndSeekDef.tbSkill;
	return tbSkill[MathRandom(#tbSkill)];
end

function RoomHideAndSeek:OnPlayerLeaveRoom(nPlayerId)
	return;
end

function RoomHideAndSeek:InitAward(szFile)
	local nTotalWeight = 0;
	local tbItemWeight = {}; -- {{nWeight, {g,d,p,l}}, {nWeight, {g,d,p,l}}, ...}
	local tbFile = Lib:LoadTabFile(szFile);
	for i = 2, #tbFile do
		local tbRow = tbFile[i];
		if tbRow["Genre"] then
			local g = tonumber(tbRow["Genre"]);
			local d = tonumber(tbRow["Detail"]);
			local p = tonumber(tbRow["Particular"]);
			local l = tonumber(tbRow["Level"]);
			local nWeight = tonumber(tbRow["RandRate"]);
			local tb = {nWeight, {g,d,p,l}};
			nTotalWeight = nTotalWeight + nWeight;
			table.insert(tbItemWeight, tb);
		end
	end
	return nTotalWeight, tbItemWeight;
end

function RoomHideAndSeek:RandomAward(nTotalWeight, tbItemWeight)
	local nRand = MathRandom(nTotalWeight);
	local nSum = 0;
	for _, v in ipairs(tbItemWeight) do
		nSum = v[1] + nSum;
		if nSum >= nRand then
			return v;
		end
	end
end

function RoomHideAndSeek:GiveAward(tbPlayerId, nTotalWeight, tbItemWeight)	
	for _, nPlayerId in ipairs(tbPlayerId) do
		local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
		if pPlayer then
			local tbAward = self:RandomAward(nTotalWeight, tbItemWeight);
			local tbGDPL = tbAward[2];
			pPlayer.AddItem(unpack(tbGDPL));
		end
	end
end

