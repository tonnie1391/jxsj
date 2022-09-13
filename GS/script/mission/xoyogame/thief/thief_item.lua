local tbVase = Item:GetClass("xoyoitem_vase");

function tbVase:PickUp()
	local tbRoom = XoyoGame:GetPlayerRoom(me.nId);
	if tbRoom and tbRoom.szName == "RoomThief" then
		tbRoom:PlayerGotVase();
	end
	return 1;
end