function [cnap,errval] = CNAgenerateSFNetwork(cnap)
%
% CellNetAnalyzer: API function CNAgenerateSFNetwork
%
% Usage:  [cnap,errval] = CNAgenerateSFNetwork(cnap)
%
% Input: cnap is either empty or a partial or a complete
%        CNA signal-flow project structure
%
% Output: cnap: contains all those fields of a CNA signal-flow project
%       structure that are required to define topology and related parameters
%       of a signal-flow network. (GUI-related fields are not created.)
%       errval: is 0 if no consistency error has been found and nonzero otherwise.
%
% There are two possible ways of calling CNAgenerateSFNetwork:
% i) cnap is empty (or does not have the field "cnap.interMat").
%       Then, an empty CNA project structure of a signal-flow
%       network will be generated and initialized.
% ii) cnap already has some (or even all) fields paramterizing a CNA 
%	signal-flow network. Then, all missing fields will be added 
%	(and initialized with default values) and the consistency of
%       the predefined fields will be checked.
%
% Example: assume you have (only) the interaction matrix and the NOT matrix
%	of a Boolean network somewhere in the MATLAB workspace (for the 
%	definition of the interaction and NOT matrix see manual). Let's call these 
%	matrices I and N, repsectively. Create now a new structure z having 
%	the (only) fields "interMat" and "notMat":
%         z.interMat=I;  z.notMat=N;
% Entering now
%         [z,errval] = CNAgenerateSFNetwork(z)
% will create a CNA signal-flow project structure that contains all the
% fields (such as z.timeScale, z.specID and so on) required for doing
% computations with this network. Non-existing fields are initialized
% with default values.
% Note that GUI-based information (such as text box size or text box color)
% is not added to the structure. So you may use the returned structure only for
% computations that do not access the GUI of CNA.
% You may save the generated network as a CNA project with
%          z=save_net_inter(z);
% but it is necessary specify the save diretory in z.path before.
% (If you register the project (either via project manager or by editing the
% file "networks") you may reload it later with the "Load w/o GUI" button.
% Alternatively, you may add GUI based parameters of the project via the 
%	project manager.)
%
% Note that CNAgenerateSFNetwork(z) will first check whether z has a field
% "interMat". If not, an empty field interMat will be generated and all other
% required fields will be initialized accordingly.
% The correct dimensions of existing fields will be checked. For example, if
% your input variable z has the two fields "interMat" and "notMat" and if
% size(interMat)~=size(notMat) you will get an error message and
% errval will be 1. cnap is then only incompletely generated.
%
% Read also: manual for field names of a CNA signal-flow project structure.

if(~isfield(cnap,'type'))
	disp(['Field ''type'' not defined. Initialized with ''2'' (for signal-flow).']);
	cnap.type=2;
elseif(cnap.type~=2)
	disp('Error: ''type'' is not 2 (i.e. signal-flow) ');
	errval=1;
	return;
end

if(~isfield(cnap,'interMat'))
	disp('Field ''interMat'' not defined. Initialized with empty matrix');
	cnap.interMat=[];
end

if(~isfield(cnap,'nums'))
	disp(['Field ''nums'' not defined. Initialized with ',num2str(size(cnap.interMat,1)),'.']);
	cnap.nums=size(cnap.interMat,1);
elseif(cnap.nums~=size(cnap.interMat,1))
	disp('Error: value for ''nums'' inconsistent with size of ''interMat''');
	errval=1;
	return;
end

if(~isfield(cnap,'numr'))
	disp(['Field ''numr'' not defined. Initialized with ',num2str(size(cnap.interMat,2)),'.']);
	cnap.numr=size(cnap.interMat,2);
elseif(cnap.numr~=size(cnap.interMat,2))
	disp('Error: value for ''numr'' inconsistent with dimension of ''interMat''');
	errval=1;
	return;
end

if(~isfield(cnap,'notMat'))
	disp('Field ''notMat'' not defined. Initialized ''notMat'' as a 1''s matrix (containing no NOTs).');
	cnap.notMat=ones(cnap.nums,cnap.numr);
elseif(any(size(cnap.interMat)~=size(cnap.notMat)))
	disp('Error: dimension of ''notMat'' inconsistent with dimension of ''interMat''');
	errval=1;
	return;
end

if(~isfield(cnap,'specID'))
	disp('Field ''specID'' not defined. Initialized ''specID'' with generic names.');
  cnap.specID= default_names('S', cnap.nums);
elseif(size(cnap.specID,1)~=cnap.nums);
	disp('Error: number of rows in ''specID'' inconsistent with dimension of ''interMat''');
	errval=1;
	return;
end

if(~isfield(cnap,'specLongName'))
	disp('Field ''specLongName'' not defined. Initialized ''specLongName'' with generic names.');
  cnap.specLongName= default_names('Species', cnap.nums);
elseif(size(cnap.specLongName,1)~=cnap.nums);
	disp('Error: number of rows in ''specLongName'' inconsistent with dimension of ''interMat''');
	errval=1;
	return;
end

if(~isfield(cnap,'specNotes'))
	disp('Field ''specNotes'' not defined. Initialized empty ''specNotes''.');
  cnap.specNotes= cell(1, cnap.nums);
  [cnap.specNotes{:}]= deal('');
elseif(size(cnap.specNotes,2)~=cnap.nums);
	disp('Error: number of rows in ''specNotes'' inconsistent with dimension of ''interMat''');
	errval=1;
	return;
end

if(~isfield(cnap,'reacID'))
	disp('Field ''reacID'' not defined. Initialized ''reacID'' with generic names.');
  cnap.reacID= default_names('R', cnap.numr);
elseif(size(cnap.reacID,1)~=cnap.numr);
	disp('Error: number of rows in ''reacID'' inconsistent with dimension of ''interMat''');
	errval=1;
	return;
end

if(~isfield(cnap,'reacNotes'))
	disp('Field ''reacNotes'' not defined. Initialized empty ''reacNotes''.');
  cnap.reacNotes= cell(1, cnap.numr);
  [cnap.reacNotes{:}]= deal('');
elseif(size(cnap.reacNotes,2)~=cnap.numr);
	disp('Error: number of rows in ''reacNotes'' inconsistent with dimension of ''interMat''');
	errval=1;
	return;
end

if(~isfield(cnap,'incTruthTable'))
	disp('Field ''incTruthTable'' not defined. Initialized as a zero vector (all interactions have complete truth tables).');
	cnap.incTruthTable=zeros(1,cnap.numr);
elseif(length(cnap.incTruthTable)~=cnap.numr)
	disp('Error: dimension of ''incTruthTable'' inconsistent with dimension of ''interMat''');
	errval=1;
	return;
end

if(~isfield(cnap,'excludeInLogical'))
	disp('Field ''excludeInLogical'' not defined. Initialized as a zero vector (all interactions will be included in logical calculations).');
	cnap.excludeInLogical=zeros(1,cnap.numr);
elseif(length(cnap.excludeInLogical)~=cnap.numr)
	disp('Error: dimension of ''excludeInLogical'' inconsistent with dimension of ''interMat''');
	errval=1;
	return;
end

if(~isfield(cnap,'timeScale'))
	disp('Field ''timeScale'' not defined. Initialized as a 1''s vector (all interactions have time scale 1)');
	cnap.timeScale=ones(cnap.numr,1);
elseif(length(cnap.timeScale)~=cnap.numr)
	disp('Error: dimension of ''timeScales'' inconsistent with dimension of ''interMat''');
	errval=1;
	return;
end

if(~isfield(cnap,'monotony'))
	disp('Field ''monotony'' not defined. Initialized as a 1''s vector (all interactions are monotone).');
	cnap.monotony=ones(1,cnap.numr);
elseif(length(cnap.monotony)~=cnap.numr)
	disp('Error: dimension of ''monotony'' inconsistent with dimension of ''interMat''');
	errval=1;
	return;
end

if(~isfield(cnap,'reacDefault'))
	disp('Field ''reacDefault'' not defined. Initialized as an NaN vector (empty default values).');
	cnap.reacDefault=NaN(cnap.numr,1);
elseif(length(cnap.reacDefault)~=cnap.numr)
	disp('Error: dimension of ''reacDefault'' inconsistent with dimension of ''interMat''');
	errval=1;
	return;
end

if(~isfield(cnap,'specDefault'))
	disp('Field ''specDefault'' not defined. Initialized as an NaN vector (empty default values).');
	cnap.specDefault=NaN(cnap.nums,1);
elseif(length(cnap.specDefault)~=cnap.nums)
	disp('Error: dimension of ''specDefault'' inconsistent with dimension of ''interMat''');
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
	disp('Error: dimension of ''reacBoxes'' inconsistent with dimension of ''interMat''');
	errval=1;
	return;
end

if(~isfield(cnap,'specBoxes'))
	disp('Field ''specBoxes'' not defined. Initialized with default values.');
	cnap.specBoxes=ones(cnap.nums,6);
	cnap.specBoxes(:,1)=(1:cnap.nums)';
	cnap.specBoxes(:,3)=100;
	cnap.specBoxes(:,4)=NaN;
elseif(size(cnap.specBoxes,1)~=cnap.nums)
	disp('Error: dimension of ''specBoxes'' inconsistent with dimension of ''interMat''');
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

