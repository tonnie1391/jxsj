local tbItem = Item:GetClass("snowbox");

SpecialEvent.Xmas2008 = SpecialEvent.Xmas2008 or {};
SpecialEvent.Xmas2008.XmasSnowman = SpecialEvent.Xmas2008.XmasSnowman or {};
local XmasSnowman = SpecialEvent.Xmas2008.XmasSnowman;
tbItem.RandomItem = {
	{{18,1,269,1},35},            --袜子
	{{18,1,270,1},10},            --盒子
	{{18,1,271,1},55},	          --糖果
	};

function tbItem:OnUse(nNpcId)
	if me.CountFreeBagCell() < 1 then
		me.Msg("您的包裹空间不足");
		return;
	end
	local nRandom = MathRandom(1, 100);
	for i = 1, #self.RandomItem do
		if self.RandomItem[i][2] >= nRandom then
			print(i);
			local pItem = me.AddItem(unpack(self.RandomItem[i][1]));
			if pItem then
				pItem.Bind(1);
				me.SetItemTimeout(pItem, 30*24*60, 0);
			end
			break;
		end
		nRandom = nRandom - self.RandomItem[i][2];
	end	
	return 1;
end	

