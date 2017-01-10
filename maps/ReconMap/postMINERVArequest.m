function [ response ] = postMINERVArequest(minerva_servlet, login, password, map, identifier, content)

% Sends a new layout to a MINERVA instance
% 
%
% INPUT
%
% minerva_servlet           URL
% login                     MINERVA username   
% password                  MINERVA password
% map                       MINERVA map
% identifier                Layout name
% content                   Content of the layout
%
% OUTPUT
% 
% response                  MINERVA's response - cell array index 1 - 0/1
%                           wether the overlay was successfully uploaded. 
%                           index 2 - success or error message
% 
% Alberto Noronha Jan/2016
    
   content = {'identifier', identifier, 'login', login, 'password', password, 'model', map, 'expression_value', content};
   xmlresponse = urlread(minerva_servlet, 'POST', content);
   
   success = strfind(xmlresponse, '<span id="default_form:status">OK</span>');
   response = cell(1,2);
   if isempty(success)
       split = strsplit(xmlresponse, '<span id="default_form:status">');
       split = split{2};
       split = strsplit(split, '</span>');
       split = split{1};
       split = strrep(split, '&quot;', '"');
       response{1,1} = 0;
       response{1,2} = split;
   else
       response{1,1} = 1;
       response{1,2} = 'Overlay was sucessfully sent to ReconMap!';
   end
end

