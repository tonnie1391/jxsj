local tbItem = Item:GetClass("equipskillbuf_fu");

tbItem.tbSkillList = {
		[1] = {892,1,2,7200},
		[2] = {2220,1,2,7200},
	};

function tbItem:OnUse()
	local nIndex = it.GetExtParam(1);
	local tbBuff = self.tbSkillList[nIndex];
	if (not tbBuff) then
		Dialog:Say("您的道具异常！");
		return 0;
	end
	
	Dialog:Say("您确定现在使用吗？", {
			{"Xác nhận", self.AddSkillBuff, self, it.dwId},
			{"Để ta suy nghĩ thêm"},
		});

	return 0;
end

function tbItem:AddSkillBuff(dwId)
	local pItem = KItem.GetObjById(dwId);
	if not pItem then
		Dialog:Say("道具不存在");
		return 0;
	end
	
	local nIndex = pItem.GetExtParam(1);
	local tbBuff = self.tbSkillList[nIndex];
	if (not tbBuff) then
		Dialog:Say("道具异常！");
		return 0;
	end

	local nRet = pItem.Delete(me);
	if nRet ~= 1 then
		return 0;
	end
	
	me.AddSkillState(tbBuff[1], tbBuff[2], tbBuff[3], tbBuff[4]*60*18, 1, 0, 1);

	return 1;		
end
