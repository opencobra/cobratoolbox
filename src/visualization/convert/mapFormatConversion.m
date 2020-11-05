function mapFormatConversion(fileNameIn,inputFormat,outputFormat)
%convert one map format into another using external tools
%
% Conversion between SBGN-ML, SBML, CellDesigner_SBML, GPML  uses:
% https://minerva.pages.uni.lu/doc/api/15.1/converter/
% Cite:
% Closing the gap between formats for storing layout information in systems biology
% David Hoksza, Piotr Gawron, Marek Ostaszewski, Jan Hasenauer, Reinhard Schneider
% Briefings in Bioinformatics, Volume 21, Issue 4, July 2020, Pages 1249–1260, https://doi.org/10.1093/bib/bbz067

% Conversion between json and others uses:
% https://draeger-lab.github.io/EscherConverter/
% wget https://github.com/draeger-lab/EscherConverter/releases/download/v1.2.1/EscherConverter-1.2.1.jar
% java -jar -Xms8G -Xmx8G -Duser.language=en /home/rfleming/work/sbgCloud/code/escher/EscherConverter.jar --help
% Cite:
% Andreas Dräger, Devesh Khandelwal, Maria Heitmeier
% https://github.com/draeger-lab/EscherConverter
%
%INPUT
% fileName name of input file, assumed to be current directory if full
% directory is not provided
%
% inputFormat: char specifing any of the following output formats
%   SBGN-ML             
%   SBML                
%   CellDesigner_SBML   
%   GPML                
% 
% outputFormat: char specifing any of the following output formats
%   SBGN-ML             
%   SBML                
%   CellDesigner_SBML   
%   GPML
%   json
%
% USAGE EXAMPLE
% fileName= 'iDopa_fol.sbgn';
% inputFormat='SBGN-ML';
% outputFormat='json';
% mapFormatConversion(fileName,inputFormat,outputFormat)

[FILEPATH,NAME,EXTIN]=fileparts(fileNameIn);

if isempty(FILEPATH)
    FILEPATH=pwd;
    fileNameIn= [FILEPATH filesep fileNameIn];
end

data = webread('https://minerva-dev.lcsb.uni.lu/minerva/api/convert/');
if ~exist('fileNameIn','var')
    fprintf('%-20s%s\n','Input format','Parser')
    for n=1:size(data.inputs)
        fprintf('%-20s%s\n',data.inputs(n).available_names{1},data.inputs(n).available_names{2})
    end
    fprintf('\n%-20s%s\n','Output format','Converter')
    for n=1:size(data.outputs)
        fprintf('%-20s%s\n',data.outputs(n).available_names{1},data.outputs(n).available_names{2})
    end
end

for n=1:size(data.inputs)
    acceptedInputs{n}=data.inputs(n).available_names{1};
end
acceptedInputs{end+1}='json';

for n=1:size(data.outputs)
    acceptedOutputs{n}=data.inputs(n).available_names{1};
end
acceptedOutputs{end+1}='json';

if ~any(strcmp(inputFormat,acceptedInputs))
    error(['no support for ' inputFormat])
end
if ~any(strcmp(outputFormat,acceptedOutputs))
    error(['no support for ' outputFormat])
end

switch inputFormat
    case 'json'
        pathToEscherConverter = which('EscherConverter-1.2.1.jar');
        if isempty(pathToEscherConverter)
            error('EscherConverter must be installed, provided in cobratoolbox/binary/all if you: updateCobraToolbox')
        end
end

switch outputFormat
    case 'SBGN-ML'
        EXTOUT = '_SBGN-ML.sbgn';
    case 'SBML'
        EXTOUT = '_SBML.xml';
    case 'CellDesigner_SBML'
        EXTOUT = '_CD.xml';
    case 'GPML'
        EXTOUT = '_GMPL.xml';
    case 'json'
        EXTOUT = '.json';
        pathToEscherConverter = which('EscherConverter-1.2.1.jar');
        if isempty(pathToEscherConverter)
            error('EscherConverter must be installed, provided in cobratoolbox/binary/all if you: updateCobraToolbox')
        end
end

if strcmp(EXTIN,'.json')
    warning('conversion from json not fully functional in all cases')
    %convert from json to SBML
    fileNameIntermediate= [FILEPATH filesep NAME '_SBML_tmp.xml'];
    % java -jar -Xms8G -Xmx8G -Duser.language=en EscherConverter-1.2.1.jar --input=glycolysis.json --format=SBML --output=glycolysis.sbml --gui=false
    command=['java -jar -Xms8G -Xmx8G -Duser.language=en ' pathToEscherConverter ' --input=' fileNameIn ' --format=SBML --output=' fileNameIntermediate ' --gui=false'];
    [status,result] = system(command);
    if status~=0
        disp(command)
    end
    if strcmp(outputFormat,'SBML')
        return
    else
        fileNameIn = fileNameIntermediate;
    end
end


switch outputFormat
    case {'SBGN-ML','SBML','CellDesigner_SBML','GPML'}
        fileNameOut= [FILEPATH filesep NAME EXTOUT];
        command=...
            ['curl -X POST --data-binary @' fileNameIn ' -H "Content-Type: text/plain" https://minerva-dev.lcsb.uni.lu/minerva/api/convert/' inputFormat ':' outputFormat ' >> ' fileNameOut];
        [status,result] = system(command);
    case 'json'
        fileNameIntermediate= [FILEPATH filesep NAME '.sbml'];
        if ~exist(fileNameIntermediate,'file')
            %first convert to sbml
            command=...
                ['curl -X POST --data-binary @' fileNameIn ' -H "Content-Type: text/plain" https://minerva-dev.lcsb.uni.lu/minerva/api/convert/' inputFormat ':SBML >> ' fileNameIntermediate];
            [status,result] = system(command);
            if status~=0
                disp(command)
            end
        end
        
        %then convert to json
        fileNameOut= [FILEPATH filesep NAME EXTOUT];
        %java -jar -Xms8G -Xmx8G -Duser.language=en EscherConverter-1.2.1.jar --input=GlycolysisLayout_small.sbml.xml --format=Escher --output=glycolysis.json --gui=false
        command=['java -jar -Xms8G -Xmx8G -Duser.language=en ' pathToEscherConverter ' --input=' fileNameIntermediate ' --format=Escher --output=' fileNameOut ' --gui=false'];
        [status,result] = system(command);
        if status~=0
            disp(command)
        end
end

% ------------------------------------------------------------
% EscherConverter version 1.2.1
% Copyright © 2015-2019 University of Tübingen
%     Systems Biology Research Group.
% This program comes with ABSOLUTELY NO WARRANTY.
% This is free software, and you are welcome
% to redistribute it under certain conditions.
% See http://www.opensource.org/licenses/mit-license.php.
% ------------------------------------------------------------
% Usage: java -jar EscherConverter-1.2.1.jar [options]
% Options include:
% 
% --help, -? 
%       displays help information
% 
% Input and output
% --input=<string>
%       Specifies the JSON input file. If a directory is given, the conversion
%       will be recursively performed. Accepts JSON.
% --output=<string>
%       The path to the file into which the output should be written. If the input
%       is a directory, this must also be a directory in order to perform a
%       recursive conversion. Accepts SBML, SBGN.
% 
% Layout
% --canvas-default-height=<float [1,1E9]>
%       Just as in the case of the width of the canvas, this value needs to be
%       specified for cases where the JSON input file lacks an explicit
%       specification of the canvas height.
% --canvas-default-width=<float [1,1E9]>
%       This value is used when no width has been defined for the canvas. Since
%       the width attribute is mandatory for the layout, a default value must be
%       provided in these cases.
% --label-height=<float [1,1E9]>
%       With this option you can specify the height of the bounding box of text
%       labels.
% --label-width=<float [1,1E9]>
%       This option defines the width of bounding boxes for text labels.
% --node-depth=<float [1,1E9]>
%       The length of nodes along z-coordinate. Escher maps are actually
%       two-dimensional, but in general, a layout can be three-dimensional. This
%       value should be an arbitrary value greater than zero, because some
%       rendering engines might not display the node if its depth is zero.
% --node-label-height=<float [1,1E9]>
%       Node labels can have a size different from general labels in the graph.
%       Here you can specify how height the bounding box of the labels for nodes
%       should be.
% --primary-node-height=<float [1,1E9]>
%       The primary node should be bigger than the secondary node. With this
%       option you can specify the height of this type of nodes.
% --primary-node-width=<float [1,1E9]>
%       Escher maps distinguish between primary and secondary nodes. Primary nodes
%       should be larger than secondary nodes and display the main flow of matter
%       through the network. This option allows you to specify the width of
%       primary nodes.
% --reaction-label-height=<float [1,1E9]>
%       Reaction label height
% --reaction-node-ratio=<float [0,1]>
%       This value is used as a conversion factor to determine the size of the
%       reaction display box depending on the size of primary nodes. Height and
%       width of reaction nodes are determined by dividing the corresponding
%       values from the primary node size by this factor.
% --secondary-node-ratio=<float [0,1]>
%       Similar to the reaction node ratio, the size of secondary nodes (width and
%       height) is determined by dividing the corresponding values from the
%       primary nodes by this value.
% --z=<float [-1E9,1E9]>
%       The position on the z-axis where the entire two-dimensional graph should
%       be drawn.
% 
% Components and their naming
% --format=<string {SBGN,SBML,Escher}>
%       The desired format for the conversion, e.g., SBML.
% --layout-id=<string>
%       In contrast to the name, this identifier does not have to be
%       human-readable. This is a machine identifier, which must start with a
%       letter or underscore and can only contain ASCII characters.
% --layout-name=<string>
%       This should be a human-readable name for the layout that is to be created.
%       This name might be displayed to describe the figure and should therefore
%       be explanatory.
% --compartment-id=<string>
%       A compartment needs to have a unique identifier, which needs to be a
%       machine-readable Sting that must start with a letter or underscore and
%       can only contain ASCII characters. Since the JSON file does not provide
%       this information, this option allows you to specify the required
%       identifier.
% --compartment-name=<string>
%       With this option it is possible to define a name for the default
%       compartment can be that needs to be generated for the conversion to SBML.
%       The name does not have any restrictions, i.e., any UTF-8 character can be
%       used.
% --infer-compartment-bounds=<boolean>
%       This converter can infer where the boundaries of compartments could be
%       drawn. To this end, it uses each node's BiGG ids to identify the
%       compartment of all metabolites. Assuming that compartments have
%       rectangular shapes, the algorithm can find the outermost node on each
%       side of the box and hence obtain the boundaries of the compartment.
%       However, this methods will fail when metabolites are drawn inside of such
%       a box that belong to a different compartment that is actually further
%       outside. For this reason, this option is deactivated by default.
% 
% Additional options
% --combine=<boolean>
%       If the SBML file contains more than one layout, whether to combine them or
%       not. False by default.
% --extract-cobra=<boolean>
%       If SBMl file is FBC compliant, then extract COBRA model from it. Defaults
%       to false.
% 
% Options for the graphical user interface
% --check-for-updates=<boolean>
%       Decide whether or not this program should search for updates at start-up.
% --gui=<boolean>
%       If this option is given, the program will display its graphical user
%       interface.
% --log-level=<string {"OFF","SEVERE","WARNING","INFO","CONFIG","FINE","FINER","FINEST","ALL"}>
%       Change the log-level of this application. This option will influence how
%       fine-grained error and other log messages will be that you receive while
%       executing this program.
% --log-file=<string>
%       This option allows you to specify a log file to which all information of
%       the program will be written. Accepts log file (*.log).

