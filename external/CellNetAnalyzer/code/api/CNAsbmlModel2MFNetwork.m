function [cnap, errval]= CNAsbmlModel2MFNetwork(SBMLModel, ext_comparts)
%
% CellNetAnalyzer API function 'CNAsbmlModel2MFNetwork'
% ---------------------------------------------
% --> converts a SBMLModel into a CNA mass-flow network (MFN) project
%
% Usage: [cnap, errval]= CNAsbmlModel2MFNetwork(SBMLModel, ext_comparts)
% 
%   SBMLModel: a strucutre containing a SBML model that was created by
%     reading a SBML file using the SBML Toolbox
%     (http://sbml.org/Software/SBMLToolbox)
%     it is assumed that the SBMLModel is free of errors (you can use the
%     validate functionality of the SBML Toolbox to check this)
%
% The second argument is optional:
%
%   ext_comparts: cell array of compartment ids (strings); the metabolites
%     which are located in the listed compartments are considered as
%     external
%     if this argument is not provided the user is queried at the command
%     line for each compartment whether its metabolites should be
%     considered as external or not
%
%
% The following results are returned:
%
%  cnap: a CellNetAnalyzer (mass-flow) project variable which can
%        afterwards be saved via CNAsaveMFNetwork
%
%  errval: 0 if conversion was successful, nonzero if an error has occured

if (SBMLModel.SBML_level == 1)
  id_field_name= 'name';
else
  id_field_name= 'id';
end
cnap.type= 1;
cnap.specID= {SBMLModel.species(:).(id_field_name)};
cnap.specLongName= {SBMLModel.species(:).name};
cnap.specNotes= strrep({SBMLModel.species(:).notes}, sprintf('\n'), ';:;');
cnap.specExternal= [SBMLModel.species(:).boundaryCondition] ~= 0;
%A# the 'constant' attribute of species is ignored here because species
%A# that have constant='true' and boundaryCondition='false' are not allowed
%A# as reactants or products in SBML
if any(cnap.specExternal)
  disp('The following metabolites are considered external because of boundary conditions:')
  disp(cnap.specID(cnap.specExternal)');
else
  disp('No explicit external metabolites are defined with boundary conditions.');
end

compartments= {SBMLModel.compartment(:).(id_field_name)};
disp('The following compartments are present in the model:');
disp(compartments');
if nargin < 2
  ext_comparts= false(size(compartments));
  for i= 1:length(compartments)
    key= input(['Consider the metabolites in compartment ', compartments{i}, ' as external? y/[n] '], 's');
    if strcmp(key, 'y')
      ext_comparts(i)= true;
    end
  end
  ext_comparts= compartments(ext_comparts);
else
  missing= setdiff(ext_comparts, compartments);
  if ~isempty(missing)
    disp('Error: the following compartments were specified to contain external metabolites but do not exist:');
    disp(missing);
    errval= 1;
    return;
  end
end

%A# add additional external species
if ~isempty(ext_comparts) %A# ismember({...}, {}) leads to an error in octave
  cnap.specExternal= cnap.specExternal | ismember({SBMLModel.species(:).compartment}, ext_comparts);
end
cnap.specInternal= find(~cnap.specExternal);

cnap.reacID= {SBMLModel.reaction(:).(id_field_name)};
reac_name= {SBMLModel.reaction(:).name};
reac_note= strrep({SBMLModel.reaction(:).notes}, sprintf('\n'), ';:;');
cnap.reacNotes= cell(size(reac_name));
for i= 1:length(reac_name) %A# put reaction name and notes together in reacNotes
  cnap.reacNotes{i}= [reac_name{i}, ' ', reac_note{i}];
end
irrev_react= [SBMLModel.reaction(:).reversible] == 0;
cnap.reacMax= repmat(Inf, length(irrev_react), 1);
cnap.reacMin= repmat(-Inf, length(irrev_react), 1);
cnap.reacMin(irrev_react)= 0;

%A# prepare one-stop look-up of all species references
num_cons= cellfun('length', {SBMLModel.reaction(:).reactant});
num_prod= cellfun('length', {SBMLModel.reaction(:).product});
spec= cell(1, sum(num_cons) + sum(num_prod));
begin= 1;
for i= 1:length(SBMLModel.reaction)
  [spec(begin:begin+num_cons(i)-1)]= {SBMLModel.reaction(i).reactant(:).species};
  begin= begin + num_cons(i);
  [spec(begin:begin+num_prod(i)-1)]= {SBMLModel.reaction(i).product(:).species};
  begin= begin + num_prod(i);
end
[spec, spec_ind]= ismember(spec, cnap.specID); %A# perform look-up
clear spec;

%A# set up stoichiometric matrix
st= zeros(length(cnap.specID), length(cnap.reacID));
has_denominators= length(SBMLModel.reaction) > 0 && isfield(SBMLModel.reaction(1), 'denominator');
begin= 1;
for i= 1:length(SBMLModel.reaction)
  reac_range= begin:begin+num_cons(i)-1;
  begin= begin + num_cons(i);
  prod_range= begin:begin+num_prod(i)-1;
  begin= begin + num_prod(i);
  st(spec_ind(reac_range), i)= -double([SBMLModel.reaction(i).reactant(:).stoichiometry]);
  st(spec_ind(prod_range), i)= double([SBMLModel.reaction(i).product(:).stoichiometry]);
  if has_denominators
    if ~isempty(reac_range) %A# prevents empty-matrix-dimension-mismatch Matlobotomy
      st(spec_ind(reac_range), i)= st(spec_ind(reac_range), i) ./ double([SBMLModel.reaction(i).reactant(:).denominator]');
    end
    if ~isempty(prod_range) %A# prevents empty-matrix-dimension-mismatch Matlobotomy
      st(spec_ind(prod_range), i)= st(spec_ind(prod_range), i) ./ double([SBMLModel.reaction(i).product(:).denominator]');
    end
  end
end
cnap.stoichMat= st;

%A# store reaction modifiers (if any were declared) in cnap.local.modifier
if length(SBMLModel.reaction) > 0 && isfield(SBMLModel.reaction(1), 'modifier')
  num_mod= cellfun('length', {SBMLModel.reaction(:).modifier});
  if any(num_mod > 0)
    spec= cell(1, sum(num_mod));
    begin= 1;
    for i= 1:length(SBMLModel.reaction)
      [spec(begin:begin+num_mod(i)-1)]= {SBMLModel.reaction(i).modifier(:).species};
      begin= begin + num_mod(i);
    end
    [spec, spec_ind]= ismember(spec, cnap.specID); %A# perform look-up
    clear spec
    cnap.local.modifier= false(length(SBMLModel.reaction), length(cnap.specID));
    begin= 1;
    for i= 1:length(SBMLModel.reaction)
      cnap.local.modifier(i, spec_ind(begin:begin+num_mod(i)-1))= true;
      begin= begin + num_mod(i);
    end
  end
end

% conversions from cell array of strings to char matrix
cnap.specID= char(cnap.specID);
cnap.specLongName= char(cnap.specLongName);
cnap.reacID= char(cnap.reacID);

[cnap, errval]= CNAgenerateMFNetwork(cnap); %A# fill in the rest
