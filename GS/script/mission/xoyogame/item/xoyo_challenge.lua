-- 逍遥录
local tbXoyolu = Item:GetClass("xoyolu");
function tbXoyolu:InitGenInfo()
	local tbTime = os.date("*t", GetTime());
	local month = tbTime.month;
	local year = tbTime.year;
	if month == 12 then
		month = 1;
		year = year + 1;
	else
		month = month + 1;
	end
	
	it.SetTimeOut(0, Lib:GetDate2Time(year*10000 + month*100 + 1) - 1);
	return {};
end

function tbXoyolu:GetTip()
	return XoyoGame.XoyoChallenge:GetXoyoluTips(me);
end

-- 逍遥谷卡片
local tbXoyoCard = Item:GetClass("xoyo_card");
function tbXoyoCard:InitGenInfo()
	it.SetTimeOut(0, GetTime() + 2*3600);
	return {};
end

function tbXoyoCard:OnUse()
	if it.nParticular == 314 then -- 特殊卡
		if me.CountFreeBagCell() < 1 then
			Dialog:Say("Hành trang không đủ 1 ô trống");
			return;
		end
		
		local tbCardGDPL = XoyoGame.XoyoChallenge:GetRandomCard();
		local pNewCard = me.AddItem(unpack(tbCardGDPL));
		if pNewCard then
			it.Delete(me);
			return;
		end
	else -- 普通卡
		local nRes, szMsg = XoyoGame.XoyoChallenge:UseCard(me, it);
		if nRes == 0 then
			Dialog:Say(szMsg);
		end
		return;
	end
end

-- 秘宝
local tbXoyoTreasure = Item:GetClass("xoyo_treasure");
function tbXoyoTreasure:InitGenInfo()
	it.SetTimeOut(0, GetTime() + 2*3600);
	return {};
end

--DoScript("\\script\\mission\\xoyogame\\item\\xoyo_challenge.lua")