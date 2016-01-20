function [ output_args ] = cobraToolboxVersion( input_args )
%COBRATOOLBOXVERSION Summary of this function goes here
%   Detailed explanation goes here

tmp=which('TranslateSBML2');
if isempty(tmp)
    fprintf('%s\n','libsbml not found')
else
    
end
addpath('~/work/sbg-code/cobratoolbox/external/sbml/libsbml-5.10.2/src/bindings/matlab')

end

