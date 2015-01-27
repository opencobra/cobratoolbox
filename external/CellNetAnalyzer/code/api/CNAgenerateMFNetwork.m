function [cnap, errval]= CNAgenerateMFNetwork(cnap)
%
% CellNetAnalyzer: API function CNAgenerateMFNetwork
%
% Usage:  [cnap, errval] = CNAgenerateMFNetwork(cnap)
%
% Input: cnap is either empty or a partial or a complete
%	  CNA mass-flow project structure   
% 
% Output: cnap: contains all those fields of a CNA mass-flow project
%	  structure that are required to define topology and related parameters
%	  of a mass-flow network. (GUI-related fields are not created.)
%	  errval: is 0 if no consistency error has been found and nonzero otherwise.
% 
% There are two possible ways of calling CNAgenerateMFNetwork:
% i) cnap is empty (or does not have the field "cnap.stoichMat"). 
%	Then, an empty CNA project structure of a mass-flow
%	network will be generated and initialized.
% ii) cnap already has some (or even all) required fields defining
%	the topology of a mass-flow network. Then, all missing fields
%	will be added (with default values) and the consistency of 
%	the predefined fields will be checked. 
%	
% Example: assume you have (only) the stoichiometric matrix of a network 
%	in the MATLAB workspace. Let's call this matrix N. Create
%	now a new structure z having the (only) field "stoichMat": 
%		z.stoichMat=N;
%	Entering now
%		[z,errval] = CNAgenerateMFNetwork(z)
%	will create a CNA mass-flow project structure that contains all the
%	fields (such as z.reacMin, z.reacMax and so on) required for doing
%	computations with this network. Non-existing fields are initialized
%	with default values. 
%	Note that GUI-based information (such as text box size or text box color) 
%	is not added to the structure. So you may use this structure only for 
%	computations that do not access the GUI of CNA. 
%	You may save the generated network as a CNA project with
%		z=save_net(z); 
%	but it is necessary specify the save diretory in z.path before.
%	(If you register the project (either via project manager or by editing the 
%	field "networks" you may reload it later with the "Load w/o GUI" button.
%	Alternatively, you may add GUI based parameters of the project via the project manager.
%
%	Note that CNAgenerateMFNetwork(z) will first check whether z has a field
%	"stoichMat". If not, an empty field stoichMat will be generated and all other
%	required fields will be initialized accordingly.  
%	The correct dimensions of existing fields will be checked. For example, if
%	your input variable z has the two fields "stoichMat" and "reacMin" and if
%	size(stoichMat,2)~=size(reacMin,1) you will get an error message and 
%	errval will be 1. cnap is then only incompletely generated.
%
%	Read also: manual for field names of a mass-flow project structure in CNA.

if(~isfield(cnap,'type'))
	disp(['Field ''type'' not defined. Initialized with ''1'' (for mass-flow).']);
	cnap.type=1;
elseif(cnap.type~=1)
	disp('Error: network ''type'' is not 1 (i.e. not mass-flow) ');
	errval=1;
	return;
end

if(~isfield(cnap,'stoichMat'))
	disp('Field ''stoichMat'' not defined. Initialized with empty matrix.');
	cnap.stoichMat=[];
end

if(~isfield(cnap,'nums'))
	disp(['Field ''nums'' not defined. Initialized with ',num2str(size(cnap.stoichMat,1)),'.']);
	cnap.nums=size(cnap.stoichMat,1);
elseif(cnap.nums~=size(cnap.stoichMat,1))
	disp('Error: value for ''nums'' inconsistent with size of ''stoichMat''');
	errval=1;
	return;
end

if(~isfield(cnap,'numr'))
	disp(['Field ''numr'' not defined. Initialized with ',num2str(size(cnap.stoichMat,2)),'.']);
	cnap.numr=size(cnap.stoichMat,2);
elseif(cnap.numr~=size(cnap.stoichMat,2))
	disp('Error: value for ''numr'' inconsistent with dimension of ''stoichMat''');
	errval=1;
	return;
end

if(~isfield(cnap,'specID'))
	disp('Field ''specID'' not defined. Initialized ''specID'' with generic names.');
  cnap.specID= default_names('S', cnap.nums);
elseif(size(cnap.specID,1)~=cnap.nums);
	disp('Error: number of rows in ''specID'' inconsistent with dimension of ''stoichMat''');
	errval=1;
	return;
end

if(~isfield(cnap,'specLongName'))
	disp('Field ''specLongName'' not defined. Initialized ''specLongName'' with generic names.');
  cnap.specLongName= default_names('Species', cnap.nums);
elseif(size(cnap.specLongName,1)~=cnap.nums);
	disp('Error: number of rows in ''specLongName'' inconsistent with dimension of ''stoichMat''');
	errval=1;
	return;
end

if(~isfield(cnap,'specNotes'))
	disp('Field ''specNotes'' not defined. Initialized empty ''specNotes''.');
  cnap.specNotes= cell(1, cnap.nums);
  [cnap.specNotes{:}]= deal('');
elseif(size(cnap.specNotes,2)~=cnap.nums);
	disp('Error: number of rows in ''specNotes'' inconsistent with dimension of ''stoichMat''');
	errval=1;
	return;
end

if(~isfield(cnap,'specExternal'))
	disp('Field ''specExternal'' not defined. Initialized with zero vector (i.e. all species are configured as internal).');
	cnap.specExternal=zeros(1,cnap.nums);
	cnap.numis=cnap.nums;
	if(isfield(cnap,'specInternal'))
		disp('	Field ''specInternal'' is adapted accordingly.');
	end
	cnap.specInternal=1:cnap.numis;
elseif(length(cnap.specExternal)~=cnap.nums);
	disp('Error: number of elements in ''specExternal'' inconsistent with dimension of ''stoichMat''.');
	errval=1;
	return;
elseif(~isfield(cnap,'specInternal'))
	disp('Field ''specInternal'' not defined. Initialized according to ''specExternal'' entry.');
	cnap.specInternal=find(~cnap.specExternal);
	if(isfield(cnap,'numis'))
		disp('	Field ''numis'' is adapted accordingly.');
	end
	cnap.numis=length(cnap.specInternal);
elseif(~isfield(cnap,'numis'))
	disp('Field ''numis'' not defined. Initialized according to ''specInternal'' entry.');
	cnap.numis=length(cnap.specInternal);
elseif(length(cnap.specInternal)~=cnap.numis)
	disp('Error: number of elements in ''specInternal'' inconsistent with ''numis''.');
	errval=1;
	return;
end

zw=find(cnap.specExternal==0);
if(length(zw)~=cnap.numis)
	disp('Error: entries in ''specExternal'' inconsistent with number of internal species (''numis'').');
	errval=1;
	return;
elseif(sum(zw-cnap.specInternal)~=0)
	disp('Error: entries in ''specExternal'' inconsistent with entries in ''specInternal''.');
	errval=1;
	return;
end


if(~isfield(cnap,'reacID'))
	disp('Field ''reacID'' not defined. Initialized ''reacID'' with generic names.');
  cnap.reacID= default_names('R', cnap.numr);
elseif(size(cnap.reacID,1)~=cnap.numr);
	disp('Error: number of rows in ''reacID'' inconsistent with dimension of ''stoichMat''');
	errval=1;
	return;
end

if(~isfield(cnap,'reacNotes'))
	disp('Field ''reacNotes'' not defined. Initialized empty ''reacNotes''.');
  cnap.reacNotes= cell(1, cnap.numr);
  [cnap.reacNotes{:}]= deal('');
elseif(size(cnap.reacNotes,2)~=cnap.numr);
	disp('Error: number of rows in ''reacNotes'' inconsistent with dimension of ''stoichMat''');
	errval=1;
	return;
end

if(~isfield(cnap,'objFunc'))
	disp('Field ''objFunc'' not defined. Initialized with zero vector (= objective function).');
	cnap.objFunc=zeros(cnap.numr,1);
elseif(size(cnap.objFunc,1)~=cnap.numr)
	disp('Error: dimension of ''objFunc'' inconsistent with dimension of ''stoichMat''');
	errval=1;
	return;
end

if(~isfield(cnap,'reacMin'))
	disp('Field ''reacMin'' not defined. Initialized with zero vector (all reactions treated as irreversible).');
	cnap.reacMin=zeros(cnap.numr,1);
elseif(size(cnap.reacMin,1)~=cnap.numr)
	disp('Error: dimension of ''reacMin'' inconsistent with dimension of ''stoichMat''');
	errval=1;
	return;
end

if(~isfield(cnap,'reacMax'))
	disp('Field ''reacMax'' not defined. Initialized with Inf vector (reaction rate is unlimited for all reactions ).');
	cnap.reacMax= repmat(Inf, cnap.numr,1);
elseif(size(cnap.reacMax,1)~=cnap.numr)
	disp('Error: dimension of ''reacMax'' inconsistent with dimension of ''stoichMat''');
	errval=1;
	return;
end

if(~isfield(cnap,'reacVariance'))
	disp('Field ''reacVariance'' not defined. Initialized for all reactions a variance level of 0.01.');
	cnap.reacVariance=0.01*ones(cnap.numr,1);
elseif(size(cnap.reacVariance,1)~=cnap.numr)
	disp('Error: dimension of ''reacVariance'' inconsistent with dimension of ''stoichMat''');
	errval=1;
	return;
end

if(~isfield(cnap,'reacDefault'))
	disp('Field ''reacDefault'' not defined. Initialized with NaN vector (empty default values).');
	cnap.reacDefault=NaN(cnap.numr,1);
elseif(length(cnap.reacDefault)~=cnap.numr)
	disp('Error: dimension of ''reacDefault'' inconsistent with dimension of ''stoichMat''');
	errval=1;
	return;
end

zw=mfindstr(cnap.reacID,'mue');
if(zw==0)
	zw=[];
end
if(~isfield(cnap,'mue'))
	disp('Field ''mue'' not defined. Initialized according to existence of string ''mue'' in ''reacID''.');
	cnap.mue=zw;
elseif(~isempty(cnap.mue))
	if(isempty(zw))
		disp('Error: ''mue'' with numerical value although not contained in ''reacID''.');
		errval=1;
		return;
	elseif(zw~=cnap.mue)
		disp('Error: value for ''mue'' not consistent with entry of ''mue'' in ''reacID''.');
		errval=1;
		return;
	end
elseif(~isempty(zw))
	disp('Error: field ''mue'' is empty although string ''mue'' exists in ''reacID''.');
	errval=1;
	return;
end

if(~isfield(cnap,'reacBoxes'))
	disp('Field ''reacBoxes'' not defined. Initialized with default values.');
	cnap.reacBoxes=ones(cnap.numr,6);
	cnap.reacBoxes(:,1)=(1:cnap.numr)';
	cnap.reacBoxes(:,3)=100;
	cnap.reacBoxes(:,4)=NaN;
elseif(size(cnap.reacBoxes,1)~=cnap.numr)
	disp('Error: dimension of ''reacBoxes'' inconsistent with dimension of ''stoichMat''');
	errval=1;
	return;
end

if(~isfield(cnap,'macroComposition'))
	disp('Field ''macroComposition'' not defined. Initialized as empty matrix (no macromolecules defined; other fields related to macromolecules adapted/initialized accordingly).');
	cnap.macroComposition=zeros(cnap.nums,0);
	cnap.macroID=[];
	cnap.macroLongName=[];
	cnap.nummac=[];
	cnap.macroDefault=[];
	cnap.macroBoxes=zeros(0,6);
	cnap.macroSynthBoxes=zeros(0,6);
	cnap.nummacsynth=0;
elseif(size(cnap.macroComposition,1)~=cnap.nums)
	disp('Error: dimension of ''macroComposition'' inconsistent with number of species.');
	errval=1;
	return;
end

if(~isfield(cnap,'nummac'))
	disp('Field ''nummac'' not defined. Initialized according to number of elements in ''macroComposition''.');
	cnap.nummac=size(cnap.macroComposition,2);
elseif(size(cnap.macroComposition,2)~=cnap.nummac)
	disp('Error: value of ''nummac'' inconsistent with dimension of ''macroComposition''');
	errval=1;
	return;
end

if(~isfield(cnap,'macroID'))
	disp('Field ''macroID'' not defined. Initialized with generic names.');
  cnap.macroID= default_names('Mac', cnap.nummac);
elseif(size(cnap.macroID,1)~=cnap.nummac);
	disp('Error: entry in ''nummac'' inconsistent with dimension of ''macroID''');
	errval=1;
	return;
end

if(~isfield(cnap,'macroLongName'))
	disp('Field ''macroLongName'' not defined. Initialized with generic names.');
  cnap.macroLongName= default_names('Macromolecule', cnap.nummac);
elseif(size(cnap.macroLongName,1)~=cnap.nummac);
	disp('Error: entry in ''nummac'' inconsistent with dimension of ''macroLongName''');
	errval=1;
	return;
end

if(~isfield(cnap,'macroDefault'))
	disp('Field ''macroDefault'' not defined. Initialized with zero vector.');
	cnap.macroDefault=zeros(cnap.numr,1);
elseif(length(cnap.macroDefault)~=cnap.nummac)
	disp('Error: dimension of ''macroDefault'' inconsistent with ''nummac''.');
	errval=1;
	return;
end

if(~isfield(cnap,'macroBoxes'))
	disp('Field ''macroBoxes'' not defined. Initialized with default values.');
	cnap.macroBoxes=ones(cnap.nummac,6);
	cnap.macroBoxes(:,1)=(1:cnap.nummac)';
	cnap.macroBoxes(:,3)=200;
	cnap.macroBoxes(:,4)=NaN;
elseif(size(cnap.macroBoxes,1)~=cnap.nummac)
	disp('Error: dimension of ''macroBoxes'' inconsistent with entry in ''nummac''.');
	errval=1;
	return;
end

if(~isfield(cnap,'macroSynthBoxes'))
	disp('Field ''macroSynthBoxes'' not defined. Initialized as empty array.');
	cnap.macroSynthBoxes=zeros(0,6);
end
if(~isfield(cnap,'nummacsynth'))
	disp('Field ''nummacsynth'' not defined. Initialized according to number of rows in ''macroSynthBoxes''.');
	cnap.nummacsynth=size(cnap.macroSynthBoxes,1);
elseif(size(cnap.macroSynthBoxes,1)~=cnap.nummacsynth)
	disp('Error: dimension of ''macroSynthBoxes'' inconsistent with entry in ''nummac''.');
	errval=1;
	return;
end

if(~isfield(cnap,'epsilon'))
	disp(['Field ''epsilon'' not defined. Initialized with ''1e-10''.']);
	cnap.epsilon=1e-10;
end

if(~isfield(cnap,'has_gui'))
	disp(['Field ''has_gui'' not defined. Initialized with ''false''.']);
	cnap.has_gui= false;
end

errval=0;
