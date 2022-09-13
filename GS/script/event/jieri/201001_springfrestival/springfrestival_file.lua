-- 文件名　：file.lua
-- 创建者　：jiazhenwei
-- 创建时间：2009-12-28 17:24:41
-- 描  述  ：

Require("\\script\\event\\jieri\\201001_springfrestival\\springfrestival_def.lua");
SpecialEvent.SpringFrestival = SpecialEvent.SpringFrestival or {};
local SpringFrestival = SpecialEvent.SpringFrestival or {};

function SpringFrestival:LoadCouplet()
	local tbFile = Lib:LoadTabFile("\\setting\\event\\jieri\\201001_springfrestival\\couplet.txt");
	if not tbFile then
		print("【新年】读取文件错误，文件不存在couplet.txt");
		return;
	end
	for nId, tbParam in ipairs(tbFile) do
		if nId >= 1 then
			local szTital  = tbParam.Tital;
			local szUp  = tbParam.Up;
			local szDown = tbParam.Down;	
			if not SpringFrestival.tbCoupletList then
				SpringFrestival.tbCoupletList = {};
			end
			SpringFrestival.tbCoupletList[nId] = {}
			SpringFrestival.tbCoupletList[nId][1] = szTital;
			SpringFrestival.tbCoupletList[nId][2] = szUp;
			SpringFrestival.tbCoupletList[nId][3] = szDown;
		end
	end
	
	if  not MODULE_GAMESERVER then
		return;
	end
	
	tbFile = Lib:LoadTabFile("\\setting\\event\\jieri\\201001_springfrestival\\huadeng.txt");
	if not tbFile then
		print("【新年】读取文件错误，文件不存在huadeng.txt");
		return;
	end
	for nId, tbParam in ipairs(tbFile) do
		local nIndex = tonumber(tbParam.Index) or 0;		
		SpringFrestival.HUADENG[nIndex] = SpringFrestival.HUADENG[nIndex] or {};
		SpringFrestival.HUADENG[nIndex].nMapId = tonumber(tbParam.MapId);
		local tbFile2 = Lib:LoadTabFile("\\setting\\event\\jieri\\201001_springfrestival\\huadeng\\"..tbParam.File);
		if not tbFile2 then
			print("【新年】读取文件错误，文件不存在 huadeng\\"..tbParam.File);
			return;	
		end
		for nId2, tbParam2 in ipairs(tbFile2) do			
			SpringFrestival.HUADENG_POS[nIndex] = SpringFrestival.HUADENG_POS[nIndex] or {};
			local nX = math.floor((tonumber(tbParam2.TRAPX) )/32);
			local nY = math.floor((tonumber(tbParam2.TRAPY) )/32);			
			table.insert(SpringFrestival.HUADENG_POS[nIndex], {nX, nY});
		end				
	end
end

SpringFrestival:LoadCouplet();
