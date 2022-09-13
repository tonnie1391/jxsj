-- 文件名　：questionnaires.lua
-- 创建者　：sunduoliang
-- 创建时间：2009-12-17 09:47:03
-- 描述　  ：调查问卷

SpecialEvent.Questionnaires = SpecialEvent.Questionnaires or {};
local tbQuest = SpecialEvent.Questionnaires;

function tbQuest:GetGblBuf()
	self.tbGblBuf = self.tbGblBuf or {};
	return self.tbGblBuf;
end

function tbQuest:SetGblBuf(tbBuf)
	self.tbGblBuf = tbBuf;
	SetGblIntBuf(GBLINTBUF_QUEST_PLIAYERLIST, 0, 1, tbBuf);              --set buff 
end
