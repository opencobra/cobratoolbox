/**
 * @file    evaluateMath.java
 * @brief   Evaluates and outputs infix expressions
 * @author  Nicolas Rodriguez (translated from the libSBML C example)
 * @author  Rainer Machne (author of original libSBML C example)
 * @author  Michael Hucka
 *
 * <!--------------------------------------------------------------------------
 * This sample program is distributed under a different license than the rest
 * of libSBML.  This program uses the open-source MIT license, as follows:
 *
 * Copyright (c) 2013-2014 by the California Institute of Technology
 * (California, USA), the European Bioinformatics Institute (EMBL-EBI, UK)
 * and the University of Heidelberg (Germany), with support from the National
 * Institutes of Health (USA) under grant R01GM070923.  All rights reserved.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
 * THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 * DEALINGS IN THE SOFTWARE.
 *
 * Neither the name of the California Institute of Technology (Caltech), nor
 * of the European Bioinformatics Institute (EMBL-EBI), nor of the University
 * of Heidelberg, nor the names of any contributors, may be used to endorse
 * or promote products derived from this software without specific prior
 * written permission.
 * ------------------------------------------------------------------------ -->
 */

import java.io.IOException;

import org.sbml.libsbml.ASTNode;
import org.sbml.libsbml.libsbml;
import org.sbml.libsbml.libsbmlConstants;


/**
 * This program asks the user to enter an infix formula, translates it to
 * an Abstract Syntax tree using the function:
 *
 *   ASTNode libsbml.parseFormula(String)
 *
 * evaluates the formula and returns the result.  See comments for double
 * evalAST(ASTNode n) for further information.
 */
public class evaluateMath
{
  public static void main (String[] args)
  {
    println( "This program evaluates infix formulas." );
    println( "Typing return triggers evaluation." );
    println( "\n" );


    long start, stop, size;

    int  i = 0;
    char c;

    String  mathStr = new String();
    ASTNode nodes;

    try
    {
      // Hit Enter to quit the loop
      while (i != 10)
      {
        // Read a character from keyboard
        i  = System.in.read();
        // 1 byte character is returned in int.
        // So cast to char
        c = (char) i;
        mathStr += c;
      }
    }
    catch (IOException ioe)
    {
      println( "IO error:" + ioe );
    }

    nodes = libsbml.parseFormula(mathStr);

    start = System.currentTimeMillis();
    double result = evalAST(nodes);
    stop  = System.currentTimeMillis();


    println("\n" + libsbml.formulaToString(nodes) + "\n= " + result + "\n");
    println("evaluation time: " + (stop - start) + " ms\n\n");
  }


  /**
   * The function evalAST(ASTNode) evaluates the formula of an Abstract
   * Syntax Tree by simple recursion and returns the result as a double
   * value.
   *
   * If variables (ASTNodeType_t AST_NAME) occur in the formula the user is
   * asked to provide a numerical value.  When evaluating ASTs within an
   * SBML document or simulating an SBML model this node type includes
   * parameters and variables of the model.  Parameters should be retrieved
   * from the SBML file, time and variables from current values of the
   * simulation.
   *
   * Not implemented:
   *
   *   - PIECEWISE, LAMBDA, and the SBML model specific functions DELAY and
   *     TIME and user-defined functions.
   *
   *   - Complex numbers and/or checking for domains of trigonometric and
   *     root functions.
   *
   *   - Checking for precision and rounding errors.
   *
   * The Nodetypes AST_TIME, AST_DELAY and AST_PIECEWISE default to 0.  The
   * SBML DELAY function and unknown functions (SBML user-defined
   * functions) use the value of the left child (first argument to
   * function) or 0 if the node has no children.
   */
  private static double evalAST (ASTNode n)
  {
    int    i;
    double result = 0;
    int    astNodeType;

    String msg;

    int       childnum = (int) n.getNumChildren();
    ASTNode[] child    = new ASTNode[childnum];


    for(i = 0; i < childnum; i++)
    {
      child[i] = n.getChild(i);
    }

    astNodeType = n.getType();

    switch (astNodeType)
    {
      case libsbmlConstants.AST_INTEGER: 
        result = (double) n.getInteger();
        break;

      case libsbmlConstants.AST_REAL:
        result = n.getReal();
        break;

      case libsbmlConstants.AST_REAL_E:
        result = n.getReal();
        break;

      case libsbmlConstants.AST_RATIONAL:
        result = n.getReal();
        break;


      case libsbmlConstants.AST_NAME:
        msg =
          "\n--------- MESSAGE FROM EVALUATION FUNCTION ----------\n\n" +
          "Please enter a number for the variable!\n" +
          "If you do not enter a valid number (empty or characters), the \n" +
          "evaluation will proceed with a current internal value and the \n" +
          "result will make no sense.\n" +
          n.getName() + " = ";

        println(msg);
        
        String l = new String();
        double var;

        try
        {
          int input = 0;
          while (input != 10)
          {
            // Read a character from keyboard
            input  = System.in.read();
            // 1 byte character is returned in int.
            // So cast to char
            l += (char) input;
          }

          var = Double.valueOf(l).doubleValue();
          println(n.getName() + " = " + var + "\n");
          result = var;
        }
        catch (IOException e)
        {
        }

        println("\n--------- END MESSAGE ----------\n\n");
        break;


      case libsbmlConstants.AST_FUNCTION_DELAY:
        msg =
          "\n--------- MESSAGE FROM EVALUATION FUNCTION ----------\n\n"      +
          "Delays can only be evaluated during a time series simulation.\n"  +
          "The value of the first child (ie. the first argument to the"      +
          "function)\nis used for this evaluation. If the function node has" +
          "no children the\nvalue defaults to 0.\n" +
          "\n--------- END MESSAGE ----------\n\n";

        println(msg);

        if (i > 0)
        {
          result = evalAST(child[0]);
        }
        else
        {
          result = 0.0;
        }
        break;

      case libsbmlConstants.AST_NAME_TIME:
        msg =
          "\n--------- MESSAGE FROM EVALUATION FUNCTION ----------\n\n"       +
          "The time can only be evaluated during a time series simulation.\n" +
          "The value of defaults to 0\n" +
          "\n--------- END MESSAGE ----------\n\n";
        println(msg);

        result = 0.0;
        break;


      case libsbmlConstants.AST_CONSTANT_E:
        /* exp(1) is used to adjust exponentiale to machine precision */
        result = Math.exp(1);
        break;

      case libsbmlConstants.AST_CONSTANT_FALSE:
        result = 0.0;
        break;

      case libsbmlConstants.AST_CONSTANT_PI:
        /* pi = 4 * atan 1  is used to adjust Pi to machine precision */
        result = 4 * Math.atan(1.);
        break;

      case libsbmlConstants.AST_CONSTANT_TRUE:
        result = 1.0;
        break;

      case libsbmlConstants.AST_PLUS:
        result = evalAST(child[0]) + evalAST(child[1]);
        break;


      case libsbmlConstants.AST_MINUS:
        if (childnum == 1)
        {
          result = - (evalAST(child[0]));
        }
        else
        {
          result = evalAST(child[0]) - evalAST(child[1]);
        }
        break;


      case libsbmlConstants.AST_TIMES:
        result = evalAST(child[0]) * evalAST(child[1]) ;
        break;

      case libsbmlConstants.AST_DIVIDE:
        result = evalAST(child[0]) / evalAST(child[1]);
        break;

      case libsbmlConstants.AST_POWER:
        result = Math.pow(evalAST(child[0]),evalAST(child[1]));
        break;

      case libsbmlConstants.AST_LAMBDA:
        msg =
          "\n--------- MESSAGE FROM EVALUATION FUNCTION ----------\n\n" +
          "This function is not implemented yet.\n"                     +
          "The value defaults to 0.\n"                                  +
          "\n--------- END MESSAGE ----------\n\n";
        println(msg);

        result = 0.0;
        break;

      case libsbmlConstants.AST_FUNCTION:
        msg =
          "\n--------- MESSAGE FROM EVALUATION FUNCTION ----------\n\n"        +
          "This function is not known.\n"                                      +
          "Within an SBML document new functions can be defined by the user\n" +
          "or application. The value of the first child (ie. the first\n"      +
          "argument to the function) is used for this evaluation. If the\n"    +
          "function node has no children the value defaults to 0.\n"           +
          "\n--------- END MESSAGE ----------\n\n";
        println(msg);

        if (childnum > 0)
        {
          result = evalAST(child[0]);
        }
        else
        {
          result = 0.0;
        }
        break;

        case libsbmlConstants.AST_FUNCTION_ABS:
          result = Math.abs(evalAST(child[0]));
          break;

        case libsbmlConstants.AST_FUNCTION_ARCCOS:
          result = Math.acos(evalAST(child[0]));
          break;

        case libsbmlConstants.AST_FUNCTION_ARCCOSH:
          result = Math.acos(evalAST(child[0])); // TODO : fix to have acosh
          break;

        case libsbmlConstants.AST_FUNCTION_ARCCOT:
          /* arccot x =  arctan (1 / x) */
          result = Math.atan(1. / evalAST(child[0]));
          break;

        case libsbmlConstants.AST_FUNCTION_ARCCOTH:
          /* arccoth x = 1/2 * ln((x+1)/(x-1)) */
          result = ((1. / 2.) *
                    Math.log((evalAST(child[0]) + 1.) /
                             (evalAST(child[0]) - 1.) ));
          break;

        case libsbmlConstants.AST_FUNCTION_ARCCSC:
          /* arccsc(x) = Arctan(1 / sqrt((x - 1)(x + 1))) */
          result = Math.atan(1. / Math.sqrt((evalAST(child[0]) - 1.) *
                                            (evalAST(child[0]) + 1.) ));
          break;

        case libsbmlConstants.AST_FUNCTION_ARCCSCH:
          /* arccsch(x) = ln((1 + sqrt(1 + x^2)) / x) */
          result = Math.log((1. +
                             Math.pow(1 + Math.pow(evalAST(child[0]), 2), 2))
                            / evalAST(child[0]));
          break;

      case libsbmlConstants.AST_FUNCTION_ARCSEC:
        /* arcsec(x) = arctan(sqrt((x - 1)(x + 1))) */
        result = Math.atan(Math.sqrt((evalAST(child[0]) - 1.) *
                                     (evalAST(child[0]) + 1.) ));
        break;

      case libsbmlConstants.AST_FUNCTION_ARCSECH:
        /* arcsech(x) = ln((1 + sqrt(1 - x^2)) / x) */
        result = Math.log((1. + Math.pow(1 -
                                         Math.pow(evalAST(child[0]), 2), 0.5))
                          / evalAST(child[0]));
        break;

      case libsbmlConstants.AST_FUNCTION_ARCSIN:
        result = Math.asin(evalAST(child[0]));
        break;

      case libsbmlConstants.AST_FUNCTION_ARCSINH:
        result = Math.asin(evalAST(child[0])); // TODO : fix to have asinh
        break;

      case libsbmlConstants.AST_FUNCTION_ARCTAN:
        result = Math.atan(evalAST(child[0]));
        break;

      case libsbmlConstants.AST_FUNCTION_ARCTANH:
        result = Math.atan(evalAST(child[0])); // TODO : fix to have atanh
        break;

      case libsbmlConstants.AST_FUNCTION_CEILING:
        result = Math.ceil(evalAST(child[0]));
        break;

      case libsbmlConstants.AST_FUNCTION_COS:
        result = Math.cos(evalAST(child[0]));
        break;

      case libsbmlConstants.AST_FUNCTION_COSH:
        result = Math.cosh(evalAST(child[0]));
        break;

      case libsbmlConstants.AST_FUNCTION_COT:
        /* cot x = 1 / tan x */
        result = 1. / Math.tan(evalAST(child[0]));
        break;

      case libsbmlConstants.AST_FUNCTION_COTH:
        /* coth x = cosh x / sinh x */
        result = Math.cosh(evalAST(child[0])) / Math.sinh(evalAST(child[0]));
        break;

      case libsbmlConstants.AST_FUNCTION_CSC:
        /* csc x = 1 / sin x */
        result = (1. / Math.sin(evalAST(child[0])));
        break;

      case libsbmlConstants.AST_FUNCTION_CSCH:
        /* csch x = 1 / cosh x  */
        result = (1. / Math.cosh(evalAST(child[0])));
        break;

      case libsbmlConstants.AST_FUNCTION_EXP:
        result = Math.exp(evalAST(child[0]));
        break;

      case libsbmlConstants.AST_FUNCTION_FACTORIAL:
        msg =
          "\n--------- MESSAGE FROM EVALUATION FUNCTION ----------\n\n"    +
          "The factorial is only implemented for integer values. If a\n"   +
          "floating point number is passed, the floor value is used for\n" +
          "calculation!\n" +
          "\n--------- END MESSAGE ----------\n\n";
        println(msg);

        double dbl = Math.floor(evalAST(child[0]));
        for(result = 1; dbl > 1; --dbl)
        {
          result *= i;
        }
        break;

      case libsbmlConstants.AST_FUNCTION_FLOOR:
        result = Math.floor(evalAST(child[0]));
        break;

      case libsbmlConstants.AST_FUNCTION_LN:
        result = Math.log(evalAST(child[0]));
        break;

      case libsbmlConstants.AST_FUNCTION_LOG:
        result = Math.log10(evalAST(child[0]));
        break;

      case libsbmlConstants.AST_FUNCTION_PIECEWISE:
        msg =
          "\n--------- MESSAGE FROM EVALUATION FUNCTION ----------\n\n" +
          "This function is not implemented yet.\n" +
          "The value defaults to 0.\n"              +
          "\n--------- END MESSAGE ----------\n\n";
        println(msg);

        result = 0.0;
        break;

      case libsbmlConstants.AST_FUNCTION_POWER:
        result = Math.pow(evalAST(child[0]), evalAST(child[1]));
        break;

      case libsbmlConstants.AST_FUNCTION_ROOT:
        result = Math.pow(evalAST(child[1]), 1. / evalAST(child[0]));
        break;

      case libsbmlConstants.AST_FUNCTION_SEC:
        /* sec x = 1 / cos x */
        result = 1. / Math.cos(evalAST(child[0]));
        break;

      case libsbmlConstants.AST_FUNCTION_SECH:
        /* sech x = 1 / sinh x */
        result = 1. / Math.sinh(evalAST(child[0]));
        break;

      case libsbmlConstants.AST_FUNCTION_SIN:
        result = Math.sin(evalAST(child[0]));
        break;

      case libsbmlConstants.AST_FUNCTION_SINH:
        result = Math.sinh(evalAST(child[0]));
        break;

      case libsbmlConstants.AST_FUNCTION_TAN:
        result = Math.tan(evalAST(child[0]));
        break;

      case libsbmlConstants.AST_FUNCTION_TANH:
        result = Math.tanh(evalAST(child[0]));
        break;
/*
      case libsbmlConstants.AST_LOGICAL_AND:
        result = (double) (evalAST(child[0]) & evalAST(child[1]));
        break;

      case libsbmlConstants.AST_LOGICAL_NOT:
        result = (double) (!(evalAST(child[0])));
        break;

      case libsbmlConstants.AST_LOGICAL_OR:
        result = (double) ((evalAST(child[0])) || (evalAST(child[1])));
        break;

      case libsbmlConstants.AST_LOGICAL_XOR:
        result = (double) ((!(evalAST(child[0])) && (evalAST(child[1])))
                           || ((evalAST(child[0])) &&  !(evalAST(child[1]))));
        break;

      case libsbmlConstants.AST_RELATIONAL_EQ:
        result = (double) ((evalAST(child[0])) == (evalAST(child[1])));
        break;

      case libsbmlConstants.AST_RELATIONAL_GEQ:
        result = (double) ((evalAST(child[0])) >= (evalAST(child[1])));
        break;

      case libsbmlConstants.AST_RELATIONAL_GT:
        result = (double) ((evalAST(child[0])) > (evalAST(child[1])));
        break;

      case libsbmlConstants.AST_RELATIONAL_LEQ:
        result = (double) ((evalAST(child[0])) <= (evalAST(child[1])));
        break;

      case libsbmlConstants.AST_RELATIONAL_LT:
        result = (double) ((evalAST(child[0])) < (evalAST(child[1])));
        break;
*/
      default:
        result = 0;
        break;
    }

    return result;
  }
    

  static void println (String msg)
  {
    System.out.println(msg);
  }


  /**
   * Loads the SWIG-generated libSBML Java module when this class is
   * loaded, or reports a sensible diagnostic message about why it failed.
   */
  static
  {
    try
    {
      System.loadLibrary("sbmlj");
      // For extra safety, check that the jar file is in the classpath.
      Class.forName("org.sbml.libsbml.libsbml");
    }
    catch (UnsatisfiedLinkError e)
    {
      System.err.println("Error encountered while attempting to load libSBML:");
      System.err.println("Please check the value of your "
                         + (System.getProperty("os.name").startsWith("Mac OS")
                            ? "DYLD_LIBRARY_PATH" : "LD_LIBRARY_PATH") +
                         " environment variable and/or your" +
                         " 'java.library.path' system property (depending on" +
                         " which one you are using) to make sure it list the" +
                         " directories needed to find the " +
                         System.mapLibraryName("sbmlj") + " library file and" +
                         " libraries it depends upon (e.g., the XML parser).");
      System.exit(1);
    }
    catch (ClassNotFoundException e)
    {
      System.err.println("Error: unable to load the file 'libsbmlj.jar'." +
                         " It is likely that your -classpath command line " +
                         " setting or your CLASSPATH environment variable " +
                         " do not include the file 'libsbmlj.jar'.");
      e.printStackTrace();

      System.exit(1);
    }
    catch (SecurityException e)
    {
      System.err.println("Error encountered while attempting to load libSBML:");
      e.printStackTrace();
      System.err.println("Could not load the libSBML library files due to a"+
                         " security exception.\n");
      System.exit(1);
    }
  }
}
