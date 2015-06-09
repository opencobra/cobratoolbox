function result = CNAloadNetwork(network,no_gui,return_cnap)
%
% CellNetAnalyzer: API function CNAloadNetwork
%
% --> loads a CNA network project
%
% Usage:  result = CNAloadNetwork(network,no_gui,return_cnap)
% 
% Input:
%    network (mandatory):
% 	- if isempty(network) == true then the network selected 
%	  by the project manager is chosen (which must have been loaded);
%       - if network is a number then the corresponding network as 
%	  specified in the cnan.net list (based on the 'networks' file) 
%	  is loaded.
%       - network can also be a cell array with {directory, type} 
%	  specifying the network to be loaded: 
%		directory: string specifying the directory (relative 
%			   or absolute path) 
%		type: 1=mass-flow; 2=signal-flow
%
%    no_gui (optional, default: false): 
%	- whether the project is to be loaded with or without GUI
%         (note that networks generated with CNAgenerateS(M)FNetworks
%         and saved with CNAsaveNetworks without registering it via
%         the project manager cannot be loaded with GUI)
%
%    return_cnap (optional, default: false): 
%	- whether a CNA project variable should be returned
%
%  It is assumed that cnan has been set up appropriately, e.g. by calling
%  startcna.
%
%  Output:
%    result:
%     The result depends on return_cnap which can only be set to true if no_gui
%     is true; if return_cnap is true then a CNA project variable is returned,
%     otherwise it is instantiated in the base workspace with the variable
%     name based on the directory name of the project. In the first case a
%     value of cnap.local.errval > 0 indicates an error. In the latter case the
%     variable name of the new project variable is returned as string in case of
%     success or an empty string in case of failure.

if nargin < 3
  return_cnap= false;
  if nargin < 2
    no_gui= false;
  end
end

result = net_init(network,no_gui,return_cnap);
