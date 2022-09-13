
-- ÁÙÊ±Login´¦Àí

function Task:_OnLogin()
	if (not me.nFaction or me.nFaction == 0) then
		if (me.IsHaveSkill(281) ~= 1) then
			me.AddFightSkill(281, 1);
		end
	end
end

function Task:AddMakeAndGatherPoint(nPoint)
	me.ChangeCurMakePoint(nPoint);
	me.ChangeCurGatherPoint(nPoint);
end

function Task:AddMoney(nPoint)
	me.Earn(nPoint, Player.emKEARN_TMP_LOGIN);
end


--PlayerSchemeEvent:RegisterGlobalDailyEvent({Task.AddMakeAndGatherPoint, Task, 5000});
--PlayerSchemeEvent:RegisterGlobalDailyEvent({Task.AddMoney, Task, 100000});
