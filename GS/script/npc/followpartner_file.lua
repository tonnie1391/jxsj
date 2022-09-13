-- 文件名　：followpartner_file.lua
-- 创建者　：jiazhenwei
-- 创建时间：2012-05-23 09:14:33
-- 功能    ：跟宠配置表读取


Npc.tbFollowPartner = Npc.tbFollowPartner or {};
local tbFollowPartner = Npc.tbFollowPartner;

function tbFollowPartner:ReadFile()	
	local tbFile = Lib:LoadTabFile("\\setting\\npc\\followpartner.txt");
	if not tbFile then
		print("【宠物系统】读取文件错误，文件不存在\\setting\\npc\\followpartner.txt");
		return;
	end	
	for nId, tbParam in ipairs(tbFile) do
		if nId > 1 then
			local nIndex = tonumber(tbParam.Index) or 0;
			local nType = tonumber(tbParam.Type) or 0;
			local nRandomSpeedTotal = tonumber(tbParam.RandomSpeedTotal) or 0;
			local nRandomSpeed = tonumber(tbParam.RandomSpeed) or 0;
			local szAwardType  = tbParam.AwardType or "";
			local szTaskType  = tbParam.TaskType or "";
			local szAwardTypeEx  = tbParam.AwardTypeEx or "";
			local szAwardTypeEx2  = tbParam.AwardTypeEx2 or "";
			local nAwardTotal = tonumber(tbParam.AwardTotal) or 0;
			local nAwardMax = tonumber(tbParam.AwardMax) or 0;
			local nAwardMin = tonumber(tbParam.AwardMin) or 0;
			local nAwardRandomMax = tonumber(tbParam.AwardRandomMax) or 0;
			local nAwardRandomMin = tonumber(tbParam.AwardRandomMin) or 0;
			local nSpeakTotal = tonumber(tbParam.SpeakTotal) or 0;
			local nSpeakNum = tonumber(tbParam.SpeakNum) or 0;
			local nSkillTotal = tonumber(tbParam.SkillTotal) or 0;
			local nSkillNum = tonumber(tbParam.SkillNum) or 0;
			local nRandomSkillId = tonumber(tbParam.RandomSkillId) or 0;
			local nRandomSkillLevel = tonumber(tbParam.RandomSkillLevel) or 0;
			local szSkillType  = tbParam.SkillType or "";
			local szItemChat  = tbParam.ItemChat or "";
			local szAwardChat  = tbParam.AwardChat or "";
			local szItemTip = tbParam.ItemTip or "";
			local szAwardItem = tbParam.AwardItem or "";
			local tbMsgChat = {};
			for i =1, 10 do
				local szFollowChat  = tbParam["FollowChat"..i] or "";
				if szFollowChat ~= "" then
					table.insert(tbMsgChat, szFollowChat);
				end
			end
			if nIndex > 0 then
				self.tbFollowPartner = self.tbFollowPartner or {};
				self.tbFollowPartner[nIndex] = {nRandomSpeedTotal, nRandomSpeed, nSpeakTotal, nSpeakNum, nType, nAwardTotal, szAwardType, szAwardTypeEx, nAwardMax, nAwardRandomMax, nAwardRandomMin, nAwardMin, szTaskType, nSkillTotal, nSkillNum, szAwardTypeEx2, szAwardItem};
				self.tbFollowSkill = self.tbFollowSkill or {};
				self.tbFollowSkill[nIndex] = {nRandomSkillId, nRandomSkillLevel, szSkillType};
				if #tbMsgChat > 0 then
					self.tbFollowChat = self.tbFollowChat or {};
					self.tbFollowChat[nIndex] = tbMsgChat;
				end
				if szItemChat ~= "" then
					self.tbItemChat = self.tbItemChat or {};
					self.tbItemChat[nIndex] = szItemChat;
				end
				if szAwardChat ~= "" then
					self.tbFollowAwardChat = self.tbFollowAwardChat or {};
					self.tbFollowAwardChat[nIndex] = szAwardChat;
				end
				if szItemTip ~= "" then
					self.tbClientTip = self.tbClientTip or {};
					self.tbClientTip[nIndex] = szItemTip;
				end
			end
		end
	end
	return 1;
end
tbFollowPartner:ReadFile();

