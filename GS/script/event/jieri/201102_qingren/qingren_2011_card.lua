-------------------------------------------------------
-- 文件名　：qingren_2011_card.lua
-- 创建者　：zhangjinpin@kingsoft
-- 创建时间：2011-01-07 16:39:08
-- 文件描述：
-------------------------------------------------------

-- 爱神卡
local tbQingren_2011 = {};
local tbItem = Item:GetClass("card2011");

tbQingren_2011.TASK_GID				= 	2151;
tbQingren_2011.TASK_FACTION 		=
{
	[1] = {{1, "少林"}, {2, "天王"}, {3, "唐门"}, {4, "五毒"}},
	[2] = {{5, "峨嵋"}, {6, "翠烟"}, {7, "丐帮"}, {8, "天忍"}},
	[3] = {{9, "武当"}, {10, "昆仑"}, {11, "明教"}, {12, "段式"}},
};
tbQingren_2011.SEX_FLITER			=	{[0] = 1, [1] = 5};

function tbItem:GetTip(nState)
	local szTip = "";
	local nCount = 0;
	local nFliter = tbQingren_2011.SEX_FLITER[me.nSex];
	for _, tbLine in ipairs(tbQingren_2011.TASK_FACTION) do
		for _, tbTaskId in ipairs(tbLine) do
			if tbTaskId[1] ~= nFliter then
				if me.GetTask(tbQingren_2011.TASK_GID, tbTaskId[1]) == 0 then
					szTip = szTip .. string.format("<color=gray>%s<color> ", tbTaskId[2]);	
				else
					nCount = nCount + 1;
					szTip = szTip .. string.format("<color=yellow>%s<color> ", tbTaskId[2]);	
				end
			end
		end
		szTip = szTip .. "\n";
	end
	szTip = szTip .. string.format("<color=yellow>（%s/%s）<color>", nCount , 11);
	return szTip;
end
