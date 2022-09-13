local tbItem = Item:GetClass("kingame_gutongqian")

function tbItem:PickUp()
	KinGame:GiveEveryOneAward(me.nMapId);
	return 0;
end
