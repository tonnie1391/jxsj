-- 文件名　：huanxianzhuanyuan.lua
-- 创建者　：jiazhenwei
-- 创建时间：2011-10-26 14:24:10
-- 功能    ：

local tbNpc = Npc:GetClass("huanxianzhuanyuan");

if (not MODULE_GAMESERVER) then
	return;
end

tbNpc.tbMap	= {
	[1] = {2115,  "Linh Tú Thôn (Kênh 1)"},
	[2] = {2116,  "Linh Tú Thôn (Kênh 2)"},
};

tbNpc.tbMap2	= {
	[1] = {2154,  "Đào Khê Trấn (Kênh 1)"},
	-- [2] = {2254,  "Đào Khê Trấn (Kênh 2)"},
};

function tbNpc:OnDialog()
	local szMsg = "Nếu thấy nơi này quá ồn ào, ta có thể đưa ngươi đến nơi vắng vẻ hơn?";
	local tbOpt = {}
	local nMapType = 0;
	for _, tb in ipairs(self.tbMap) do
		if tb[1] ~= me.nMapId then
			table.insert(tbOpt, {tb[2], self.ChangeMap, self, tb[1], 1609, 3268});
		elseif tb[1] == me.nMapId then
			nMapType = 1;
		end
	end
	
	if nMapType == 0 then
		tbOpt = {};
	end
	
	local nMapId, nX, nY = me.GetWorldPos();
	for _, tb in ipairs(self.tbMap2) do
		if tb[1] ~= me.nMapId then
			if (nX - 1814) * (nX - 1814) + (nY - 3476) * (nY - 3476) < 100 then
				table.insert(tbOpt, {tb[2], self.ChangeMap, self, tb[1], 1812, 3472});
			else
				table.insert(tbOpt, {tb[2], self.ChangeMap, self, tb[1], 1678, 3236});
			end
		end
	end
	
	if me.GetTask(2027,230) == 1 or me.GetTask(1000, 528) == 747 then
		table.insert(tbOpt, {"Quay về Vân Trung Trấn", self.ComeBackYunZhong, self});
	end

	table.insert(tbOpt,{"Ta không cần"});
	Dialog:Say(szMsg, tbOpt);
end

function tbNpc:ChangeMap(nMapId, nX, nY)
	me.NewWorld(nMapId,  nX, nY);
end

function tbNpc:ComeBackYunZhong()
	me.NewWorld(1, 1386, 3100);
end
