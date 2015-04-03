/**
 * \file    list_get_fix.i
 * \brief   "casts" void* return from List::get to the type of holded data 
 * \author  TBI {xtof,raim}@tbi.univie.ac.at
 * 
/* Copyright 2009 TBI
 *
 * This library is free software; you can redistribute it and/or modify it
 * under the terms of the GNU Lesser General Public License as published
 * by the Free Software Foundation; either version 2.1 of the License, or
 * any later version.
 *
 * This library is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY, WITHOUT EVEN THE IMPLIED WARRANTY OF
 * MERCHANTABILITY OR FITNESS FOR A PARTICULAR PURPOSE.  The software and
 * documentation provided hereunder is on an "as is" basis, and the
 * California Institute of Technology and Japan Science and Technology
 * Corporation have no obligations to provide maintenance, support,
 * updates, enhancements or modifications.  In no event shall the
 * California Institute of Technology or the Japan Science and Technology
 * Corporation be liable to any party for direct, indirect, special,
 * incidental or consequential damages, including lost profits, arising
 * out of the use of this software and its documentation, even if the
 * California Institute of Technology and/or Japan Science and Technology
 * Corporation have been advised of the possibility of such damage. See
 * the GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this library; if not, write to the Free Software Foundation,
 * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.
 *
 * The original code contained here was initially developed by:
 *
 *     Christoph Flamm
 *
 * Contributor(s):
 *
 *  Akiya Jouraku
 */


/**
 *  Wraps the following functions by using the corresponding
 *  ListWrapper<TYPENAME> class ( src/bindings/swig/ListWrapper.h ).
 *
 *  - List* ModelHistory::getListCreators()
 *  - List* ModelHistory::getListModifiedDates()
 *  - List* SBase::getCVTerms()
 *  - List* SBMLNamespaces::getSupportedNamespaces()
 *
 *  ListWrapper<TYPENAME> class is wrapped as ListTYPENAMEs class.
 *  So, the above functions are wrapped as follows:
 *
 *  - ModelCreatorList ModelHistory::getListCreators()
 *  - DateList         ModelHistory::getListModifiedDates()
 *  - CVTermList       SBase::getCVTerms()
 *  - SBMLNamespacesList SBMLNamespaces::getSupportedNamespaces()
 *
 */

%typemap(out) List* ModelHistory::getListCreators
{
  ListWrapper<ModelCreator> *listw = ($1 != 0) ? new ListWrapper<ModelCreator>($1) : 0;
  ST(argvi) = SWIG_NewPointerObj(SWIG_as_voidptr(listw), 
#if SWIG_VERSION > 0x010333
                                 SWIGTYPE_p_ListWrapperT_ModelCreator_t, 
#else
                                 SWIGTYPE_p_ListWrapperTModelCreator_t, 
#endif
                                 SWIG_OWNER | %newpointer_flags);
  argvi++;
}

%typemap(out) List* ModelHistory::getListModifiedDates
{
  ListWrapper<Date> *listw = ($1 != 0) ? new ListWrapper<Date>($1) : 0;
  ST(argvi) = SWIG_NewPointerObj(SWIG_as_voidptr(listw), 
#if SWIG_VERSION > 0x010333
                                 SWIGTYPE_p_ListWrapperT_Date_t, 
#else
                                 SWIGTYPE_p_ListWrapperTDate_t, 
#endif
                                 SWIG_OWNER | %newpointer_flags);
  argvi++;
}

%typemap(out) List* SBase::getCVTerms
{
  ListWrapper<CVTerm> *listw = ($1 != 0) ? new ListWrapper<CVTerm>($1) : 0;
  ST(argvi) = SWIG_NewPointerObj(SWIG_as_voidptr(listw), 
#if SWIG_VERSION > 0x010333
                                 SWIGTYPE_p_ListWrapperT_CVTerm_t, 
#else
                                 SWIGTYPE_p_ListWrapperTCVTerm_t, 
#endif
                                 SWIG_OWNER | %newpointer_flags);
  argvi++;
}

%feature("shadow")
ModelHistory::getListModifiedDates()
%{
  sub getListModifiedDates {
    my $lox = LibSBMLc::ModelHistory_getListModifiedDates(@_);
    my @lox = ();
    for (my $i=0; $i<$lox->getSize(); $i++) {
      push @lox, $lox->get($i);
    }
    return wantarray ? @lox : $lox;
  }
%}

%feature("shadow")
ModelHistory::getListCreators()
%{
  sub getListCreators {
    my $lox = LibSBMLc::ModelHistory_getListCreators(@_);
    my @lox = ();
    for (my $i=0; $i<$lox->getSize(); $i++) {
      push @lox, $lox->get($i);
    }
    return wantarray ? @lox : $lox;
  }
%}

%feature("shadow")
SBase::getCVTerms()
%{
  sub getCVTerms {
    my $lox = LibSBMLc::SBase_getCVTerms(@_);
    my @lox = ();
    for (my $i=0; $i<$lox->getSize(); $i++) {
      push @lox, $lox->get($i);
    }
    return wantarray ? @lox : $lox;
  }
%}

%typemap(out) List* SBMLNamespaces::getSupportedNamespaces
{
  ListWrapper<SBMLNamespaces> *listw = ($1 != 0) ? new ListWrapper<SBMLNamespaces>($1) : 0;
  ST(argvi) = SWIG_NewPointerObj(SWIG_as_voidptr(listw), 
#if SWIG_VERSION > 0x010333
                                 SWIGTYPE_p_ListWrapperT_SBMLNamespaces_t, 
#else
                                 SWIGTYPE_p_ListWrapperTSBMLNamespaces_t, 
#endif
                                 SWIG_OWNER | %newpointer_flags);
  argvi++;
}

%feature("shadow")
SBMLNamespaces::getSupportedNamespaces()
%{
  sub getSupportedNamespaces {
    my $lox = LibSBMLc::SBMLNamespaces_getSupportedNamespaces(@_);
    my @lox = ();
    for (my $i=0; $i<$lox->getSize(); $i++) {
      push @lox, $lox->get($i);
    }
    return wantarray ? @lox : $lox;
  }
%}
