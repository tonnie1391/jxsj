if not MODULE_GAMESERVER and not MODULE_GAMECLIENT then
	return;
end

-- 自定义关系表
Battle.tbCampCustomRelation = {
	[1] = {			-- 表示一个关系表，1是索引号，只能1～99，应该够用了
		-- 定义一个最大KD_MAX_CAMPROLE*KD_MAX_CAMPROLE (10*10)的矩阵，这里分成多个表来写，否则累死人，
		-- 1是可以敌对，0是不敌对，全是1的表可以不填，类似c++的默认参数调用
		{1, 1, 1, 1, 1},				-- 1号身份 战车
		{1, 1, 1, 1, 0},				-- 2号身份 箭塔
		{1, 1, 1, 1, 0},				-- 3号身份 炮塔
		{1, 0, 0, 1, 0},				-- 4号身份 玩家
		{0, 0, 0, 0, 0},				-- 5号身份 龙脉
	},
}

function Battle:SetCampRelationTable()
	for nIdx, tbRelation in pairs(self.tbCampCustomRelation) do
		if (type(nIdx) ~= "number" or nIdx > 99 or nIdx <= 0) then
			print("Error! invalid relation table index!");
			return;
		end
		if (SetCampCustomRelationTable(nIdx, tbRelation) ~= 0) then
			print("Fail to set relation table!");
		end
	end
end

Battle:SetCampRelationTable();

