print("begin load vfactory.lua")

if (not VFactory.tbDefault ) then
	VFactory.tbDefault = {};
end	

VFactory.tbClass={}		-- 存放tbClass[szClassName]=Class
VFactory.tbMapClass={}
VFactory.bInit = false;

--获取szClassName指定类
function VFactory:LoadFile(szFileName)	
	if (self.bInit == true) then
		return
	end
	
	print("begin load vfactory.txt");
	
	local tbFileData = KLib.LoadTabFile(szFileName);
	for  nRow = 2, #tbFileData do
		local szBaseClass = tbFileData[nRow][1];
		local szDerivedClass = tbFileData[nRow][2];
	
		--创建基类
		local tbBaseClass = self.tbClass[szBaseClass];
		if (not tbBaseClass) then
			tbBaseClass = Lib:NewClass(self.tbDefault);
			self.tbClass[szBaseClass]	= tbBaseClass;
		end
		
		--创建派生类
		local tbDerivedClass = self.tbClass[szDerivedClass];
		if (not tbDerivedClass) then
			tbDerivedClass = Lib:NewClass(tbBaseClass);
			self.tbClass[szDerivedClass] = tbDerivedClass;
		end
		
		--加入映射表
		if (not self.tbMapClass[szBaseClass]) then
			self.tbMapClass[szBaseClass] = tbDerivedClass;
		end		
	end	
	
	self.bInit = true;
end	

function VFactory:GetClass(szClassName)
	self:LoadFile("\\setting\\scriptvalue\\vfactory.txt");
	local tbClass = self.tbClass[szClassName];
	if (not tbClass) then
		self.tbClass[szClassName] = {};
		tbClass = self.tbClass[szClassName];
	end
	return tbClass
end

--根据基类类型，创建当前版本的对象
function VFactory:New(szClassType)
	self:LoadFile("\\setting\\scriptvalue\\vfactory.txt");
	local tbClass = self.tbMapClass[szClassType];
	if (not tbClass) then
		print("请往\\setting\\scriptvalue\\vfactory.txt 文件中加入当前版本类");
		return
	end
	return tbClass
end	
