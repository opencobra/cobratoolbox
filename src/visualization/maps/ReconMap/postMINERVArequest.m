function [ response ] = postMINERVArequest(login, password, map, googleLicenseContent, identifier, content)
% Sends a new layout to a MINERVA instance
%
% USAGE:
%
%    [response] = postMINERVArequest(minerva_servlet, login, password, map, identifier, content)
%
% INPUTS:
%    minerva_servlet:           URL
%    login:                     MINERVA username
%    password:                  MINERVA password
%    map:                       MINERVA map
% .  googleLicenseContent:      True if user agreed to Google Maps terms of
% use: https://cloud.google.com/maps-platform/terms/
%    identifier:                Layout name
%    content:                   Content of the layout
%
% OUTPUT:
%    response:                  MINERVA's response - cell array index 1 - 0/1
%                               whether the overlay was successfully uploaded.
%                               index 2 - success or error message
%
% .. Author: - Alberto Noronha Jan/2016



%    content = {'identifier', identifier, 'login', login, 'password', password, 'model', map, 'expression_value', content};
%    xmlresponse = urlread(minerva_servlet, 'POST', content);

    headerlength = ' ';
   loginURL = strcat({'curl'}, {headerlength} , {'-X POST -c - --data "login='}, login, {'&password='}, password, {'" https://www.vmh.life/minerva/api/doLogin/'});
   [x , command_out] = system(char(loginURL));
   if isempty(regexp(command_out, 'Invalid credentials'))
       [startIndex,endIndex] = regexp(command_out,'MINERVA_AUTH_TOKEN\s+(.*)$');
       split = strsplit(command_out(startIndex:endIndex), '\t');
       minerva_auth_token = split{2};
       minerva_server = strcat('https://www.vmh.life/minerva/api/projects/', map, '/overlays/');
       filename = strcat(identifier, '.txt');
       curl_str = strcat({'curl'}, {headerlength}, '-X POST --data "content=', content, '&description=', identifier ,'&filename=', filename, '&name=', identifier, {'&googleLicenseConsent='}, googleLicenseContent, {'" --cookie "MINERVA_AUTH_TOKEN='}, minerva_auth_token, {'" '}, minerva_server);
       [x , response] = system(char(curl_str));
       if ~isempty(regexp(response, '"status":"OK"'))
           response = 'Overlay generated successfully!'
       end
   else
       response = 'Invalid credentials. Please make sure your login and password are correct.';
   end
end
