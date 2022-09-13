-- 文件名　：wanted_gc.lua
-- 创建者　：sunduoliang
-- 创建时间：2010-08-04 11:31:18

Require("\\script\\task\\wanted\\wanted_file.lua");

function Wanted:AddFinishTaskCount_GC(nLevel)
	--self:CheckFinishTaskCount_GC();
	if self.DEF_SAVE_TASK[nLevel] then
		local nWeekCount = KGblTask.SCGetDbTaskInt(self.DEF_SAVE_TASK[nLevel][1]);
		KGblTask.SCSetDbTaskInt(self.DEF_SAVE_TASK[nLevel][1], nWeekCount + 1);
	end

end

function Wanted:ScheduletaskGC()
	self:ReRandomTaskGC(1);
	if tonumber(os.date("%w", GetTime())) ~= 1 then
		return 0;
	end
	self:CheckFinishTaskCount_GC();
end

function Wanted:CheckFinishTaskCount_GC()
	for nLevel, tbTask in ipairs(self.DEF_SAVE_TASK) do
		local nWeekCount = KGblTask.SCGetDbTaskInt(tbTask[1]);
		local nLastWeekCount = KGblTask.SCGetDbTaskInt(tbTask[2]);
		KGblTask.SCSetDbTaskInt(tbTask[2], nWeekCount);
		KGblTask.SCSetDbTaskInt(tbTask[1], 0);
		Dbg:WriteLog("Wanted", "SaveWeekCount", "nLevel|nWeekCount|nLastWeekCount", nLevel, nWeekCount, nLastWeekCount);
	end
end

function Wanted:ReRandomTaskGC(bForce)
	if bForce == 1 or self.nRandomTask == 0 then
		for nSeg in pairs(self.RANDOM_SEG_LIST) do
			Lib:SmashTable(self.TaskLevelSeg[nSeg])
		end
		self.nRandomTask = 1;
	end
	for nSeg, tbTask in pairs(self.TaskLevelSeg) do
		GlobalExcute({"Wanted:ReRandomTask", nSeg, tbTask});
	end
end

Wanted:LoadTask();

GCEvent:RegisterGCServerStartFunc(Wanted.ReRandomTaskGC, Wanted);
GCEvent:RegisterAllServerStartFunc(Wanted.ReRandomTaskGC, Wanted);

