function cnap = CNAsaveNetwork(cnap)
%
% CellNetAnalyzer: API function CNAsaveNetwork
%
% Usage:  cnap = CNAsaveNetwork(cnap)
%
% Input: cnap is a CNA mass-flow or signal-flow project.
%        It must have all essential fields required
%	 to store a CNA mass flow project. For example,
%	 a project variable created by CNAgenerateMFNetwork
%	 or CNAgenerateSFNetwork is sufficient.
%	 Note that the cnap.path field must be set to an
%        appropriate directory (absolute or relative path)
%        where the project files will be saved. Existing
%        project files will be overwritten! If the directory
%        does not exist then it will be created.
%
% Output: A CNA network project.

if(cnap.type==1)
	cnap=save_net(cnap);
else
	cnap=save_net_inter(cnap);
end

