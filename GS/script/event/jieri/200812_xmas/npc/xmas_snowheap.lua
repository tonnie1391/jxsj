-------------------------------------------------------------------
--File: xmas_snowheap.lua
--Author: fenghewen
--Date: 2008-5-19 09:59
--Describe: 雪堆NPC脚本
-------------------------------------------------------------------
if  MODULE_GC_SERVER then
	return;
end
local tbSnowHeapNpc = Npc:GetClass("xmas_snowheap");
tbSnowHeapNpc.nNpcId = 3471;		-- 雪堆npc的Id  --待改
tbSnowHeapNpc.nDelayTime = 2;		-- 进度条读取秒数
--tbSnowHeapNpc.tbSnowItem = {18,1,537,1};		--小雪团
tbSnowHeapNpc.tbSnowItem = {22,1,45,1};		--小雪团

-- 打断拾取的事件
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

-- 功能: 拾取雪堆进度条，执行self.nDelayTime秒的延时
function tbSnowHeapNpc:OnDialog()
	local nCheck = SpecialEvent.Xmas2008:Check();
	if nCheck ~= 1 then
		Dialog:Say(string.format("好大一堆雪啊，但是我现在拿这个东西好像也没什么用。"));
		return 0;
	end	
	local tbTmp = him.GetTempTable("Npc");
	if tbTmp.nMaxUse and tbTmp.nMaxUse <= 0 then
		Dialog:Say(string.format("你找来找去，没发现任何小雪团。"));
		return 0;
	end
	local tbNpcTemp = him.GetTempTable("Npc");
	
	if not tbNpcTemp.tbPlayerList then
		tbNpcTemp.tbPlayerList = {};
	end
	local tbPlayerList = tbNpcTemp.tbPlayerList;
	if tbPlayerList[me.nId] == 1 then
		Dialog:Say("我好像已经拿捡到小雪团了，还是给他人留点吧。");
		return 0;
	end		
	if me.CountFreeBagCell() < 1 then
		me.Msg("你的背包空间不足!");
		return 0;
	end
	
	-- 进度条
	GeneralProcess:StartProcess("雪堆拾取中...", self.nDelayTime * Env.GAME_FPS, {self.DoPickUp, self, him.dwId}, nil, tbEvent);
end

function tbSnowHeapNpc:DoPickUp(nNpcId)
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		return 0;
	end
	local tbNpcTemp = pNpc.GetTempTable("Npc");
	
	if not tbNpcTemp.tbPlayerList then
		tbNpcTemp.tbPlayerList = {};
	end
	local tbPlayerList = tbNpcTemp.tbPlayerList;
	
	if tbPlayerList[me.nId] == 1 then
		Dialog:Say("我好像已经拿捡到小雪团了，还是给他人留点吧。");
		return 0;
	end
	
	if me.CountFreeBagCell() < 1 then
		Dialog:Say("你的背包空间不足!")
		return 0;
	end
	
	-- 给小雪团
	local nNum = MathRandom(1, 9);
	local nG, nD, nP, nL = unpack(self.tbSnowItem);
	me.AddStackItem(nG, nD, nP, nL, {bTimeOut=1}, nNum);
	tbPlayerList[me.nId] = 1;
	
	local tbTmp = pNpc.GetTempTable("Npc");
	if tbTmp.nMaxUse and tbTmp.nMaxUse <= 0 then
		tbTmp.nMaxUse = tbTmp.nMaxUse - 1;
	end
end
