/**
 * @file    SBMLDoclet.java
 * @brief   Exclude files, allow tag "@internal", and more.
 * @author  Michael Hucka
 * 
 * <!-- -----------------------------------------------------------------------
 * Portions of this code are under the following copyright terms:
 *
 * Copyright 2004 Sun Microsystems, Inc. All Rights Reserved.
 * 
 * Redistribution and use in source and binary forms, with or without 
 * modification, are permitted provided that the following conditions are met:
 * 
 *  - Redistribution of source code must retain the above copyright notice, 
 *    this list of conditions and the following disclaimer.
 *
 *  - Redistribution in binary form must reproduce the above copyright notice, 
 *    this list of conditions and the following disclaimer in the documentation 
 *    and/or other materials provided with the distribution.
 *
 * Neither the name of Sun Microsystems, Inc. nor the names of contributors may be 
 * used to endorse or promote products derived from this software without specific 
 * prior written permission.
 *  
 * This software is provided "AS IS," without a warranty of any kind. ALL EXPRESS 
 * OR IMPLIED CONDITIONS, REPRESENTATIONS AND WARRANTIES, INCLUDING ANY IMPLIED 
 * WARRANTY OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE OR NON-INFRINGEMENT, 
 * ARE HEREBY EXCLUDED. SUN MICROSYSTEMS, INC. ("SUN") AND ITS LICENSORS SHALL NOT 
 * BE LIABLE FOR ANY DAMAGES SUFFERED BY LICENSEE AS A RESULT OF USING, MODIFYING 
 * OR DISTRIBUTING THIS SOFTWARE OR ITS DERIVATIVES. IN NO EVENT WILL SUN OR ITS 
 * LICENSORS BE LIABLE FOR ANY LOST REVENUE, PROFIT OR DATA, OR FOR DIRECT, INDIRECT, 
 * SPECIAL, CONSEQUENTIAL, INCIDENTAL OR PUNITIVE DAMAGES, HOWEVER CAUSED AND 
 * REGARDLESS OF THE THEORY OF LIABILITY, ARISING OUT OF THE USE OF OR INABILITY 
 * TO USE THIS SOFTWARE, EVEN IF SUN HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH 
 * DAMAGES.
 *  
 * You acknowledge that this software is not designed, licensed or intended for 
 * use in the design, construction, operation or maintenance of any nuclear facility. 
 *
 * ------------------------------------------------------------------------ -->
 *
 * Portions of this code was originally obtained on 24 Feb. 2008 from
 * http://java.sun.com/developer/JDCTechTips/2004/tt1214.html
 * Author: Jamie Ho, Sun Microsystems, Inc.
 *
 * The following documentation was copied from that page.
 *
 * java -classpath <path to doclet and path to tools.jar>
 *     ExcludeDoclet  -excludefile <path to exclude file>  <javadoc options>
 *
 * In response to the command, the validOptions method of the Doclet class
 * looks for the -excludefile option. If it finds it, the method reads the
 * contents of the exclude file -- these are the set of classes and
 * packages to ignore. Then the start method is called. As each class or
 * package is processed, the method throws away the classes and packages in
 * the exclude set. The doclet includes the optionLength method, this
 * allows the doclet to run under both J2SE 1.4 and 5.0.
 *
 * Compile the doclet as follows:
 *
 *   javac -classpath tools.jar ExcludeDoclet.java
 *
 * Replace tools.jar with the appropriate location of your JDK
 * installation. For example, if you're running in the Windows environment
 * and your JDK is installed in the c:\jdk1.5.0 directory, specify
 * c:\jdk1.5.0\lib\tools.jar.
 *
 * Next, create a file such as skip.txt to identify which classes to
 * skip. For this example, run ExcludeDoclet with the standard JDK
 * classes, and ignore a set in the java.lang package:
 *
 *    java.lang.Math
 *    java.lang.Long
 *    java.lang.InternalError 
 *    java.lang.InterruptedException 
 *    java.lang.Iterable 
 *    java.lang.LinkageError
 *
 * Then run the following command (on one line):
 *
 * java -classpath .;c:\jdk1.5.0\lib\tools.jar ExcludeDoclet 
 *    -d docs -excludefile skip.txt -sourcepath c:\jdk1.5.0\src 
 *    -source 1.5 java.lang
 *
 * The command will generate the javadoc for the java.lang package,
 * excluding the six classes and interfaces identified in skip.txt.
 *
 * ----------------------------------------------------------------------------
 * Additional notes (M. Hucka):
 * - "tools.jar" is called "classes.jar" on MacOS and it's located in
 *   /System/Library/Frameworks/JavaVM.framework/Classes/classes.jar
 *   See http://lists.apple.com/archives/java-dev/2002/Jun/msg00901.html
 *
 * - 2008-02-25 I made a small tweak to the diagnostic msgs printed by start()
 *
 * - 2011-11-03 I added the @exclude tag processing code written by
 * Chris Nokleberg and made available from the following URL:
 * http://www.sixlegs.com/blog/java/exclude-javadoc-tag.html The page was
 * dated 22 Feb 2005.  The page stated that the code is in the public
 * domain.  The file was originally also named ExcludeDoclet.java.  What I
 * did is take the code and make it a subclass within this file, and took
 * the bulk of the previous doclet code and put it in *another* subclass in
 * this file, then hooked them together through the main() method.
 *
 * - 2011-11-08 Changed @exclude to @internal, which is what Doxygen uses
 * for the purse we're using this for.
 */

import java.io.*;
import java.util.*;
import java.lang.reflect.*;
import com.sun.tools.doclets.standard.Standard;
import com.sun.tools.javadoc.Main;
import com.sun.javadoc.*;


/**
 * A wrapper for Javadoc.  Accepts additional options:
 *
 * * "-excludefile": specifies which classes and packages should be excluded
 *   from the output.
 *
 * * "-listskipped": print things that get skipped because they are SWIG
 *   things we don't want in the documentation.
 *
 * @author Jamie Ho
 * @author Michael Hucka
 */
public class SBMLDoclet extends Doclet
{
    private static List m_args = new ArrayList();
    private static Set m_excludeSet = new HashSet();
    static boolean m_list_skipped = false;

    /**
     * First executes the doclet that exclude files.
     * Then it executes the doclet that processes the classes and excludes
     * things marked with @exclude.
     *
     * @param args  the Javadoc arguments from the command line
     */
    public static void main(String[] args)
    {
        String name;

        name = FileExclusionDoclet.class.getName();
        Main.execute(name, name, args);

        name = SBMLProcessingDoclet.class.getName();
        Main.execute(name, name, (String[]) m_args.toArray(new String[] {}));
    }

    /* --------------------------------------------------------------------- */

    /**
     * File exclusion handler class.
     *
     * This code was originally taken from:
     * @(#)SBMLDoclet.java	1.1 04/08/31
     * http://java.sun.com/developer/JDCTechTips/2004/tt1214.html
     */
    public static class FileExclusionDoclet
        extends Doclet
    {
        /**
         * Iterate through the documented classes and remove the ones that should
         * be excluded.
         * 
         * @param root the initial RootDoc (before filtering).
         */
        public static boolean start(RootDoc root)
        {
            root.printNotice("SBMLDoclet removing excluded source files...");
            ClassDoc[] classes = root.classes();
            for (int i = 0; i < classes.length; i++) {
                if (m_excludeSet.contains(classes[i].qualifiedName()) ||
                    m_excludeSet.contains(classes[i].containingPackage().name())) {
                    root.printNotice("Excluding " + classes[i].qualifiedName());
                    continue;
                }
                m_args.add(classes[i].position().file().getPath());   
            }
            return true;
        }

        /**
         * Let every option be valid.  The real validation happens in the
         * standard doclet, not here.  Remove the "-excludefile" and
         * "-subpackages" options because they are not needed by the standard
         * doclet.  Similarly, process SBMLDoclet's -listexcludes flag here
         * and also remove it.
         * 
         * @param options   the options from the command line
         * @param reporter  the error reporter
         */
        public static boolean validOptions(String[][] options,
                                           DocErrorReporter reporter)
        {
            for (int i = 0; i < options.length; i++) {
                if (options[i][0].equalsIgnoreCase("-excludefile")) {
                    try {
                        readExcludeFile(options[i][1]);
                    } catch (Exception e) {
                        e.printStackTrace();
                    }
                    continue;
                }
                if (options[i][0].equals("-subpackages")) {
                    continue;
                }
                if (options[i][0].equals("-listskipped")) {
                    m_list_skipped = true;
                    continue;
                }
                for (int j = 0; j < options[i].length; j++) {
                    m_args.add(options[i][j]);
                }
            }
            return true;
        }

        /**
         * Parse the file that specifies which classes and packages to exclude from
         * the output. You can write comments in this file by starting the line with
         * a '#' character.
         * 
         * @param filePath the path to the exclude file.
         */
        private static void readExcludeFile(String filePath)
            throws Exception
        {
            LineNumberReader reader = new LineNumberReader(new FileReader(filePath));
            String line;
            while ((line = reader.readLine()) != null) {
                if (line.trim().startsWith("#"))
                    continue;
                m_excludeSet.add(line.trim());
            }
        }

        /**
         * Method required to validate the length of the given option.  This is a
         * bit ugly but the options must be hard coded here.  Otherwise, Javadoc
         * will throw errors when parsing options.  We could delegate to the 
         * Standard doclet when computing option lengths, but then this doclet would
         * be dependent on the version of J2SE used.  Prefer to hard code options
         * here so that this doclet can be used with 1.4.x or 1.5.x .
         * 
         * @param option  the option to compute the length for
         */
        public static int optionLength(String option)
        {
            if (option.equalsIgnoreCase("-excludefile")) {
                return 2;   
            }

            //General options
            if (option.equals("-author") ||
                option.equals("-docfilessubdirs") ||
                option.equals("-keywords") ||
                option.equals("-linksource") ||
                option.equals("-nocomment") ||
                option.equals("-nodeprecated") ||
                option.equals("-nosince") ||
                option.equals("-notimestamp") ||
                option.equals("-quiet") ||
                option.equals("-xnodate") ||
                option.equals("-version")) {
                return 1;
            } else if (option.equals("-d") ||
                       option.equals("-docencoding") ||
                       option.equals("-encoding") ||
                       option.equals("-excludedocfilessubdir") ||
                       option.equals("-link") ||
                       option.equals("-sourcetab") ||
                       option.equals("-noqualifier") ||
                       option.equals("-output") ||
                       option.equals("-sourcepath") ||
                       option.equals("-tag") ||
                       option.equals("-taglet") ||
                       option.equals("-tagletpath")) {
                return 2;
            } else if (option.equals("-group") ||
                       option.equals("-linkoffline")) {
                return 3;
            }

            //Standard doclet options
            option = option.toLowerCase();
            if (option.equals("-nodeprecatedlist") ||
                option.equals("-noindex") ||
                option.equals("-notree") ||
                option.equals("-nohelp") ||
                option.equals("-splitindex") ||
                option.equals("-serialwarn") ||
                option.equals("-use") ||
                option.equals("-nonavbar") ||
                option.equals("-nooverview")) {
                return 1;
            } else if (option.equals("-footer") ||
                       option.equals("-header") ||
                       option.equals("-packagesheader") ||
                       option.equals("-doctitle") ||
                       option.equals("-windowtitle") ||
                       option.equals("-bottom") ||
                       option.equals("-helpfile") ||
                       option.equals("-stylesheetfile") ||
                       option.equals("-charset") ||
                       option.equals("-overview")) {
                return 2;
            } else {
                return 0;
            }
        }
    }

    /* --------------------------------------------------------------------- */

    /**
     * Our own processing doclet.
     *
     * The code to handle @internal was originally taken from:
     * http://www.sixlegs.com/blog/java/exclude-javadoc-tag.html
     * Author:  Chris Nokleberg.
     * It looks for @internal in documentation strings and excludes the
     * method or class marked by it.
     *
     * This has added code to substitute a documentation string for
     * delete().  I have not been able to find a way to do otherwise.  SWIG
     * will simply not let me attach doc strings to delete() at all, so I
     * have to do it outside.  Grafting the code here was the best
     * solution, though this code could stand to be reorganized and
     * modularized better.
     */

    public static class SBMLProcessingDoclet
        extends Doclet
    {
        private static RootDoc the_root;

        public static boolean validOptions(String[][] options,
                                           DocErrorReporter reporter)
        {
            return Standard.validOptions(options, reporter);
        }

        public static int optionLength(String option)
        {
            return Standard.optionLength(option);
        }

        public static boolean start(RootDoc root)
        {
            the_root = root;
            return Standard.start((RootDoc) process(root, RootDoc.class));
        }

        private static boolean markedInternal(Doc doc)
        {
            if (doc instanceof ProgramElementDoc)
            {
                ProgramElementDoc pdoc = (ProgramElementDoc) doc;
                if (pdoc.containingPackage().tags("internal").length > 0)
                    return true;
            }
            return doc.tags("internal").length > 0;
        }

        private static boolean isSWIGWrapper(Doc doc)
        {
            if (doc instanceof ProgramElementDoc)
            {
                ProgramElementDoc pdoc = (ProgramElementDoc) doc;
                if (pdoc.containingPackage().name().startsWith("SWIGTYPE_p"))
                    return true;
            }
            return doc.name().startsWith("SWIGTYPE_p");
        }

        private static boolean isJNIclass(Doc doc)
        {
            if (doc instanceof ProgramElementDoc)
            {
                ProgramElementDoc pdoc = (ProgramElementDoc) doc;
                if (pdoc.containingPackage().name().startsWith("libsbmlJNI"))
                    return true;
            }
            return doc.name().startsWith("libsbmlJNI");
        }

        private static boolean isDeleteMethod(Doc doc)
        {
            if (doc instanceof ProgramElementDoc)
            {
                ProgramElementDoc pdoc = (ProgramElementDoc) doc;
                if (pdoc.qualifiedName().endsWith("delete"))
                    return true;
            }
            return (doc.isMethod() && doc.name().equals("delete"));
        }

        private static Object process(Object obj, Class expect)
        {
            if (obj == null)
                return null;
            Class cls = obj.getClass();
            if (cls.getName().startsWith("com.sun."))
            {
                return Proxy.newProxyInstance(cls.getClassLoader(),
                                              cls.getInterfaces(),
                                              new InternalTagHandler(obj));
            }
            else if (obj instanceof Object[])
            {
                Class componentType = expect.getComponentType();
                Object[] array = (Object[])obj;
                List list = new ArrayList(array.length);
                for (int i = 0; i < array.length; i++)
                {
                    Object entry = array[i];
                    if (entry instanceof Doc)
                    {
                        Doc item = (Doc) entry;

                        if (markedInternal(item))
                            continue;

                        if (isSWIGWrapper(item) || isJNIclass(item))
                        {
                            if (m_list_skipped)
                            {
                                the_root.printNotice("SBMLDoclet: skipping "
                                                     + item);
                            }
                            continue;
                        }

                        if (isDeleteMethod(item))
                        {
                            item.setRawCommentText(
                                 "Explicitly deletes the underlying native object." +
                                 "<p>" +
                                 "In general, application software will not need to call this method " +
                                 "directly.  The Java language binding for libSBML is implemented as a " +
                                 "language wrapper that provides a Java interface to libSBML's " +
                                 "underlying C++/C code.  Some of the Java methods return objects that " +
                                 "are linked to objects created not by Java code, but by C++ code.  The " +
                                 "Java objects wrapped around them will be deleted when the garbage " +
                                 "collector invokes the corresponding C++ <code>finalize()</code> methods for the " +
                                 "objects.  The <code>finalize()</code> methods in turn call " +
                                 "the {@link #delete()} method on the libSBML object. " +
                                 "<p>" +
                                 "This method is exposed in case calling programs want to ensure that " +
                                 "the underlying object is freed immediately, and not at some arbitrary " +
                                 "time determined by the Java garbage collector.  In normal usage, " +
                                 "callers do not need to invoke {@link #delete()} themselves.");
                        }
                    }
                    list.add(process(entry, componentType));
                }
                return list.toArray((Object[])Array.newInstance(componentType, list.size()));
            }
            else
            {
                return obj;
            }
        }

        private static class InternalTagHandler
            implements InvocationHandler
        {
            private Object target;

            public InternalTagHandler(Object target)
            {
                this.target = target;
            }

            public Object invoke(Object proxy, Method method, Object[] args)
                throws Throwable
            {
                if (args != null)
                {
                    String mName = method.getName();
                    if (mName.equals("compareTo") || mName.equals("equals") ||
                        mName.equals("overrides") || mName.equals("subclassOf"))
                    {
                        args[0] = unwrap(args[0]);
                    }
                }
                try
                {
                    return process(method.invoke(target, args), method.getReturnType());
                }
                catch (InvocationTargetException e)
                {
                    throw e.getTargetException();
                }
            }

            private Object unwrap(Object proxy)
            {
                if (proxy instanceof Proxy)
                    return ((InternalTagHandler) Proxy.getInvocationHandler(proxy)).target;
                return proxy;
            }
        }
    }

}
