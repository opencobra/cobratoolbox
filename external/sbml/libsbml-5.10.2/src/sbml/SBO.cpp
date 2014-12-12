/**
 * @file    SBO.cpp
 * @brief   SBO utility functions
 * @author  Ben Bornstein
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

#include <iomanip>
#include <sstream>
#include <iterator>

#include <sbml/xml/XMLAttributes.h>
#include <sbml/xml/XMLOutputStream.h>
#include <sbml/xml/XMLErrorLog.h>

#include <sbml/SBMLError.h>
#include <sbml/SBMLErrorLog.h>

#include <sbml/SBO.h>

/** @cond doxygenIgnored */

using namespace std;

/** @endcond */

LIBSBML_CPP_NAMESPACE_BEGIN

#ifdef __cplusplus

/** @cond doxygenLibsbmlInternal */
/*
 * @return true if sboTerm is in the correct format (a zero-padded, seven
 * digit string preceded by SBO:), false otherwise.
 */
bool
SBO::checkTerm (const std::string& sboTerm)
{
  string::size_type size = sboTerm.size();
  bool              okay = (size == 11);

  char sbo[4]    = {83, 66, 79, 58};
  unsigned int n = 0;

  while (okay && n < 4)
  {
    okay = (sboTerm[n] == sbo[n]);
    n++;
  }

  for (n = 4; okay && n < size; ++n) okay = isdigit(sboTerm[n]);

  return okay;
}
/** @endcond */


/** @cond doxygenLibsbmlInternal */
/*
 * @return true if sboTerm is in the range [0 -- 9999999], false
 * otherwise.
 */
bool
SBO::checkTerm (int sboTerm)
{
  return (sboTerm >= 0 && sboTerm <= 9999999);
}
/** @endcond */

/** @cond doxygenLibsbmlInternal */

/*
 * Reads (and checks) sboTerm from the given XMLAttributes set.
 *
 * @return the sboTerm as an integer or -1 if the sboTerm was not in the
 * correct format or not found.
 */
int
SBO::readTerm (const XMLAttributes& attributes, SBMLErrorLog* log, 
               unsigned int level, unsigned int version, 
               unsigned int line, unsigned int column)
{
  int index = attributes.getIndex("sboTerm");
  if (index == -1)
  {
    return -1;
  }
  else if (!checkTerm(attributes.getValue(index)))
  {
    log->logError(InvalidSBOTermSyntax, level, version, "", line, column);
    return -1;
  }
  else
  {
    return stringToInt( attributes.getValue(index) );
  }
}


/*
 * Writes sboTerm as an XMLAttribute to the given XMLOutputStream.
 */
void
SBO::writeTerm (XMLOutputStream& stream, int sboTerm, const std::string& prefix)
{
  stream.writeAttribute( "sboTerm", prefix, intToString(sboTerm) );
}
/** @endcond */


/** @cond doxygenLibsbmlInternal */
/*
 * @return the given string sboTerm as an integer.  If the sboTerm is not
 * in the correct format (a zero-padded, seven digit string), -1 is
 * returned.
 */
int
SBO::stringToInt (const std::string& sboTerm)
{
  int result = -1;

  if ( checkTerm(sboTerm) )
  {
    result  = (sboTerm[10] - 48);
    result += (sboTerm[9] - 48) * 10;
    result += (sboTerm[8] - 48) * 100;
    result += (sboTerm[7] - 48) * 1000;
    result += (sboTerm[6] - 48) * 10000;
    result += (sboTerm[5] - 48) * 100000;
    result += (sboTerm[4] - 48) * 1000000;
  }

  return result;
}
/** @endcond */


/*
 * @return the given integer sboTerm as a zero-padded seven digit string.
 * If the sboTerm is not in the correct range ([0 -- 9999999]), an empty
 * string is returned.
 */
string
SBO::intToString (int sboTerm)
{
  string result = "";

  if ( checkTerm(sboTerm) )
  {
    ostringstream stream;
    stream << "SBO:";
    stream << setw(7) << setfill('0') << sboTerm;
    result = stream.str();
  }

  return result;
}


/**
  * functions for checking the SBO term is from correct part of SBO
  * Unary Functor returns the parent portion of a ParentMap pair.
  */
struct GetSecond : public unary_function<const pair<const int, int>, int>
{
  int operator() (const pair<const int, int>& pair) { return pair.second; }
};


/** @cond doxygenLibsbmlInternal */
/**
  * functions for checking the SBO term is from correct part of SBO
  * returns true if the term is-a parent, false otherwise
  */
bool
SBO::isChildOf(unsigned int term, unsigned int parent)
{
  bool        result = false;
  if (mParent.empty())
  {
    populateSBOTree();
  }
  ParentRange range  = mParent.equal_range(term);
  deque<unsigned int>  nodes;


  // Copy parents of term to nodes.
  transform(range.first, range.second, back_inserter(nodes), GetSecond());

  // Search nodes DFS for parent.
  // (For BFS, change back() and pop_back() to front() and pop_front().)
  while ( !nodes.empty() )
  {
    const unsigned int p = nodes.back();
    nodes.pop_back();

    if (p == parent)
    {
      result = true;
      break;
    }

    // Copy parents of p to nodes and continue search.
    range = mParent.equal_range(p);
    transform(range.first, range.second, back_inserter(nodes), GetSecond());
  }

  return result;
}
/** @endcond */


/**
  * functions for checking the SBO term is from correct part of SBO
  * returns true if the term is-a QuantitativeParameter, false otherwise
  */
bool
SBO::isQuantitativeParameter  (unsigned int sboTerm)
{
  if (sboTerm == 2)
    return true;
  else
  {
    return isChildOf(sboTerm, 2);
  }
}


/**
  * functions for checking the SBO term is from correct part of SBO
  * returns true if the term is-a ParticipantRole, false otherwise
  */
bool
SBO::isParticipantRole  (unsigned int sboTerm)
{
  if (sboTerm == 3)
    return true;
  else
  {
    return isChildOf(sboTerm, 3);
  }
}


/**
  * functions for checking the SBO term is from correct part of SBO
  * returns true if the term is-a ModellingFramework, false otherwise
  */
bool
SBO::isModellingFramework  (unsigned int sboTerm)
{
  if (sboTerm == 4)
    return true;
  else
  {
    return isChildOf(sboTerm, 4);
  }
}


/**
  * functions for checking the SBO term is from correct part of SBO
  * returns true if the term is-a MathematicalExpression, false otherwise
  */
bool
SBO::isMathematicalExpression  (unsigned int sboTerm)
{
  if (sboTerm == 64)
    return true;
  else
  {
    return isChildOf(sboTerm, 64);
  }
}


/**
  * functions for checking the SBO term is from correct part of SBO
  * returns true if the term is-a KineticConstant, false otherwise
  */
bool
SBO::isKineticConstant  (unsigned int sboTerm)
{
  if (sboTerm == 9)
    return true;
  else
  {
    return isChildOf(sboTerm, 9);
  }
}


/**
  * functions for checking the SBO term is from correct part of SBO
  * returns true if the term is-a Reactant, false otherwise
  */
bool
SBO::isReactant  (unsigned int sboTerm)
{
  if (sboTerm == 10)
    return true;
  else
  {
    return isChildOf(sboTerm, 10);
  }
}


/**
  * functions for checking the SBO term is from correct part of SBO
  * returns true if the term is-a Product, false otherwise
  */
bool
SBO::isProduct  (unsigned int sboTerm)
{
  if (sboTerm == 11)
    return true;
  else
  {
    return isChildOf(sboTerm, 11);
  }
}


/**
  * functions for checking the SBO term is from correct part of SBO
  * returns true if the term is-a isModifier, false otherwise
  */
bool
SBO::isModifier  (unsigned int sboTerm)
{
  if (sboTerm == 19)
    return true;
  else
  {
    return isChildOf(sboTerm, 19);
  }
}


/**
  * functions for checking the SBO term is from correct part of SBO
  * returns true if the term is-a RateLaw, false otherwise
  */
bool
SBO::isRateLaw  (unsigned int sboTerm)
{
  if (sboTerm == 1)
    return true;
  else
  {
    return isChildOf(sboTerm, 1);
  }
}


/**
  * functions for checking the SBO term is from correct part of SBO
  * returns true if the term is-a Event, false otherwise
  */
bool
SBO::isEvent  (unsigned int sboTerm)
{
  if (sboTerm == 231)
    return true;
  else
  {
    return isChildOf(sboTerm, 231);
  }
}


/**
  * functions for checking the SBO term is from correct part of SBO
  * returns true if the term is-a PhysicalParticipant, false otherwise
  */
bool
SBO::isPhysicalParticipant  (unsigned int sboTerm)
{
  if (sboTerm == 236)
    return true;
  else
  {
    return isChildOf(sboTerm, 236);
  }
}


/**
  * functions for checking the SBO term is from correct part of SBO
  * returns true if the term is-a Participant, false otherwise
  */
bool
SBO::isParticipant  (unsigned int sboTerm)
{
  if (sboTerm == 235)
    return true;
  else
  {
    return isChildOf(sboTerm, 235);
  }
}

/*
 * Function for checking the SBO term is from correct part of SBO.
 *
 * @return true if the term is-a Interaction, false otherwise
 */
bool
SBO::isInteraction  (unsigned int sboTerm)
{
  return SBO::isEvent(sboTerm);
}

/*
 * Function for checking the SBO term is from correct part of SBO.
 *
 * @return true if the term is-a Entity, false otherwise
 */
bool
SBO::isEntity  (unsigned int sboTerm)
{
  return SBO::isPhysicalParticipant(sboTerm);
}

/*
 * Function for checking the SBO term is from correct part of SBO.
 *
 * @return true if the term is-a FunctionalEntity, false otherwise
 */
bool
SBO::isFunctionalEntity  (unsigned int sboTerm)
{
  if (sboTerm == 241)
    return true;
  else
  {
    return isChildOf(sboTerm, 241);
  }
}

/*
 * Function for checking the SBO term is from correct part of SBO.
 *
 * @return true if the term is-a MaterialEntity, false otherwise
 */
bool
SBO::isMaterialEntity  (unsigned int sboTerm)
{
  if (sboTerm == 240)
    return true;
  else
  {
    return isChildOf(sboTerm, 240);
  }
}

/*
 * Function for checking the SBO term is from correct part of SBO.
 *
 * @return true if the term is-a ConservationLaw, false otherwise
 */
bool
SBO::isConservationLaw  (unsigned int sboTerm)
{
  if (sboTerm == 355)
    return true;
  else
  {
    return isChildOf(sboTerm, 355);
  }
}

/*
 * Function for checking the SBO term is from correct part of SBO.
 *
 * @return true if the term is-a SteadyStateExpression, false otherwise
 */
bool
SBO::isSteadyStateExpression  (unsigned int sboTerm)
{
  if (sboTerm == 391)
    return true;
  else
  {
    return isChildOf(sboTerm, 391);
  }
}

/*
 * Function for checking the SBO term is from correct part of SBO.
 *
 * @return true if the term is-a FunctionalCompartment, false otherwise
 */
bool
SBO::isFunctionalCompartment  (unsigned int sboTerm)
{
  if (sboTerm == 289)
    return true;
  else
  {
    return isChildOf(sboTerm, 289);
  }
}

/*
 * Function for checking the SBO term is from correct part of SBO.
 *
 * @return true if the term is-a ContinuousFramework, false otherwise
 */
bool
SBO::isContinuousFramework  (unsigned int sboTerm)
{
  if (sboTerm == 62)
    return true;
  else
  {
    return isChildOf(sboTerm, 62);
  }
}

/*
 * Function for checking the SBO term is from correct part of SBO.
 *
 * @return true if the term is-a DiscreteFramework, false otherwise
 */
bool
SBO::isDiscreteFramework  (unsigned int sboTerm)
{
  if (sboTerm == 63)
    return true;
  else
  {
    return isChildOf(sboTerm, 63);
  }
}

/*
 * Function for checking the SBO term is from correct part of SBO.
 *
 * @return true if the term is-a LogicalFramework, false otherwise
 */
bool
SBO::isLogicalFramework  (unsigned int sboTerm)
{
  if (sboTerm == 234)
    return true;
  else
  {
    return isChildOf(sboTerm, 234);
  }
}


/*
 * Function for checking the SBO term is from correct part of SBO.
 *
 * @return true if the term is-a MetadataRepresentation, false otherwise
 */
bool
SBO::isMetadataRepresentation  (unsigned int sboTerm)
{
  if (sboTerm == 544)
    return true;
  else
  {
    return isChildOf(sboTerm, 544);
  }
}


/*
 * Function for checking the SBO term is from correct part of SBO.
 *
 * @return true if the term is-a OccurringEntityRepresentation, false otherwise
 */
bool
SBO::isOccurringEntityRepresentation  (unsigned int sboTerm)
{
  if (sboTerm == 231)
    return true;
  else
  {
    return isChildOf(sboTerm, 231);
  }
}


/*
 * Function for checking the SBO term is from correct part of SBO.
 *
 * @return true if the term is-a PhysicalEntityRepresentation, false otherwise
 */
bool
SBO::isPhysicalEntityRepresentation  (unsigned int sboTerm)
{
  if (sboTerm == 236)
    return true;
  else
  {
    return isChildOf(sboTerm, 236);
  }
}


/*
 * Function for checking the SBO term is from correct part of SBO.
 *
 * @return true if the term is-a SystemsDescriptionParameter, false otherwise
 */
bool
SBO::isSystemsDescriptionParameter  (unsigned int sboTerm)
{
  if (sboTerm == 545)
    return true;
  else
  {
    return isChildOf(sboTerm, 545);
  }
}


/*
 * Function for checking the SBO term is Obselete
 *
 * @return true if the term is-a Obselete, false otherwise
 */
bool
SBO::isObselete  (unsigned int sboTerm)
{
  if (sboTerm == 1000)
    return true;
  else
  {
    return isChildOf(sboTerm, 1000);
  }
}


/** @cond doxygenLibsbmlInternal */
/**
  * functions for checking the SBO term is from correct part of SBO
  * populates the parent-child map
  */
void
SBO::populateSBOTree()
{
  // generated from SBO on October 25th 2013
  mParent.insert( pair<const int, int>(  1,  64) );
  mParent.insert( pair<const int, int>(  2, 545) );
  mParent.insert( pair<const int, int>(  3,   0) );
  mParent.insert( pair<const int, int>(  4,   0) );
  mParent.insert( pair<const int, int>(  5, 1000) );
  mParent.insert( pair<const int, int>(  6, 1000) );
  mParent.insert( pair<const int, int>(  7, 1000) );
  mParent.insert( pair<const int, int>(  8, 1000) );
  mParent.insert( pair<const int, int>(  9,   2) );
  mParent.insert( pair<const int, int>( 10,   3) );
  mParent.insert( pair<const int, int>( 11,   3) );
  mParent.insert( pair<const int, int>( 12,   1) );
  mParent.insert( pair<const int, int>( 13, 459) );
  mParent.insert( pair<const int, int>( 14, 241) );
  mParent.insert( pair<const int, int>( 15,  10) );
  mParent.insert( pair<const int, int>( 16,   9) );
  mParent.insert( pair<const int, int>( 17,   9) );
  mParent.insert( pair<const int, int>( 18,   9) );
  mParent.insert( pair<const int, int>( 19,   3) );
  mParent.insert( pair<const int, int>( 20,  19) );
  mParent.insert( pair<const int, int>( 21, 459) );
  mParent.insert( pair<const int, int>( 22,  16) );
  mParent.insert( pair<const int, int>( 22, 153) );
  mParent.insert( pair<const int, int>( 23,  17) );
  mParent.insert( pair<const int, int>( 23, 153) );
  mParent.insert( pair<const int, int>( 24,  18) );
  mParent.insert( pair<const int, int>( 24, 153) );
  mParent.insert( pair<const int, int>( 25,  35) );
  mParent.insert( pair<const int, int>( 26, 1000) );
  mParent.insert( pair<const int, int>( 27, 193) );
  mParent.insert( pair<const int, int>( 28, 150) );
  mParent.insert( pair<const int, int>( 28, 326) );
  mParent.insert( pair<const int, int>( 29,  28) );
  mParent.insert( pair<const int, int>( 30,  28) );
  mParent.insert( pair<const int, int>( 31,  28) );
  mParent.insert( pair<const int, int>( 32,  16) );
  mParent.insert( pair<const int, int>( 32, 156) );
  mParent.insert( pair<const int, int>( 33,  17) );
  mParent.insert( pair<const int, int>( 33, 156) );
  mParent.insert( pair<const int, int>( 34,  18) );
  mParent.insert( pair<const int, int>( 34, 156) );
  mParent.insert( pair<const int, int>( 35,  22) );
  mParent.insert( pair<const int, int>( 35, 154) );
  mParent.insert( pair<const int, int>( 36,  23) );
  mParent.insert( pair<const int, int>( 36, 154) );
  mParent.insert( pair<const int, int>( 37,  24) );
  mParent.insert( pair<const int, int>( 37, 154) );
  mParent.insert( pair<const int, int>( 38,  32) );
  mParent.insert( pair<const int, int>( 39,  33) );
  mParent.insert( pair<const int, int>( 40,  34) );
  mParent.insert( pair<const int, int>( 41,  12) );
  mParent.insert( pair<const int, int>( 42,  12) );
  mParent.insert( pair<const int, int>( 43,  41) );
  mParent.insert( pair<const int, int>( 44,  41) );
  mParent.insert( pair<const int, int>( 45,  41) );
  mParent.insert( pair<const int, int>( 46,   9) );
  mParent.insert( pair<const int, int>( 47,  43) );
  mParent.insert( pair<const int, int>( 47, 163) );
  mParent.insert( pair<const int, int>( 48, 154) );
  mParent.insert( pair<const int, int>( 48, 162) );
  mParent.insert( pair<const int, int>( 49,  44) );
  mParent.insert( pair<const int, int>( 49, 163) );
  mParent.insert( pair<const int, int>( 50,  45) );
  mParent.insert( pair<const int, int>( 51, 1000) );
  mParent.insert( pair<const int, int>( 52,  50) );
  mParent.insert( pair<const int, int>( 52, 163) );
  mParent.insert( pair<const int, int>( 53,  45) );
  mParent.insert( pair<const int, int>( 54,  53) );
  mParent.insert( pair<const int, int>( 54, 163) );
  mParent.insert( pair<const int, int>( 55,  41) );
  mParent.insert( pair<const int, int>( 56,  55) );
  mParent.insert( pair<const int, int>( 57,  56) );
  mParent.insert( pair<const int, int>( 57, 163) );
  mParent.insert( pair<const int, int>( 58,  55) );
  mParent.insert( pair<const int, int>( 59,  58) );
  mParent.insert( pair<const int, int>( 59, 163) );
  mParent.insert( pair<const int, int>( 60,  55) );
  mParent.insert( pair<const int, int>( 61,  60) );
  mParent.insert( pair<const int, int>( 61, 163) );
  mParent.insert( pair<const int, int>( 62,   4) );
  mParent.insert( pair<const int, int>( 63,   4) );
  mParent.insert( pair<const int, int>( 64,   0) );
  mParent.insert( pair<const int, int>( 65, 155) );
  mParent.insert( pair<const int, int>( 65, 162) );
  mParent.insert( pair<const int, int>( 66,  22) );
  mParent.insert( pair<const int, int>( 66, 155) );
  mParent.insert( pair<const int, int>( 67,  23) );
  mParent.insert( pair<const int, int>( 67, 155) );
  mParent.insert( pair<const int, int>( 68,  24) );
  mParent.insert( pair<const int, int>( 68, 155) );
  mParent.insert( pair<const int, int>( 69,  42) );
  mParent.insert( pair<const int, int>( 70,  69) );
  mParent.insert( pair<const int, int>( 71,  69) );
  mParent.insert( pair<const int, int>( 72,  71) );
  mParent.insert( pair<const int, int>( 73,  71) );
  mParent.insert( pair<const int, int>( 74,  69) );
  mParent.insert( pair<const int, int>( 75,  74) );
  mParent.insert( pair<const int, int>( 76,  74) );
  mParent.insert( pair<const int, int>( 77,  74) );
  mParent.insert( pair<const int, int>( 78,  42) );
  mParent.insert( pair<const int, int>( 79,  78) );
  mParent.insert( pair<const int, int>( 80,  78) );
  mParent.insert( pair<const int, int>( 81,  78) );
  mParent.insert( pair<const int, int>( 82,  81) );
  mParent.insert( pair<const int, int>( 83,  81) );
  mParent.insert( pair<const int, int>( 84,  78) );
  mParent.insert( pair<const int, int>( 85,  84) );
  mParent.insert( pair<const int, int>( 86,  84) );
  mParent.insert( pair<const int, int>( 87,  84) );
  mParent.insert( pair<const int, int>( 88,  42) );
  mParent.insert( pair<const int, int>( 89,  88) );
  mParent.insert( pair<const int, int>( 90,  89) );
  mParent.insert( pair<const int, int>( 91,  89) );
  mParent.insert( pair<const int, int>( 92,  89) );
  mParent.insert( pair<const int, int>( 93,  92) );
  mParent.insert( pair<const int, int>( 94,  92) );
  mParent.insert( pair<const int, int>( 95,  89) );
  mParent.insert( pair<const int, int>( 96,  95) );
  mParent.insert( pair<const int, int>( 97,  95) );
  mParent.insert( pair<const int, int>( 98,  95) );
  mParent.insert( pair<const int, int>( 99,  88) );
  mParent.insert( pair<const int, int>(100,  99) );
  mParent.insert( pair<const int, int>(101,  99) );
  mParent.insert( pair<const int, int>(102,  99) );
  mParent.insert( pair<const int, int>(103, 102) );
  mParent.insert( pair<const int, int>(104, 102) );
  mParent.insert( pair<const int, int>(105,  99) );
  mParent.insert( pair<const int, int>(106, 105) );
  mParent.insert( pair<const int, int>(107, 105) );
  mParent.insert( pair<const int, int>(108, 105) );
  mParent.insert( pair<const int, int>(109,  42) );
  mParent.insert( pair<const int, int>(110, 109) );
  mParent.insert( pair<const int, int>(111, 110) );
  mParent.insert( pair<const int, int>(112, 110) );
  mParent.insert( pair<const int, int>(113, 110) );
  mParent.insert( pair<const int, int>(114, 113) );
  mParent.insert( pair<const int, int>(115, 113) );
  mParent.insert( pair<const int, int>(116, 110) );
  mParent.insert( pair<const int, int>(117, 116) );
  mParent.insert( pair<const int, int>(118, 116) );
  mParent.insert( pair<const int, int>(119, 116) );
  mParent.insert( pair<const int, int>(120, 109) );
  mParent.insert( pair<const int, int>(121, 120) );
  mParent.insert( pair<const int, int>(122, 120) );
  mParent.insert( pair<const int, int>(123, 120) );
  mParent.insert( pair<const int, int>(124, 123) );
  mParent.insert( pair<const int, int>(125, 123) );
  mParent.insert( pair<const int, int>(126, 120) );
  mParent.insert( pair<const int, int>(127, 126) );
  mParent.insert( pair<const int, int>(128, 126) );
  mParent.insert( pair<const int, int>(129, 126) );
  mParent.insert( pair<const int, int>(130, 109) );
  mParent.insert( pair<const int, int>(131, 130) );
  mParent.insert( pair<const int, int>(132, 130) );
  mParent.insert( pair<const int, int>(133, 130) );
  mParent.insert( pair<const int, int>(134, 133) );
  mParent.insert( pair<const int, int>(135, 133) );
  mParent.insert( pair<const int, int>(136, 130) );
  mParent.insert( pair<const int, int>(137, 136) );
  mParent.insert( pair<const int, int>(138, 136) );
  mParent.insert( pair<const int, int>(139, 136) );
  mParent.insert( pair<const int, int>(140,  43) );
  mParent.insert( pair<const int, int>(140, 166) );
  mParent.insert( pair<const int, int>(141,  44) );
  mParent.insert( pair<const int, int>(141, 166) );
  mParent.insert( pair<const int, int>(142,  50) );
  mParent.insert( pair<const int, int>(142, 166) );
  mParent.insert( pair<const int, int>(143,  53) );
  mParent.insert( pair<const int, int>(143, 166) );
  mParent.insert( pair<const int, int>(144,  56) );
  mParent.insert( pair<const int, int>(144, 166) );
  mParent.insert( pair<const int, int>(145,  58) );
  mParent.insert( pair<const int, int>(145, 166) );
  mParent.insert( pair<const int, int>(146,  60) );
  mParent.insert( pair<const int, int>(146, 166) );
  mParent.insert( pair<const int, int>(147,   2) );
  mParent.insert( pair<const int, int>(148,   2) );
  mParent.insert( pair<const int, int>(149, 157) );
  mParent.insert( pair<const int, int>(150, 268) );
  mParent.insert( pair<const int, int>(151, 150) );
  mParent.insert( pair<const int, int>(152, 150) );
  mParent.insert( pair<const int, int>(153,   9) );
  mParent.insert( pair<const int, int>(154, 153) );
  mParent.insert( pair<const int, int>(155, 153) );
  mParent.insert( pair<const int, int>(156,   9) );
  mParent.insert( pair<const int, int>(157, 188) );
  mParent.insert( pair<const int, int>(158, 382) );
  mParent.insert( pair<const int, int>(159,   9) );
  mParent.insert( pair<const int, int>(160, 153) );
  mParent.insert( pair<const int, int>(160, 159) );
  mParent.insert( pair<const int, int>(161, 156) );
  mParent.insert( pair<const int, int>(161, 159) );
  mParent.insert( pair<const int, int>(162,  46) );
  mParent.insert( pair<const int, int>(162, 153) );
  mParent.insert( pair<const int, int>(163,  41) );
  mParent.insert( pair<const int, int>(164, 1000) );
  mParent.insert( pair<const int, int>(165, 1000) );
  mParent.insert( pair<const int, int>(166,  41) );
  mParent.insert( pair<const int, int>(231,   0) );
  mParent.insert( pair<const int, int>(232, 1000) );
  mParent.insert( pair<const int, int>(167, 375) );
  mParent.insert( pair<const int, int>(168, 374) );
  mParent.insert( pair<const int, int>(169, 168) );
  mParent.insert( pair<const int, int>(170, 168) );
  mParent.insert( pair<const int, int>(171, 170) );
  mParent.insert( pair<const int, int>(172, 170) );
  mParent.insert( pair<const int, int>(173, 237) );
  mParent.insert( pair<const int, int>(174, 237) );
  mParent.insert( pair<const int, int>(175, 237) );
  mParent.insert( pair<const int, int>(176, 167) );
  mParent.insert( pair<const int, int>(177, 176) );
  mParent.insert( pair<const int, int>(178, 182) );
  mParent.insert( pair<const int, int>(179, 176) );
  mParent.insert( pair<const int, int>(180, 176) );
  mParent.insert( pair<const int, int>(181, 176) );
  mParent.insert( pair<const int, int>(182, 176) );
  mParent.insert( pair<const int, int>(183, 205) );
  mParent.insert( pair<const int, int>(184, 205) );
  mParent.insert( pair<const int, int>(185, 167) );
  mParent.insert( pair<const int, int>(186,  46) );
  mParent.insert( pair<const int, int>(187, 1000) );
  mParent.insert( pair<const int, int>(188,   2) );
  mParent.insert( pair<const int, int>(189, 188) );
  mParent.insert( pair<const int, int>(190, 382) );
  mParent.insert( pair<const int, int>(191, 193) );
  mParent.insert( pair<const int, int>(192,   1) );
  mParent.insert( pair<const int, int>(193, 308) );
  mParent.insert( pair<const int, int>(194, 193) );
  mParent.insert( pair<const int, int>(195, 192) );
  mParent.insert( pair<const int, int>(196, 226) );
  mParent.insert( pair<const int, int>(197, 196) );
  mParent.insert( pair<const int, int>(198, 192) );
  mParent.insert( pair<const int, int>(199,  28) );
  mParent.insert( pair<const int, int>(200, 176) );
  mParent.insert( pair<const int, int>(201, 200) );
  mParent.insert( pair<const int, int>(202, 200) );
  mParent.insert( pair<const int, int>(203, 1000) );
  mParent.insert( pair<const int, int>(204, 205) );
  mParent.insert( pair<const int, int>(205, 375) );
  mParent.insert( pair<const int, int>(206,  20) );
  mParent.insert( pair<const int, int>(207,  20) );
  mParent.insert( pair<const int, int>(208, 176) );
  mParent.insert( pair<const int, int>(209, 176) );
  mParent.insert( pair<const int, int>(210, 182) );
  mParent.insert( pair<const int, int>(211, 182) );
  mParent.insert( pair<const int, int>(212, 208) );
  mParent.insert( pair<const int, int>(212, 210) );
  mParent.insert( pair<const int, int>(213, 208) );
  mParent.insert( pair<const int, int>(213, 211) );
  mParent.insert( pair<const int, int>(214, 210) );
  mParent.insert( pair<const int, int>(215, 210) );
  mParent.insert( pair<const int, int>(216, 210) );
  mParent.insert( pair<const int, int>(217, 210) );
  mParent.insert( pair<const int, int>(218, 210) );
  mParent.insert( pair<const int, int>(219, 210) );
  mParent.insert( pair<const int, int>(220, 210) );
  mParent.insert( pair<const int, int>(221, 210) );
  mParent.insert( pair<const int, int>(222, 221) );
  mParent.insert( pair<const int, int>(223, 221) );
  mParent.insert( pair<const int, int>(224, 210) );
  mParent.insert( pair<const int, int>(225, 346) );
  mParent.insert( pair<const int, int>(226, 360) );
  mParent.insert( pair<const int, int>(227, 226) );
  mParent.insert( pair<const int, int>(228, 227) );
  mParent.insert( pair<const int, int>(229, 227) );
  mParent.insert( pair<const int, int>(230, 227) );
  mParent.insert( pair<const int, int>(233, 210) );
  mParent.insert( pair<const int, int>(234,   4) );
  mParent.insert( pair<const int, int>(235, 1000) );
  mParent.insert( pair<const int, int>(236,   0) );
  mParent.insert( pair<const int, int>(237, 374) );
  mParent.insert( pair<const int, int>(238, 237) );
  mParent.insert( pair<const int, int>(239, 168) );
  mParent.insert( pair<const int, int>(240, 236) );
  mParent.insert( pair<const int, int>(241, 236) );
  mParent.insert( pair<const int, int>(242, 241) );
  mParent.insert( pair<const int, int>(243, 404) );
  mParent.insert( pair<const int, int>(244, 241) );
  mParent.insert( pair<const int, int>(245, 240) );
  mParent.insert( pair<const int, int>(246, 245) );
  mParent.insert( pair<const int, int>(247, 240) );
  mParent.insert( pair<const int, int>(248, 245) );
  mParent.insert( pair<const int, int>(249, 248) );
  mParent.insert( pair<const int, int>(250, 246) );
  mParent.insert( pair<const int, int>(251, 246) );
  mParent.insert( pair<const int, int>(252, 246) );
  mParent.insert( pair<const int, int>(253, 240) );
  mParent.insert( pair<const int, int>(254,   2) );
  mParent.insert( pair<const int, int>(255, 1000) );
  mParent.insert( pair<const int, int>(256, 1000) );
  mParent.insert( pair<const int, int>(257,   2) );
  mParent.insert( pair<const int, int>(258,   2) );
  mParent.insert( pair<const int, int>(259,   2) );
  mParent.insert( pair<const int, int>(260, 267) );
  mParent.insert( pair<const int, int>(260, 270) );
  mParent.insert( pair<const int, int>(261, 282) );
  mParent.insert( pair<const int, int>(262, 458) );
  mParent.insert( pair<const int, int>(263, 308) );
  mParent.insert( pair<const int, int>(264, 263) );
  mParent.insert( pair<const int, int>(265, 275) );
  mParent.insert( pair<const int, int>(266, 442) );
  mParent.insert( pair<const int, int>(267, 273) );
  mParent.insert( pair<const int, int>(268,   1) );
  mParent.insert( pair<const int, int>(269, 268) );
  mParent.insert( pair<const int, int>(270, 430) );
  mParent.insert( pair<const int, int>(271, 270) );
  mParent.insert( pair<const int, int>(272, 188) );
  mParent.insert( pair<const int, int>(273, 430) );
  mParent.insert( pair<const int, int>(274, 273) );
  mParent.insert( pair<const int, int>(274, 379) );
  mParent.insert( pair<const int, int>(275, 430) );
  mParent.insert( pair<const int, int>(276, 275) );
  mParent.insert( pair<const int, int>(277, 276) );
  mParent.insert( pair<const int, int>(278, 404) );
  mParent.insert( pair<const int, int>(279,   2) );
  mParent.insert( pair<const int, int>(280, 241) );
  mParent.insert( pair<const int, int>(281, 193) );
  mParent.insert( pair<const int, int>(282, 281) );
  mParent.insert( pair<const int, int>(282, 309) );
  mParent.insert( pair<const int, int>(283, 282) );
  mParent.insert( pair<const int, int>(283, 310) );
  mParent.insert( pair<const int, int>(284, 241) );
  mParent.insert( pair<const int, int>(285, 240) );
  mParent.insert( pair<const int, int>(286, 253) );
  mParent.insert( pair<const int, int>(287, 193) );
  mParent.insert( pair<const int, int>(288, 193) );
  mParent.insert( pair<const int, int>(289,   3) );
  mParent.insert( pair<const int, int>(290, 240) );
  mParent.insert( pair<const int, int>(291, 240) );
  mParent.insert( pair<const int, int>(292,  62) );
  mParent.insert( pair<const int, int>(293,  62) );
  mParent.insert( pair<const int, int>(294,  63) );
  mParent.insert( pair<const int, int>(295,  63) );
  mParent.insert( pair<const int, int>(296, 253) );
  mParent.insert( pair<const int, int>(297, 296) );
  mParent.insert( pair<const int, int>(298, 241) );
  mParent.insert( pair<const int, int>(299, 241) );
  mParent.insert( pair<const int, int>(300, 1000) );
  mParent.insert( pair<const int, int>(301,  35) );
  mParent.insert( pair<const int, int>(302,  36) );
  mParent.insert( pair<const int, int>(303, 308) );
  mParent.insert( pair<const int, int>(304, 303) );
  mParent.insert( pair<const int, int>(305, 303) );
  mParent.insert( pair<const int, int>(306, 303) );
  mParent.insert( pair<const int, int>(306, 309) );
  mParent.insert( pair<const int, int>(307, 306) );
  mParent.insert( pair<const int, int>(307, 310) );
  mParent.insert( pair<const int, int>(308,   2) );
  mParent.insert( pair<const int, int>(309, 308) );
  mParent.insert( pair<const int, int>(310, 309) );
  mParent.insert( pair<const int, int>(311, 278) );
  mParent.insert( pair<const int, int>(312, 278) );
  mParent.insert( pair<const int, int>(313, 334) );
  mParent.insert( pair<const int, int>(314, 334) );
  mParent.insert( pair<const int, int>(315, 241) );
  mParent.insert( pair<const int, int>(316, 334) );
  mParent.insert( pair<const int, int>(317, 241) );
  mParent.insert( pair<const int, int>(318, 334) );
  mParent.insert( pair<const int, int>(319, 334) );
  mParent.insert( pair<const int, int>(320,  25) );
  mParent.insert( pair<const int, int>(321,  25) );
  mParent.insert( pair<const int, int>(322,  27) );
  mParent.insert( pair<const int, int>(323,  27) );
  mParent.insert( pair<const int, int>(324, 186) );
  mParent.insert( pair<const int, int>(324, 350) );
  mParent.insert( pair<const int, int>(325, 186) );
  mParent.insert( pair<const int, int>(325, 353) );
  mParent.insert( pair<const int, int>(326, 269) );
  mParent.insert( pair<const int, int>(327, 247) );
  mParent.insert( pair<const int, int>(328, 247) );
  mParent.insert( pair<const int, int>(329, 404) );
  mParent.insert( pair<const int, int>(330, 211) );
  mParent.insert( pair<const int, int>(331,   9) );
  mParent.insert( pair<const int, int>(331, 346) );
  mParent.insert( pair<const int, int>(332, 331) );
  mParent.insert( pair<const int, int>(333,  49) );
  mParent.insert( pair<const int, int>(334, 404) );
  mParent.insert( pair<const int, int>(335, 404) );
  mParent.insert( pair<const int, int>(336,  10) );
  mParent.insert( pair<const int, int>(337, 281) );
  mParent.insert( pair<const int, int>(338,  35) );
  mParent.insert( pair<const int, int>(338,  38) );
  mParent.insert( pair<const int, int>(339,  36) );
  mParent.insert( pair<const int, int>(339, 341) );
  mParent.insert( pair<const int, int>(340,  37) );
  mParent.insert( pair<const int, int>(340, 341) );
  mParent.insert( pair<const int, int>(341, 154) );
  mParent.insert( pair<const int, int>(342, 375) );
  mParent.insert( pair<const int, int>(343, 342) );
  mParent.insert( pair<const int, int>(344, 342) );
  mParent.insert( pair<const int, int>(345, 1000) );
  mParent.insert( pair<const int, int>(346,   2) );
  mParent.insert( pair<const int, int>(347, 346) );
  mParent.insert( pair<const int, int>(348,   9) );
  mParent.insert( pair<const int, int>(348, 346) );
  mParent.insert( pair<const int, int>(349,  35) );
  mParent.insert( pair<const int, int>(350,  48) );
  mParent.insert( pair<const int, int>(352,  46) );
  mParent.insert( pair<const int, int>(352, 156) );
  mParent.insert( pair<const int, int>(353, 352) );
  mParent.insert( pair<const int, int>(354, 240) );
  mParent.insert( pair<const int, int>(355,  64) );
  mParent.insert( pair<const int, int>(356,  35) );
  mParent.insert( pair<const int, int>(357, 375) );
  mParent.insert( pair<const int, int>(358, 375) );
  mParent.insert( pair<const int, int>(359, 355) );
  mParent.insert( pair<const int, int>(360,   2) );
  mParent.insert( pair<const int, int>(361, 360) );
  mParent.insert( pair<const int, int>(362, 359) );
  mParent.insert( pair<const int, int>(363, 282) );
  mParent.insert( pair<const int, int>(364, 188) );
  mParent.insert( pair<const int, int>(365, 154) );
  mParent.insert( pair<const int, int>(365, 160) );
  mParent.insert( pair<const int, int>(366, 155) );
  mParent.insert( pair<const int, int>(366, 160) );
  mParent.insert( pair<const int, int>(367, 161) );
  mParent.insert( pair<const int, int>(368, 161) );
  mParent.insert( pair<const int, int>(369, 404) );
  mParent.insert( pair<const int, int>(370,  27) );
  mParent.insert( pair<const int, int>(371, 370) );
  mParent.insert( pair<const int, int>(372, 370) );
  mParent.insert( pair<const int, int>(373,  27) );
  mParent.insert( pair<const int, int>(374, 231) );
  mParent.insert( pair<const int, int>(375, 231) );
  mParent.insert( pair<const int, int>(376, 176) );
  mParent.insert( pair<const int, int>(377, 176) );
  mParent.insert( pair<const int, int>(378, 270) );
  mParent.insert( pair<const int, int>(379, 430) );
  mParent.insert( pair<const int, int>(380,   2) );
  mParent.insert( pair<const int, int>(381, 380) );
  mParent.insert( pair<const int, int>(382, 380) );
  mParent.insert( pair<const int, int>(383, 381) );
  mParent.insert( pair<const int, int>(384, 381) );
  mParent.insert( pair<const int, int>(385, 381) );
  mParent.insert( pair<const int, int>(386, 378) );
  mParent.insert( pair<const int, int>(387, 270) );
  mParent.insert( pair<const int, int>(388, 378) );
  mParent.insert( pair<const int, int>(389,   2) );
  mParent.insert( pair<const int, int>(390, 389) );
  mParent.insert( pair<const int, int>(391,  64) );
  mParent.insert( pair<const int, int>(392, 374) );
  mParent.insert( pair<const int, int>(393, 168) );
  mParent.insert( pair<const int, int>(394, 168) );
  mParent.insert( pair<const int, int>(395, 375) );
  mParent.insert( pair<const int, int>(396, 375) );
  mParent.insert( pair<const int, int>(397, 375) );
  mParent.insert( pair<const int, int>(398, 374) );
  mParent.insert( pair<const int, int>(399, 211) );
  mParent.insert( pair<const int, int>(400, 211) );
  mParent.insert( pair<const int, int>(401, 211) );
  mParent.insert( pair<const int, int>(402, 182) );
  mParent.insert( pair<const int, int>(403, 402) );
  mParent.insert( pair<const int, int>(404, 241) );
  mParent.insert( pair<const int, int>(405, 240) );
  mParent.insert( pair<const int, int>(406, 240) );
  mParent.insert( pair<const int, int>(407, 169) );
  mParent.insert( pair<const int, int>(408, 1000) );
  mParent.insert( pair<const int, int>(409, 236) );
  mParent.insert( pair<const int, int>(410, 290) );
  mParent.insert( pair<const int, int>(411, 170) );
  mParent.insert( pair<const int, int>(412, 231) );
  mParent.insert( pair<const int, int>(413, 374) );
  mParent.insert( pair<const int, int>(414, 413) );
  mParent.insert( pair<const int, int>(415, 413) );
  mParent.insert( pair<const int, int>(416, 390) );
  mParent.insert( pair<const int, int>(417, 390) );
  mParent.insert( pair<const int, int>(418, 286) );
  mParent.insert( pair<const int, int>(419, 286) );
  mParent.insert( pair<const int, int>(420, 286) );
  mParent.insert( pair<const int, int>(420, 296) );
  mParent.insert( pair<const int, int>(421, 286) );
  mParent.insert( pair<const int, int>(422, 261) );
  mParent.insert( pair<const int, int>(423, 194) );
  mParent.insert( pair<const int, int>(424, 194) );
  mParent.insert( pair<const int, int>(425, 268) );
  mParent.insert( pair<const int, int>(426, 425) );
  mParent.insert( pair<const int, int>(427, 426) );
  mParent.insert( pair<const int, int>(428, 426) );
  mParent.insert( pair<const int, int>(429, 268) );
  mParent.insert( pair<const int, int>(430, 269) );
  mParent.insert( pair<const int, int>(431, 425) );
  mParent.insert( pair<const int, int>(432, 429) );
  mParent.insert( pair<const int, int>(433, 429) );
  mParent.insert( pair<const int, int>(434, 429) );
  mParent.insert( pair<const int, int>(435, 429) );
  mParent.insert( pair<const int, int>(436, 429) );
  mParent.insert( pair<const int, int>(437, 326) );
  mParent.insert( pair<const int, int>(438, 326) );
  mParent.insert( pair<const int, int>(439, 326) );
  mParent.insert( pair<const int, int>(440, 430) );
  mParent.insert( pair<const int, int>(441, 275) );
  mParent.insert( pair<const int, int>(442, 265) );
  mParent.insert( pair<const int, int>(443, 430) );
  mParent.insert( pair<const int, int>(444, 443) );
  mParent.insert( pair<const int, int>(445, 444) );
  mParent.insert( pair<const int, int>(446, 444) );
  mParent.insert( pair<const int, int>(447, 444) );
  mParent.insert( pair<const int, int>(448, 444) );
  mParent.insert( pair<const int, int>(449, 447) );
  mParent.insert( pair<const int, int>(450, 448) );
  mParent.insert( pair<const int, int>(451, 430) );
  mParent.insert( pair<const int, int>(452, 451) );
  mParent.insert( pair<const int, int>(453, 451) );
  mParent.insert( pair<const int, int>(454, 430) );
  mParent.insert( pair<const int, int>(455, 454) );
  mParent.insert( pair<const int, int>(456, 430) );
  mParent.insert( pair<const int, int>(457, 456) );
  mParent.insert( pair<const int, int>(458, 430) );
  mParent.insert( pair<const int, int>(459,  19) );
  mParent.insert( pair<const int, int>(460,  13) );
  mParent.insert( pair<const int, int>(461, 459) );
  mParent.insert( pair<const int, int>(462, 459) );
  mParent.insert( pair<const int, int>(463, 303) );
  mParent.insert( pair<const int, int>(464, 375) );
  mParent.insert( pair<const int, int>(465,   2) );
  mParent.insert( pair<const int, int>(466, 465) );
  mParent.insert( pair<const int, int>(467, 465) );
  mParent.insert( pair<const int, int>(468, 465) );
  mParent.insert( pair<const int, int>(469, 413) );
  mParent.insert( pair<const int, int>(470, 540) );
  mParent.insert( pair<const int, int>(471, 196) );
  mParent.insert( pair<const int, int>(472, 196) );
  mParent.insert( pair<const int, int>(473, 552) );
  mParent.insert( pair<const int, int>(474,  64) );
  mParent.insert( pair<const int, int>(475, 474) );
  mParent.insert( pair<const int, int>(476, 347) );
  mParent.insert( pair<const int, int>(477, 346) );
  mParent.insert( pair<const int, int>(478, 193) );
  mParent.insert( pair<const int, int>(479, 478) );
  mParent.insert( pair<const int, int>(480, 478) );
  mParent.insert( pair<const int, int>(481, 380) );
  mParent.insert( pair<const int, int>(482,   9) );
  mParent.insert( pair<const int, int>(483, 1000) );
  mParent.insert( pair<const int, int>(484, 1000) );
  mParent.insert( pair<const int, int>(485,  46) );
  mParent.insert( pair<const int, int>(486, 381) );
  mParent.insert( pair<const int, int>(487, 474) );
  mParent.insert( pair<const int, int>(488, 487) );
  mParent.insert( pair<const int, int>(489, 487) );
  mParent.insert( pair<const int, int>(490, 188) );
  mParent.insert( pair<const int, int>(491,   9) );
  mParent.insert( pair<const int, int>(492,   2) );
  mParent.insert( pair<const int, int>(493, 241) );
  mParent.insert( pair<const int, int>(494, 493) );
  mParent.insert( pair<const int, int>(495, 493) );
  mParent.insert( pair<const int, int>(496, 493) );
  mParent.insert( pair<const int, int>(497, 389) );
  mParent.insert( pair<const int, int>(498, 381) );
  mParent.insert( pair<const int, int>(499, 1000) );
  mParent.insert( pair<const int, int>(500, 343) );
  mParent.insert( pair<const int, int>(501, 343) );
  mParent.insert( pair<const int, int>(502, 343) );
  mParent.insert( pair<const int, int>(503, 361) );
  mParent.insert( pair<const int, int>(504, 361) );
  mParent.insert( pair<const int, int>(505, 518) );
  mParent.insert( pair<const int, int>(506, 504) );
  mParent.insert( pair<const int, int>(507, 517) );
  mParent.insert( pair<const int, int>(508, 503) );
  mParent.insert( pair<const int, int>(509, 196) );
  mParent.insert( pair<const int, int>(510, 504) );
  mParent.insert( pair<const int, int>(511, 503) );
  mParent.insert( pair<const int, int>(512, 196) );
  mParent.insert( pair<const int, int>(513, 504) );
  mParent.insert( pair<const int, int>(514, 508) );
  mParent.insert( pair<const int, int>(515, 509) );
  mParent.insert( pair<const int, int>(516, 510) );
  mParent.insert( pair<const int, int>(517, 503) );
  mParent.insert( pair<const int, int>(518, 196) );
  mParent.insert( pair<const int, int>(519, 504) );
  mParent.insert( pair<const int, int>(520, 517) );
  mParent.insert( pair<const int, int>(521, 518) );
  mParent.insert( pair<const int, int>(522, 519) );
  mParent.insert( pair<const int, int>(523, 517) );
  mParent.insert( pair<const int, int>(524, 518) );
  mParent.insert( pair<const int, int>(525, 519) );
  mParent.insert( pair<const int, int>(526, 344) );
  mParent.insert( pair<const int, int>(527,   1) );
  mParent.insert( pair<const int, int>(528, 527) );
  mParent.insert( pair<const int, int>(529, 527) );
  mParent.insert( pair<const int, int>(530, 527) );
  mParent.insert( pair<const int, int>(531, 527) );
  mParent.insert( pair<const int, int>(532, 527) );
  mParent.insert( pair<const int, int>(533, 461) );
  mParent.insert( pair<const int, int>(534, 461) );
  mParent.insert( pair<const int, int>(535, 461) );
  mParent.insert( pair<const int, int>(536, 207) );
  mParent.insert( pair<const int, int>(537, 207) );
  mParent.insert( pair<const int, int>(538,   2) );
  mParent.insert( pair<const int, int>(539,   2) );
  mParent.insert( pair<const int, int>(540, 360) );
  mParent.insert( pair<const int, int>(541, 540) );
  mParent.insert( pair<const int, int>(542,   2) );
  mParent.insert( pair<const int, int>(543, 296) );
  mParent.insert( pair<const int, int>(544,   0) );
  mParent.insert( pair<const int, int>(545,   0) );
  mParent.insert( pair<const int, int>(546, 545) );
  mParent.insert( pair<const int, int>(547, 234) );
  mParent.insert( pair<const int, int>(548, 547) );
  mParent.insert( pair<const int, int>(549, 547) );
  mParent.insert( pair<const int, int>(550, 544) );
  mParent.insert( pair<const int, int>(551, 555) );
  mParent.insert( pair<const int, int>(552, 550) );
  mParent.insert( pair<const int, int>(553, 552) );
  mParent.insert( pair<const int, int>(554, 552) );
  mParent.insert( pair<const int, int>(555, 557) );
  mParent.insert( pair<const int, int>(556, 557) );
  mParent.insert( pair<const int, int>(557, 550) );
  mParent.insert( pair<const int, int>(558,   2) );
  mParent.insert( pair<const int, int>(559,   2) );
  mParent.insert( pair<const int, int>(560, 163) );
  mParent.insert( pair<const int, int>(561, 166) );
  mParent.insert( pair<const int, int>(562,  45) );
  mParent.insert( pair<const int, int>(563, 562) );
  mParent.insert( pair<const int, int>(564, 562) );
  mParent.insert( pair<const int, int>(565, 545) );
  mParent.insert( pair<const int, int>(566, 538) );
  mParent.insert( pair<const int, int>(567, 565) );
  mParent.insert( pair<const int, int>(568, 565) );
  mParent.insert( pair<const int, int>(569, 391) );
  mParent.insert( pair<const int, int>(570, 569) );
  mParent.insert( pair<const int, int>(571,   2) );
  mParent.insert( pair<const int, int>(572, 571) );
  mParent.insert( pair<const int, int>(573, 572) );
  mParent.insert( pair<const int, int>(574, 573) );
  mParent.insert( pair<const int, int>(575, 573) );
  mParent.insert( pair<const int, int>(576, 571) );
  mParent.insert( pair<const int, int>(577, 576) );
  mParent.insert( pair<const int, int>(578, 577) );
  mParent.insert( pair<const int, int>(579, 577) );
  mParent.insert( pair<const int, int>(580, 571) );
  mParent.insert( pair<const int, int>(581, 580) );
  mParent.insert( pair<const int, int>(582, 581) );
  mParent.insert( pair<const int, int>(583, 581) );
  mParent.insert( pair<const int, int>(584, 346) );
  mParent.insert( pair<const int, int>(585, 347) );
  mParent.insert( pair<const int, int>(586, 346) );
  mParent.insert( pair<const int, int>(587, 185) );
  mParent.insert( pair<const int, int>(588, 185) );
  mParent.insert( pair<const int, int>(589, 205) );
  mParent.insert( pair<const int, int>(590, 354) );
  mParent.insert( pair<const int, int>(591, 464) );
  mParent.insert( pair<const int, int>(592, 361) );
  mParent.insert( pair<const int, int>(593, 592) );
  mParent.insert( pair<const int, int>(594,   3) );
  mParent.insert( pair<const int, int>(595,  19) );
  mParent.insert( pair<const int, int>(596,  19) );
  mParent.insert( pair<const int, int>(597,  20) );
  mParent.insert( pair<const int, int>(598,   3) );
  mParent.insert( pair<const int, int>(599, 473) );
  mParent.insert( pair<const int, int>(600, 599) );
  mParent.insert( pair<const int, int>(601, 599) );
  mParent.insert( pair<const int, int>(602, 546) );
  mParent.insert( pair<const int, int>(603,  11) );
  mParent.insert( pair<const int, int>(604,  15) );



}
/** @endcond */

#endif /* __cplusplus */  
/** @cond doxygenIgnored */

/** @endcond */

LIBSBML_CPP_NAMESPACE_END
