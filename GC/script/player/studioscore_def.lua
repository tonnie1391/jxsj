--
-- FileName: studioscore_def.lua
-- Author: hanruofei
-- Time: 2011/6/24 9:16
-- Comment:
--

StudioScore.bIsOpen = StudioScore.bIsOpen or true;

StudioScore.tbScoredBuyItems = {}; -- 买东西加分项
StudioScore.tbScoredSellItems = {}; -- 卖东西加分项
StudioScore.tbActivityScores = {}; -- 参加活动加分项

StudioScore.tbScoreSetting = 
{
	buy = {},
	sell = {},
	activity = {},
};

StudioScore.tbTaskId2ScoreItem = {};

function StudioScore:LoadSettingItem(v)
	local Score = tonumber(v.Score);
	if not Score then
		print("Score:" .. tostring(Score) .. "不是合法的数字格式");
		return
	end
	
	local nTaskId = tonumber(v.nTaskId) or 0;
	if nTaskId == 0 and math.floor(Score) ~= Score then
		print("Score是小数，但是nTaskId为0");
		return;
	end
	
	
	return {nTaskId = nTaskId,	Score = Score, nMaxCount = tonumber(v.nMaxCount),}
end

function StudioScore:LoadSetting(szSettingFile)
	local tbData = Lib:LoadTabFile(szSettingFile);
	if not tbData then
		print ("File " .. szSettingFile .. " Load Failed !");
		return;
	end
	
	for i, v in ipairs(tbData) do
		if v.szName == "" then
			print(szSettingFile .. " 第" .. i .. "行未指定szName，跳过");
		elseif v.szType == "" then
			print(szSettingFile .. " 第" .. i .. "行未指定szType，跳过");
		else
			if not self.tbScoreSetting[v.szType]  then
				self.tbScoreSetting[v.szType] = {};
			end
			if self.tbScoreSetting[v.szType][v.szName] then
				print(szSettingFile .. " 第" .. i .. "行指定的szName重复，跳过");
			else
				local tbItem = self:LoadSettingItem(v);
				if tbItem then
					self.tbScoreSetting[v.szType][v.szName] = tbItem;
					local nTaskId = tonumber(v.nTaskId) or 0;
					if nTaskId ~= 0 then
						if self.tbTaskId2ScoreItem[nTaskId]  then
							if self.tbTaskId2ScoreItem[nTaskId].Score ~= tbItem.Score then
								print("同一个TaskId " .. nTaskId .. "对应的项，有不同的Score，错误！");
							end
						else
							self.tbTaskId2ScoreItem[nTaskId] = tbItem;
						end
					end
				end
			end

		end
	end
end

StudioScore:LoadSetting("\\setting\\player\\score_def.txt");

