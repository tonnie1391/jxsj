-------------------------------------------------------
-- 文件名　: shengxia_gc.lua
-- 创建者　: lgy
-- 创建时间: 2012-7-5 17:27:11
-- 文件描述: 
-------------------------------------------------------

if not MODULE_GC_SERVER then
	return;
end

Require("\\script\\event\\jieri\\201207_shengxia\\shengxia_def.lua");

local tbShengXia2012 = SpecialEvent.tbShengXia2012;

--载入缓存数据                                         
function tbShengXia2012:LoadBuffer_GC()
	local tbLoadBuffer = GetGblIntBuf(self.BUFFER_INDEX, 0);
	if tbLoadBuffer and type(tbLoadBuffer) == "table" then
		self.tbGlobalBuffer = tbLoadBuffer;
	end
end

--保存缓存，通知gs
function tbShengXia2012:SaveBuffer_GC()
	SetGblIntBuf(self.BUFFER_INDEX, 0, 1, self.tbGlobalBuffer);
	GlobalExcute({"SpecialEvent.tbShengXia2012:LoadBuffer_GS"});
end

--清楚缓存，通知gs
function tbShengXia2012:ClearBuffer_GC()
	print("clearing...")
	self.tbGlobalBuffer = {};
	SetGblIntBuf(self.BUFFER_INDEX, 0, 1, {});
	GlobalExcute({"SpecialEvent.tbShengXia2012:ClearBuffer_GS"});
end


--设置数据，存入缓存，通知gs。
function tbShengXia2012:SetBuffer(nDay, nGold, nSilver, nBronze)
	if not self.tbGlobalBuffer[nDay] then
		self.tbGlobalBuffer[nDay] = {};	
	end
	if (not nGold) or (not nSilver) or (not nBronze) then
		return "各个奖牌数没有输入完整";
	end
	
	self.tbGlobalBuffer[nDay][1] = nGold;
	self.tbGlobalBuffer[nDay][2] = nSilver;
	self.tbGlobalBuffer[nDay][3] = nBronze;
	self.tbGlobalBuffer[nDay][4] = nGold + nSilver + nBronze;

	self:SaveBuffer_GC();
	self:UpdateDay();
	return 1;
end

--跟新流水号
function tbShengXia2012:UpdateDay()
	local nDay = KGblTask.SCGetDbTaskInt(DBTASK_SHENGXIA_DAY);
	nDay = nDay + 1;
	KGblTask.SCSetDbTaskInt(DBTASK_SHENGXIA_DAY, nDay);
end

--重置流水号
function tbShengXia2012:ReSetDay()
	KGblTask.SCSetDbTaskInt(DBTASK_SHENGXIA_DAY, 0);
end

--注册GC重启LOAD
GCEvent:RegisterGCServerStartFunc(tbShengXia2012.LoadBuffer_GC, tbShengXia2012);
