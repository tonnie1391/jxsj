-- FileName	: yaoqinghan.lua
-- Author	: furuilei
-- Time		: 2010/6/21 14:30
-- Comment	: 邀请函

local tbItem = Item:GetClass("marry_yaoqinghan");

function tbItem:OnUse()
	local szMsg = "宾客携带邀请函便可进入<color=yellow>对应的<color>典礼场地。二位侠侣的好友与同一家族的人不需要此邀请函即可进入。";
	Dialog:Say(szMsg);
	return 0;
end
