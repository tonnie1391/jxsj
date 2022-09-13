--4±¶µØÍ¼
--sunduoliang
--2008.11.10

Require("\\script\\task\\fourfoldmap\\fourfoldmap_def.lua");

local Fourfold = Task.FourfoldMap;

function Fourfold:Apply_GC(nPlayerId, nCityMapId, nLevel)
	GlobalExcute({"Task.FourfoldMap:SyncMap", nPlayerId, nCityMapId, nLevel});
end

function Fourfold:Release_GC(nPlayerId, nCityMapId, nLevel)
	GlobalExcute({"Task.FourfoldMap:ReleaseMap", nPlayerId, nCityMapId, nLevel});
end
