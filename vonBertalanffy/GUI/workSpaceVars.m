%[VARSINWORKSPACE, VARARGOUT = workSpaceVars(varargin) checks if the variables varargin
% are in the workspace and returns those variables that exist in
% workspace in the cell VARSINWORKSPACE. 
% The inputs are of type string. 
% The variables that do not exist in the workspace are returned in the cell
% varargout
function [varsInWorkspace, notInWorkspace] = workSpaceVars(varargin)
   %get all the workspace variables
   workVars = workspaceInCell();
   disp(length(workVars))

   %variables to check for in the cell VARS
   vars = varargin;
   count_vars = 1;
   
   %varsInWorkspace = cell(1,length(vars));
   %notInWorkspace = cell(1,length(vars));
   
   while count_vars<=length(vars)
      [isin, index] = isInCell(vars{count_vars},workVars);
      if isin==1
          varsInWorkspace{count_vars} = workVars{index};
      else
          notInWorkspace{count_vars-length(varsInWorkspace)} = vars{count_vars};
      end
      count_vars=count_vars+1;
   end
   
end

