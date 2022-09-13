--武林联赛令牌
--孙多良
--2008.10.14

local tbItem = Item:GetClass("wldh_reputeling");

function tbItem:OnUse()	
	if me.IsAccountLock() ~= 0 then
		me.Msg("你的账号处于锁定状态，无法使用该物品。");
		return 0;
	end
	
	if me.CheckLevelLimit(11, 1) == 1 then
		me.Msg("您已经达到武林大会声望最高等级，将无法使用武林大会声望令牌");
		return;
	end
	
	local nFlag = Player:AddRepute(me, 11, 1, 44);
	
	if (0 == nFlag) then
		return;
	elseif (1 == nFlag) then
		me.Msg("您已经达到武林大会声望最高等级，将无法使用武林大会声望令牌");
		return;
	end

	me.Msg(string.format("您获得<color=yellow>%s点<color>武林大会声望.", 44))
	return 1;
end


