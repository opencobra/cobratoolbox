/**
 * @file    appendAnnotation.java
 * @brief   Adds annotation to a model and a species
 * @author  Akira Funahashi (translated from libSBML C++ examples (using other Java examples provided by Nicolas Rodriguez))
 * @author  Akiya Jouraku
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


import org.sbml.libsbml.libsbmlConstants;
import org.sbml.libsbml.CVTerm;
import org.sbml.libsbml.Date;
import org.sbml.libsbml.ModelCreator;
import org.sbml.libsbml.ModelHistory;
import org.sbml.libsbml.SBMLWriter;
import org.sbml.libsbml.Species;
import org.sbml.libsbml.SBMLDocument;
import org.sbml.libsbml.SBMLReader;
 

public class appendAnnotation
{
  public static void main (String[] args)
  {        
    if (args.length != 2)
    {
      println("\n  usage: java appendAnnotation <input-filename> <output-filename>\n");
      System.exit(2);
    }

    SBMLDocument d;
    SBMLReader reader     = new SBMLReader();
    SBMLWriter writer     = new SBMLWriter();

    d = reader.readSBML(args[0]);

    long errors = d.getNumErrors();

    if (errors > 0)
    {
      println("Read Error(s):");
      d.printErrors();
      println("Correct the above and re-run.");
    }
    else
    {
        String model_history_annotation = 
           "<annotation>\n" +
           "  <rdf:RDF xmlns:rdf=\"http://www.w3.org/1999/02/22-rdf-syntax-ns#\" xmlns:dc=\"http://purl.org/dc/elements/1.1/\" xmlns:dcterms=\"http://purl.org/dc/terms/\" xmlns:vCard=\"http://www.w3.org/2001/vcard-rdf/3.0#\" xmlns:bqbiol=\"http://biomodels.net/biology-qualifiers/\" xmlns:bqmodel=\"http://biomodels.net/model-qualifiers/\">\n" +
           "    <rdf:Description rdf:about=\"#\">\n" +
           "      <dc:creator rdf:parseType=\"Resource\">\n" +
           "        <rdf:Bag>\n" +
           "          <rdf:li rdf:parseType=\"Resource\">\n" +
           "            <vCard:N rdf:parseType=\"Resource\">\n" +
           "              <vCard:Family>Keating</vCard:Family>\n" +
           "              <vCard:Given>Sarah</vCard:Given>\n" +
           "            </vCard:N>\n" +
           "            <vCard:EMAIL>sbml-team@caltech.edu</vCard:EMAIL>\n" +
           "            <vCard:ORG>\n" +
           "              <vCard:Orgname>University of Hertfordshire</vCard:Orgname>\n" + 
           "            </vCard:ORG>\n" +
           "          </rdf:li>\n" +
           "        </rdf:Bag>\n" +
           "      </dc:creator>\n" +
           "      <dcterms:created rdf:parseType=\"Resource\">\n" +
           "        <dcterms:W3CDTF>1999-11-13T06:54:32Z</dcterms:W3CDTF>\n" +
           "      </dcterms:created>\n" +
           "      <dcterms:modified rdf:parseType=\"Resource\">\n" +
           "        <dcterms:W3CDTF>2007-11-31T06:54:00-02:00</dcterms:W3CDTF>\n" +
           "      </dcterms:modified>\n" +
           "    </rdf:Description>\n" +
           "  </rdf:RDF>\n" +
           "</annotation>\n";

        d.getModel().appendAnnotation(model_history_annotation);
        /*
         * The above code can be replaced by the following code.
         *
         ModelHistory h = new ModelHistory();

         ModelCreator c = new ModelCreator();
         c.setFamilyName("Keating");
         c.setGivenName("Sarah");
         c.setEmail("sbml-team@caltech.edu");
         c.setOrganisation("University of Hertfordshire");

         h.addCreator(c);

         Date date = new Date("1999-11-13T06:54:32");
         Date date2 = new Date("2007-11-31T06:54:00-02:00");

         h.setCreatedDate(date);
         h.setModifiedDate(date2);

         d.getModel().setModelHistory(h);
         *
         */
        
        long n = d.getModel().getNumSpecies();

        if (n > 0)
        { 
          Species s = d.getModel().getSpecies(0);

          String cvterms_annotation =
            "<annotation>\n" +
            "  <rdf:RDF xmlns:rdf=\"http://www.w3.org/1999/02/22-rdf-syntax-ns#\" xmlns:dc=\"http://purl.org/dc/elements/1.1/\" xmlns:dcterms=\"http://purl.org/dc/terms/\" xmlns:vCard=\"http://www.w3.org/2001/vcard-rdf/3.0#\" xmlns:bqbiol=\"http://biomodels.net/biology-qualifiers/\" xmlns:bqmodel=\"http://biomodels.net/model-qualifiers/\">\n" +
            "    <rdf:Description rdf:about=\"#\">\n" +
            "      <bqbiol:isVersionOf>\n" +
            "        <rdf:Bag>\n" +
            "          <rdf:li rdf:resource=\"http://www.geneontology.org/#GO:0005892\"/>\n" +
            "          <rdf:li rdf:resource=\"http://www.ebi.ac.uk/interpro/#IPR002394\"/>\n" +
            "        </rdf:Bag>\n" +
            "      </bqbiol:isVersionOf>\n" +
            "      <bqbiol:is>\n" +
            "        <rdf:Bag>\n" +
            "          <rdf:li rdf:resource=\"http://www.geneontology.org/#GO:0005895\"/>\n" +
            "        </rdf:Bag>\n" +
            "      </bqbiol:is>\n" +
            "    </rdf:Description>\n" +
            "  </rdf:RDF>\n" +
            "</annotation>\n";

          s.appendAnnotation(cvterms_annotation);
          
          /*
           * The above code can be replaced by the following code.
           *
          CVTerm cv = new CVTerm();
          cv.setQualifierType(libsbmlConstants.BIOLOGICAL_QUALIFIER);
          cv.setBiologicalQualifierType(libsbmlConstants.BQB_IS_VERSION_OF);
          cv.addResource("http://www.geneontology.org/#GO:0005892");

          CVTerm cv2 = new CVTerm();
          cv2.setQualifierType(libsbmlConstants.BIOLOGICAL_QUALIFIER);
          cv2.setBiologicalQualifierType(libsbmlConstants.BQB_IS);
          cv2.addResource("http://www.geneontology.org/#GO:0005895");

          CVTerm cv1 = new CVTerm();
          cv1.setQualifierType(libsbmlConstants.BIOLOGICAL_QUALIFIER);
          cv1.setBiologicalQualifierType(libsbmlConstants.BQB_IS_VERSION_OF);
          cv1.addResource("http://www.ebi.ac.uk/interpro/#IPR002394");

          s.addCVTerm(cv);
          s.addCVTerm(cv2);
          s.addCVTerm(cv1);
           * 
           */
        }
    }
    writer.writeSBML(d, args[1]);
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

