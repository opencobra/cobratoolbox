/**
 * @file   Compiler.cs
 * @brief  Runtime Compiler for C# files.
 * @author Frank Bergmann (fbergman@u.washington.edu)
 * 
 *<!---------------------------------------------------------------------------
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
 *--------------------------------------------------------------------------->*/

#region Using directives 
using System;
using System.Text;
using System.Collections;
using System.Collections.Specialized;
using System.Reflection;
using Microsoft.CSharp;
using System.CodeDom;
using System.CodeDom.Compiler;
#endregion

namespace LibSBMLCSTestRunner
{
    /// <summary>
    /// the Compile class was written out of the idea to generate wrapper 
    /// classes in memory at runtime and then compile them ... 
    /// </summary>
    public class Compiler
    {


        /// <summary>
        /// the execute method takes a stringcollection of wrapper classes,
        /// compiles them and executes methods on the classes
        /// </summary>
        /// <param name="oProxyCode"></param>
        public static object GetInstance(string source, string sClassName)
        {
            Assembly oResult = GetAssembly(source);
            try
            {
                object o = oResult.CreateInstance(sClassName);
                if (o != null)
                {
                    return o;
                }
                else
                {
                    System.Diagnostics.Debug.WriteLine("Couldn't create instance: '" + sClassName + "'");
                    System.Diagnostics.Debug.WriteLine("Error Compiling the model.");
                }
            }
            catch (Exception ex)
            {
                m_sCompileErrors.Add("Error Compiling the model: " + ex.Message);
            }
            return null;

        }

        /// <summary>
        /// the execute method takes a stringcollection of wrapper classes,
        /// compiles them and executes methods on the classes
        /// </summary>        
        public static object GetInstance(string source, string sClassName, string sLocation)
        {

            addAssembly(sLocation);
            return GetInstance(source, sClassName);
        }



        public static Assembly GetAssembly(string source)
        {
            Compiler oCompler = new Compiler();
            CSharpCodeProvider cscp = new CSharpCodeProvider();
            return oCompler.Compile(cscp, source);
        }


        /// <summary>
        /// adds an assembly to the assembly list ... this list will be needed
        /// to add references to that assemblies for the newly compiled class
        /// </summary>
        /// <param name="sAssembly"></param>
        public static void addAssembly(string sAssembly)
        {
            m_oAssemblies.Add(sAssembly);
        }
        
        public static string getLastErrors()
        {
            StringBuilder oBuilder = new StringBuilder();
            foreach (string s in m_sCompileErrors)
                oBuilder.Append(s + Environment.NewLine);
            return oBuilder.ToString();
        }

        private Assembly Compile(CodeDomProvider provider, string source)
        {
            m_sCompileErrors.Clear();
            CompilerParameters param = new CompilerParameters();
            param.GenerateExecutable = false;
            param.IncludeDebugInformation = false;
            param.GenerateInMemory = true;
            param.TreatWarningsAsErrors = false;
            param.WarningLevel = 2;
            foreach (string s in m_oAssemblies)
                param.ReferencedAssemblies.Add(s);

            CompilerResults cr = provider.CompileAssemblyFromSource(param, source);

            if (cr.Errors.Count != 0)
            {
                m_sCompileErrors.Add("Error Compiling the model:");
                CompilerErrorCollection es = cr.Errors;
                foreach (CompilerError s in es)
                {
                    m_sCompileErrors.Add("    Error at Line,Col: " + s.Line + "," + s.Column + " error number: " + s.ErrorNumber + " " + s.ErrorText);
                }
                return null;
            }
            return cr.CompiledAssembly;
        }
        private static StringCollection m_oAssemblies = new StringCollection();
        private static StringCollection m_sCompileErrors = new StringCollection();
    }
}

