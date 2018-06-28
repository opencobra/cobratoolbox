function setupxlwrite()
%setupxlwrite setup all folders and pathes necessary to use xlwrite from Matlab file Exchange.
% 
% USAGE:
%
%    setupxlwrite()
% NOTE:
% This function will look for the external folder 
% .. Author: - Thomas Pfau May 2017

global CBTDIR
if strcmp(which('xlwrite'),'')    
    if isempty(CBTDIR)
        initCobraToolbox
    end
    xlwritepath = [CBTDIR filesep 'External' filesep 'xlwrite'];
    addpath(xlwritepath);    
end    
    % Check if POI lib is loaded
    
if exist('org.apache.poi.ss.usermodel.WorkbookFactory', 'class') ~= 8 ...
    || exist('org.apache.poi.hssf.usermodel.HSSFWorkbook', 'class') ~= 8 ...
    || exist('org.apache.poi.xssf.usermodel.XSSFWorkbook', 'class') ~= 8        
    oldfolder = pwd;
    folder = fileparts(which('xlwrite'));
    cd(folder);
    addpath([ folder filesep 'poi_library']);
    javaaddpath(['poi_library' filesep 'poi-3.8-20120326.jar']);
    javaaddpath(['poi_library' filesep 'poi-ooxml-3.8-20120326.jar']);
    javaaddpath(['poi_library' filesep 'poi-ooxml-schemas-3.8-20120326.jar']);
    javaaddpath(['poi_library' filesep 'xmlbeans-2.3.0.jar']);
    javaaddpath(['poi_library' filesep 'dom4j-1.6.1.jar']);
    cd(oldfolder);
end

end
