/**
 * @file    ModelHistory.h
 * @brief   ModelHistory I/O
 * @author  Sarah Keating
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
 * ------------------------------------------------------------------------ -->
 *
 * @class ModelHistory
 * @sbmlbrief{core} MIRIAM-compliant data about a model's history.
 *
 * @htmlinclude not-sbml-warning.html
 *
 * The SBML specification beginning with Level&nbsp;2 Version&nbsp;2 defines
 * a standard approach to recording optional model history and model creator
 * information in a form that complies with MIRIAM (<a target="_blank"
 * href="http://www.nature.com/nbt/journal/v23/n12/abs/nbt1156.html">"Minimum
 * Information Requested in the Annotation of biochemical Models"</a>,
 * <i>Nature Biotechnology</i>, vol. 23, no. 12, Dec. 2005).  LibSBML
 * provides the ModelHistory class as a convenient high-level interface for
 * working with model history data.
 *
 * Model histories in SBML consist of one or more <em>model creators</em>,
 * a single date of @em creation, and one or more @em modification dates.
 * The overall XML form of this data takes the following form:
 * 
 <pre class="fragment">
 &lt;dc:creator&gt;
   &lt;rdf:Bag&gt;
     &lt;rdf:li rdf:parseType="Resource"&gt;
       <span style="background-color: #d0eed0">+++</span>
       &lt;vCard:N rdf:parseType="Resource"&gt;
         &lt;vCard:Family&gt;<span style="background-color: #bbb">family name</span>&lt;/vCard:Family&gt;
         &lt;vCard:Given&gt;<span style="background-color: #bbb">given name</span>&lt;/vCard:Given&gt;
       &lt;/vCard:N&gt;
       <span style="background-color: #d0eed0">+++</span>
       <span style="border-bottom: 2px dotted #888">&lt;vCard:EMAIL&gt;<span style="background-color: #bbb">email address</span>&lt;/vCard:EMAIL&gt;</span>
       <span style="background-color: #d0eed0">+++</span>
       <span style="border-bottom: 2px dotted #888">&lt;vCard:ORG rdf:parseType="Resource"&gt;</span>
        <span style="border-bottom: 2px dotted #888">&lt;vCard:Orgname&gt;<span style="background-color: #bbb">organization name</span>&lt;/vCard:Orgname&gt;</span>
       <span style="border-bottom: 2px dotted #888">&lt;/vCard:ORG&gt;</span>
       <span style="background-color: #d0eed0">+++</span>
     &lt;/rdf:li&gt;
     <span style="background-color: #edd">...</span>
   &lt;/rdf:Bag&gt;
 &lt;/dc:creator&gt;
 &lt;dcterms:created rdf:parseType="Resource"&gt;
   &lt;dcterms:W3CDTF&gt;<span style="background-color: #bbb">creation date</span>&lt;/dcterms:W3CDTF&gt;
 &lt;/dcterms:created&gt;
 &lt;dcterms:modified rdf:parseType="Resource"&gt;
   &lt;dcterms:W3CDTF&gt;<span style="background-color: #bbb">modification date</span>&lt;/dcterms:W3CDTF&gt;
 &lt;/dcterms:modified&gt;
 <span style="background-color: #edd">...</span>
 </pre>
 *
 * In the template above, the <span style="border-bottom: 2px dotted #888">underlined</span>
 * portions are optional, the symbol
 * <span class="code" style="background-color: #d0eed0">+++</span> is a placeholder
 * for either no content or valid XML content that is not defined by
 * the annotation scheme, and the ellipses
 * <span class="code" style="background-color: #edd">...</span>
 * are placeholders for zero or more elements of the same form as the
 * immediately preceding element.  The various placeholders for content, namely
 * <span class="code" style="background-color: #bbb">family name</span>,
 * <span class="code" style="background-color: #bbb">given name</span>,
 * <span class="code" style="background-color: #bbb">email address</span>,
 * <span class="code" style="background-color: #bbb">organization</span>,
 * <span class="code" style="background-color: #bbb">creation date</span>, and
 * <span class="code" style="background-color: #bbb">modification date</span>
 * are data that can be filled in using the various methods on
 * the ModelHistory class described below.
 *
 * @see ModelCreator
 * @see Date
 */ 

#ifndef ModelHistory_h
#define ModelHistory_h


#include <sbml/common/extern.h>
#include <sbml/common/sbmlfwd.h>
#include <sbml/common/operationReturnValues.h>
#include <sbml/util/List.h>

#include <sbml/xml/XMLNode.h>

#ifndef LIBSBML_USE_STRICT_INCLUDES
#include <sbml/annotation/Date.h>
#include <sbml/annotation/ModelCreator.h>
#endif

#ifdef __cplusplus

#include <string>

LIBSBML_CPP_NAMESPACE_BEGIN

#ifdef LIBSBML_USE_STRICT_INCLUDES
  class Date;
  class ModelCreator;
#endif

class LIBSBML_EXTERN ModelHistory
{
public:

  /**
   * Creates a new ModelHistory object.
   */
  ModelHistory ();


  /**
   * Destroys this ModelHistory object.
   */
  ~ModelHistory();


  /**
   * Copy constructor; creates a copy of this ModelHistory object.
   *
   * @param orig the object to copy.
   * 
   * @throws SBMLConstructorException
   * Thrown if the argument @p orig is @c NULL.
   */
  ModelHistory(const ModelHistory& orig);


  /**
   * Assignment operator for ModelHistory.
   *
   * @param rhs The object whose values are used as the basis of the
   * assignment.
   *
   * @throws SBMLConstructorException
   * Thrown if the argument @p rhs is @c NULL.
   */
  ModelHistory& operator=(const ModelHistory& rhs);


  /**
   * Creates and returns a deep copy of this ModelHistory object.
   *
   * @return the (deep) copy of this ModelHistory object.
   */
  ModelHistory* clone () const;


  /**
   * Returns the "creation date" portion of this ModelHistory object.
   *
   * @return a Date object representing the creation date stored in
   * this ModelHistory object.
   */
  Date * getCreatedDate();

  
  /**
   * Returns the "modified date" portion of this ModelHistory object.
   * 
   * Note that in the MIRIAM format for annotations, there can be multiple
   * modification dates.  The libSBML ModelHistory class supports this by
   * storing a list of "modified date" values.  If this ModelHistory object
   * contains more than one "modified date" value in the list, this method
   * will return the first one in the list.
   *
   * @return a Date object representing the date of modification
   * stored in this ModelHistory object.
   */
  Date * getModifiedDate();

  
  /**
   * Predicate returning @c true or @c false depending on whether this
   * ModelHistory's "creation date" is set.
   *
   * @return @c true if the creation date value of this ModelHistory is
   * set, @c false otherwise.
   */
  bool isSetCreatedDate();

  
  /**
   * Predicate returning @c true or @c false depending on whether this
   * ModelHistory's "modified date" is set.
   *
   * @return @c true if the modification date value of this ModelHistory
   * object is set, @c false otherwise.
   */
  bool isSetModifiedDate();

  
  /**
   * Sets the creation date of this ModelHistory object.
   *  
   * @param date a Date object representing the date to which the "created
   * date" portion of this ModelHistory should be set.
   *
   * @copydetails doc_returns_success_code
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_INVALID_OBJECT, OperationReturnValues_t}
   */
  int setCreatedDate(Date* date);

  
  /**
   * Sets the modification date of this ModelHistory object.
   *  
   * @param date a Date object representing the date to which the "modified
   * date" portion of this ModelHistory should be set.
   *
   * @copydetails doc_returns_success_code
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_OPERATION_FAILED, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_INVALID_OBJECT, OperationReturnValues_t}
   */
  int setModifiedDate(Date* date);

  
  /**
   * Adds a copy of a Date object to the list of "modified date" values
   * stored in this ModelHistory object.
   *
   * In the MIRIAM format for annotations, there can be multiple
   * modification dates.  The libSBML ModelHistory class supports this by
   * storing a list of "modified date" values.
   *  
   * @param date a Date object representing the "modified date" that should
   * be added to this ModelHistory object.
   * 
   * @copydetails doc_returns_success_code
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_OPERATION_FAILED, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_INVALID_OBJECT, OperationReturnValues_t}
   */
  int addModifiedDate(Date* date);

  
  /**
   * Returns the list of "modified date" values (as Date objects) stored in
   * this ModelHistory object.
   * 
   * In the MIRIAM format for annotations, there can be multiple
   * modification dates.  The libSBML ModelHistory class supports this by
   * storing a list of "modified date" values.
   * 
   * @return the list of modification dates for this ModelHistory object.
   */
  List * getListModifiedDates();

  
  /**
   * Get the nth Date object in the list of "modified date" values stored
   * in this ModelHistory object.
   * 
   * In the MIRIAM format for annotations, there can be multiple
   * modification dates.  The libSBML ModelHistory class supports this by
   * storing a list of "modified date" values.
   * 
   * @return the nth Date in the list of ModifiedDates of this
   * ModelHistory.
   */
  Date* getModifiedDate(unsigned int n);

  
  /**
   * Get the number of Date objects in this ModelHistory object's list of
   * "modified dates".
   * 
   * In the MIRIAM format for annotations, there can be multiple
   * modification dates.  The libSBML ModelHistory class supports this by
   * storing a list of "modified date" values.
   * 
   * @return the number of ModifiedDates in this ModelHistory.
   */
  unsigned int getNumModifiedDates();

  
  /**
   * Adds a copy of a ModelCreator object to the list of "model creator"
   * values stored in this ModelHistory object.
   *
   * In the MIRIAM format for annotations, there can be multiple model
   * creators.  The libSBML ModelHistory class supports this by storing a
   * list of "model creator" values.
   * 
   * @param mc the ModelCreator to add
   *
   * @copydetails doc_returns_success_code
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_INVALID_OBJECT, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_OPERATION_FAILED, OperationReturnValues_t}
   */
  int addCreator(ModelCreator * mc);

  
  /**
   * Returns the list of ModelCreator objects stored in this ModelHistory
   * object.
   *
   * In the MIRIAM format for annotations, there can be multiple model
   * creators.  The libSBML ModelHistory class supports this by storing a
   * list of "model creator" values.
   * 
   * @return the list of ModelCreator objects.
   */
  List * getListCreators();

  
  /**
   * Get the nth ModelCreator object stored in this ModelHistory object.
   *
   * In the MIRIAM format for annotations, there can be multiple model
   * creators.  The libSBML ModelHistory class supports this by storing a
   * list of "model creator" values.
   * 
   * @return the nth ModelCreator object.
   */
  ModelCreator* getCreator(unsigned int n);

  
  /**
   * Get the number of ModelCreator objects stored in this ModelHistory
   * object.
   *
   * In the MIRIAM format for annotations, there can be multiple model
   * creators.  The libSBML ModelHistory class supports this by storing a
   * list of "model creator" values.
   * 
   * @return the number of ModelCreators objects.
   */
  unsigned int getNumCreators();


  /**
   * Predicate returning @c true if all the required elements for this
   * ModelHistory object have been set.
   *
   * The required elements for a ModelHistory object are "created
   * name", "modified date", and at least one "model creator".
   *
   * @return a boolean value indicating whether all the required
   * elements for this object have been defined.
   */ 
  bool hasRequiredAttributes();

    
  /** @cond doxygenLibsbmlInternal */
   
  bool hasBeenModified();

  void resetModifiedFlags();
   
  /** @endcond */


protected:
  /** @cond doxygenLibsbmlInternal */

  /* Can have more than one creator. */

  List * mCreators;

  Date* mCreatedDate;

  /*
   * there can be more than one modified date
   * this is a bug and so as to not break code 
   * I'll hack the old code to interact with a list.
   */
  
  List * mModifiedDates;

  bool mHasBeenModified;


  /** @endcond */
};

LIBSBML_CPP_NAMESPACE_END

#endif  /* __cplusplus */

#ifndef SWIG

LIBSBML_CPP_NAMESPACE_BEGIN
BEGIN_C_DECLS


/**
 * Creates a new ModelHistory_t structure and returns a pointer to it.
 *
 * @return pointer to newly created ModelHistory_t structure.
 *
 * @memberof ModelHistory_t
 */
LIBSBML_EXTERN
ModelHistory_t * ModelHistory_create ();

/**
 * Destroys this ModelHistory_t.
 *
 * @param mh ModelHistory_t structure to be freed.
 *
 * @memberof ModelHistory_t
 */
LIBSBML_EXTERN
void ModelHistory_free(ModelHistory_t* mh);

/**
 * Creates a deep copy of the given ModelHistory_t structure
 * 
 * @param mh the ModelHistory_t structure to be copied
 * 
 * @return a (deep) copy of the given ModelHistory_t structure.
 *
 * @memberof ModelHistory_t
 */
LIBSBML_EXTERN
ModelHistory_t *
ModelHistory_clone (const ModelHistory_t* mh);


/**
 * Adds a copy of a ModelCreator_t structure to the 
 * ModelHistory_t structure.
 *
 * @param mh the ModelHistory_t structure
 * @param mc the ModelCreator_t structure to add.
 *
 * @copydetails doc_returns_success_code
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_OBJECT, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_OPERATION_FAILED, OperationReturnValues_t}
 *
 * @memberof ModelHistory_t
 */
LIBSBML_EXTERN
int ModelHistory_addCreator(ModelHistory_t * mh, 
                             ModelCreator_t * mc);

/**
 * Get the number of ModelCreator_t structures in this 
 * ModelHistory.
 * 
 * @param mh the ModelHistory_t structure
 * 
 * @return the number of ModelCreators in this 
 * ModelHistory.
 *
 * @memberof ModelHistory_t
 */
LIBSBML_EXTERN
unsigned int ModelHistory_getNumCreators(ModelHistory_t * mh);

/**
 * Get the List_t of ModelCreator_t structures in this 
 * ModelHistory.
 *
 * @param mh the ModelHistory_t structure
 * 
 * @return a pointer to the List_t structure of ModelCreators 
 * for this ModelHistory_t structure.
 *
 * @memberof ModelHistory_t
 */
LIBSBML_EXTERN
List_t * ModelHistory_getListCreators(ModelHistory_t * mh);

/**
 * Get the nth ModelCreator_t structure in this ModelHistory_t.
 * 
 * @param mh the ModelHistory_t structure
 * @param n an unsigned int indicating which ModelCreator_t
 *
 * @return the nth ModelCreator of this ModelHistory_t.
 *
 * @memberof ModelHistory_t
 */
LIBSBML_EXTERN
ModelCreator_t* ModelHistory_getCreator(ModelHistory_t * mh, unsigned int n);

/**
 * Sets the createdDate.
 *  
 * @param mh the ModelHistory_t structure
 * @param date the Date_t structure representing the date
 * the ModelHistory_t was created. 
 *
 * @copydetails doc_returns_success_code
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_OBJECT, OperationReturnValues_t}
 *
 * @memberof ModelHistory_t
 */
LIBSBML_EXTERN
int ModelHistory_setCreatedDate(ModelHistory_t * mh, 
                                 Date_t * date);

/**
 * Returns the createdDate from the ModelHistory_t.
 *
 * @param mh the ModelHistory_t structure
 * 
 * @return Date_t structure representing the createdDate
 * from the ModelHistory_t structure.
 *
 * @memberof ModelHistory_t
 */
LIBSBML_EXTERN
Date_t * ModelHistory_getCreatedDate(ModelHistory_t * mh);

/**
 * Predicate indicating whether this
 * ModelHistory_t's createdDate is set.
 *
 * @param mh the ModelHistory_t structure to be queried
 *
 * @return true (non-zero) if the createdDate of this 
 * ModelHistory_t structure is set, false (0) otherwise.
 *
 * @memberof ModelHistory_t
 */
LIBSBML_EXTERN
int ModelHistory_isSetCreatedDate(ModelHistory_t * mh);

/**
 * Sets the modifiedDate.
 *  
 * @param mh the ModelHistory_t structure
 * @param date the Date_t structure representing the date
 * the ModelHistory_t was modified. 
 *
 * @copydetails doc_returns_success_code
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_OBJECT, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_OPERATION_FAILED, OperationReturnValues_t}
 *
 * @memberof ModelHistory_t
 */
LIBSBML_EXTERN
int ModelHistory_setModifiedDate(ModelHistory_t * mh, 
                                  Date_t * date);

/**
 * Returns the modifiedDate from the ModelHistory_t.
 *
 * @param mh the ModelHistory_t structure
 * 
 * @return Date_t structure representing the modifiedDate
 * from the ModelHistory_t structure.
 *
 * @memberof ModelHistory_t
 */
LIBSBML_EXTERN
Date_t * ModelHistory_getModifiedDate(ModelHistory_t * mh);

/**
 * Predicate indicating whether this
 * ModelHistory_t's modifiedDate is set.
 *
 * @param mh the ModelHistory_t structure to be queried
 *
 * @return true (non-zero) if the modifiedDate of this 
 * ModelHistory_t structure is set, false (0) otherwise.
 *
 * @memberof ModelHistory_t
 */
LIBSBML_EXTERN
int ModelHistory_isSetModifiedDate(ModelHistory_t * mh);

/**
 * Adds a copy of a Date_t structure to the 
 * list of modifiedDates in the ModelHistory_t structure.
 *
 * @param mh the ModelHistory_t structure
 * @param date the Date_t structure to add.
 *
 * @copydetails doc_returns_success_code
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_OBJECT, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_OPERATION_FAILED, OperationReturnValues_t}
 *
 * @memberof ModelHistory_t
 */
LIBSBML_EXTERN
int 
ModelHistory_addModifiedDate(ModelHistory_t * mh, Date_t * date);

/**
 * Get the List_t of Date_t structures in the list of ModifiedDates 
 * in this ModelHistory_t.
 *
 * @param mh the ModelHistory_t structure
 * 
 * @return a pointer to the List_t structure of Dates 
 * for this ModelHistory_t structure.
 *
 * @memberof ModelHistory_t
 */
LIBSBML_EXTERN
List_t * 
ModelHistory_getListModifiedDates(ModelHistory_t * mh);

/**
 * Get the number of modified Date_t structures in the list of ModifiedDates 
 * in this ModelHistory_t.
 *
 * @param mh the ModelHistory_t structure
 * 
 * @return the number of Dates in the list of ModifiedDates in this 
 * ModelHistory_t.
 *
 * @memberof ModelHistory_t
 */
LIBSBML_EXTERN
unsigned int 
ModelHistory_getNumModifiedDates(ModelHistory_t * mh);

/**
 * Get the nth Date_t structure in the list of ModifiedDates
 * in this ModelHistory_t.
 * 
 * @param mh the ModelHistory_t structure
 * @param n an unsigned int indicating which Date_t
 *
 * @return the nth Date_t in the list of ModifiedDates
 * of this ModelHistory_t.
 *
 * @note A bug in libSBML meant that originally a ModelHistory_t structure
 * contained only one instance of a ModifiedDate_t.  In fact the MIRIAM
 * annotation expects zero or more modified dates and thus the
 * implementation was changed.  To avoid impacting on existing code
 * there is a ditinction between the function 
 * ModelHistory_getModifiedDate() which requires no index value and
 * this function that indexes into a list.
 *
 * @memberof ModelHistory_t
 */
LIBSBML_EXTERN
Date_t* 
ModelHistory_getModifiedDateFromList(ModelHistory_t * mh, unsigned int n);


/** 
 * Checks if the model history has all the required attributes.
 *
 * @param mh the ModelHistory_t structure
 * 
 * @return true (1) if this ModelHistory_t has all the required elements,
 * otherwise false (0) will be returned. If an invalid ModelHistory_t 
 * was provided LIBSBML_INVALID_OBJECT is returned.
 *
 * @memberof ModelHistory_t
 */
LIBSBML_EXTERN
int
ModelHistory_hasRequiredAttributes(ModelHistory_t *mh);


END_C_DECLS
LIBSBML_CPP_NAMESPACE_END

#endif  /* !SWIG */
#endif  /** ModelHistory_h **/

