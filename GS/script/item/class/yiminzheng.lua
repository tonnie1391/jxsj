local tbItem 	= Item:GetClass("yiminzheng");

function tbItem:OnUse()
	League.ChangeServer:ApplyChangeServer_GS1(me.nId)
	return 1;
end
