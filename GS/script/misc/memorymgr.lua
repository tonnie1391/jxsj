-------------------------------------------------------------------
--File: memorymgr.lua
--Author: zhongjunqi
--Date: 2012-4-10 22:51:59
--Describe: 内存策略管理 
-------------------------------------------------------------------


-- 初始化
function MemoryMgr:Start()
	self.nRegisterId = Timer:Register(18*600, self.OnTimer, self);
	self.tbMemInfo = {};				-- 记录当前的内存信息
	print("MemoryMgr Start!");
	self.bOutputDbgInfo = 1;			-- 是否输出调试信息
	-- 历史调整记录，最多保存500次
	self.tbHistroy = {nBegin=1, nCount=0, nMaxRecord=500};
end


function MemoryMgr:OnTimer()	-- 时间到，会调用此函数
	local tbMem = KLib.GetScriptMemAllocInfo(1000);			-- 只返回分配数量大于50的内存池，这样有助于提高效率
	if (not tbMem) then
		return;
	end
	
	-- 输出调试信息
	if (self.bOutputDbgInfo == 1) then
		self:OutputDbgInfo(tbMem);
	end
	
	self:RecordInfo(tbMem);
	
	for i, tbInfo in ipairs(tbMem) do
		-- 直接设置内存池大小为峰值大小，第三个参数表示采用缓慢释放的方式
		KLib.SetScriptAllocatorPoolSize(tbInfo.nAllocIndex, tbInfo.nMaxUseCount, 2);
		KLib.ResetScriptAllocatorMaxUseCount(tbInfo.nAllocIndex);			-- 重新统计峰值
	end
	
	return;
end

-- 输出调试信息
function MemoryMgr:OutputDbgInfo(tbMem)
	if (not tbMem) then
		return;
	end
	
	local szBlockSize = "BlockSize";
	local szAllocCountMsg = "AllocCount";
	local szFreeCountMsg = "FreeCount";
	local szPoolSize = "PoolSize";
	local szMaxUseCount = "MaxUseCount";
	local szTobeFreeCount = "TobeFreeCount";
	
	for i, tbInfo in ipairs(tbMem) do
		szBlockSize = szBlockSize .. "," .. tbInfo.nBlockSize;
		szAllocCountMsg = szAllocCountMsg .. "," .. tbInfo.nAllocCount;
		szFreeCountMsg = szFreeCountMsg .. "," .. tbInfo.nFreeCount;
		szPoolSize = szPoolSize .. "," .. tbInfo.nPoolSize;
		szMaxUseCount = szMaxUseCount .. "," .. tbInfo.nMaxUseCount;
		szTobeFreeCount = szTobeFreeCount .. "," .. tbInfo.nTobeFreeCount;
	end
	print(szBlockSize);
	print(szAllocCountMsg);
	print(szFreeCountMsg);
	print(szPoolSize);
	print(szMaxUseCount);
	print(szTobeFreeCount);
end

function MemoryMgr:RecordInfo(tbMem)
	if (not tbMem) then
		return;
	end
	local tbRecord = {};
	tbRecord.Time = GetLocalDate("%H:%M:%S");
	
	for i, tbInfo in ipairs(tbMem) do
		tbRecord[i] = { BlockSize = tbInfo.nBlockSize,AllocCount=tbInfo.nAllocCount, FreeCount=tbInfo.nFreeCount,
						PoolSize=tbInfo.nPoolSize,MaxUseCount=tbInfo.nMaxUseCount};
	end
	
	if (self.tbHistroy.nCount >= self.tbHistroy.nMaxRecord) then
		self.tbHistroy[self.tbHistroy.nBegin] = tbRecord;
		self.tbHistroy.nBegin = self.tbHistroy.nBegin % self.tbHistroy.nMaxRecord + 1;
	else
		self.tbHistroy.nCount = self.tbHistroy.nCount + 1;
		self.tbHistroy[self.tbHistroy.nCount] = tbRecord;
	end
	
--{
--	{
--		Time="",
--		[1] = {BlockSize=, AllocCount=, FreeCount=,PoolSize=,MaxUseCount=,TobeFreeCount=},
--	 	[2] = {} 
--	 },
--	 {
--	 },
--}
end
