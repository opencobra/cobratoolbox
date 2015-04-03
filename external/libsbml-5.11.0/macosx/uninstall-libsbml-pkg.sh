#!/bin/sh
#
# @file   uninstall-libsbml-pkg.sh
# @brief  This shell script uninstalls the libSBML package for MacOSX.
#
#
#<!---------------------------------------------------------------------------
# This file is part of libSBML.  Please visit http://sbml.org for more
# information about SBML, and the latest version of libSBML.
#
# Copyright (C) 2013-2014 jointly by the following organizations:
#     1. California Institute of Technology, Pasadena, CA, USA
#     2. EMBL European Bioinformatics Institute (EMBL-EBI), Hinxton, UK
#     3. University of Heidelberg, Heidelberg, Germany
#
# Copyright (C) 2009-2013 jointly by the following organizations:
#     1. California Institute of Technology, Pasadena, CA, USA
#     2. EMBL European Bioinformatics Institute (EMBL-EBI), Hinxton, UK
#
# Copyright (C) 2006-2008 by the California Institute of Technology,
#     Pasadena, CA, USA
#
# Copyright (C) 2002-2005 jointly by the following organizations:
#     1. California Institute of Technology, Pasadena, CA, USA
#     2. Japan Science and Technology Agency, Japan
#
# This library is free software; you can redistribute it and/or modify it
# under the terms of the GNU Lesser General Public License as published by
# the Free Software Foundation.  A copy of the license agreement is provided
# in the file named "LICENSE.txt" included with this software distribution
# and also available online as http://sbml.org/software/libsbml/license.html
#----------------------------------------------------------------------- -->*/

set -e

PKGUTIL=/usr/sbin/pkgutil
INSTALL_DIR=$(cd `dirname $0` && pwd)/..
MYPATH=uninstall-libsbml-pkg.sh
DEBUG=

function delete_file_or_dir {
FILE=$1

if [ -d "$FILE" ]; then
rm -rf "$FILE"
fi

if [ -e "$FILE" ]; then
rm -f "$FILE"
fi

}

if [ ${EUID} != 0 ] ; then
echo "Please run this shell script as the user 'root'."
exit 1
fi

cd "$INSTALL_DIR"

# here the list of files and directories to delete

delete_file_or_dir include/sbml/annotation/CVTerm.h
delete_file_or_dir include/sbml/annotation/ModelHistory.h
delete_file_or_dir include/sbml/annotation/RDFAnnotation.h
delete_file_or_dir include/sbml/common/common.h
delete_file_or_dir include/sbml/common/extern.h
delete_file_or_dir include/sbml/common/libsbml-config-common.h
delete_file_or_dir include/sbml/common/libsbml-config.h
delete_file_or_dir include/sbml/common/libsbml-namespace.h
delete_file_or_dir include/sbml/common/libsbml-version.h
delete_file_or_dir include/sbml/common/operationReturnValues.h
delete_file_or_dir include/sbml/common/sbmlfwd.h
delete_file_or_dir include/sbml/Compartment.h
delete_file_or_dir include/sbml/CompartmentType.h
delete_file_or_dir include/sbml/compress/bzfstream.h
delete_file_or_dir include/sbml/compress/CompressCommon.h
delete_file_or_dir include/sbml/compress/crypt.h
delete_file_or_dir include/sbml/compress/InputDecompressor.h
delete_file_or_dir include/sbml/compress/ioapi.h
delete_file_or_dir include/sbml/compress/iowin32.h
delete_file_or_dir include/sbml/compress/OutputCompressor.h
delete_file_or_dir include/sbml/compress/unzip.h
delete_file_or_dir include/sbml/compress/zfstream.h
delete_file_or_dir include/sbml/compress/zip.h
delete_file_or_dir include/sbml/compress/zipfstream.h
delete_file_or_dir include/sbml/Constraint.h
delete_file_or_dir include/sbml/conversion/ConversionOption.h
delete_file_or_dir include/sbml/conversion/ConversionProperties.h
delete_file_or_dir include/sbml/conversion/SBMLConverter.h
delete_file_or_dir include/sbml/conversion/SBMLConverterRegister.h
delete_file_or_dir include/sbml/conversion/SBMLConverterRegistry.h
delete_file_or_dir include/sbml/conversion/SBMLFunctionDefinitionConverter.h
delete_file_or_dir include/sbml/conversion/SBMLInitialAssignmentConverter.h
delete_file_or_dir include/sbml/conversion/SBMLLevelVersionConverter.h
delete_file_or_dir include/sbml/conversion/SBMLRuleConverter.h
delete_file_or_dir include/sbml/conversion/SBMLStripPackageConverter.h
delete_file_or_dir include/sbml/conversion/SBMLUnitsConverter.h
delete_file_or_dir include/sbml/Delay.h
delete_file_or_dir include/sbml/Event.h
delete_file_or_dir include/sbml/EventAssignment.h
delete_file_or_dir include/sbml/ExpectedAttributes.h
delete_file_or_dir include/sbml/extension/ISBMLExtensionNamespaces.h
delete_file_or_dir include/sbml/extension/SBaseExtensionPoint.h
delete_file_or_dir include/sbml/extension/SBasePlugin.h
delete_file_or_dir include/sbml/extension/SBasePluginCreator.h
delete_file_or_dir include/sbml/extension/SBasePluginCreatorBase.h
delete_file_or_dir include/sbml/extension/SBMLDocumentPlugin.h
delete_file_or_dir include/sbml/extension/SBMLExtension.h
delete_file_or_dir include/sbml/extension/SBMLExtensionException.h
delete_file_or_dir include/sbml/extension/SBMLExtensionNamespaces.h
delete_file_or_dir include/sbml/extension/SBMLExtensionRegister.h
delete_file_or_dir include/sbml/extension/SBMLExtensionRegistry.h
delete_file_or_dir include/sbml/FunctionDefinition.h
delete_file_or_dir include/sbml/InitialAssignment.h
delete_file_or_dir include/sbml/KineticLaw.h
delete_file_or_dir include/sbml/ListOf.h
delete_file_or_dir include/sbml/LocalParameter.h
delete_file_or_dir include/sbml/math/ASTNode.h
delete_file_or_dir include/sbml/math/FormulaFormatter.h
delete_file_or_dir include/sbml/math/FormulaParser.h
delete_file_or_dir include/sbml/math/FormulaTokenizer.h
delete_file_or_dir include/sbml/math/MathML.h
delete_file_or_dir include/sbml/Model.h
delete_file_or_dir include/sbml/packages/layout/common/LayoutExtensionTypes.h
delete_file_or_dir include/sbml/packages/layout/common/layoutfwd.h
delete_file_or_dir include/sbml/packages/layout/extension/LayoutExtension.h
delete_file_or_dir include/sbml/packages/layout/extension/LayoutModelPlugin.h
delete_file_or_dir include/sbml/packages/layout/extension/LayoutSpeciesReferencePlugin.h
delete_file_or_dir include/sbml/packages/layout/sbml/BoundingBox.h
delete_file_or_dir include/sbml/packages/layout/sbml/CompartmentGlyph.h
delete_file_or_dir include/sbml/packages/layout/sbml/CubicBezier.h
delete_file_or_dir include/sbml/packages/layout/sbml/Curve.h
delete_file_or_dir include/sbml/packages/layout/sbml/Dimensions.h
delete_file_or_dir include/sbml/packages/layout/sbml/GraphicalObject.h
delete_file_or_dir include/sbml/packages/layout/sbml/Layout.h
delete_file_or_dir include/sbml/packages/layout/sbml/LineSegment.h
delete_file_or_dir include/sbml/packages/layout/sbml/Point.h
delete_file_or_dir include/sbml/packages/layout/sbml/ReactionGlyph.h
delete_file_or_dir include/sbml/packages/layout/sbml/SpeciesGlyph.h
delete_file_or_dir include/sbml/packages/layout/sbml/SpeciesReferenceGlyph.h
delete_file_or_dir include/sbml/packages/layout/sbml/SpeciesReferenceRole.h
delete_file_or_dir include/sbml/packages/layout/sbml/TextGlyph.h
delete_file_or_dir include/sbml/packages/layout/util/LayoutAnnotation.h
delete_file_or_dir include/sbml/packages/layout/util/LayoutUtilities.h
delete_file_or_dir include/sbml/Parameter.h
delete_file_or_dir include/sbml/Priority.h
delete_file_or_dir include/sbml/Reaction.h
delete_file_or_dir include/sbml/Rule.h
delete_file_or_dir include/sbml/SBase.h
delete_file_or_dir include/sbml/SBMLConstructorException.h
delete_file_or_dir include/sbml/SBMLDocument.h
delete_file_or_dir include/sbml/SBMLError.h
delete_file_or_dir include/sbml/SBMLErrorLog.h
delete_file_or_dir include/sbml/SBMLErrorTable.h
delete_file_or_dir include/sbml/SBMLNamespaces.h
delete_file_or_dir include/sbml/SBMLReader.h
delete_file_or_dir include/sbml/SBMLTransforms.h
delete_file_or_dir include/sbml/SBMLTypeCodes.h
delete_file_or_dir include/sbml/SBMLTypes.h
delete_file_or_dir include/sbml/SBMLVisitor.h
delete_file_or_dir include/sbml/SBMLWriter.h
delete_file_or_dir include/sbml/SBO.h
delete_file_or_dir include/sbml/Species.h
delete_file_or_dir include/sbml/SpeciesReference.h
delete_file_or_dir include/sbml/SpeciesType.h
delete_file_or_dir include/sbml/StoichiometryMath.h
delete_file_or_dir include/sbml/SyntaxChecker.h
delete_file_or_dir include/sbml/Trigger.h
delete_file_or_dir include/sbml/Unit.h
delete_file_or_dir include/sbml/UnitDefinition.h
delete_file_or_dir include/sbml/UnitKind.h
delete_file_or_dir xinclude/sbml/units/FormulaUnitsData.h
delete_file_or_dir include/sbml/units/UnitFormulaFormatter.h
delete_file_or_dir include/sbml/units/UnitKindList.h
delete_file_or_dir include/sbml/util/List.h
delete_file_or_dir include/sbml/util/memory.h
delete_file_or_dir include/sbml/util/Stack.h
delete_file_or_dir include/sbml/util/StringBuffer.h
delete_file_or_dir include/sbml/util/util.h
delete_file_or_dir include/sbml/validator/ConsistencyValidator.h
delete_file_or_dir include/sbml/validator/ConstraintMacros.h
delete_file_or_dir include/sbml/validator/constraints
delete_file_or_dir include/sbml/validator/constraints/IdBase.h
delete_file_or_dir include/sbml/validator/constraints/IdList.h
delete_file_or_dir include/sbml/validator/constraints/MathMLBase.h
delete_file_or_dir include/sbml/validator/constraints/OverDeterminedCheck.h
delete_file_or_dir include/sbml/validator/constraints/UniqueIdBase.h
delete_file_or_dir include/sbml/validator/constraints/UniqueMetaId.h
delete_file_or_dir include/sbml/validator/constraints/UnitsBase.h
delete_file_or_dir include/sbml/validator/IdentifierConsistencyValidator.h
delete_file_or_dir include/sbml/validator/InternalConsistencyValidator.h
delete_file_or_dir include/sbml/validator/L1CompatibilityValidator.h
delete_file_or_dir include/sbml/validator/L2v1CompatibilityValidator.h
delete_file_or_dir include/sbml/validator/L2v2CompatibilityValidator.h
delete_file_or_dir include/sbml/validator/L2v3CompatibilityValidator.h
delete_file_or_dir include/sbml/validator/L2v4CompatibilityValidator.h
delete_file_or_dir include/sbml/validator/L3v1CompatibilityValidator.h
delete_file_or_dir include/sbml/validator/MathMLConsistencyValidator.h
delete_file_or_dir include/sbml/validator/ModelingPracticeValidator.h
delete_file_or_dir include/sbml/validator/OverdeterminedValidator.h
delete_file_or_dir include/sbml/validator/SBMLExternalValidator.h
delete_file_or_dir include/sbml/validator/SBMLInternalValidator.h
delete_file_or_dir include/sbml/validator/SBMLValidator.h
delete_file_or_dir include/sbml/validator/SBOConsistencyValidator.h
delete_file_or_dir include/sbml/validator/UnitConsistencyValidator.h
delete_file_or_dir include/sbml/validator/Validator.h
delete_file_or_dir include/sbml/validator/VConstraint.h
delete_file_or_dir include/sbml/xml/LibXMLAttributes.h
delete_file_or_dir include/sbml/xml/LibXMLHandler.h
delete_file_or_dir include/sbml/xml/LibXMLNamespaces.h
delete_file_or_dir include/sbml/xml/LibXMLParser.h
delete_file_or_dir include/sbml/xml/LibXMLTranscode.h
delete_file_or_dir include/sbml/xml/XMLAttributes.h
delete_file_or_dir include/sbml/xml/XMLBuffer.h
delete_file_or_dir include/sbml/xml/XMLError.h
delete_file_or_dir include/sbml/xml/XMLErrorLog.h
delete_file_or_dir include/sbml/xml/XMLExtern.h
delete_file_or_dir include/sbml/xml/XMLFileBuffer.h
delete_file_or_dir include/sbml/xml/XMLHandler.h
delete_file_or_dir include/sbml/xml/XMLInputStream.h
delete_file_or_dir include/sbml/xml/XMLMemoryBuffer.h
delete_file_or_dir include/sbml/xml/XMLNamespaces.h
delete_file_or_dir include/sbml/xml/XMLNode.h
delete_file_or_dir include/sbml/xml/XMLOutputStream.h
delete_file_or_dir include/sbml/xml/XMLParser.h
delete_file_or_dir include/sbml/xml/XMLToken.h
delete_file_or_dir include/sbml/xml/XMLTokenizer.h
delete_file_or_dir include/sbml/xml/XMLTriple.h
delete_file_or_dir lib/CheckAndConvert.m
delete_file_or_dir lib/ConvertFormulaToMathML.m
delete_file_or_dir lib/isoctave.m
delete_file_or_dir lib/Contents.m
delete_file_or_dir lib/OutputSBML.m
delete_file_or_dir lib/TranslateSBML.m
delete_file_or_dir lib/installSBML.m
delete_file_or_dir lib/isSBML_Model.m
delete_file_or_dir lib/libsbml.dylib
delete_file_or_dir lib/libsbml.5.dylib
delete_file_or_dir lib/libsbml.5.3.0.dylib
delete_file_or_dir lib/libsbml.5.4.0.dylib
delete_file_or_dir lib/libsbml.5.4.1.dylib
delete_file_or_dir lib/libsbml.5.5.0.dylib
delete_file_or_dir lib/libsbml.5.6.0.dylib
delete_file_or_dir lib/libsbml.5.7.0.dylib
delete_file_or_dir lib/libsbml.a
delete_file_or_dir lib/libsbml.la
delete_file_or_dir lib/libsbmlj.jnilib
delete_file_or_dir lib/mono/libsbmlcsP/libsbml.dylib
delete_file_or_dir lib/mono/libsbmlcsP/libsbmlcs.dylib
delete_file_or_dir lib/mono/libsbmlcsP/libsbmlcsP.dll
delete_file_or_dir lib/mono/gac/libsbmlcsP
delete_file_or_dir lib/mono/libsbmlcsP
delete_file_or_dir lib/OutputSBML.mexmaci64
delete_file_or_dir lib/perl5/site_perl/5.12.3/darwin-thread-multi-2level/auto/LibSBML/.libs/LibSBML.a
delete_file_or_dir lib/perl5/site_perl/5.12.3/darwin-thread-multi-2level/auto/LibSBML/.libs/LibSBML.bundle
delete_file_or_dir lib/perl5/site_perl/5.12.3/darwin-thread-multi-2level/auto/LibSBML/.libs/LibSBML.bundle.dSYM
delete_file_or_dir lib/perl5/site_perl/5.12.3/darwin-thread-multi-2level/auto/LibSBML/.libs/LibSBML.bundle.dSYM/Contents
delete_file_or_dir lib/perl5/site_perl/5.12.3/darwin-thread-multi-2level/auto/LibSBML/.libs/LibSBML.bundle.dSYM/Contents/Info.plist
delete_file_or_dir lib/perl5/site_perl/5.12.3/darwin-thread-multi-2level/auto/LibSBML/.libs/LibSBML.bundle.dSYM/Contents/Resources
delete_file_or_dir lib/perl5/site_perl/5.12.3/darwin-thread-multi-2level/auto/LibSBML/.libs/LibSBML.bundle.dSYM/Contents/Resources/DWARF
delete_file_or_dir lib/perl5/site_perl/5.12.3/darwin-thread-multi-2level/auto/LibSBML/.libs/LibSBML.bundle.dSYM/Contents/Resources/DWARF/LibSBML.bundle
delete_file_or_dir lib/perl5/site_perl/5.12.3/darwin-thread-multi-2level/auto/LibSBML/.libs/LibSBML.la
delete_file_or_dir lib/perl5/site_perl/5.12.3/darwin-thread-multi-2level/auto/LibSBML/.libs/LibSBML.lai
delete_file_or_dir lib/perl5/site_perl/5.12.3/darwin-thread-multi-2level/auto/LibSBML/.libs
delete_file_or_dir lib/perl5/site_perl/5.12.3/darwin-thread-multi-2level/auto/LibSBML/.packlist
delete_file_or_dir lib/perl5/site_perl/5.12.3/darwin-thread-multi-2level/auto/LibSBML/LibSBML.bs
delete_file_or_dir lib/perl5/site_perl/5.12.3/darwin-thread-multi-2level/auto/LibSBML/LibSBML.bundle
delete_file_or_dir lib/perl5/site_perl/5.12.3/darwin-thread-multi-2level/auto/LibSBML/LibSBML.la
delete_file_or_dir lib/perl5/site_perl/5.12.3/darwin-thread-multi-2level/auto/LibSBML
delete_file_or_dir lib/perl5/site_perl/5.12.3/darwin-thread-multi-2level/LibSBML.pm
delete_file_or_dir lib/perl5/site_perl/5.12.3/darwin-thread-multi-2level/LibSBML.pod

delete_file_or_dir lib/perl5/site_perl/5.10.0/darwin-thread-multi-2level/auto/LibSBML/.libs/LibSBML.a
delete_file_or_dir lib/perl5/site_perl/5.10.0/darwin-thread-multi-2level/auto/LibSBML/.libs/LibSBML.bundle
delete_file_or_dir lib/perl5/site_perl/5.10.0/darwin-thread-multi-2level/auto/LibSBML/.libs/LibSBML.bundle.dSYM
delete_file_or_dir lib/perl5/site_perl/5.10.0/darwin-thread-multi-2level/auto/LibSBML/.libs/LibSBML.bundle.dSYM/Contents
delete_file_or_dir lib/perl5/site_perl/5.10.0/darwin-thread-multi-2level/auto/LibSBML/.libs/LibSBML.bundle.dSYM/Contents/Info.plist
delete_file_or_dir lib/perl5/site_perl/5.10.0/darwin-thread-multi-2level/auto/LibSBML/.libs/LibSBML.bundle.dSYM/Contents/Resources
delete_file_or_dir lib/perl5/site_perl/5.10.0/darwin-thread-multi-2level/auto/LibSBML/.libs/LibSBML.bundle.dSYM/Contents/Resources/DWARF
delete_file_or_dir lib/perl5/site_perl/5.10.0/darwin-thread-multi-2level/auto/LibSBML/.libs/LibSBML.bundle.dSYM/Contents/Resources/DWARF/LibSBML.bundle
delete_file_or_dir lib/perl5/site_perl/5.10.0/darwin-thread-multi-2level/auto/LibSBML/.libs/LibSBML.la
delete_file_or_dir lib/perl5/site_perl/5.10.0/darwin-thread-multi-2level/auto/LibSBML/.libs/LibSBML.lai
delete_file_or_dir lib/perl5/site_perl/5.10.0/darwin-thread-multi-2level/auto/LibSBML/.libs
delete_file_or_dir lib/perl5/site_perl/5.10.0/darwin-thread-multi-2level/auto/LibSBML/.packlist
delete_file_or_dir lib/perl5/site_perl/5.10.0/darwin-thread-multi-2level/auto/LibSBML/LibSBML.bs
delete_file_or_dir lib/perl5/site_perl/5.10.0/darwin-thread-multi-2level/auto/LibSBML/LibSBML.bundle
delete_file_or_dir lib/perl5/site_perl/5.10.0/darwin-thread-multi-2level/auto/LibSBML/LibSBML.la
delete_file_or_dir lib/perl5/site_perl/5.10.0/darwin-thread-multi-2level/auto/LibSBML
delete_file_or_dir lib/perl5/site_perl/5.10.0/darwin-thread-multi-2level/LibSBML.pm
delete_file_or_dir lib/perl5/site_perl/5.10.0/darwin-thread-multi-2level/LibSBML.pod

delete_file_or_dir lib/pkgconfig/libsbml.pc
delete_file_or_dir lib/python2.7/site-packages/libsbml/__init__.py
delete_file_or_dir lib/python2.7/site-packages/libsbml/__init__.pyc
delete_file_or_dir lib/python2.7/site-packages/libsbml/_libsbml.so
delete_file_or_dir lib/python2.7/site-packages/libsbml-5.3.0-py2.7.egg-info
delete_file_or_dir lib/python2.7/site-packages/libsbml-5.4.0-py2.7.egg-info
delete_file_or_dir lib/python2.7/site-packages/libsbml-5.4.1-py2.7.egg-info
delete_file_or_dir lib/python2.7/site-packages/libsbml-5.5.0-py2.7.egg-info
delete_file_or_dir lib/python2.7/site-packages/libsbml-5.6.0-py2.7.egg-info
delete_file_or_dir lib/python2.7/site-packages/libsbml-5.7.0-py2.7.egg-info
delete_file_or_dir lib/python2.7/site-packages/libsbml.pth
delete_file_or_dir lib/python2.7/site-packages/libsbml

delete_file_or_dir lib/python2.6/site-packages/libsbml/__init__.py
delete_file_or_dir lib/python2.6/site-packages/libsbml/__init__.pyc
delete_file_or_dir lib/python2.6/site-packages/libsbml/_libsbml.so
delete_file_or_dir lib/python2.6/site-packages/libsbml-5.3.0-py2.6.egg-info
delete_file_or_dir lib/python2.6/site-packages/libsbml-5.4.0-py2.6.egg-info
delete_file_or_dir lib/python2.6/site-packages/libsbml-5.4.1-py2.6.egg-info
delete_file_or_dir lib/python2.6/site-packages/libsbml-5.5.0-py2.6.egg-info
delete_file_or_dir lib/python2.6/site-packages/libsbml-5.6.0-py2.6.egg-info
delete_file_or_dir lib/python2.6/site-packages/libsbml-5.7.0-py2.6.egg-info
delete_file_or_dir lib/python2.6/site-packages/libsbml.pth
delete_file_or_dir lib/python2.6/site-packages/libsbml

delete_file_or_dir lib/ruby/site_ruby/1.8/universal-darwin11.0/libSBML.bundle
delete_file_or_dir lib/ruby/site_ruby/1.8/universal-darwin10.0/libSBML.bundle

delete_file_or_dir lib/TranslateSBML.mexmaci64
delete_file_or_dir share/java
delete_file_or_dir share/java/libsbmlj.jar

delete_file_or_dir include/sbml/util
delete_file_or_dir include/sbml/xml
delete_file_or_dir include/sbml/validator
delete_file_or_dir include/sbml/math
delete_file_or_dir include/sbml/packages/layout/extension
delete_file_or_dir include/sbml/packages/layout/util
delete_file_or_dir include/sbml/packages/layout/common
delete_file_or_dir include/sbml/packages/layout/sbml
delete_file_or_dir include/sbml/packages/layout
delete_file_or_dir include/sbml/packages
delete_file_or_dir include/sbml/compress
delete_file_or_dir include/sbml/extension
delete_file_or_dir include/sbml/common
delete_file_or_dir include/sbml/conversion
delete_file_or_dir include/sbml/annotation
delete_file_or_dir include/sbml

delete_file_or_dir bin/uninstall-libsbml-pkg.sh


# forget that libsbml was installed
LIBSBML_PKGID=`${PKGUTIL} --pkgs | grep libsbml`

if (echo "${LIBSBML_PKGID}" | grep -q -i libsbml); then
${PKGUTIL} --forget ${LIBSBML_PKGID}
fi

echo
echo Uninstall finished successfully.

