function [fragmentedMol,decomposableBool,inchiExistBool] = autoFragment(inchi,radius,dGPredictorPath,canonicalise,cacheName,printLevel)
%given one or more inchi, automatically fragment it into a set of smiles
%each centered around an atom with radius specifying the number of bonds to 
%neighbouring atoms
%
% INPUT
% inchi             n x 1 cell array of molecules each specified by InChI strings 
%                   or a single InChI string as a char
% OPTIONAL INPUT
% radius            number of bonds around each central smiles atom
% dGPredictorPath   path to the folder containg a git clone of https://github.com/maranasgroup/dGPredictor
%                   path must be the full absolute path without ~/
% cacheName         fileName of cache to load (if it exists) or save to (if it does not exist)
%
% OUTPUT
% fragmentedMol      n x 1 structure with the following fields for each inchi:
% *.inchi            inchi string
% *.smilesCount      Map structure
%                    Each Key is a canonical smiles string (not canonical smiles if canonicalise==0)
%                    Each value is the incidence of each smiles string in a molecule 
%
% decomposableBool   n x 1 logical vector, true if inchi is decomposable
%
% EXTERNAL DEPENDENCIES
% Python, see:
% [pyEnvironment,pySearchPath]=initPythonEnvironment(environmentName,reset)
%
% rdkit, e.g., installed in an Anaconda environment
% https://www.rdkit.org
% https://www.rdkit.org/docs/Install.html#introduction-to-anaconda
%
% dGPredictor
% https://github.com/maranasgroup/dGPredictor

% Author Ronan M.T. Fleming 2021


if isempty(inchi)
    fragmentedMol=[];
    decomposableBool=[];
    return
end
if ~exist('inchi','var')
    inchi='InChI=1S/C5H8O4/c6-4(7)2-1-3-5(8)9/h1-3H2,(H,6,7)(H,8,9)/p-2';
end
if ~exist('radius','var')
    radius=1;
end
if ~exist('dGPredictorPath','var') || isempty(dGPredictorPath)
    %must be the full absolute path without ~/
    dGPredictorPath='/home/rfleming/work/sbgCloud/code/dGPredictor';
end
if ~exist('canonicalise','var')
    canonicalise=0;
end
if exist('cacheName','var') && ~isempty(cacheName)
    aPath=which('autoFragment');
    cacheName = strrep(aPath,'autoFragment.m',['cache' filesep cacheName '.mat']);
    if exist(cacheName,'file')
        load(cacheName)
        return
    end
end
if ~exist('printLevel','var')
    printLevel=0;
end


try
    pythonPath = py_addpath(dGPredictorPath);
    decompose_groups = py.importlib.import_module('decompose_groups');
    py.importlib.reload(decompose_groups); %uncomment if edits to decompose_groups.py made since the last load
catch
    current_py_path = get_py_path();
    [pyEnvironment,pySearchPath]=initPythonEnvironment('dGPredictor',1);
    pythonPath = py_addpath(dGPredictorPath);
    decompose_groups = py.importlib.import_module('decompose_groups');
end

inchiModule = py.importlib.import_module('rdkit.Chem.inchi');

if ischar(inchi)
    inchiChar=inchi;
    clear inchi;
    inchi{1}=inchiChar;
end

nInchi=length(inchi);

for i=1:nInchi
    if ~isempty(inchi{i})
        inchi{i}=strtrim(inchi{i});
    end
end
decomposableBool=true(nInchi,1);
inchiExistBool=true(nInchi,1);
fragmentedMol=struct();
for i = 1:nInchi
    if isempty(inchi{i})
        inchiExistBool(i)=0;
    else
        if printLevel>0
            fprintf('%u\t%s\n',i,inchi{i})
        end
        mol=inchiModule.MolFromInchi(inchi{i});
        fragmentedMol(i,1).inchi=inchi{i};

        try
            %inchi='InChI=1S/C5H8O4/c6-4(7)2-1-3-5(8)9/h1-3H2,(H,6,7)(H,8,9)/p-2'
            %smi_count =  {'CCC': 3, 'CC(=O)[O-]': 2, 'C=O': 2, 'C[O-]': 2}
            %Python dict with no properties.
            smi_count = decompose_groups.count_substructures(uint8(radius),mol);
            
            %convert dictonary into map structure
            %https://nl.mathworks.com/help/matlab/matlab_prog/overview-of-the-map-data-structure.html
            %fragmentedMol(i).smilesCounts = containers.Map('KeyType','char','ValueType','double');
            fragmentedMol(i).smilesCounts = containers.Map();
            for raw_key = py.list(keys(smi_count))
                key = raw_key{1};
                value = double(smi_count{key});
                fragmentedMol(i,1).smilesCounts(string(key)) = value;
            end
            %         data = smi_count;
            %         data = py.json.dumps(data);
            %         data = char(data);
            %         data = jsondecode(data);
        catch
            decomposableBool(i)=0;
        end
    end
end

if canonicalise
    ChemModule = py.importlib.import_module('rdkit.Chem');
    nMols=length(fragmentedMol);
    for i = 1:nMols
        if decomposableBool(i)
            nFrag=length(fragmentedMol(i).smilesCounts);
            fragmentSmiles = fragmentedMol(i).smilesCounts.keys;
            canonSmiles=cell(nFrag,1);
            for j=1:nFrag
                if isempty(fragmentSmiles{j})
                    canonSmiles{j} = fragmentSmiles{j};
                else
                    canonSmiles{j} = char(ChemModule.CanonSmiles(fragmentSmiles{j}));
                end
            end
            [uniqueCanonSmiles,IA,IC] = unique(canonSmiles);
            nUniqueFrag = length(uniqueCanonSmiles);
            %canonical smiles fragments are not unique
            if nFrag~=nUniqueFrag
                fragmentCounts = fragmentedMol(i).smilesCounts.values;
                %regenerate the smiles count map with only unique entries
                %fragmentedMol(i).smilesCounts = containers.Map('KeyType','char','ValueType','double');
                %unique canonical smiles correspond to first indices given by IA
                fragmentedMol(i).smilesCounts = containers.Map(canonSmiles(IA),fragmentCounts(IA));
                %add the counts of the duplicates
                for j=1:nFrag
                    if ~any(j == IA)
                        fragmentedMol(i).smilesCounts(canonSmiles{j}) = fragmentedMol(i).smilesCounts(canonSmiles{j}) +  cell2mat(fragmentCounts(j));
                    end
                end
                fprintf('%s\n',['Consolidated duplicate canonical fragments for ' fragmentedMol(i).inchi])
            end
        end
    end
end

if exist('cacheName','var') && ~isempty(cacheName)
    save(cacheName,'fragmentedMol','decomposableBool','inchiExistBool')
end


    
return
% 
%     % # dGPredictor
% %
% % ==================================
% % ### Requirements:
% % 1. RDkit (http://www.rdkit.org/)
% % 2. pandas (https://pandas.pydata.org/)
% % 3. Scikit-learn (https://scikit-learn.org/stable/)
% % 4. Streamlit==0.55.2 (https://streamlit.io/)
% 
% %From the MATLAB command prompt, add the folder containing autoFragment.py to the Python search path.
% autoFragmentFolder = fileparts(which('autoFragment.m'));
% cd(autoFragmentFolder)
% pythonPath = py_addpath(autoFragmentFolder, 0);
% autoFragment = py.importlib.import_module('autofragment')
% %%
% %
% 
% 
% 
% 
% 
% decompose_groups = py.importlib.import_module('/home/rfleming/work/sbgCloud/code/dGPredictor/decompose_groups');
% 
% db = py.pandas.read_csv(pyargs('filepath_or_buffer',[autoFragmentFolder filesep 'data' filesep 'test_compounds.csv'],'index_col','compound_id'));
% 
% % https://nl.mathworks.com/help/matlab/matlab_external/accessing-elements-in-python-container-types.html
% % Indexing Features Not Supported in MATLAB:
% % Use of square brackets, [].
% % db_smiles = db['smiles_pH7'].to_dict()
% 
% % https://nl.mathworks.com/help/matlab/matlab_external/python-dict-variables.html
% db_dict = db.to_dict();
% 
% db_struct = struct(db_dict);
% 
% %dictionary object with just id & smiles
% db_smiles = db_struct.smiles_pH7;
% 
% %%
% rdkit = py.importlib.import_module('rdkit');
% 
% mol = py.rdkit.Chem.MolFromSmiles(db_smiles)
% 
% 
% try
%     
% catch e
%     disp(e.message)
%     if (isa(e,'matlab.exception.PyException'))
%         e.ExceptionObject;
%     end
%     if contains(e.message,'libstdc')
%         disp('Import of rdkit.Chem failed. Trying the following command ...')
%         disp('mv /usr/local/bin/MATLAB/R2021a/sys/os/glnxa64/libstdc++.so.6 /usr/local/bin/MATLAB/R2021a/sys/os/glnxa64/deactivated.libstdc++.so.6')
%         [success,response]=system('mv /usr/local/bin/MATLAB/R2021a/sys/os/glnxa64/libstdc++.so.6 /usr/local/bin/MATLAB/R2021a/sys/os/glnxa64/deactivated.libstdc++.so.6');
%         if success==0
%             chem = py.importlib.import_module('rdkit.Chem');
%         end
%     else
%         disp('Import of rdkit.Chem failed. Run py.importlib.import_module(''rdkit.Chem'') from the command line to debug.')
%     end
% end
% 
% InchiKey = char(chem.inchi.InchiToInchiKey(inchi));
% 
% return
% 
% % chem = py.importlib.import_module('rdkit.Chem')
% % Error using __init__><module> (line 23)
% % Python Error: ImportError: /usr/local/bin/MATLAB/R2021a/interprocess/bin/glnxa64/pycli/../../../../sys/os/glnxa64/libstdc++.so.6: version `GLIBCXX_3.4.26' not found (required by
% % /usr/local/bin/anaconda3/envs/dGPredictor/lib/python3.8/site-packages/rdkit/Chem/../../../../libboost_regex.so.1.74.0)
% % 
% % Error in <frozen importlib>_call_with_frames_removed (line 219)
% % 
% % Error in <frozen importlib>exec_module (line 783)
% % 
% % Error in <frozen importlib>_load_unlocked (line 671)
% % 
% % Error in <frozen importlib>_find_and_load_unlocked (line 975)
% % 
% % Error in <frozen importlib>_find_and_load (line 991)
% % 
% % Error in <frozen importlib>_gcd_import (line 1014)
% % 
% % Error in __init__>import_module (line 127)
% 
% mol = py.rdkit.Chem.MolFromSmiles(db_smiles);
% 
% 
% 
% %https://nl.mathworks.com/matlabcentral/answers/592918-using-matlab-with-ubuntu-anaconda-and-python
% autoFragment = py.importlib.import_module('autofragment')
% 
% py.autofragment.decompse_ac(db_smiles)
