function sbmlTestModelToMat(folder)
%function to translate a batch of sbml files in .xml format, into cobra
%toolbox compatible models, saving each as a .mat file in the same folder
%containing one 'model' structure derived from the corresponding .xml file
%
%25/11/14 Ronan Fleming, first version.

%choose the folder within the folder 'testModels' where the .xml files are located
if ~exist('folder', 'var')
    folder='m_model_collection';
end

%choose the printLevel
printLevel=1; %only print out names of models that don't parse

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global CBTDIR
if isempty(CBTDIR)
    tmp=which('initCobraToolbox');
    CBTDIR=tmp(1:end-length('/initCobraToolbox.m'));
end

modelDir=[CBTDIR filesep 'testing' filesep 'testModels' filesep folder];
files=dir(modelDir);

for k=3:length(files)
    if strcmp(files(k).name(end-2:end),'xml')
        %read in the xml file
        fileName=files(k).name;
        if ~exist([fileName(1:end-3) 'mat'],'file')
            filePathName=[modelDir filesep fileName];
            %save as mat file in the same directory
            savedMatFile=[CBTDIR filesep 'testing' filesep 'testModels' filesep folder filesep fileName(1:end-4) '.mat'];
            try
                defaultBound=1000;
                fileType='SBML';
                model = readCbModel(filePathName,defaultBound,fileType);
                %disp(savedMatFile)
                save(savedMatFile,'model');
                if printLevel>1
                    fprintf('%s%s\n',fileName, [' :compatible with readCbModel'])
                end
            catch
                if printLevel>0
                    fprintf('%s%s\n',fileName, [' :incompatible with readCbModel'])
                end
                %should not leave half finished files around if there are
                %any
                if exist(savedMatFile,'file')
                    rmfile(savedMatFile)
                end
            end
        else
            if strcmp(fileName,'textbook.xml')
                pause(eps)
            end
            if printLevel>1
                fprintf('%s%s\n',fileName, [' :already parsed and compatible with readCbModel'])
            end
        end
    end
end











