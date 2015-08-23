function CNASFNetwork2sbmlQual(cnap, fname)
% CNA API function CNASFNetwork2sbmlQual
% *************************************
% Exports CNA signal-flow project to an SBML file complying 
% with the ‘SBML Qual’ specifications.

%  Usage: CNASFNetwork2sbmlQual(cnap, fname)

% Arguments:
%     cnap: a CNA signal-flow project
%     fname: the name of the SBML file to be generated

% The logical model is interpreted as a binary model and treats ITT as AND
% gates; half-edges are ignored. All interactions affecting one node are 
% collected into one transition to fulfill the coherence recommendation 
% of the SBML qual standard.


fid= fopen(fname, 'w', 'n', 'UTF-8');
SBMLheader= {'<?xml version="1.0" encoding="UTF8"?>'
  '<sbml xmlns="http://www.sbml.org/sbml/level3/version1/core" level="3" version="1" xmlns:qual="http://www.sbml.org/sbml/level3/version1/qual/version1" qual:required="true">'};
string2SId([]);
defComp= string2SId('defaultCompartment');

fprintf(fid, '%s\n', SBMLheader{:});
fprintf(fid, '<model id="%s" name="%s">\n', string2SId(cnap.net_var_name),  cnap.net_var_name);
fprintf(fid, '<listOfCompartments>\n\t<compartment id="%s" name="default compartment" constant="false"/>\n', defComp);
fprintf(fid, '</listOfCompartments>\n<qual:listOfQualitativeSpecies>\n');

specSId= string2SId(cellstr(cnap.specID));
specName= cellstr(cnap.specLongName);
for i= 1:cnap.nums
  fprintf(fid, '\t<qual:qualitativeSpecies qual:compartment="%s" qual:constant="false" qual:id="%s" qual:name="%s" qual:maxLevel="1"/>\n',...
    defComp, specSId{i}, specName{i});
end

fprintf(fid, '</qual:listOfQualitativeSpecies>\n<qual:listOfTransitions>\n');

transSId= string2SId(strcat('TR', strtrim(cellstr(num2str((1:cnap.nums)')))));
transName= strcat(repmat({'interactions affecting '}, cnap.nums, 1), cellstr(cnap.specID));
for i= 1:cnap.nums
  interactions= find(cnap.interMat(i, :) > 0);
  interactions(~any(cnap.interMat(:, interactions) < 0, 1))= []; %A# remove incoming half-edges
  if ~isempty(interactions)
    inputs= find(any(cnap.interMat(:, interactions) < 0, 2))';
    fprintf(fid, '\t<qual:transition qual:id="%s" qual:name="%s">\n', transSId{i}, transName{i});
    fprintf(fid, '\t\t<qual:listOfInputs>\n');
    for j= 1:length(inputs)
      fprintf(fid, '\t\t\t<qual:input qual:qualitativeSpecies="%s" qual:transitionEffect="none" />\n',...
        specSId{inputs(j)});
    end
    fprintf(fid, ['\t\t</qual:listOfInputs>\n\t\t<qual:listOfOutputs>\n',...
      '\t\t\t<qual:output qual:qualitativeSpecies="%s" qual:transitionEffect="assignmentLevel" />\n',...
      '\t\t</qual:listOfOutputs>\n\t\t<qual:listOfFunctionTerms>\n\t\t<qual:defaultTerm qual:resultLevel="0"/>\n',...
      '\t\t<qual:functionTerm qual:resultLevel="1">\n\t\t<math xmlns="http://www.w3.org/1998/Math/MathML">\n'], specSId{i});
    if length(interactions) > 1
      fprintf(fid, '\t\t\t<apply> <or/>\n');
    end
    for j= interactions
      writeConjunction(fid, specSId, find(cnap.interMat(:, j) < 0)', cnap.notMat(:, j));
    end
    if length(interactions) > 1
      fprintf(fid, '\t\t\t</apply>\n');
    end
    fprintf(fid, '\t\t</math>\n\t\t</qual:functionTerm>\n\t\t</qual:listOfFunctionTerms>\n\t</qual:transition>\n');
  end
end
fprintf(fid, '</qual:listOfTransitions>\n</model>\n</sbml>\n');
fclose(fid);

function writeConjunction(fid, specSId, literals, negations)
if length(literals) > 1
  fprintf(fid, '\t\t\t\t<apply> <and/>\n');
end
for i= literals
  fprintf(fid, '\t\t\t\t\t<apply> <eq/> <ci> %s </ci> <cn type="integer"> %d </cn> </apply>\n', specSId{i}, negations(i));
end
if length(literals) > 1
  fprintf(fid, '\t\t\t\t</apply>\n');
end

function res= string2SId(str)
% call with [] to reset the persistent exclusion variable
persistent exclusion;

if isempty(str)
  exclusion= cell(0, 1);
else
  res= genvarname(str, exclusion); %A# conforms with SBML but may not always look nice
  exclusion= [exclusion; res];
end
