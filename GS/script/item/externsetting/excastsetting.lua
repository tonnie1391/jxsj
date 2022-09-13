------------------------------------------------------
-- 文件名　：excastsetting.lua
-- 创建者　：dengyong
-- 创建时间：2012-02-13 18:01:12
-- 描  述  ：ex装备相关
------------------------------------------------------

Item.EX_CAST_SETTING_FILE	 = "\\setting\\item\\001\\extern\\change\\exequipcastsetting.txt"


-- 额外前缀
function Item:GetExNamePreFix(nDetail, nRefineLevel, nCastLevel, nSex)
	if not self.tbExCastSetting or not self.tbExCastSetting[nDetail] or 
		not nCastLevel or not nRefineLevel  or not nSex then
		return "";
	end
	
	local tb = self.tbExCastSetting[nDetail];
	local _tbCast = tb["Cast"] or {};
	local _tbRefine = tb["Refine"] or {};
	
	local szRefine = _tbRefine[nRefineLevel] or "";
	local szCast = _tbCast[nCastLevel] and _tbCast[nCastLevel][nSex + 1] or "";
	
	return szRefine..szCast; 
end

-- 精铸规则对应的强化属性组ID
function Item:GetExCastEnhId(nDetail, nCastLevel)
	if not self.tbExCastSetting or not self.tbExCastSetting[nDetail] then
		return 0;
	end
	
	local tb = self.tbExCastSetting[nDetail];
	local _tbCast = tb["Cast"];
	if not _tbCast or not _tbCast[nCastLevel] then
		return 0;
	end
	
	return tonumber(_tbCast[nCastLevel][3]) or 0;
end

-- 精铸对应表
function Item:LoadExCastSetting()
	local tbFile = Lib:LoadTabFile(self.EX_CAST_SETTING_FILE);
	if not tbFile then
		assert(false, self.EX_CAST_SETTING_FILE.." load failed!");
	end
	
	self.tbExCastSetting = {};
	for i, tbData in pairs(tbFile) do
		if i ~= 1 then	-- 实体的第一行是描述
			local nType = assert(tonumber(tbData.DetailType));
			
			local nIndex = 1;
			local _tbInfo = {};
			while(tbData["Cast"..nIndex.."NameMa"] and tbData["Cast"..nIndex.."NameFm"] and tbData["Cast"..nIndex.."Id"]) do  -- 要求nIndex连续
				_tbInfo["Cast"] = _tbInfo["Cast"] or {};
				table.insert(_tbInfo["Cast"], { tbData["Cast"..nIndex.."NameMa"], tbData["Cast"..nIndex.."NameFm"], tbData["Cast"..nIndex.."Id"] });
				nIndex = nIndex + 1;
			end
			
			nIndex = 1;
			while(tbData["Refine"..nIndex.."Name"]) do
				_tbInfo["Refine"] = _tbInfo["Refine"] or {};
				table.insert(_tbInfo["Refine"], tbData["Refine"..nIndex.."Name"]);
				nIndex = nIndex + 1;
			end
			
			self.tbExCastSetting[nType] = _tbInfo;			
		end
	end
end

Item:LoadExCastSetting();