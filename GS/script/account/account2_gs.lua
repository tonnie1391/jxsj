-------------------------------------------------------------------
--File: account2_gs.lua
--Author: sunduoliang
--Date: 2012-7-21 10:04
--Describe: 副密码功能
-------------------------------------------------------------------

--检查该功能是否可以使用
function Account:Account2CheckIsUse(pPlayer, nType)
	if IsLoginUseVicePassword(pPlayer.nPlayerIndex) ~= 1 then
		-- 主密码无限制
		return 1;
	end
	if not self.tbAccount2LockDef_Tsk_Id[nType] then
		-- 不存在的类型，没有限制使用
		return 1;
	end
	local nLimit = pPlayer.GetTask(self.nAccount2LockDef_Tsk_Group, self.tbAccount2LockDef_Tsk_Id[nType][1]);
	if nLimit == 1 then
		return 0;
	end
	return 1;
end

--检查该功能是否可以使用
function Account:Account2CheckIsUseById(nPlayerId, nType)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId) 
	if not pPlayer then
		return 0;
	end
	return self:Account2CheckIsUse(pPlayer, nType);
end

-- 设置副密码是否可使用某类型，type为类型，bUse=1可使用，0不可使用
function Account:Account2SetUseState(pPlayer, nType, bUse)
	if IsLoginUseVicePassword(pPlayer.nPlayerIndex) == 1 then
		-- 副密码无法设置
		return 1;
	end
	if not self.tbAccount2LockDef_Tsk_Id[nType] then
		-- 不存在的类型，没有限制使用
		return 1;
	end
	local nLimit = 0;
	if bUse == 0 then
		nLimit = 1;
	end
	 pPlayer.SetTask(self.nAccount2LockDef_Tsk_Group, self.tbAccount2LockDef_Tsk_Id[nType][1], nLimit);
end

function Account:Account2CheckIsUseByIndex(nPlayerIndex, nType)
	local pPlayer = KPlayer.GetPlayerObjByIndex(nPlayerIndex);
	if not pPlayer then
		return 0;
	end
	local nLimit = self:Account2CheckIsUse(pPlayer, nType);
	if nLimit == 0 then
		pPlayer.Msg("你正在使用副密码登陆游戏，设置了权限控制，无法进行该操作！")
	end
	return nLimit;
end
