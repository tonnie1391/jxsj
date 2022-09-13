-------------------------------------------------------
-- 文件名　：qinshihuang_gc.lua
-- 创建者　：zhangjinpin@kingsoft
-- 创建时间：2009-06-20 14:31:21
-- 文件描述：
-------------------------------------------------------

Require("\\script\\boss\\qinshihuang\\qinshihuang_def.lua");

if (not MODULE_GC_SERVER) then
	return 0;
end

local tbQinshihuang = Boss.Qinshihuang;

function Boss:OpenQinFive()
	local szMsg = "随着日月星辰的置换，秦陵第五层的大门缓缓开启了……";
	tbQinshihuang:BroadCast_GC(szMsg, tbQinshihuang.MSG_CHANNEL);
	tbQinshihuang:BroadCast_GC(szMsg, tbQinshihuang.MSG_BOTTOM);
	GlobalExcute{"Boss.Qinshihuang:DoOpenQinFive"};
end

function Boss:CloseQinFive()
	local szMsg = "勇士们经过了短暂的探索后，秦陵第五层的大门缓缓关闭了……";
	tbQinshihuang:BroadCast_GC(szMsg, tbQinshihuang.MSG_CHANNEL);
	tbQinshihuang:BroadCast_GC(szMsg, tbQinshihuang.MSG_BOTTOM);
	GlobalExcute{"Boss.Qinshihuang:DoCloseQinFive"};
end

function Boss:CloseQinSystem()
	GlobalExcute{"Boss.Qinshihuang:_CloseSystem"};
end

function Boss:OpenQinSystem()
	GlobalExcute{"Boss.Qinshihuang:_OpenSystem"};
end

function Boss:UpdateQinBoss()
	
	local tbData = {};
	local tbTimer = {};
	local tbMapId = {1536, 1537, 1538, 1539};
	
	local i;
	for i = 1, 4 do 
		
		local nRand = MathRandom(1, 2400);
		local tbMap = Boss.Qinshihuang.tbSmallBossPos[tbMapId[i]];
	
		if tbMap and #tbMap > 0 then
			local nIndex = MathRandom(1, #tbMap);
			tbTimer[i] = Timer:Register(nRand * Env.GAME_FPS, tbQinshihuang.OnTimerCallBoss, tbQinshihuang, tbMapId[i], nIndex);
			tbData[i] = {nTime = nRand, nIndex = nIndex};
		end	
	end
end

function tbQinshihuang:OnTimerCallBoss(nMapId, nIndex)

	local tbMap = self.tbSmallBossPos[nMapId];
	if not tbMap or not tbMap[nIndex] or #tbMap <= 0 then
		return 0;
	end
	
	local nTemplateId = tbMap[nIndex].nTemplateId;
	local nMapX = tbMap[nIndex].nMapX;
	local nMapY = tbMap[nIndex].nMapY;
	
	GlobalExcute{"Boss.Qinshihuang:DoUpdateQinBoss", nTemplateId, nMapId, nMapX, nMapY};
	return 0;
end

function tbQinshihuang:OnBossReal_GC()
	if not self.tbBoss.nRealMap then
		local nRealMap = 0;
		local nRand = MathRandom(1, 3);
		for nMapId, nIndex in pairs(self.tbMapIndex) do
			if nIndex == nRand then
				nRealMap = nMapId;
				break;
			end
		end
		self.tbBoss.nRealMap = nRealMap;
		GlobalExcute{"Boss.Qinshihuang:OnBossReal_GS", nRealMap};
	end
end

function tbQinshihuang:ClearBossReal_GC()
	self.tbBoss.nRealMap = nil;
end

function tbQinshihuang:LoadSmallBossPos()
	
	local tbFile = Lib:LoadTabFile(self.SMALL_BOSS_POS_PATH);
	if not tbFile then
		return;
	end

	local tbMap = {};
	for _, tbRow in pairs(tbFile) do
		local nMapId = tonumber(tbRow.nMapId);
		if not tbMap[nMapId] then
			tbMap[nMapId]= {};
		end
		table.insert(tbMap[nMapId], {nTemplateId = tonumber(tbRow.nTemplateId), nMapX = tonumber(tbRow.nMapX), nMapY = tonumber(tbRow.nMapY)});
	end
	
	self.tbSmallBossPos = tbMap;
end

function tbQinshihuang:BroadCast_GC(szMsg, nType)
	GlobalExcute({"Boss.Qinshihuang:OnBroadCast", szMsg, nType});
end

GCEvent:RegisterGCServerStartFunc(Boss.Qinshihuang.LoadSmallBossPos, Boss.Qinshihuang);
