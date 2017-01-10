function [ helpText ] = writeGDXFromCOBRA( cobraStruct,fileName,small )
%Writes a GDX file with the stoichiometric matrix and
%the reversibility information. If small is set to true, it writes a
%smaller GDX . Requires wgdx to be on path, which is provided by a GAMS installation.
%Allowed Calls:
%writeGDXFromCOBRA(cobraStruct): Generates a name for the gdx file using
%date and time info
%writeGDXFromCOBRA(cobraStruct,fileName) / writeGDXFromCOBRA(cobraStruct,fileName,false): 
%uses provided filename, gdx has reactions and metabolites sets. 
%writeGDXFromCOBRA(cobraStruct,fileName,true):
%uses provided filename, gdx doesn't have reactions and
%metabolites sets, intented to be read using a feature in GAMS v>24.2.1. (see output helpText)
%02/17/15 Claudio Delpino & Romina Lasry @PLAPIQUI

if(exist('wgdx') ~=0)
  if(nargin<2)
     fileName=strcat('COBRAModel_',datestr(now,'mmddyyHHMMSS'),'.gdx');
  end
  
matStruct.name='S';
matStruct.val=full(cobraStruct.S);
matStruct.uels={transpose(cobraStruct.mets),transpose(cobraStruct.rxns)};
matStruct.form='full';
matStruct.type='parameter';

revStruct.name='isRev';
revStruct.val=cobraStruct.rev;
revStruct.uels=transpose(cobraStruct.rxns);
revStruct.form='full';
revStruct.type='parameter';

if(nargin<3 || ~small)
    fprintf('If your GAMS version is higher than 24.2.1,\nyou can pass small=true to this function\nto get a reduced gdx that uses a special load to populate the sets\n');
    metSetStruct.name='met';
    metSetStruct.uels=transpose(cobraStruct.mets);
    rxnSetStruct.name='rxn';
    rxnSetStruct.uels=transpose(cobraStruct.rxns);
    wgdx(fileName,revStruct,matStruct,metSetStruct,rxnSetStruct);
    helpText=sprintf('\n Example load for .gms file: \n \nsets met,rxn \nparameters S,isRev \n$gdxin %s%c%s  \n$load S met rxn isRev \n$gdxin\n',pwd,filesep,fileName);
else
    wgdx(fileName,revStruct,matStruct);
    helpText=sprintf('\n Example load for .gms file: \n \nsets met,rxn \nparameters S,isRev \n$gdxin %s%c%s  \n$load S met<S.dim1 rxn<S.dim2 isRev \n$gdxin\n',pwd,filesep,fileName);
end
else 
    fprintf('wgdx() not found. Is the GAMS system directory in the MatLab Path?\n');
end
