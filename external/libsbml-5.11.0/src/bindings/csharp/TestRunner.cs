/**
 * @file   TestRunner.cs
 * @brief  Test Runner for C# test files.
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

using System;
using System.Collections.Generic;
using System.Text;
using System.IO;
using System.Reflection;
using System.Diagnostics;

namespace LibSBMLCSTestRunner
{


    /// <summary>
    /// <para>This test Programm takes a directory of C# files, compiles them and 
    /// then runs all test methods found. </para>
    /// 
    /// <para>- currently no support for test data</para>
    /// 
    /// <para>To use it simply invoke it with three arguments, for example: 
    /// 
    /// <c>LibSBMLCSTestRunner \\libsbml\\src\\sbml\\test \\libsbml\\src\\sbml\\test-data libsbmlCS.dll</c>
    /// </para>
    /// 
    /// author: Frank Bergmann (fbergman@u.washington.edu)
    /// 
    /// </summary>
    class TestRunner
    {
        private static void PrintUsageAndExit()
        {

            Console.WriteLine("Usage: TestRunner");
            Console.WriteLine();
            Console.WriteLine("\t -t | --tests <Directory containing generated test files>");
            Console.WriteLine("\t -d | --data <Directory containing test-data>");
            Console.WriteLine("\t -l | --lib  <Full path to libsbml C# bindings to be used>");
            Console.WriteLine("\t -a | --additional-tests  <space separated list of additional directories>");
            Console.WriteLine("\t -w | --working-dir   <directory to change into before running tests.>");
            Console.WriteLine("\t -p | --path   <directory add to the path.>");
            Console.WriteLine();
            Console.WriteLine("For backwards compatibility it is also possible to invoke the testrunner");
            Console.WriteLine("with only the test data directory, in which case tests compiled into the");
            Console.WriteLine("testrunner will be executed. Or it could be invoked with three arguments");
            Console.WriteLine("1. the test directory, 2. the test data directory, 3. the library to use.");
            Console.WriteLine();
            Environment.Exit(-1);
        }

        static void Main(string[] args)
        {
            TestArguments arguments = new TestArguments(args);
			if (arguments.HaveAdditionalPath)
			{
                ProcessStartInfo info = new ProcessStartInfo(
                                    new FileInfo(Assembly.GetEntryAssembly().Location).FullName,
                                    arguments.StrippedArgs()
                                    );
                info.UseShellExecute = false;
                info.EnvironmentVariables["PATH"] = arguments.AdditionalPath + ";" + info.EnvironmentVariables["PATH"];
                info.EnvironmentVariables["LD_LIBRARY_PATH"] = arguments.AdditionalPath + ":" + info.EnvironmentVariables["LD_LIBRARY_PATH"];
                info.EnvironmentVariables["DYLD_LIBRARY_PATH"] = arguments.AdditionalPath + ":" + info.EnvironmentVariables["DYLD_LIBRARY_PATH"];
                Process.Start(info);
				return;
			}
			
			Console.WriteLine("LibSBML C# Testrunner");
            Console.WriteLine("=====================");

         
            if (!arguments.IsValid)
            {
                // for backwards compatibility 
                if (args.Length == 1 )
                {
                    arguments = new TestArguments();
                    arguments.TestDataDirectory = args[0];
                }
                else if (args.Length == 3)
                {
                    arguments = new TestArguments();
                    arguments.TestDirectory = args[0];
                    arguments.TestDataDirectory = args[1];
                    arguments.ManagedLibrary = args[2];
                }

                if (!arguments.IsValid)
                {
                    PrintUsageAndExit();
                }
            }
			
			if (arguments.HaveWorkingDirectory)
				Directory.SetCurrentDirectory(arguments.WorkingDirectory);	

            if (File.Exists(arguments.ManagedLibrary))
                AppDomain.CurrentDomain.AssemblyResolve += delegate(object s, ResolveEventArgs e)
                                                           {
                                                               string filename = new AssemblyName(e.Name).Name;
                                                               string path = string.Format(@"{0}.dll", Path.Combine(new FileInfo(arguments.ManagedLibrary).DirectoryName, filename));
                                                               return Assembly.LoadFrom(path);
                                                           };

            if (arguments.UseCompiledTests)
            {
                RunTestsInNamespace(arguments);
            }
            else
            {
                CompileAndRunTests(arguments);
            }


            if (arguments.HaveAdditionalDirectories)
            {
                Console.WriteLine();
                Console.WriteLine("AdditionalTests");
                Console.WriteLine("===============");
                Console.WriteLine();

                foreach (string path in arguments.AdditionalTestDirectories)
                {
                    Console.WriteLine("running tests from: " + path);
                    Console.WriteLine();
                    RunTests(arguments.ManagedLibrary, path, arguments.TestDataDirectory);
                    Console.WriteLine();
                }
            }


        }

        /// <summary>
        /// This runs all tests in the 'LibSBMLCSTest' namespace, which 
        /// presumably are included in this assembly. 
        /// </summary>
        /// <param name="args">TestRunner arguments</param>
        private static void RunTestsInNamespace(TestArguments args)
        {

            string sData = args.TestDataDirectory;

            if (!Directory.Exists(sData))
            {
                Console.WriteLine("Data Directory does not exist" + Environment.NewLine);
                Environment.Exit(-1);
            }


            // all seems well so let us run through the tests:
            Console.WriteLine("Running the tests with: ");
            Console.WriteLine("\tData Directory:   " + sData);
            Console.WriteLine();

            RunTestsInAssembly(Assembly.GetExecutingAssembly(), sData);

            Console.WriteLine(Environment.NewLine);
            Console.WriteLine(String.Format("Total Number of Tests {0}, failures {1}",
                                 nTestFunc, nFailureSum));
            if (nFailureSum == 0)
            {
                Console.WriteLine("\nAll tests passed." + Environment.NewLine);
                return;
            }

            PrintErrors();
            Environment.Exit(1);

        }

        /// <summary>
        /// This runs the tests by recompiling all tests in the specified
        /// source directory.
        /// </summary>
        /// <param name="args">TestRunner arguments</param>
        private static void CompileAndRunTests(TestArguments args)
        {

            string sSource = args.TestDirectory;
            string sData = args.TestDataDirectory;
            string sLibrary = args.ManagedLibrary;

            if (!Directory.Exists(sSource))
            {
                Console.WriteLine("Source Directory does not exist" + Environment.NewLine);
                PrintUsageAndExit();
            }

            if (!Directory.Exists(sData))
            {
                Console.WriteLine("Data Directory does not exist" + Environment.NewLine);
                PrintUsageAndExit();
            }

            if (!File.Exists(sLibrary))
            {
                Console.WriteLine("libsbml C# binding assembly does not exist." + Environment.NewLine);
                PrintUsageAndExit();
            }

            // all seems well so let us run through the tests:
            Console.WriteLine("Running the tests with: ");
            Console.WriteLine("\tSource Directory: " + sSource);
            Console.WriteLine("\tData Directory:   " + sData);
            Console.WriteLine("\tC# binding:       " + sLibrary);
            Console.WriteLine();

            RunTests(sLibrary, sSource, sData);
        }

        private static int RunTestsInDirectory(string testDir, string sData)
        {
            // then compile and run all C# files
            string[] testFiles = Directory.GetFiles(testDir, "*.cs");

            foreach (string testFile in testFiles)
            {
                RunTestFile(testFile, testDir, sData);
            }
            return testFiles.Length;
        }

        private static void RunTests(string sLibrary, string sSource, string sData)
        {
            // add reference library to the compiler so that it will be referenced
            // by the test files
            Compiler.addAssembly(sLibrary);

            int testFileNum = 0;

            nCompileErrors = 0;
            nSuccessSum = 0;
            nFailureSum = 0;
            nTestFunc = 0;

            string[] testDirs = Directory.GetDirectories(sSource);
            foreach (string testDir in testDirs)
            {
                testFileNum += RunTestsInDirectory(testDir, sData);
            }

            if (testFileNum == 0)
            {
                testFileNum += RunTestsInDirectory(sSource, sData);
            }

            Console.WriteLine();
            Console.WriteLine();
            Console.WriteLine(String.Format("Encountered {0} compile errors (invalid tests)", nCompileErrors));
            Console.WriteLine(String.Format("Total Number of Test files {0}, Tests {1}, failures {2}",
                                             testFileNum, nTestFunc, nFailureSum));
            if (nFailureSum == 0 && nCompileErrors == 0)
            {
                Console.WriteLine("\nAll tests passed.");
                return;
            }

            PrintErrors();
            Environment.Exit(1);
        }

        static int nCompileErrors;
        static int nSuccessSum;
        static int nFailureSum;
        static int nTestFunc;

        readonly static List<ErrorDetails> _errors = new List<ErrorDetails>();

        /// <summary>
        /// Prints all errors that occured
        /// </summary>
        private static void PrintErrors()
        {
            if (_errors == null || _errors.Count == 0) return;

            foreach (ErrorDetails item in _errors)
            {
                Console.WriteLine();
                Console.WriteLine();

                Console.WriteLine(item.Message);
                Console.WriteLine(new string('=', 20));
                Console.WriteLine(item.Exception.Message);
                Console.WriteLine(item.Exception.StackTrace);
            }

            Console.WriteLine();
            Console.WriteLine();
        }

        private static void RunTestFile(string testFile, string testDir, string sData)
        {
#if DEBUG
            Console.WriteLine(String.Format("Runing test file: '{0}' in {1}", new FileInfo(testFile).Name, testDir));
            Console.WriteLine("----------------------------------------------------------------");
#endif
            // read C# code            
            string source = File.ReadAllText(testFile);

            // compile the test file and create an assembly            
            Assembly oTestClass = Compiler.GetAssembly(source);

            if (oTestClass == null)
            {
                Console.WriteLine("Error compiling the test class (details on std::error) ");
                Console.Error.WriteLine(Compiler.getLastErrors());
                nCompileErrors++;
                Console.WriteLine();
                return;
            }

            // test compiled so now we can run the tests
            RunTestsInAssembly(oTestClass, sData);
#if DEBUG
            Console.WriteLine(); 
            Console.WriteLine();
#endif
        }

        private static void RunTestsInAssembly(Assembly oTestClass, string sData)
        {
            // get all classes, we know that all test-classes begin with Test
            Type[] types = oTestClass.GetExportedTypes();
            foreach (Type type in types)
            {
                if (type.Name.StartsWith("Test"))
                {
                    // we have a test class: 
                    RunTestsInType(oTestClass, type, sData);
                }
            }
        }

        private static void RunTestsInType(Assembly oTestClass, Type type, string sData)
        {
            // counting successes and failures
            int nSuccess = 0;
            int nFailure = 0;

            try
            {
                // get all methods
                MemberInfo[] members = type.GetMembers();

                foreach (MemberInfo member in members)
                {

                    // test methods begin with test_
                    if (member.Name.StartsWith("test_"))
                    {
                        ++nTestFunc;
                        // set up the class
                        object testClass = SetupTestClass(oTestClass, type);

                        // run the test
                        try
                        {
                            type.InvokeMember(member.Name, BindingFlags.InvokeMethod |
                                        BindingFlags.Default, null, testClass, null);
                        }
                        catch (TargetInvocationException ex)
                        {
                            Console.Write("E");
                            _errors.Add(new ErrorDetails(
                                String.Format("Error in '{0}': ", member.Name),
                                ex.InnerException));
                            nFailure++;
                            continue;
                        }
                        catch (Exception ex)
                        {
                            Console.Write("E");
                            _errors.Add(new ErrorDetails(
                                string.Format("Error in '{0}': ", member.Name),
                                ex));
                            nFailure++;
                            continue;
                        }

                        // if we are still here the test was successful
#if DEBUG
                        Console.WriteLine(String.Format("Calling '{0}'", member.Name));
#else
                        Console.Write(".");
#endif
                        nSuccess++;

                    }
                }
            }
            catch (Exception ex)
            {
                Console.Write("E");
                _errors.Add(new ErrorDetails(
                    String.Format("Error running tests for {0}: ", type.Name),
                    ex));
                return;
            }

#if DEBUG
            Console.WriteLine();
            Console.WriteLine(
                String.Format("Testing completed: Pass:{0}, Fail:{1} (Total:{2})",
                              nSuccess, nFailure, nSuccess+nFailure));
#else
            Console.Write(".");
#endif
            nSuccessSum += nSuccess;
            nFailureSum += nFailure;

        }

        private static object SetupTestClass(Assembly oTestClass, Type type)
        {

            object oClass = Activator.CreateInstance(type);
            try
            {
                type.InvokeMember("setUp",
                                  BindingFlags.InvokeMethod | BindingFlags.Default,
                                  null, oClass, null);
            }
            catch (Exception)
            {
                // 2010-07-22 <mhucka@caltech.edu> Some just don't have a
                // setup class.  It's confusing to see these errors.  

                // Console.WriteLine("Could not run setUp class ... ");
            }
            return oClass;
        }
    }

    /// <summary>
    /// Internal class holding all error information
    /// </summary>
    public class ErrorDetails
    {
        private Exception _exception;

        /// <summary>
        /// Gets / Sets the Exception
        /// </summary>
        public Exception Exception
        {
            get { return _exception; }
            set { _exception = value; }
        }

        private string _message;

        /// <summary>
        /// Gets / Sets the Error message
        /// </summary>
        public string Message
        {
            get { return _message; }
            set { _message = value; }
        }

        /// <summary>
        /// Initializes a new instance of the ErrorDetails class.
        /// </summary>
        /// <param name="message">Mesage to print</param>
        /// <param name="exception">exception object</param>
        public ErrorDetails(string message, Exception exception)
        {
            Exception = exception;
            Message = message;
        }
    }

    /// <summary>
    /// Test arguments parses the command line arguments given to the testrunner
    /// </summary>
    public class TestArguments
    {
        /// <summary>
        /// Constructs a new TestArguments object from command line arguments.
        /// </summary>
        /// <param name="args">command line arguments</param>
        public TestArguments(string[] args)
            : this()
        {
            ParseArguments(args);
        }

        /// <summary>
        /// Initializes a new instance of the TestArguments class.
        /// </summary>
        public TestArguments()
        {
            ManagedLibrary = "libsbmlcsP.dll";
            AdditionalTestDirectories = new List<string>();
        }

        private string[] _OriginalArgs;
        public string[] OriginalArgs
        {
            get
            {
                return _OriginalArgs;
            }
            set
            {
                _OriginalArgs = value;
            }
        }

        public void ParseArguments(string[] args)
        {
            _OriginalArgs = args;

            for (int i = 0; i < args.Length; i++)
            {
                string current = args[i].ToLowerInvariant();
                bool haveNext = i + 1 < args.Length;
                string next = (haveNext ? args[i + 1] : null);

                if (haveNext && (current == "-l" || current == "--lib"))
                {
                    ManagedLibrary = next;
                    i++;
                }
                else if (haveNext && (current == "-d" || current == "--data"))
                {
                    TestDataDirectory = next;
                    i++;
                }
                else if (haveNext && (current == "-p" || current == "--path"))
                {
                    AdditionalPath = next;
                    i++;
                }
                else if (haveNext && (current == "-t" || current == "--tests"))
                {
                    TestDirectory = next;
                    i++;
                }
                else if (haveNext && (current == "-w" || current == "--working-dir"))
                {
                    WorkingDirectory = next;
                    i++;
                }
                else if (haveNext && (current == "-a" || current == "--additional-tests"))
                {
                    // consume remaining arguments
                    string[] additionalDirs = new string[args.Length - (i + 1)];
                    Array.Copy(args, i + 1, additionalDirs, 0, args.Length - (i + 1));
                    AdditionalTestDirectories.AddRange(additionalDirs);
                    return;
                }
            }
        }

        public bool HaveAdditionalDirectories
        {
            get
            {
                return AdditionalTestDirectories != null &&
                AdditionalTestDirectories.Count > 0;
            }
        }

        public bool UseCompiledTests
        {
            get
            {
                return !string.IsNullOrEmpty(TestDataDirectory)
                    && string.IsNullOrEmpty(TestDirectory);
            }
        }

        private string _workingDirectory;
        public string WorkingDirectory
        {
            get { return _workingDirectory; }
            set { _workingDirectory = value; }
        }

        private string _additionalPath;
        public string AdditionalPath
        {
            get { return _additionalPath; }
            set { _additionalPath = value; }
        }

        public bool HaveAdditionalPath
        {
            get
            {
                return !string.IsNullOrEmpty(_additionalPath) &&
                    Directory.Exists(_additionalPath);
            }
        }
        
        private string _testDirectory;
        public string TestDirectory
        {
            get { return _testDirectory; }
            set { _testDirectory = value; }
        }

        private string _testDataDirectory;
        public string TestDataDirectory
        {
            get { return _testDataDirectory; }
            set { _testDataDirectory = value; }
        }

        private string _managedLibrary;
        public string ManagedLibrary
        {
            get { return _managedLibrary; }
            set { _managedLibrary = value; }
        }

        private List<string> _additionalTestDirectories;
        public List<string> AdditionalTestDirectories
        {
            get { return _additionalTestDirectories; }
            set { _additionalTestDirectories = value; }
        }

        public bool HaveWorkingDirectory
        {
            get
            {
                return !string.IsNullOrEmpty(WorkingDirectory) && Directory.Exists(WorkingDirectory);
            }
        }


        /// <summary>
        /// Ensures that all needed parameters are present.
        /// </summary>
        public bool IsValid
        {
            get
            {
                bool valid = true;
                if (UseCompiledTests)
                {
                    valid &= Directory.Exists(TestDataDirectory);
                }
                else
                {
                    valid &= Directory.Exists(TestDataDirectory) &&
                        Directory.Exists(TestDirectory);

                }

                valid &= !String.IsNullOrEmpty(ManagedLibrary) &&
                    File.Exists(ManagedLibrary);

                if (HaveAdditionalDirectories)
                {
                    foreach (string path in AdditionalTestDirectories)
                    {
                        valid &= Directory.Exists(path);
                    }
                }

                return valid;
            }
        }

        /// <summary>
        /// Return current arguments
        /// </summary>
        /// <returns></returns>
        public override string ToString()
        {
            return string.Format(
                "{0}\tTest Directory        : {1}" +
                "{0}\tTest Data Directory   : {2}" +
                "{0}\tTest Managed Library  : {3}" +
                "{0}\tUse Compiled Tests    : {4}" +
                "{0}\tHave Additional Tests : {5}" +
                "{0}\tIsValid               : {6}",
                Environment.NewLine,
                TestDirectory,
                TestDataDirectory,
                ManagedLibrary,
                UseCompiledTests,
                HaveAdditionalDirectories,
                IsValid
                );
        }

        public string StrippedArgs()
        {
            //-t | --tests <Directory containing generated test files>");
            //-d | --data <Directory containing test-data>");
            //-l | --lib  <Full path to libsbml C# bindings to be used>");
            //-a | --additional-tests  <space separated list of additional directories>");
            //-w | --working-dir   <directory to change into before running tests.>");
            //-p | --path   <directory add to the path.>");
            StringBuilder builder = new StringBuilder();
            for (int i = 0; i < OriginalArgs.Length; i++)
            {
                if (OriginalArgs[i] == "-p" || OriginalArgs[i] == "--path")
                    i = i + 1;
                else
                    builder.AppendFormat("\"{0}\" ", OriginalArgs[i]);
            }
            return builder.ToString();
        }
    }

}

