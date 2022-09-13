-------------------------------------------------------
-- 文件名　：marry_game.lua
-- 创建者　：furuilei
-- 创建时间：2010-01-21 16:39:35
-- 文件描述：结婚小游戏
-------------------------------------------------------

Require("\\script\\marry\\logic\\marry_def.lua");

if (not MODULE_GAMESERVER) then
	return 0;
end

local tbMiniGame = Marry.MiniGame or {};
Marry.MiniGame = tbMiniGame;

--==================================================================

tbMiniGame.FULINMEN_TEMPLATE_ID = 6615;

-- npc福临门的坐标，对应的是4个不同等级的地图
tbMiniGame.TB_POS_FULINMEN = {
	[1] = {1740, 3175},
	[2] = {1588, 3188},
	[3] = {1671, 3106},
	[4] = {1560, 3253},
	};
	
tbMiniGame.STEP_GAME_DABAOZHU	= 1;	-- 游戏，大爆竹
tbMiniGame.STEP_GAME_TONGXINSHU	= 2;	-- 游戏，采摘同心果
tbMiniGame.STEP_GAME_CAIBAOTU	= 3;	-- 游戏，幸运财宝兔

tbMiniGame.TB_GAME_NAME = {
	[tbMiniGame.STEP_GAME_DABAOZHU] = "大爆竹",
	[tbMiniGame.STEP_GAME_TONGXINSHU] = "摘取同心果",
	[tbMiniGame.STEP_GAME_CAIBAOTU] = "幸运财宝兔",
	};

tbMiniGame.CAIBAOTU_ITEM_GDPL = {18, 1, 608, 1};			-- 财宝兔道具gdpl
tbMiniGame.BAOXIANG_GDPL_SMALL = {18, 1, 610, 1};	-- 财宝兔兑换成的小宝箱gdpl
tbMiniGame.BAOXIANG_GDPL_BIG = {18, 1, 609, 1};		-- 财宝兔兑换成的大宝箱gdpl
tbMiniGame.TB_BOXINFO = {
	{nCount = 10, szName = "财神大宝箱", tbGDPL = {18, 1, 609, 1}},
	{nCount = 1, szName = "财神小宝箱", tbGDPL = {18, 1, 610, 1}},
	};

--==================================================================

-- 召唤出小游戏的管理者npc（福临门）
function tbMiniGame:CallMiniGameNpc(nMapId)
	local nWeddingMapLevel = Marry:GetWeddingMapLevel(nMapId);
	local tbPos = self.TB_POS_FULINMEN[nWeddingMapLevel];
	if (not tbPos) then
		return 0;
	end
	KNpc.Add2(self.FULINMEN_TEMPLATE_ID , 120, -1, nMapId, unpack(tbPos));
end

function tbMiniGame:CheckPlayer()
	local szErrMsg = "";
	local tbCoupleName = Marry:GetWeddingOwnerName(me.nMapId);
	if (2 ~= #tbCoupleName) then
		return 0, szErrMsg;
	end
	
	if (me.szName ~= tbCoupleName[1] and me.szName ~= tbCoupleName[2]) then
		szErrMsg = "请二位侠侣中的一人来开启游戏。";
		return 0, szErrMsg;
	end
	return 1;
end

function tbMiniGame:OnDialog(nNpcId)
	local szMsg = "这里真热闹啊！我也来助兴！\n我这有些小游戏，每种都可以玩一次，准备好了就请二位侠侣中的一人来开启游戏吧！";
	local tbOpt = {
		{"<color=yellow>开心大爆竹<color>", self.DabaozhuDlg, self},
		{"<color=yellow>采摘同心果<color>", self.TongxinguoDlg, self},
		{"<color=yellow>幸运财宝兔<color>", self.CaibaoTuDlg, self},
		{"兑换宝箱", self.Change2BoxDlg, self},
		};
	Dialog:Say(szMsg, tbOpt);
end

-- 获取当前进行到了第几个游戏
function tbMiniGame:GetCurStep(nMapId)
	return Marry:GetMiniGameStep(nMapId) or 0;
end

-- 设置当前进行到了第几个游戏
function tbMiniGame:SetCurStep(nMapId, nNewStep)
	return Marry:SetMiniGameStep(nMapId, nNewStep);
end

-- 进入下一个游戏环节
function tbMiniGame:NextStep(nMapId)
	local nCurStep = math.floor(self:GetCurStep(nMapId));
	self:SetCurStep(nMapId, nCurStep + 1);
end

-- 把当前的游戏环节设置为正在进行当中，在结束之前不能开始下一环节
function tbMiniGame:SetCurStepPlaying(nMapId)
	-- 加上0.5表示这个环节已经开始，但是还没有结束
	local nCurStep = math.floor(self:GetCurStep(nMapId)) + 0.5;
	self:SetCurStep(nMapId, nCurStep);
end

function tbMiniGame:CheckStep(nStep)
	local nCurStep = self:GetCurStep(me.nMapId);
	
	-- 当前已经有环节正在进行，不能开启下一个游戏
	if (math.mod(nCurStep, 1) ~= 0) then
		nCurStep = math.ceil(nCurStep);
		local szCurGame = self.TB_GAME_NAME[nCurStep];
		if (szCurGame) then
			Dialog:Say(string.format("小游戏<color=yellow>%s<color>正在进行当中，等当前游戏结束之后再玩下一个游戏吧。",
				szCurGame));
		end
		return 0;
	end
	
	-- 小游戏开启顺序不正确
	nCurStep = math.floor(nCurStep);
	if (nStep > self.STEP_GAME_CAIBAOTU) then
		Dialog:Say("所有小游戏都已经完成，祝您玩得愉快。");
		return 0;
	elseif (nStep < nCurStep + 1) then
		Dialog:Say("请注意：该小游戏已经结束。");
		return 0;
	elseif (nStep > nCurStep + 1) then
		Dialog:Say("请注意：小游戏需要按照顺序开启。");
		return 0;
	end
	return 1;
end

function tbMiniGame:DabaozhuDlg()
	local szMsg = "玩法：<color=yellow>请提前召集更多的人来这里！<color>二位侠侣开启游戏后，我旁边会出现一个爆竹，一分钟后爆出好东西，<color=green>爆竹周围的人越多，奖励越高！<color>\n你确定要开始这个游戏吗？";
	local tbOpt = {
		{"是的，开始游戏", self.DaBaozhu, self},
		{"等等，我先去叫人"},
		};
	Dialog:Say(szMsg, tbOpt);
end

-- 开心大爆竹
function tbMiniGame:DaBaozhu()
	local bCanOpenGame, szErrMsg = self:CheckPlayer();
	if (0 == bCanOpenGame) then
		if ("" ~= szErrMsg) then
			Dialog:Say(szErrMsg);
		end
		return 0;
	end
	
	if (self:CheckStep(self.STEP_GAME_DABAOZHU) ~= 1) then
		return 0;
	end
	
	self:SetCurStepPlaying(me.nMapId);
	local tbNpc = Npc:GetClass("marry_dabaozhu");
	tbNpc:OpenBaozhu(me.nMapId);
	self:SendGameStartMsg();
end

function tbMiniGame:TongxinguoDlg()
	local szMsg = "玩法：<color=yellow>请侠侣先准备好一个背包空位！<color>二位侠侣开启游戏后，我旁边会出现一棵树，<color=green>二位侠侣同时采摘，可获得同心果！<color>你确定要开始这个游戏吗？";
	local tbOpt = {
		{"是的，开始游戏", self.Tongxinguo, self},
		{"等等，我先准备一下"},
		};
	Dialog:Say(szMsg, tbOpt);
end

-- 采摘同心果
function tbMiniGame:Tongxinguo()
	local bCanOpenGame, szErrMsg = self:CheckPlayer();
	if (0 == bCanOpenGame) then
		if ("" ~= szErrMsg) then
			Dialog:Say(szErrMsg);
		end
		return 0;
	end
	
	if (self:CheckStep(self.STEP_GAME_TONGXINSHU) ~= 1) then
		return 0;
	end
	
	self:SetCurStepPlaying(me.nMapId);
	local tbNpc = Npc:GetClass("marry_tongxinshu");
	tbNpc:GameStart(me.nMapId);
	self:SendGameStartMsg();
end

function tbMiniGame:CaibaoTuDlg()
	local szMsg = "玩法：<color=yellow>请提前通知大家做好准备！<color>二位侠侣开启游戏后，典礼场地里会随机出现财宝兔，抓获兔子可获得钱袋。<color=green>钱袋可以在我这里兑换宝箱。<color>";
	local tbOpt = {
		{"是的，开始游戏", self.CaibaoTu, self},
		{"等等，我先准备一下"},
		};
	Dialog:Say(szMsg, tbOpt);
end

-- 幸运财宝兔
function tbMiniGame:CaibaoTu()
	local bCanOpenGame, szErrMsg = self:CheckPlayer();
	if (0 == bCanOpenGame) then
		if ("" ~= szErrMsg) then
			Dialog:Say(szErrMsg);
		end
		return 0;
	end
	
	if (self:CheckStep(self.STEP_GAME_CAIBAOTU) ~= 1) then
		return 0;
	end
	
	self:SetCurStepPlaying(me.nMapId);
	local tbNpc = Npc:GetClass("marry_caibaotu");
	tbNpc:StartGame(me.nMapId);
	self:SendGameStartMsg();
end

function tbMiniGame:Change2BoxDlg()
	local szMsg = "你可以参加幸运财宝兔活动，抓住兔子，得到钱袋。用钱袋来这里兑换宝箱。每个小宝箱需要1个钱袋，每个大宝箱需要10个钱袋。你确定要兑换吗？";
	local tbOpt = {
		{"兑换大宝箱", self.Change2Box, self, self.TB_BOXINFO[1]},
		{"兑换小宝箱", self.Change2Box, self, self.TB_BOXINFO[2]},
		{"一会再来吧"},
		};
	Dialog:Say(szMsg, tbOpt);
end

-- 用财宝兔兑换箱子（可以用10个兑换成一个大的，或者用1个兑换成小的）
function tbMiniGame:Change2Box(tbBoxInfo)
	local nOwnCount = me.GetItemCountInBags(unpack(self.CAIBAOTU_ITEM_GDPL));
	if (0 == nOwnCount) then
		Dialog:Say("你身上没有钱袋，不能兑换。参加典礼中的<color=yellow>“幸运财宝兔”<color>游戏可以获得钱袋。");
		return 0;
	end
	
	local szName = KItem.GetNameById(unpack(self.CAIBAOTU_ITEM_GDPL));
	if (nOwnCount < tbBoxInfo.nCount) then
		local szErrMsg = string.format("你的<color=yellow>%s<color>数量不足，兑换%s至少需要<color=yellow>%s<color>个钱袋。",
										szName, tbBoxInfo.szName, tbBoxInfo.nCount);
		Dialog:Say(szErrMsg);
		return 0;
	end
	
	if (me.CountFreeBagCell() < 1) then
		Dialog:Say("你的包裹空间不足，请清理出1格背包空间再来吧。");
		return 0;
	end
	
	local bRet = me.ConsumeItemInBags2(tbBoxInfo.nCount, unpack(self.CAIBAOTU_ITEM_GDPL));
	if (bRet ~= 0) then
		return 0;
	end
	
	me.AddItem(unpack(tbBoxInfo.tbGDPL));
end

function tbMiniGame:GetAllPlayers(nMapId)
	local tbPlayerList = Marry:GetAllPlayers(nMapId) or {};
	return tbPlayerList;
end

-- 给当前地图所有玩家信息，用来提示游戏开始
function tbMiniGame:SendMsg2MapPlayer(nMapId, szMsg)
	if (not nMapId or not szMsg) then
		return 0;
	end
	
	local tbPlayerList = self:GetAllPlayers(nMapId);
	for _, pPlayer in pairs(tbPlayerList) do
		Dialog:SendBlackBoardMsg(pPlayer, szMsg);
	end
end

function tbMiniGame:SendGameStartMsg()
	local nCurStep = self:GetCurStep(me.nMapId);
	nCurStep = math.ceil(nCurStep);
	local szCurGame = self.TB_GAME_NAME[nCurStep];
	local szMsg = string.format("小游戏<color=yellow>%s<color>开始了", szCurGame);
	self:SendMsg2MapPlayer(me.nMapId, szMsg);
end
