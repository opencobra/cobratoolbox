function [experiment] = generateIsotopomerSolver(model, inputMet, experiment, FVAflag)

%wdir = which('generateIsotopomerSolver');
%ofile = fopen(strcat(wdir, 'model_description.txt'), 'w');
% description:  
% input:  model containing standard fields and a .isotopomer field
% outputs:  none
% prints a file to /isotopomer/solver/ directory which looks like
% BiosyntheticMappingFile except that it has the indexes of every reaction
% in there as well.
% after that it calls converter.pl, optimizer.pl and validator.pl but I can
% take care of that.


oriFolder = pwd; % save working directory

source_array = model.isotopomer; 
Isotopomer_Info = []; 

if isempty(inputMet)
    inputMet = 'xglcDe';
end
%check if experiment parameter is provided, if so turn on flag
experiment_present = 0; 
 
if (nargin > 2)
    experiment_present = 1; 
end
if nargin < 4
    FVAflag = false;
end

userxn = true(size(model.rxns));
if FVAflag
    [m1, m2] = fluxVariability(model,0);
    userxn = (abs(m1) > 1e-7 | abs(m2) > 1e-7);
    if any(userxn == false)
        display('ommitting reactions due to FVA')
        model.rxns(userxn == false)
    end
end

for i= 1:1:length(source_array)   
    if(~isempty(source_array{i}) && userxn(i))
        [token,rem]=strtok(source_array(i)); 
        str = num2str(i);
        new_string = strcat(token,' v',str ,rem);
        new_string = new_string{1}; 
        [a,b] = strread(new_string,'%s%s','delimiter','!'); 
        Isotopomer_Info = vertcat(Isotopomer_Info,a,b);
    end
end


%add #Measured Metabolites# if experiment input is provided
if(experiment_present)
    frags = experiment.fragments; 
    exp_names = fieldnames(frags);
    exp_names_len = length(exp_names);  
    Isotopomer_Info = vertcat(Isotopomer_Info,[],'!!Measured Metabolites!!'); 
    
    for i = 1:exp_names_len
            exp_name = char(exp_names(i));
            met = frags.(exp_name).met;
            fragment = frags.(exp_name).fragment;
            met_exp = strcat(met,'->',mat2str(fragment));
            Isotopomer_Info = vertcat(Isotopomer_Info,met_exp);
    end
end

% print out the input metabolite.
Isotopomer_Info = vertcat(inputMet, Isotopomer_Info); 



isotopomer = dataset(Isotopomer_Info); 
xdir = which('generateIsotopomerSolver');
xdir = strrep(xdir, 'generateIsotopomerSolver.m', '') % get only directory

%export(isotopomer,'file','C:\UserSVN\isotopomer\solver\Isotopomer_Text.txt'); 
export(isotopomer,'file',strcat(xdir,'IsotopomerModel.txt'),'WriteVarNames',false); 

cd(xdir);
display('generating EMU method')
perl generatorEMU.pl;
display('generating CUMOMER method')
perl generatorCumomer.pl;
display('optimizing EMU method')
perl optimizerEMU.pl;
display('optimizing CUMOMER method')
perl optimizerCumomer.pl;

cd(oriFolder); % restore working directory

return