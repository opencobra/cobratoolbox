package org.sbml.libsbml;

/**
 * Constants defined in libSBML.
 * <p>
 * <em style='color: #555'>
 * This interace class is defined by libSBML only and has no direct
 * equivalent in terms of SBML components.
 * </em>
 * <p>
 * This interface is necessary because of programming language differences
 * between Java and the underlying C++ core of libSBML's implementation, as
 * well as limitations in the translation system (SWIG) used to create the
 * Java interface.  In the C++ core, nearly all of the following constants
 * are defined as enumerations.  However, owing to how SWIG works and the
 * lack of proper enumerations in Java before Java 1.4, the enumerations
 * are instead translated to plain constants here in this {@link
 * libsbmlConstants} interface.
 */   
public interface libsbmlConstants
{
    /**
     * A version string of the form "1.2.3".
     */
    public final static String LIBSBML_DOTTED_VERSION = "5.10.2";


    /**
     * The version as an integer: version 1.2.3 becomes 10203.  Since the major
     * number comes first, the overall number will always increase when a new
     * libSBML is released, making it easy to use less-than and greater-than
     * comparisons when testing versions numbers.
     */
    public final static int LIBSBML_VERSION = 51002;


    /**
     * The numeric version as a string: version 1.2.3 becomes "10203".
     */
    public final static String LIBSBML_VERSION_STRING = "51002";


    // OperationReturnValues_t 
  

    /**
     * One of the possible libSBML operation return codes.
     * <p>
     * This code has the following meaning: The operation was successful.
     */
    public final static int LIBSBML_OPERATION_SUCCESS = 0;
  

    /**
     * One of the possible libSBML operation return codes.
     *
     * This code has the following meaning: An index parameter exceeded the
     * bounds of a data array or other collection used in the operation.
     * This return value is typically returned by methods that take index
     * numbers to refer to lists of objects, when the caller has provided
     * an index that exceeds the bounds of the list.  LibSBML provides
     * methods for checking the size of list/sequence/collection
     * structures, and callers should verify the sizes before calling
     * methods that take index numbers.
     */
    public final static int LIBSBML_INDEX_EXCEEDS_SIZE = -1;
  

    /**
     * One of the possible libSBML operation return codes.
     * <p>
     * This code has the following meaning: The attribute that is the
     * subject of this operation is not valid for the combination of SBML
     * Level and Version for the underlying object.  This can happen
     * because libSBML strives to offer a uniform API for all SBML Levels
     * and Versions, but some object attributes and elements are not
     * defined for all SBML Levels and Versions.  Calling programs are
     * expected to be aware of which object structures they are working
     * with, but when errors of this kind occur, they are reported using
     * this return value.
     */
    public final static int LIBSBML_UNEXPECTED_ATTRIBUTE = -2;
  

    /**
     * One of the possible libSBML operation return codes.
     * <p>
     * This code has the following meaning: The requested action could not
     * be performed.  This can occur in a variety of contexts, such as
     * passing a null object as a parameter in a situation where it does
     * not make sense to permit a null object.
     */
    public final static int LIBSBML_OPERATION_FAILED = -3;
  

    /**
     * One of the possible libSBML operation return codes.
     * <p>
     * This code has the following meaning: A value passed as an argument
     * to the method is not of a type that is valid for the operation or
     * kind of object involved.  For example, this return code is used when
     * a calling program attempts to set an SBML object identifier to a
     * string whose syntax does not conform to the SBML identifier syntax.
     */
    public final static int LIBSBML_INVALID_ATTRIBUTE_VALUE = -4;
  

    /**
     * One of the possible libSBML operation return codes.
     * <p>
     * This code has the following meaning: The object passed as an
     * argument to the method is not of a type that is valid for the
     * operation or kind of object involved.  For example, handing an
     * invalidly-constructed {@link ASTNode} to a method expecting an
     * {@link ASTNode} will result in this error.
     */
    public final static int LIBSBML_INVALID_OBJECT = -5;
  

    /**
     * One of the possible libSBML operation return codes.
     * <p>
     * This code has the following meaning: There already exists an object
     * with this identifier in the context where this operation is being
     * attempted.  This error is typically returned in situations where
     * SBML object identifiers must be unique, such as attempting to add
     * two species with the same identifier to a model.
     */
    public final static int LIBSBML_DUPLICATE_OBJECT_ID = -6;
  

    /**
     * One of the possible libSBML operation return codes.
     * <p>
     * This code has the following meaning: The SBML Level associated with
     * the object does not match the Level of the parent object.  This
     * error can happen when an SBML component such as a species or
     * compartment object is created outside of a model and a calling
     * program then attempts to add the object to a model that has a
     * different SBML Level defined.
     */
    public final static int LIBSBML_LEVEL_MISMATCH = -7;
  

    /**
     * One of the possible libSBML operation return codes.
     * <p>
     * This code has the following meaning: The SBML Version within the
     * SBML Level associated with the object does not match the Version of
     * the parent object.  This error can happen when an SBML component
     * such as a species or compartment object is created outside of a
     * model and a calling program then attempts to add the object to a
     * model that has a different SBML Level+Version combination.
     */
    public final static int LIBSBML_VERSION_MISMATCH = -8;
  

    /**
     * One of the possible libSBML operation return codes.
     * <p>
     * This code has the following meaning: The XML operation attempted is
     * not valid for the object or context involved.  This error is
     * typically returned by the XML interface layer of libSBML, when a
     * calling program attempts to construct or manipulate XML in an
     * invalid way.
     */
    public final static int LIBSBML_INVALID_XML_OPERATION = -9;


    /**
     * One of the possible libSBML operation return codes.
     * <p>
     * This code has the following meaning: The operation attempt could not
     * be performed because the object(s) involved have mismatched XML
     * namespaces for SBML Level/Versions.  This typically means the
     * properties of the {@link SBMLNamespaces} objects possessed by the
     * SBML objects do not correspond in some way.
     */
    public final static int LIBSBML_NAMESPACES_MISMATCH = -10;


    /**
     * One of the possible libSBML operation return codes.
     * <p>
     * This error is typically returned in situations where the
     * appendAnnotation function is being used to add an annotation that has
     * a namespace that is already present in the existing annotation.
     */
    public final static int LIBSBML_DUPLICATE_ANNOTATION_NS = -11;


    /**
     * One of the possible libSBML operation return codes.
     * <p>
     * This code has the following meaning: The existing annotation does
     * not have a top-level element with the given name. This error is
     * typically returned in situations one of the annotation replacement
     * functions is being used to replace or remove an annotation with a
     * name that does not match the name of any top-level element that is
     * already present in the existing annotation.
     */
    public final static int LIBSBML_ANNOTATION_NAME_NOT_FOUND = -12;


    /**
     * One of the possible libSBML operation return codes.
     * <p>
     * This code has the following meaning: The existing annotation does
     * not have a top-level element with the given namespace. This error is
     * typically returned in situations where one of the annotation
     * replacement functinos is being used to remove an annotation with a
     * namespace that does not match the namespace of any top-level element
     * that is already present in the existing annotation.
     */
    public final static int LIBSBML_ANNOTATION_NS_NOT_FOUND = -13;


    /**
     * One of the possible libSBML package operation return codes.
     * <p>
     * This code has the following meaning: the Version of the package
     * extension within the SBML Level and version associated with the
     * object does not match the Version of the parent object. This error
     * can happen when an SBML component object is created outside of a
     * model, and a calling program then attempts to add the object to a
     * model that has a different SBML Level+Version+Package Version
     * combination.
     */
    public final static int LIBSBML_PKG_VERSION_MISMATCH  = -20;


    /**
     * One of the possible libSBML package operation return codes.
     * <p>
     * This code has the following meaning: the required package extension
     * is unknown. This error is typically returned when creating an object
     * of {@link SBase} derived class with the required package, creating
     * an object of {@link SBMLNamespaces} or its derived class with the
     * required package, or invoking functions depending on the required
     * package.  To avoid this error, the library of the required package
     * needs to be linked.
     */
    public final static int LIBSBML_PKG_UNKNOWN           = -21;


    /**
     * One of the possible libSBML package operation return codes.
     * <p>
     * This code has the following meaning: The required version of the
     * package extension is unknown.  This error is typically returned when
     * creating an object of {@link SBase} derived class with the required
     * package, creating an object of {@link SBMLNamespaces} or its derived
     * class with the required package, or invoking functions depending on
     * the required package.  This error may be avoided by updating the
     * library of the required package to be linked.
     */
    public final static int LIBSBML_PKG_UNKNOWN_VERSION    = -22;


    /**
     * One of the possible libSBML package operation return codes.
     * <p>
     * This code has the following meaning: The required package extension
     * is disabled.  This error is typically returned when creating an
     * object of {@link SBase} derived class with the required package,
     * creating an object of {@link SBMLNamespaces} or its derived class
     * with the required package, or invoking functions depending on the
     * required package.  To avoid this error, the library of the required
     * package needs to be enabled.
     */
    public final static int LIBSBML_PKG_DISABLED            = -23;


    /**
     * One of the possible libSBML package operation return codes.
     * <p>
     * This code has the following meaning: another version of the required
     * package extension has already been enabled in the target SBase
     * object, or enabled in the model to/in which the target object to be
     * added/contained. This error is typically returned when adding an
     * object of some {@link SBase} derived class with the required package
     * to other {@link SBase} derived object, or when enabling the required
     * package in the target object.  To avoid this error, the conflict of
     * versions need to be avoided.
     */
    public final static int LIBSBML_PKG_CONFLICTED_VERSION  = -24;


    /**
     * One of the possible libSBML package operation return codes.
     * <p>
     * This code has the following meaning: another SBML package extension
     * for the same URI has already been registered. This error is
     * typically returned when adding a SBML package extension to the
     * {@link SBMLExtensionRegistry}. To avoid this error, ensure that SBML
     * package extensions are only registered once.
     */
    public final static int LIBSBML_PKG_CONFLICT            = -25;


    /**
     * One of the possible libSBML package operation return codes.
     * <p>
     * This code has the following meaning: while attempting to convert the
     * SBML document using {@link SBMLLevelVersionConverter#convert()} or
     * related methods, the target namespace has been found to be invalid
     * or unset.  (The function {@link SBMLNamespaces#isValidCombination()}
     * may be useful in detecting this situation and preventing the error.)
     */
    public final static int LIBSBML_CONV_INVALID_TARGET_NAMESPACE = -30;


    /**
     * One of the possible libSBML package operation return codes.
     * <p>
     * This code has the following meaning: conversions involving SBML
     * Level&nbsp;3 packages are not available in the given libSBML
     * method. This error is typically returned when calling a converter
     * that does not have the functionality to deal with SBML packages. To
     * avoid this error, ensure that the requested {@link
     * ConversionProperties} specifies packages.
     */
    public final static int LIBSBML_CONV_PKG_CONVERSION_NOT_AVAILABLE = -31;


    /**
     * One of the possible libSBML package operation return codes.
     * <p>
     * This code has the following meaning: The document on which
     * conversion is being requested is invalid and the requested
     * conversion cannot be performed. This error is typically returned
     * when a conversion routine has been given an invalid target document
     * or the conversion requires a certain degree of validity that is not
     * present in the document. To avoid this error use the {@link
     * SBMLDocument#checkConsistency()} function to find and resolve errors
     * before passing the document to a conversion method.
     */
    public final static int LIBSBML_CONV_INVALID_SRC_DOCUMENT = -32;


    /**
     * One of the possible libSBML package operation return codes.
     * <p>
     * This code has the following meaning: conversion with the given
     * properties is not yet available.
     */
    public final static int LIBSBML_CONV_CONVERSION_NOT_AVAILABLE = -33;


    /**
     * One of the possible libSBML package operation return codes.
     * <p>
     * This code has the following meaning: the SBML Level 3 package
     * involved is not known to this copy of libSBML.
     */
    public final static int LIBSBML_CONV_PKG_CONSIDERED_UNKNOWN = -34;



    // SBMLTypeCode_t 

    /**
     * One of the possible SBML component type codes.
     * <p>
     * LibSBML attaches an identifying code to every kind of SBML object.
     * These are known as <em>SBML type codes</em>.  In other languages,
     * the set of type codes is stored in an enumeration; in the Java
     * language interface for libSBML, the type codes are defined as static
     * integer constants in the interface class {@link libsbmlConstants}.
     * The names of the type codes all begin with the characters
     * <code>SBML_</code>.
     */
    public final static int SBML_UNKNOWN = 0;
  

    /**
     * One of the possible SBML component type codes.
     * <p>
     * LibSBML attaches an identifying code to every kind of SBML object.
     * These are known as <em>SBML type codes</em>.  In other languages,
     * the set of type codes is stored in an enumeration; in the Java
     * language interface for libSBML, the type codes are defined as static
     * integer constants in the interface class {@link libsbmlConstants}.
     * The names of the type codes all begin with the characters
     * <code>SBML_</code>.
     */
    public final static int SBML_COMPARTMENT = SBML_UNKNOWN + 1;
  

    /**
     * One of the possible SBML component type codes.
     * <p>
     * LibSBML attaches an identifying code to every kind of SBML object.
     * These are known as <em>SBML type codes</em>.  In other languages,
     * the set of type codes is stored in an enumeration; in the Java
     * language interface for libSBML, the type codes are defined as static
     * integer constants in the interface class {@link libsbmlConstants}.
     * The names of the type codes all begin with the characters
     * <code>SBML_</code>.
     */
    public final static int SBML_COMPARTMENT_TYPE = SBML_COMPARTMENT + 1;
  

    /**
     * One of the possible SBML component type codes.
     * <p>
     * LibSBML attaches an identifying code to every kind of SBML object.
     * These are known as <em>SBML type codes</em>.  In other languages,
     * the set of type codes is stored in an enumeration; in the Java
     * language interface for libSBML, the type codes are defined as static
     * integer constants in the interface class {@link libsbmlConstants}.
     * The names of the type codes all begin with the characters
     * <code>SBML_</code>.
     */
    public final static int SBML_CONSTRAINT = SBML_COMPARTMENT_TYPE + 1;
  

    /**
     * One of the possible SBML component type codes.
     * <p>
     * LibSBML attaches an identifying code to every kind of SBML object.
     * These are known as <em>SBML type codes</em>.  In other languages,
     * the set of type codes is stored in an enumeration; in the Java
     * language interface for libSBML, the type codes are defined as static
     * integer constants in the interface class {@link libsbmlConstants}.
     * The names of the type codes all begin with the characters
     * <code>SBML_</code>.
     */
    public final static int SBML_DOCUMENT = SBML_CONSTRAINT + 1;
  

    /**
     * One of the possible SBML component type codes.
     * <p>
     * LibSBML attaches an identifying code to every kind of SBML object.
     * These are known as <em>SBML type codes</em>.  In other languages,
     * the set of type codes is stored in an enumeration; in the Java
     * language interface for libSBML, the type codes are defined as static
     * integer constants in the interface class {@link libsbmlConstants}.
     * The names of the type codes all begin with the characters
     * <code>SBML_</code>.
     */
    public final static int SBML_EVENT = SBML_DOCUMENT + 1;
  

    /**
     * One of the possible SBML component type codes.
     * <p>
     * LibSBML attaches an identifying code to every kind of SBML object.
     * These are known as <em>SBML type codes</em>.  In other languages,
     * the set of type codes is stored in an enumeration; in the Java
     * language interface for libSBML, the type codes are defined as static
     * integer constants in the interface class {@link libsbmlConstants}.
     * The names of the type codes all begin with the characters
     * <code>SBML_</code>.
     */
    public final static int SBML_EVENT_ASSIGNMENT = SBML_EVENT + 1;
  

    /**
     * One of the possible SBML component type codes.
     * <p>
     * LibSBML attaches an identifying code to every kind of SBML object.
     * These are known as <em>SBML type codes</em>.  In other languages,
     * the set of type codes is stored in an enumeration; in the Java
     * language interface for libSBML, the type codes are defined as static
     * integer constants in the interface class {@link libsbmlConstants}.
     * The names of the type codes all begin with the characters
     * <code>SBML_</code>.
     */
    public final static int SBML_FUNCTION_DEFINITION = SBML_EVENT_ASSIGNMENT + 1;
  

    /**
     * One of the possible SBML component type codes.
     * <p>
     * LibSBML attaches an identifying code to every kind of SBML object.
     * These are known as <em>SBML type codes</em>.  In other languages,
     * the set of type codes is stored in an enumeration; in the Java
     * language interface for libSBML, the type codes are defined as static
     * integer constants in the interface class {@link libsbmlConstants}.
     * The names of the type codes all begin with the characters
     * <code>SBML_</code>.
     */
    public final static int SBML_INITIAL_ASSIGNMENT = SBML_FUNCTION_DEFINITION + 1;
  

    /**
     * One of the possible SBML component type codes.
     * <p>
     * LibSBML attaches an identifying code to every kind of SBML object.
     * These are known as <em>SBML type codes</em>.  In other languages,
     * the set of type codes is stored in an enumeration; in the Java
     * language interface for libSBML, the type codes are defined as static
     * integer constants in the interface class {@link libsbmlConstants}.
     * The names of the type codes all begin with the characters
     * <code>SBML_</code>.
     */
    public final static int SBML_KINETIC_LAW = SBML_INITIAL_ASSIGNMENT + 1;
  

    /**
     * One of the possible SBML component type codes.
     * <p>
     * LibSBML attaches an identifying code to every kind of SBML object.
     * These are known as <em>SBML type codes</em>.  In other languages,
     * the set of type codes is stored in an enumeration; in the Java
     * language interface for libSBML, the type codes are defined as static
     * integer constants in the interface class {@link libsbmlConstants}.
     * The names of the type codes all begin with the characters
     * <code>SBML_</code>.
     */
    public final static int SBML_LIST_OF = SBML_KINETIC_LAW + 1;
  

    /**
     * One of the possible SBML component type codes.
     * <p>
     * LibSBML attaches an identifying code to every kind of SBML object.
     * These are known as <em>SBML type codes</em>.  In other languages,
     * the set of type codes is stored in an enumeration; in the Java
     * language interface for libSBML, the type codes are defined as static
     * integer constants in the interface class {@link libsbmlConstants}.
     * The names of the type codes all begin with the characters
     * <code>SBML_</code>.
     */
    public final static int SBML_MODEL = SBML_LIST_OF + 1;
  

    /**
     * One of the possible SBML component type codes.
     * <p>
     * LibSBML attaches an identifying code to every kind of SBML object.
     * These are known as <em>SBML type codes</em>.  In other languages,
     * the set of type codes is stored in an enumeration; in the Java
     * language interface for libSBML, the type codes are defined as static
     * integer constants in the interface class {@link libsbmlConstants}.
     * The names of the type codes all begin with the characters
     * <code>SBML_</code>.
     */
    public final static int SBML_PARAMETER = SBML_MODEL + 1;
  

    /**
     * One of the possible SBML component type codes.
     * <p>
     * LibSBML attaches an identifying code to every kind of SBML object.
     * These are known as <em>SBML type codes</em>.  In other languages,
     * the set of type codes is stored in an enumeration; in the Java
     * language interface for libSBML, the type codes are defined as static
     * integer constants in the interface class {@link libsbmlConstants}.
     * The names of the type codes all begin with the characters
     * <code>SBML_</code>.
     */
    public final static int SBML_REACTION = SBML_PARAMETER + 1;
  

    /**
     * One of the possible SBML component type codes.
     * <p>
     * LibSBML attaches an identifying code to every kind of SBML object.
     * These are known as <em>SBML type codes</em>.  In other languages,
     * the set of type codes is stored in an enumeration; in the Java
     * language interface for libSBML, the type codes are defined as static
     * integer constants in the interface class {@link libsbmlConstants}.
     * The names of the type codes all begin with the characters
     * <code>SBML_</code>.
     */
    public final static int SBML_RULE = SBML_REACTION + 1;
  

    /**
     * One of the possible SBML component type codes.
     * <p>
     * LibSBML attaches an identifying code to every kind of SBML object.
     * These are known as <em>SBML type codes</em>.  In other languages,
     * the set of type codes is stored in an enumeration; in the Java
     * language interface for libSBML, the type codes are defined as static
     * integer constants in the interface class {@link libsbmlConstants}.
     * The names of the type codes all begin with the characters
     * <code>SBML_</code>.
     */
    public final static int SBML_SPECIES = SBML_RULE + 1;
  

    /**
     * One of the possible SBML component type codes.
     * <p>
     * LibSBML attaches an identifying code to every kind of SBML object.
     * These are known as <em>SBML type codes</em>.  In other languages,
     * the set of type codes is stored in an enumeration; in the Java
     * language interface for libSBML, the type codes are defined as static
     * integer constants in the interface class {@link libsbmlConstants}.
     * The names of the type codes all begin with the characters
     * <code>SBML_</code>.
     */
    public final static int SBML_SPECIES_REFERENCE = SBML_SPECIES + 1;
  

    /**
     * One of the possible SBML component type codes.
     * <p>
     * LibSBML attaches an identifying code to every kind of SBML object.
     * These are known as <em>SBML type codes</em>.  In other languages,
     * the set of type codes is stored in an enumeration; in the Java
     * language interface for libSBML, the type codes are defined as static
     * integer constants in the interface class {@link libsbmlConstants}.
     * The names of the type codes all begin with the characters
     * <code>SBML_</code>.
     */
    public final static int SBML_SPECIES_TYPE = SBML_SPECIES_REFERENCE + 1;
  

    /**
     * One of the possible SBML component type codes.
     * <p>
     * LibSBML attaches an identifying code to every kind of SBML object.
     * These are known as <em>SBML type codes</em>.  In other languages,
     * the set of type codes is stored in an enumeration; in the Java
     * language interface for libSBML, the type codes are defined as static
     * integer constants in the interface class {@link libsbmlConstants}.
     * The names of the type codes all begin with the characters
     * <code>SBML_</code>.
     */
    public final static int SBML_MODIFIER_SPECIES_REFERENCE = SBML_SPECIES_TYPE + 1;
  

    /**
     * One of the possible SBML component type codes.
     * <p>
     * LibSBML attaches an identifying code to every kind of SBML object.
     * These are known as <em>SBML type codes</em>.  In other languages,
     * the set of type codes is stored in an enumeration; in the Java
     * language interface for libSBML, the type codes are defined as static
     * integer constants in the interface class {@link libsbmlConstants}.
     * The names of the type codes all begin with the characters
     * <code>SBML_</code>.
     */
    public final static int SBML_UNIT_DEFINITION = SBML_MODIFIER_SPECIES_REFERENCE + 1;
  

    /**
     * One of the possible SBML component type codes.
     * <p>
     * LibSBML attaches an identifying code to every kind of SBML object.
     * These are known as <em>SBML type codes</em>.  In other languages,
     * the set of type codes is stored in an enumeration; in the Java
     * language interface for libSBML, the type codes are defined as static
     * integer constants in the interface class {@link libsbmlConstants}.
     * The names of the type codes all begin with the characters
     * <code>SBML_</code>.
     */
    public final static int SBML_UNIT = SBML_UNIT_DEFINITION + 1;
  

    /**
     * One of the possible SBML component type codes.
     * <p>
     * LibSBML attaches an identifying code to every kind of SBML object.
     * These are known as <em>SBML type codes</em>.  In other languages,
     * the set of type codes is stored in an enumeration; in the Java
     * language interface for libSBML, the type codes are defined as static
     * integer constants in the interface class {@link libsbmlConstants}.
     * The names of the type codes all begin with the characters
     * <code>SBML_</code>.
     */
    public final static int SBML_ALGEBRAIC_RULE = SBML_UNIT + 1;
  

    /**
     * One of the possible SBML component type codes.
     * <p>
     * LibSBML attaches an identifying code to every kind of SBML object.
     * These are known as <em>SBML type codes</em>.  In other languages,
     * the set of type codes is stored in an enumeration; in the Java
     * language interface for libSBML, the type codes are defined as static
     * integer constants in the interface class {@link libsbmlConstants}.
     * The names of the type codes all begin with the characters
     * <code>SBML_</code>.
     */
    public final static int SBML_ASSIGNMENT_RULE = SBML_ALGEBRAIC_RULE + 1;
  

    /**
     * One of the possible SBML component type codes.
     * <p>
     * LibSBML attaches an identifying code to every kind of SBML object.
     * These are known as <em>SBML type codes</em>.  In other languages,
     * the set of type codes is stored in an enumeration; in the Java
     * language interface for libSBML, the type codes are defined as static
     * integer constants in the interface class {@link libsbmlConstants}.
     * The names of the type codes all begin with the characters
     * <code>SBML_</code>.
     */
    public final static int SBML_RATE_RULE = SBML_ASSIGNMENT_RULE + 1;
  

    /**
     * One of the possible SBML component type codes.
     * <p>
     * LibSBML attaches an identifying code to every kind of SBML object.
     * These are known as <em>SBML type codes</em>.  In other languages,
     * the set of type codes is stored in an enumeration; in the Java
     * language interface for libSBML, the type codes are defined as static
     * integer constants in the interface class {@link libsbmlConstants}.
     * The names of the type codes all begin with the characters
     * <code>SBML_</code>.
     */
    public final static int SBML_SPECIES_CONCENTRATION_RULE = SBML_RATE_RULE + 1;
  

    /**
     * One of the possible SBML component type codes.
     * <p>
     * LibSBML attaches an identifying code to every kind of SBML object.
     * These are known as <em>SBML type codes</em>.  In other languages,
     * the set of type codes is stored in an enumeration; in the Java
     * language interface for libSBML, the type codes are defined as static
     * integer constants in the interface class {@link libsbmlConstants}.
     * The names of the type codes all begin with the characters
     * <code>SBML_</code>.
     */
    public final static int SBML_COMPARTMENT_VOLUME_RULE = SBML_SPECIES_CONCENTRATION_RULE + 1;
  

    /**
     * One of the possible SBML component type codes.
     * <p>
     * LibSBML attaches an identifying code to every kind of SBML object.
     * These are known as <em>SBML type codes</em>.  In other languages,
     * the set of type codes is stored in an enumeration; in the Java
     * language interface for libSBML, the type codes are defined as static
     * integer constants in the interface class {@link libsbmlConstants}.
     * The names of the type codes all begin with the characters
     * <code>SBML_</code>.
     */
    public final static int SBML_PARAMETER_RULE = SBML_COMPARTMENT_VOLUME_RULE + 1;
  

    /**
     * One of the possible SBML component type codes.
     * <p>
     * LibSBML attaches an identifying code to every kind of SBML object.
     * These are known as <em>SBML type codes</em>.  In other languages,
     * the set of type codes is stored in an enumeration; in the Java
     * language interface for libSBML, the type codes are defined as static
     * integer constants in the interface class {@link libsbmlConstants}.
     * The names of the type codes all begin with the characters
     * <code>SBML_</code>.
     */
    public final static int SBML_TRIGGER = SBML_PARAMETER_RULE + 1;
  

    /**
     * One of the possible SBML component type codes.
     * <p>
     * LibSBML attaches an identifying code to every kind of SBML object.
     * These are known as <em>SBML type codes</em>.  In other languages,
     * the set of type codes is stored in an enumeration; in the Java
     * language interface for libSBML, the type codes are defined as static
     * integer constants in the interface class {@link libsbmlConstants}.
     * The names of the type codes all begin with the characters
     * <code>SBML_</code>.
     */
    public final static int SBML_DELAY = SBML_TRIGGER + 1;
  

    /**
     * One of the possible SBML component type codes.
     * <p>
     * LibSBML attaches an identifying code to every kind of SBML object.
     * These are known as <em>SBML type codes</em>.  In other languages,
     * the set of type codes is stored in an enumeration; in the Java
     * language interface for libSBML, the type codes are defined as static
     * integer constants in the interface class {@link libsbmlConstants}.
     * The names of the type codes all begin with the characters
     * <code>SBML_</code>.
     */
    public final static int SBML_STOICHIOMETRY_MATH = SBML_DELAY + 1;
  

    /**
     * One of the possible SBML component type codes.
     * <p>
     * LibSBML attaches an identifying code to every kind of SBML object.
     * These are known as <em>SBML type codes</em>.  In other languages,
     * the set of type codes is stored in an enumeration; in the Java
     * language interface for libSBML, the type codes are defined as static
     * integer constants in the interface class {@link libsbmlConstants}.
     * The names of the type codes all begin with the characters
     * <code>SBML_</code>.
     */
    public final static int SBML_LOCAL_PARAMETER = SBML_STOICHIOMETRY_MATH + 1;
  

    /**
     * One of the possible SBML component type codes.
     * <p>
     * LibSBML attaches an identifying code to every kind of SBML object.
     * These are known as <em>SBML type codes</em>.  In other languages,
     * the set of type codes is stored in an enumeration; in the Java
     * language interface for libSBML, the type codes are defined as static
     * integer constants in the interface class {@link libsbmlConstants}.
     * The names of the type codes all begin with the characters
     * <code>SBML_</code>.
     */
    public final static int SBML_PRIORITY = SBML_LOCAL_PARAMETER + 1;
  

    /**
     * One of the possible SBML component type codes.
     * <p>
     * LibSBML attaches an identifying code to every kind of SBML object.
     * These are known as <em>SBML type codes</em>.  In other languages,
     * the set of type codes is stored in an enumeration; in the Java
     * language interface for libSBML, the type codes are defined as static
     * integer constants in the interface class {@link libsbmlConstants}.
     * The names of the type codes all begin with the characters
     * <code>SBML_</code>.
     */
    public final static int SBML_GENERIC_SBASE = SBML_PRIORITY + 1;
  

    // UnitKind_t 

    /**
     * One of the possible predefined SBML units.
     */
    public final static int UNIT_KIND_AMPERE = 0;
  

    /**
     * One of the possible predefined SBML units.
     */
    public final static int UNIT_KIND_AVOGADRO = UNIT_KIND_AMPERE + 1;
  

    /**
     * One of the possible predefined SBML units.
     */
    public final static int UNIT_KIND_BECQUEREL = UNIT_KIND_AVOGADRO + 1;
  

    /**
     * One of the possible predefined SBML units.
     */
    public final static int UNIT_KIND_CANDELA = UNIT_KIND_BECQUEREL + 1;
  

    /**
     * One of the possible predefined SBML units.
     */
    public final static int UNIT_KIND_CELSIUS = UNIT_KIND_CANDELA + 1;
  

    /**
     * One of the possible predefined SBML units.
     */
    public final static int UNIT_KIND_COULOMB = UNIT_KIND_CELSIUS + 1;
  

    /**
     * One of the possible predefined SBML units.
     */
    public final static int UNIT_KIND_DIMENSIONLESS = UNIT_KIND_COULOMB + 1;
  

    /**
     * One of the possible predefined SBML units.
     */
    public final static int UNIT_KIND_FARAD = UNIT_KIND_DIMENSIONLESS + 1;
  

    /**
     * One of the possible predefined SBML units.
     */
    public final static int UNIT_KIND_GRAM = UNIT_KIND_FARAD + 1;
  

    /**
     * One of the possible predefined SBML units.
     */
    public final static int UNIT_KIND_GRAY = UNIT_KIND_GRAM + 1;
  

    /**
     * One of the possible predefined SBML units.
     */
    public final static int UNIT_KIND_HENRY = UNIT_KIND_GRAY + 1;
  

    /**
     * One of the possible predefined SBML units.
     */
    public final static int UNIT_KIND_HERTZ = UNIT_KIND_HENRY + 1;
  

    /**
     * One of the possible predefined SBML units.
     */
    public final static int UNIT_KIND_ITEM = UNIT_KIND_HERTZ + 1;
  

    /**
     * One of the possible predefined SBML units.
     */
    public final static int UNIT_KIND_JOULE = UNIT_KIND_ITEM + 1;
  

    /**
     * One of the possible predefined SBML units.
     */
    public final static int UNIT_KIND_KATAL = UNIT_KIND_JOULE + 1;
  

    /**
     * One of the possible predefined SBML units.
     */
    public final static int UNIT_KIND_KELVIN = UNIT_KIND_KATAL + 1;
  

    /**
     * One of the possible predefined SBML units.
     */
    public final static int UNIT_KIND_KILOGRAM = UNIT_KIND_KELVIN + 1;
  

    /**
     * One of the possible predefined SBML units.
     */
    public final static int UNIT_KIND_LITER = UNIT_KIND_KILOGRAM + 1;
  

    /**
     * One of the possible predefined SBML units.
     */
    public final static int UNIT_KIND_LITRE = UNIT_KIND_LITER + 1;
  

    /**
     * One of the possible predefined SBML units.
     */
    public final static int UNIT_KIND_LUMEN = UNIT_KIND_LITRE + 1;
  

    /**
     * One of the possible predefined SBML units.
     */
    public final static int UNIT_KIND_LUX = UNIT_KIND_LUMEN + 1;
  

    /**
     * One of the possible predefined SBML units.
     */
    public final static int UNIT_KIND_METER = UNIT_KIND_LUX + 1;
  

    /**
     * One of the possible predefined SBML units.
     */
    public final static int UNIT_KIND_METRE = UNIT_KIND_METER + 1;
  

    /**
     * One of the possible predefined SBML units.
     */
    public final static int UNIT_KIND_MOLE = UNIT_KIND_METRE + 1;
  

    /**
     * One of the possible predefined SBML units.
     */
    public final static int UNIT_KIND_NEWTON = UNIT_KIND_MOLE + 1;
  

    /**
     * One of the possible predefined SBML units.
     */
    public final static int UNIT_KIND_OHM = UNIT_KIND_NEWTON + 1;
  

    /**
     * One of the possible predefined SBML units.
     */
    public final static int UNIT_KIND_PASCAL = UNIT_KIND_OHM + 1;
  

    /**
     * One of the possible predefined SBML units.
     */
    public final static int UNIT_KIND_RADIAN = UNIT_KIND_PASCAL + 1;
  

    /**
     * One of the possible predefined SBML units.
     */
    public final static int UNIT_KIND_SECOND = UNIT_KIND_RADIAN + 1;
  

    /**
     * One of the possible predefined SBML units.
     */
    public final static int UNIT_KIND_SIEMENS = UNIT_KIND_SECOND + 1;
  

    /**
     * One of the possible predefined SBML units.
     */
    public final static int UNIT_KIND_SIEVERT = UNIT_KIND_SIEMENS + 1;
  

    /**
     * One of the possible predefined SBML units.
     */
    public final static int UNIT_KIND_STERADIAN = UNIT_KIND_SIEVERT + 1;
  

    /**
     * One of the possible predefined SBML units.
     */
    public final static int UNIT_KIND_TESLA = UNIT_KIND_STERADIAN + 1;
  

    /**
     * One of the possible predefined SBML units.
     */
    public final static int UNIT_KIND_VOLT = UNIT_KIND_TESLA + 1;
  

    /**
     * One of the possible predefined SBML units.
     */
    public final static int UNIT_KIND_WATT = UNIT_KIND_VOLT + 1;
  

    /**
     * One of the possible predefined SBML units.
     */
    public final static int UNIT_KIND_WEBER = UNIT_KIND_WATT + 1;
  

    /**
     * One of the possible predefined SBML units.
     */
    public final static int UNIT_KIND_INVALID = UNIT_KIND_WEBER + 1;

    // RuleType_t 
  

    /**
     * One of the possible SBML {@link Rule} object types.
     */
    public final static int RULE_TYPE_RATE = 0;
  

    /**
     * One of the possible SBML {@link Rule} object types.
     */
    public final static int RULE_TYPE_SCALAR = RULE_TYPE_RATE + 1;
  

    /**
     * One of the possible SBML {@link Rule} object types.
     */
    public final static int RULE_TYPE_INVALID = RULE_TYPE_SCALAR + 1;

  

    // ASTNodeType_t 
  

    /**
     * One of the possible {@link ASTNode} types.  Each {@link ASTNode} has
     * a type whose value is one of the elements of this enumeration.
     */
    public final static int AST_PLUS = '+';
  

    /**
     * One of the possible {@link ASTNode} types.  Each {@link ASTNode} has
     * a type whose value is one of the elements of this enumeration.
     */
    public final static int AST_MINUS = '-';
  

    /**
     * One of the possible {@link ASTNode} types.  Each {@link ASTNode} has
     * a type whose value is one of the elements of this enumeration.
     */
    public final static int AST_TIMES = '*';
  

    /**
     * One of the possible {@link ASTNode} types.  Each {@link ASTNode} has
     * a type whose value is one of the elements of this enumeration.
     */
    public final static int AST_DIVIDE = '/';
  

    /**
     * One of the possible {@link ASTNode} types.  Each {@link ASTNode} has
     * a type whose value is one of the elements of this enumeration.
     */
    public final static int AST_POWER = '^';
  

    /**
     * One of the possible {@link ASTNode} types.  Each {@link ASTNode} has
     * a type whose value is one of the elements of this enumeration.
     */
    public final static int AST_INTEGER = 256;
  

    /**
     * One of the possible {@link ASTNode} types.  Each {@link ASTNode} has
     * a type whose value is one of the elements of this enumeration.
     */
    public final static int AST_REAL = AST_INTEGER + 1;
  

    /**
     * One of the possible {@link ASTNode} types.  Each {@link ASTNode} has
     * a type whose value is one of the elements of this enumeration.
     */
    public final static int AST_REAL_E = AST_REAL + 1;
  

    /**
     * One of the possible {@link ASTNode} types.  Each {@link ASTNode} has
     * a type whose value is one of the elements of this enumeration.
     */
    public final static int AST_RATIONAL = AST_REAL_E + 1;
  

    /**
     * One of the possible {@link ASTNode} types.  Each {@link ASTNode} has
     * a type whose value is one of the elements of this enumeration.
     */
    public final static int AST_NAME = AST_RATIONAL + 1;
  

    /**
     * One of the possible {@link ASTNode} types.  Each {@link ASTNode} has
     * a type whose value is one of the elements of this enumeration.
     */
    public final static int AST_NAME_AVOGADRO = AST_NAME + 1;
  

    /**
     * One of the possible {@link ASTNode} types.  Each {@link ASTNode} has
     * a type whose value is one of the elements of this enumeration.
     */
    public final static int AST_NAME_TIME = AST_NAME_AVOGADRO + 1;
  

    /**
     * One of the possible {@link ASTNode} types.  Each {@link ASTNode} has
     * a type whose value is one of the elements of this enumeration.
     */
    public final static int AST_CONSTANT_E = AST_NAME_TIME + 1;
  

    /**
     * One of the possible {@link ASTNode} types.  Each {@link ASTNode} has
     * a type whose value is one of the elements of this enumeration.
     */
    public final static int AST_CONSTANT_FALSE = AST_CONSTANT_E + 1;
  

    /**
     * One of the possible {@link ASTNode} types.  Each {@link ASTNode} has
     * a type whose value is one of the elements of this enumeration.
     */
    public final static int AST_CONSTANT_PI = AST_CONSTANT_FALSE + 1;
  

    /**
     * One of the possible {@link ASTNode} types.  Each {@link ASTNode} has
     * a type whose value is one of the elements of this enumeration.
     */
    public final static int AST_CONSTANT_TRUE = AST_CONSTANT_PI + 1;
  

    /**
     * One of the possible {@link ASTNode} types.  Each {@link ASTNode} has
     * a type whose value is one of the elements of this enumeration.
     */
    public final static int AST_LAMBDA = AST_CONSTANT_TRUE + 1;
  

    /**
     * One of the possible {@link ASTNode} types.  Each {@link ASTNode} has
     * a type whose value is one of the elements of this enumeration.
     */
    public final static int AST_FUNCTION = AST_LAMBDA + 1;
  

    /**
     * One of the possible {@link ASTNode} types.  Each {@link ASTNode} has
     * a type whose value is one of the elements of this enumeration.
     */
    public final static int AST_FUNCTION_ABS = AST_FUNCTION + 1;
  

    /**
     * One of the possible {@link ASTNode} types.  Each {@link ASTNode} has
     * a type whose value is one of the elements of this enumeration.
     */
    public final static int AST_FUNCTION_ARCCOS = AST_FUNCTION_ABS + 1;
  

    /**
     * One of the possible {@link ASTNode} types.  Each {@link ASTNode} has
     * a type whose value is one of the elements of this enumeration.
     */
    public final static int AST_FUNCTION_ARCCOSH = AST_FUNCTION_ARCCOS + 1;
  

    /**
     * One of the possible {@link ASTNode} types.  Each {@link ASTNode} has
     * a type whose value is one of the elements of this enumeration.
     */
    public final static int AST_FUNCTION_ARCCOT = AST_FUNCTION_ARCCOSH + 1;
  

    /**
     * One of the possible {@link ASTNode} types.  Each {@link ASTNode} has
     * a type whose value is one of the elements of this enumeration.
     */
    public final static int AST_FUNCTION_ARCCOTH = AST_FUNCTION_ARCCOT + 1;
  

    /**
     * One of the possible {@link ASTNode} types.  Each {@link ASTNode} has
     * a type whose value is one of the elements of this enumeration.
     */
    public final static int AST_FUNCTION_ARCCSC = AST_FUNCTION_ARCCOTH + 1;
  

    /**
     * One of the possible {@link ASTNode} types.  Each {@link ASTNode} has
     * a type whose value is one of the elements of this enumeration.
     */
    public final static int AST_FUNCTION_ARCCSCH = AST_FUNCTION_ARCCSC + 1;
  

    /**
     * One of the possible {@link ASTNode} types.  Each {@link ASTNode} has
     * a type whose value is one of the elements of this enumeration.
     */
    public final static int AST_FUNCTION_ARCSEC = AST_FUNCTION_ARCCSCH + 1;
  

    /**
     * One of the possible {@link ASTNode} types.  Each {@link ASTNode} has
     * a type whose value is one of the elements of this enumeration.
     */
    public final static int AST_FUNCTION_ARCSECH = AST_FUNCTION_ARCSEC + 1;
  

    /**
     * One of the possible {@link ASTNode} types.  Each {@link ASTNode} has
     * a type whose value is one of the elements of this enumeration.
     */
    public final static int AST_FUNCTION_ARCSIN = AST_FUNCTION_ARCSECH + 1;
  

    /**
     * One of the possible {@link ASTNode} types.  Each {@link ASTNode} has
     * a type whose value is one of the elements of this enumeration.
     */
    public final static int AST_FUNCTION_ARCSINH = AST_FUNCTION_ARCSIN + 1;
  

    /**
     * One of the possible {@link ASTNode} types.  Each {@link ASTNode} has
     * a type whose value is one of the elements of this enumeration.
     */
    public final static int AST_FUNCTION_ARCTAN = AST_FUNCTION_ARCSINH + 1;
  

    /**
     * One of the possible {@link ASTNode} types.  Each {@link ASTNode} has
     * a type whose value is one of the elements of this enumeration.
     */
    public final static int AST_FUNCTION_ARCTANH = AST_FUNCTION_ARCTAN + 1;
  

    /**
     * One of the possible {@link ASTNode} types.  Each {@link ASTNode} has
     * a type whose value is one of the elements of this enumeration.
     */
    public final static int AST_FUNCTION_CEILING = AST_FUNCTION_ARCTANH + 1;
  

    /**
     * One of the possible {@link ASTNode} types.  Each {@link ASTNode} has
     * a type whose value is one of the elements of this enumeration.
     */
    public final static int AST_FUNCTION_COS = AST_FUNCTION_CEILING + 1;
  

    /**
     * One of the possible {@link ASTNode} types.  Each {@link ASTNode} has
     * a type whose value is one of the elements of this enumeration.
     */
    public final static int AST_FUNCTION_COSH = AST_FUNCTION_COS + 1;
  

    /**
     * One of the possible {@link ASTNode} types.  Each {@link ASTNode} has
     * a type whose value is one of the elements of this enumeration.
     */
    public final static int AST_FUNCTION_COT = AST_FUNCTION_COSH + 1;
  

    /**
     * One of the possible {@link ASTNode} types.  Each {@link ASTNode} has
     * a type whose value is one of the elements of this enumeration.
     */
    public final static int AST_FUNCTION_COTH = AST_FUNCTION_COT + 1;
  

    /**
     * One of the possible {@link ASTNode} types.  Each {@link ASTNode} has
     * a type whose value is one of the elements of this enumeration.
     */
    public final static int AST_FUNCTION_CSC = AST_FUNCTION_COTH + 1;
  

    /**
     * One of the possible {@link ASTNode} types.  Each {@link ASTNode} has
     * a type whose value is one of the elements of this enumeration.
     */
    public final static int AST_FUNCTION_CSCH = AST_FUNCTION_CSC + 1;
  

    /**
     * One of the possible {@link ASTNode} types.  Each {@link ASTNode} has
     * a type whose value is one of the elements of this enumeration.
     */
    public final static int AST_FUNCTION_DELAY = AST_FUNCTION_CSCH + 1;
  

    /**
     * One of the possible {@link ASTNode} types.  Each {@link ASTNode} has
     * a type whose value is one of the elements of this enumeration.
     */
    public final static int AST_FUNCTION_EXP = AST_FUNCTION_DELAY + 1;
  

    /**
     * One of the possible {@link ASTNode} types.  Each {@link ASTNode} has
     * a type whose value is one of the elements of this enumeration.
     */
    public final static int AST_FUNCTION_FACTORIAL = AST_FUNCTION_EXP + 1;
  

    /**
     * One of the possible {@link ASTNode} types.  Each {@link ASTNode} has
     * a type whose value is one of the elements of this enumeration.
     */
    public final static int AST_FUNCTION_FLOOR = AST_FUNCTION_FACTORIAL + 1;
  

    /**
     * One of the possible {@link ASTNode} types.  Each {@link ASTNode} has
     * a type whose value is one of the elements of this enumeration.
     */
    public final static int AST_FUNCTION_LN = AST_FUNCTION_FLOOR + 1;
  

    /**
     * One of the possible {@link ASTNode} types.  Each {@link ASTNode} has
     * a type whose value is one of the elements of this enumeration.
     */
    public final static int AST_FUNCTION_LOG = AST_FUNCTION_LN + 1;
  

    /**
     * One of the possible {@link ASTNode} types.  Each {@link ASTNode} has
     * a type whose value is one of the elements of this enumeration.
     */
    public final static int AST_FUNCTION_PIECEWISE = AST_FUNCTION_LOG + 1;
  

    /**
     * One of the possible {@link ASTNode} types.  Each {@link ASTNode} has
     * a type whose value is one of the elements of this enumeration.
     */
    public final static int AST_FUNCTION_POWER = AST_FUNCTION_PIECEWISE + 1;
  

    /**
     * One of the possible {@link ASTNode} types.  Each {@link ASTNode} has
     * a type whose value is one of the elements of this enumeration.
     */
    public final static int AST_FUNCTION_ROOT = AST_FUNCTION_POWER + 1;
  

    /**
     * One of the possible {@link ASTNode} types.  Each {@link ASTNode} has
     * a type whose value is one of the elements of this enumeration.
     */
    public final static int AST_FUNCTION_SEC = AST_FUNCTION_ROOT + 1;
  

    /**
     * One of the possible {@link ASTNode} types.  Each {@link ASTNode} has
     * a type whose value is one of the elements of this enumeration.
     */
    public final static int AST_FUNCTION_SECH = AST_FUNCTION_SEC + 1;
  

    /**
     * One of the possible {@link ASTNode} types.  Each {@link ASTNode} has
     * a type whose value is one of the elements of this enumeration.
     */
    public final static int AST_FUNCTION_SIN = AST_FUNCTION_SECH + 1;
  

    /**
     * One of the possible {@link ASTNode} types.  Each {@link ASTNode} has
     * a type whose value is one of the elements of this enumeration.
     */
    public final static int AST_FUNCTION_SINH = AST_FUNCTION_SIN + 1;
  

    /**
     * One of the possible {@link ASTNode} types.  Each {@link ASTNode} has
     * a type whose value is one of the elements of this enumeration.
     */
    public final static int AST_FUNCTION_TAN = AST_FUNCTION_SINH + 1;
  

    /**
     * One of the possible {@link ASTNode} types.  Each {@link ASTNode} has
     * a type whose value is one of the elements of this enumeration.
     */
    public final static int AST_FUNCTION_TANH = AST_FUNCTION_TAN + 1;
  

    /**
     * One of the possible {@link ASTNode} types.  Each {@link ASTNode} has
     * a type whose value is one of the elements of this enumeration.
     */
    public final static int AST_LOGICAL_AND = AST_FUNCTION_TANH + 1;
  

    /**
     * One of the possible {@link ASTNode} types.  Each {@link ASTNode} has
     * a type whose value is one of the elements of this enumeration.
     */
    public final static int AST_LOGICAL_NOT = AST_LOGICAL_AND + 1;
  

    /**
     * One of the possible {@link ASTNode} types.  Each {@link ASTNode} has
     * a type whose value is one of the elements of this enumeration.
     */
    public final static int AST_LOGICAL_OR = AST_LOGICAL_NOT + 1;
  

    /**
     * One of the possible {@link ASTNode} types.  Each {@link ASTNode} has
     * a type whose value is one of the elements of this enumeration.
     */
    public final static int AST_LOGICAL_XOR = AST_LOGICAL_OR + 1;
  

    /**
     * One of the possible {@link ASTNode} types.  Each {@link ASTNode} has
     * a type whose value is one of the elements of this enumeration.
     */
    public final static int AST_RELATIONAL_EQ = AST_LOGICAL_XOR + 1;
  

    /**
     * One of the possible {@link ASTNode} types.  Each {@link ASTNode} has
     * a type whose value is one of the elements of this enumeration.
     */
    public final static int AST_RELATIONAL_GEQ = AST_RELATIONAL_EQ + 1;
  

    /**
     * One of the possible {@link ASTNode} types.  Each {@link ASTNode} has
     * a type whose value is one of the elements of this enumeration.
     */
    public final static int AST_RELATIONAL_GT = AST_RELATIONAL_GEQ + 1;
  

    /**
     * One of the possible {@link ASTNode} types.  Each {@link ASTNode} has
     * a type whose value is one of the elements of this enumeration.
     */
    public final static int AST_RELATIONAL_LEQ = AST_RELATIONAL_GT + 1;
  

    /**
     * One of the possible {@link ASTNode} types.  Each {@link ASTNode} has
     * a type whose value is one of the elements of this enumeration.
     */
    public final static int AST_RELATIONAL_LT = AST_RELATIONAL_LEQ + 1;
  

    /**
     * One of the possible {@link ASTNode} types.  Each {@link ASTNode} has
     * a type whose value is one of the elements of this enumeration.
     */
    public final static int AST_RELATIONAL_NEQ = AST_RELATIONAL_LT + 1;
  

    /**
     * One of the possible {@link ASTNode} types.  Each {@link ASTNode} has
     * a type whose value is one of the elements of this enumeration.
     */
    public final static int AST_CONSTRUCTOR_OTHERWISE = AST_RELATIONAL_NEQ + 1;


    /**
     * One of the possible {@link ASTNode} types.  Each {@link ASTNode} has
     * a type whose value is one of the elements of this enumeration.
     */
    public final static int AST_CONSTRUCTOR_PIECE = AST_CONSTRUCTOR_OTHERWISE + 1;


    /**
     * One of the possible {@link ASTNode} types.  Each {@link ASTNode} has
     * a type whose value is one of the elements of this enumeration.
     */
    public final static int AST_QUALIFIER_BVAR = AST_CONSTRUCTOR_PIECE + 1;


    /**
     * One of the possible {@link ASTNode} types.  Each {@link ASTNode} has
     * a type whose value is one of the elements of this enumeration.
     */
    public final static int AST_QUALIFIER_DEGREE = AST_QUALIFIER_BVAR + 1;


    /**
     * One of the possible {@link ASTNode} types.  Each {@link ASTNode} has
     * a type whose value is one of the elements of this enumeration.
     */
    public final static int AST_QUALIFIER_LOGBASE = AST_QUALIFIER_DEGREE + 1;


    /**
     * One of the possible {@link ASTNode} types.  Each {@link ASTNode} has
     * a type whose value is one of the elements of this enumeration.
     */
    public final static int AST_SEMANTICS = AST_QUALIFIER_LOGBASE + 1;


    /**
     * One of the possible {@link ASTNode} types.  Each {@link ASTNode} has
     * a type whose value is one of the elements of this enumeration.
     */
    public final static int AST_UNKNOWN = AST_RELATIONAL_NEQ + 1;


    /**
     * One of the possible {@link ASTNode} types.  Each {@link ASTNode} has
     * a type whose value is one of the elements of this enumeration.
     */
    public final static int AST_ORIGINATES_IN_PACKAGE = AST_UNKNOWN + 1;


    // ParseLogType_t

    /**
     * Parse <code>log(x)</code> as the base-10 logarithm of <code>x</code>.
     */
    public final static int L3P_PARSE_LOG_AS_LOG10 = 0;


    /**
     * Parse <code>log(x)</code> as the natural logarithm of <code>x</code>.
     */
    public final static int L3P_PARSE_LOG_AS_LN = 1;


    /**
     * Refuse to parse <code>log(x)</code> at all, and set an error message 
     * telling the user to use <code>log10(x)</code>, <code>ln(x)</code>,
     * or <code>log(base, x)</code> instead.
     */
    public final static int L3P_PARSE_LOG_AS_ERROR = 2;


    /**
     * Collapse unary minuses where possible when parsing text-string
     * formulas.
     */
    public final static boolean L3P_COLLAPSE_UNARY_MINUS = true;


    /**
     * Retain unary minuses in the AST representation when parsing
     * text-string formulas.
     */
    public final static boolean L3P_EXPAND_UNARY_MINUS = false;


    /**
     * Parse units in text-string formulas when parsing
     * text-string formulas.
     */
    public final static boolean L3P_PARSE_UNITS = true;


    /**
     * Do not recognize units in text-string formulas&mdash;treat them as
     * errors.
     */
    public final static boolean L3P_NO_UNITS = false;


    /**
     * Recognize 'avogadro' as an SBML Level 3 symbol when parsing
     * text-string formulas.
     */
    public final static boolean L3P_AVOGADRO_IS_CSYMBOL = true;


    /**
     * Do not treat 'avogadro' specially&mdash;consider it a plain symbol
     * name when parsing text-string formulas.
     */
    public final static boolean L3P_AVOGADRO_IS_NAME = false;


    /**
     * Treat all forms of built-in functions as referencing that function,
     * regardless of the capitalization of that string.
     */
    public final static boolean L3P_COMPARE_BUILTINS_CASE_INSENSITIVE = true;


    /**
     * Treat only the all-lower-case form of built-in functions as
     * referencing that function, and all other forms of capitalization of
     * that string as referencing user-defined functions or values.
     */
    public final static boolean L3P_COMPARE_BUILTINS_CASE_SENSITIVE = true;


    // L3ParserGrammarLineType_t

    /**
     */
    public final static int INFIX_SYNTAX_NAMED_SQUARE_BRACKETS = 0;
    public final static int INFIX_SYNTAX_CURLY_BRACES = INFIX_SYNTAX_NAMED_SQUARE_BRACKETS + 1;
    public final static int INFIX_SYNTAX_CURLY_BRACES_SEMICOLON = INFIX_SYNTAX_CURLY_BRACES + 1;


    // XMLErrorCode_t


    /**
     * A value in the enumeration of all the error and warning codes
     * returned by the XML layer in libSBML.  Please consult the
     * documentation for {@link XMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int XMLUnknownError = 0;
  

    /**
     * A value in the enumeration of all the error and warning codes
     * returned by the XML layer in libSBML.  Please consult the
     * documentation for {@link XMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int XMLOutOfMemory = 1;
  

    /**
     * A value in the enumeration of all the error and warning codes
     * returned by the XML layer in libSBML.  Please consult the
     * documentation for {@link XMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int XMLFileUnreadable = 2;
  

    /**
     * A value in the enumeration of all the error and warning codes
     * returned by the XML layer in libSBML.  Please consult the
     * documentation for {@link XMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int XMLFileUnwritable = 3;
  

    /**
     * A value in the enumeration of all the error and warning codes
     * returned by the XML layer in libSBML.  Please consult the
     * documentation for {@link XMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int XMLFileOperationError = 4;
  

    /**
     * A value in the enumeration of all the error and warning codes
     * returned by the XML layer in libSBML.  Please consult the
     * documentation for {@link XMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int XMLNetworkAccessError = 5;
  

    /**
     * A value in the enumeration of all the error and warning codes
     * returned by the XML layer in libSBML.  Please consult the
     * documentation for {@link XMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int InternalXMLParserError = 101;
  

    /**
     * A value in the enumeration of all the error and warning codes
     * returned by the XML layer in libSBML.  Please consult the
     * documentation for {@link XMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int UnrecognizedXMLParserCode = 102;
  

    /**
     * A value in the enumeration of all the error and warning codes
     * returned by the XML layer in libSBML.  Please consult the
     * documentation for {@link XMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int XMLTranscoderError = 103;
  

    /**
     * A value in the enumeration of all the error and warning codes
     * returned by the XML layer in libSBML.  Please consult the
     * documentation for {@link XMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int MissingXMLDecl = 1001;
  

    /**
     * A value in the enumeration of all the error and warning codes
     * returned by the XML layer in libSBML.  Please consult the
     * documentation for {@link XMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int MissingXMLEncoding = 1002;
  

    /**
     * A value in the enumeration of all the error and warning codes
     * returned by the XML layer in libSBML.  Please consult the
     * documentation for {@link XMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int BadXMLDecl = 1003;
  

    /**
     * A value in the enumeration of all the error and warning codes
     * returned by the XML layer in libSBML.  Please consult the
     * documentation for {@link XMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int BadXMLDOCTYPE = 1004;
  

    /**
     * A value in the enumeration of all the error and warning codes
     * returned by the XML layer in libSBML.  Please consult the
     * documentation for {@link XMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int InvalidCharInXML = 1005;
  

    /**
     * A value in the enumeration of all the error and warning codes
     * returned by the XML layer in libSBML.  Please consult the
     * documentation for {@link XMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int BadlyFormedXML = 1006;
  

    /**
     * A value in the enumeration of all the error and warning codes
     * returned by the XML layer in libSBML.  Please consult the
     * documentation for {@link XMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int UnclosedXMLToken = 1007;
  

    /**
     * A value in the enumeration of all the error and warning codes
     * returned by the XML layer in libSBML.  Please consult the
     * documentation for {@link XMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int InvalidXMLConstruct = 1008;
  

    /**
     * A value in the enumeration of all the error and warning codes
     * returned by the XML layer in libSBML.  Please consult the
     * documentation for {@link XMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int XMLTagMismatch = 1009;
  

    /**
     * A value in the enumeration of all the error and warning codes
     * returned by the XML layer in libSBML.  Please consult the
     * documentation for {@link XMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int DuplicateXMLAttribute = 1010;
  

    /**
     * A value in the enumeration of all the error and warning codes
     * returned by the XML layer in libSBML.  Please consult the
     * documentation for {@link XMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int UndefinedXMLEntity = 1011;
  

    /**
     * A value in the enumeration of all the error and warning codes
     * returned by the XML layer in libSBML.  Please consult the
     * documentation for {@link XMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int BadProcessingInstruction = 1012;
  

    /**
     * A value in the enumeration of all the error and warning codes
     * returned by the XML layer in libSBML.  Please consult the
     * documentation for {@link XMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int BadXMLPrefix = 1013;
  

    /**
     * A value in the enumeration of all the error and warning codes
     * returned by the XML layer in libSBML.  Please consult the
     * documentation for {@link XMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int BadXMLPrefixValue = 1014;
  

    /**
     * A value in the enumeration of all the error and warning codes
     * returned by the XML layer in libSBML.  Please consult the
     * documentation for {@link XMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int MissingXMLRequiredAttribute = 1015;
  

    /**
     * A value in the enumeration of all the error and warning codes
     * returned by the XML layer in libSBML.  Please consult the
     * documentation for {@link XMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int XMLAttributeTypeMismatch = 1016;
  

    /**
     * A value in the enumeration of all the error and warning codes
     * returned by the XML layer in libSBML.  Please consult the
     * documentation for {@link XMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int XMLBadUTF8Content = 1017;
  

    /**
     * A value in the enumeration of all the error and warning codes
     * returned by the XML layer in libSBML.  Please consult the
     * documentation for {@link XMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int MissingXMLAttributeValue = 1018;
  

    /**
     * A value in the enumeration of all the error and warning codes
     * returned by the XML layer in libSBML.  Please consult the
     * documentation for {@link XMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int BadXMLAttributeValue = 1019;
  

    /**
     * A value in the enumeration of all the error and warning codes
     * returned by the XML layer in libSBML.  Please consult the
     * documentation for {@link XMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int BadXMLAttribute = 1020;
  

    /**
     * A value in the enumeration of all the error and warning codes
     * returned by the XML layer in libSBML.  Please consult the
     * documentation for {@link XMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int UnrecognizedXMLElement = 1021;
  

    /**
     * A value in the enumeration of all the error and warning codes
     * returned by the XML layer in libSBML.  Please consult the
     * documentation for {@link XMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int BadXMLComment = 1022;
  

    /**
     * A value in the enumeration of all the error and warning codes
     * returned by the XML layer in libSBML.  Please consult the
     * documentation for {@link XMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int BadXMLDeclLocation = 1023;
  

    /**
     * A value in the enumeration of all the error and warning codes
     * returned by the XML layer in libSBML.  Please consult the
     * documentation for {@link XMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int XMLUnexpectedEOF = 1024;
  

    /**
     * A value in the enumeration of all the error and warning codes
     * returned by the XML layer in libSBML.  Please consult the
     * documentation for {@link XMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int BadXMLIDValue = 1025;
  

    /**
     * A value in the enumeration of all the error and warning codes
     * returned by the XML layer in libSBML.  Please consult the
     * documentation for {@link XMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int BadXMLIDRef = 1026;
  

    /**
     * A value in the enumeration of all the error and warning codes
     * returned by the XML layer in libSBML.  Please consult the
     * documentation for {@link XMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int UninterpretableXMLContent = 1027;
  

    /**
     * A value in the enumeration of all the error and warning codes
     * returned by the XML layer in libSBML.  Please consult the
     * documentation for {@link XMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int BadXMLDocumentStructure = 1028;
  

    /**
     * A value in the enumeration of all the error and warning codes
     * returned by the XML layer in libSBML.  Please consult the
     * documentation for {@link XMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int InvalidAfterXMLContent = 1029;
  

    /**
     * A value in the enumeration of all the error and warning codes
     * returned by the XML layer in libSBML.  Please consult the
     * documentation for {@link XMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int XMLExpectedQuotedString = 1030;
  

    /**
     * A value in the enumeration of all the error and warning codes
     * returned by the XML layer in libSBML.  Please consult the
     * documentation for {@link XMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int XMLEmptyValueNotPermitted = 1031;
  

    /**
     * A value in the enumeration of all the error and warning codes
     * returned by the XML layer in libSBML.  Please consult the
     * documentation for {@link XMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int XMLBadNumber = 1032;
  

    /**
     * A value in the enumeration of all the error and warning codes
     * returned by the XML layer in libSBML.  Please consult the
     * documentation for {@link XMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int XMLBadColon = 1033;
  

    /**
     * A value in the enumeration of all the error and warning codes
     * returned by the XML layer in libSBML.  Please consult the
     * documentation for {@link XMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int MissingXMLElements = 1034;
  

    /**
     * A value in the enumeration of all the error and warning codes
     * returned by the XML layer in libSBML.  Please consult the
     * documentation for {@link XMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int XMLContentEmpty = 1035;
  

    /**
     * A value in the enumeration of all the error and warning codes
     * returned by the XML layer in libSBML.  Please consult the
     * documentation for {@link XMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int XMLErrorCodesUpperBound = 9999;

    // XMLErrorCategory_t 
  

    /**
     * Category code for errors in the XML layer.
     * <p>
     * This code has the following meaning: A problem involving the libSBML
     * software itself or the underlying XML parser.  This almost certainly
     * indicates a software defect (i.e., bug) in libSBML.  Please report
     * instances of this to the libSBML developers.
     */
    public final static int LIBSBML_CAT_INTERNAL = 0;
  

    /**
     * Category code for errors in the XML layer.
     * <p>
     * This code has the following meaning: A problem reported by the
     * operating system, such as an inability to read or write a file.
     * This indicates something that is not a program error but is outside
     * of the control of libSBML.
     */
    public final static int LIBSBML_CAT_SYSTEM = LIBSBML_CAT_INTERNAL + 1;
  

    /**
     * Category code for errors in the XML layer.
     * <p>
     * This code has the following meaning: A problem in the XML content
     * itself.  This usually arises from malformed XML or the use of
     * constructs not permitted in SBML.
     */
    public final static int LIBSBML_CAT_XML = LIBSBML_CAT_SYSTEM + 1;

    // XMLErrorSeverity_t 
  

    /**
     * Severity code for errors in the XML layer.
     * <p>
     * This code has the following meaning: The error is actually
     * informational and not necessarily a serious problem.
     */
    public final static int LIBSBML_SEV_INFO = 0;
  

    /**
     * Severity code for errors in the XML layer.
     * <p>
     * This code has the following meaning: The error object represents a
     * problem that is not serious enough to necessarily stop the problem,
     * but applications should take note of the problem and evaluate what
     * its implications may be.
     */
    public final static int LIBSBML_SEV_WARNING = LIBSBML_SEV_INFO + 1;
  

    /**
     * Severity code for errors in the XML layer.
     * <p>
     * This code has the following meaning: The error object represents a
     * serious error.  The application may continue running but it is
     * unlikely to be able to continue processing the same XML file or data
     * stream. 
     */
    public final static int LIBSBML_SEV_ERROR = LIBSBML_SEV_WARNING + 1;
  

    /**
     * Severity code for errors in the XML layer.
     * <p>
     * This code has the following meaning: A serious error occurred, such
     * as an out-of-memory condition, and the software should terminate
     * immediately.
     */
    public final static int LIBSBML_SEV_FATAL = LIBSBML_SEV_ERROR + 1;


    // XMLErrorSeverityOverride_t 

    /**
     * Severity override code for errors logged in the XML layer.
     * <p>
     * XMLErrorLog can be configured whether to log errors or not log them.
     * This code has the following meaning: log errors in the error log, as
     * normal.
     */
    public final static int LIBSBML_OVERRIDE_DISABLED = 0;


    /**
     * Severity override code for errors logged in the XML layer.
     * <p>
     * XMLErrorLog can be configured whether to log errors or not log them.
     * This code has the following meaning: disable all error logging.
     */
    public final static int LIBSBML_OVERRIDE_DONT_LOG = LIBSBML_OVERRIDE_DISABLED + 1;


    /**
     * Severity override code for errors logged in the XML layer.
     * <p>
     * XMLErrorLog can be configured whether to log errors or not log them.
     * This code has the following meaning: log all errors as warnings instead
     * of actual errors.
     */
    public final static int LIBSBML_OVERRIDE_WARNING = LIBSBML_OVERRIDE_DONT_LOG + 1;


    // SBMLErrorCode_t 
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int UnknownError = 10000;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int NotUTF8 = 10101;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int UnrecognizedElement = 10102;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int NotSchemaConformant = 10103;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int L3NotSchemaConformant = 10104;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int InvalidMathElement = 10201;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int DisallowedMathMLSymbol = 10202;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int DisallowedMathMLEncodingUse = 10203;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int DisallowedDefinitionURLUse = 10204;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int BadCsymbolDefinitionURLValue = 10205;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int DisallowedMathTypeAttributeUse = 10206;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int DisallowedMathTypeAttributeValue = 10207;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int LambdaOnlyAllowedInFunctionDef = 10208;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int BooleanOpsNeedBooleanArgs = 10209;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int NumericOpsNeedNumericArgs = 10210;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int ArgsToEqNeedSameType = 10211;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int PiecewiseNeedsConsistentTypes = 10212;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int PieceNeedsBoolean = 10213;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int ApplyCiMustBeUserFunction = 10214;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int ApplyCiMustBeModelComponent = 10215;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int KineticLawParametersAreLocalOnly = 10216;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int MathResultMustBeNumeric = 10217;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int OpsNeedCorrectNumberOfArgs = 10218;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int InvalidNoArgsPassedToFunctionDef = 10219;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int DisallowedMathUnitsUse = 10220;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int InvalidUnitsValue = 10221;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int DuplicateComponentId = 10301;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int DuplicateUnitDefinitionId = 10302;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int DuplicateLocalParameterId = 10303;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int MultipleAssignmentOrRateRules = 10304;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int MultipleEventAssignmentsForId = 10305;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int EventAndAssignmentRuleForId = 10306;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int DuplicateMetaId = 10307;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int InvalidSBOTermSyntax = 10308;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int InvalidMetaidSyntax = 10309;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int InvalidIdSyntax = 10310;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int InvalidUnitIdSyntax = 10311;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int InvalidNameSyntax = 10312;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int MissingAnnotationNamespace = 10401;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int DuplicateAnnotationNamespaces = 10402;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int SBMLNamespaceInAnnotation = 10403;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int MultipleAnnotations = 10404;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int InconsistentArgUnits = 10501;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int InconsistentKineticLawUnitsL3 = 10503;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int AssignRuleCompartmentMismatch = 10511;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int AssignRuleSpeciesMismatch = 10512;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int AssignRuleParameterMismatch = 10513;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int AssignRuleStoichiometryMismatch = 10514;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int InitAssignCompartmenMismatch = 10521;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int InitAssignSpeciesMismatch = 10522;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int InitAssignParameterMismatch = 10523;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int InitAssignStoichiometryMismatch = 10524;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int RateRuleCompartmentMismatch = 10531;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int RateRuleSpeciesMismatch = 10532;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int RateRuleParameterMismatch = 10533;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int RateRuleStoichiometryMismatch = 10534;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int KineticLawNotSubstancePerTime = 10541;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int SpeciesInvalidExtentUnits = 10542;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int DelayUnitsNotTime = 10551;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int EventAssignCompartmentMismatch = 10561;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int EventAssignSpeciesMismatch = 10562;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int EventAssignParameterMismatch = 10563;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int EventAssignStoichiometryMismatch = 10564;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int PriorityUnitsNotDimensionless = 10565;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int OverdeterminedSystem = 10601;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int UpperUnitBound = 10599;


    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int InvalidModelSBOTerm = 10701;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int InvalidFunctionDefSBOTerm = 10702;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int InvalidParameterSBOTerm = 10703;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int InvalidInitAssignSBOTerm = 10704;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int InvalidRuleSBOTerm = 10705;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int InvalidConstraintSBOTerm = 10706;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int InvalidReactionSBOTerm = 10707;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int InvalidSpeciesReferenceSBOTerm = 10708;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int InvalidKineticLawSBOTerm = 10709;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int InvalidEventSBOTerm = 10710;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int InvalidEventAssignmentSBOTerm = 10711;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int InvalidCompartmentSBOTerm = 10712;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int InvalidSpeciesSBOTerm = 10713;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int InvalidCompartmentTypeSBOTerm = 10714;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int InvalidSpeciesTypeSBOTerm = 10715;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int InvalidTriggerSBOTerm = 10716;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int InvalidDelaySBOTerm = 10717;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int NotesNotInXHTMLNamespace = 10801;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int NotesContainsXMLDecl = 10802;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int NotesContainsDOCTYPE = 10803;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int InvalidNotesContent = 10804;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int OnlyOneNotesElementAllowed = 10805;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int InvalidNamespaceOnSBML = 20101;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int MissingOrInconsistentLevel = 20102;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int MissingOrInconsistentVersion = 20103;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int PackageNSMustMatch = 20104;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int LevelPositiveInteger = 20105;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int VersionPositiveInteger = 20106;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int AllowedAttributesOnSBML = 20108;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int MissingModel = 20201;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int L3PackageOnLowerSBML = 20109;


    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int IncorrectOrderInModel = 20202;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int EmptyListElement = 20203;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int NeedCompartmentIfHaveSpecies = 20204;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int OneOfEachListOf = 20205;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int OnlyFuncDefsInListOfFuncDefs = 20206;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int OnlyUnitDefsInListOfUnitDefs = 20207;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int OnlyCompartmentsInListOfCompartments = 20208;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int OnlySpeciesInListOfSpecies = 20209;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int OnlyParametersInListOfParameters = 20210;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int OnlyInitAssignsInListOfInitAssigns = 20211;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int OnlyRulesInListOfRules = 20212;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int OnlyConstraintsInListOfConstraints = 20213;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int OnlyReactionsInListOfReactions = 20214;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int OnlyEventsInListOfEvents = 20215;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int L3ConversionFactorOnModel = 20216;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int L3TimeUnitsOnModel = 20217;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int L3VolumeUnitsOnModel = 20218;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int L3AreaUnitsOnModel = 20219;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int L3LengthUnitsOnModel = 20220;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int L3ExtentUnitsOnModel = 20221;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int AllowedAttributesOnModel = 20222;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int AllowedAttributesOnListOfFuncs = 20223;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int AllowedAttributesOnListOfUnitDefs = 20224;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int AllowedAttributesOnListOfComps = 20225;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int AllowedAttributesOnListOfSpecies = 20226;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int AllowedAttributesOnListOfParams = 20227;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int AllowedAttributesOnListOfInitAssign = 20228;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int AllowedAttributesOnListOfRules = 20229;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int AllowedAttributesOnListOfConstraints = 20230;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int AllowedAttributesOnListOfReactions = 20231;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int AllowedAttributesOnListOfEvents = 20232;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int FunctionDefMathNotLambda = 20301;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int InvalidApplyCiInLambda = 20302;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int RecursiveFunctionDefinition = 20303;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int InvalidCiInLambda = 20304;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int InvalidFunctionDefReturnType = 20305;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int OneMathElementPerFunc = 20306;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int AllowedAttributesOnFunc = 20307;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int InvalidUnitDefId = 20401;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int InvalidSubstanceRedefinition = 20402;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int InvalidLengthRedefinition = 20403;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int InvalidAreaRedefinition = 20404;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int InvalidTimeRedefinition = 20405;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int InvalidVolumeRedefinition = 20406;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int VolumeLitreDefExponentNotOne = 20407;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int VolumeMetreDefExponentNot3 = 20408;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int EmptyListOfUnits = 20409;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int InvalidUnitKind = 20410;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int OffsetNoLongerValid = 20411;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int CelsiusNoLongerValid = 20412;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int EmptyUnitListElement = 20413;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int OneListOfUnitsPerUnitDef = 20414;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int OnlyUnitsInListOfUnits = 20415;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int AllowedAttributesOnUnitDefinition = 20419;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int AllowedAttributesOnListOfUnits = 20420;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int AllowedAttributesOnUnit = 20421;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int ZeroDimensionalCompartmentSize = 20501;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int ZeroDimensionalCompartmentUnits = 20502;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int ZeroDimensionalCompartmentConst = 20503;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int UndefinedOutsideCompartment = 20504;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int RecursiveCompartmentContainment = 20505;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int ZeroDCompartmentContainment = 20506;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int Invalid1DCompartmentUnits = 20507;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int Invalid2DCompartmentUnits = 20508;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int Invalid3DCompartmentUnits = 20509;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int InvalidCompartmentTypeRef = 20510;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int OneDimensionalCompartmentUnits = 20511;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int TwoDimensionalCompartmentUnits = 20512;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int ThreeDimensionalCompartmentUnits = 20513;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int AllowedAttributesOnCompartment = 20517;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int NoUnitsOnCompartment = 20518;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int InvalidSpeciesCompartmentRef = 20601;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int HasOnlySubsNoSpatialUnits = 20602;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int NoSpatialUnitsInZeroD = 20603;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int NoConcentrationInZeroD = 20604;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int SpatialUnitsInOneD = 20605;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int SpatialUnitsInTwoD = 20606;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int SpatialUnitsInThreeD = 20607;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int InvalidSpeciesSusbstanceUnits = 20608;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int BothAmountAndConcentrationSet = 20609;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int NonBoundarySpeciesAssignedAndUsed = 20610;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int NonConstantSpeciesUsed = 20611;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int InvalidSpeciesTypeRef = 20612;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int MultSpeciesSameTypeInCompartment = 20613;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int MissingSpeciesCompartment = 20614;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int SpatialSizeUnitsRemoved = 20615;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int SubstanceUnitsOnSpecies = 20616;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int ConversionFactorOnSpecies = 20617;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int AllowedAttributesOnSpecies = 20623;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int InvalidParameterUnits = 20701;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int ParameterUnits = 20702;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int ConversionFactorMustConstant = 20705;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int AllowedAttributesOnParameter = 20706;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int InvalidInitAssignSymbol = 20801;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int MultipleInitAssignments = 20802;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int InitAssignmentAndRuleForSameId = 20803;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int OneMathElementPerInitialAssign = 20804;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int AllowedAttributesOnInitialAssign = 20805;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int InvalidAssignRuleVariable = 20901;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int InvalidRateRuleVariable = 20902;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int AssignmentToConstantEntity = 20903;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int RateRuleForConstantEntity = 20904;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int RepeatedRule10304 = 20905;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int CircularRuleDependency = 20906;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int OneMathElementPerRule = 20907;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int AllowedAttributesOnAssignRule = 20908;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int AllowedAttributesOnRateRule = 20909;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int AllowedAttributesOnAlgRule = 20910;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int ConstraintMathNotBoolean = 21001;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int IncorrectOrderInConstraint = 21002;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int ConstraintNotInXHTMLNamespace = 21003;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int ConstraintContainsXMLDecl = 21004;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int ConstraintContainsDOCTYPE = 21005;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int InvalidConstraintContent = 21006;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int OneMathElementPerConstraint = 21007;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int OneMessageElementPerConstraint = 21008;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int AllowedAttributesOnConstraint = 21009;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int NoReactantsOrProducts = 21101;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int IncorrectOrderInReaction = 21102;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int EmptyListInReaction = 21103;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int InvalidReactantsProductsList = 21104;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int InvalidModifiersList = 21105;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int OneSubElementPerReaction = 21106;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int CompartmentOnReaction = 21107;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int AllowedAttributesOnReaction = 21110;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int InvalidSpeciesReference = 21111;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int RepeatedRule20611 = 21112;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int BothStoichiometryAndMath = 21113;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int AllowedAttributesOnSpeciesReference = 21116;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int AllowedAttributesOnModifier = 21117;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int UndeclaredSpeciesRef = 21121;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int IncorrectOrderInKineticLaw = 21122;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int EmptyListInKineticLaw = 21123;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int NonConstantLocalParameter = 21124;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int SubsUnitsNoLongerValid = 21125;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int TimeUnitsNoLongerValid = 21126;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int OneListOfPerKineticLaw = 21127;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int OnlyLocalParamsInListOfLocalParams = 21128;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int AllowedAttributesOnListOfLocalParam = 21129;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int OneMathPerKineticLaw = 21130;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int UndeclaredSpeciesInStoichMath = 21131;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int AllowedAttributesOnKineticLaw = 21132;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int AllowedAttributesOnListOfSpeciesRef = 21150;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int AllowedAttributesOnListOfMods = 21151;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int AllowedAttributesOnLocalParameter = 21172;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int MissingTriggerInEvent = 21201;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int TriggerMathNotBoolean = 21202;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int MissingEventAssignment = 21203;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int TimeUnitsEvent = 21204;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int IncorrectOrderInEvent = 21205;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int ValuesFromTriggerTimeNeedDelay = 21206;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int DelayNeedsValuesFromTriggerTime = 21207;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int OneMathPerTrigger = 21209;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int OneMathPerDelay = 21210;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int InvalidEventAssignmentVariable = 21211;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int EventAssignmentForConstantEntity = 21212;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int OneMathPerEventAssignment = 21213;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int AllowedAttributesOnEventAssignment = 21214;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int OnlyOneDelayPerEvent = 21221;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int OneListOfEventAssignmentsPerEvent = 21222;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int OnlyEventAssignInListOfEventAssign = 21223;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int AllowedAttributesOnListOfEventAssign = 21224;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int AllowedAttributesOnEvent = 21225;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int AllowedAttributesOnTrigger = 21226;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int AllowedAttributesOnDelay = 21227;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int PersistentNotBoolean = 21228;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int InitialValueNotBoolean = 21229;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int OnlyOnePriorityPerEvent = 21230;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int OneMathPerPriority = 21231;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int AllowedAttributesOnPriority = 21232;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int GeneralWarningNotSpecified = 29999;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int CompartmentShouldHaveSize = 80501;
  
 
    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int SpeciesShouldHaveValue = 80601;


    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int ParameterShouldHaveUnits = 80701;


    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int LocalParameterShadowsId = 81121;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int LibSBMLAdditionalCodesLowerBound = 90000;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int CannotConvertToL1V1 = 90001;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int NoEventsInL1 = 91001;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int NoFunctionDefinitionsInL1 = 91002;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int NoConstraintsInL1 = 91003;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int NoInitialAssignmentsInL1 = 91004;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int NoSpeciesTypesInL1 = 91005;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int NoCompartmentTypeInL1 = 91006;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int NoNon3DCompartmentsInL1 = 91007;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int NoFancyStoichiometryMathInL1 = 91008;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int NoNonIntegerStoichiometryInL1 = 91009;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int NoUnitMultipliersOrOffsetsInL1 = 91010;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int SpeciesCompartmentRequiredInL1 = 91011;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int NoSpeciesSpatialSizeUnitsInL1 = 91012;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int NoSBOTermsInL1 = 91013;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int StrictUnitsRequiredInL1 = 91014;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int ConversionFactorNotInL1 = 91015;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int CompartmentNotOnL1Reaction = 91016;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int ExtentUnitsNotSubstance = 91017;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int GlobalUnitsNotDeclared = 91018;


    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int HasOnlySubstanceUnitsNotinL1 = 91019;


    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int AvogadroNotSupported = 91020;


    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int NoConstraintsInL2v1 = 92001;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int NoInitialAssignmentsInL2v1 = 92002;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int NoSpeciesTypeInL2v1 = 92003;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int NoCompartmentTypeInL2v1 = 92004;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int NoSBOTermsInL2v1 = 92005;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int NoIdOnSpeciesReferenceInL2v1 = 92006;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int NoDelayedEventAssignmentInL2v1 = 92007;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int StrictUnitsRequiredInL2v1 = 92008;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int IntegerSpatialDimensions = 92009;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int StoichiometryMathNotYetSupported = 92010;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int PriorityLostFromL3 = 92011;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int NonPersistentNotSupported = 92012;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int InitialValueFalseEventNotSupported = 92013;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int SBOTermNotUniversalInL2v2 = 93001;

  
    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int NoUnitOffsetInL2v2 = 93002;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int NoKineticLawTimeUnitsInL2v2 = 93003;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int NoKineticLawSubstanceUnitsInL2v2 = 93004;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int NoDelayedEventAssignmentInL2v2 = 93005;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int ModelSBOBranchChangedBeyondL2v2 = 93006;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int StrictUnitsRequiredInL2v2 = 93007;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int StrictSBORequiredInL2v2 = 93008;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int DuplicateAnnotationInvalidInL2v2 = 93009;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int NoUnitOffsetInL2v3 = 94001;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int NoKineticLawTimeUnitsInL2v3 = 94002;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int NoKineticLawSubstanceUnitsInL2v3 = 94003;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int NoSpeciesSpatialSizeUnitsInL2v3 = 94004;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int NoEventTimeUnitsInL2v3 = 94005;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int NoDelayedEventAssignmentInL2v3 = 94006;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int ModelSBOBranchChangedBeyondL2v3 = 94007;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int StrictUnitsRequiredInL2v3 = 94008;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int StrictSBORequiredInL2v3 = 94009;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int DuplicateAnnotationInvalidInL2v3 = 94010;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int NoUnitOffsetInL2v4 = 95001;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int NoKineticLawTimeUnitsInL2v4 = 95002;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int NoKineticLawSubstanceUnitsInL2v4 = 95003;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int NoSpeciesSpatialSizeUnitsInL2v4 = 95004;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int NoEventTimeUnitsInL2v4 = 95005;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int ModelSBOBranchChangedInL2v4 = 95006;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int DuplicateAnnotationInvalidInL2v4 = 95007;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int NoSpeciesTypeInL3v1 = 96001;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int NoCompartmentTypeInL3v1 = 96002;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int NoUnitOffsetInL3v1 = 96003;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int NoKineticLawTimeUnitsInL3v1 = 96004;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int NoKineticLawSubstanceUnitsInL3v1 = 96005;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int NoSpeciesSpatialSizeUnitsInL3v1 = 96006;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int NoEventTimeUnitsInL3v1 = 96007;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int ModelSBOBranchChangedInL3v1 = 96008;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int DuplicateAnnotationInvalidInL3v1 = 96009;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int NoCompartmentOutsideInL3v1 = 96010;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int NoStoichiometryMathInL3v1 = 96011;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int InvalidSBMLLevelVersion = 99101;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int AnnotationNotesNotAllowedLevel1 = 99104;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int InvalidRuleOrdering = 99106;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int RequiredPackagePresent = 99107;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int UnrequiredPackagePresent = 99108;

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int PackageRequiredShouldBeFalse = 99109;


    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int SubsUnitsAllowedInKL = 99127;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int TimeUnitsAllowedInKL = 99128;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int FormulaInLevel1KL = 99129;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int L3SubstanceUnitsOnModel = 99130;


    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int TimeUnitsRemoved = 99206;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int BadMathML = 99219;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int FailedMathMLReadOfDouble = 99220;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int FailedMathMLReadOfInteger = 99221;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int FailedMathMLReadOfExponential = 99222;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int FailedMathMLReadOfRational = 99223;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int BadMathMLNodeType = 99224;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int InvalidMathMLAttribute = 99225;


    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int NoTimeSymbolInFunctionDef = 99301;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int NoBodyInFunctionDef = 99302;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int DanglingUnitSIdRef = 99303;


    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int RDFMissingAboutTag = 99401;


    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int RDFEmptyAboutTag = 99402;


    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int RDFAboutTagNotMetaid = 99403;


    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int RDFNotCompleteModelHistory = 99404;


    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int RDFNotModelHistory = 99405;


    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int AnnotationNotElement = 99406;


    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int InconsistentArgUnitsWarnings = 99502;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int InconsistentPowerUnitsWarnings = 99503;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int InconsistentExponUnitsWarnings = 99504;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int UndeclaredUnits = 99505;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int UndeclaredTimeUnitsL3 = 99506;

  
    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int UndeclaredExtentUnitsL3 = 99507;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int UndeclaredObjectUnitsL3 = 99508;


    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int UnrecognisedSBOTerm = 99701;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int ObseleteSBOTerm = 99702;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int IncorrectCompartmentSpatialDimensions = 99901;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int CompartmentTypeNotValidAttribute = 99902;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int ConstantNotValidAttribute = 99903;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int MetaIdNotValidAttribute = 99904;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int SBOTermNotValidAttributeBeforeL2V3 = 99905;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int InvalidL1CompartmentUnits = 99906;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int L1V1CompartmentVolumeReqd = 99907;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int CompartmentTypeNotValidComponent = 99908;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int ConstraintNotValidComponent = 99909;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int EventNotValidComponent = 99910;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int SBOTermNotValidAttributeBeforeL2V2 = 99911;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int FuncDefNotValidComponent = 99912;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int InitialAssignNotValidComponent = 99913;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int VariableNotValidAttribute = 99914;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int UnitsNotValidAttribute = 99915;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int ConstantSpeciesNotValidAttribute = 99916;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int SpatialSizeUnitsNotValidAttribute = 99917;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int SpeciesTypeNotValidAttribute = 99918;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int HasOnlySubsUnitsNotValidAttribute = 99919;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int IdNotValidAttribute = 99920;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int NameNotValidAttribute = 99921;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int SpeciesTypeNotValidComponent = 99922;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int StoichiometryMathNotValidComponent = 99923;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int MultiplierNotValidAttribute = 99924;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int OffsetNotValidAttribute = 99925;

  
    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int L3SpatialDimensionsUnset = 99926;


    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int UnknownCoreAttribute = 99994;


    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int UnknownPackageAttribute = 99995;


    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int PackageConversionNotSupported = 99996;


    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int InvalidTargetLevelVersion = 99997;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int L3NotSupported = 99998;
  

    /**
     * A value in the enumeration of all the SBML error and warning codes
     * for objects of class {@link SBMLError}.  Please consult the
     * documentation for {@link SBMLError} for an explanation of the
     * meaning of this particular error code.
     */
    public final static int SBMLCodesUpperBound = 99999;

    // SBMLErrorCategory_t 
  

    /**
     * Category code for {@link SBMLError} diagnostics.
     * <p>
     * This code has the following meaning: General SBML error not falling
     * into another category below.
     */
    public final static int LIBSBML_CAT_SBML = (LIBSBML_CAT_XML+1);
  

    /**
     * Category code for {@link SBMLError} diagnostics.
     * <p>
     * This code has the following meaning: Category of errors that can
     * only occur during attempted translation from one Level/Version of
     * SBML to another.  This particular category applies to errors
     * encountered while trying to convert a model from SBML Level&nbsp;2
     * to SBML Level&nbsp;1.
     */
    public final static int LIBSBML_CAT_SBML_L1_COMPAT = LIBSBML_CAT_SBML + 1;
  

    /**
     * Category code for {@link SBMLError} diagnostics.
     * <p>
     * This code has the following meaning: Category of errors that can
     * only occur during attempted translation from one Level/Version of
     * SBML to another.  This particular category applies to errors
     * encountered while trying to convert a model to SBML Level&nbsp;2
     * Version&nbsp;1.
     */
    public final static int LIBSBML_CAT_SBML_L2V1_COMPAT = LIBSBML_CAT_SBML_L1_COMPAT + 1;
  

    /**
     * Category code for {@link SBMLError} diagnostics.
     * <p>
     * This code has the following meaning: Category of errors that can
     * only occur during attempted translation from one Level/Version of
     * SBML to another.  This particular category applies to errors
     * encountered while trying to convert a model to SBML Level&nbsp;2
     * Version&nbsp;2.
     */
    public final static int LIBSBML_CAT_SBML_L2V2_COMPAT = LIBSBML_CAT_SBML_L2V1_COMPAT + 1;
  

    /**
     * Category code for {@link SBMLError} diagnostics.
     * <p>
     * This code has the following meaning: Category of errors that can
     * occur while validating general SBML constructs.  With respect to the
     * SBML specification, these concern failures in applying the
     * validation rules numbered 2xxxx in the Level&nbsp;2 Versions&nbsp;2
     * and&nbsp;3 specifications.
     */
    public final static int LIBSBML_CAT_GENERAL_CONSISTENCY = LIBSBML_CAT_SBML_L2V2_COMPAT + 1;
  

    /**
     * Category code for {@link SBMLError} diagnostics.
     * <p>
     * This code has the following meaning: Category of errors that can
     * occur while validating symbol identifiers in a model.  With respect
     * to the SBML specification, these concern failures in applying the
     * validation rules numbered 103xx in the Level&nbsp;2 Versions&nbsp;2
     * and&nbsp;3 specifications.
     */
    public final static int LIBSBML_CAT_IDENTIFIER_CONSISTENCY = LIBSBML_CAT_GENERAL_CONSISTENCY + 1;
  

    /**
     * Category code for {@link SBMLError} diagnostics.
     * <p>
     * This code has the following meaning: Category of errors that can
     * occur while validating the units of measurement on quantities in a
     * model.  With respect to the SBML specification, these concern
     * failures in applying the validation rules numbered 105xx in the
     * Level&nbsp;2 Versions&nbsp;2 and&nbsp;3 specifications.
     */
    public final static int LIBSBML_CAT_UNITS_CONSISTENCY = LIBSBML_CAT_IDENTIFIER_CONSISTENCY + 1;
  

    /**
     * Category code for {@link SBMLError} diagnostics.
     * <p>
     * This code has the following meaning: Category of errors that can
     * occur while validating MathML formulas in a model.  With respect to
     * the SBML specification, these concern failures in applying the
     * validation rules numbered 102xx in the Level&nbsp;2 Versions&nbsp;2
     * and&nbsp;3 specifications.
     */
    public final static int LIBSBML_CAT_MATHML_CONSISTENCY = LIBSBML_CAT_UNITS_CONSISTENCY + 1;
  

    /**
     * Category code for {@link SBMLError} diagnostics.
     * <p>
     * This code has the following meaning: Category of errors that can
     * occur while validating SBO identifiers in a model.  With respect to
     * the SBML specification, these concern failures in applying the
     * validation rules numbered 107xx in the Level&nbsp;2 Versions&nbsp;2
     * and&nbsp;3 specifications.
     */
    public final static int LIBSBML_CAT_SBO_CONSISTENCY = LIBSBML_CAT_MATHML_CONSISTENCY + 1;
  

    /**
     * Category code for {@link SBMLError} diagnostics.
     * <p>
     * This code has the following meaning: Error in the system of
     * equations in the model: the system is overdetermined, therefore
     * violating a tenet of proper SBML.  With respect to the SBML
     * specification, this is validation rule #10601 in the SBML
     * Level&nbsp;2 Versions&nbsp;2 and&nbsp;3 specifications.
     */
    public final static int LIBSBML_CAT_OVERDETERMINED_MODEL = LIBSBML_CAT_SBO_CONSISTENCY + 1;
  

    /**
     * Category code for {@link SBMLError} diagnostics.
     * <p>
     * This code has the following meaning: Category of errors that can
     * only occur during attempted translation from one Level/Version of
     * SBML to another.  This particular category applies to errors
     * encountered while trying to convert a model to SBML Level&nbsp;2
     * Version&nbsp;3.
     */
    public final static int LIBSBML_CAT_SBML_L2V3_COMPAT = LIBSBML_CAT_OVERDETERMINED_MODEL + 1;
  

    /**
     * Category code for {@link SBMLError} diagnostics.
     * <p>
     * This code has the following meaning: Category of warnings about
     * recommended good practices involving SBML and computational
     * modeling.  (These are tests performed by libSBML and do not have
     * equivalent SBML validation rules.)
     */
    public final static int LIBSBML_CAT_MODELING_PRACTICE = LIBSBML_CAT_SBML_L2V3_COMPAT + 1;
  

    /**
     * Category code for {@link SBMLError} diagnostics.
     * <p>
     * This code has the following meaning: Category of errors that can
     * occur while validating libSBML's internal representation of SBML
     * constructs. (These are tests performed by libSBML and do not have
     * equivalent SBML validation rules.)
     */
    public final static int LIBSBML_CAT_INTERNAL_CONSISTENCY = LIBSBML_CAT_MODELING_PRACTICE + 1;
  

    /**
     * Category code for {@link SBMLError} diagnostics.
     * <p>
     * This code has the following meaning: Category of errors that can
     * only occur during attempted translation from one Level/Version of
     * SBML to another.  This particular category applies to errors
     * encountered while trying to convert a model to SBML Level&nbsp;2
     * Version&nbsp;4.
     */
    public final static int LIBSBML_CAT_SBML_L2V4_COMPAT = LIBSBML_CAT_INTERNAL_CONSISTENCY + 1;
  

    /**
     * Category code for {@link SBMLError} diagnostics.
     * <p>
     * This code has the following meaning: Category of errors that can
     * only occur during attempted translation from one Level/Version of
     * SBML to another.  This particular category applies to errors
     * encountered while trying to convert a model to SBML Level&nbsp;3
     * Version&nbsp;1.
     */
    public final static int LIBSBML_CAT_SBML_L3V1_COMPAT = LIBSBML_CAT_SBML_L2V4_COMPAT + 1;


    // SBMLErrorSeverity_t 

    // QualifierType_t 
  

    /**
     * One of the possible MIRIAM annotation types used by {@link CVTerm}.
     */
    public final static int MODEL_QUALIFIER = 0;
  

    /**
     * One of the possible MIRIAM annotation types used by {@link CVTerm}.
     */
    public final static int BIOLOGICAL_QUALIFIER = MODEL_QUALIFIER + 1;
  

    /**
     * One of the possible MIRIAM annotation types used by {@link CVTerm}.
     */
    public final static int UNKNOWN_QUALIFIER = BIOLOGICAL_QUALIFIER + 1;

    // ModelQualifierType_t 
  

    /**
     * One of the possible MIRIAM annotation model qualifier types used by
     * {@link CVTerm}.
     */
    public final static int BQM_IS = 0;
  

    /**
     * One of the possible MIRIAM annotation model qualifier types used by
     * {@link CVTerm}.
     */
    public final static int BQM_IS_DESCRIBED_BY = BQM_IS + 1;
  

    /**
     * One of the possible MIRIAM annotation model qualifier types used by
     * {@link CVTerm}.
     */
    public final static int BQM_IS_DERIVED_FROM = BQM_IS_DESCRIBED_BY + 1;
  

    /**
     * One of the possible MIRIAM annotation model qualifier types used by
     * {@link CVTerm}.
     */
    public final static int BQM_UNKNOWN = BQM_IS_DERIVED_FROM + 1;

    // BiolQualifierType_t 
  

    /**
     * One of the possible MIRIAM annotation model qualifier types used by
     * {@link CVTerm}.  Please consult the explanation of the qualifiers
     * defined by BioModels.net at <a target="_blank"
     * href="http://biomodels.net/qualifiers">http://biomodels.net/qualifiers</a>.
     */
    public final static int BQB_IS = 0;
  

    /**
     * One of the possible MIRIAM annotation model qualifier types used by
     * {@link CVTerm}.  Please consult the explanation of the qualifiers
     * defined by BioModels.net at <a target="_blank"
     * href="http://biomodels.net/qualifiers">http://biomodels.net/qualifiers</a>.
     */
    public final static int BQB_HAS_PART = BQB_IS + 1;
  

    /**
     * One of the possible MIRIAM annotation model qualifier types used by
     * {@link CVTerm}.  Please consult the explanation of the qualifiers
     * defined by BioModels.net at <a target="_blank"
     * href="http://biomodels.net/qualifiers">http://biomodels.net/qualifiers</a>.
     */
    public final static int BQB_IS_PART_OF = BQB_HAS_PART + 1;
  

    /**
     * One of the possible MIRIAM annotation model qualifier types used by
     * {@link CVTerm}.  Please consult the explanation of the qualifiers
     * defined by BioModels.net at <a target="_blank"
     * href="http://biomodels.net/qualifiers">http://biomodels.net/qualifiers</a>.
     */
    public final static int BQB_IS_VERSION_OF = BQB_IS_PART_OF + 1;
  

    /**
     * One of the possible MIRIAM annotation model qualifier types used by
     * {@link CVTerm}.  Please consult the explanation of the qualifiers
     * defined by BioModels.net at <a target="_blank"
     * href="http://biomodels.net/qualifiers">http://biomodels.net/qualifiers</a>.
     */
    public final static int BQB_HAS_VERSION = BQB_IS_VERSION_OF + 1;
  

    /**
     * One of the possible MIRIAM annotation model qualifier types used by
     * {@link CVTerm}.  Please consult the explanation of the qualifiers
     * defined by BioModels.net at <a target="_blank"
     * href="http://biomodels.net/qualifiers">http://biomodels.net/qualifiers</a>.
     */
    public final static int BQB_IS_HOMOLOG_TO = BQB_HAS_VERSION + 1;
  

    /**
     * One of the possible MIRIAM annotation model qualifier types used by
     * {@link CVTerm}.  Please consult the explanation of the qualifiers
     * defined by BioModels.net at <a target="_blank"
     * href="http://biomodels.net/qualifiers">http://biomodels.net/qualifiers</a>.
     */
    public final static int BQB_IS_DESCRIBED_BY = BQB_IS_HOMOLOG_TO + 1;
  

    /**
     * One of the possible MIRIAM annotation model qualifier types used by
     * {@link CVTerm}.  Please consult the explanation of the qualifiers
     * defined by BioModels.net at <a target="_blank"
     * href="http://biomodels.net/qualifiers">http://biomodels.net/qualifiers</a>.
     */
    public final static int BQB_IS_ENCODED_BY = BQB_IS_DESCRIBED_BY + 1;
  

    /**
     * One of the possible MIRIAM annotation model qualifier types used by
     * {@link CVTerm}.  Please consult the explanation of the qualifiers
     * defined by BioModels.net at <a target="_blank"
     * href="http://biomodels.net/qualifiers">http://biomodels.net/qualifiers</a>.
     */
    public final static int BQB_ENCODES = BQB_IS_ENCODED_BY + 1;
  

    /**
     * One of the possible MIRIAM annotation model qualifier types used by
     * {@link CVTerm}.  Please consult the explanation of the qualifiers
     * defined by BioModels.net at <a target="_blank"
     * href="http://biomodels.net/qualifiers">http://biomodels.net/qualifiers</a>.
     */
    public final static int BQB_OCCURS_IN = BQB_ENCODES + 1;
  

    /**
     * One of the possible MIRIAM annotation model qualifier types used by
     * {@link CVTerm}.  Please consult the explanation of the qualifiers
     * defined by BioModels.net at <a target="_blank"
     * href="http://biomodels.net/qualifiers">http://biomodels.net/qualifiers</a>.
     */
    public final static int BQB_HAS_PROPERTY = BQB_OCCURS_IN + 1;
  

    /**
     * One of the possible MIRIAM annotation model qualifier types used by
     * {@link CVTerm}.  Please consult the explanation of the qualifiers
     * defined by BioModels.net at <a target="_blank"
     * href="http://biomodels.net/qualifiers">http://biomodels.net/qualifiers</a>.
     */
    public final static int BQB_IS_PROPERTY_OF = BQB_HAS_PROPERTY + 1;
  

    /**
     * One of the possible MIRIAM annotation model qualifier types used by
     * {@link CVTerm}.  Please consult the explanation of the qualifiers
     * defined by BioModels.net at <a target="_blank"
     * href="http://biomodels.net/qualifiers">http://biomodels.net/qualifiers</a>.
     */
    public final static int BQB_UNKNOWN = BQB_IS_PROPERTY_OF + 1;


    /**
     * One of the possible SBML {@link ConversionOption} value types.
     */
    public final static int CNV_TYPE_BOOL = 0;


    /**
     * One of the possible SBML {@link ConversionOption} value types.
     */
    public final static int CNV_TYPE_DOUBLE = 1;


    /**
     * One of the possible SBML {@link ConversionOption} value types.
     */
    public final static int CNV_TYPE_INT = 2;


    /**
     * One of the possible SBML {@link ConversionOption} value types.
     */
    public final static int CNV_TYPE_SINGLE = 3;


    /**
     * One of the possible SBML {@link ConversionOption} value types.
     */
    public final static int CNV_TYPE_STRING = 4;


    // SBMLCompTypeCode_t 

    /**
     * <span class="pkg-marker pkg-color-comp">comp</span> One of the
     * possible SBML component type codes.
     * <p>
     * LibSBML attaches an identifying code to every kind of SBML object.
     * These are known as <em>SBML type codes</em>.  In other languages,
     * the set of type codes is stored in an enumeration; in the Java
     * language interface for libSBML, the type codes are defined as static
     * integer constants in the interface class {@link libsbmlConstants}.
     * The names of the type codes all begin with the characters
     * <code>SBML_</code>.
     * <p>
     * Each libSBML extension for SBML Level&nbsp;3 packages adds its own
     * type codes to objects.  The present type code belongs to libSBML's
     * extension to support the SBML Level&nbsp;3 Hierarchical Model
     * Composition (&ldquo;comp&rdquo;) package.  It is used to identify
     * the type of SBML component to which a given object corresponds.
     */
    public final static int SBML_COMP_SUBMODEL = 250;


    /**
     * <span class="pkg-marker pkg-color-comp">comp</span> One of the
     * possible SBML component type codes.
     * <p>
     * LibSBML attaches an identifying code to every kind of SBML object.
     * These are known as <em>SBML type codes</em>.  In other languages,
     * the set of type codes is stored in an enumeration; in the Java
     * language interface for libSBML, the type codes are defined as static
     * integer constants in the interface class {@link libsbmlConstants}.
     * The names of the type codes all begin with the characters
     * <code>SBML_</code>.
     * <p>
     * Each libSBML extension for SBML Level&nbsp;3 packages adds its own
     * type codes to objects.  The present type code belongs to libSBML's
     * extension to support the SBML Level&nbsp;3 Hierarchical Model
     * Composition (&ldquo;comp&rdquo;) package.  It is used to identify
     * the type of SBML component to which a given object corresponds.
     */
    public final static int SBML_COMP_MODELDEFINITION = 251;


    /**
     * <span class="pkg-marker pkg-color-comp">comp</span> One of the
     * possible SBML component type codes.
     * <p>
     * LibSBML attaches an identifying code to every kind of SBML object.
     * These are known as <em>SBML type codes</em>.  In other languages,
     * the set of type codes is stored in an enumeration; in the Java
     * language interface for libSBML, the type codes are defined as static
     * integer constants in the interface class {@link libsbmlConstants}.
     * The names of the type codes all begin with the characters
     * <code>SBML_</code>.
     * <p>
     * Each libSBML extension for SBML Level&nbsp;3 packages adds its own
     * type codes to objects.  The present type code belongs to libSBML's
     * extension to support the SBML Level&nbsp;3 Hierarchical Model
     * Composition (&ldquo;comp&rdquo;) package.  It is used to identify
     * the type of SBML component to which a given object corresponds.
     */
    public final static int SBML_COMP_EXTERNALMODELDEFINITION = 252;


    /**
     * <span class="pkg-marker pkg-color-comp">comp</span> One of the
     * possible SBML component type codes.
     * <p>
     * LibSBML attaches an identifying code to every kind of SBML object.
     * These are known as <em>SBML type codes</em>.  In other languages,
     * the set of type codes is stored in an enumeration; in the Java
     * language interface for libSBML, the type codes are defined as static
     * integer constants in the interface class {@link libsbmlConstants}.
     * The names of the type codes all begin with the characters
     * <code>SBML_</code>.
     * <p>
     * Each libSBML extension for SBML Level&nbsp;3 packages adds its own
     * type codes to objects.  The present type code belongs to libSBML's
     * extension to support the SBML Level&nbsp;3 Hierarchical Model
     * Composition (&ldquo;comp&rdquo;) package.  It is used to identify
     * the type of SBML component to which a given object corresponds.
     */
    public final static int SBML_COMP_SBASEREF = 253;


    /**
     * <span class="pkg-marker pkg-color-comp">comp</span> One of the
     * possible SBML component type codes.
     * <p>
     * LibSBML attaches an identifying code to every kind of SBML object.
     * These are known as <em>SBML type codes</em>.  In other languages,
     * the set of type codes is stored in an enumeration; in the Java
     * language interface for libSBML, the type codes are defined as static
     * integer constants in the interface class {@link libsbmlConstants}.
     * The names of the type codes all begin with the characters
     * <code>SBML_</code>.
     * <p>
     * Each libSBML extension for SBML Level&nbsp;3 packages adds its own
     * type codes to objects.  The present type code belongs to libSBML's
     * extension to support the SBML Level&nbsp;3 Hierarchical Model
     * Composition (&ldquo;comp&rdquo;) package.  It is used to identify
     * the type of SBML component to which a given object corresponds.
     */
    public final static int SBML_COMP_DELETION = 254;


    /**
     * <span class="pkg-marker pkg-color-comp">comp</span> One of the
     * possible SBML component type codes.
     * <p>
     * LibSBML attaches an identifying code to every kind of SBML object.
     * These are known as <em>SBML type codes</em>.  In other languages,
     * the set of type codes is stored in an enumeration; in the Java
     * language interface for libSBML, the type codes are defined as static
     * integer constants in the interface class {@link libsbmlConstants}.
     * The names of the type codes all begin with the characters
     * <code>SBML_</code>.
     * <p>
     * Each libSBML extension for SBML Level&nbsp;3 packages adds its own
     * type codes to objects.  The present type code belongs to libSBML's
     * extension to support the SBML Level&nbsp;3 Hierarchical Model
     * Composition (&ldquo;comp&rdquo;) package.  It is used to identify
     * the type of SBML component to which a given object corresponds.
     */
    public final static int SBML_COMP_REPLACEDELEMENT = 255;


    /**
     * <span class="pkg-marker pkg-color-comp">comp</span> One of the
     * possible SBML component type codes.
     * <p>
     * LibSBML attaches an identifying code to every kind of SBML object.
     * These are known as <em>SBML type codes</em>.  In other languages,
     * the set of type codes is stored in an enumeration; in the Java
     * language interface for libSBML, the type codes are defined as static
     * integer constants in the interface class {@link libsbmlConstants}.
     * The names of the type codes all begin with the characters
     * <code>SBML_</code>.
     * <p>
     * Each libSBML extension for SBML Level&nbsp;3 packages adds its own
     * type codes to objects.  The present type code belongs to libSBML's
     * extension to support the SBML Level&nbsp;3 Hierarchical Model
     * Composition (&ldquo;comp&rdquo;) package.  It is used to identify
     * the type of SBML component to which a given object corresponds.
     */
    public final static int SBML_COMP_REPLACEDBY = 256;


    /**
     * <span class="pkg-marker pkg-color-comp">comp</span> One of the
     * possible SBML component type codes.
     * <p>
     * LibSBML attaches an identifying code to every kind of SBML object.
     * These are known as <em>SBML type codes</em>.  In other languages,
     * the set of type codes is stored in an enumeration; in the Java
     * language interface for libSBML, the type codes are defined as static
     * integer constants in the interface class {@link libsbmlConstants}.
     * The names of the type codes all begin with the characters
     * <code>SBML_</code>.
     * <p>
     * Each libSBML extension for SBML Level&nbsp;3 packages adds its own
     * type codes to objects.  The present type code belongs to libSBML's
     * extension to support the SBML Level&nbsp;3 Hierarchical Model
     * Composition (&ldquo;comp&rdquo;) package.  It is used to identify
     * the type of SBML component to which a given object corresponds.
     */
    public final static int SBML_COMP_PORT = 257;


    // SBMLFbcTypeCode_t 

    /**
     * <span class="pkg-marker pkg-color-fbc">fbc</span> One of the
     * possible SBML component type codes.
     * <p>
     * LibSBML attaches an identifying code to every kind of SBML object.
     * These are known as <em>SBML type codes</em>.  In other languages,
     * the set of type codes is stored in an enumeration; in the Java
     * language interface for libSBML, the type codes are defined as static
     * integer constants in the interface class {@link libsbmlConstants}.
     * The names of the type codes all begin with the characters
     * <code>SBML_</code>.
     * <p>
     * Each libSBML extension for SBML Level&nbsp;3 packages adds its own
     * type codes to objects.  The present type code belongs to libSBML's
     * extension to support the SBML Level&nbsp;3 Flux Balance Constraints
     * (&ldquo;fbc&rdquo;) package.  It is used to identify the type of SBML
     * component to which a given object corresponds.
     */
    public final static int SBML_FBC_ASSOCIATION = 800;


    /**
     * <span class="pkg-marker pkg-color-fbc">fbc</span> One of the
     * possible SBML component type codes.
     * <p>
     * LibSBML attaches an identifying code to every kind of SBML object.
     * These are known as <em>SBML type codes</em>.  In other languages,
     * the set of type codes is stored in an enumeration; in the Java
     * language interface for libSBML, the type codes are defined as static
     * integer constants in the interface class {@link libsbmlConstants}.
     * The names of the type codes all begin with the characters
     * <code>SBML_</code>.
     * <p>
     * Each libSBML extension for SBML Level&nbsp;3 packages adds its own
     * type codes to objects.  The present type code belongs to libSBML's
     * extension to support the SBML Level&nbsp;3 Flux Balance Constraints
     * (&ldquo;fbc&rdquo;) package.  It is used to identify the type of SBML
     * component to which a given object corresponds.
     */
    public final static int SBML_FBC_FLUXBOUND = 801;


    /**
     * <span class="pkg-marker pkg-color-fbc">fbc</span> One of the
     * possible SBML component type codes.
     * <p>
     * LibSBML attaches an identifying code to every kind of SBML object.
     * These are known as <em>SBML type codes</em>.  In other languages,
     * the set of type codes is stored in an enumeration; in the Java
     * language interface for libSBML, the type codes are defined as static
     * integer constants in the interface class {@link libsbmlConstants}.
     * The names of the type codes all begin with the characters
     * <code>SBML_</code>.
     * <p>
     * Each libSBML extension for SBML Level&nbsp;3 packages adds its own
     * type codes to objects.  The present type code belongs to libSBML's
     * extension to support the SBML Level&nbsp;3 Flux Balance Constraints
     * (&ldquo;fbc&rdquo;) package.  It is used to identify the type of SBML
     * component to which a given object corresponds.
     */
    public final static int SBML_FBC_FLUXOBJECTIVE = 802;


    /**
     * <span class="pkg-marker pkg-color-fbc">fbc</span> One of the
     * possible SBML component type codes.
     * <p>
     * LibSBML attaches an identifying code to every kind of SBML object.
     * These are known as <em>SBML type codes</em>.  In other languages,
     * the set of type codes is stored in an enumeration; in the Java
     * language interface for libSBML, the type codes are defined as static
     * integer constants in the interface class {@link libsbmlConstants}.
     * The names of the type codes all begin with the characters
     * <code>SBML_</code>.
     * <p>
     * Each libSBML extension for SBML Level&nbsp;3 packages adds its own
     * type codes to objects.  The present type code belongs to libSBML's
     * extension to support the SBML Level&nbsp;3 Flux Balance Constraints
     * (&ldquo;fbc&rdquo;) package.  It is used to identify the type of SBML
     * component to which a given object corresponds.
     */
    public final static int SBML_FBC_GENEASSOCIATION = 803;


    /**
     * <span class="pkg-marker pkg-color-fbc">fbc</span> One of the
     * possible SBML component type codes.
     * <p>
     * LibSBML attaches an identifying code to every kind of SBML object.
     * These are known as <em>SBML type codes</em>.  In other languages,
     * the set of type codes is stored in an enumeration; in the Java
     * language interface for libSBML, the type codes are defined as static
     * integer constants in the interface class {@link libsbmlConstants}.
     * The names of the type codes all begin with the characters
     * <code>SBML_</code>.
     * <p>
     * Each libSBML extension for SBML Level&nbsp;3 packages adds its own
     * type codes to objects.  The present type code belongs to libSBML's
     * extension to support the SBML Level&nbsp;3 Flux Balance Constraints
     * (&ldquo;fbc&rdquo;) package.  It is used to identify the type of SBML
     * component to which a given object corresponds.
     */
    public final static int SBML_FBC_OBJECTIVE = 804;



    // AssociationTypeCode_t 

    /**
     * <span class="pkg-marker pkg-color-fbc">fbc</span> One of the
     * possible Association types.
     * <p>
     * The Association class is not part of the official SBML Level&nbsp;3
     * Flux Balance Constraints specification, but is instead a proposed
     * future development of the package.  If adopted, it would be a child of
     * a GeneAssociation that would describe a single 'and' or 'or'
     * relationship between two or more genes or other associations.
     * <p>
     * The present code is one of the possible Association types for this
     * proposed SBML Level&nbsp;3 Flux Balance Constraints
     * (&ldquo;fbc&rdquo;) package future development.  
     */
    public final static int GENE_ASSOCIATION = 0;


    /**
     * <span class="pkg-marker pkg-color-fbc">fbc</span> One of the
     * possible Association types.
     * <p>
     * The Association class is not part of the official SBML Level&nbsp;3
     * Flux Balance Constraints specification, but is instead a proposed
     * future development of the package.  If adopted, it would be a child of
     * a GeneAssociation that would describe a single 'and' or 'or'
     * relationship between two or more genes or other associations.
     * <p>
     * The present code is one of the possible Association types for this
     * proposed SBML Level&nbsp;3 Flux Balance Constraints
     * (&ldquo;fbc&rdquo;) package future development.  
     */
    public final static int AND_ASSOCIATION = 1;


    /**
     * <span class="pkg-marker pkg-color-fbc">fbc</span> One of the
     * possible Association types.
     * <p>
     * The Association class is not part of the official SBML Level&nbsp;3
     * Flux Balance Constraints specification, but is instead a proposed
     * future development of the package.  If adopted, it would be a child of
     * a GeneAssociation that would describe a single 'and' or 'or'
     * relationship between two or more genes or other associations.
     * <p>
     * The present code is one of the possible Association types for this
     * proposed SBML Level&nbsp;3 Flux Balance Constraints
     * (&ldquo;fbc&rdquo;) package future development.  
     */
    public final static int OR_ASSOCIATION = 2;


    /**
     * <span class="pkg-marker pkg-color-fbc">fbc</span> One of the
     * possible Association types.
     * <p>
     * The Association class is not part of the official SBML Level&nbsp;3
     * Flux Balance Constraints specification, but is instead a proposed
     * future development of the package.  If adopted, it would be a child of
     * a GeneAssociation that would describe a single 'and' or 'or'
     * relationship between two or more genes or other associations.
     * <p>
     * The present code is one of the possible Association types for this
     * proposed SBML Level&nbsp;3 Flux Balance Constraints
     * (&ldquo;fbc&rdquo;) package future development.  
     */
    public final static int UNKNOWN_ASSOCIATION = 3;


    // FluxBoundOperation_t 

    /**
     * <span class="pkg-marker pkg-color-fbc">fbc</span> One of the
     * possible FluxBound operation types.
     * <p>
     * The FluxBound class is part of the SBML Level&nbsp;3 Flux Balanced
     * Constraints package.  Its purpose is to to hold a single equality or
     * inequality that represents the maximum or minimum value a reaction
     * flux can obtain at steady state.  One of the attributes of FluxBound
     * is "operation".  This code is one of the possible values of the
     * "operation" attribute.  The possible legal values are less than or
     * equal to, greater than or equal to, or equal to.  The additional two
     * options "less than" and "greater than" are not legal values for the
     * FluxBound "operation" attribute, but are provided to allow backwards
     * compatibility with an earlier version of the draft specification.
     */
    public final static int FLUXBOUND_OPERATION_LESS_EQUAL = 0;


    /**
     * <span class="pkg-marker pkg-color-fbc">fbc</span> One of the
     * possible FluxBound operation types.
     * <p>
     * The FluxBound class is part of the SBML Level&nbsp;3 Flux Balanced
     * Constraints package.  Its purpose is to to hold a single equality or
     * inequality that represents the maximum or minimum value a reaction
     * flux can obtain at steady state.  One of the attributes of FluxBound
     * is "operation".  This code is one of the possible values of the
     * "operation" attribute.  The possible legal values are less than or
     * equal to, greater than or equal to, or equal to.  The additional two
     * options "less than" and "greater than" are not legal values for the
     * FluxBound "operation" attribute, but are provided to allow backwards
     * compatibility with an earlier version of the draft specification.
     */
    public final static int FLUXBOUND_OPERATION_GREATER_EQUAL = FLUXBOUND_OPERATION_LESS_EQUAL + 1;


    /**
     * <span class="pkg-marker pkg-color-fbc">fbc</span> One of the
     * possible FluxBound operation types.
     * <p>
     * The FluxBound class is part of the SBML Level&nbsp;3 Flux Balanced
     * Constraints package.  Its purpose is to to hold a single equality or
     * inequality that represents the maximum or minimum value a reaction
     * flux can obtain at steady state.  One of the attributes of FluxBound
     * is "operation".  This code is one of the possible values of the
     * "operation" attribute.  The possible legal values are less than or
     * equal to, greater than or equal to, or equal to.  The additional two
     * options "less than" and "greater than" are not legal values for the
     * FluxBound "operation" attribute, but are provided to allow backwards
     * compatibility with an earlier version of the draft specification.
     */
    public final static int FLUXBOUND_OPERATION_LESS = FLUXBOUND_OPERATION_GREATER_EQUAL + 1;


    /**
     * <span class="pkg-marker pkg-color-fbc">fbc</span> One of the
     * possible FluxBound operation types.
     * <p>
     * The FluxBound class is part of the SBML Level&nbsp;3 Flux Balanced
     * Constraints package.  Its purpose is to to hold a single equality or
     * inequality that represents the maximum or minimum value a reaction
     * flux can obtain at steady state.  One of the attributes of FluxBound
     * is "operation".  This code is one of the possible values of the
     * "operation" attribute.  The possible legal values are less than or
     * equal to, greater than or equal to, or equal to.  The additional two
     * options "less than" and "greater than" are not legal values for the
     * FluxBound "operation" attribute, but are provided to allow backwards
     * compatibility with an earlier version of the draft specification.
     */
    public final static int FLUXBOUND_OPERATION_GREATER = FLUXBOUND_OPERATION_LESS + 1;


    /**
     * <span class="pkg-marker pkg-color-fbc">fbc</span> One of the
     * possible FluxBound operation types.
     * <p>
     * The FluxBound class is part of the SBML Level&nbsp;3 Flux Balanced
     * Constraints package.  Its purpose is to to hold a single equality or
     * inequality that represents the maximum or minimum value a reaction
     * flux can obtain at steady state.  One of the attributes of FluxBound
     * is "operation".  This code is one of the possible values of the
     * "operation" attribute.  The possible legal values are less than or
     * equal to, greater than or equal to, or equal to.  The additional two
     * options "less than" and "greater than" are not legal values for the
     * FluxBound "operation" attribute, but are provided to allow backwards
     * compatibility with an earlier version of the draft specification.
     */
    public final static int FLUXBOUND_OPERATION_EQUAL = FLUXBOUND_OPERATION_GREATER + 1;


    /**
     * <span class="pkg-marker pkg-color-fbc">fbc</span> One of the
     * possible FluxBound operation types.
     * <p>
     * The FluxBound class is part of the SBML Level&nbsp;3 Flux Balanced
     * Constraints package.  Its purpose is to to hold a single equality or
     * inequality that represents the maximum or minimum value a reaction
     * flux can obtain at steady state.  One of the attributes of FluxBound
     * is "operation".  This code is one of the possible values of the
     * "operation" attribute.  The possible legal values are less than or
     * equal to, greater than or equal to, or equal to.  The additional two
     * options "less than" and "greater than" are not legal values for the
     * FluxBound "operation" attribute, but are provided to allow backwards
     * compatibility with an earlier version of the draft specification.
     */
    public final static int FLUXBOUND_OPERATION_UNKNOWN = FLUXBOUND_OPERATION_EQUAL + 1;

    // ObjectiveType_t 

    /**
     * <span class="pkg-marker pkg-color-fbc">fbc</span> One of the
     * possible Objective types.
     * <p>

     * The Objective class is part of the SBML Level&nbsp;3 Flux Balanced
     * Constraints package.  Its purpose is to represent the so-called
     * <em>objective function</em>, which generally consist of a linear
     * combination ofmodel variables (fluxes) and a sense (direction).  The
     * Objective class has a "type" attribute, and the present code is one of
     * possible type values.
     */
    public final static int OBJECTIVE_TYPE_MAXIMIZE = 0;


    /**
     * <span class="pkg-marker pkg-color-fbc">fbc</span> One of the
     * possible Objective types.
     * <p>

     * The Objective class is part of the SBML Level&nbsp;3 Flux Balanced
     * Constraints package.  Its purpose is to represent the so-called
     * <em>objective function</em>, which generally consist of a linear
     * combination ofmodel variables (fluxes) and a sense (direction).  The
     * Objective class has a "type" attribute, and the present code is one of
     * possible type values.
     */
    public final static int OBJECTIVE_TYPE_MINIMIZE = OBJECTIVE_TYPE_MAXIMIZE + 1;


    /**
     * <span class="pkg-marker pkg-color-fbc">fbc</span> One of the
     * possible Objective types.
     * <p>

     * The Objective class is part of the SBML Level&nbsp;3 Flux Balanced
     * Constraints package.  Its purpose is to represent the so-called
     * <em>objective function</em>, which generally consist of a linear
     * combination ofmodel variables (fluxes) and a sense (direction).  The
     * Objective class has a "type" attribute, and the present code is one of
     * possible type values.
     */
    public final static int OBJECTIVE_TYPE_UNKNOWN = OBJECTIVE_TYPE_MINIMIZE + 1;


    // SBMLLayoutTypeCode_t 

    /**
     * <span class="pkg-marker pkg-color-layout">layout</span> One of the
     * possible SBML component type codes.
     * <p>
     * LibSBML attaches an identifying code to every kind of SBML object.
     * These are known as <em>SBML type codes</em>.  In other languages,
     * the set of type codes is stored in an enumeration; in the Java
     * language interface for libSBML, the type codes are defined as static
     * integer constants in the interface class {@link libsbmlConstants}.
     * The names of the type codes all begin with the characters
     * <code>SBML_</code>.
     * <p>
     * Each libSBML extension for SBML Level&nbsp;3 packages adds its own
     * type codes to objects.  The present type code belongs to libSBML's
     * extension to support the SBML Level&nbsp;3 Layout
     * (&ldquo;layout&rdquo;) package.  It is used to identify the type of
     * SBML component to which a given object corresponds.
     */
    public final static int SBML_LAYOUT_BOUNDINGBOX = 100;


    /**
     * <span class="pkg-marker pkg-color-layout">layout</span> One of the
     * possible SBML component type codes.
     * <p>
     * LibSBML attaches an identifying code to every kind of SBML object.
     * These are known as <em>SBML type codes</em>.  In other languages,
     * the set of type codes is stored in an enumeration; in the Java
     * language interface for libSBML, the type codes are defined as static
     * integer constants in the interface class {@link libsbmlConstants}.
     * The names of the type codes all begin with the characters
     * <code>SBML_</code>.
     * <p>
     * Each libSBML extension for SBML Level&nbsp;3 packages adds its own
     * type codes to objects.  The present type code belongs to libSBML's
     * extension to support the SBML Level&nbsp;3 Layout
     * (&ldquo;layout&rdquo;) package.  It is used to identify the type of
     * SBML component to which a given object corresponds.
     */
    public final static int SBML_LAYOUT_COMPARTMENTGLYPH = 101;


    /**
     * <span class="pkg-marker pkg-color-layout">layout</span> One of the
     * possible SBML component type codes.
     * <p>
     * LibSBML attaches an identifying code to every kind of SBML object.
     * These are known as <em>SBML type codes</em>.  In other languages,
     * the set of type codes is stored in an enumeration; in the Java
     * language interface for libSBML, the type codes are defined as static
     * integer constants in the interface class {@link libsbmlConstants}.
     * The names of the type codes all begin with the characters
     * <code>SBML_</code>.
     * <p>
     * Each libSBML extension for SBML Level&nbsp;3 packages adds its own
     * type codes to objects.  The present type code belongs to libSBML's
     * extension to support the SBML Level&nbsp;3 Layout
     * (&ldquo;layout&rdquo;) package.  It is used to identify the type of
     * SBML component to which a given object corresponds.
     */
    public final static int SBML_LAYOUT_CUBICBEZIER = 102;


    /**
     * <span class="pkg-marker pkg-color-layout">layout</span> One of the
     * possible SBML component type codes.
     * <p>
     * LibSBML attaches an identifying code to every kind of SBML object.
     * These are known as <em>SBML type codes</em>.  In other languages,
     * the set of type codes is stored in an enumeration; in the Java
     * language interface for libSBML, the type codes are defined as static
     * integer constants in the interface class {@link libsbmlConstants}.
     * The names of the type codes all begin with the characters
     * <code>SBML_</code>.
     * <p>
     * Each libSBML extension for SBML Level&nbsp;3 packages adds its own
     * type codes to objects.  The present type code belongs to libSBML's
     * extension to support the SBML Level&nbsp;3 Layout
     * (&ldquo;layout&rdquo;) package.  It is used to identify the type of
     * SBML component to which a given object corresponds.
     */
    public final static int SBML_LAYOUT_CURVE = 103;


    /**
     * <span class="pkg-marker pkg-color-layout">layout</span> One of the
     * possible SBML component type codes.
     * <p>
     * LibSBML attaches an identifying code to every kind of SBML object.
     * These are known as <em>SBML type codes</em>.  In other languages,
     * the set of type codes is stored in an enumeration; in the Java
     * language interface for libSBML, the type codes are defined as static
     * integer constants in the interface class {@link libsbmlConstants}.
     * The names of the type codes all begin with the characters
     * <code>SBML_</code>.
     * <p>
     * Each libSBML extension for SBML Level&nbsp;3 packages adds its own
     * type codes to objects.  The present type code belongs to libSBML's
     * extension to support the SBML Level&nbsp;3 Layout
     * (&ldquo;layout&rdquo;) package.  It is used to identify the type of
     * SBML component to which a given object corresponds.
     */
    public final static int SBML_LAYOUT_DIMENSIONS = 104;


    /**
     * <span class="pkg-marker pkg-color-layout">layout</span> One of the
     * possible SBML component type codes.
     * <p>
     * LibSBML attaches an identifying code to every kind of SBML object.
     * These are known as <em>SBML type codes</em>.  In other languages,
     * the set of type codes is stored in an enumeration; in the Java
     * language interface for libSBML, the type codes are defined as static
     * integer constants in the interface class {@link libsbmlConstants}.
     * The names of the type codes all begin with the characters
     * <code>SBML_</code>.
     * <p>
     * Each libSBML extension for SBML Level&nbsp;3 packages adds its own
     * type codes to objects.  The present type code belongs to libSBML's
     * extension to support the SBML Level&nbsp;3 Layout
     * (&ldquo;layout&rdquo;) package.  It is used to identify the type of
     * SBML component to which a given object corresponds.
     */
    public final static int SBML_LAYOUT_GRAPHICALOBJECT = 105;


    /**
     * <span class="pkg-marker pkg-color-layout">layout</span> One of the
     * possible SBML component type codes.
     * <p>
     * LibSBML attaches an identifying code to every kind of SBML object.
     * These are known as <em>SBML type codes</em>.  In other languages,
     * the set of type codes is stored in an enumeration; in the Java
     * language interface for libSBML, the type codes are defined as static
     * integer constants in the interface class {@link libsbmlConstants}.
     * The names of the type codes all begin with the characters
     * <code>SBML_</code>.
     * <p>
     * Each libSBML extension for SBML Level&nbsp;3 packages adds its own
     * type codes to objects.  The present type code belongs to libSBML's
     * extension to support the SBML Level&nbsp;3 Layout
     * (&ldquo;layout&rdquo;) package.  It is used to identify the type of
     * SBML component to which a given object corresponds.
     */
    public final static int SBML_LAYOUT_LAYOUT = 106;


    /**
     * <span class="pkg-marker pkg-color-layout">layout</span> One of the
     * possible SBML component type codes.
     * <p>
     * LibSBML attaches an identifying code to every kind of SBML object.
     * These are known as <em>SBML type codes</em>.  In other languages,
     * the set of type codes is stored in an enumeration; in the Java
     * language interface for libSBML, the type codes are defined as static
     * integer constants in the interface class {@link libsbmlConstants}.
     * The names of the type codes all begin with the characters
     * <code>SBML_</code>.
     * <p>
     * Each libSBML extension for SBML Level&nbsp;3 packages adds its own
     * type codes to objects.  The present type code belongs to libSBML's
     * extension to support the SBML Level&nbsp;3 Layout
     * (&ldquo;layout&rdquo;) package.  It is used to identify the type of
     * SBML component to which a given object corresponds.
     */
    public final static int SBML_LAYOUT_LINESEGMENT = 107;


    /**
     * <span class="pkg-marker pkg-color-layout">layout</span> One of the
     * possible SBML component type codes.
     * <p>
     * LibSBML attaches an identifying code to every kind of SBML object.
     * These are known as <em>SBML type codes</em>.  In other languages,
     * the set of type codes is stored in an enumeration; in the Java
     * language interface for libSBML, the type codes are defined as static
     * integer constants in the interface class {@link libsbmlConstants}.
     * The names of the type codes all begin with the characters
     * <code>SBML_</code>.
     * <p>
     * Each libSBML extension for SBML Level&nbsp;3 packages adds its own
     * type codes to objects.  The present type code belongs to libSBML's
     * extension to support the SBML Level&nbsp;3 Layout
     * (&ldquo;layout&rdquo;) package.  It is used to identify the type of
     * SBML component to which a given object corresponds.
     */
    public final static int SBML_LAYOUT_POINT = 108;


    /**
     * <span class="pkg-marker pkg-color-layout">layout</span> One of the
     * possible SBML component type codes.
     * <p>
     * LibSBML attaches an identifying code to every kind of SBML object.
     * These are known as <em>SBML type codes</em>.  In other languages,
     * the set of type codes is stored in an enumeration; in the Java
     * language interface for libSBML, the type codes are defined as static
     * integer constants in the interface class {@link libsbmlConstants}.
     * The names of the type codes all begin with the characters
     * <code>SBML_</code>.
     * <p>
     * Each libSBML extension for SBML Level&nbsp;3 packages adds its own
     * type codes to objects.  The present type code belongs to libSBML's
     * extension to support the SBML Level&nbsp;3 Layout
     * (&ldquo;layout&rdquo;) package.  It is used to identify the type of
     * SBML component to which a given object corresponds.
     */
    public final static int SBML_LAYOUT_REACTIONGLYPH = 109;


    /**
     * <span class="pkg-marker pkg-color-layout">layout</span> One of the
     * possible SBML component type codes.
     * <p>
     * LibSBML attaches an identifying code to every kind of SBML object.
     * These are known as <em>SBML type codes</em>.  In other languages,
     * the set of type codes is stored in an enumeration; in the Java
     * language interface for libSBML, the type codes are defined as static
     * integer constants in the interface class {@link libsbmlConstants}.
     * The names of the type codes all begin with the characters
     * <code>SBML_</code>.
     * <p>
     * Each libSBML extension for SBML Level&nbsp;3 packages adds its own
     * type codes to objects.  The present type code belongs to libSBML's
     * extension to support the SBML Level&nbsp;3 Layout
     * (&ldquo;layout&rdquo;) package.  It is used to identify the type of
     * SBML component to which a given object corresponds.
     */
    public final static int SBML_LAYOUT_SPECIESGLYPH = 110;


    /**
     * <span class="pkg-marker pkg-color-layout">layout</span> One of the
     * possible SBML component type codes.
     * <p>
     * LibSBML attaches an identifying code to every kind of SBML object.
     * These are known as <em>SBML type codes</em>.  In other languages,
     * the set of type codes is stored in an enumeration; in the Java
     * language interface for libSBML, the type codes are defined as static
     * integer constants in the interface class {@link libsbmlConstants}.
     * The names of the type codes all begin with the characters
     * <code>SBML_</code>.
     * <p>
     * Each libSBML extension for SBML Level&nbsp;3 packages adds its own
     * type codes to objects.  The present type code belongs to libSBML's
     * extension to support the SBML Level&nbsp;3 Layout
     * (&ldquo;layout&rdquo;) package.  It is used to identify the type of
     * SBML component to which a given object corresponds.
     */
    public final static int SBML_LAYOUT_SPECIESREFERENCEGLYPH = 111;


    /**
     * <span class="pkg-marker pkg-color-layout">layout</span> One of the
     * possible SBML component type codes.
     * <p>
     * LibSBML attaches an identifying code to every kind of SBML object.
     * These are known as <em>SBML type codes</em>.  In other languages,
     * the set of type codes is stored in an enumeration; in the Java
     * language interface for libSBML, the type codes are defined as static
     * integer constants in the interface class {@link libsbmlConstants}.
     * The names of the type codes all begin with the characters
     * <code>SBML_</code>.
     * <p>
     * Each libSBML extension for SBML Level&nbsp;3 packages adds its own
     * type codes to objects.  The present type code belongs to libSBML's
     * extension to support the SBML Level&nbsp;3 Layout
     * (&ldquo;layout&rdquo;) package.  It is used to identify the type of
     * SBML component to which a given object corresponds.
     */
    public final static int SBML_LAYOUT_TEXTGLYPH = 112;


    /**
     * <span class="pkg-marker pkg-color-layout">layout</span> One of the
     * possible SBML component type codes.
     * <p>
     * LibSBML attaches an identifying code to every kind of SBML object.
     * These are known as <em>SBML type codes</em>.  In other languages,
     * the set of type codes is stored in an enumeration; in the Java
     * language interface for libSBML, the type codes are defined as static
     * integer constants in the interface class {@link libsbmlConstants}.
     * The names of the type codes all begin with the characters
     * <code>SBML_</code>.
     * <p>
     * Each libSBML extension for SBML Level&nbsp;3 packages adds its own
     * type codes to objects.  The present type code belongs to libSBML's
     * extension to support the SBML Level&nbsp;3 Layout
     * (&ldquo;layout&rdquo;) package.  It is used to identify the type of
     * SBML component to which a given object corresponds.
     */
    public final static int SBML_LAYOUT_REFERENCEGLYPH = 113;


    /**
     * <span class="pkg-marker pkg-color-layout">layout</span> One of the
     * possible SBML component type codes.
     * <p>
     * LibSBML attaches an identifying code to every kind of SBML object.
     * These are known as <em>SBML type codes</em>.  In other languages,
     * the set of type codes is stored in an enumeration; in the Java
     * language interface for libSBML, the type codes are defined as static
     * integer constants in the interface class {@link libsbmlConstants}.
     * The names of the type codes all begin with the characters
     * <code>SBML_</code>.
     * <p>
     * Each libSBML extension for SBML Level&nbsp;3 packages adds its own
     * type codes to objects.  The present type code belongs to libSBML's
     * extension to support the SBML Level&nbsp;3 Layout
     * (&ldquo;layout&rdquo;) package.  It is used to identify the type of
     * SBML component to which a given object corresponds.
     */
    public final static int SBML_LAYOUT_GENERALGLYPH = 114;


    // SpeciesReferenceRole_t 

    /**
     * <span class="pkg-marker pkg-color-layout">layout</span> One of the
     * possible roles of a SpeciesReferenceGlyph.
     * <p>
     * SpeciesReferenceGlyphs include an attribute to describe the role of a
     * given SpeciesReference in a model diagram.  The present code is one of
     * the possible values for this role attribute.
     */
    public final static int SPECIES_ROLE_UNDEFINED = 0;


    /**
     * <span class="pkg-marker pkg-color-layout">layout</span> One of the
     * possible roles of a SpeciesReferenceGlyph.
     * <p>
     * SpeciesReferenceGlyphs include an attribute to describe the role of a
     * given SpeciesReference in a model diagram.  The present code is one of
     * the possible values for this role attribute.
     */
    public final static int SPECIES_ROLE_SUBSTRATE = SPECIES_ROLE_UNDEFINED + 1;


    /**
     * <span class="pkg-marker pkg-color-layout">layout</span> One of the
     * possible roles of a SpeciesReferenceGlyph.
     * <p>
     * SpeciesReferenceGlyphs include an attribute to describe the role of a
     * given SpeciesReference in a model diagram.  The present code is one of
     * the possible values for this role attribute.
     */
    public final static int SPECIES_ROLE_PRODUCT = SPECIES_ROLE_SUBSTRATE + 1;


    /**
     * <span class="pkg-marker pkg-color-layout">layout</span> One of the
     * possible roles of a SpeciesReferenceGlyph.
     * <p>
     * SpeciesReferenceGlyphs include an attribute to describe the role of a
     * given SpeciesReference in a model diagram.  The present code is one of
     * the possible values for this role attribute.
     */
    public final static int SPECIES_ROLE_SIDESUBSTRATE = SPECIES_ROLE_PRODUCT + 1;


    /**
     * <span class="pkg-marker pkg-color-layout">layout</span> One of the
     * possible roles of a SpeciesReferenceGlyph.
     * <p>
     * SpeciesReferenceGlyphs include an attribute to describe the role of a
     * given SpeciesReference in a model diagram.  The present code is one of
     * the possible values for this role attribute.
     */
    public final static int SPECIES_ROLE_SIDEPRODUCT = SPECIES_ROLE_SIDESUBSTRATE + 1;


    /**
     * <span class="pkg-marker pkg-color-layout">layout</span> One of the
     * possible roles of a SpeciesReferenceGlyph.
     * <p>
     * SpeciesReferenceGlyphs include an attribute to describe the role of a
     * given SpeciesReference in a model diagram.  The present code is one of
     * the possible values for this role attribute.
     */
    public final static int SPECIES_ROLE_MODIFIER = SPECIES_ROLE_SIDEPRODUCT + 1;


    /**
     * <span class="pkg-marker pkg-color-layout">layout</span> One of the
     * possible roles of a SpeciesReferenceGlyph.
     * <p>
     * SpeciesReferenceGlyphs include an attribute to describe the role of a
     * given SpeciesReference in a model diagram.  The present code is one of
     * the possible values for this role attribute.
     */
    public final static int SPECIES_ROLE_ACTIVATOR = SPECIES_ROLE_MODIFIER + 1;


    /**
     * <span class="pkg-marker pkg-color-layout">layout</span> One of the
     * possible roles of a SpeciesReferenceGlyph.
     * <p>
     * SpeciesReferenceGlyphs include an attribute to describe the role of a
     * given SpeciesReference in a model diagram.  The present code is one of
     * the possible values for this role attribute.
     */
    public final static int SPECIES_ROLE_INHIBITOR = SPECIES_ROLE_ACTIVATOR + 1;


    // SBMLQualTypeCode_t 

    /**
     * <span class="pkg-marker pkg-color-qual">qual</span> One of the
     * possible SBML component type codes.
     * <p>
     * LibSBML attaches an identifying code to every kind of SBML object.
     * These are known as <em>SBML type codes</em>.  In other languages,
     * the set of type codes is stored in an enumeration; in the Java
     * language interface for libSBML, the type codes are defined as static
     * integer constants in the interface class {@link libsbmlConstants}.
     * The names of the type codes all begin with the characters
     * <code>SBML_</code>.
     * <p>
     * Each libSBML extension for SBML Level&nbsp;3 packages adds its own
     * type codes to objects.  The present type code belongs to libSBML's
     * extension to support the SBML Level&nbsp;3 Qualitative Models
     * (&ldquo;qual&rdquo;) package.  It is used to identify the type of
     * SBML component to which a given object corresponds.
     */
    public final static int SBML_QUAL_QUALITATIVE_SPECIES = 1100;


    /**
     * <span class="pkg-marker pkg-color-qual">qual</span> One of the
     * possible SBML component type codes.
     * <p>
     * LibSBML attaches an identifying code to every kind of SBML object.
     * These are known as <em>SBML type codes</em>.  In other languages,
     * the set of type codes is stored in an enumeration; in the Java
     * language interface for libSBML, the type codes are defined as static
     * integer constants in the interface class {@link libsbmlConstants}.
     * The names of the type codes all begin with the characters
     * <code>SBML_</code>.
     * <p>
     * Each libSBML extension for SBML Level&nbsp;3 packages adds its own
     * type codes to objects.  The present type code belongs to libSBML's
     * extension to support the SBML Level&nbsp;3 Qualitative Models
     * (&ldquo;qual&rdquo;) package.  It is used to identify the type of
     * SBML component to which a given object corresponds.
     */
    public final static int SBML_QUAL_TRANSITION = 1101;


    /**
     * <span class="pkg-marker pkg-color-qual">qual</span> One of the
     * possible SBML component type codes.
     * <p>
     * LibSBML attaches an identifying code to every kind of SBML object.
     * These are known as <em>SBML type codes</em>.  In other languages,
     * the set of type codes is stored in an enumeration; in the Java
     * language interface for libSBML, the type codes are defined as static
     * integer constants in the interface class {@link libsbmlConstants}.
     * The names of the type codes all begin with the characters
     * <code>SBML_</code>.
     * <p>
     * Each libSBML extension for SBML Level&nbsp;3 packages adds its own
     * type codes to objects.  The present type code belongs to libSBML's
     * extension to support the SBML Level&nbsp;3 Qualitative Models
     * (&ldquo;qual&rdquo;) package.  It is used to identify the type of
     * SBML component to which a given object corresponds.
     */
    public final static int SBML_QUAL_INPUT = 1102;


    /**
     * <span class="pkg-marker pkg-color-qual">qual</span> One of the
     * possible SBML component type codes.
     * <p>
     * LibSBML attaches an identifying code to every kind of SBML object.
     * These are known as <em>SBML type codes</em>.  In other languages,
     * the set of type codes is stored in an enumeration; in the Java
     * language interface for libSBML, the type codes are defined as static
     * integer constants in the interface class {@link libsbmlConstants}.
     * The names of the type codes all begin with the characters
     * <code>SBML_</code>.
     * <p>
     * Each libSBML extension for SBML Level&nbsp;3 packages adds its own
     * type codes to objects.  The present type code belongs to libSBML's
     * extension to support the SBML Level&nbsp;3 Qualitative Models
     * (&ldquo;qual&rdquo;) package.  It is used to identify the type of
     * SBML component to which a given object corresponds.
     */
    public final static int SBML_QUAL_OUTPUT = 1103;


    /**
     * <span class="pkg-marker pkg-color-qual">qual</span> One of the
     * possible SBML component type codes.
     * <p>
     * LibSBML attaches an identifying code to every kind of SBML object.
     * These are known as <em>SBML type codes</em>.  In other languages,
     * the set of type codes is stored in an enumeration; in the Java
     * language interface for libSBML, the type codes are defined as static
     * integer constants in the interface class {@link libsbmlConstants}.
     * The names of the type codes all begin with the characters
     * <code>SBML_</code>.
     * <p>
     * Each libSBML extension for SBML Level&nbsp;3 packages adds its own
     * type codes to objects.  The present type code belongs to libSBML's
     * extension to support the SBML Level&nbsp;3 Qualitative Models
     * (&ldquo;qual&rdquo;) package.  It is used to identify the type of
     * SBML component to which a given object corresponds.
     */
    public final static int SBML_QUAL_FUNCTION_TERM = 1104;


    /**
     * <span class="pkg-marker pkg-color-qual">qual</span> One of the
     * possible SBML component type codes.
     * <p>
     * LibSBML attaches an identifying code to every kind of SBML object.
     * These are known as <em>SBML type codes</em>.  In other languages,
     * the set of type codes is stored in an enumeration; in the Java
     * language interface for libSBML, the type codes are defined as static
     * integer constants in the interface class {@link libsbmlConstants}.
     * The names of the type codes all begin with the characters
     * <code>SBML_</code>.
     * <p>
     * Each libSBML extension for SBML Level&nbsp;3 packages adds its own
     * type codes to objects.  The present type code belongs to libSBML's
     * extension to support the SBML Level&nbsp;3 Qualitative Models
     * (&ldquo;qual&rdquo;) package.  It is used to identify the type of
     * SBML component to which a given object corresponds.
     */
    public final static int SBML_QUAL_DEFAULT_TERM = 1105;


    // InputTransitionEffect_t 

    /**
     * <span class="pkg-marker pkg-color-qual">qual</span> One of the
     * possible Input transition effects.
     * <p>
     * The Input class is part of the SBML Level&nbsp;3 Qualitative Models
     * package.  Its purpose is to represent a qualitative species that
     * participates in a Transition; specifically, in Petri nets, these are
     * the input places of the transition, and in logical models, they are
     * the regulators of the species whose behaviour is defined by the
     * transition.  Input has an attribute named "transitionEffect" that 
     * is used to describe how the QualitativeSpecies referenced by the
     * Input is affected by the Transition.
     * <p>
     * The present code is one of the possible values of the
     * "transitionEffect" attribute of an Input object.
     */
    public final static int INPUT_TRANSITION_EFFECT_NONE = 0;


    /**
     * <span class="pkg-marker pkg-color-qual">qual</span> One of the
     * possible Input transition effects.
     * <p>
     * The Input class is part of the SBML Level&nbsp;3 Qualitative Models
     * package.  Its purpose is to represent a qualitative species that
     * participates in a Transition; specifically, in Petri nets, these are
     * the input places of the transition, and in logical models, they are
     * the regulators of the species whose behaviour is defined by the
     * transition.  Input has an attribute named "transitionEffect" that 
     * is used to describe how the QualitativeSpecies referenced by the
     * Input is affected by the Transition.
     * <p>
     * The present code is one of the possible values of the
     * "transitionEffect" attribute of an Input object.
     */
    public final static int INPUT_TRANSITION_EFFECT_CONSUMPTION = INPUT_TRANSITION_EFFECT_NONE + 1;


    /**
     * <span class="pkg-marker pkg-color-qual">qual</span> One of the
     * possible Input transition effects.
     * <p>
     * The Input class is part of the SBML Level&nbsp;3 Qualitative Models
     * package.  Its purpose is to represent a qualitative species that
     * participates in a Transition; specifically, in Petri nets, these are
     * the input places of the transition, and in logical models, they are
     * the regulators of the species whose behaviour is defined by the
     * transition.  Input has an attribute named "transitionEffect" that 
     * is used to describe how the QualitativeSpecies referenced by the
     * Input is affected by the Transition.
     * <p>
     * The present code is one of the possible values of the
     * "transitionEffect" attribute of an Input object.
     */
    public final static int INPUT_TRANSITION_EFFECT_UNKNOWN = INPUT_TRANSITION_EFFECT_CONSUMPTION + 1;

    // InputSign_t 

    /**
     * <span class="pkg-marker pkg-color-qual">qual</span> One of the
     * possible Input "sign" attribute values.
     * <p>
     * The Input class is part of the SBML Level&nbsp;3 Qualitative Models
     * package.  Its purpose is to represent a qualitative species that
     * participates in a Transition; specifically, in Petri nets, these are
     * the input places of the transition, and in logical models, they are
     * the regulators of the species whose behaviour is defined by the
     * transition.  Input has an attribute named "sign" that is used to
     * indicate whether the contribution of this input is positive, negative,
     * both (dual) or unknown. This enables a model to distinguish between
     * stimulation and inhibition and can facilitate interpretation of
     * themodel without the mathematics. The sign is particularly used for
     * visualization purposes and has no impact on the mathematical
     * interpretation.
     * <p>
     * The present code is one of the possible values of the "sign" attribute
     * of an Input object.
     */
    public final static int INPUT_SIGN_POSITIVE = 0;


    /**
     * <span class="pkg-marker pkg-color-qual">qual</span> One of the
     * possible Input "sign" attribute values.
     * <p>
     * The Input class is part of the SBML Level&nbsp;3 Qualitative Models
     * package.  Its purpose is to represent a qualitative species that
     * participates in a Transition; specifically, in Petri nets, these are
     * the input places of the transition, and in logical models, they are
     * the regulators of the species whose behaviour is defined by the
     * transition.  Input has an attribute named "sign" that is used to
     * indicate whether the contribution of this input is positive, negative,
     * both (dual) or unknown. This enables a model to distinguish between
     * stimulation and inhibition and can facilitate interpretation of
     * themodel without the mathematics. The sign is particularly used for
     * visualization purposes and has no impact on the mathematical
     * interpretation.
     * <p>
     * The present code is one of the possible values of the "sign" attribute
     * of an Input object.
     */
    public final static int INPUT_SIGN_NEGATIVE = INPUT_SIGN_POSITIVE + 1;


    /**
     * <span class="pkg-marker pkg-color-qual">qual</span> One of the
     * possible Input "sign" attribute values.
     * <p>
     * The Input class is part of the SBML Level&nbsp;3 Qualitative Models
     * package.  Its purpose is to represent a qualitative species that
     * participates in a Transition; specifically, in Petri nets, these are
     * the input places of the transition, and in logical models, they are
     * the regulators of the species whose behaviour is defined by the
     * transition.  Input has an attribute named "sign" that is used to
     * indicate whether the contribution of this input is positive, negative,
     * both (dual) or unknown. This enables a model to distinguish between
     * stimulation and inhibition and can facilitate interpretation of
     * themodel without the mathematics. The sign is particularly used for
     * visualization purposes and has no impact on the mathematical
     * interpretation.
     * <p>
     * The present code is one of the possible values of the "sign" attribute
     * of an Input object.
     */
    public final static int INPUT_SIGN_DUAL = INPUT_SIGN_NEGATIVE + 1;


    /**
     * <span class="pkg-marker pkg-color-qual">qual</span> One of the
     * possible Input "sign" attribute values.
     * <p>
     * The Input class is part of the SBML Level&nbsp;3 Qualitative Models
     * package.  Its purpose is to represent a qualitative species that
     * participates in a Transition; specifically, in Petri nets, these are
     * the input places of the transition, and in logical models, they are
     * the regulators of the species whose behaviour is defined by the
     * transition.  Input has an attribute named "sign" that is used to
     * indicate whether the contribution of this input is positive, negative,
     * both (dual) or unknown. This enables a model to distinguish between
     * stimulation and inhibition and can facilitate interpretation of
     * themodel without the mathematics. The sign is particularly used for
     * visualization purposes and has no impact on the mathematical
     * interpretation.
     * <p>
     * The present code is one of the possible values of the "sign" attribute
     * of an Input object.
     */
    public final static int INPUT_SIGN_UNKNOWN = INPUT_SIGN_DUAL + 1;


    /**
     * <span class="pkg-marker pkg-color-qual">qual</span> One of the
     * possible Input "sign" attribute values.
     * <p>
     * The Input class is part of the SBML Level&nbsp;3 Qualitative Models
     * package.  Its purpose is to represent a qualitative species that
     * participates in a Transition; specifically, in Petri nets, these are
     * the input places of the transition, and in logical models, they are
     * the regulators of the species whose behaviour is defined by the
     * transition.  Input has an attribute named "sign" that is used to
     * indicate whether the contribution of this input is positive, negative,
     * both (dual) or unknown. This enables a model to distinguish between
     * stimulation and inhibition and can facilitate interpretation of
     * themodel without the mathematics. The sign is particularly used for
     * visualization purposes and has no impact on the mathematical
     * interpretation.
     * <p>
     * The present code is one of the possible values of the "sign" attribute
     * of an Input object.
     */
    public final static int INPUT_SIGN_VALUE_NOTSET = INPUT_SIGN_UNKNOWN + 1;


    // OutputTransitionEffect_t 

    /**
     * <span class="pkg-marker pkg-color-qual">qual</span> One of the
     * possible OutputTransition "transitionEffect" attribute values.
     * <p>
     * The OutputTransition class is part of the SBML Level&nbsp;3
     * Qualitative Models package.  Its purpose is to represent a qualitative
     * species that is affected by a Transition.  (In Petri net models, these
     * are the output places of the transition.)  OutputTransition has an
     * attribute named "transitionEffect" that is used to describe how the
     * QualitativeSpecies referenced by the Output is affected by the
     * Transition.
     <p>
     * The present code is one of the possible values of the
     * "transitionEffect" attribute of an OutputTransition object.
     */
    public final static int OUTPUT_TRANSITION_EFFECT_PRODUCTION = 0;


    /**
     * <span class="pkg-marker pkg-color-qual">qual</span> One of the
     * possible OutputTransition "transitionEffect" attribute values.
     * <p>
     * The OutputTransition class is part of the SBML Level&nbsp;3
     * Qualitative Models package.  Its purpose is to represent a qualitative
     * species that is affected by a Transition.  (In Petri net models, these
     * are the output places of the transition.)  OutputTransition has an
     * attribute named "transitionEffect" that is used to describe how the
     * QualitativeSpecies referenced by the Output is affected by the
     * Transition.
     <p>
     * The present code is one of the possible values of the
     * "transitionEffect" attribute of an OutputTransition object.
     */
    public final static int OUTPUT_TRANSITION_EFFECT_ASSIGNMENT_LEVEL = OUTPUT_TRANSITION_EFFECT_PRODUCTION + 1;


    /**
     * <span class="pkg-marker pkg-color-qual">qual</span> One of the
     * possible OutputTransition "transitionEffect" attribute values.
     * <p>
     * The OutputTransition class is part of the SBML Level&nbsp;3
     * Qualitative Models package.  Its purpose is to represent a qualitative
     * species that is affected by a Transition.  (In Petri net models, these
     * are the output places of the transition.)  OutputTransition has an
     * attribute named "transitionEffect" that is used to describe how the
     * QualitativeSpecies referenced by the Output is affected by the
     * Transition.
     <p>
     * The present code is one of the possible values of the
     * "transitionEffect" attribute of an OutputTransition object.
     */
    public final static int OUTPUT_TRANSITION_EFFECT_UNKNOWN = OUTPUT_TRANSITION_EFFECT_ASSIGNMENT_LEVEL + 1;


    // CompSBMLErrorCode_t 

    /**
     * <span class="pkg-marker pkg-color-comp">comp</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;comp&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int CompUnknown = 1010100;


    /**
     * <span class="pkg-marker pkg-color-comp">comp</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;comp&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int CompNSUndeclared = 1010101;


    /**
     * <span class="pkg-marker pkg-color-comp">comp</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;comp&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int CompElementNotInNs = 1010102;


    /**
     * <span class="pkg-marker pkg-color-comp">comp</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;comp&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int CompDuplicateComponentId = 1010301;

    /**
     * <span class="pkg-marker pkg-color-comp">comp</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;comp&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int CompUniqueModelIds = 1010302;


    /**
     * <span class="pkg-marker pkg-color-comp">comp</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;comp&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int CompUniquePortIds = 1010303;


    /**
     * <span class="pkg-marker pkg-color-comp">comp</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;comp&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int CompInvalidSIdSyntax = 1010304;


    /**
     * <span class="pkg-marker pkg-color-comp">comp</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;comp&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int CompInvalidSubmodelRefSyntax = 1010308;


    /**
     * <span class="pkg-marker pkg-color-comp">comp</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;comp&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int CompInvalidDeletionSyntax = 1010309;


    /**
     * <span class="pkg-marker pkg-color-comp">comp</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;comp&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int CompInvalidConversionFactorSyntax = 1010310;


    /**
     * <span class="pkg-marker pkg-color-comp">comp</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;comp&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int CompInvalidNameSyntax = 1010311;


    /**
     * <span class="pkg-marker pkg-color-comp">comp</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;comp&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int CompReplacedUnitsShouldMatch = 1010501;


    /**
     * <span class="pkg-marker pkg-color-comp">comp</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;comp&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int CompOneListOfReplacedElements = 1020101;


    /**
     * <span class="pkg-marker pkg-color-comp">comp</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;comp&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int CompLOReplaceElementsAllowedElements = 1020102;


    /**
     * <span class="pkg-marker pkg-color-comp">comp</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;comp&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int CompLOReplacedElementsAllowedAttribs = 1020103;


    /**
     * <span class="pkg-marker pkg-color-comp">comp</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;comp&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int CompEmptyLOReplacedElements = 1020104;


    /**
     * <span class="pkg-marker pkg-color-comp">comp</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;comp&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int CompOneReplacedByElement = 1020105;


    /**
     * <span class="pkg-marker pkg-color-comp">comp</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;comp&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int CompAttributeRequiredMissing = 1020201;


    /**
     * <span class="pkg-marker pkg-color-comp">comp</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;comp&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int CompAttributeRequiredMustBeBoolean = 1020202;


    /**
     * <span class="pkg-marker pkg-color-comp">comp</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;comp&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int CompRequiredTrueIfElementsRemain = 1020203;


    /**
     * <span class="pkg-marker pkg-color-comp">comp</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;comp&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int CompRequiredFalseIfAllElementsReplaced = 1020204;


    /**
     * <span class="pkg-marker pkg-color-comp">comp</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;comp&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int CompOneListOfModelDefinitions = 1020205;


    /**
     * <span class="pkg-marker pkg-color-comp">comp</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;comp&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int CompEmptyLOModelDefs = 1020206;


    /**
     * <span class="pkg-marker pkg-color-comp">comp</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;comp&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int CompLOModelDefsAllowedElements = 1020207;


    /**
     * <span class="pkg-marker pkg-color-comp">comp</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;comp&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int CompLOExtModelDefsAllowedElements = 1020208;


    /**
     * <span class="pkg-marker pkg-color-comp">comp</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;comp&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int CompLOModelDefsAllowedAttributes = 1020209;


    /**
     * <span class="pkg-marker pkg-color-comp">comp</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;comp&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int CompLOExtModDefsAllowedAttributes = 1020210;


    /**
     * <span class="pkg-marker pkg-color-comp">comp</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;comp&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int CompOneListOfExtModelDefinitions = 1020211;


    /**
     * <span class="pkg-marker pkg-color-comp">comp</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;comp&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int CompAttributeRequiredMustBeTrue = 1020212;


    /**
     * <span class="pkg-marker pkg-color-comp">comp</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;comp&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int CompExtModDefAllowedCoreAttributes = 1020301;


    /**
     * <span class="pkg-marker pkg-color-comp">comp</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;comp&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int CompExtModDefAllowedElements = 1020302;


    /**
     * <span class="pkg-marker pkg-color-comp">comp</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;comp&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int CompExtModDefAllowedAttributes = 1020303;


    /**
     * <span class="pkg-marker pkg-color-comp">comp</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;comp&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int CompReferenceMustBeL3 = 1020304;


    /**
     * <span class="pkg-marker pkg-color-comp">comp</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;comp&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int CompModReferenceMustIdOfModel = 1020305;


    /**
     * <span class="pkg-marker pkg-color-comp">comp</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;comp&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int CompExtModMd5DoesNotMatch = 1020306;


    /**
     * <span class="pkg-marker pkg-color-comp">comp</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;comp&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int CompInvalidSourceSyntax = 1020307;


    /**
     * <span class="pkg-marker pkg-color-comp">comp</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;comp&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int CompInvalidModelRefSyntax = 1020308;


    /**
     * <span class="pkg-marker pkg-color-comp">comp</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;comp&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int CompInvalidMD5Syntax = 1020309;


    /**
     * <span class="pkg-marker pkg-color-comp">comp</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;comp&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int CompCircularExternalModelReference = 1020310;


    /**
     * <span class="pkg-marker pkg-color-comp">comp</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;comp&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int CompOneListOfOnModel = 1020501;


    /**
     * <span class="pkg-marker pkg-color-comp">comp</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;comp&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int CompNoEmptyListOfOnModel = 1020502;


    /**
     * <span class="pkg-marker pkg-color-comp">comp</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;comp&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int CompLOSubmodelsAllowedElements = 1020503;


    /**
     * <span class="pkg-marker pkg-color-comp">comp</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;comp&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int CompLOPortsAllowedElements = 1020504;


    /**
     * <span class="pkg-marker pkg-color-comp">comp</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;comp&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int CompLOSubmodelsAllowedAttributes = 1020505;


    /**
     * <span class="pkg-marker pkg-color-comp">comp</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;comp&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int CompLOPortsAllowedAttributes = 1020506;


    /**
     * <span class="pkg-marker pkg-color-comp">comp</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;comp&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int CompSubmodelAllowedCoreAttributes = 1020601;


    /**
     * <span class="pkg-marker pkg-color-comp">comp</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;comp&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int CompSubmodelAllowedElements = 1020602;


    /**
     * <span class="pkg-marker pkg-color-comp">comp</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;comp&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int CompOneListOfDeletionOnSubmodel = 1020603;


    /**
     * <span class="pkg-marker pkg-color-comp">comp</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;comp&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int CompSubmodelNoEmptyLODeletions = 1020604;


    /**
     * <span class="pkg-marker pkg-color-comp">comp</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;comp&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int CompLODeletionsAllowedElements = 1020605;


    /**
     * <span class="pkg-marker pkg-color-comp">comp</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;comp&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int CompLODeletionAllowedAttributes = 1020606;


    /**
     * <span class="pkg-marker pkg-color-comp">comp</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;comp&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int CompSubmodelAllowedAttributes = 1020607;


    /**
     * <span class="pkg-marker pkg-color-comp">comp</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;comp&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int CompModReferenceSyntax = 1020608;


    /**
     * <span class="pkg-marker pkg-color-comp">comp</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;comp&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int CompInvalidTimeConvFactorSyntax = 1020613;


    /**
     * <span class="pkg-marker pkg-color-comp">comp</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;comp&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int CompInvalidExtentConvFactorSyntax = 1020614;


    /**
     * <span class="pkg-marker pkg-color-comp">comp</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;comp&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int CompSubmodelMustReferenceModel = 1020615;


    /**
     * <span class="pkg-marker pkg-color-comp">comp</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;comp&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int CompSubmodelCannotReferenceSelf = 1020616;


    /**
     * <span class="pkg-marker pkg-color-comp">comp</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;comp&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int CompModCannotCircularlyReferenceSelf = 1020617;


    /**
     * <span class="pkg-marker pkg-color-comp">comp</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;comp&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int CompTimeConversionMustBeParameter = 1020622;


    /**
     * <span class="pkg-marker pkg-color-comp">comp</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;comp&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int CompExtentConversionMustBeParameter = 1020623;


    /**
     * <span class="pkg-marker pkg-color-comp">comp</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;comp&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int CompPortRefMustReferencePort = 1020701;


    /**
     * <span class="pkg-marker pkg-color-comp">comp</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;comp&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int CompIdRefMustReferenceObject = 1020702;


    /**
     * <span class="pkg-marker pkg-color-comp">comp</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;comp&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int CompUnitRefMustReferenceUnitDef = 1020703;


    /**
     * <span class="pkg-marker pkg-color-comp">comp</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;comp&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int CompMetaIdRefMustReferenceObject = 1020704;


    /**
     * <span class="pkg-marker pkg-color-comp">comp</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;comp&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int CompParentOfSBRefChildMustBeSubmodel = 1020705;


    /**
     * <span class="pkg-marker pkg-color-comp">comp</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;comp&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int CompInvalidPortRefSyntax = 1020706;


    /**
     * <span class="pkg-marker pkg-color-comp">comp</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;comp&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int CompInvalidIdRefSyntax = 1020707;


    /**
     * <span class="pkg-marker pkg-color-comp">comp</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;comp&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int CompInvalidUnitRefSyntax = 1020708;


    /**
     * <span class="pkg-marker pkg-color-comp">comp</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;comp&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int CompInvalidMetaIdRefSyntax = 1020709;


    /**
     * <span class="pkg-marker pkg-color-comp">comp</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;comp&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int CompOneSBaseRefOnly = 1020710;


    /**
     * <span class="pkg-marker pkg-color-comp">comp</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;comp&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int CompDeprecatedSBaseRefSpelling = 1020711;


    /**
     * <span class="pkg-marker pkg-color-comp">comp</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;comp&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int CompSBaseRefMustReferenceObject = 1020712;


    /**
     * <span class="pkg-marker pkg-color-comp">comp</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;comp&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int CompSBaseRefMustReferenceOnlyOneObject = 1020713;


    /**
     * <span class="pkg-marker pkg-color-comp">comp</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;comp&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int CompNoMultipleReferences = 1020714;


    /**
     * <span class="pkg-marker pkg-color-comp">comp</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;comp&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int CompPortMustReferenceObject = 1020801;


    /**
     * <span class="pkg-marker pkg-color-comp">comp</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;comp&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int CompPortMustReferenceOnlyOneObject = 1020802;


    /**
     * <span class="pkg-marker pkg-color-comp">comp</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;comp&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int CompPortAllowedAttributes = 1020803;


    /**
     * <span class="pkg-marker pkg-color-comp">comp</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;comp&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int CompPortReferencesUnique = 1020804;


    /**
     * <span class="pkg-marker pkg-color-comp">comp</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;comp&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int CompDeletionMustReferenceObject = 1020901;


    /**
     * <span class="pkg-marker pkg-color-comp">comp</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;comp&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int CompDeletionMustReferOnlyOneObject = 1020902;


    /**
     * <span class="pkg-marker pkg-color-comp">comp</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;comp&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int CompDeletionAllowedAttributes = 1020903;


    /**
     * <span class="pkg-marker pkg-color-comp">comp</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;comp&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int CompReplacedElementMustRefObject = 1021001;


    /**
     * <span class="pkg-marker pkg-color-comp">comp</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;comp&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int CompReplacedElementMustRefOnlyOne = 1021002;


    /**
     * <span class="pkg-marker pkg-color-comp">comp</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;comp&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int CompReplacedElementAllowedAttributes = 1021003;


    /**
     * <span class="pkg-marker pkg-color-comp">comp</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;comp&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int CompReplacedElementSubModelRef = 1021004;


    /**
     * <span class="pkg-marker pkg-color-comp">comp</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;comp&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int CompReplacedElementDeletionRef = 1021005;


    /**
     * <span class="pkg-marker pkg-color-comp">comp</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;comp&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int CompReplacedElementConvFactorRef = 1021006;


    /**
     * <span class="pkg-marker pkg-color-comp">comp</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;comp&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int CompReplacedElementSameReference = 1021010;


    /**
     * <span class="pkg-marker pkg-color-comp">comp</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;comp&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int CompReplacedElementNoDelAndConvFact = 1021011;


    /**
     * <span class="pkg-marker pkg-color-comp">comp</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;comp&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int CompReplacedByMustRefObject = 1021101;


    /**
     * <span class="pkg-marker pkg-color-comp">comp</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;comp&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int CompReplacedByMustRefOnlyOne = 1021102;


    /**
     * <span class="pkg-marker pkg-color-comp">comp</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;comp&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int CompReplacedByAllowedAttributes = 1021103;


    /**
     * <span class="pkg-marker pkg-color-comp">comp</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;comp&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int CompReplacedBySubModelRef = 1021104;


    /**
     * <span class="pkg-marker pkg-color-comp">comp</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;comp&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int CompMustReplaceSameClass = 1021201;


    /**
     * <span class="pkg-marker pkg-color-comp">comp</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;comp&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int CompMustReplaceIDs = 1021202;


    /**
     * <span class="pkg-marker pkg-color-comp">comp</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;comp&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int CompMustReplaceMetaIDs = 1021203;


    /**
     * <span class="pkg-marker pkg-color-comp">comp</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;comp&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int CompMustReplacePackageIDs = 1021204;


    /**
     * <span class="pkg-marker pkg-color-comp">comp</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;comp&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int CompUnresolvedReference = 1090101;


    /**
     * <span class="pkg-marker pkg-color-comp">comp</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;comp&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int CompNoModelInReference = 1090102;


    /**
     * <span class="pkg-marker pkg-color-comp">comp</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;comp&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int CompExtModDefBad = 1090103;


    /**
     * <span class="pkg-marker pkg-color-comp">comp</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;comp&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int CompModelFlatteningFailed = 1090104;


    /**
     * <span class="pkg-marker pkg-color-comp">comp</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;comp&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int CompFlatModelNotValid = 1090105;


    /**
     * <span class="pkg-marker pkg-color-comp">comp</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;comp&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int CompLineNumbersUnreliable = 1090106;


    /**
     * <span class="pkg-marker pkg-color-comp">comp</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;comp&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int CompFlatteningNotRecognisedReqd = 1090107;


    /**
     * <span class="pkg-marker pkg-color-comp">comp</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;comp&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int CompFlatteningNotRecognisedNotReqd = 1090108;


    /**
     * <span class="pkg-marker pkg-color-comp">comp</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;comp&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int CompFlatteningNotImplementedNotReqd = 1090109;


    /**
     * <span class="pkg-marker pkg-color-comp">comp</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;comp&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int CompFlatteningNotImplementedReqd = 1090110;


    /**
     * <span class="pkg-marker pkg-color-comp">comp</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;comp&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int CompFlatteningWarning = 1090111;


    /**
     * <span class="pkg-marker pkg-color-comp">comp</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;comp&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int CompDeprecatedDeleteFunction = 1090112;


    /**
     * <span class="pkg-marker pkg-color-comp">comp</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;comp&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int CompDeprecatedReplaceFunction = 1090113;


    /**
     * <span class="pkg-marker pkg-color-comp">comp</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;comp&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int CompDeletedReplacement = 1090114;


    /**
     * <span class="pkg-marker pkg-color-comp">comp</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;comp&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int CompIdRefMayReferenceUnknownPackage = 1090115;


    /**
     * <span class="pkg-marker pkg-color-comp">comp</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;comp&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int CompMetaIdRefMayReferenceUnknownPkg = 1090116;


    // FbcSBMLErrorCode_t 

    /**
     * <span class="pkg-marker pkg-color-fbc">fbc</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;fbc&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int FbcUnknown = 2010100;


    /**
     * <span class="pkg-marker pkg-color-fbc">fbc</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;fbc&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int FbcNSUndeclared = 2010101;


    /**
     * <span class="pkg-marker pkg-color-fbc">fbc</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;fbc&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int FbcElementNotInNs = 2010102;


    /**
     * <span class="pkg-marker pkg-color-fbc">fbc</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;fbc&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int FbcDuplicateComponentId = 2010301;


    /**
     * <span class="pkg-marker pkg-color-fbc">fbc</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;fbc&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int FbcSBMLSIdSyntax = 2010302;


    /**
     * <span class="pkg-marker pkg-color-fbc">fbc</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;fbc&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int FbcAttributeRequiredMissing = 2020101;


    /**
     * <span class="pkg-marker pkg-color-fbc">fbc</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;fbc&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int FbcAttributeRequiredMustBeBoolean = 2020102;


    /**
     * <span class="pkg-marker pkg-color-fbc">fbc</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;fbc&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int FbcRequiredFalse = 2020103;


    /**
     * <span class="pkg-marker pkg-color-fbc">fbc</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;fbc&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int FbcOnlyOneEachListOf = 2020201;


    /**
     * <span class="pkg-marker pkg-color-fbc">fbc</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;fbc&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int FbcNoEmptyListOfs = 2020202;


    /**
     * <span class="pkg-marker pkg-color-fbc">fbc</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;fbc&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int FbcLOFluxBoundsAllowedElements = 2020203;


    /**
     * <span class="pkg-marker pkg-color-fbc">fbc</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;fbc&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int FbcLOObjectivesAllowedElements = 2020204;


    /**
     * <span class="pkg-marker pkg-color-fbc">fbc</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;fbc&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int FbcLOFluxBoundsAllowedAttributes = 2020205;


    /**
     * <span class="pkg-marker pkg-color-fbc">fbc</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;fbc&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int FbcLOObjectivesAllowedAttributes = 2020206;


    /**
     * <span class="pkg-marker pkg-color-fbc">fbc</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;fbc&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int FbcActiveObjectiveSyntax = 2020207;


    /**
     * <span class="pkg-marker pkg-color-fbc">fbc</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;fbc&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int FbcActiveObjectiveRefersObjective = 2020208;


    /**
     * <span class="pkg-marker pkg-color-fbc">fbc</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;fbc&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int FbcSpeciesAllowedL3Attributes = 2020301;


    /**
     * <span class="pkg-marker pkg-color-fbc">fbc</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;fbc&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int FbcSpeciesChargeMustBeInteger = 2020302;


    /**
     * <span class="pkg-marker pkg-color-fbc">fbc</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;fbc&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int FbcSpeciesFormulaMustBeString = 2020303;


    /**
     * <span class="pkg-marker pkg-color-fbc">fbc</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;fbc&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int FbcFluxBoundAllowedL3Attributes = 2020401;


    /**
     * <span class="pkg-marker pkg-color-fbc">fbc</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;fbc&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int FbcFluxBoundAllowedElements = 2020402;


    /**
     * <span class="pkg-marker pkg-color-fbc">fbc</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;fbc&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int FbcFluxBoundRequiredAttributes = 2020403;


    /**
     * <span class="pkg-marker pkg-color-fbc">fbc</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;fbc&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int FbcFluxBoundRectionMustBeSIdRef = 2020404;


    /**
     * <span class="pkg-marker pkg-color-fbc">fbc</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;fbc&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int FbcFluxBoundNameMustBeString = 2020405;


    /**
     * <span class="pkg-marker pkg-color-fbc">fbc</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;fbc&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int FbcFluxBoundOperationMustBeEnum = 2020406;


    /**
     * <span class="pkg-marker pkg-color-fbc">fbc</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;fbc&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int FbcFluxBoundValueMustBeDouble = 2020407;


    /**
     * <span class="pkg-marker pkg-color-fbc">fbc</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;fbc&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int FbcFluxBoundReactionMustExist = 2020408;


    /**
     * <span class="pkg-marker pkg-color-fbc">fbc</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;fbc&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int FbcFluxBoundsForReactionConflict = 2020409;


    /**
     * <span class="pkg-marker pkg-color-fbc">fbc</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;fbc&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int FbcObjectiveAllowedL3Attributes = 2020501;


    /**
     * <span class="pkg-marker pkg-color-fbc">fbc</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;fbc&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int FbcObjectiveAllowedElements = 2020502;


    /**
     * <span class="pkg-marker pkg-color-fbc">fbc</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;fbc&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int FbcObjectiveRequiredAttributes = 2020503;


    /**
     * <span class="pkg-marker pkg-color-fbc">fbc</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;fbc&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int FbcObjectiveNameMustBeString = 2020504;


    /**
     * <span class="pkg-marker pkg-color-fbc">fbc</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;fbc&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int FbcObjectiveTypeMustBeEnum = 2020505;


    /**
     * <span class="pkg-marker pkg-color-fbc">fbc</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;fbc&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int FbcObjectiveOneListOfObjectives = 2020506;


    /**
     * <span class="pkg-marker pkg-color-fbc">fbc</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;fbc&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int FbcObjectiveLOFluxObjMustNotBeEmpty = 2020507;


    /**
     * <span class="pkg-marker pkg-color-fbc">fbc</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;fbc&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int FbcObjectiveLOFluxObjOnlyFluxObj = 2020508;


    /**
     * <span class="pkg-marker pkg-color-fbc">fbc</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;fbc&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int FbcObjectiveLOFluxObjAllowedAttribs = 2020509;


    /**
     * <span class="pkg-marker pkg-color-fbc">fbc</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;fbc&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int FbcFluxObjectAllowedL3Attributes = 2020601;


    /**
     * <span class="pkg-marker pkg-color-fbc">fbc</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;fbc&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int FbcFluxObjectAllowedElements = 2020602;


    /**
     * <span class="pkg-marker pkg-color-fbc">fbc</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;fbc&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int FbcFluxObjectRequiredAttributes = 2020603;


    /**
     * <span class="pkg-marker pkg-color-fbc">fbc</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;fbc&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int FbcFluxObjectNameMustBeString = 2020604;


    /**
     * <span class="pkg-marker pkg-color-fbc">fbc</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;fbc&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int FbcFluxObjectReactionMustBeSIdRef = 2020605;


    /**
     * <span class="pkg-marker pkg-color-fbc">fbc</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;fbc&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int FbcFluxObjectReactionMustExist = 2020606;


    /**
     * <span class="pkg-marker pkg-color-fbc">fbc</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;fbc&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int FbcFluxObjectCoefficientMustBeDouble = 2020607;


    // LayoutSBMLErrorCode_t 

    /**
     * <span class="pkg-marker pkg-color-layout">layout</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;layout&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int LayoutUnknownError = 6010100;


    /**
     * <span class="pkg-marker pkg-color-layout">layout</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;layout&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int LayoutNSUndeclared = 6010101;


    /**
     * <span class="pkg-marker pkg-color-layout">layout</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;layout&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int LayoutElementNotInNs = 6010102;


    /**
     * <span class="pkg-marker pkg-color-layout">layout</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;layout&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int LayoutDuplicateComponentId = 6010301;


    /**
     * <span class="pkg-marker pkg-color-layout">layout</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;layout&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int LayoutSIdSyntax = 6010302;


    /**
     * <span class="pkg-marker pkg-color-layout">layout</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;layout&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int LayoutXsiTypeAllowedLocations = 6010401;


    /**
     * <span class="pkg-marker pkg-color-layout">layout</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;layout&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int LayoutXsiTypeSyntax = 6010402;


    /**
     * <span class="pkg-marker pkg-color-layout">layout</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;layout&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int LayoutAttributeRequiredMissing = 6020101;


    /**
     * <span class="pkg-marker pkg-color-layout">layout</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;layout&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int LayoutAttributeRequiredMustBeBoolean = 6020102;


    /**
     * <span class="pkg-marker pkg-color-layout">layout</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;layout&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int LayoutRequiredFalse = 6020103;


    /**
     * <span class="pkg-marker pkg-color-layout">layout</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;layout&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int LayoutOnlyOneLOLayouts = 6020201;


    /**
     * <span class="pkg-marker pkg-color-layout">layout</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;layout&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int LayoutLOLayoutsNotEmpty = 6020202;


    /**
     * <span class="pkg-marker pkg-color-layout">layout</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;layout&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int LayoutLOLayoutsAllowedElements = 6020203;


    /**
     * <span class="pkg-marker pkg-color-layout">layout</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;layout&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int LayoutLOLayoutsAllowedAttributes = 6020204;


    /**
     * <span class="pkg-marker pkg-color-layout">layout</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;layout&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int LayoutLayoutAllowedElements = 6020301;


    /**
     * <span class="pkg-marker pkg-color-layout">layout</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;layout&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int LayoutLayoutAllowedCoreAttributes = 6020302;


    /**
     * <span class="pkg-marker pkg-color-layout">layout</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;layout&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int LayoutOnlyOneEachListOf = 6020303;


    /**
     * <span class="pkg-marker pkg-color-layout">layout</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;layout&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int LayoutNoEmptyListOfs = 6020304;


    /**
     * <span class="pkg-marker pkg-color-layout">layout</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;layout&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int LayoutLayoutAllowedAttributes = 6020305;


    /**
     * <span class="pkg-marker pkg-color-layout">layout</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;layout&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int LayoutLayoutNameMustBeString = 6020306;


    /**
     * <span class="pkg-marker pkg-color-layout">layout</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;layout&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int LayoutLOCompGlyphAllowedAttributes = 6020307;


    /**
     * <span class="pkg-marker pkg-color-layout">layout</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;layout&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int LayoutLOCompGlyphAllowedElements = 6020308;


    /**
     * <span class="pkg-marker pkg-color-layout">layout</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;layout&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int LayoutLOSpeciesGlyphAllowedAttributes = 6020309;


    /**
     * <span class="pkg-marker pkg-color-layout">layout</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;layout&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int LayoutLOSpeciesGlyphAllowedElements = 6020310;


    /**
     * <span class="pkg-marker pkg-color-layout">layout</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;layout&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int LayoutLORnGlyphAllowedAttributes = 6020311;


    /**
     * <span class="pkg-marker pkg-color-layout">layout</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;layout&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int LayoutLORnGlyphAllowedElements = 6020312;


    /**
     * <span class="pkg-marker pkg-color-layout">layout</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;layout&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int LayoutLOAddGOAllowedAttribut = 6020313;


    /**
     * <span class="pkg-marker pkg-color-layout">layout</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;layout&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int LayoutLOAddGOAllowedElements = 6020314;


    /**
     * <span class="pkg-marker pkg-color-layout">layout</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;layout&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int LayoutLayoutMustHaveDimensions = 6020315;


    /**
     * <span class="pkg-marker pkg-color-layout">layout</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;layout&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int LayoutLOTextGlyphAllowedAttributes = 6020316;


    /**
     * <span class="pkg-marker pkg-color-layout">layout</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;layout&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int LayoutLOTextGlyphAllowedElements = 6020317;


    /**
     * <span class="pkg-marker pkg-color-layout">layout</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;layout&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int LayoutGOAllowedCoreElements = 6020401;


    /**
     * <span class="pkg-marker pkg-color-layout">layout</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;layout&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int LayoutGOAllowedCoreAttributes = 6020402;


    /**
     * <span class="pkg-marker pkg-color-layout">layout</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;layout&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int LayoutGOAllowedElements = 6020403;


    /**
     * <span class="pkg-marker pkg-color-layout">layout</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;layout&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int LayoutGOAllowedAttributes = 6020404;


    /**
     * <span class="pkg-marker pkg-color-layout">layout</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;layout&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int LayoutGOMetaIdRefMustBeIDREF = 6020405;


    /**
     * <span class="pkg-marker pkg-color-layout">layout</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;layout&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int LayoutGOMetaIdRefMustReferenceObject = 6020406;


    /**
     * <span class="pkg-marker pkg-color-layout">layout</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;layout&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int LayoutGOMustContainBoundingBox = 6020407;


    /**
     * <span class="pkg-marker pkg-color-layout">layout</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;layout&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int LayoutCGAllowedCoreElements = 6020501;


    /**
     * <span class="pkg-marker pkg-color-layout">layout</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;layout&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int LayoutCGAllowedCoreAttributes = 6020502;


    /**
     * <span class="pkg-marker pkg-color-layout">layout</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;layout&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int LayoutCGAllowedElements = 6020503;


    /**
     * <span class="pkg-marker pkg-color-layout">layout</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;layout&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int LayoutCGAllowedAttributes = 6020504;


    /**
     * <span class="pkg-marker pkg-color-layout">layout</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;layout&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int LayoutCGMetaIdRefMustBeIDREF = 6020505;


    /**
     * <span class="pkg-marker pkg-color-layout">layout</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;layout&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int LayoutCGMetaIdRefMustReferenceObject = 6020506;


    /**
     * <span class="pkg-marker pkg-color-layout">layout</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;layout&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int LayoutCGCompartmentSyntax = 6020507;


    /**
     * <span class="pkg-marker pkg-color-layout">layout</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;layout&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int LayoutCGCompartmentMustRefComp = 6020508;


    /**
     * <span class="pkg-marker pkg-color-layout">layout</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;layout&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int LayoutCGNoDuplicateReferences = 6020509;


    /**
     * <span class="pkg-marker pkg-color-layout">layout</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;layout&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int LayoutCGOrderMustBeDouble = 6020510;


    /**
     * <span class="pkg-marker pkg-color-layout">layout</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;layout&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int LayoutSGAllowedCoreElements = 6020601;


    /**
     * <span class="pkg-marker pkg-color-layout">layout</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;layout&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int LayoutSGAllowedCoreAttributes = 6020602;


    /**
     * <span class="pkg-marker pkg-color-layout">layout</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;layout&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int LayoutSGAllowedElements = 6020603;


    /**
     * <span class="pkg-marker pkg-color-layout">layout</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;layout&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int LayoutSGAllowedAttributes = 6020604;


    /**
     * <span class="pkg-marker pkg-color-layout">layout</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;layout&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int LayoutSGMetaIdRefMustBeIDREF = 6020605;


    /**
     * <span class="pkg-marker pkg-color-layout">layout</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;layout&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int LayoutSGMetaIdRefMustReferenceObject = 6020606;


    /**
     * <span class="pkg-marker pkg-color-layout">layout</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;layout&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int LayoutSGSpeciesSyntax = 6020607;


    /**
     * <span class="pkg-marker pkg-color-layout">layout</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;layout&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int LayoutSGSpeciesMustRefSpecies = 6020608;


    /**
     * <span class="pkg-marker pkg-color-layout">layout</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;layout&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int LayoutSGNoDuplicateReferences = 6020609;


    /**
     * <span class="pkg-marker pkg-color-layout">layout</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;layout&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int LayoutRGAllowedCoreElements = 6020701;


    /**
     * <span class="pkg-marker pkg-color-layout">layout</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;layout&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int LayoutRGAllowedCoreAttributes = 6020702;


    /**
     * <span class="pkg-marker pkg-color-layout">layout</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;layout&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int LayoutRGAllowedElements = 6020703;


    /**
     * <span class="pkg-marker pkg-color-layout">layout</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;layout&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int LayoutRGAllowedAttributes = 6020704;


    /**
     * <span class="pkg-marker pkg-color-layout">layout</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;layout&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int LayoutRGMetaIdRefMustBeIDREF = 6020705;


    /**
     * <span class="pkg-marker pkg-color-layout">layout</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;layout&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int LayoutRGMetaIdRefMustReferenceObject = 6020706;


    /**
     * <span class="pkg-marker pkg-color-layout">layout</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;layout&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int LayoutRGReactionSyntax = 6020707;


    /**
     * <span class="pkg-marker pkg-color-layout">layout</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;layout&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int LayoutRGReactionMustRefReaction = 6020708;


    /**
     * <span class="pkg-marker pkg-color-layout">layout</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;layout&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int LayoutRGNoDuplicateReferences = 6020709;


    /**
     * <span class="pkg-marker pkg-color-layout">layout</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;layout&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int LayoutLOSpeciesRefGlyphAllowedElements = 6020710;


    /**
     * <span class="pkg-marker pkg-color-layout">layout</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;layout&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int LayoutLOSpeciesRefGlyphAllowedAttribs = 6020711;


    /**
     * <span class="pkg-marker pkg-color-layout">layout</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;layout&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int LayoutLOSpeciesRefGlyphNotEmpty = 6020712;


    /**
     * <span class="pkg-marker pkg-color-layout">layout</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;layout&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int LayoutGGAllowedCoreElements = 6020801;


    /**
     * <span class="pkg-marker pkg-color-layout">layout</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;layout&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int LayoutGGAllowedCoreAttributes = 6020802;


    /**
     * <span class="pkg-marker pkg-color-layout">layout</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;layout&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int LayoutGGAllowedElements = 6020803;


    /**
     * <span class="pkg-marker pkg-color-layout">layout</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;layout&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int LayoutGGAllowedAttributes = 6020804;


    /**
     * <span class="pkg-marker pkg-color-layout">layout</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;layout&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int LayoutGGMetaIdRefMustBeIDREF = 6020805;


    /**
     * <span class="pkg-marker pkg-color-layout">layout</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;layout&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int LayoutGGMetaIdRefMustReferenceObject = 6020806;


    /**
     * <span class="pkg-marker pkg-color-layout">layout</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;layout&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int LayoutGGReferenceSyntax = 6020807;


    /**
     * <span class="pkg-marker pkg-color-layout">layout</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;layout&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int LayoutGGReferenceMustRefObject = 6020808;


    /**
     * <span class="pkg-marker pkg-color-layout">layout</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;layout&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int LayoutGGNoDuplicateReferences = 6020809;


    /**
     * <span class="pkg-marker pkg-color-layout">layout</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;layout&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int LayoutLOReferenceGlyphAllowedElements = 6020810;


    /**
     * <span class="pkg-marker pkg-color-layout">layout</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;layout&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int LayoutLOReferenceGlyphAllowedAttribs = 6020811;


    /**
     * <span class="pkg-marker pkg-color-layout">layout</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;layout&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int LayoutLOSubGlyphAllowedElements = 6020812;


    /**
     * <span class="pkg-marker pkg-color-layout">layout</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;layout&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int LayoutLOSubGlyphAllowedAttribs = 6020813;


    /**
     * <span class="pkg-marker pkg-color-layout">layout</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;layout&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int LayoutTGAllowedCoreElements = 6020901;


    /**
     * <span class="pkg-marker pkg-color-layout">layout</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;layout&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int LayoutTGAllowedCoreAttributes = 6020902;


    /**
     * <span class="pkg-marker pkg-color-layout">layout</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;layout&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int LayoutTGAllowedElements = 6020903;


    /**
     * <span class="pkg-marker pkg-color-layout">layout</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;layout&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int LayoutTGAllowedAttributes = 6020904;


    /**
     * <span class="pkg-marker pkg-color-layout">layout</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;layout&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int LayoutTGMetaIdRefMustBeIDREF = 6020905;


    /**
     * <span class="pkg-marker pkg-color-layout">layout</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;layout&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int LayoutTGMetaIdRefMustReferenceObject = 6020906;


    /**
     * <span class="pkg-marker pkg-color-layout">layout</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;layout&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int LayoutTGOriginOfTextSyntax = 6020907;


    /**
     * <span class="pkg-marker pkg-color-layout">layout</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;layout&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int LayoutTGOriginOfTextMustRefObject = 6020908;


    /**
     * <span class="pkg-marker pkg-color-layout">layout</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;layout&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int LayoutTGNoDuplicateReferences = 6020909;


    /**
     * <span class="pkg-marker pkg-color-layout">layout</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;layout&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int LayoutTGGraphicalObjectSyntax = 6020910;


    /**
     * <span class="pkg-marker pkg-color-layout">layout</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;layout&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int LayoutTGGraphicalObjectMustRefObject = 6020911;


    /**
     * <span class="pkg-marker pkg-color-layout">layout</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;layout&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int LayoutTGTextMustBeString = 6020912;


    /**
     * <span class="pkg-marker pkg-color-layout">layout</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;layout&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int LayoutSRGAllowedCoreElements = 6021001;


    /**
     * <span class="pkg-marker pkg-color-layout">layout</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;layout&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int LayoutSRGAllowedCoreAttributes = 6021002;


    /**
     * <span class="pkg-marker pkg-color-layout">layout</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;layout&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int LayoutSRGAllowedElements = 6021003;


    /**
     * <span class="pkg-marker pkg-color-layout">layout</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;layout&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int LayoutSRGAllowedAttributes = 6021004;


    /**
     * <span class="pkg-marker pkg-color-layout">layout</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;layout&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int LayoutSRGMetaIdRefMustBeIDREF = 6021005;


    /**
     * <span class="pkg-marker pkg-color-layout">layout</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;layout&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int LayoutSRGMetaIdRefMustReferenceObject = 6021006;


    /**
     * <span class="pkg-marker pkg-color-layout">layout</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;layout&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int LayoutSRGSpeciesReferenceSyntax = 6021007;


    /**
     * <span class="pkg-marker pkg-color-layout">layout</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;layout&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int LayoutSRGSpeciesRefMustRefObject = 6021008;


    /**
     * <span class="pkg-marker pkg-color-layout">layout</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;layout&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int LayoutSRGNoDuplicateReferences = 6021009;


    /**
     * <span class="pkg-marker pkg-color-layout">layout</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;layout&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int LayoutSRGSpeciesGlyphSyntax = 6021010;


    /**
     * <span class="pkg-marker pkg-color-layout">layout</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;layout&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int LayoutSRGSpeciesGlyphMustRefObject = 6021011;


    /**
     * <span class="pkg-marker pkg-color-layout">layout</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;layout&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int LayoutSRGRoleSyntax = 6021012;


    /**
     * <span class="pkg-marker pkg-color-layout">layout</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;layout&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int LayoutREFGAllowedCoreElements = 6021101;


    /**
     * <span class="pkg-marker pkg-color-layout">layout</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;layout&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int LayoutREFGAllowedCoreAttributes = 6021102;


    /**
     * <span class="pkg-marker pkg-color-layout">layout</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;layout&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int LayoutREFGAllowedElements = 6021103;


    /**
     * <span class="pkg-marker pkg-color-layout">layout</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;layout&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int LayoutREFGAllowedAttributes = 6021104;


    /**
     * <span class="pkg-marker pkg-color-layout">layout</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;layout&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int LayoutREFGMetaIdRefMustBeIDREF = 6021105;


    /**
     * <span class="pkg-marker pkg-color-layout">layout</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;layout&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int LayoutREFGMetaIdRefMustReferenceObject = 6021106;


    /**
     * <span class="pkg-marker pkg-color-layout">layout</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;layout&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int LayoutREFGReferenceSyntax = 6021107;


    /**
     * <span class="pkg-marker pkg-color-layout">layout</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;layout&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int LayoutREFGReferenceMustRefObject = 6021108;


    /**
     * <span class="pkg-marker pkg-color-layout">layout</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;layout&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int LayoutREFGNoDuplicateReferences = 6021109;


    /**
     * <span class="pkg-marker pkg-color-layout">layout</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;layout&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int LayoutREFGGlyphSyntax = 6021110;


    /**
     * <span class="pkg-marker pkg-color-layout">layout</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;layout&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int LayoutREFGGlyphMustRefObject = 6021111;


    /**
     * <span class="pkg-marker pkg-color-layout">layout</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;layout&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int LayoutREFGRoleSyntax = 6021112;


    /**
     * <span class="pkg-marker pkg-color-layout">layout</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;layout&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int LayoutPointAllowedCoreElements = 6021201;


    /**
     * <span class="pkg-marker pkg-color-layout">layout</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;layout&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int LayoutPointAllowedCoreAttributes = 6021202;


    /**
     * <span class="pkg-marker pkg-color-layout">layout</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;layout&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int LayoutPointAllowedAttributes = 6021203;


    /**
     * <span class="pkg-marker pkg-color-layout">layout</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;layout&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int LayoutPointAttributesMustBeDouble = 6021204;


    /**
     * <span class="pkg-marker pkg-color-layout">layout</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;layout&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int LayoutBBoxAllowedCoreElements = 6021301;


    /**
     * <span class="pkg-marker pkg-color-layout">layout</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;layout&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int LayoutBBoxAllowedCoreAttributes = 6021302;


    /**
     * <span class="pkg-marker pkg-color-layout">layout</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;layout&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int LayoutBBoxAllowedElements = 6021303;


    /**
     * <span class="pkg-marker pkg-color-layout">layout</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;layout&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int LayoutBBoxAllowedAttributes = 6021304;


    /**
     * <span class="pkg-marker pkg-color-layout">layout</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;layout&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int LayoutBBoxConsistent3DDefinition = 6021305;


    /**
     * <span class="pkg-marker pkg-color-layout">layout</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;layout&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int LayoutCurveAllowedCoreElements = 6021401;


    /**
     * <span class="pkg-marker pkg-color-layout">layout</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;layout&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int LayoutCurveAllowedCoreAttributes = 6021402;


    /**
     * <span class="pkg-marker pkg-color-layout">layout</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;layout&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int LayoutCurveAllowedElements = 6021403;


    /**
     * <span class="pkg-marker pkg-color-layout">layout</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;layout&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int LayoutCurveAllowedAttributes = 6021404;


    /**
     * <span class="pkg-marker pkg-color-layout">layout</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;layout&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int LayoutLOCurveSegsAllowedAttributes = 6021405;


    /**
     * <span class="pkg-marker pkg-color-layout">layout</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;layout&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int LayoutLOCurveSegsAllowedElements = 6021406;


    /**
     * <span class="pkg-marker pkg-color-layout">layout</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;layout&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int LayoutLOCurveSegsNotEmpty = 6021407;


    /**
     * <span class="pkg-marker pkg-color-layout">layout</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;layout&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int LayoutLSegAllowedCoreElements = 6021501;


    /**
     * <span class="pkg-marker pkg-color-layout">layout</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;layout&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int LayoutLSegAllowedCoreAttributes = 6021502;


    /**
     * <span class="pkg-marker pkg-color-layout">layout</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;layout&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int LayoutLSegAllowedElements = 6021503;


    /**
     * <span class="pkg-marker pkg-color-layout">layout</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;layout&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int LayoutLSegAllowedAttributes = 6021504;


    /**
     * <span class="pkg-marker pkg-color-layout">layout</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;layout&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int LayoutCBezAllowedCoreElements = 6021601;


    /**
     * <span class="pkg-marker pkg-color-layout">layout</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;layout&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int LayoutCBezAllowedCoreAttributes = 6021602;


    /**
     * <span class="pkg-marker pkg-color-layout">layout</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;layout&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int LayoutCBezAllowedElements = 6021603;


    /**
     * <span class="pkg-marker pkg-color-layout">layout</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;layout&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int LayoutCBezAllowedAttributes = 6021604;


    /**
     * <span class="pkg-marker pkg-color-layout">layout</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;layout&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int LayoutDimsAllowedCoreElements = 6021701;


    /**
     * <span class="pkg-marker pkg-color-layout">layout</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;layout&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int LayoutDimsAllowedCoreAttributes = 6021702;


    /**
     * <span class="pkg-marker pkg-color-layout">layout</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;layout&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int LayoutDimsAllowedAttributes = 6021703;


    /**
     * <span class="pkg-marker pkg-color-layout">layout</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;layout&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int LayoutDimsAttributesMustBeDouble = 6021704;


    // QualSBMLErrorCode_t 

    /**
     * <span class="pkg-marker pkg-color-qual">qual</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;qual&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int QualUnknown = 3010100;


    /**
     * <span class="pkg-marker pkg-color-qual">qual</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;qual&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int QualNSUndeclared = 3010101;


    /**
     * <span class="pkg-marker pkg-color-qual">qual</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;qual&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int QualElementNotInNs = 3010102;


    /**
     * <span class="pkg-marker pkg-color-qual">qual</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;qual&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int QualFunctionTermBool = 3010201;


    /**
     * <span class="pkg-marker pkg-color-qual">qual</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;qual&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int QualMathCSymbolDisallowed = 3010202;


    /**
     * <span class="pkg-marker pkg-color-qual">qual</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;qual&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int QualDuplicateComponentId = 3010301;


    /**
     * <span class="pkg-marker pkg-color-qual">qual</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;qual&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int QualAttributeRequiredMissing = 3020101;


    /**
     * <span class="pkg-marker pkg-color-qual">qual</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;qual&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int QualAttributeRequiredMustBeBoolean = 3020102;


    /**
     * <span class="pkg-marker pkg-color-qual">qual</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;qual&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int QualRequiredTrueIfTransitions = 3020103;


    /**
     * <span class="pkg-marker pkg-color-qual">qual</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;qual&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int QualOneListOfTransOrQS = 3020201;


    /**
     * <span class="pkg-marker pkg-color-qual">qual</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;qual&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int QualEmptyLONotAllowed = 3020202;


    /**
     * <span class="pkg-marker pkg-color-qual">qual</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;qual&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int QualLOTransitiondAllowedElements = 3020203;


    /**
     * <span class="pkg-marker pkg-color-qual">qual</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;qual&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int QualLOQualSpeciesAllowedElements = 3020204;


    /**
     * <span class="pkg-marker pkg-color-qual">qual</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;qual&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int QualLOQualSpeciesAllowedAttributes = 3020205;


    /**
     * <span class="pkg-marker pkg-color-qual">qual</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;qual&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int QualLOTransitionsAllowedAttributes = 3020206;


    /**
     * <span class="pkg-marker pkg-color-qual">qual</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;qual&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int QualQualSpeciesAllowedCoreAttributes = 3020301;


    /**
     * <span class="pkg-marker pkg-color-qual">qual</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;qual&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int QualQualSpeciesAllowedElements = 3020302;


    /**
     * <span class="pkg-marker pkg-color-qual">qual</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;qual&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int QualQualSpeciesAllowedAttributes = 3020303;


    /**
     * <span class="pkg-marker pkg-color-qual">qual</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;qual&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int QualConstantMustBeBool = 3020304;


    /**
     * <span class="pkg-marker pkg-color-qual">qual</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;qual&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int QualNameMustBeString = 3020305;


    /**
     * <span class="pkg-marker pkg-color-qual">qual</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;qual&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int QualInitialLevelMustBeInt = 3020306;


    /**
     * <span class="pkg-marker pkg-color-qual">qual</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;qual&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int QualMaxLevelMustBeInt = 3020307;


    /**
     * <span class="pkg-marker pkg-color-qual">qual</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;qual&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int QualCompartmentMustReferExisting = 3020308;


    /**
     * <span class="pkg-marker pkg-color-qual">qual</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;qual&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int QualInitialLevelCannotExceedMax = 3020309;


    /**
     * <span class="pkg-marker pkg-color-qual">qual</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;qual&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int QualConstantQSCannotBeOutput = 3020310;


    /**
     * <span class="pkg-marker pkg-color-qual">qual</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;qual&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int QualQSAssignedOnlyOnce = 3020311;


    /**
     * <span class="pkg-marker pkg-color-qual">qual</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;qual&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int QualInitalLevelNotNegative = 3020312;


    /**
     * <span class="pkg-marker pkg-color-qual">qual</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;qual&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int QualMaxLevelNotNegative = 3020313;


    /**
     * <span class="pkg-marker pkg-color-qual">qual</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;qual&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int QualTransitionAllowedCoreAttributes = 3020401;


    /**
     * <span class="pkg-marker pkg-color-qual">qual</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;qual&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int QualTransitionAllowedElements = 3020402;


    /**
     * <span class="pkg-marker pkg-color-qual">qual</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;qual&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int QualTransitionAllowedAttributes = 3020403;


    /**
     * <span class="pkg-marker pkg-color-qual">qual</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;qual&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int QualTransitionNameMustBeString = 3020404;


    /**
     * <span class="pkg-marker pkg-color-qual">qual</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;qual&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int QualTransitionLOElements = 3020405;


    /**
     * <span class="pkg-marker pkg-color-qual">qual</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;qual&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int QualTransitionEmptyLOElements = 3020406;


    /**
     * <span class="pkg-marker pkg-color-qual">qual</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;qual&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int QualTransitionLOInputElements = 3020407;


    /**
     * <span class="pkg-marker pkg-color-qual">qual</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;qual&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int QualTransitionLOOutputElements = 3020408;


    /**
     * <span class="pkg-marker pkg-color-qual">qual</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;qual&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int QualTransitionLOFuncTermElements = 3020409;


    /**
     * <span class="pkg-marker pkg-color-qual">qual</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;qual&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int QualTransitionLOInputAttributes = 3020410;


    /**
     * <span class="pkg-marker pkg-color-qual">qual</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;qual&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int QualTransitionLOOutputAttributes = 3020411;


    /**
     * <span class="pkg-marker pkg-color-qual">qual</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;qual&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int QualTransitionLOFuncTermAttributes = 3020412;


    /**
     * <span class="pkg-marker pkg-color-qual">qual</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;qual&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int QualTransitionLOFuncTermExceedMax = 3020413;


    /**
     * <span class="pkg-marker pkg-color-qual">qual</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;qual&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int QualTransitionLOFuncTermNegative = 3020414;


    /**
     * <span class="pkg-marker pkg-color-qual">qual</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;qual&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int QualInputAllowedCoreAttributes = 3020501;


    /**
     * <span class="pkg-marker pkg-color-qual">qual</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;qual&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int QualInputAllowedElements = 3020502;


    /**
     * <span class="pkg-marker pkg-color-qual">qual</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;qual&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int QualInputAllowedAttributes = 3020503;


    /**
     * <span class="pkg-marker pkg-color-qual">qual</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;qual&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int QualInputNameMustBeString = 3020504;


    /**
     * <span class="pkg-marker pkg-color-qual">qual</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;qual&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int QualInputSignMustBeSignEnum = 3020505;


    /**
     * <span class="pkg-marker pkg-color-qual">qual</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;qual&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int QualInputTransEffectMustBeInputEffect = 3020506;


    /**
     * <span class="pkg-marker pkg-color-qual">qual</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;qual&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int QualInputThreshMustBeInteger = 3020507;


    /**
     * <span class="pkg-marker pkg-color-qual">qual</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;qual&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int QualInputQSMustBeExistingQS = 3020508;


    /**
     * <span class="pkg-marker pkg-color-qual">qual</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;qual&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int QualInputConstantCannotBeConsumed = 3020509;


    /**
     * <span class="pkg-marker pkg-color-qual">qual</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;qual&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int QualInputThreshMustBeNonNegative = 3020510;


    /**
     * <span class="pkg-marker pkg-color-qual">qual</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;qual&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int QualOutputAllowedCoreAttributes = 3020601;


    /**
     * <span class="pkg-marker pkg-color-qual">qual</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;qual&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int QualOutputAllowedElements = 3020602;


    /**
     * <span class="pkg-marker pkg-color-qual">qual</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;qual&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int QualOutputAllowedAttributes = 3020603;


    /**
     * <span class="pkg-marker pkg-color-qual">qual</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;qual&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int QualOutputNameMustBeString = 3020604;


    /**
     * <span class="pkg-marker pkg-color-qual">qual</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;qual&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int QualOutputTransEffectMustBeOutput = 3020605;


    /**
     * <span class="pkg-marker pkg-color-qual">qual</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;qual&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int QualOutputLevelMustBeInteger = 3020606;


    /**
     * <span class="pkg-marker pkg-color-qual">qual</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;qual&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int QualOutputQSMustBeExistingQS = 3020607;


    /**
     * <span class="pkg-marker pkg-color-qual">qual</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;qual&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int QualOutputConstantMustBeFalse = 3020608;


    /**
     * <span class="pkg-marker pkg-color-qual">qual</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;qual&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int QualOutputProductionMustHaveLevel = 3020609;


    /**
     * <span class="pkg-marker pkg-color-qual">qual</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;qual&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int QualOutputLevelMustBeNonNegative = 3020610;


    /**
     * <span class="pkg-marker pkg-color-qual">qual</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;qual&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int QualDefaultTermAllowedCoreAttributes = 3020701;


    /**
     * <span class="pkg-marker pkg-color-qual">qual</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;qual&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int QualDefaultTermAllowedElements = 3020702;


    /**
     * <span class="pkg-marker pkg-color-qual">qual</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;qual&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int QualDefaultTermAllowedAttributes = 3020703;


    /**
     * <span class="pkg-marker pkg-color-qual">qual</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;qual&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int QualDefaultTermResultMustBeInteger = 3020704;


    /**
     * <span class="pkg-marker pkg-color-qual">qual</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;qual&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int QualDefaultTermResultMustBeNonNeg = 3020705;


    /**
     * <span class="pkg-marker pkg-color-qual">qual</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;qual&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int QualFuncTermAllowedCoreAttributes = 3020801;


    /**
     * <span class="pkg-marker pkg-color-qual">qual</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;qual&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int QualFuncTermAllowedElements = 3020802;


    /**
     * <span class="pkg-marker pkg-color-qual">qual</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;qual&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int QualFuncTermAllowedAttributes = 3020803;


    /**
     * <span class="pkg-marker pkg-color-qual">qual</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;qual&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int QualFuncTermOnlyOneMath = 3020804;


    /**
     * <span class="pkg-marker pkg-color-qual">qual</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;qual&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int QualFuncTermResultMustBeInteger = 3020805;


    /**
     * <span class="pkg-marker pkg-color-qual">qual</span> A value in the
     * enumeration of all the error and warning codes generated by the
     * libSBML &ldquo;qual&rdquo; extension for objects of class {@link
     * SBMLError}.  Please consult the documentation for {@link SBMLError}
     * for an explanation of the meaning of this particular error code.
     */
    public final static int QualFuncTermResultMustBeNonNeg = 3020806;
}
