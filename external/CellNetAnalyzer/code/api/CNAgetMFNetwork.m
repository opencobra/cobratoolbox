function [mfn]= CNAgetMFNetwork(cnap,biocomp)
%
% CellNetAnalyzer: API function CNAgetMFNetwork
% 	--> all those attributes (fields ) from a CNA 
%	mass-flow project are copied into a new struct 
%	variable, that define the network topology
%
% Usage:  mfn = CNAgetMFNetwork(cnap,biocomp)
%
% Input: cnap is a CNA mass-flow project structure   
%        biocomp is (cnap.nummac,1) vector defining the biomass
%                composition; if macromolecules have not been
%		 defined in the project set biocomp=[] (Default:cnap.macroDefault);
% 
% Output: mfn: all those fields of the mass-flow project cnap are copied 
%	  into mfn that define the topology and related parameters of the 
%	  network. In particular, GUI-related fields are not copied.
%
%	  If the network has macromeolecules (and uses thus CNA's biomass 
%	  synthesis reaction 'mue'), the vector biocomp will be used
%	  together with cnap.macroComposition to calculate the stoichiometry 
%	  of reaction 'mue' which is then inserted into the column with the  
%	  index stored in cnap.mue.
%
% This function provides a convenient way to copy/export the network structure	 
% of a CNA mass-flow project. GUI related or temporary (local) fields are not
% duplicated. 
%
% See also manual for field names of a mass-flow project structure in CNA.

mfn=[];

if(nargin<2)
	biocomp=cnap.macroDefault;
end

if(~isfield(cnap,'type'))
	disp(['Field ''type'' not defined. Not a CellNetAnalyzer project.']);
	return;
elseif(cnap.type~=1)
	disp('Error: network ''type'' is not mass-flow.');
	return;
end

if(~isempty(cnap.mue))
	if(length(biocomp)~=cnap.nummac)
       		disp('Dimension of vector of macro composition not consistent with cnap.nummac.');
		return;
	elseif(size(biocomp,1)~=cnap.nummac)
               	biocomp=biocomp';
       	end
       	mfn.stoichMat=initsmat(cnap.stoichMat,cnap.mue,cnap.macroComposition,biocomp,1:cnap.nums);
else
	if(~isempty(biocomp))
       		disp('cnap.mue is empty - ignoring biomass composition.');
	end
	mfn.stoichMat=cnap.stoichMat;
end

mfn.nums=cnap.nums;
mfn.numr=cnap.numr;
mfn.numis=cnap.numis;
mfn.nummac=cnap.nummac;
mfn.specLongName=cnap.specLongName;
mfn.specNotes=cnap.specNotes;
mfn.specExternal=cnap.specExternal;
mfn.specInternal=cnap.specInternal;
mfn.specID=cnap.specID;
mfn.reacID=cnap.reacID;
mfn.reacNotes=cnap.reacNotes;
mfn.objFunc=cnap.objFunc;
mfn.reacMin=cnap.reacMin;
mfn.reacMax=cnap.reacMax;
mfn.reacVariance=cnap.reacVariance;
mfn.reacDefault=cnap.reacDefault;
mfn.mue=cnap.mue;
mfn.macroID=cnap.macroID;
mfn.macroLongName=cnap.macroLongName;
mfn.macroComposition=cnap.macroComposition;
mfn.macroDefault=cnap.macroDefault;
