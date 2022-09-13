-- 文件名  : beautyhero_file.lua
-- 创建者  : zounan
-- 创建时间: 2010-09-20 14:27:03
-- 描述    : 
--require


-- 读取各个比赛场地的随机进入点
function BeautyHero:LoadArenaRange(szFullPath)
	self.tbArenaRange = {}
	local tbNumColName = {ARENA_ID = 1, X = 1, Y = 1, RADII = 1};
	local tbFileData = Lib:LoadTabFile(szFullPath, tbNumColName);
	if not tbFileData then
		print("[ERR]BeautyHero:LoadArenaRange",szFullPath);
		return 0;
	end
	for nIndex, tbRow in pairs(tbFileData) do
		if not self.tbArenaRange[tbRow.ARENA_ID] then
			self.tbArenaRange[tbRow.ARENA_ID] = {}
		end
		local tbPoint = {nX = tbRow.X, nY = tbRow.Y, nR = tbRow.RADII};	-- 中心X,Y,半径
		table.insert(self.tbArenaRange[tbRow.ARENA_ID], tbPoint);
	end
	return 1;
end

-- 淘汰赛定点载入
function BeautyHero:LoadArenaPoint(szFullPath)
	self.tbArenaPoint = {}
	local tbNumColName = {ARENA_ID = 1, X1 = 1, Y1 = 1, X2 = 1, Y2 = 1};
	local tbFileData = Lib:LoadTabFile(szFullPath, tbNumColName);
	if not tbFileData then
		print("[ERR]BeautyHero:LoadArenaPoint",szFullPath);
		return 0;
	end
	for nIndex, tbRow in pairs(tbFileData) do
		self.tbArenaPoint[tbRow.ARENA_ID] = {}	-- 有重复定点则会覆盖
		self.tbArenaPoint[tbRow.ARENA_ID][1] = {tbRow.X1, tbRow.Y1};
		self.tbArenaPoint[tbRow.ARENA_ID][2] = {tbRow.X2, tbRow.Y2};
	end
	return 1;
end

-- 加载奖励箱子的刷点
function BeautyHero:LoadBoxPoint(szFullPath)
	self.tbBoxPoint = {}
	local tbNumColName = {GROUP = 1, X = 1, Y = 1};
	local tbFileData = Lib:LoadTabFile(szFullPath, tbNumColName);
	if not tbFileData then
		print("[ERR]BeautyHero:LoadBoxPoint",szFullPath);
		return 0;
	end
	for nIndex, tbRow in pairs(tbFileData) do
		if not self.tbBoxPoint[tbRow.GROUP] then
			self.tbBoxPoint[tbRow.GROUP] = {}
		end
		local tbPoint = {nX = tbRow.X, nY = tbRow.Y};	-- 中心X,Y,半径
		table.insert(self.tbBoxPoint[tbRow.GROUP], tbPoint);
	end
	return 1;
end


-- 冠军宝箱定点载入
function BeautyHero:LoadGuanjunBaoxiangPoint(szFullPath)
	self.tbGuanjunbaoxiangPoint = {}
	local tbNumColName = {TRAPX = 1, TRAPY = 1,};
	local tbFileData = Lib:LoadTabFile(szFullPath, tbNumColName);
	if not tbFileData then
		print("[ERR]BeautyHero:LoadNpcPoint",szFullPath);
		return 0;
	end
	for nIndex, tbRow in pairs(tbFileData) do
		self.tbGuanjunbaoxiangPoint[#self.tbGuanjunbaoxiangPoint+1] = {math.floor(tbRow.TRAPX/32), math.floor(tbRow.TRAPY/32)};
	end
	return 1;
end


-- 七七定点载入
function BeautyHero:LoadNpcPoint(szFullPath)
	self.tbNpcPoint = {}
	local tbNumColName = {ARENA_ID = 1, TRAPX = 1, TRAPY = 1,};
	local tbFileData = Lib:LoadTabFile(szFullPath, tbNumColName);
	if not tbFileData then
		print("[ERR]BeautyHero:LoadNpcPoint",szFullPath);
		return 0;
	end
	for nIndex, tbRow in pairs(tbFileData) do
		self.tbNpcPoint[tbRow.ARENA_ID] = {math.floor(tbRow.TRAPX/32), math.floor(tbRow.TRAPY/32)};
	end
	return 1;
end

function BeautyHero:InitFile()
	self:LoadArenaRange(self.ARENA_RANGE);	
	self:LoadArenaPoint(self.ARENA_POINT);	-- 读取淘汰定点配置
	self:LoadBoxPoint(self.BOX_POINT);		-- 读取箱子的刷点
	self:LoadNpcPoint(self.QIQI_POINT);
	self:LoadGuanjunBaoxiangPoint(self.GUANJUNBAOXIANG_POINT);
end

BeautyHero:InitFile();
