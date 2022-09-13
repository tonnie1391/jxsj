-- 文件名　：refreshnpa_file.lua
-- 创建者　：jiazhenwei
-- 创建时间：2010-04-07 19:48:50
-- 描  述  ：
SpecialEvent.LaborDay = SpecialEvent.LaborDay or {};
local LaborDay = SpecialEvent.LaborDay or {};
LaborDay.tbFileName = {{114,121},{130,137}};

function LaborDay:LoadNpc()	
	if  not MODULE_GAMESERVER then
		return;
	end
	
	local szFileName = "";	
	for _,tbMapList in ipairs(self.tbFileName) do
		for i = tbMapList[1], tbMapList[2] do 
			szFileName = string.format("\\setting\\event\\jieri\\20100501_laborday\\npc_soldier%s.txt", i);
			local tbFile = Lib:LoadTabFile(szFileName);
			if not tbFile then
				print("【五一】读取文件错误，文件不存在",szFileName);
				return;
			end
			for nId, tbParam in ipairs(tbFile) do
				if nId >= 1 then
					local nTRAPX  = tonumber(tbParam.TRAPX);
					local nTRAPY = tonumber(tbParam.TRAPY);
					if not LaborDay.tbNpcsoldierList then
						LaborDay.tbNpcsoldierList = {};
					end
					LaborDay.tbNpcsoldierList[i] = LaborDay.tbNpcsoldierList[i] or {};
					table.insert(LaborDay.tbNpcsoldierList[i], {nTRAPX,nTRAPY});
				end		
			end		
		
			szFileName = string.format("\\setting\\event\\jieri\\20100501_laborday\\npc_gen%s.txt", i);
			local tbFile = Lib:LoadTabFile(szFileName);
			if not tbFile then
				print("【五一】读取文件错误，文件不存在",szFileName);
				return;
			end
			for nId, tbParam in ipairs(tbFile) do
				if nId >= 1 then
					local nTRAPX  = tonumber(tbParam.TRAPX);
					local nTRAPY = tonumber(tbParam.TRAPY);
					if not LaborDay.tbNpcgenList then
						LaborDay.tbNpcgenList = {};
					end
					LaborDay.tbNpcgenList[i] = LaborDay.tbNpcgenList[i] or {};
					table.insert(LaborDay.tbNpcgenList[i], {nTRAPX,nTRAPY});
				end
			end
		end
	end
end

if   MODULE_GAMESERVER then
	LaborDay:LoadNpc();
end

