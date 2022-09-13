
local tbYeLianDaShi = Npc:GetClass("yeliandashi");

function tbYeLianDaShi:OnDialog()
	if me.IsAccountLock() ~= 0 then
		Dialog:Say("Tài khoản đang bị khóa, không thể thao tác!");
		Account:OpenLockWindow(me);
		return;
	end
	if Account:Account2CheckIsUse(me, 7) == 0 then
		Dialog:Say("你正在使用副密码登陆游戏，设置了权限控制，无法进行该操作！");
		return 0;
	end
	
	-- 直接打开强化，允许所有的强化操作
	if me.GetExtMonthPay() >= EventManager.IVER_nPlayerFuli_Hexuan then
		-- 如果有充值特权，就打开强化
		me.OpenEnhance(Item.ENHANCE_MODE_ENHANCE, Item.BIND_MONEY, 0);	-- 注意：不能使用玄晶合成做为默认打开配置，因为特权合玄已经占用了
	else
		-- 没有充值特权就默认打开合玄的界面
		me.OpenEnhance(Item.ENHANCE_MODE_ALLOW_ALL, Item.BIND_MONEY, 0);
	end
end



function tbYeLianDaShi:SelectMoneyType(nMode)
end


function tbYeLianDaShi:CheckPermission(tbOption)
	if me.IsAccountLock() ~= 0 then
		Dialog:Say("Tài khoản đang bị khóa, không thể thao tác!");
		Account:OpenLockWindow(me);
		return;
	end
	if Account:Account2CheckIsUse(me, 7) == 0 then
		Dialog:Say("你正在使用副密码登陆游戏，设置了权限控制，无法进行该操作！");
		return 0;
	end		
	Lib:CallBack(tbOption);
end

-- 申请装备剥离
function tbYeLianDaShi:ApplyPeelHighEquip()	
	local szMsg = "强化等级12或以上的装备剥离起来颇为麻烦，我需要准备一个半时辰<color=red>(3小时)<color>，之后的四个时辰内我可以给你剥离，过时不候。一次申请只能剥<color=red>一件<color>装备。";
	local tbOpt = {
			{"我要申请剥离", Item.ApplyPeelHighEquipSure, Item},
			{"取消"}
		};
	Dialog:Say(szMsg, tbOpt);	
end

-- 取消装备剥离
function tbYeLianDaShi:CancelPeelHighEquip()
	local szMsg = "你是否要取消剥离申请？取消后无法剥离强化等级12或以上的装备";
	local tbOpt = {
			{"是", Item.CancelPeelHighEquipSure, Item},
			{"否"}
		};	
	Dialog:Say(szMsg, tbOpt);	
end

function tbYeLianDaShi:DelayBindEquip(nType)
	if me.IsAccountLock() ~= 0 then
		Dialog:Say("Tài khoản đang bị khóa, không thể thao tác!");
		return;
	end
	if Account:Account2CheckIsUse(me, 7) == 0 then
		Dialog:Say("你正在使用副密码登陆游戏，设置了权限控制，无法进行该操作！");
		return 0;
	end	
	Dialog:OpenGift("请放入物品", {"Item:DelayBind_Check", nType}, {Item.DelayBind_OK, Item, nType});
end
