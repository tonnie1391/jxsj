if (not MODULE_GC_SERVER) then
	return 0;
end

function GbWlls:Gc_Anncone(szAnncone)
	GC_AllExcute({"GbWlls:Gb_Anncone", szAnncone});
end
	
function GbWlls:Gb_Anncone(szAnncone)
	if GLOBAL_AGENT then
		GC_AllExcute({"GbWlls:Anncone_GC", szAnncone});
	end
end

function GbWlls:Anncone_GC(szAnncone)
--	local nGate = tonumber(string.sub(GetGatewayName(), 5, -1));
--	if GbWlls.tbLeagueName[nGate] then
	GlobalExcute({"GbWlls:Anncone_GS", szAnncone});
--	end
end

-- 合服时候用
function GbWlls:MergeCoZoneAndMainZoneBuf(tbSubBuf)
	print("[GbWlls MergeCoZoneAndMainZoneBuf] Start!!");
	
	self.tb8RankInfo = self:LoadGbWllsGbBuf();
	if (tbSubBuf) then
		-- 规则是：如果主服有数据，那么就用主服的数据，如果主服没有数据那么就把从服的合进来
		local nMainSession = self.tb8RankInfo.nSession;
		if (not nMainSession or nMainSession <= 0) then
			self.tb8RankInfo = tbSubBuf;
			GbWlls:SaveGbWllsGbBuf(self.tb8RankInfo);		
		end
	end
	
	print("[GbWlls MergeCoZoneAndMainZoneBuf] end!!");
end
