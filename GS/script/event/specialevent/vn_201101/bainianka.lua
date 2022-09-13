-- 文件名  : bainianka.lua
-- 创建者  : jiazhenwei
-- 创建时间: 2010-12-31 16:17:12
-- 描述    : 拜年卡

local tbItem = Item:GetClass("bainianka_vn");

function tbItem:OnUse()
	local szMsg = string.format("%s使用拜年卡祝贺大家春节安康盛旺。", me.szName);
	local nFlag = Item:GetClass("randomitem"):SureOnUse(149, nil, nil, nil, nil, nil, nil, nil, nil, it);
	if nFlag == 1 then
		me.SendMsgToFriend(szMsg);
		Player:SendMsgToKinOrTong(me, szMsg);
		Player:SendMsgToKinOrTong(me, szMsg, 1);
	end
	return nFlag;
end

function tbItem:InitGenInfo()
	-- 设定有效期限	
	it.SetTimeOut(0, GetTime() + 30 * 24 * 3600);	
	return	{ };
end
