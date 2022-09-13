 
if not MODULE_GC_SERVER then
	print("treause_gc.luaÖ»ÄÜÔÚGC¼ÓÔØ!");
	return;
end
function TreasureMap:SynData(nTime, nAddedMoney, nServerId)
	GlobalExcute{"TreasureMap:SynDataToGS", nTime, nAddedMoney, nServerId};
end

function TreasureMap:Open()
	GlobalExcute{"TreasureMap:OpenByGC"};
end

function TreasureMap:Close()
	GlobalExcute{"TreasureMap:CloseByGC"};
end