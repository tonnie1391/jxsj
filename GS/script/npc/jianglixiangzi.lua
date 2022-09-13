-------------------------------------------------------------------
--File: 	jianglixiangzi.lua
--Author: 	zhengyuhua
--Date: 	2008-9-21 11:30
--Describe: 箱子NPC脚本
-------------------------------------------------------------------
local tbXiangZiNpc	= {};
Npc.tbXiangZiNpc	= tbXiangZiNpc;
tbXiangZiNpc.NPC_TAMPLATE_ID	= 2700	-- 箱子NPC模板ID

-- nSubWorld: 		地图ID
-- nX:				x坐标，没乘32的
-- nY:				y坐标，没乘32的
-- nTakeTime:		拾取箱子所需要的进度条时间
-- tbParam:		（类似确定窗口的逻辑）
--		tbParam.tbTable: 			回调函数所在表	
--		tbParam.fnAwardFunction		箱子获取后的回调函数名，回调函数参数格式为fn(pPlayer, ...)
-- 		tbParam.tbParam:			[可选]不定参数表
-- nBagCell:		[可选参数]拾取箱子所需要的背包空间的要求,默认为1
-- nExistTime:		[可选参数]箱子生存时间，设定后到时间自动消失，否则直到有玩家采集后消失。
function tbXiangZiNpc:AddBox(nSubWorld, nX, nY, nTakeTime, tbParam, nBagCell, nExistTime)
	local pNpc = KNpc.Add2(self.NPC_TAMPLATE_ID, 10, -1, nSubWorld, nX, nY);
	if not pNpc then
		return;
	end
	local tbTemp = pNpc.GetTempTable("Npc");
	tbTemp.tbBoxData = {};
	tbTemp.tbBoxData.nTakeTime = nTakeTime;
	tbTemp.tbBoxData.nBagCell = nBagCell or 1;
	tbTemp.tbBoxData.tbTable = tbParam.tbTable;
	tbTemp.tbBoxData.fnAwardFunction = tbParam.fnAwardFunction;
	tbTemp.tbBoxData.tbParam = tbParam.tbParam;
	if nExistTime and nExistTime > 0 then
		tbTemp.tbBoxData.nTimerId = Timer:Register(
			nExistTime, 
			self.DelBox, self, pNpc.dwId
		)
	end
	return pNpc;
end

-- 删除箱子NPC
function tbXiangZiNpc:DelBox(nNpcId)
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		return 0;
	end
	local tbTemp = pNpc.GetTempTable("Npc");
	if tbTemp.tbBoxData and tbTemp.tbBoxData.nTimerId then
		Timer:Close(tbTemp.tbBoxData.nTimerId);
	end
	pNpc.Delete();
end

local tbJiangLiXiangZi = Npc:GetClass("jianglixiangzi");

function tbJiangLiXiangZi:OnDialog()
	local tbTemp = him.GetTempTable("Npc");
	if not tbTemp.tbBoxData then
		return 0;
	end
	if (me.CountFreeBagCell() < tbTemp.tbBoxData.nBagCell) then
		me.Msg("你的背包没有足够的空间。");
		return 0;
	end
	local tbEvent = 
	{
		Player.ProcessBreakEvent.emEVENT_MOVE,
		Player.ProcessBreakEvent.emEVENT_ATTACK,
		Player.ProcessBreakEvent.emEVENT_SIT,
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
	
	-- 进度条
	GeneralProcess:StartProcess(
		"", 
		tbTemp.tbBoxData.nTakeTime, 
		{self.CompleteProcess, self, him.dwId, me.nId}, 
		nil, 
		tbEvent
	);
end

-- 进度条读完，执行回调
function tbJiangLiXiangZi:CompleteProcess(nNpcId, nPlayerId)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		return 0;
	end
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		return 0;
	end
	local tbTemp = pNpc.GetTempTable("Npc");
	if tbTemp.tbBoxData then
		if tbTemp.tbBoxData.tbParam then
			tbTemp.tbBoxData.fnAwardFunction(tbTemp.tbBoxData.tbTable, pPlayer, unpack(tbTemp.tbBoxData.tbParam));
		else
			tbTemp.tbBoxData.fnAwardFunction(tbTemp.tbBoxData.tbTable, pPlayer);
		end
	end
	tbXiangZiNpc:DelBox(nNpcId);
end
