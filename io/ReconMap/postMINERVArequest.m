function [ response ] = postMINERVArequest(minerva_servlet, login, password, model, identifier, content)

% Sends a new layout to a MINERVA instance
% 
%
% INPUT
%
% minerva_servlet           Struct with the information of minerva instance:
%                           address, login, password and model (map)
% login                     MINERVA username   
% password                  MINERVA password
% model                     MINERVA map
% identifier                Layout name
% content                   Content of the layout
%
% OUTPUT
% 
% response                  MINERVA's response
% 
% Alberto Noronha Jan/2016
    
   content = {'identifier', identifier, 'login', login, 'password', password, 'model', model, 'expression_value', content};
   response = urlread(minerva_servlet, 'POST', content);
   
end

