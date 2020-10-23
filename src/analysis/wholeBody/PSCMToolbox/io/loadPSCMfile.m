function variable = loadPSCMfile(fileName)
% Loads a mat file into the workspace, given a nickname or a full filename
% Assumes that fileName points to a mat file with a single variable,
% otherwise the set of variables in the mat file are returned as a
% structure, where each field is a variable.
%
% INPUT: 
% fileName:     nickname of .mat file to load
%               or 
%               full name of .mat file to load
% 
% OUTPUT:
% variable:     matlab variable returned

global useSolveCobraLPCPLEX
useSolveCobraLPCPLEX

useReadCbModel = 0;
switch fileName
    case 'Harvey'
        if useSolveCobraLPCPLEX
            %COBRA v2 format
            load Harvey_1_01c
            
            male.subSystems(strmatch('Transport, endoplasmic reticular',male.subSystems,'exact'))={'Transport, endoplasmic reticulum'};
            male.subSystems(strmatch('Arginine and Proline Metabolism',male.subSystems,'exact'))={'Arginine and proline Metabolism'};
            male.subSystems(strmatch(' ',male.subSystems,'exact'))={'Miscellaneous'};
            
            if 1
                %convert to v3 format except for coupling constraints
                male   = convertOldStyleModel(male,0,0);
            end
        else
            if useReadCbModel
                male = readCbModel('Harvey_1_03c', 'fileType','Matlab', 'modelName', 'male');
            else
                %COBRA v3 format
                %load Harvey_1_02c
                load Harvey_1_03c
            end
        end
        if isfield(male,'gender')
            male.sex = male.gender;
            male = rmfield(male,'gender');
        else
            male.sex = 'male';
        end
        if isfield(male,'rxnGeneMat')
            male = rmfield(male,'rxnGeneMat');
        end
        variable = male;
    case 'Harvetta'
        if useSolveCobraLPCPLEX
            %COBRA v2 format
            load Harvetta_1_01c
            
            female.subSystems(strmatch('Transport, endoplasmic reticular',female.subSystems,'exact'))={'Transport, endoplasmic reticulum'};
            female.subSystems(strmatch('Arginine and Proline Metabolism',female.subSystems,'exact'))={'Arginine and proline Metabolism'};
            female.subSystems(strmatch(' ',female.subSystems,'exact'))={'Miscellaneous'};
                        
            if 1
                %convert to v3 format except for coupling constraints
                female = convertOldStyleModel(female,0,0);
            end
        else
            if useReadCbModel
                female = readCbModel('Harvetta_1_03c', 'fileType','Matlab', 'modelName', 'male');
            else
                %COBRA v3 format
                %load Harvetta_1_02c
                load Harvetta_1_03c
            end
        end
        if isfield(female,'gender')
            female.sex = female.gender;
            female = rmfield(female,'gender');
        else
            female.sex = 'female';
        end
        if isfield(female,'rxnGeneMat')
            female = rmfield(female,'rxnGeneMat');
        end
        variable = female;
    case 'Recon3D'
        load Recon3D_Harvey_Used_in_Script_120502
        variable = modelConsistent;
    otherwise
        load(fileName)
        s = whos;
        %attempt to return the file
        variable = s.name;
end


