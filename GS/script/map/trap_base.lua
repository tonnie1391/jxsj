
Map.tbBasePlayerTrap = Map.tbBasePlayerTrap or {};
local tbBasePlayerTrap = Map.tbBasePlayerTrap;

--配置表信息存在临时表中
tbBasePlayerTrap.tbMapTrap = Map.tbBasePlayerTrap.tbMapTrap or {};
tbBasePlayerTrap.tbClassName2Index = tbBasePlayerTrap.tbClassName2Index or {};


-- 载入地图隐身墙的信息
function tbBasePlayerTrap:LoadInfo()
	local tbFileData	= Lib:LoadTabFile("\\setting\\map\\basetrapinfo.txt");
	if not tbFileData then
		print("[地图trap点配置表不对]\\setting\\map\\basetrapinfo.txt");
		return;
	end
	for i, tbRow in pairs(tbFileData) do
		if i > 1 then
			local nMapId       = tonumber(tbRow.MapId);
			local bToFight     = tonumber(tbRow.ToFightState) or 0;
			local bBeProtected = tonumber(tbRow.BeProtected) or 0;
			local szClassName  = tbRow.ClassName;
			local szScript     = tbRow.Script;
			table.insert(self.tbMapTrap,{nMapId,bToFight,bBeProtected,szClassName,szScript})
			self.tbClassName2Index[szClassName] = #self.tbMapTrap;
		end
	end
	self:SetFunction();
end

--定义OnPlayer函数
function tbBasePlayerTrap:SetFunction()
	if not self.tbMapTrap then
		return 0;
	end
	for _, tbInfo in pairs(self.tbMapTrap) do
		if(tbInfo[1] and tbInfo[4]) then
			local tbMap = Map:GetClass(tbInfo[1]); -- 地图Id
			local tbTrap = tbMap:GetTrapClass(tbInfo[4]);
			tbTrap.OnPlayer = function(tbTrap)
				local tbTrapInfo = Map.tbBasePlayerTrap.tbMapTrap[Map.tbBasePlayerTrap.tbClassName2Index[tbTrap.szName]];
				if not tbTrapInfo then
					return 0;
				end
				local nToFight     = tonumber(tbTrapInfo[2]);
				local nBeProtected = tonumber(tbTrapInfo[3]) or 0;
				local szScript     = tbTrapInfo[5] or "";
				if nToFight and (nToFight == 0 or nToFight == 1) then
					if me.nFightState ~= nToFight then
						if nToFight == 1 then
							Dialog:SendBlackBoardMsg(me, "Tiến vào khu vực luyện công!");
						else
							Dialog:SendBlackBoardMsg(me, "Rời khỏi khu vực luyện công!");
						end
					end
					me.SetFightState(nToFight);
				end
				if nBeProtected and nBeProtected > 0 then
					Player:AddProtectedState(me, nBeProtected);
				end
				if szScript ~= "" then
					 loadstring(szScript)();
				end
			end
		end
	end
end

--启动载入脚本
tbBasePlayerTrap:LoadInfo();


