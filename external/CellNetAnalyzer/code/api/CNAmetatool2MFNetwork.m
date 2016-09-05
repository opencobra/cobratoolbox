function [cnap, errval]= CNAmetatool2MFNetwork(fname)
%
% CellNetAnalyzer API function 'CNAmetatool2MFNetwork'
%
% Usage:  [cnap, errval] = CNAmetatool2MFNetwork(fname)
%
% Input:  fname is the filename of the Metatool input file that is to be
%         converted. if no file name is specified, a dialog box occurs.
%
% Output: the mass-flow project variable cnap (which can afterwards be saved
%	  via CNAsaveMFNetwork) and errval indicating 
%         whether some error occured during conversion (1: error; 
%   	  0: no error). For the type of error check the console output.
%	  

cnap=[];
errval=1

if nargin<1 || isempty(fname)
	[ldat, fpath]=uigetfile('*.dat','Metatool File');
	if(ldat==0) return; end;
	lfi=fopen([fpath,ldat],'r');
	if(lfi==-1)
        	disp(['Error loading file:  ',ldat]);
        	return;
	end
	fname=[fpath,ldat];
end

sys= parse(fname);
if sys.err
  disp('Error: Cannot correctly parse input file');
end
cnap.type= 1;
cnap.specID= char([sys.int_met; sys.ext_met]);
cnap.specLongName= cnap.specID;
cnap.nums= size(cnap.specID, 1);
cnap.numis= length(sys.int_met);
cnap.specExternal= false(1, cnap.nums);
cnap.specExternal(cnap.numis+1:end)= true;
cnap.specInternal= 1:cnap.numis;
cnap.reacID= char(sys.react_name);
cnap.numr= length(sys.react_name);
cnap.reacMax= repmat(Inf, cnap.numr, 1);
cnap.reacMin= zeros(cnap.numr, 1);
cnap.reacMin(~sys.irrev_react)= -Inf;
cnap.stoichMat= [sys.st; sys.ext];
[cnap, errval]= CNAgenerateMFNetwork(cnap);
errval= errval | sys.err;
