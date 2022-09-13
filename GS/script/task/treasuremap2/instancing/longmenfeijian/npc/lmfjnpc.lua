-- 文件名　：lmfjnpc.lua
-- 创建者　：zhangjunjie
-- 创建时间：2011-10-27 19:40:54
-- 描述：npc

local tbEvent = 
{
	Player.ProcessBreakEvent.emEVENT_MOVE,
	Player.ProcessBreakEvent.emEVENT_ATTACK,
	Player.ProcessBreakEvent.emEVENT_SITE,
	Player.ProcessBreakEvent.emEVENT_USEITEM,
	Player.ProcessBreakEvent.emEVENT_ARRANGEITEM,
	Player.ProcessBreakEvent.emEVENT_DROPITEM,
	Player.ProcessBreakEvent.emEVENT_SENDMAIL,
	Player.ProcessBreakEvent.emEVENT_TRADE,
	Player.ProcessBreakEvent.emEVENT_CHANGEFIGHTSTATE,
	Player.ProcessBreakEvent.emEVENT_CLIENTCOMMAND,
	Player.ProcessBreakEvent.emEVENT_LOGOUT,
	Player.ProcessBreakEvent.emEVENT_DEATH,
}

-------------荆棘林入口npc
local tbStep2EnterNpc = Npc:GetClass("lmfj_step2_enter");

function tbStep2EnterNpc:OnDialog()
	local pGame = TreasureMap2:GetInstancing(me.nMapId); --获得对象
	if not pGame then
		return 0;
	end
	local pRoom = pGame.tbRoom;
	if not pRoom then
		return 0;
	end
	if pRoom.nStepId ~= 2 then
		return 0;
	end
	local szMsg = "    Yên Thu Thảo... Kim Ngọc Thảo... Mạc Ngôn Hoa... Lạc Ảnh Hoa... Kiếm Thảo... Haha...\n    Nếu không tìm được, đừng mong qua khỏi Rừng Gai."
	Dialog:Say(szMsg,{"Ta hiểu rồi"});
end


--------------草药
local tbStep2Grass = Npc:GetClass("lmfj_step2_grass");

function tbStep2Grass:OnDialog()
	local pGame = TreasureMap2:GetInstancing(me.nMapId); --获得对象
	if not pGame then
		return 0;
	end
	local pRoom = pGame.tbRoom;
	if not pRoom then
		return 0;
	end
	if pRoom.nStepId ~= 2 then
		return 0;
	end
	GeneralProcess:StartProcess("Đang thu thập...", 1 * Env.GAME_FPS, {self.GetGrass,self,him.dwId},nil,tbEvent);
end

function tbStep2Grass:GetGrass(nNpcId)
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		return 0;
	end
	local pGame = TreasureMap2:GetInstancing(me.nMapId); --获得对象
	if not pGame then
		return 0;
	end
	local pRoom = pGame.tbRoom;
	if not pRoom then
		return 0;
	end
	if pRoom.nStepId ~= 2 then
		return 0;
	end
	local tbItem = pRoom.tbGrassItem[pNpc.nTemplateId];
	if not tbItem then
		return 0;
	end
	if me.CountFreeBagCell() < 1 then
		local szMsg = "Hành trang không đủ chỗ trống.";
		me.Msg(szMsg);
		return 0;
	end
	local pItem = me.AddItem(unpack(tbItem));	--加草药
	if pItem then
		Dialog:SendBlackBoardMsg(me,"Ở lối ra có một lư hưng, đặt thảo dược vào để tinh luyện...");
		pNpc.Delete();
	end
end

---------------收集草药的瓶子
local tbStep2Bottle = Npc:GetClass("lmfj_step2_bottle");

tbStep2Bottle.tbInputGDPL = --需要放入的材料gdpl
{
	"18,1,1510,1",	
	"18,1,1510,2",
	"18,1,1510,3",
	"18,1,1510,4",
	"18,1,1510,5",
};

function tbStep2Bottle:OnDialog()
	local szMsg = string.format("    Hãy đặt 5 loại thảo dược khác nhau (<color=yellow>Yên Thu Thảo, Kim Ngọc Thảo, Mạc Ngôn Hoa, Lạc Ảnh Hoa, Kiếm Thảo<color>), chế tạo xong là có thể tiến vào!");
	local tbOpt = {};
	tbOpt[#tbOpt + 1] = {"Cho thảo dược vào",self.InputMaterial,self,him.dwId};
	tbOpt[#tbOpt + 1] = {"Ta hiểu rồi"};
	Dialog:Say(szMsg,tbOpt);
end


function tbStep2Bottle:InputMaterial()
	local pGame = TreasureMap2:GetInstancing(me.nMapId); --获得对象
	if not pGame then
		return 0;
	end
	local pRoom = pGame.tbRoom;
	if not pRoom then
		return 0;
	end
	local tbHasGiveItem = pRoom.tbHasGiveGrass;
	if pRoom.nNeedGrassCount - #tbHasGiveItem <= 0 then
		Dialog:Say(string.format("Nhóm đã thu thập %s loại thảo dược rồi, hãy tiếp tục tìm kiếm.",pRoom.nNeedGrassCount),{"Ta hiểu rồi"});
		return 0;
	end
	local szNeed = "";
	for szName,nNeed in pairs(pRoom.tbGiveGrassName) do
		if nNeed == 1 then
			szNeed = szNeed .. szName .. "，";
		end
	end
	szNeed = string.sub(szNeed,1,-3);
	local szMsg = string.format("Bạn đã thu thập %d loại thảo dược, vẫn còn <color=yellow>%s loại<color>, hãy tìm chúng trong Rừng Gai",#tbHasGiveItem,szNeed);
	Dialog:OpenGift(szMsg, nil, {self.OnInputMaterial,self,him.dwId});
end

function tbStep2Bottle:CheckCanDel(szGDPL)
	if not szGDPL or #szGDPL == 0 then
		return 0;
	end
	local bCanDel = 0;
	for _,sz in pairs(self.tbInputGDPL) do
		if sz == szGDPL then
			bCanDel = 1;
			break;
		end
	end
	return bCanDel;
end

function tbStep2Bottle:OnInputMaterial(nNpcId,tbItemObj)
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		return 0;
	end
	local pGame = TreasureMap2:GetInstancing(me.nMapId); --获得对象
	if not pGame then
		return 0;
	end
	local pRoom = pGame.tbRoom;
	local nRoomId = pRoom.nStepId;
	if not pRoom or nRoomId ~= 2 then
		return 0;
	end
	for nCount, pItem in pairs(tbItemObj) do
		local szGDPL = pItem[1].SzGDPL();
		local szName = pItem[1].szName;
		local nIsExisted = 0;
		for _,szGrass in pairs(pRoom.tbHasGiveGrass) do
			if szGDPL == szGrass then
				nIsExisted = 1;
				break;
			end
		end
		if self:CheckCanDel(szGDPL) == 1 then
			if nIsExisted ~= 1 then
				table.insert(pRoom.tbHasGiveGrass,szGDPL);
				pRoom.tbGiveGrassName[szName] = 0;
			end
			me.DelItem(pItem[1], 0);
		end
	end
	pRoom:ProcessGrass();
end

-----------------------------------------第三关接引人
local tbStep3EnterNpc = Npc:GetClass("lmfj_step3_enter");

function tbStep3EnterNpc:OnDialog()
	local pGame = TreasureMap2:GetInstancing(me.nMapId); --获得对象
	if not pGame then
		return 0;
	end
	local pRoom = pGame.tbRoom;
	if not pRoom then
		return 0;
	end
	if pRoom.nStepId ~= 2 then	--开启后nStepId为3，就不能再开第二次了
		return 0;
	end
	pRoom:ProcessStep3();
end

------------------------------------------第三关骨头
local tbStep3Bone = Npc:GetClass("lmfj_step3_bone");

function tbStep3Bone:OnDialog()
	local pGame = TreasureMap2:GetInstancing(me.nMapId); --获得对象
	if not pGame then
		return 0;
	end
	local pRoom = pGame.tbRoom;
	if not pRoom then
		return 0;
	end
	GeneralProcess:StartProcess("Đang giải độc...", 1 * Env.GAME_FPS, {self.RemoveBuff,self,him.dwId},nil,tbEvent);
end


function tbStep3Bone:RemoveBuff(nNpcId,nPlayerId)
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		return 0;
	end
	--判断buff，清楚buff,删掉npc
	if me.GetSkillState(2407) > 0 then
		me.RemoveSkillState(2407);
	end
end


--------------------------第四关接引人
local tbStep4EnterNpc = Npc:GetClass("lmfj_step4_enter");

function tbStep4EnterNpc:OnDialog()
	local pGame = TreasureMap2:GetInstancing(me.nMapId); --获得对象
	if not pGame then
		return 0;
	end
	local pRoom = pGame.tbRoom;
	if not pRoom then
		return 0;
	end
	local tbOrder = pRoom.tbNeedOpenStep4Order;
	local szOrder = "";
	for i = 1 ,#tbOrder do
		szOrder = szOrder .. pRoom.tbSwitchName[tbOrder[i]] .. ", ";
	end
	szOrder = string.sub(szOrder,1,-3);
	local szMsg = string.format("    Phía trước là một mê cung, dựa theo <color=yellow>%s<color>. Mở theo thứ tự để có thể vượt qua\n    Những người đến trước đây đã bị quái vật ăn thịt <color=yellow>Hãy tiêu diệt quái vật trước để có thể thấy được kho báu và các cơ quan.<color>",szOrder);
	Dialog:Say(szMsg,{"Ta hiểu rồi"});
end

--------------------------------------机关
local tbStep4Switch = Npc:GetClass("lmfj_step4_switch");

function tbStep4Switch:OnDialog()
	local pGame = TreasureMap2:GetInstancing(me.nMapId); --获得对象
	if not pGame then
		return 0;
	end
	local pRoom = pGame.tbRoom;
	if not pRoom then
		return 0;
	end
	if pRoom.nStepId ~= 4 then
		return 0;
	end
	GeneralProcess:StartProcess("Đang mở...", 3 * Env.GAME_FPS, {self.OpenSwitch,self,him.dwId,me.nId},nil,tbEvent);
end

function tbStep4Switch:OpenSwitch(nNpcId,nPlayerId)
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		return 0;
	end
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		return 0;
	end
	local pGame = TreasureMap2:GetInstancing(pPlayer.nMapId); --获得对象
	if not pGame then
		return 0;
	end
	local pRoom = pGame.tbRoom;
	if not pRoom then
		return 0;
	end
	KTeam.Msg2Team(pPlayer.nTeamId, string.format("<color=yellow>%s<color> đã mở cơ quan <color=yellow>“%s”<color>",pPlayer.szName,pNpc.szName));	
	pRoom:ProcessOpenSwitch(nNpcId,pPlayer.szName);
end

----------------------------------------------------宝箱
local tbStep4Box = Npc:GetClass("lmfj_step4_box");

tbStep4Box.tbBoxAward = 
{
	[1] = {10000,{500,3600}},	
	[2] = {20000,{2900,14900}},
	[3] = {30000,{5000,16500}},
};

function tbStep4Box:OnDialog()
	local pGame = TreasureMap2:GetInstancing(me.nMapId); --获得对象
	if not pGame then
		return 0;
	end
	local pRoom = pGame.tbRoom;
	if not pRoom then
		return 0;
	end
	if pGame.tbOpenBoxPlayer[me.nId] and pGame.tbOpenBoxPlayer[me.nId] >= pRoom.nOpenBoxMaxCount then
		me.Msg(string.format("Bạn đã mở %s bảo rương, đừng tham lam quá.",pRoom.nOpenBoxMaxCount));
		return 0;
	end
	GeneralProcess:StartProcess("Đang mở...", 3 * Env.GAME_FPS, {self.OpenBox,self,him.dwId,me.nId},nil,tbEvent);
end

function tbStep4Box:OpenBox(nNpcId,nPlayerId)
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		return 0;
	end
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		return 0;
	end
	local pGame = TreasureMap2:GetInstancing(pPlayer.nMapId); --获得对象
	if not pGame then
		return 0;
	end
	local pRoom = pGame.tbRoom;
	if not pRoom then
		return 0;
	end
	local tbAward = self.tbBoxAward[pGame.nTreasureLevel];
	if not tbAward then
		return 0;
	end
	local nExp = tbAward[1];
	local tbBindMoney = tbAward[2];
	pGame:AddOpenBoxPlayer(nPlayerId);	--记录开过的玩家
	if nExp then
		pPlayer.AddExp(nExp);
	end
	if tbBindMoney then
		local nGiveMoney = MathRandom(tbBindMoney[1],tbBindMoney[2]);
		if pPlayer.GetBindMoney() + nGiveMoney <= pPlayer.GetMaxCarryMoney() then
			pPlayer.AddBindMoney(nGiveMoney);
		end
	end
	if pNpc.GetTempTable("TreasureMap2").nMaxOpenedCount >= pRoom.nBoxOpenedMaxCount then
		pNpc.Delete();
	end
	return 1;
end

---------------------第5关去除buff的npc
local tbStep5Grass = Npc:GetClass("lmfj_step5_grass");

function tbStep5Grass:OnDialog()
	local pGame = TreasureMap2:GetInstancing(me.nMapId); --获得对象
	if not pGame then
		return 0;
	end
	local pRoom = pGame.tbRoom;
	if not pRoom then
		return 0;
	end
	if pRoom.nStepId ~= 5 then
		return 0;
	end
	--判断buff，清楚buff
	if me.GetSkillState(2410) <= 0 then
		return 0;
	end
	GeneralProcess:StartProcess("Đang hóa giải...", 1 * Env.GAME_FPS, {self.RemoveBuff,self,him.dwId},nil,tbEvent);
end


function tbStep5Grass:RemoveBuff(nNpcId)
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		return 0;
	end
	--判断buff，清楚buff
	if me.GetSkillState(2410) > 0 then
		me.RemoveSkillState(2410);
	end
end


---------------------传入npc
local tbStep7TransferNpc = Npc:GetClass("lmfj_step7_transfer");

function tbStep7TransferNpc:OnDialog()
	local pGame = TreasureMap2:GetInstancing(me.nMapId); --获得对象
	if not pGame then
		return 0;
	end
	local pRoom = pGame.tbRoom;
	if not pRoom then
		return 0;
	end
	if pRoom.nStepId ~= 7 then
		return 0;
	end
	local tbPos = pRoom.tbTransferPos;
	if not tbPos then
		return 0;
	end
	local szMsg = "Bạn muốn vào Quán trọ Long Môn sao?"
	local tbOpt = {};
	tbOpt[#tbOpt + 1] = {"Đúng vậy, hãy đưa ta qua",self.Transfer,self,pGame.nMapId,tbPos};
	tbOpt[#tbOpt + 1] = {"Để ta suy nghĩ thêm"};
	Dialog:Say(szMsg,tbOpt);
end

function tbStep7TransferNpc:Transfer(nMapId,tbPos)
	if not nMapId or not tbPos then
		return 0;
	end
	me.NewWorld(nMapId,tbPos[1],tbPos[2]);	--传送到室内
	Player:AddProtectedState(me,3);	--加个3秒保护时间
end

---------------路路通
local tbLulutong = Npc:GetClass("lmfj_llt");

tbLulutong.tbTransferPos =
{
	[1] = {},
	[2] = {},
	[3] = {"Cô Lâu Huyệt",{47104/32,99488/32}},
	[4] = {},
	[5] = {"Tân Nguyệt Lục Châu",{47424/32,89056/32}},
	[6] = {},
	[7] = {"Long Môn Tiêu Cục",{50496/32,92608/32}},
};

function tbLulutong:OnDialog()
	local pGame = TreasureMap2:GetInstancing(me.nMapId); --获得对象
	if not pGame then
		return 0;
	end
	local pRoom = pGame.tbRoom;
	if not pRoom then
		return 0;
	end
	local nStepId = pRoom.nStepId;
	if not nStepId then
		return 0;
	end
	local tbInfo = {};
	for i = 1 , nStepId do
		if #self.tbTransferPos[i] ~= 0 then
			table.insert(tbInfo,self.tbTransferPos[i]);
		end
	end
	if #tbInfo <= 0 then
		local szMsg = "    Chào đại hiệp, quãng đường đại hiệp muốn đến không xa, hãy dùng chiến mã của ngươi nhé!";
		Dialog:Say(szMsg,{"Ta hiểu rồi"});
		return 0;
	else
		local szMsg = "    Ngươi muốn đi đâu? Hãy nói cho ta biết";
		local tbOpt = {};
		for _,tbPos in ipairs(tbInfo) do 
			tbOpt[#tbOpt + 1] = {"Hãy đưa ta đến <color=yellow>" .. tbPos[1] .. "<color>",self.Transfer,self,pGame.nMapId,tbPos[2]};
		end
		tbOpt[#tbOpt + 1] = {"Để ta đi ngựa vậy"};
		Dialog:Say(szMsg,tbOpt);
		return 0;
	end
end


function tbLulutong:Transfer(nMapId,tbPos)
	if not nMapId or not tbPos then
		return 0;
	end
	me.NewWorld(nMapId,tbPos[1],tbPos[2]);
	Player:AddProtectedState(me,3);	--加个3秒保护时间
end