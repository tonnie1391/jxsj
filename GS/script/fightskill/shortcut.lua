-- 左右键技能快捷键

FightSkill.SKILLTREE_KEY_COUNT		= 9;	-- 快捷键最大个数
FightSkill.TSKID_LEFT_RIGHT_SKILL 	= 10;	-- 技能快捷键任务变量号
FightSkill.TSKGID_LEFT_RIGHT_SKILL	= 4;	-- 技能快捷键任务变量组号

function FightSkill:LoadSkillTask(pPlayer)
	local nId = pPlayer.GetTask(self.TSKGID_LEFT_RIGHT_SKILL, self.TSKID_LEFT_RIGHT_SKILL);
	local nLeft = Lib:LoadBits(nId, 0, 15);
	local nRight = Lib:LoadBits(nId, 16, 31);
	return nLeft, nRight;
end

function FightSkill:LoadShortcut(pPlayer)
	local nLeft, nRight = self:LoadSkillTask(pPlayer);
	local nWeaponSkill = pPlayer.GetWeaponSkill();
	if pPlayer.IsHaveSkill(nLeft) == 1 then
		pPlayer.nLeftSkill = nLeft;
	else
		pPlayer.nLeftSkill = nWeaponSkill;
	end
	if pPlayer.IsHaveSkill(nRight) == 1 then
		pPlayer.nRightSkill = nRight;
	else
		pPlayer.nRightSkill = nWeaponSkill;
	end
end

function FightSkill:SaveLeftSkill(pPlayer)
	self:SaveLeftSkillEx(pPlayer, pPlayer.nLeftSkill);
end

function FightSkill:SaveRightSkill(pPlayer)
	self:SaveRightSkillEx(pPlayer, pPlayer.nRightSkill);
end

function FightSkill:SaveLeftSkillEx(pPlayer, nSkillId)
	if(MODULE_GAMESERVER)then
		pPlayer.CallClientScript({"FightSkill:SaveLeftSkillEx", 0, nSkillId});
		return;
	end
	
	if(pPlayer == 0)then -- 来自GameServer
		me.nLeftSkill = nSkillId;
	else
		local nId = pPlayer.GetTask(self.TSKGID_LEFT_RIGHT_SKILL, self.TSKID_LEFT_RIGHT_SKILL);
		local nValue = Lib:SetBits(nId, nSkillId, 0, 15);
		pPlayer.SetTask(self.TSKGID_LEFT_RIGHT_SKILL, self.TSKID_LEFT_RIGHT_SKILL, nValue);	
	end
end

function FightSkill:SaveRightSkillEx(pPlayer, nSkillId)
	if(MODULE_GAMESERVER)then
		pPlayer.CallClientScript({"FightSkill:SaveRightSkillEx", 0, nSkillId});
		return;
	end
	
	if(pPlayer == 0)then -- 来自GameServer
		me.nRightSkill = nSkillId;
	else
		local nId = pPlayer.GetTask(self.TSKGID_LEFT_RIGHT_SKILL, self.TSKID_LEFT_RIGHT_SKILL);
		local nValue = Lib:SetBits(nId, nSkillId, 16, 31);
		pPlayer.SetTask(self.TSKGID_LEFT_RIGHT_SKILL, self.TSKID_LEFT_RIGHT_SKILL, nValue);	
	end
end

-- 将左右技能键设为默认值
function FightSkill:ClearLeftRightSkill(pPlayer)
	if(MODULE_GAMESERVER)then
		pPlayer.CallClientScript({"FightSkill:ClearLeftRightSkill"});
		return;
	end
	
	me.nLeftSkill = 1;
	me.nRightSkill = 1;
end

function FightSkill:GetLeftSkill(pPlayer)
	local nLeft, nRight = self:LoadSkillTask(pPlayer);
	return nLeft;
end

function FightSkill:GetRightSkill(pPlayer)
	local nLeft, nRight = self:LoadSkillTask(pPlayer);
	return nRight;
end
--ADD:快捷栏技能
function FightSkill:SetShortcutSkill(pPlayer, nPosition, nSkillId, nIsRefreshWindow)
	if nPosition < 0 or nPosition > Item.SHORTCUTBAR_OBJ_MAX_SIZE then
		return;
	end	
	local nFlags = pPlayer.GetTask(Item.TSKGID_SHORTCUTBAR, Item.TSKID_SHORTCUTBAR_FLAG);
	nFlags = Lib:SetBits(nFlags, Item.SHORTCUTBAR_TYPE_SKILL, nPosition * 3 - 3, nPosition * 3 - 1); 	
	pPlayer.SetTask(Item.TSKGID_SHORTCUTBAR, Item.TSKID_SHORTCUTBAR_FLAG, nFlags);
	pPlayer.SetTask(Item.TSKGID_SHORTCUTBAR, nPosition * 2 - 1, nSkillId);
	pPlayer.SetTask(Item.TSKGID_SHORTCUTBAR, nPosition * 2 , 0);
	if nIsRefreshWindow == 1 then 
		FightSkill:RefreshShortcutWindow(pPlayer);
	end
end
-- 物品快捷栏   tbItem = {G,D,P,L,S}
function FightSkill:SetShortcutItem(pPlayer, nPosition, tbItem ,nIsRefreshWindow)
	if nPosition < 0 or nPosition > Item.SHORTCUTBAR_OBJ_MAX_SIZE then
		return;
	end	
	local nFlags = pPlayer.GetTask(Item.TSKGID_SHORTCUTBAR, Item.TSKID_SHORTCUTBAR_FLAG);
	nFlags = Lib:SetBits(nFlags, Item.SHORTCUTBAR_TYPE_ITEM, nPosition * 3 - 3, nPosition * 3 - 1); 	
	pPlayer.SetTask(Item.TSKGID_SHORTCUTBAR, Item.TSKID_SHORTCUTBAR_FLAG, nFlags);	
	local nLow  = Lib:SetBits(tbItem[1], tbItem[2], 16, 31);
	local nHigh = Lib:SetBits(tbItem[3], tbItem[4], 16, 23);
	nHigh = Lib:SetBits(nHigh, tbItem[5], 24, 31);
	pPlayer.SetTask(Item.TSKGID_SHORTCUTBAR, nPosition * 2 - 1, nLow);
	pPlayer.SetTask(Item.TSKGID_SHORTCUTBAR, nPosition * 2 , nHigh);
	if nIsRefreshWindow == 1 then	
 		FightSkill:RefreshShortcutWindow(pPlayer);
 	end
end

--清快捷栏
function FightSkill:ClearShortcut(pPlayer, nIsRefreshWindow)	
	pPlayer.SetTask(Item.TSKGID_SHORTCUTBAR, Item.TSKID_SHORTCUTBAR_FLAG, 0); -- 只清标记位
	if nIsRefreshWindow == 1 then 
		FightSkill:RefreshShortcutWindow(pPlayer);
	end
end	

--刷新快捷栏
function FightSkill:RefreshShortcutWindow(pPlayer)
	if MODULE_GAMECLIENT then
		UiManager:CloseWindow(Ui.UI_SHORTCUTBAR);
    	UiManager:OpenWindow (Ui.UI_SHORTCUTBAR);
    	return;
	end
	if MODULE_GAMESERVER then
		pPlayer.CallClientScript({"FightSkill:RefreshShortcutWindow"});
		return;
	end	
end
