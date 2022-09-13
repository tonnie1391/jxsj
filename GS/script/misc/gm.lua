-- 为了方便调试而建立一些函数
-- 重要注意事项：
--	1、常规、通用的函数不应该写在这里，这里的所有函数原则上不允许在游戏世界内调用。
--		原因：此文件可能会根据调试需要经常修改，所有的函数都有被破坏的可能。
--	2、本文件内可以按照全局的方式定义函数（实际上函数都在GM这个table内），使用时也可以当作全局使用
--		原因：为了方便，本文件采用了特殊方式模拟成了全局环境
function GM:DoCommand(szCmd)
	DoScript("\\script\\misc\\gm.lua");	-- 每次都重载这个脚本
	print("GmCmd["..tostring(me and me.szName).."]:", szCmd);
	
	local fnCmd, szMsg	= loadstring(szCmd, "[GmCmd]");
	if (not fnCmd) then
		error("Do GmCmd failed:"..szMsg);
	else
		setfenv(fnCmd, GM);
		return fnCmd();
	end
end

if (MODULE_GC_SERVER) then
	
GM.tbCommand = GM.tbCommand or {};	--自动执行指令  [szName] = {nDate, szFun}

--补偿接口start详细参数，考看\script\event\compensate\compensate_gm.lua
function GM:AddOnLine(szGate, szAccount, szName, nSDate, nEDate, szScript, bMsg)
	return SpecialEvent.CompensateGM:AddOnLine(szGate, szAccount, szName, nSDate, nEDate, szScript, bMsg);
end

function GM:AddOnNpc(szGate, szAccount, szName, nSDate, nEDate, tbAward)
	return SpecialEvent.CompensateGM:AddOnNpc(szGate, szAccount, szName, nSDate, nEDate, tbAward);
end

function GM:DelOnLine(szGate, szAccount, szName, nLogId, nGcManul, szResult)
	return SpecialEvent.CompensateGM:DelOnLine(szGate, szAccount, szName, nLogId, nGcManul, szResult);
end

function GM:DelOnNpc(szGate, szAccount, szName, nLogId, nGcManul, szResult)
	return SpecialEvent.CompensateGM:DelOnNpc(szGate, szAccount, szName, nLogId, nGcManul, szResult);
end

function GM:ClearDateOut()
	return SpecialEvent.CompensateGM:ClearDateOut();
end
--补偿接口end

-- 将玩家从桃源天牢释放
function GM:SetFree(szPlayerName)	
	GlobalExcute{"Player:SetFree", szPlayerName};
end
-- 将玩家抓入桃源天牢
function GM:Arrest(szPlayerName, nJailTerm)
	GlobalExcute{"Player:Arrest", szPlayerName, nJailTerm};
end

function GM:AddFriendFavorByHand(szAppName, szDstName, nFavor, nMethod)
	if (not szAppName or not szDstName or szAppName == szDstName or nFavor <= 0) then
		return;
	end
	local nAppId = KGCPlayer.GetPlayerIdByName(szAppName);
	local nDstId = KGCPlayer.GetPlayerIdByName(szDstName);
	local bByHand = 1;
	nMethod = nMethod or 0;
	local nCanAddFavor = Relation:CheckCanAddFavor(nAppId, nDstId, nFavor, nMethod);
	if (1 == nCanAddFavor) then
		KRelation.AddFriendFavor(nAppId, nDstId, nFavor, nMethod, bByHand);
		KRelation.SyncFriendInfo(nAppId, nDstId);
	end
end

-- 手工修改ib道具
-- tbWareInfo 需要修改的商品属性（需要修改哪些内容就写哪些内容，但是商品id必须写上，参考\\setting\\ibshop\\warelist.txt配置文件）
function GM:ModifyIBWare(tbWareInfo, bSave)
	if (not tbWareInfo) then
		return;
	end
	
	IbShop:SaveIbshopCmd(tbWareInfo, bSave or 1);
	return ModifyIBWare(tbWareInfo);
end

-- 在奇珍阁手工增加ib道具
-- tbWareInfo 需要添加的商品的信息（参考\\setting\\ibshop\\warelist.txt配置文件，另外，不需要写商品id，会自动分配）
function GM:AddIbWare(tbWareInfo)
	tbWareInfo = IbShop:PreEditIBWare(tbWareInfo);
	if (not tbWareInfo) then
		return;
	end
	
	return AddIBWare(tbWareInfo);
end

-- 从奇珍阁手工删除道具
-- tbWareInfo 要删除的商品信息 （仅需要填写商品id和商品所属的货币类型, \\setting\\ibshop\\warelist.txt配置文件）
function GM:DelIbWare(tbWareInfo, bSave)
	if (not tbWareInfo) then
		return;
	end
	
	return DelIBWare(tbWareInfo);
end

-- 获取奇珍阁所有商品信息
function GM:ShowAllWareInfo()
	local tbWareInfo = ShowAllWareInfo();
	Lib:ShowTB(tbWareInfo);
end

--存buf并执行
function GM:DoAndSaveBuf(szName, nDate, szFun)
	if self.tbCommand[szName] then
		return "名字为["..szName.."]的指令已经存在，请重新命名！";
	end
	if GetTime() > Lib:GetDate2Time(tonumber(nDate) or 0) then
		return "时间已过期，请检查指令执行结束时间。";
	end
	print("[DoAndSaveGmCmd]",szName, nDate, szFun);
	local fnCmd, szMsg	= loadstring(szFun, "[GmCmdAndSave]");
	if (not fnCmd) then
		return "DoAndSave GmCmd failed:"..szMsg;
	else
		fnCmd();
	end
	self.tbCommand[szName] = {nDate, szFun};
	SetGblIntBuf(GBLINTBUF_GMCOMMAND, 0, 1, self.tbCommand);
	return 1;
end

--7台服务器启动完毕执行
function GM:AutoDoCommand()
	local nNowTime = GetTime();
	for szName, tbCommandEx in pairs(self.tbCommand) do
		if nNowTime <= Lib:GetDate2Time(tbCommandEx[1]) then
			local fnCmd, szMsg	= loadstring(tbCommandEx[2], "[AutoDoGmCmd]");
			if (not fnCmd) then
				error("AutoDo GmCmd failed:"..szMsg);
			else
				fnCmd();
			end	
		else
			self.tbCommand[szName] = nil;
		end
	end
	SetGblIntBuf(GBLINTBUF_GMCOMMAND, 0, 1, self.tbCommand);
end

--重启loadbuf
function GM:LoadBuffer_GC()
	self.tbCommand = self.tbCommand or {};
	local tbBuffer = GetGblIntBuf(GBLINTBUF_GMCOMMAND, 0);
	if tbBuffer and type(tbBuffer) == "table" then
		self.tbCommand = tbBuffer;
	end	
end

GCEvent:RegisterGCServerStartFunc(GM.LoadBuffer_GC, GM);
else	-- if (MODULE_GC_SERVER) then

-- 搜索玩家所有空间查找物品
-- zhengyuhua: 不放在Item模块是因为不允许游戏正常逻辑使用，该指令会搜索回购空间
function GM:GMFindAllRoom(varItem)
	local tbResult = {};
	local tbRoom = {};
	Lib:MergeTable(tbRoom, Item.BAG_ROOM );
	Lib:MergeTable(tbRoom, Item.REPOSITORY_ROOM );
	Lib:MergeTable(tbRoom, {Item.ROOM_RECYCLE, Item.ROOM_EQUIP, Item.ROOM_EQUIPEX, Item.ROOM_EQUIPEX2});
	for _, nRoom in ipairs(tbRoom) do
		local tbFind;
		if type(varItem) == "string" then
			tbFind = me.FindClassItem(nRoom, varItem);
		elseif type(varItem) == "table" then
			tbFind = me.FindItem(nRoom, unpack(varItem));
		else
			Dbg:WriteLog("_GM_XF", "FindItemError", type(varItem), varItem);
		end
		if (tbFind) then
			for _, tbItem in ipairs(tbFind) do
				tbItem.nRoom = nRoom;
			end
			Lib:MergeTable(tbResult, tbFind);
		end
	end
	return tbResult;
end

-- 扣除玄晶
-- eg:
--local tbXuan = 
--{玄等级	不绑的数量  绑的数量
--	[6] = {		1,		1,		},
--	[7] = {		0,		3,		},
--}
function GM:ClearPlayerXuan(tbXuan)
	local tbXJ = self:GMFindAllRoom("xuanjing");
	for _, tbItem in pairs(tbXJ) do 
		local nL = tbItem.pItem.nLevel;
		if tbXuan[nL] and tbItem.pItem.IsBind() ~= 1 and tbXuan[nL][1] > 0 then 
			local nRet = me.DelItem(tbItem.pItem);
			if nRet == 1 then 
				tbXuan[nL][1] = tbXuan[nL][1] - 1;
				Dbg:WriteLog("_GM_XF", me.szName, "扣除1个"..nL.."玄(不绑)");
			end 
		elseif tbXuan[nL] and tbItem.pItem.IsBind() == 1 and tbXuan[nL][2] > 0 then
			local nRet = me.DelItem(tbItem.pItem);
			if nRet == 1 then 
				tbXuan[nL][2] = tbXuan[nL][2] - 1;
				Dbg:WriteLog("_GM_XF", me.szName, "扣除1个"..nL.."玄(绑定)");
			end 
		end 
	end
end


function GM:_ClearOneItem(pItem, bBind, nNum, fnCheck)
	local nCount = pItem.nCount
	local tbBindInfo = {[0] = "不绑定物品", [1] = "绑定物品"};
	if (nNum > 0) and (pItem.IsBind() == bBind) and 
		(not fnCheck or fnCheck(pItem) == 1) then
		local szName = pItem.szName;
		if nNum >= nCount then
			local nRet = me.DelItem(pItem);
			if nRet then
				nNum = nNum - nCount;
				Dbg:WriteLog("_GM_XF", me.szName, "扣除"..tbBindInfo[bBind], nCount.."个", szName);
			end
		else
			pItem.SetCount(nCount - nNum);
			Dbg:WriteLog("_GM_XF", me.szName, "扣除"..tbBindInfo[bBind], nCount.."个", szName);
			nNum = 0;
		end
	end
	return nNum;
end


-- 扣除某些物品
-- eg.1 GM:ClearPlayerItem("spritestone", 5000, 1000)
-- eg.2 GM:ClearPlayerItem({18,1,1,1}, 10, 1);
-- eg.3 local fn = function (pItem)
--			if pItem.nLevel > 1 then
--				return 1;
--			end
--			return 0;
--		end
--		GM:ClearPlayerItem("spritestone", 5000, 1000, fn);
function GM:ClearPlayerItem(varItem, nBindNum, nUnBindNum, fnCheck)
	local tbFind = self:GMFindAllRoom(varItem);
	for _, tbItem in ipairs(tbFind) do
		if nBindNum > 0 and tbItem.pItem.IsBind() == 1 then
			nBindNum = self:_ClearOneItem(tbItem.pItem, 1, nBindNum, fnCheck)
		elseif nUnBindNum > 0 and tbItem.pItem.IsBind() == 0 then
			nUnBindNum = self:_ClearOneItem(tbItem.pItem, 0, nUnBindNum, fnCheck)
		end
	end
	if nBindNum > 0 then
		Dbg:WriteLog("_GM_XF", me.szName, "剩余未扣除"..nBindNum.."个");
	end
	if nUnBindNum > 0 then
		Dbg:WriteLog("_GM_XF", me.szName, "剩余未扣除"..nUnBindNum.."个");
	end
	if nBindNum == 0 and nUnBindNum == 0 then
		Dbg:WriteLog("_GM_XF", me.szName, "扣除完全成功");
	end
end

-- 装备降等级
-- eg:
--local tbEquipToDegreade = 
--{Room		x		y		降级数量
--	{0, 	0, 		0, 		16},
--}
--GM:DegradeEquip(tbEquipToDegreade)
function GM:DegradeEquip(tbEquip)
	for _, tbPos in ipairs(tbEquip) do 
		local pEquip = me.GetItem(unpack(tbPos));
		if pEquip then 
			local nEnhTimes = math.max(0,pEquip.nEnhTimes - math.abs(tbPos[4]));
			pEquip.Regenerate(
				pEquip.nGenre,
				pEquip.nDetail,
				pEquip.nParticular,
				pEquip.nLevel,
				pEquip.nSeries,
				nEnhTimes,
				pEquip.nLucky,
				pEquip.GetGenInfo(),
				0,
				pEquip.dwRandSeed,
				0
			); 
			Dbg:WriteLog("_GM_XF", me.szName, pEquip.szName, "强化等级下降为"..pEquip.nEnhTimes.."级");
		end 
	end
end

-- 删除角色的银两、绑银、绑金
function GM:ClearMoney(nMoney, nBindMoney, nBindCoin)
	if me.CostMoney(nMoney, 0)==1 then
		Dbg:WriteLog("_GM_XF", me.szName, "成功扣银两 "..nMoney);
	else
		local nCurMoney = me.nCashMoney;
		me.CostMoney(nCurMoney);
		Dbg:WriteLog("_GM_XF", me.szName, "应扣银两 "..nMoney, "实扣"..nCurMoney);
	end
	
	if me.CostBindMoney(nBindMoney, Player.emKBINDMONEY_COST_GM) ==1 then
		Dbg:WriteLog("_GM_XF", me.szName, "成功扣绑银 "..nBindMoney);
	else
		local nCurMoney = me.GetBindMoney();
		me.CostBindMoney(nCurMoney, Player.emKBINDMONEY_COST_GM);
		Dbg:WriteLog("_GM_XF", me.szName, "应扣绑银 "..nBindMoney, "实扣"..nCurMoney);
	end 
	
	if me.AddBindCoin(-nBindCoin, Player.emKBINDCOIN_COST_GM) ==1 then
		Dbg:WriteLog("_GM_XF", me.szName, "成功扣绑金 "..nBindCoin);
	else
		local nCurMoney = me.nBindCoin;
		me.AddBindCoin(-nCurMoney, Player.emKBINDCOIN_COST_GM);
		Dbg:WriteLog("_GM_XF", me.szName, "应扣绑金 "..nBindCoin, "实扣"..nCurMoney);
	end 
end

-- 扣某个指定位置的物品
-- eg:
--local tbItem = 
--{Room		x		y
--	{0, 	0, 		0},
--}
--GM:DelPlayerRoomItem(tbItem)
function GM:DelPlayerRoomItem(tbItem)
	for _, tbRoom in ipairs(tbItem) do
		local pItem = me.GetItem(unpack(tbRoom));
		if pItem then
			local szName = pItem.szName;
			if me.DelItem(pItem) == 1 then
				Dbg:WriteLog("_GM_XF", me.szName, "扣除角色物品", szName);
			end
		else
			Dbg:WriteLog("_GM_XF", me.szName, "无法获取角色该位置的物品", unpack(tbRoom));
		end
	end
end

end		-- if (MODULE_GC_SERVER) then	else

-- 模拟全局环境
setmetatable(GM, {__index=_G});
setfenv(1, GM);

function GetRobot(nFromId, nToId)
	local tbAllPlayer	= KPlayer.GetAllPlayer();
	local tbRobot		= {};
	local nCount	= 0;
	nToId	= nToId or nFromId;
	for _, pPlayer in pairs(tbAllPlayer) do
		local szName	= pPlayer.szAccount;
		if (string.sub(szName, 1, 5) == "robot") then
			local nRobotId	= tonumber(string.sub(szName, 6));
			if (nRobotId and nRobotId >= nFromId and nRobotId <= nToId) then
				nCount	= nCount + 1;
				tbRobot[nRobotId]	= pPlayer;
			end
		end
	end
	
	return tbRobot, nCount;
end

function CallRobot(nFromId, nToId, nRange)
	local nMapId, nMapX, nMapY = me.GetWorldPos();
	local tbRobot, nCount	= GetRobot(nFromId, nToId);
	nRange	= nRange or 0;
	nMapX	= nMapX - nRange - 1;
	nMapY	= nMapY - nRange - 1;
	for _, pPlayer in pairs(tbRobot) do
		pPlayer.NewWorld(nMapId, nMapX + MathRandom(nRange * 2 + 1), nMapY + MathRandom(nRange * 2 + 1));
	end
	me.Msg(nCount.." robot(s) called!");
end

function PowerUp(nLevel)
	if (nLevel) then
		ST_LevelUp(nLevel);
	end
	me.AddFightSkill("梯云纵", 60);
	me.AddFightSkill("无形蛊", 60);
	me.Earn(10000000, 0);			-- 1000W银子
end

function BuildTong()
	me.SetCurCamp(4)
	SetCamp(4)
	SetTask(99, 1)
	CreateTong(1)
	-- 用于当长老
	AddLeadExp(10011100)
	--AddRepute(500)		-- TODO: xyf AddRepute 该指令已改，此处无效
end

function ShowOnline()
	me.Msg("Srv:["..GetServerName().."] Online:"..KPlayer.GetPlayerCount());
end
function ShowGMCmd()
	Say("GM Command List",7,"DoSct","RunSctFile","ReloadSct","ReloadAll","ShowGMCmd","GetPlayerInfo","Woooo!");
end

function RESTORE()
	me.RestoreMana();
	me.RestoreLife();
	me.RestoreStamina();
end

function CallNpc(varNpcIdOrName, nLevel, nSeries, nNoRevive, nGoldType, nNpcType)
	nNpcType = tonumber(nNpcType); --0为普通怪，1为精英，2为首领
	local w,x,y = me.GetWorldPos();
	local 	mapindex = SubWorldID2Idx(w);
	if (mapindex < 0 ) then
		me.Msg("Get MapIndex Error.");
		return
	end
	local nNpcId	= 0;
	if (type(varNpcIdOrName) == "string") then
		nNpcId	= KNpc.GetTemplateIdByName(varNpcIdOrName);
		if (nNpcId <= 0) then
			me.Msg("Npc:%s not found!", varNpcIdOrName);
			return;
		end
	else
		nNpcId	= varNpcIdOrName;
	end
	local nRet	= KNpc.Add2(nNpcId, nLevel or 1, nSeries or 0, w, x, y, nNoRevive or 1, nGoldType or 0)
	if nRet and nNpcType then
		nRet.ChangeType(nNpcType)
	end
	me.Msg("AddNpc:"..varNpcIdOrName.." ("..tostring(nRet)..")");
	return nRet;
end

function ShowTask(nGroup, nTaskId)
	me.Msg("Get task: "..me.GetTask(nGroup, nTaskId));
end

function CheckTask()
	local tbTask	= me.GetAllTask();
	local tbId		= {};
	for nId, nValue in pairs(tbTask) do
		tbId[#tbId+1]	= nId;
	end
	table.sort(tbId);
	local tbBack	= {};
	for _, nId in ipairs(tbId) do
		tbBack[#tbBack+1]	= {nId, tbTask[nId]};
	end
	tbBack[#tbBack+1]	= {0xffffffff, 0};	-- 保护
	
	local tbBackTask	= GM.tbBackTask or {};
	GM.tbBackTask		= tbBackTask;
	
	local tbBackOld	= tbBackTask[me.szName] or {{0xffffffff, 0}};
	local nIdx1	= 1;
	local nIdx2	= 1;
	local nCount	= math.max(#tbBackOld, #tbBack) - 1;
	local nDifCount	= 0;
	while (nIdx1 <= nCount and nIdx2 <= nCount) do
		local tbTask1	= tbBackOld[nIdx1];
		local tbTask2	= tbBack[nIdx2];
		local nId		= 0;
		local nValue1	= 0;
		local nValue2	= 0;
		if (tbTask1[1] > tbTask2[1]) then
			nId		= tbTask2[1];
			nValue2	= tbTask2[2];
			nIdx2	= nIdx2 + 1;
		elseif (tbTask1[1] < tbTask2[1]) then
			nId		= tbTask1[1];
			nValue1	= tbTask1[2];
			nIdx1	= nIdx1 + 1;
		else
			nId		= tbTask1[1];
			nValue1	= tbTask1[2];
			nValue2	= tbTask2[2];
			nIdx1	= nIdx1 + 1;
			nIdx2	= nIdx2 + 1;
		end
		if (nValue1 ~= nValue2) then
			nDifCount	= nDifCount + 1;
			print(string.format("%d,%d\t%d => %d", math.floor(nId/65536), math.mod(nId,65536), nValue1, nValue2));
		end
	end	
	
	print("Different Count:", nDifCount);
	tbBackTask[me.szName]	= tbBack;
end


-- 随机加一个任务卷轴
function AddScrollTask()
	ScrollTask:AddScroll();
end

-- 根据传入的任务 ID 加一个卷轴
function AddScrollTaskByNum(szNum)
	szNum = tonumber(szNum, 16);
	ScrollTask:AddScroll(szNum);
end

-- 触发一个随机任务
function StartRandomTask(nTaskId)
	RandomTask:OnStart();
end

-- 显示玩家当前的坐标 mapid, x, y
function ShowWorldPos()
	local nMapId, nMapX, nMapY = me.GetWorldPos();
	me.Msg(string.format("%d,\t%d,\t%d", nMapId, nMapX, nMapY));
end

-- 输出玩家当前的坐标 mapid, x, y 到文件
function OutputWorldPos(szPosName)
	if (szPosName == nil) then
		szPosName = "";
	end
	
	local nMapId, nMapX, nMapY = me.GetWorldPos();
	me.Msg(string.format("<color=yellow>%s<color>:\t%d,\t%d,\t%d", szPosName, nMapId, nMapX, nMapY));
	
	if (g_szPosOutputFileKey == nil) then
		g_szPosOutputFileKey = "pos_output";
		if (KFile.TabFile_Load("\\log\\pos_output.txt", g_szPosOutputFileKey, "true") ~= 1) then
			me.Msg("打开\\log\\pos_output.txt文件失败");
			return;
		end
	end
	local nFileRowCount = KFile.TabFile_GetRowCount(g_szPosOutputFileKey);
	if (nFileRowCount == 0) then
		KFile.TabFile_SetCell(g_szPosOutputFileKey, 1, 1, "POS_NAME");
		KFile.TabFile_SetCell(g_szPosOutputFileKey, 1, 2, "MAP_ID");
		KFile.TabFile_SetCell(g_szPosOutputFileKey, 1, 3, "MAP_X");
		KFile.TabFile_SetCell(g_szPosOutputFileKey, 1, 4, "MAP_Y");
		KFile.TabFile_SetCell(g_szPosOutputFileKey, 1, 5, "MINIMAP_X");
		KFile.TabFile_SetCell(g_szPosOutputFileKey, 1, 6, "MINIMAP_Y");
		nFileRowCount = 1;
	end
	local nPosNameRow = KFile.TabFile_Search(g_szPosOutputFileKey, 1, szPosName, 1);
	if (nPosNameRow <= 0) then
		nPosNameRow = nFileRowCount + 1;
	end
	KFile.TabFile_SetCell(g_szPosOutputFileKey, nPosNameRow, 1, szPosName);
	KFile.TabFile_SetCell(g_szPosOutputFileKey, nPosNameRow, 2, nMapId);
	KFile.TabFile_SetCell(g_szPosOutputFileKey, nPosNameRow, 3, nMapX);
	KFile.TabFile_SetCell(g_szPosOutputFileKey, nPosNameRow, 4, nMapY);
	KFile.TabFile_SetCell(g_szPosOutputFileKey, nPosNameRow, 5, math.floor(nMapX / 8));
	KFile.TabFile_SetCell(g_szPosOutputFileKey, nPosNameRow, 6, math.floor(nMapY / 16));
	KFile.TabFile_Save(g_szPosOutputFileKey);
end

function LPAI(nCount)
	if (nCount < 1) then
		me.Msg("个数不对");
		return;
	end
	for i=1, nCount do
		me.AddItem(18, 1, 79, 1);
	end
end

-- 调用旧临时道具
function TI(nSelect)
	local tbItem	= Item:GetClass("tempitem");
	if (nSelect == 1) then
		tbItem:OnTransPak(tbItem.tbMap);
	elseif (nSelect == 2) then
		tbItem:OnSkillPak();
	elseif (nSelect == 3) then
		GM.tbPlayer:Main();
	else
		Dialog:Say("-= 临时道具 =-\n\n顶~~<pic=47>",
			{"传送包", TI, 1},
			{"技能包", TI, 2},
			{"玩家包", TI, 3},
			{"Kết thúc đối thoại"}
		);
	end
end

-- 宋金调试
function sj()
	Battle:GM();
end

function KickOutAccount()
	
end

function Msg2Player(varValue)
	me.Msg(tostring(varValue))
end

function M(...)
	me.Msg(Lib:ConcatStr(arg))
end

function LoadLevelLadder()
	GCExcute({"Ladder:LoadLevelLadder"});
end

function SetGongXun()
	GCExcute({"Battle:UpdateRank"});
end

function GetLadder(nType)
	local tbLadder, szContext = GetShowLadder(nType);
	if (not tbLadder) then
		print("没有排行榜");
		return;
	end
	print("szContext = ", szContext);
	for key, value in pairs(tbLadder) do
		print(key);
		if (value) then
			for ke, pv in pairs(value) do
				print(ke, pv);
			end
		end
	end
end

function ShowMapStat()
	local tbPlayer = KPlayer.GetAllPlayer();
	local tbCount = {};
	for _, pPlayer in pairs(tbPlayer) do
		local nMapId = pPlayer.nMapId;
		local nCount = tbCount[nMapId] or 0;
		tbCount[nMapId] = nCount + 1;
	end
	for nMapId, nCount in pairs(tbCount) do
		print("Map["..nMapId.."]: ", nCount, GetMapNameFormId(nMapId));
	end
end

function _linktask(n)
	me.ChangeCurMakePoint(1000000);
	me.ChangeCurGatherPoint(1000000);
	for i=1, n do
		for j=2, 18, 2 do
			for k=1, 3 do
				me.AddItem(22, 1, j, k);
			end
		end 
	end
	for n=1,10 do 
		LifeSkill:SetSkillLevel(me, n, 100) 
	end
	for i=1, n do
		for j=66, 68 do
			for k=1, 4 do
				me.AddItem(18,1,j,k);
			end
		end
	end
end

function _stlt(level, year, month, day, hour, min)
	local tbDate = { year = year,month = month,day = day,hour = hour or 0, min = min or 0};
	local nSecTime =  Lib:GetSecFromNowData(tbDate);
	Player.tbOffline.tbOpenLevelLimitTime[level] = nSecTime;
end

function _ofl()
	Player.tbOffline:GM();
end

function _gett(nTime)
	local tbDate = os.date("*t", nTime);
	print("========================")
	for key, value in pairs(tbDate) do
		print("key, value = ", key, value);
	end
	print("========================")
end

function AddDNews(nKey, szTitle, szMsg, nEndTime)
	local nTime = GetTime() + nEndTime; 
	Task.tbHelp:AddDNews(nKey, szTitle, szMsg, nTime, GetTime());
end


function AddMyManPaiNew()
	if (me.nFaction <= 0) then
		me.Msg("还没加入门派");
		return;
	end
	GCExcute({"FactionBattle:InitFactionNewsTable"});
	GCExcute({"FactionBattle:RecNewsForNewsMan", me.nFaction, me.szName});
end

function AddMyDa()
	if (me.nFaction <= 0) then
		me.Msg("还没加入门派");
		return;
	end
	local tbManPai = {};
	tbManPai[me.nFaction] = me.szName;
	GCExcute({"FactionElect:RecNewsForMenPaiDaShiXiong", tbManPai});
end

function GetProcInfo(bWithConInfo)
	local tbConInfo = {};
	if (bWithConInfo == 1) then
		for _, tb in ipairs(GetConInfo()) do
			local tbP = tbConInfo[tb.nProcessId] or {};
			tbConInfo[tb.nProcessId] = tbP;
			if (tb.szType == "TCP") then
				tbP[#tbP + 1] = string.format("TCP %s:%d [%s]",
					tb.szRemoteIp, tb.nRemotePort, string.sub(tb.szState, 15));
			elseif (tb.szType == "UDP") then
				tbP[#tbP + 1] = string.format("UDP %s:%d",
					tb.szLocalIp, tb.nLocalPort);
			end
		end
	end
	local tbProInfo = {};
	for _, tb in ipairs(GetProcessInfo()) do
		tbProInfo[tb.nProcessId] = {
			Name = tb.szName,
			Con = tbConInfo[tb.nProcessId],
		};
		tbConInfo[tb.nProcessId] = nil;
	end
	for nProcessId, tb in ipairs(tbConInfo) do
		tbProInfo[nProcessId] = {
			Con = tb,
		};
	end
	return tbProInfo;
end

--踢玩家下线
function GM:KickOut(szName, szReson)
	local nId = KGCPlayer.GetPlayerIdByName(szName);
	if not nId or nId <= 0 then
		return szName.." rolename is not exist";
	end	
	if (MODULE_GC_SERVER) then
		return GlobalExcute{"GM:KickOut", szName, szReson};
	else	
		local pPlayer=KPlayer.GetPlayerObjById(nId);
		if pPlayer then
			if (szReson) then
				pPlayer.PlayerLog(Log.emKPLAYERLOG_TYPE_GM_OPERATION, szReson);
			end
			pPlayer.KickOut();
		end
	end
end

--超级踢玩家下线，根据帐号名，用于卡号bishop的情况
function GM:KickOutByAccount(szAccountName)
	if (not MODULE_GC_SERVER) then
		return;
	end
	-- 踢出该帐号下的所有角色
	local tbRoles = GetRolesByAccount(szAccountName);
	if (tbRoles) then
		for _, szRoleName in pairs(tbRoles) do
			if (GCGetPlayerOnlineServer(szRoleName) ~= 0) then			-- 角色在线，踢出
				return self:KickOut(szRoleName);	-- 在线踢出就不用从bishop踢了，正常的踢出流程
			end
		end
	end
	-- 从bishop里面踢出
	return KickoutFromBishop(szAccountName);	
end


function GM:DoClientCmd(szType, szCmd)
	me.CallServerScript({"LogMsg", szType, assert(loadstring(szCmd))()});
end

function GM:OnCallClient(nRegId, ...)
	me.CallServerScript({"ClientCallBack", nRegId, Lib:PCall(...)});
end
