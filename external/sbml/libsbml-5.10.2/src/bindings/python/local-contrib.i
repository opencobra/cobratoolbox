/**
 * @file    local-contrib.i
 * @brief   Contributed class that makes using libSBML from python more convenient
 *          for the time being this only works for python 2.x, but won't break python 3
 * @author  Gordon Ball
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
 *----------------------------------------------------------------------- -->
 *
 * @class AutoProperty
 * @sbmlbrief{core} Metaclass to convert getX/setX methods into Python
 * properties.
 *
 * This class is attached to SBase and automatically applies for all classes
 * which inherit from it.  Its purpose is to make libSBML more convenient to
 * use from Python.  It is a metaclass for automatically detecting getX/setX
 * methods at class creation time (not instantiation), and adding properties
 * (directly calling C methods where possible) to the class dictionary.
 *
 * @note Currently this class only works for Python 2.x, but should not break
 * in Python 3.
 */

%pythoncode %{

class AutoProperty(type):
    """
    Metaclass for automatically detecting getX/setX methods and adding
    properties to the class dictionary.

    This class is attached to SBase and automatically applies for all classes
    which inherit from it.  Its purpose is to make libSBML more convenient to
    use from Python.  It works by analyzing classes at class creation time
    (not at instantiation) and adding corresponding properties (directly
    calling C methods where possible) to the class dictionary.

    @note Currently this class only works for Python 2.x, but should not break
    in Python 3.
    """
    def __new__(cls, classname, bases, classdict):
        """
        Iterate over the items in the classdict looking for get/set pairs
        and declaring them as properties.
        """

        import re
        import keyword

        re_mangle = re.compile(r'[A-Za-z][a-z]+|[A-Z]+(?=$|[A-Z0-9])|\d+')
        re_id = re.compile(r'^[A-Za-z_][A-Za-z0-9_]*$')
        re_getdoc = re.compile(r'^\s*[A-Za-z_][A-Za-z0-9_]*\(self\)')
        re_setdoc = re.compile(r'^\s*[A-Za-z_][A-Za-z0-9_]*\(self,[^,)]+\)')

        #convert ACapitalCasedStringXYZ123 -> a_capital_cased_string_xyz_123
        mangle_name = lambda x: ('_'.join(re_mangle.findall(x))).lower()

        get_methods = set()
        set_methods = set()
        swig_setter = classdict.get('__swig_setmethods__', {})

        #only search for get/set methods
        #we assume that any unset method also has either get or set
        #a small number of set without get cases exist so we can't only
        #search for get methods
        for k, v in classdict.items():
            name = k[3:]
            prefix = k[:3]
            mangled = mangle_name(name)
            if name:
                if callable(v):
                    if re_id.match(mangled) and mangled not in keyword.kwlist:
                        if prefix == 'get':
                            get_methods.add(name)
                        elif prefix == 'set':
                            set_methods.add(name)

        for name in get_methods | set_methods:

            mangled = mangle_name(name)

            #ListOfFoobars -> foobars
            if mangled.startswith('list_of_'):
                mangled = mangled[8:]

            getter = setter = deleter = None
            if name in get_methods:
                getter = classdict['get'+name]
            
                #this is a very dirty way of checking if the get method
                #requires extra arguments (and hence cannot be a property)
                #it should be possible to do this properly in SWIG?
                if getter.__doc__:
                    if not re_getdoc.match(getter.__doc__):
                        continue

                #use the c-level get function if the python function
                #only consists of a call to it
                cname = classname + '_get' + name
                #test if function is "return _libsbml.CLASS_getNAME(__args__)"
                if getter.func_code.co_names == ('_libsbml', cname):
                    getter = getattr(_libsbml, cname)
    
            if name in set_methods:
                setter = classdict['set'+name]
                if setter.__doc__:
                    if not re_setdoc.match(setter.__doc__):
                        continue

                cname = classname + '_set' + name
                if setter.func_code.co_names == ('_libsbml', cname):
                    setter = getattr(_libsbml, cname)
                #property fget does not get intercepted by __getattr__
                #but fset does, so we implement property setting via
                #the __swig_setmethods__ dict
                swig_setter[mangled] = setter
            
            if 'unset' + name in classdict:
                deleter = classdict['unset'+name]
                if deleter.__doc__:
                    #like a get method, a delete method should
                    #only require a self argument
                    if not re_getdoc.match(deleter.__doc__):
                        continue
                
                cname = classname + '_unset' + name
                if deleter.func_code.co_names == ('_libsbml', cname):
                    deleter = getattr(_libsbml, cname)

            if getter or setter or deleter:
                #fset is technically redundant since the method is dispatched
                #via _swig_setattr rather than through the property due to that
                #function not delegating to object.__setattr__ which properly
                #handles properties
                classdict[mangled] = property(fget=getter, fset=setter, fdel=deleter)

            def __repr__(self):
                desc = self.__class__.__name__
                if hasattr(self, '__len__'):
                    desc += '[%s]' % self.__len__()
                if hasattr(self, 'id') and self.id:
                    desc += ' %s' % self.id
                if hasattr(self, 'name') and self.name:
                    desc += ' "%s"' % self.name
                return '<' + desc + '>'
                
            if classdict.get('__repr__', None) in (_swig_repr, None):
                classdict['__repr__'] = __repr__


        return type.__new__(cls, classname, bases, classdict)

%}

%extend SBase
{
    %pythoncode
    {
        __metaclass__ = AutoProperty
    }
}


%extend SBasePlugin
{
    %pythoncode
    {
        __metaclass__ = AutoProperty
    }
}

