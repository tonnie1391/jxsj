-- 神秘家书
local tbBaijiang = Item:GetClass("baijiang");

function tbBaijiang:OnUse()
	local szInfo = "德侩兄亲启：\n"..
	"上月于汉水古渡与金狗遭遇，血战三昼夜，死伤赢野，血流成河。主人夫妇下落不明，余仅以身免，现寄居于一农户家中养伤，无法赶返。\n"..
	"然秋琳姐已于月前护送主人夫妇幼子返乡，请妥善安排，万勿为仇家寻得。古渡之战颇多蹊跷，诸多隐居之前辈高手皆一一现身，其中曲折，\n"..
	"非三言两语可尽，待余归来之日，再述前事。若夏季来临前余仍未返回，则二人性命皆托付于兄，万望念及主人夫妇大恩，保其平安。\n"..
	"                                                                                                                     弟白疆百拜";
	Dialog:Say(szInfo)
	return 0;
end