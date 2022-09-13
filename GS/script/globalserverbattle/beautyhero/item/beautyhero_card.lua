local tbItem = Item:GetClass("beautyhero_card");

function tbItem:GetTip()
	if it.szCustomString == "" then
		return "";
	end
	return string.format("<color=yellow>%s<color>µÄÓ¦Ô®¿¨Æ¬",it.szCustomString);	
end


function tbItem:InitGenInfo()
	it.SetTimeOut(0, GetTime() + BeautyHero.TIME_CARD * 60);
	return	{ };
end
