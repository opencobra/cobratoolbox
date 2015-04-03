/*
 * @file    AutoTestRunner.java
 * @brief   Test Runner for Java test scripts
 * @author  Akiya Jouraku
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
 *----------------------------------------------------------------------- -->*/

import java.io.File;
import java.io.FilenameFilter;
import java.util.regex.Pattern;
import java.util.regex.Matcher;
import java.lang.reflect.*;

import org.sbml.libsbml.test.*;
import org.sbml.libsbml.*;

public class AutoTestRunner
{
  static String pkgNameBase = "org.sbml.libsbml.test";
  static String testDirBase = "test/org/sbml/libsbml/test";
  static String[] testDirs = { "sbml", "xml", "annotation", "math" };
  static String fileRegex   = "Test.*\\.java";
  static String methodRegex = "^test.*";

  static int testNum = 0;
  static int failNum = 0;

  public static File[] getTestFileNames (String dirname)
  {
    File fd = new File(testDirBase + "/" + dirname);
    return fd.listFiles( new TestFilenameFilter(fileRegex) );
  }

  public static void test(String dirname)
  {
    File[] testFiles = getTestFileNames(dirname);
    int filenum = testFiles.length;

    while ( --filenum >= 0 )
    {
      String pkgName = pkgNameBase + "." + dirname;
      String clsName = pkgName + "." + testFiles[filenum].getName().replaceFirst(".java$","");
      Class<?>  cls        = null;
      Object obj = null;
      Method[] listMethods = null;
      Method setup    = null;
      Method teardown = null;

      try {
       cls = Class.forName(clsName);
       obj = cls.newInstance(); 
       listMethods = cls.getDeclaredMethods();
      }
      catch (ClassNotFoundException e)
      {
        e.printStackTrace();
        continue;
      }
      catch ( InstantiationException e)
      {
        e.printStackTrace();
        continue;
      }
      catch ( IllegalAccessException e)
      {
        e.printStackTrace();
        continue;
      }

      try {
        setup = cls.getDeclaredMethod("setUp",(Class[])null);
        setup.setAccessible(true);
      }
      catch ( NoSuchMethodException e) {}

      try {
        teardown = cls.getDeclaredMethod("tearDown",(Class[])null);
        teardown.setAccessible(true);
      }
      catch ( NoSuchMethodException e) {}

      for (int i=0; i < listMethods.length; i++)
      {
        Pattern re_method  = Pattern.compile(methodRegex);
        String method_name = listMethods[i].getName();
        Matcher m = re_method.matcher(method_name);

        if ( m.matches()) {

          ++testNum;

          /**
           *
           * setup()
           *
           */
          try {
            if ( setup != null)
            {
              setup.invoke(obj,(Object[])null); 
            }
          }
          catch ( IllegalAccessException e)
          {
            ++failNum;
            System.err.println("F");
            e.printStackTrace();
            continue;
          } 
          catch ( IllegalArgumentException e)
          {
            ++failNum;
            System.err.println("F");
             e.printStackTrace();
            continue;
          } 
          catch ( InvocationTargetException e)
          {
            ++failNum;
            System.err.println("F");
            e.getCause().printStackTrace();  
            continue;
          } 
          catch ( NullPointerException e)
          {
            ++failNum;
            System.err.println("F");
            e.printStackTrace();  
            continue;
          } 

          /**
           *
           * test*()
           *
           */

          try {
            listMethods[i].invoke(obj,(Object[])null);
            System.err.print(".");
          }
          catch ( IllegalAccessException e)
          {
            ++failNum;
            System.err.println("F");
            e.printStackTrace();
          }
          catch ( IllegalArgumentException e)
          {
            ++failNum;
            System.err.println("F");
            e.printStackTrace();
          }
          catch ( InvocationTargetException e)
          {
            ++failNum;
            System.err.println("F");
            e.getCause().printStackTrace();
          }
          catch ( NullPointerException e)
          {
            ++failNum;
            System.err.println("F");
            e.printStackTrace();
          }
  
          /**
           *
           * tearDown()
           *
           */
           try{
             if ( teardown != null)
             {
               teardown.invoke(obj,(Object[])null); 
             }
           }
           catch ( IllegalAccessException e)
           {
             ++failNum;
             e.printStackTrace();
           }
           catch ( IllegalArgumentException e)
           {
             ++failNum;
             e.printStackTrace();
           }
           catch ( InvocationTargetException e)
           {
             ++failNum;
             e.getCause().printStackTrace();
           }
           catch ( NullPointerException e)
           {
             ++failNum;
             e.printStackTrace();
           }
        }
      }
    }

  }

  public static void main (String argv[])
  {
    for (int i=0; i < testDirs.length; i++ )
    {
      test(testDirs[i]);
    }

    System.err.println("\n" + testNum + " tests, " + failNum + " failures ");
    if ( failNum == 0 )
    {
      System.err.println("All tests passed");
      System.exit(0);
    }
    else
    {
      System.exit(1);
    }
  }

}

class TestFilenameFilter implements FilenameFilter
{
  String fileRegex = null;
  
  TestFilenameFilter(String re)
  {
    fileRegex = re;
  }

  public boolean accept(File dir, String name) 
  {
    Pattern re_tfile = Pattern.compile(fileRegex);
    Matcher m = re_tfile.matcher(name);
    if ( m.matches()) {
      return true;
    }
    return false;
  }
}


