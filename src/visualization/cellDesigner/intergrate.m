function [ ~ ] = intergrate(fname,fname_out,model,FBAsolution,listRxn)
%
% USAGE:
%
%    intergrate(fname, fname_out, model, FBAsolution, listRxn)
%
% INPUTS:
%    fname:               The name fo the file
%    fname_out:           The name of the output XML file name.
%    model:               A COBRA model structure
%    FBAsolution:         FBA results of a COBRA simulation by the
%                         `optimizeCbModel` function
%    listRxn:             A list of reaction IDs, after which the flux values are modified
%                         or added. P.s., the reaction IDs must be present in both the
%                         parsed CD model and the COBRA model structures. the reactions
%                         can be examined by `cmpR` function.
%
% OUTPUT:
%    fname_out:           A new XML file with the width of reaction links
%                         changed according to flux values calculated by COBRA
%
% EXAMPLE:
%
%    intergrate('anno_test.xml', 'anno_test_2_ecoli.xml', model_ecoli,solution, model_ecoli.rxns(:))
%
% .. Author: - Longfei Mao April, 2015


FBA_result=FBAsolution;
[parsed] = parseCD(fname);   % Parse a CellDesigner XML file into a CD Matlab structure
[ref,normalizedFlux] = addFlux(model,FBA_result,parsed,listRxn) % Overaly the flux distribution with the CD Matlab structure
[annotedText] = writeXML(fname,parsed,fname_out); % Write the CD Matlab strcuture to a new CD XML file.
