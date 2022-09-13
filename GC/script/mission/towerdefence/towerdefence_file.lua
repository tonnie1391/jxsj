-- 文件名　：towerdefence_file.lua
-- 创建者　：jiazhenwei
-- 创建时间：2010-03-09 15:48:13
-- 描  述  ：

Require("\\script\\mission\\towerdefence\\towerdefence_def.lua");

function TowerDefence:LoadGameType()	
	local tbFile = Lib:LoadTabFile("\\setting\\mission\\towerdefence\\npc_skill_money.txt");
	if not tbFile then
		print("TDGame读取文件错误，文件不存在npc_skill_money.txt");
		return;
	end
	for nId, tbParam in ipairs(tbFile) do
		if nId >= 1 then
			local nNpcId  = tonumber(tbParam.nNpcId);
			local nSkillId  = tonumber(tbParam.nSkillId);
			local nIntegral  = tonumber(tbParam.nIntegral);
			local nMoney  = tonumber(tbParam.nMoney);
			self.NPC_SKILL[nNpcId] = nSkillId;
			self.NPC_AWORD[nNpcId] = {nIntegral,nMoney};
		end
	end
	
	local tbFile = Lib:LoadTabFile("\\setting\\mission\\towerdefence\\npc_refresh_type.txt");
	if not tbFile then
		print("TDGame读取文件错误，文件不存在npc_refresh_type.txt");
		return;
	end
	for nId, tbParam in ipairs(tbFile) do	
		if nId >= 1 then
			local nType  = tonumber(tbParam.nType);				
			if not self.NPC_TYPE_ID[nId] and nType then
				if nType == 1 then
					self.NPC_TYPE_ID[nId] = {};	
					for i = 1, 20 do
						local szKey = string.format("nId%s",i);
						if tbParam[szKey] then
							table.insert(self.NPC_TYPE_ID[nId], tonumber(tbParam[szKey]));
						end
					end
				else
					self.NPC_TYPE_ID[nId] = tonumber(tbParam.nId1);
				end
			end
		end
	end
end

if  MODULE_GAMESERVER then
	TowerDefence:LoadGameType();
end

