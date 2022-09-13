local tbCarrot = Item:GetClass("xoyoitem_carrot");

function tbCarrot:IsPickable()
	local tbRoom = XoyoGame:GetPlayerRoom(me.nId);
	if tbRoom and tbRoom.szName == "RoomCarrot" then
		local res = tbRoom:CanPlayerPickCarrot(me);
		return res;
	end
	return 0;
end

function tbCarrot:PickUp()
	local tbRoom = XoyoGame:GetPlayerRoom(me.nId);
	if tbRoom then
		tbRoom:PlayerGotCarrot(me, nil, 1);
	end
	return 1;
end