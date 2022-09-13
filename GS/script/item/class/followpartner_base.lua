-- 文件名　：followpartner_base.lua
-- 创建者　：jiazhenwei
-- 创建时间：2012-05-10 12:04:25
-- 功能    ：

local tbItem = Item:GetClass("FollowPartner");

function tbItem:OnUse()
	local nValid = Npc.tbFollowPartner:CheckTimeValid(me);	--当前召唤宠物是否有效
	if nValid <= 0 then
		Npc.tbFollowPartner:InitSelf();
	end
	local nNpcId = tonumber(it.GetExtParam(1));
	local nType = tonumber(it.GetExtParam(2));
	local nChangeColor =  tonumber(it.GetExtParam(3));
	local nSkillId =  tonumber(it.GetExtParam(4));
	local nSkillLevel =  tonumber(it.GetExtParam(5));
	local nMyType = me.GetTask(Npc.tbFollowPartner.TSK_GROUP, Npc.tbFollowPartner.TSK_TYPE);
	local nMyNpcId = me.GetTask(Npc.tbFollowPartner.TSK_GROUP, Npc.tbFollowPartner.TSK_NPC_TEMPID);
	if nNpcId <= 0 or nType <= 0 then
		return;
	end
	local tbType = Npc.tbFollowPartner.tbFollowPartner[nType];
	local szTypeMsg = Npc.tbFollowPartner.tbItemChat[nType] 
	if not tbType or not szTypeMsg then
		return;
	end
	local tbOpt = {{"Để ta suy nghĩ thêm"}};
	local nState = it.GetGenInfo(2);
	--取道具上累计的奖励
	local nDate = tonumber(GetLocalDate("%Y%m%d"));
	if nValid == 1 and nType == nMyType and nNpcId == nMyNpcId and nState == 1 then
		self:AddAward2Item(it, tbType);
		table.insert(tbOpt, 1, {"Thu hồi", self.CallBackPartner, self, it.dwId, nSkillId, nSkillLevel});
	end
	if nValid ~= 1 then
		table.insert(tbOpt, 1, {"Triệu hồi", self.CallPartner, self, it.dwId, nNpcId ,nType, nChangeColor, nSkillId, nSkillLevel});
		nState = 2;
	elseif nMyType <= 0 then
		table.insert(tbOpt, 1, {"Triệu hồi", self.CallPartner, self, it.dwId, nNpcId ,nType, nChangeColor, nSkillId, nSkillLevel});
	end
	if tbType[5] > 0 and it.GetGenInfo(1) >= tbType[6] and it.GetGenInfo(3) ~= nDate then
		table.insert(tbOpt, 1, {"<color=green>Nhận thưởng<color>", self.GetAward, self, it.dwId, tbType});
	end
	local szMsg = "";
	if nType ~= 2 then
		szMsg = string.format(szTypeMsg, tbType[6], it.GetGenInfo(1));
	else
		szMsg = string.format(szTypeMsg, me.GetBaseAwardExp() * tbType[6], me.GetBaseAwardExp() * it.GetGenInfo(1));
	end
	if it.GetGenInfo(3) == nDate then
		szMsg = szMsg.."\n\n<color=green>Đã nhận phần thưởng hôm nay<color>";
	end
	if nState <= 0 then
		szMsg = "Một thú cưng đã được triệu hồi. Thu hồi lại trước khi triệu hồi thú cưng khác.";
	end
	Dialog:Say(szMsg, tbOpt);
	return;
end

--收回跟宠
function tbItem:CallBackPartner(nItemId, nSkillId, nSkillLevel)
	local pItem = KItem.GetObjById(nItemId)
	if not pItem then
		return;
	end
	local tbPlayerTemp =  me.GetTempTable("Player");
	if not tbPlayerTemp.tbFollowPartner then
		return;
	end
	local nNpcId = tbPlayerTemp.tbFollowPartner.nParnerId;
	local pNpc = KNpc.GetById(nNpcId);
	Npc.tbFollowPartner:CallBackPartner(pNpc);
	pItem.SetGenInfo(2, 0);
	pItem.Sync();
	if nSkillId > 0 and nSkillLevel > 0 then
		if me.GetSkillState(nSkillId) == nSkillLevel then
			me.RemoveSkillState(nSkillId);
		end
	end
end

--获得奖励
function tbItem:GetAward(nItemId, tbType)
	local pItem = KItem.GetObjById(nItemId)
	if not pItem then
		return;
	end
	
	local nAward = pItem.GetGenInfo(1);
	if nAward < tbType[6] then
		Dialog:Say("累计的奖励还不够多。");
		return;
	end
	local nNowDate = tonumber(GetLocalDate("%Y%m%d"));
	if pItem.GetGenInfo(3) == nNowDate then
		Dialog:Say("您今天已经领取过了，明天再来领取吧。");
		return;
	end
	if tbType[5] == 1 then
		if me.GetBindMoney() + nAward > me.GetMaxCarryMoney() then
			Dialog:Say("您身上的绑定银两过多，请整理下。");
			return;
		end
		me.AddBindMoney(nAward);
	elseif tbType[5] == 2 then
		me.AddExp(me.GetBaseAwardExp() * nAward);
	elseif tbType[5] == 3 then
		me.AddExp(nAward);
	elseif tbType[5] == 4 then
		me.AddBindCoin(nAward);
	elseif tbType[5] == 5 and tbType[17] ~= "" then
		local tbGDPL = Lib:SplitStr(tbType[17]);
		if #tbGDPL < 5 then
			Dialog:Say("奖励异常，请联系GM。");
			return;
		end
		local nNeedBag = 0;
		if not tbGDPL[6] then
			nNeedBag = KItem.GetNeedFreeBag(tonumber(tbGDPL[1]), tonumber(tbGDPL[2]), tonumber(tbGDPL[3]), tonumber(tbGDPL[4]), nil, tonumber(tbGDPL[5]));
		else
			nNeedBag = tonumber(tbGDPL[5]);
		end
		if me.CountFreeBagCell() < nNeedBag then
			Dialog:Say(string.format("Hành trang không đủ %s ô.", nNeedBag));
			return;
		end
		if not tbGDPL[6] then
			me.AddStackItem(tonumber(tbGDPL[1]), tonumber(tbGDPL[2]), tonumber(tbGDPL[3]), tonumber(tbGDPL[4]), {bForceBind = 1}, tonumber(tbGDPL[5]));
		else
			for i =1, tonumber(tbGDPL[5]) do
				me.AddItemEx(tonumber(tbGDPL[1]), tonumber(tbGDPL[2]), tonumber(tbGDPL[3]), tonumber(tbGDPL[4]),{bForceBind = 1},nil, GetTime() + tonumber(tbGDPL[6]) * 60);
			end
		end
	end
	pItem.SetGenInfo(1, 0);
	pItem.SetGenInfo(3, tonumber(GetLocalDate("%Y%m%d")));
	pItem.Sync();
	--当前是激活的宠物，需要把角色变量也删除掉
	if pItem.GetGenInfo(2) == 1 then
		me.SetTask(Npc.tbFollowPartner.TSK_GROUP, Npc.tbFollowPartner.TSK_AWARD_ADD, 0);
	end
end

--把玩家任务变量充到道具变量中
function tbItem:AddAward2Item(pItem, tbType)
	local nMax = tbType[6];
	local nAdd = me.GetTask(Npc.tbFollowPartner.TSK_GROUP, Npc.tbFollowPartner.TSK_AWARD_ADD);
	nAdd = math.min(nAdd, nMax);
	if nAdd ~= pItem.GetGenInfo(1) then
		pItem.SetGenInfo(1, nAdd);
		pItem.Sync();
	end
end

--召唤跟宠
function tbItem:CallPartner(nItemId, nNpcId, nType, nChangeColor, nSkillId, nSkillLevel, bProcesss)
	local pItem = KItem.GetObjById(nItemId);
	if not pItem then
		return;
	end	
	if me.nFightState == 1 then
		if not bProcesss then
			local tbEvent = 
				{
					Player.ProcessBreakEvent.emEVENT_MOVE,
					Player.ProcessBreakEvent.emEVENT_ATTACK,
					Player.ProcessBreakEvent.emEVENT_SITE,
					Player.ProcessBreakEvent.emEVENT_USEITEM,
					Player.ProcessBreakEvent.emEVENT_ARRANGEITEM,
					Player.ProcessBreakEvent.emEVENT_DROPITEM,
					Player.ProcessBreakEvent.emEVENT_SENDMAIL,
					Player.ProcessBreakEvent.emEVENT_TRADE,
					Player.ProcessBreakEvent.emEVENT_CHANGEFIGHTSTATE,
					Player.ProcessBreakEvent.emEVENT_CLIENTCOMMAND,
					Player.ProcessBreakEvent.emEVENT_LOGOUT,
					Player.ProcessBreakEvent.emEVENT_DEATH,
				};
			GeneralProcess:StartProcess("Đang triệu hồi...", 5* Env.GAME_FPS, {self.CallPartner, self, nItemId, nNpcId, nType, nChangeColor, nSkillId, nSkillLevel, 1}, nil, tbEvent);
			return;
		end
	end
	local _, nTime = pItem.GetTimeOut();
	nTime = nTime - GetTime();
	if nTime <= 0 then
		nTime = 30 * 24 * 3600;	--如果没有有效期的道具默认30天
	end
	local pPartner = Npc.tbFollowPartner:CallFollowPartner(nNpcId, nType, nTime, pItem);
	if pPartner then
		pItem.SetGenInfo(2, 1);
		pItem.Sync();
		if nChangeColor > 0 then
			pPartner.ChangeColorScheme(nChangeColor);
		end
		if nSkillId > 0 and nSkillLevel > 0 then
			me.AddSkillState(nSkillId, nSkillLevel, 1, nTime  * 18, 1, 0, 1);
		end
	end
end
