function [sfn] = CNAgetSFNetwork(cnap)
%
% CellNetAnalyzer: API function CNAgetSFNetwork
%
%       --> all those attributes (fields) from a CNA
%       signal-flow project are copied into a new struct
%       variable, that define the network topology
%
% Usage:  sfn = CNAgetSFNetwork(cnap)
%
% Input: cnap is a CNA mass-flow project structure
%
% Output: sfn: all those fields of the signal-flow project cnap are copied
%         into sfn that define the topology and related attributes of the
%         network. In particular, GUI-related fields are not copied.
%
% This function provides a convenient way to copy/export the network structure
% of a CNA mass-flow project into a new variable that can be further used
% outside CellNetAnalyzer. GUI related or temporary (local) fields will not
% be duplicated.
%
% See also manual for field names of a signal-flow project structure in CNA.

sfn=[];

if(~isfield(cnap,'type'))
        disp(['Field ''type'' not defined. Not a CellNetAnalyzer project.']);
        return;
elseif(cnap.type~=2)
        disp('Error: network ''type'' is not signal-flow.');
        return;
end


sfn.nums=cnap.nums;
sfn.numr=cnap.numr;
sfn.interMat=cnap.interMat;
sfn.notMat=cnap.notMat;
sfn.specLongName=cnap.specLongName;
sfn.specNotes=cnap.specNotes;
sfn.specID=cnap.specID;
sfn.specDefault=cnap.specDefault;
sfn.reacID=cnap.reacID;
sfn.reacNotes=cnap.reacNotes;
sfn.reacDefault=cnap.reacDefault;
sfn.incTruthTable=cnap.incTruthTable;
sfn.excludeInLogical=cnap.excludeInLogical;
sfn.timeScale=cnap.timeScale;
sfn.nonotony=cnap.monotony;

