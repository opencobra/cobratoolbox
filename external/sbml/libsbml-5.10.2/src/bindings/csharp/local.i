/**
 * @file    local.i
 * @brief   cs-specific SWIG directives for wrapping libSBML API this file 
 *          has been adapted from the SWIG java bindings written by 
 * 	    Ben Bornstein and Akiya Jouraku
 * @author  Frank Bergmann (fbergman@u.washington.edu)
 * @author  Akiya Jouraku
 *
 * <!--------------------------------------------------------------------------
 * This file is part of libSBML.  Please visit http://sbml.org for more
 * information about SBML, and the latest version of libSBML.
 *
 * Copyright (C) 2013-2014 jointly by the following organizations:
 *     1. California Institute of Technology, Pasadena, CA, USA
 *     2. EMBL European Bioinformatics Institute (EMBL-EBI), Hinxton, UK
 *     3. University of Heidelberg, Heidelberg, Germany
 *
 * Copyright (C) 2009-2013 jointly by the following organizations: 
 *     1. California Institute of Technology, Pasadena, CA, USA
 *     2. EMBL European Bioinformatics Institute (EMBL-EBI), Hinxton, UK
 *  
 * Copyright (C) 2006-2008 by the California Institute of Technology,
 *     Pasadena, CA, USA 
 *  
 * Copyright (C) 2002-2005 jointly by the following organizations: 
 *     1. California Institute of Technology, Pasadena, CA, USA
 *     2. Japan Science and Technology Agency, Japan
 * 
 * This library is free software; you can redistribute it and/or modify it
 * under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation.  A copy of the license agreement is provided
 * in the file named "LICENSE.txt" included with this software distribution
 * and also available online as http://sbml.org/software/libsbml/license.html
 * ---------------------------------------------------------------------- -->*/


 
%include "std_string.i"
%include "std_wstring.i"

%include "exception.i"
%include <typemaps.i>

%include "enumsimple.swg"
%csconst(1);


%csconstvalue("'+'") AST_PLUS;
%csconstvalue("'-'") AST_MINUS;
%csconstvalue("'*'") AST_TIMES;
%csconstvalue("'/'") AST_DIVIDE;
%csconstvalue("'^'") AST_POWER;


////////////////////////////////////////////////////////////////////////////////
//
// Changes default behaviour for converting string variables between 
// C# side and C++ side.
//
// -----------------------------------------------------------------------------
// (default)  
// C# string (Unicode (wide char)) -> C++ char* (ANSI CP (multibyte char))
// 
// (changed)  
// C# string (Unicode (wide char)) -> C++ wchar_t* (Unicode (wide char)) 
// -> C++ char* (UTF8 (multibyte char))
// -----------------------------------------------------------------------------
//
// By default, C# Unicode string is converted to C++ ANSI CP string (not UTF8 
// string) and this leads to an invalid encoding error in libSBML API which 
// requires UTF8 string.
// To avoid this problem, the following typemap directive changes the behaviour 
// of string conversion to pass UTF8 string to libSBML C++ API. 
// Since there seems to be no way to directly convert C# Unicode string to C++ 
// UTF8 string, C# Unicode string is converted to C++ Unicode character (wchar_t*) 
// and then converted to UTF8 character (char*). 
//

#ifdef SWIGWIN 

%define SWIGCSHARP_IMTYPE_WSTRING(TYPENAME)
%typemap(imtype, 
         inattributes="[MarshalAs(UnmanagedType.LPWStr)]", 
         outattributes="[return: MarshalAs(UnmanagedType.LPWStr)]" 
        ) TYPENAME "string"
%enddef

SWIGCSHARP_IMTYPE_WSTRING(std::string)
SWIGCSHARP_IMTYPE_WSTRING(std::string&)
SWIGCSHARP_IMTYPE_WSTRING(const std::string&)
SWIGCSHARP_IMTYPE_WSTRING(std::string*)
SWIGCSHARP_IMTYPE_WSTRING(const std::string*)
SWIGCSHARP_IMTYPE_WSTRING(char*)
SWIGCSHARP_IMTYPE_WSTRING(const char*)

//
// In SWIG-1.3.35, a callback function for a returned wide string (implemented in 
// SWIGWStringHelper class) doesn't work when the given Unicode string converted 
// from UTF8 string (the callback function is used in libsbml_wrap.cpp when 
// returning an Unicode character).
// So, currently, the SWIGWStringHelper class is modified as follows.
//
// (NOTICE) 
//  To disable the default SWIGStringHelper class, SWIG_CSHARP_NO_WSTRING_HELPER 
//  needs to be defined by passing  -DSWIG_CSHARP_NO_WSTRING_HELPER  to SWIG command 
//  line.
//

%insert(runtime) %{
/* Callback for returning strings to C# without leaking memory */
typedef void * (SWIGSTDCALL* SWIG_CSharpWStringHelperCallback)(const wchar_t *);
static SWIG_CSharpWStringHelperCallback SWIG_csharp_wstring_callback = NULL;
%}

%pragma(csharp) imclasscode=%{
  protected class SWIGWStringHelper {

    public delegate IntPtr SWIGWStringDelegate(IntPtr message);
    static SWIGWStringDelegate wstringDelegate = new SWIGWStringDelegate(CreateWString);

    [DllImport("$dllimport", EntryPoint="SWIGRegisterWStringCallback_$module")]
    public static extern void SWIGRegisterWStringCallback_$module(SWIGWStringDelegate wstringDelegate);

    static IntPtr CreateWString([MarshalAs(UnmanagedType.LPWStr)]IntPtr cString) {
      string ustr = System.Runtime.InteropServices.Marshal.PtrToStringUni(cString);
      return System.Runtime.InteropServices.Marshal.StringToHGlobalUni(ustr);
    }

    static SWIGWStringHelper() {
      SWIGRegisterWStringCallback_$module(wstringDelegate);
    }
  }

  static protected SWIGWStringHelper swigWStringHelper = new SWIGWStringHelper();
%}

%insert(runtime) %{
#ifdef __cplusplus
extern "C"
#endif
SWIGEXPORT void SWIGSTDCALL SWIGRegisterWStringCallback_$module(SWIG_CSharpWStringHelperCallback callback) {
  SWIG_csharp_wstring_callback = callback;
}
%}

#endif //SWIGWIN

//////////////////////////////////////////////////////////////////////
//
// typemap between "unsigned int (C++)" and "long (C#)"
//
// The following typemap directives for the above conversion have been
// added with CLS-compliant in mind. 
// (uint can not be used in CLS-compliant API)
//
//////////////////////////////////////////////////////////////////////

// mapping for a type of function argument in libsbml_wrap.cpp
%typemap(ctype,  out="unsigned int")        unsigned int        "long long"
%typemap(ctype,  out="unsigned int") const unsigned int& "const long long&"

// mapping for a type of function argument in csharp-files/libsbmlPINVOKE.cs
%typemap(imtype, out="uint") unsigned int        "long"
%typemap(imtype, out="uint") const unsigned int& "long"

// mapping for a type of function argument in csharp-files/*.cs (C# proxy classes)
%typemap(cstype) unsigned int        "long"
%typemap(cstype) const unsigned int& "long"

// conversion for a given argument in libsbml_wrap.cpp
%typemap(in)     unsigned int        { $1 = (unsigned int)$input;  }
%typemap(in)     unsigned int*       { $1 = (unsigned int*)$input; }

// conversion for a returned value in csharp-files/*.cs (C# proxy classes)
%typemap(csout)  unsigned int        { return (long)$imcall; }
%typemap(csout)  const unsigned int& { return (long)$imcall; }
%typemap(csout)  uint                { return (long)$imcall; }
%typemap(csdirectorout) unsigned int "(uint)$cscall"

// definition that allows all methods to be overridden, that cause issues 
// as usually happens when swigdoc adds documentation on a virtual member. 

%define COVARIANT_METHOD_NAME(_CNAME_,_METHOD_)
%typemap(cstype) string   _CNAME_ ## ::_METHOD_  "_CNAME_"
%csmethodmodifiers  _CNAME_ ## ::_METHOD_  "public new"
%enddef

//////////////////////////////////////////////////////////////////////


/**
 * Adds DownCastBase(long cPtr, boolean owner) method for package extension
 */
%typemap(cscode) SBMLExtension
%{
  public virtual SBasePlugin DowncastSBasePlugin(IntPtr cPtr, bool owner)
  {
    if (cPtr.Equals(IntPtr.Zero)) return null;
	return new SBasePlugin(cPtr, owner);
  }

  public virtual SBase DowncastSBase(IntPtr cPtr, bool owner)
  {
    if (cPtr.Equals(IntPtr.Zero)) return null;	  
    return new SBase(cPtr, owner);
  }
%}


/**
 * @return the most specific c# object possible for the given SBase
 * object.
 */
%pragma(csharp) modulecode =
%{

	public static SBMLExtension DowncastExtension(IntPtr cPtr, bool owner)
	{		
		if (cPtr.Equals(IntPtr.Zero)) return null;
		
		SBMLExtension ext = new SBMLExtension(cPtr, false);
		string pkgName = ext.getName();
%}
%include "local-downcast-extension.i"
%pragma(csharp) modulecode =
%{				
		return new SBMLExtension(cPtr,owner);
	}
	
	public static SBMLNamespaces DowncastSBMLNamespaces(IntPtr cPtr, bool owner)
	{
		if (cPtr.Equals(IntPtr.Zero)) return null;
		
		SBMLNamespaces sbn = new SBMLNamespaces(cPtr, false);
		if (sbn != null)
		{
			XMLNamespaces ns = sbn.getNamespaces();
%}
%include "local-downcast-namespaces.i"
%pragma(csharp) modulecode =
%{				
		}
		return new SBMLNamespaces(cPtr, owner);
		
	}
	
	
	public static SBMLConverter DowncastSBMLConverter(IntPtr cPtr, bool owner)
	{
		if (cPtr.Equals(IntPtr.Zero)) return null;
		
		SBMLConverter con = new SBMLConverter(cPtr, false);
		string conName = con.getName();
		
		if (conName == "SBML Units Converter")
		  return new SBMLUnitsConverter(cPtr,owner);
		else if (conName == "SBML Strip Package Converter")
		  return new SBMLStripPackageConverter(cPtr,owner);
		else if (conName == "SBML Rule Converter")
		  return new SBMLRuleConverter(cPtr,owner);
		else if (conName == "SBML Reaction Converter")
		  return new SBMLReactionConverter(cPtr,owner);
		else if (conName == "SBML Local Parameter Converter")
		  return new SBMLLocalParameterConverter(cPtr,owner);
		else if (conName == "SBML Level Version Converter")
		  return new SBMLLevelVersionConverter(cPtr,owner);
		else if (conName == "SBML Initial Assignment Converter")
		  return new SBMLInitialAssignmentConverter(cPtr,owner);
		else if (conName == "SBML Infer Units Converter")
		  return new SBMLInferUnitsConverter(cPtr,owner);
		else if (conName == "SBML Id Converter")
		  return new SBMLIdConverter(cPtr,owner);
		else if (conName == "SBML Function Definition Converter")
		  return new SBMLFunctionDefinitionConverter(cPtr,owner);	
%}
%include "local-downcast-converters.i"
%pragma(csharp) modulecode =
%{			
		return new SBMLConverter(cPtr,owner);
	}
	
	public static SBasePlugin DowncastSBasePlugin(IntPtr cPtr, bool owner)
	{
		if (cPtr.Equals(IntPtr.Zero)) return null;
		
		SBasePlugin sbp = new SBasePlugin(cPtr, false);
		string pkgName = sbp.getPackageName();
		
		SBMLExtension sbmlext = SBMLExtensionRegistry.getInstance().getExtension(pkgName);
		if (sbmlext != null)
		{
			return sbmlext.DowncastSBasePlugin(cPtr,owner);
		}

		return new SBasePlugin(cPtr,owner);
	}
	

	public static SBase DowncastSBase(IntPtr cPtr, bool owner)
	{
		if (cPtr.Equals(IntPtr.Zero)) return null;
		
		SBase sb = new SBase(cPtr, false);
		string pkgName = sb.getPackageName();
		if (pkgName == "core")
		{
			switch( sb.getTypeCode() )
			{
				case (int) libsbml.SBML_COMPARTMENT:
					return new Compartment(cPtr, owner);
				
				case (int) libsbml.SBML_COMPARTMENT_TYPE:
					return new CompartmentType(cPtr, owner);

				case (int) libsbml.SBML_CONSTRAINT:
					return new Constraint(cPtr, owner);

				case (int) libsbml.SBML_DOCUMENT:
					return new SBMLDocument(cPtr, owner);
	
				case (int) libsbml.SBML_DELAY:
					return new Delay(cPtr, owner);
					
				case (int) libsbml.SBML_EVENT:
					return new Event(cPtr, owner);
					
				case (int) libsbml.SBML_EVENT_ASSIGNMENT:
					return new EventAssignment(cPtr, owner);
					
				case (int) libsbml.SBML_FUNCTION_DEFINITION:
					return new FunctionDefinition(cPtr, owner);
				
				case (int) libsbml.SBML_INITIAL_ASSIGNMENT:
					return new InitialAssignment(cPtr, owner);
					
				case (int) libsbml.SBML_KINETIC_LAW:
					return new KineticLaw(cPtr, owner);
					
				case (int) libsbml.SBML_LIST_OF:
				     string name = sb.getElementName();
				     if(name == "listOf")
			             {
					return new ListOf(cPtr, owner);
				     }
				     else if(name == "listOfCompartments")
				     {
					return new ListOfCompartments(cPtr, owner);
				     }
				     else if(name == "listOfCompartmentTypes")
				     {
					return new ListOfCompartmentTypes(cPtr, owner);
				     }
				     else if(name == "listOfConstraints")
				     {
					return new ListOfConstraints(cPtr, owner);
				     }
				     else if(name == "listOfEvents")
				     {
				         return new ListOfEvents(cPtr, owner);
	                             }
	                             else if(name == "listOfEventAssignments")
	                             {
					return new ListOfEventAssignments(cPtr, owner);
	        		     }
			             else if(name == "listOfFunctionDefinitions")
			             {
	     		               return new ListOfFunctionDefinitions(cPtr, owner);
			             }
			             else if(name == "listOfInitialAssignments")
			             {
			               return new ListOfInitialAssignments(cPtr, owner);
			             }
			             else if(name == "listOfParameters")
			             {
			               return new ListOfParameters(cPtr, owner);
			             }
			             else if(name == "listOfLocalParameters")
			             {
			               return new ListOfLocalParameters(cPtr, owner);
			             }
				     else if(name == "listOfReactions")
			             {
			               return new ListOfReactions(cPtr, owner);
			             }
			             else if(name == "listOfRules")
			             {
			               return new ListOfRules(cPtr, owner);
	                             }
			             else if(name == "listOfSpecies")
			             {
			               return new ListOfSpecies(cPtr, owner);
	                             }
			             else if(name == "listOfUnknowns")
			             {
			               return new ListOfSpeciesReferences(cPtr, owner);
	                             }
			             else if(name == "listOfReactants")
			             {
			               return new ListOfSpeciesReferences(cPtr, owner);
	                             }
			             else if(name == "listOfProducts")
			             {
			               return new ListOfSpeciesReferences(cPtr, owner);
	                             }
			             else if(name == "listOfModifiers")
			             {
			               return new ListOfSpeciesReferences(cPtr, owner);
	                             }
			             else if(name == "listOfSpeciesTypes")
			             {
			               return new ListOfSpeciesTypes(cPtr, owner);
	                             }
			             else if(name == "listOfUnits")
			             {
			               return new ListOfUnits(cPtr, owner);
	                             }
			             else if(name == "listOfUnitDefinitions")
			             {
			               return new ListOfUnitDefinitions(cPtr, owner);
	                             }
			             return new ListOf(cPtr, owner);
					
				case (int) libsbml.SBML_MODEL:
					return new Model(cPtr, owner);
					
				case (int) libsbml.SBML_PARAMETER:
					return new Parameter(cPtr, owner);
					
			case (int) libsbml.SBML_PRIORITY:
				return new Priority(cPtr, owner);
				
				case (int) libsbml.SBML_LOCAL_PARAMETER:
					return new LocalParameter(cPtr, owner);
					
				case (int) libsbml.SBML_REACTION:
					return new Reaction(cPtr, owner);
					
				case (int) libsbml.SBML_SPECIES:
					return new Species(cPtr, owner);
					
				case (int) libsbml.SBML_SPECIES_REFERENCE:
					return new SpeciesReference(cPtr, owner);
					
				case (int) libsbml.SBML_MODIFIER_SPECIES_REFERENCE:
					return new ModifierSpeciesReference(cPtr, owner);
	
				case (int) libsbml.SBML_SPECIES_TYPE:
					return new SpeciesType(cPtr, owner);
	
				case (int) libsbml.SBML_TRIGGER:
					return new Trigger(cPtr, owner);
					
				case (int) libsbml.SBML_UNIT_DEFINITION:
					return new UnitDefinition(cPtr, owner);
					
				case (int) libsbml.SBML_UNIT:
					return new Unit(cPtr, owner);
					
				case (int) libsbml.SBML_ALGEBRAIC_RULE:
					return new AlgebraicRule(cPtr, owner);
					
				case (int) libsbml.SBML_ASSIGNMENT_RULE:
					return new AssignmentRule(cPtr, owner);
					
				case (int) libsbml.SBML_RATE_RULE:
					return new RateRule(cPtr, owner);
	
				case (int) libsbml.SBML_STOICHIOMETRY_MATH:
					return new StoichiometryMath(cPtr, owner);
					
				default:
					return new SBase(cPtr, owner);
			}
		}
		else 
		{
			SBMLExtension sbmlext = SBMLExtensionRegistry.getInstance().getExtension(pkgName);
			if (sbmlext != null)
			{
				return sbmlext.DowncastSBase(cPtr,owner);
			}
		}
		return new SBase(cPtr, owner);
	}
	
%}
#ifndef LIBSBML_USE_LEGACY_MATH

%pragma(csharp) modulecode =
%{	
	public static ASTBase DowncastASTBase(IntPtr cPtr, bool owner)
    {
		if (cPtr.Equals(IntPtr.Zero)) return null;
	
		ASTBase ab = new ASTBase(cPtr,false);
		switch( ab.getTypeCode() )
		{
			default:
			case (int)libsbml.AST_TYPECODE_BASE:
			return new ASTBase(cPtr, owner);
			/*
			case (int)libsbml.AST_TYPECODE_CN_BASE:
			return new ASTCnBase(cPtr, owner);
			case (int)libsbml.AST_TYPECODE_FUNCTION_BASE:
			return new ASTFunctionBase(cPtr, owner);
			case (int)libsbml.AST_TYPECODE_NUMBER:
			return new ASTNumber(cPtr, owner);
			case (int)libsbml.AST_TYPECODE_CN_INTEGER:
			return new ASTCnIntegerNode(cPtr, owner);
			case (int)libsbml.AST_TYPECODE_CN_EXPONENTIAL:
			return new ASTCnExponentialNode(cPtr, owner);
			case (int)libsbml.AST_TYPECODE_CN_RATIONAL:
			return new ASTCnRationalNode(cPtr, owner);
			case (int)libsbml.AST_TYPECODE_CN_REAL:
			return new ASTCnRealNode(cPtr, owner);
			case (int)libsbml.AST_TYPECODE_CSYMBOL:
			return new ASTCSymbol(cPtr, owner);
			case (int)libsbml.AST_TYPECODE_CSYMBOL_AVOGADRO:
			return new ASTCSymbolAvogadroNode(cPtr, owner);
			case (int)libsbml.AST_TYPECODE_CSYMBOL_DELAY:
			return new ASTCSymbolDelayNode(cPtr, owner);
			case (int)libsbml.AST_TYPECODE_CSYMBOL_TIME:
			return new ASTCSymbolTimeNode(cPtr, owner);
			case (int)libsbml.AST_TYPECODE_FUNCTION:
			return new ASTFunction(cPtr, owner);
			case (int)libsbml.AST_TYPECODE_FUNCTION_UNARY:
			return new ASTUnaryFunctionNode(cPtr, owner);
			case (int)libsbml.AST_TYPECODE_FUNCTION_BINARY:
			return new ASTBinaryFunctionNode(cPtr, owner);
			case (int)libsbml.AST_TYPECODE_FUNCTION_NARY:
			return new ASTNaryFunctionNode(cPtr, owner);
			case (int)libsbml.AST_TYPECODE_FUNCTION_PIECEWISE:
			return new ASTPiecewiseFunctionNode(cPtr, owner);
			case (int)libsbml.AST_TYPECODE_FUNCTION_LAMBDA:
			return new ASTLambdaFunctionNode(cPtr, owner);
			case (int)libsbml.AST_TYPECODE_FUNCTION_CI:
			return new ASTCiFunctionNode(cPtr, owner);
			case (int)libsbml.AST_TYPECODE_FUNCTION_SEMANTIC:
			return new ASTSemanticsNode(cPtr, owner);
			case (int)libsbml.AST_TYPECODE_FUNCTION_QUALIFIER:
			return new ASTQualifierNode(cPtr, owner);*/
			case (int)libsbml.AST_TYPECODE_ASTNODE:
			return new ASTNode(cPtr, owner);
	
		}	
		//return new ASTBase(cPtr, owner);
    }

%}


/**
 * Convert ASTBase objects into the most specific object possible.
 */
%typemap("csout", excode=SWIGEXCODE) ASTBase*
{
	ASTBase ret = (ASTBase) libsbml.DowncastASTBase($imcall, $owner);$excode
	return ret;
}


#endif

/**
 * Convert SBMLNamespaces objects into the most specific object possible.
 */
%typemap("csout", excode=SWIGEXCODE) SBMLNamespaces*
{
	SBMLNamespaces ret
	    = (SBMLNamespaces) libsbml.DowncastSBMLNamespaces($imcall, $owner);$excode
	return ret;
}

/**
 * Convert SBMLConverter objects into the most specific object possible.
 */
%typemap("csout", excode=SWIGEXCODE) SBMLConverter*
{
	SBMLConverter ret
	    = (SBMLConverter) libsbml.DowncastSBMLConverter($imcall, $owner);$excode
	return ret;
}

/**
 * Convert SBMLExtension objects into the most specific object possible.
 */
%typemap("csout", excode=SWIGEXCODE) SBMLExtension*
{
        SBMLExtension ret
	    = (SBMLExtension) libsbml.DowncastExtension($imcall, $owner);$excode
        return ret;
}

/**
 * Convert SBMLExtensionRegistry objects into the most specific object possible.
 */
%typemap("csout", excode=SWIGEXCODE) SBMLExtensionRegistry*
{
        SBMLExtensionRegistry ret
	    = (SBMLExtensionRegistry) libsbml.DowncastSBMLExtensionRegistry($imcall, $owner);$excode
        return ret;
}

/**
 * Convert SBasePlugin objects into the most specific object possible.
 */
%typemap("csout", excode=SWIGEXCODE) SBasePlugin*
{
        SBasePlugin ret = (SBasePlugin) libsbml.DowncastSBasePlugin($imcall, $owner);$excode
        return ret;
}

/**
 * Convert SBase objects into the most specific object possible.
 */
%typemap("csout", excode=SWIGEXCODE) SBase*
{
	SBase ret = (SBase) libsbml.DowncastSBase($imcall, $owner);$excode
	return ret;
}

/**
 * Convert Rule objects into the most specific object possible.
 */
%typemap("csout", excode=SWIGEXCODE) Rule*
{
        Rule ret = (Rule) libsbml.DowncastSBase($imcall, $owner);$excode
	return ret;
}

/**
 * Convert SimpleSpeciesReference objects into the most specific object possible.
 */
%typemap("csout", excode=SWIGEXCODE) SimpleSpeciesReference*
{
	SimpleSpeciesReference ret
	    = (SimpleSpeciesReference) libsbml.DowncastSBase($imcall, $owner);$excode
	return ret;
}


/**
 * getCPtrAndDisown() is like getCPtr() but it also sets the SWIG memory
 * ownsership flag to false.
 *
 * We used to use %typemap(javagetcptr), but this has been deprecated
 * in SWIG 1.3.24.  Instead we add getCPtrAndDisown() from the incantation
 * below (taken from the SWIG 1.3.24 CHANGES file).
 */

/* Utility macro for manipulating the C# body code method attributes */
%define SWIGCSHARP_ATTRIBS(TYPENAME, CTOR_ATTRIB, GETCPTR_ATTRIB)

%typemap(csbody) TYPENAME
%{
	private HandleRef swigCPtr;
	protected bool swigCMemOwn;
	
	CTOR_ATTRIB $csclassname(IntPtr cPtr, bool cMemoryOwn)
	{
		swigCMemOwn = cMemoryOwn;
		swigCPtr    = new HandleRef(this, cPtr);
	}
	
	GETCPTR_ATTRIB static HandleRef getCPtr($csclassname obj)
	{
		return (obj == null) ? new HandleRef(null, IntPtr.Zero) : obj.swigCPtr;
	}
	
	GETCPTR_ATTRIB static HandleRef getCPtrAndDisown ($csclassname obj)
	{
		HandleRef ptr = new HandleRef(null, IntPtr.Zero);
		
		if (obj != null)
		{
			ptr             = obj.swigCPtr;
			obj.swigCMemOwn = false;
		}
		
		return ptr;
	}
%}


#if SWIG_VERSION >= 0x020000

%typemap(csbody_derived) TYPENAME
%{
	private HandleRef swigCPtr;
	
	CTOR_ATTRIB $csclassname(IntPtr cPtr, bool cMemoryOwn) : base($modulePINVOKE.$csclassname_SWIGUpcast(cPtr), cMemoryOwn)
	{
		//super($modulePINVOKE.$csclassnameUpcast(cPtr), cMemoryOwn);
		swigCPtr = new HandleRef(this, cPtr);
	}
	
	GETCPTR_ATTRIB static HandleRef getCPtr($csclassname obj)
	{
		return (obj == null) ? new HandleRef(null, IntPtr.Zero) : obj.swigCPtr;
	}
	
	GETCPTR_ATTRIB static HandleRef getCPtrAndDisown ($csclassname obj)
	{
		HandleRef ptr = new HandleRef(null, IntPtr.Zero);
		
		if (obj != null)
		{
			ptr             = obj.swigCPtr;
			obj.swigCMemOwn = false;
		}
		
		return ptr;
	}
%}

#else

%typemap(csbody_derived) TYPENAME
%{
	private HandleRef swigCPtr;
	
	CTOR_ATTRIB $csclassname(IntPtr cPtr, bool cMemoryOwn) : base($modulePINVOKE.$csclassnameUpcast(cPtr), cMemoryOwn)
	{
		//super($modulePINVOKE.$csclassnameUpcast(cPtr), cMemoryOwn);
		swigCPtr = new HandleRef(this, cPtr);
	}
	
	GETCPTR_ATTRIB static HandleRef getCPtr($csclassname obj)
	{
		return (obj == null) ? new HandleRef(null, IntPtr.Zero) : obj.swigCPtr;
	}
	
	GETCPTR_ATTRIB static HandleRef getCPtrAndDisown ($csclassname obj)
	{
		HandleRef ptr = new HandleRef(null, IntPtr.Zero);
		
		if (obj != null)
		{
			ptr             = obj.swigCPtr;
			obj.swigCMemOwn = false;
		}
		
		return ptr;
	}
%}

#endif

%enddef

/* The default is INTERNAL getCPtr, INTERNAL constructor */
SWIGCSHARP_ATTRIBS(SWIGTYPE, internal, internal)

/* Public getCPtr method, PUBLIC constructor */
%define PUBLIC_GETCPTR(TYPENAME)
SWIGCSHARP_ATTRIBS(TYPENAME, protected, public)
%enddef

/* Public getCPtr method, public constructor */
%define PUBLIC_BODYMETHODS(TYPENAME)
SWIGCSHARP_ATTRIBS(TYPENAME, public, public)
%enddef


/**
 *
 * Overrides the 'operator==', 'operator!=', 'Equals' and 'GetHashCode' methods 
 * for C# proxy classes of SBase subclasses and classes in libSBML.
 *
 * By default, 'operator==' ( and 'Equals' method) for each wrapped class
 * object returns 'true' if the given two objects refer to the same 
 * *C# proxy object* (not the underlying C++ object). 
 * For example, the following code returns 'true'.
 *
 *   Model m = new Model();
 *   m.createReaction();
 *   Reaction r1  = m.getReaction(0);
 *   Reaction r2 = r1;
 *   return (r1 == r2);  <---- this returns 'true'
 *
 * On the other hand, the following code returns 'false' in spite of
 * the same underlying C++ objects.
 *
 *   Model m = new Model();
 *   m.createReaction();
 *   Reaction r1 = m.getReaction(0);
 *   Reaction r2 = m.getReaction(0);
 *   return (r1 == r2);  <---- this returns 'false'
 *
 * The following override changes the behaviour of the default 'operator==' and
 * 'Equals' method such that returns 'true' if the given two objects refer to 
 * the same underlying C++  object (i.e. 'true' is returned in the both above
 *  examples).
 * 
 */


%define SWIGCS_EQUALS(CLASS)
%typemap("cscode") CLASS
%{
  public static bool operator==(CLASS lhs, CLASS rhs)
  {
    if((Object)lhs == (Object)rhs)
    {
      return true;
    }

    if( ((Object)lhs == null) || ((Object)rhs == null) )
    {
      return false;
    }

    return (getCPtr(lhs).Handle.ToString() == getCPtr(rhs).Handle.ToString());
  }

  public static bool operator!=(CLASS lhs, CLASS rhs)
  {
    return !(lhs == rhs);
  }

  public override bool Equals(Object sb)
  {
    if ( ! (sb is CLASS) )
    {
      return false;
    }

    return this == (CLASS)sb;
  }

  public override int GetHashCode()
  {
    return swigCPtr.Handle.ToInt32();
  }
%}
%enddef

SWIGCS_EQUALS(SBase)
SWIGCS_EQUALS(SBMLReader)
SWIGCS_EQUALS(SBMLWriter)
SWIGCS_EQUALS(ASTNode)
SWIGCS_EQUALS(CVTerm)
SWIGCS_EQUALS(Date)
SWIGCS_EQUALS(ModelHistory)
SWIGCS_EQUALS(ModelCreator)
SWIGCS_EQUALS(XMLNamespaces)
SWIGCS_EQUALS(SBMLNamespaces)
SWIGCS_EQUALS(XMLAttributes)
SWIGCS_EQUALS(XMLToken)
SWIGCS_EQUALS(XMLNode)
SWIGCS_EQUALS(XMLError)
SWIGCS_EQUALS(XMLErrorLog)
SWIGCS_EQUALS(XMLOutputStream)


/**
 * Wraps covariant return types of ::clone functions.
 *
 * Currently, C# doesn't support covariant return types.
 * However, in wrapped C# functions, covariant return types can be emulated 
 * just by changing the method modifier ("override" -> "new").
 */

#pragma SWIG nowarn=842

%define COVARIANT_RTYPE_CLONE(_CNAME_)
%typemap(cstype) _CNAME_* _CNAME_::clone  "_CNAME_"
%csmethodmodifiers _CNAME_::clone  "public new"
%enddef

COVARIANT_RTYPE_CLONE(Compartment)
COVARIANT_RTYPE_CLONE(CompartmentType)
COVARIANT_RTYPE_CLONE(Constraint)
COVARIANT_RTYPE_CLONE(Delay)
COVARIANT_RTYPE_CLONE(Event)
COVARIANT_RTYPE_CLONE(EventAssignment)
COVARIANT_RTYPE_CLONE(FunctionDefinition)
COVARIANT_RTYPE_CLONE(InitialAssignment)
COVARIANT_RTYPE_CLONE(KineticLaw)
COVARIANT_RTYPE_CLONE(Model)
COVARIANT_RTYPE_CLONE(Parameter)
COVARIANT_RTYPE_CLONE(Priority)
COVARIANT_RTYPE_CLONE(LocalParameter)
COVARIANT_RTYPE_CLONE(Reaction)
COVARIANT_RTYPE_CLONE(Rule)
COVARIANT_RTYPE_CLONE(AlgebraicRule)
COVARIANT_RTYPE_CLONE(AssignmentRule)
COVARIANT_RTYPE_CLONE(RateRule)
COVARIANT_RTYPE_CLONE(SBMLDocument)
COVARIANT_RTYPE_CLONE(Species)
COVARIANT_RTYPE_CLONE(SpeciesReference)
COVARIANT_RTYPE_CLONE(SpeciesType)
COVARIANT_RTYPE_CLONE(StoichiometryMath)
COVARIANT_RTYPE_CLONE(Trigger)
COVARIANT_RTYPE_CLONE(Unit)
COVARIANT_RTYPE_CLONE(UnitDefinition)
COVARIANT_RTYPE_CLONE(ListOf)
COVARIANT_RTYPE_CLONE(ListOfCompartmentTypes)
COVARIANT_RTYPE_CLONE(ListOfCompartments)
COVARIANT_RTYPE_CLONE(ListOfConstraints)
COVARIANT_RTYPE_CLONE(ListOfEventAssignments)
COVARIANT_RTYPE_CLONE(ListOfEvents)
COVARIANT_RTYPE_CLONE(ListOfFunctionDefinitions)
COVARIANT_RTYPE_CLONE(ListOfInitialAssignments)
COVARIANT_RTYPE_CLONE(ListOfParameters)
COVARIANT_RTYPE_CLONE(ListOfLocalParameters)
COVARIANT_RTYPE_CLONE(ListOfReactions)
COVARIANT_RTYPE_CLONE(ListOfRules)
COVARIANT_RTYPE_CLONE(ListOfSpecies)
COVARIANT_RTYPE_CLONE(ListOfSpeciesReferences)
COVARIANT_RTYPE_CLONE(ListOfSpeciesTypes)
COVARIANT_RTYPE_CLONE(ListOfUnitDefinitions)
COVARIANT_RTYPE_CLONE(ListOfUnits)

/**
 *
 * Wraps covariant return types of ListOfXXX::get functions.
 *
 * Currently, C# doesn't support covariant return types.
 * However, in wrapped C# functions, covariant return types can be emulated 
 * just by changing the method modifier ("override" -> "new").
 */

%define COVARIANT_RTYPE_LISTOF_GET_REMOVE(_CNAME_)
%typemap(cstype) _CNAME_* ListOf ## _CNAME_ ## s::get  "_CNAME_"
%csmethodmodifiers ListOf ## _CNAME_ ## s::get(unsigned int n)  "public new"
%typemap(cstype) _CNAME_* ListOf ## _CNAME_ ## s::remove  "_CNAME_"
%csmethodmodifiers ListOf ## _CNAME_ ## s::remove(unsigned int n)  "public new"
%enddef

COVARIANT_RTYPE_LISTOF_GET_REMOVE(CompartmentType)
COVARIANT_RTYPE_LISTOF_GET_REMOVE(Compartment)
COVARIANT_RTYPE_LISTOF_GET_REMOVE(EventAssignment)
COVARIANT_RTYPE_LISTOF_GET_REMOVE(Event)
COVARIANT_RTYPE_LISTOF_GET_REMOVE(FunctionDefinition)
COVARIANT_RTYPE_LISTOF_GET_REMOVE(InitialAssignment)
COVARIANT_RTYPE_LISTOF_GET_REMOVE(Parameter)
COVARIANT_RTYPE_LISTOF_GET_REMOVE(Reaction)
COVARIANT_RTYPE_LISTOF_GET_REMOVE(Rule)
COVARIANT_RTYPE_LISTOF_GET_REMOVE(SpeciesType)
COVARIANT_RTYPE_LISTOF_GET_REMOVE(UnitDefinition)
COVARIANT_RTYPE_LISTOF_GET_REMOVE(Constraint)
COVARIANT_RTYPE_LISTOF_GET_REMOVE(Unit)

// Some classes don't match the macro above and have to handled separately:

%typemap(cstype) Species* ListOfSpecies::get  "Species"
%csmethodmodifiers ListOfSpecies::get(unsigned int n) "public new"
%typemap(cstype) Species* ListOfSpecies::remove  "Species"
%csmethodmodifiers ListOfSpecies::remove(unsigned int n) "public new"

%typemap(cstype) SimpleSpeciesReference* ListOfSpeciesReferences::get  "SimpleSpeciesReference"
%csmethodmodifiers ListOfSpeciesReferences::get(unsigned int n)  "public new"
%typemap(cstype) SimpleSpeciesReference* ListOfSpeciesReferences::remove  "SimpleSpeciesReference"
%csmethodmodifiers ListOfSpeciesReferences::remove(unsigned int n)  "public new"

%typemap(cstype) LocalParameter* ListOfLocalParameters::get  "Parameter"
%csmethodmodifiers ListOfLocalParameters::get(unsigned int n)  "public new"
%typemap(cstype) LocalParameter* ListOfLocalParameters::remove  "Parameter"
%csmethodmodifiers ListOfLocalParameters::remove(unsigned int n)  "public new"



%define COVARIANT_GETID(_CNAME_)
%typemap(cstype) string   _CNAME_ ## ::getId  "_CNAME_"
%csmethodmodifiers  _CNAME_ ## ::getId  "public new"
%enddef

COVARIANT_GETID(Rule)
COVARIANT_GETID(EventAssignment)
COVARIANT_GETID(InitialAssignment)

/**
 * Wraps the SBMLConstructorException
 *
 * The SBMLConstructorException (C++ class) is wrapped as the 
 * SBMLConsturctorException (C# class) which is derived from
 * the built-in ArgumentException class.
 *
 * For example, the exception can be catched in C# code as follows:
 *
 * ---------------------------------------------
 *  Model m;
 *  try
 *  {
 *    m = new Model(level,version);
 *  }
 *  catch (SBMLConstructorException e)
 *  {
 *     string errmsg = e.Message;
 *  }
 * ---------------------------------------------
 */

%ignore SBMLConstructorException::SBMLConstructorException(std::string);

%typemap(csbase) SBMLConstructorException "System.ArgumentException";
%typemap(cscode) SBMLConstructorException 
%{
  internal SBMLConstructorException(IntPtr cPtr, bool cMemoryOwn, string v) : base(v)
  {
    swigCMemOwn = cMemoryOwn;
    swigCPtr    = new HandleRef(this, cPtr);
  }

  public SBMLConstructorException(string v) : 
   this(libsbmlPINVOKE.new_SBMLConstructorException__SWIG_0(), true, v) 
  {}
%}

%typemap(csbase) XMLConstructorException "System.ArgumentException";
%typemap(cscode) XMLConstructorException 
%{
  internal XMLConstructorException(IntPtr cPtr, bool cMemoryOwn, string v) : base(v)
  {
    swigCMemOwn = cMemoryOwn;
    swigCPtr    = new HandleRef(this, cPtr);
  }

  public XMLConstructorException(string v) : 
   this(libsbmlPINVOKE.new_XMLConstructorException(), true, v) 
  {}
%}

%ignore XMLConstructorException(std::string message);
//
// cited from SWIG and C# manual ("18.4.4 Custom C# ApplicationException example")
// in http://www.swig.org/
// 
%insert(runtime) %{
  // Code to handle throwing of C# CustomApplicationException from C/C++ code.
  // The equivalent delegate to the callback, CSharpExceptionCallback_t, is CustomExceptionDelegate
  // and the equivalent customExceptionCallback instance is customDelegate
  typedef void (SWIGSTDCALL* CSharpExceptionCallback_t)(const char *, int);
  CSharpExceptionCallback_t customExceptionCallback = NULL;

  extern "C" SWIGEXPORT
  void SWIGSTDCALL CustomExceptionRegisterCallback(CSharpExceptionCallback_t customCallback) {
    customExceptionCallback = customCallback;
  }

  // Note that SWIG detects any method calls named starting with
  // SWIG_CSharpSetPendingException for warning 845
  static void SWIG_CSharpSetPendingExceptionCustom(const char *msg, int type) {
    customExceptionCallback(msg, type);
  }
%}

%pragma(csharp) imclasscode=%{
  class CustomExceptionHelper {
    // C# delegate for the C/C++ customExceptionCallback
    public delegate void CustomExceptionDelegate(string message, int type);
    static CustomExceptionDelegate customDelegate =
                                   new CustomExceptionDelegate(SetPendingCustomException);

    [DllImport("$dllimport", EntryPoint="CustomExceptionRegisterCallback")]
    public static extern
           void CustomExceptionRegisterCallback(CustomExceptionDelegate customCallback);

    static void SetPendingCustomException(string message, int type) {
      if (type == 0)
      SWIGPendingException.Set(new SBMLConstructorException(message));
	  else 
		SWIGPendingException.Set(new XMLConstructorException(message));
    }

    static CustomExceptionHelper() {
      CustomExceptionRegisterCallback(customDelegate);
    }
  }

  // The following pragma's disable the compiler warning that the variable is
  // never used.  Don't remove the actual code, though, or you will get 
  // compile-time errors.

  #pragma warning disable 0414
  static CustomExceptionHelper exceptionHelper = new CustomExceptionHelper();
  #pragma warning restore 0414
%}


%define SBMLCONSTRUCTOR_EXCEPTION(SBASE_CLASS_NAME)
%exception SBASE_CLASS_NAME
%{
  try {
    $action
  }
  catch (const SBMLConstructorException &e) {
    SWIG_CSharpSetPendingExceptionCustom(e.what(),0);
  }
  catch (const SBMLExtensionException &e) {
    SWIG_CSharpSetPendingExceptionCustom(e.what(),0);
  }
%}
%enddef


SBMLCONSTRUCTOR_EXCEPTION(Compartment)
SBMLCONSTRUCTOR_EXCEPTION(CompartmentType)
SBMLCONSTRUCTOR_EXCEPTION(Constraint)
SBMLCONSTRUCTOR_EXCEPTION(Delay)
SBMLCONSTRUCTOR_EXCEPTION(Event)
SBMLCONSTRUCTOR_EXCEPTION(EventAssignment)
SBMLCONSTRUCTOR_EXCEPTION(FunctionDefinition)
SBMLCONSTRUCTOR_EXCEPTION(InitialAssignment)
SBMLCONSTRUCTOR_EXCEPTION(KineticLaw)
SBMLCONSTRUCTOR_EXCEPTION(Model)
SBMLCONSTRUCTOR_EXCEPTION(Parameter)
SBMLCONSTRUCTOR_EXCEPTION(Priority)
SBMLCONSTRUCTOR_EXCEPTION(LocalParameter)
SBMLCONSTRUCTOR_EXCEPTION(Reaction)
SBMLCONSTRUCTOR_EXCEPTION(AssignmentRule)
SBMLCONSTRUCTOR_EXCEPTION(AlgebraicRule)
SBMLCONSTRUCTOR_EXCEPTION(RateRule)
SBMLCONSTRUCTOR_EXCEPTION(Species)
SBMLCONSTRUCTOR_EXCEPTION(SpeciesReference)
SBMLCONSTRUCTOR_EXCEPTION(ModifierSpeciesReference)
SBMLCONSTRUCTOR_EXCEPTION(SpeciesType)
SBMLCONSTRUCTOR_EXCEPTION(StoichiometryMath)
SBMLCONSTRUCTOR_EXCEPTION(Trigger)
SBMLCONSTRUCTOR_EXCEPTION(Unit)
SBMLCONSTRUCTOR_EXCEPTION(UnitDefinition)
SBMLCONSTRUCTOR_EXCEPTION(SBMLDocument)
SBMLCONSTRUCTOR_EXCEPTION(SBMLNamespaces)
SBMLCONSTRUCTOR_EXCEPTION(SBMLExtensionNamespaces)

SBMLCONSTRUCTOR_EXCEPTION(ListOf)
SBMLCONSTRUCTOR_EXCEPTION(ListOfCompartments)
SBMLCONSTRUCTOR_EXCEPTION(ListOfCompartmentTypes)
SBMLCONSTRUCTOR_EXCEPTION(ListOfConstraints)
SBMLCONSTRUCTOR_EXCEPTION(ListOfEventAssignments)
SBMLCONSTRUCTOR_EXCEPTION(ListOfEvents)
SBMLCONSTRUCTOR_EXCEPTION(ListOfFunctionDefinitions)
SBMLCONSTRUCTOR_EXCEPTION(ListOfInitialAssignments)
SBMLCONSTRUCTOR_EXCEPTION(ListOfParameters)
SBMLCONSTRUCTOR_EXCEPTION(ListOfLocalParameters)
SBMLCONSTRUCTOR_EXCEPTION(ListOfReactions)
SBMLCONSTRUCTOR_EXCEPTION(ListOfRules)
SBMLCONSTRUCTOR_EXCEPTION(ListOfSpecies)
SBMLCONSTRUCTOR_EXCEPTION(ListOfSpeciesReferences)
SBMLCONSTRUCTOR_EXCEPTION(ListOfSpeciesTypes)
SBMLCONSTRUCTOR_EXCEPTION(ListOfUnitDefinitions)
SBMLCONSTRUCTOR_EXCEPTION(ListOfUnits)




%define XMLCONSTRUCTOR_EXCEPTION(SBASE_CLASS_NAME)
%exception SBASE_CLASS_NAME
%{
  try {
    $action
  }
  catch (const XMLConstructorException &e) {
    SWIG_CSharpSetPendingExceptionCustom(e.what(),1);
  }
%}
%enddef


XMLCONSTRUCTOR_EXCEPTION(XMLAttributes)
XMLCONSTRUCTOR_EXCEPTION(XMLError)
XMLCONSTRUCTOR_EXCEPTION(XMLNamespaces)
XMLCONSTRUCTOR_EXCEPTION(XMLNode)
XMLCONSTRUCTOR_EXCEPTION(XMLOutputStream)
XMLCONSTRUCTOR_EXCEPTION(XMLToken)
XMLCONSTRUCTOR_EXCEPTION(XMLTripple)


/**
 * takeover ownership
 *
 * - void ListOf::appendAndOwn(SBase* item)
 */
%typemap(csin) SBase*       item "SBase.getCPtrAndDisown($csinput)";
%typemap(csin) const SBase* item "SBase.getCPtr($csinput)";

/**
 * takeover ownership
 *
 * - void ASTNode::addChild (ASTNode* child)
 * - void ASTNode::prependChild (ASTNode* child)
 */
%typemap(csin) ASTNode*       child "ASTNode.getCPtrAndDisown($csinput)";
%typemap(csin) const ASTNode* child "ASTNode.getCPtr($csinput)";

/**
 * takeover ownership
 *
 * - void ASTNode::insertChild  (unsigned int n, ASTNode* newChild)
 * - void ASTNode::replaceChild (unsigned int n, ASTNode* newChild)
 */
%typemap(csin) ASTNode*       newChild "ASTNode.getCPtrAndDisown($csinput)";
%typemap(csin) const ASTNode* newChild "ASTNode.getCPtr($csinput)";

/**
 * takeover ownership
 *
 * - void ASTNode::addSemanticsAnnotation (XMLNode* sAnnotation);
 */
%typemap(csin) XMLNode*       sAnnotation "XMLNode.getCPtrAndDisown($csinput)";
%typemap(csin) const XMLNode* sAnnotation "XMLNode.getCPtr($csinput)";


/**
 * Of course, there are some exceptions to the above rule.  These typemaps
 * cover the following functions:
 *
 *  - writeSBML()
 *  - writeSBMLToString()
 *  - writeMathML()
 *  - writeMathMLToString()
 *
 * Which take either an SBMLDocument or MathMLDocument as input.
 */
%typemap(csin) SBMLDocument   * "SBMLDocument.getCPtr($csinput)";
%typemap(csin) MathMLDocument * "MathMLDocument.getCPtr($csinput)";



%typemap(cstype) std::ostream& "OStream"
%typemap(csin) std::ostream& "SWIGTYPE_p_std__ostream.getCPtr($csinput.get_ostream())";


//////////////////////////////////////////////////////////////////////
//
// directives for converting Unicode <-> UTF8 in Windows
//
//////////////////////////////////////////////////////////////////////

#ifdef SWIGWIN

%typemap(ctype) std::string        "wchar_t*"
%typemap(ctype) std::string&       "wchar_t*"
%typemap(ctype) const std::string& "wchar_t*"
%typemap(ctype) std::string*       "wchar_t*"
%typemap(ctype) const std::string* "wchar_t*"
%typemap(ctype) char*              "wchar_t*"
%typemap(ctype) const char*        "wchar_t*"


//
// Unicode -> UTF8 (std::string&, const std::string&)
// (argument variable)
//
%typemap("in") std::string&, const std::string&  (std::string arg_str) {
  char*  mbstr = convertUnicodeToUTF8($input);
  if (!mbstr) return $null;

  arg_str.assign(mbstr);
  $1 = &arg_str;
  delete[] mbstr;
}


//
// UTF8 -> Unicode (std::string&, const std::string&) 
// (return variable)
//
%typemap("out") std::string&, const std::string& {
  $result = convertUTF8ToUnicode(($1)->c_str());
  wchar_t* unistr = convertUTF8ToUnicode(($1)->c_str());
  $result = (wchar_t*) SWIG_csharp_wstring_callback((const wchar_t*)unistr);
  delete[] unistr;
}


//
// Unicode -> UTF8 (std::string)
// (argument variable)
//
%typemap("in") std::string {
  char*  mbstr = convertUnicodeToUTF8($input);
  (&$1)->assign(mbstr);
  delete[] mbstr;
}


//
// UTF8 -> Unicode (std::string)
// (return variable)
//
%typemap("out") std::string {
  $result = convertUTF8ToUnicode( $1.c_str() );
  wchar_t* unistr = convertUTF8ToUnicode( $1.c_str() );
  $result = (wchar_t*) SWIG_csharp_wstring_callback((const wchar_t*)unistr);
  delete[] unistr;
}


//
// Unicode -> UTF8 (char*, const char*)
// (argument variable)
//
%typemap("in")  char*, const char* {
  if ($input)
  {
    $1 = convertUnicodeToUTF8($input);
    if (!$1) return $null;
  }
}

%typemap("freearg")  char*, const char* {
  delete[] $1;
}


//
// UTF8 -> Unicode (char*, const char*)
// (returned variable)
//
%typemap("out")  char*, const char* {
  $result = convertUTF8ToUnicode( $1 );
  wchar_t* unistr = convertUTF8ToUnicode( $1 );
  $result = (wchar_t*) SWIG_csharp_wstring_callback((const wchar_t*)unistr);
  delete[] unistr;
}


//
//  A string for filename should be encoded by ANSI CP not by UTF-8 
//  because file i/o functions used in libSBML requires the ANSI CP 
//  encoded string for a given filename.
//  
//  1) SBMLReader::readSBML(const std::string& filename)
//  2) readSBML(const char* filename)
//  3) SBMLWriter::writeSBML(SBMLDocument*, const std::string& filename)
//  4) writeSBML(SBMLDocument*, const char* filename)
//


//
// Unicode -> ANSI CP (for const std::string& filename)
//
%typemap("in") const std::string& filename (std::string arg_str) {
    char*  mbstr = convertUnicodeToACP($input);
    if (!mbstr) return $null;

    arg_str.assign(mbstr);
    $1 = &arg_str;
    delete[] mbstr;
}


//
// Unicode -> ANSI CP (for const char* filename)
//
%typemap("in")  const char* filename{
    if ($input)
    {
      $1 = convertUnicodeToACP($input);
      if (!$1) return $null;
    }
}

#endif //SWIGWIN

///////////////////////////////////////////////////////////////////////////

%include "OStream.h"

%{
#include "OStream.cpp"
%}

%pragma(csharp) modulecode =
%{
  public static readonly OStream cout = new OStream(OStream.COUT); 
  public static readonly OStream cerr = new OStream(OStream.CERR); 
  public static readonly OStream clog = new OStream(OStream.CLOG); 
%}


/**
 *  Wraps the following functions by using the corresponding
 *  ListWrapper<TYPENAME> class.
 *
 *  - List* ModelHistory::getListCreators()
 *  - List* ModelHistory::getListModifiedDates()
 *  - List* SBase::getCVTerms()
 *  - List* SBMLNamespaces::getSupportedNamespaces()
 *
 *  ListWrapper<TYPENAME> class is wrapped as TYPENAMEList class.
 *  So, the above functions are wrapped as follows:
 *
 *  - ModelCreatorList ModelHistory.getListCreators()
 *  - DateList         ModelHistory.getListModifiedDates()
 *  - CVTermList       SBase.getCVTerms()
 *  - SBMLNamespacesList  SBMLNamespaces.getSupportedNamespaces()
 *
 */

%define LIST_WRAPPER(_FNAME_,_TYPENAME_)
%typemap(cstype)  List* _FNAME_ %{ _TYPENAME_ ## List %}
%typemap(csout) List* _FNAME_ 
{ 
  IntPtr cPtr = $imcall;
  return (cPtr == IntPtr.Zero) ? null : new _TYPENAME_ ## List(cPtr, true);
}
%typemap(out) List* _FNAME_ 
{
   ListWrapper<_TYPENAME_> *listw = ($1 != 0) ? new ListWrapper<_TYPENAME_>($1) : 0;  
   $result = (void*)listw;
}
%enddef

LIST_WRAPPER(ModelHistory::getListCreators,ModelCreator)
LIST_WRAPPER(ModelHistory::getListModifiedDates,Date)
LIST_WRAPPER(SBase::getCVTerms,CVTerm)
LIST_WRAPPER(SBase::getListOfAllElements,SBase)
LIST_WRAPPER(SBasePlugin::getListOfAllElements,SBase)
LIST_WRAPPER(SBase::getListOfAllElementsFromPlugins,SBase)
LIST_WRAPPER(SBMLNamespaces::getSupportedNamespaces,SBMLNamespaces)

 
%include "local-packages.i"
%include "csdoc.i"
