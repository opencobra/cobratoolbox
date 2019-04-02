function model = setAnnotations(model, values, varargin)
% Set the annotations for a given set of IDs.
%
% USAGE:
%    model = setAnnotations(model, values, field, ids, database, varargin)
% 
% INPUTS:
%    model:         A COBRA style model structure
%    values:        The values of the given annotation. if the field is
%                   defined, these will be checked for validity.
%                   See the note for allowed options. 
% OPTIONAL INPUTS:
%    varargin:      Additional parameter/value pairs or a parameter struct
%                   to further specify the annotation, or add additional
%                   properties with the following parameters:
%                    * `annotationQualifier` - The bioql qualifier to retrieve the info for (Default: 'is')
%                    * `annotationType` - The type of the annotation. either 'bio' or 'model'. 'model' is only applicable if the referenceField is set to 'model'. Default('bio')
%                    * `ids` - The ids (or positions) of the elements for which to add/set annotations. If positions are given, the field parameter has to be set.
%                    * `referenceField` - the type field referenced (e.g. 'rxns', or 'mets'). If none is given, annotations will be assigned to all possible matching model ids.     
%                    * `database` - the database to retrieve data from (e.g. KEGG, BiGG etc) must be provided, if the values are not a struct. 
%                    * `annotationType` - the 
% OUTPUT:
%    model:         The model with the updated annotations
% 
% NOTE:
%       The input format of values can be either a cell array of strings,
%       or a cell array of cell arrays. In the former case multiple IDs are
%       separated by '; '. In the latter case, each cell in the cell array
%       contains exactly one ID.
%       If only a single value is set, the input values can also be a
%       single string, or a cell array of strings (for multiple IDs).
%       Finally, the annotations can be supplied as an sbml type struct
%       (with cvterms and corresponding specifications), as returned by
%       getAnnotations(). If this is given, 


model = addAnnotation(model,values,varargin{:},'replaceAnnotation',true); % simply call the add Function and replace the data.



                            