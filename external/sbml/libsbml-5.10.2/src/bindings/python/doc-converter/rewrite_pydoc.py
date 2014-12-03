#!/usr/bin/env python
##
## @file    rewrite_pydoc.py
## @brief   Convert libSBML Python doc file to something readable as docstrings
## @author  Mike Hucka
##
## Purpose:
## 
## The comments in the libSBML source code use Doxygen mark-up; this
## content is read by Doxygen and Javadoc, in combination with other
## scripts, to produce the libSBML API documentation in the libSBML "docs"
## directory.  When creating the Python language interface, SWIG takes the
## comments and inserts them as documentation strings in the Python code,
## which is good from the perspective of being an easy way to provide help
## for the Python interface classes and methods, but bad from the
## perspective that it is full of Doxygen markup and not suitable for
## direct reading by humans.
## 
## This program converts the Doxygen-based documentation strings by
## rewriting them to plain text.  This plain text can then be included in
## the final Python bindings for libSBML, so that users can use the Python
## interactive help system to view the documentation.
## 
## This program is not a general converter; it is designed specifically to
## work with the way that we generate the libSBML python bindings.
## However, it should not be too difficult to adapt to other similar
## software projects.
## 
## The main hardwired assumptions are the following:
## 
## * The input file to rewrite_pydoc.py is the output produced by our
##   ../../swig/swigdoc.py, which produces documentation definitions for
##   swig.  These have the form shown in the following example:
## 
##      %feature("docstring") SBMLReader::SBMLReader "
##      Creates a new SBMLReader and returns it. 
## 
##      The libSBML SBMLReader objects offer methods for reading SBML in
##      XML form from files and text strings.
##      ";
## 
##   The output of rewrite_pydoc.py is another .i file in which all Doxygen
##   tags have been translated and the docstring contents have been
##   reformatted for use in the python plain-text interactive help system.
## 
## * In our process for producing the libSBML Python bindings, we take the
##   output of rewrite_pydoc.py and include it in the input to swig.  This
##   is done via an %include command in the ../local.i file.  The
##   consequence is that swig reads these %feature commands, and uses them
##   when it produces a file named "libsbml.py" containing the Python code
##   for the libSBML interface.  The objects and methods in "libsbml.py"
##   contain Python-style "docstrings" that are a combination of we defined
##   in the .i file and what swig itself constructs.  (In particular, swig
##   adds documentation about the method signatures, because the methods
##   are interfaces to native code and Python introspection cannot reveal
##   the data types of the parameters.)
##
## * The Doxygen markup understood by rewrite_pydoc.py is not the complete
##   set of all possible Doxygen tags.  We don't use all possible Doxygen
##   tags in the libSBML documentation, and so this program only looks for
##   the ones we have been using.
##
## * We add our own Doxygen markup commands as aliases.  At the time
##   of this writing, the main aliases are @sbmlpackage{...} and
##   @sbmlbrief{...}.  This converter is designed to recognize and
##   process these commands.
##
## Special features:
##
## * This parser understands HTML tables to a limited degree, and converts
##   them to text tables with the help of the PrettyTable library (included
##   as a separate file).  The parser is far from being a full-featured HTML
##   or HTML table parser, but it handles basic tables reasonably well.  It
##   does not recognize row spans, column spans, or CSS styling.
## 
## * When expanding @htmlinclude directives, it first checks to see if a
##   version of the named file, but with a .txt extension, exists in the same
##   location where it finds the .html file.  If the .txt eversion exists, it
##   includes that instead of the .html file.  (This allows hand-formatted
##   text files to be used, which is useful for providing tables to replace
##   HTML tables that the built-in table parser does not handle nicely.)
##
## * When expanding @image directives, it looks for a file with the extension
##   .txt in the same directory where it finds the .jpg file.  If the .txt
##   version exists, it includes that; if it doesn't exist, it does not
##   include anything.  (Since the docstrings are plain-text, no other action
##   seems sensible in this context.)
##
## <!--------------------------------------------------------------------------
## This file is part of libSBML.  Please visit http://sbml.org for more
## information about SBML, and the latest version of libSBML.
##
## Copyright (C) 2013-2014 jointly by the following organizations:
##     1. California Institute of Technology, Pasadena, CA, USA
##     2. EMBL European Bioinformatics Institute (EMBL-EBI), Hinxton, UK
##     3. University of Heidelberg, Heidelberg, Germany
##
## Copyright (C) 2009-2013 jointly by the following organizations: 
##     1. California Institute of Technology, Pasadena, CA, USA
##     2. EMBL European Bioinformatics Institute (EMBL-EBI), Hinxton, UK
##  
## Copyright (C) 2006-2008 by the California Institute of Technology,
##     Pasadena, CA, USA 
##  
## Copyright (C) 2002-2005 jointly by the following organizations: 
##     1. California Institute of Technology, Pasadena, CA, USA
##     2. Japan Science and Technology Agency, Japan
## 
## This library is free software; you can redistribute it and/or modify it
## under the terms of the GNU Lesser General Public License as published by
## the Free Software Foundation.  A copy of the license agreement is provided
## in the file named "LICENSE.txt" included with this software distribution
## and also available online as http://sbml.org/software/libsbml/license.html
## ------------------------------------------------------------------------ -->

import argparse
import re
import sys
import os
import textwrap
from formatter import NullWriter, AbstractFormatter
try:
    from htmllib import HTMLParser
except Exception:
    from html.parser import HTMLParser
from prettytable import PrettyTable


# -----------------------------------------------------------------------------
# Globals.
# -----------------------------------------------------------------------------

# Need to find a better way than hardwiring these here.
known_refs = { 'comp'   : 'Hierarchical Model Composition',
               'layout' : 'Layout',
               'fbc'    : 'Flux Balance Constraints',
               'qual'   : 'Qualitative Modeling' }


# -----------------------------------------------------------------------------
# Command-line argument handling.
# -----------------------------------------------------------------------------

__desc = '''Translates the libSBML Doxygen help text in file "pydoc.i" 
into a form suitable to serve as Python help strings.'''

__desc_end = '''This file is part of libSBML.  Please visit http://sbml.org for
more information about SBML, and the latest version of libSBML.'''


def parse_cmdline(direct_args = None):
    parser = argparse.ArgumentParser(description=__desc, epilog=__desc_end)
    parser.add_argument("-q", "--quiet", action="store_const", const=True,
                        help="be quiet -- don't print messages")
    parser.add_argument("-f", "--file", required=True,
                        help="specify the file to translate")
    parser.add_argument("-o", "--output", required=True,
                        help="specify the file to store the results")
    parser.add_argument("-i", "--include",
                        help="specify the directory for @htmlinclude files")
    parser.add_argument("-g", "--graphics",
                        help="specify the directory for @image files")
    return parser.parse_args(direct_args)


def get_input_file_name(direct_args = None):
    return expanded_path(direct_args.file)


def get_output_file_name(direct_args = None):
    return expanded_path(direct_args.output)


def get_include_dir(direct_args = None):
    return expanded_path(direct_args.include)


def get_graphics_dir(direct_args = None):
    return expanded_path(direct_args.graphics)


def get_quiet_flag(direct_args = None):
    return direct_args.quiet


# -----------------------------------------------------------------------------
# Helper classes.
# -----------------------------------------------------------------------------

# This is a modifid version of DumbWriter from Python 2.6's formatter.py.  The
# original DumbWriter is hardwired to write its output to a file; this version
# writes all text to an internal string variable.  The contents can be
# obtained using a call to get_text().

class RewritePydocStringWriter(NullWriter):

    def __init__(self, maxcol=72):
        self.text = ''
        self.maxcol = maxcol
        NullWriter.__init__(self)
        self.reset()

    def reset(self):
        self.col = 0
        self.atbreak = 0

    def send_paragraph(self, blankline):
        self.text += '\n'*blankline
        self.col = 0
        self.atbreak = 0

    def send_line_break(self):
        self.text += '\n'
        self.col = 0
        self.atbreak = 0

    def send_hor_rule(self, *args, **kw):
        self.text += '\n' + '-'*self.maxcol + '\n'
        self.col = 0
        self.atbreak = 0

    def send_literal_data(self, data):
        self.text += data
        i = data.rfind('\n')
        if i >= 0:
            self.col = 0
            data = data[i+1:]
        data = data.expandtabs()
        self.col = self.col + len(data)
        self.atbreak = 0

    def send_flowing_data(self, data):
        if not data: return
        atbreak = self.atbreak or data[0].isspace()
        col = self.col
        maxcol = self.maxcol
        for word in data.split():
            if atbreak:
                if col + len(word) >= maxcol:
                    self.text += '\n'
                    col = 0
                else:
                    self.text += ' '
                    col = col + 1
            self.text += word
            col = col + len(word)
            atbreak = 1
        self.col = col
        self.atbreak = data[-1].isspace()

    def get_text(self):
        return latin1_to_ascii(self.text)


# This is derived from Python 2.6's htmllib HTMLParser class, with the only
# difference that it doesn't add an anchor like "[1]" into the text it
# writes when it encounters a <a ...>...</a> element in the HTML input.

class RewritePydocHTMLParser(HTMLParser):

    def anchor_end(self):
        pass


# -----------------------------------------------------------------------------
# Body
# -----------------------------------------------------------------------------

def rewrite(contents, include_dir, graphics_dir, quietly=False):
    """Rewrite every docstring in the string argument 'contents', looking for
    @htmlinclude'd files in 'include_dir' and @image files in 'graphics_dir'.
    Print messages about errors unless parameter 'quietly' is True."""

    p = re.compile('(%feature\("docstring"\) \S+ "\n)(.*?)(^";\n\s*)', re.DOTALL|re.MULTILINE)
    return p.sub(lambda match: rewrite_each(match, include_dir, graphics_dir, quietly), contents)


def rewrite_each(match, include_dir, graphics_dir, quietly):
    """Called by 'rewrite' to translate a single instance of a docstring.
    'match' is the regular expression match."""

    feature_line = match.group(1)
    body         = match.group(2)
    tail         = match.group(3)

    if re.search('@internal', body):   # Skip everything if it's internal.
        body = "Internal implementation method.\n"
    else:
        body = rewrite_one_body(body, include_dir, graphics_dir, quietly)
    return feature_line + body + tail


def rewrite_one_body(body, include_dir, graphics_dir, quietly):
    """Rewrite one docstring."""

    # First, some configurable values, to help improve consistency.

    line_width  = 70
    list_indent = 3

    # Start by removing ^M characters, because they confuse the
    # interpretation of ends of lines.  (They shouldn't be in the input
    # file in the first place, but Windows users using svn sometimes
    # introduce them by accident.)

    body = re.sub(r'\015', '', body)

    # Next, deal with conditionals, since that affects what else needs to
    # be done.

    p = re.compile('(@if|@ifnot)[\s*]+(\w+)[\s*]+(.+?)((@else)\s+(.+?))?@endif', re.DOTALL)
    body = p.sub(rewrite_if_else, body)

    # Insert inclusions early, because we may need to process the contents.

    p = re.compile(r'@htmlinclude\s+([^\s:;,(){}+|?"\'/]+)([\s:;,(){}+|?"\'/])')
    body = p.sub(lambda match: rewrite_htmlinclude(match, include_dir, quietly), body)

    # Remove & store verbatim blocks.  These present a special challenge
    # because we don't want to fill the paragraphs in these regions or do
    # other processing.  The approach here is to store the blocks and put
    # them back in a final step at the end.  Note that verbatim, code and
    # <pre> are all formatted in the same way, because in plain-text it's
    # difficult to make the distinctions clear (and anyway, we don't use them
    # much differently in the libSBML code).

    placeholders = []
    p = re.compile('@verbatim(.+?)@endverbatim\n', re.DOTALL)
    body = p.sub(lambda match: store_text(match, 1, placeholders, "\n"), body)
    p = re.compile('@code({[.\w]+?})?(.+?)@endcode\n', re.DOTALL)
    body = p.sub(lambda match: store_text(match, 2, placeholders, "\n"), body)

    # Remove things that have been commented out with HTML comments.

    p = re.compile(r'<!--(.+?) -->', re.DOTALL)
    body = p.sub(r'', body)

    # Translate basic HTML constructs.

    body = re.sub(r'&lt;',        '<',                                body)
    body = re.sub(r'&le;',        '<=',                               body)
    body = re.sub(r'&gt;',        '>',                                body)
    body = re.sub(r'&ge;',        '>=',                               body)
    body = re.sub(r'&ne;',        '!=',                               body)
    body = re.sub(r'&pi;',        'Pi',                               body)
    body = re.sub(r'&#34;',       '\\"',                              body)
    body = re.sub(r'&#64;',       '@',                                body)
    body = re.sub(r'&quot;',      '\\\\"',                            body)
    body = re.sub(r'&[lr]d?quo;', '\\\\"',                            body)
    body = re.sub(r'&nbsp;',      ' ',                                body)
    body = re.sub(r'&ndash;',     '-',                                body)
    body = re.sub(r'&mdash;',     ' -- ',                             body)
    body = re.sub(r'<br>\s*',     '\n',                               body)
    body = re.sub(r'<ul(\s+.*?)?>\s*', '\n',                          body)
    body = re.sub(r'</ul>\s*',         '',                            body)
    body = re.sub(r'<li(\s+.*?)?>\s*', '\n' + ' '*list_indent + '* ', body)
    body = re.sub(r'</li>\s*',         '',                            body)

    # Matched pairs of tags.

    for tag in ['strong', 'em', 'i', 'b', 'code', 'span', 'div', 'a']:
        p = re.compile(r'<(?P<tag>' + tag + r')(\s+.*?)?>(.*?)</(?P=tag)>',
                       re.DOTALL|re.IGNORECASE)
        body = p.sub(r'\3', body)

    # We probably should do <sub> and <sup> repeatedly, in case there's
    # nesting involved, but in our docs we've never nested them.

    p = re.compile(r'<sub>(.+?)</sub>', re.DOTALL|re.IGNORECASE)
    body = p.sub(r'_\1', body)
    p = re.compile(r'<sup>\s*(.+?)\s*</sup>', re.DOTALL|re.IGNORECASE)
    body = p.sub(r'^\1', body)

    # We don't want our <pre> blocks to be wrapped, but we do want basic HTML
    # processing done, so we wait until now to store them.  We also treat our
    # <pre> elements for signature descriptions specially first.

    p = re.compile(r"<pre class='signature'>(.+?)</pre>", re.DOTALL|re.IGNORECASE)
    body = p.sub(r"\n    \1\n", body)
    p = re.compile(r'<pre(\s+.*?)?>(.+?)</pre>', re.DOTALL|re.IGNORECASE)
    body = p.sub(lambda match: store_text(match, 2, placeholders, "\n"), body)

    # Doing <p> after <pre> is easier than coming up with a hairy regexp to
    # avoid the wrong match.

    body = re.sub(r'<p.*?>\s*',  '\n',                          body)
    body = re.sub(r'</p>',       '',                            body)

    # Now finish rewriting Doxygen tags.

    body = rewrite_see(body)

    # Remove excess inter-paragraph spacing prior to rewrapping paragraphs,
    # or the extra spaces at the beginning of blank lines can introduce
    # extra leading spaces in the first lines of the paragraphs.

    body = re.sub(r'\n *\n *\n *', '\n\n', body)

    body = re.sub(r'%',            '',                            body)
    body = re.sub(r'@li\s+',       '\n' + ' '*list_indent + '* ', body)
    body = re.sub(r'@em\s+',       '',                            body)
    body = re.sub(r'@returns?\s+', 'Returns ',                    body)

    p = re.compile(r'@c\s+(\S+(\(\))?)', re.IGNORECASE)
    body = p.sub(r'\1', body)

    p = re.compile(r'@param\s+(\S+)\s+', re.IGNORECASE)
    body = p.sub(r'Parameter \'\1\' is ', body)

    p = re.compile(r'@throws\s+(\S+)\s+', re.IGNORECASE)
    body = p.sub(r'Throws \1: ', body)

    p = re.compile(r'@deprecated\s+(\S+)\s+', re.IGNORECASE)
    body = p.sub(r'DEPRECATED. \1 ', body)

    p = re.compile(r'@p\s+(\S+)\b', re.IGNORECASE)
    body = p.sub(r"'\1'", body)

    p = re.compile(r'@link\s+(\S+)\s+(\S+\+)?(\S+)\s*@endlink', re.IGNORECASE)
    body = p.sub(r'\3', body)
    # Fix up a case that mysteriously doesn't get caught by the regexp above.
    body = re.sub(r'@link\s+libsbml@endlink', "'libsbml'", body)

    p = re.compile(r'@ref\s+(\w+)', re.IGNORECASE)
    body = p.sub(rewrite_ref, body)

    p = re.compile(r'@note(\s*)', re.IGNORECASE)
    body = p.sub(r'Note:\n\n', body)

    p = re.compile(r'@docnote(\s*)', re.IGNORECASE)
    body = p.sub(R'Documentation note:\n\n', body)

    p = re.compile(r'@warning(\s*)', re.IGNORECASE)
    body = p.sub(r'WARNING:\n\n', body)

    p = re.compile(r'@sbmlpackage{(\w+)}', re.IGNORECASE)
    body = p.sub(r'', body)

    p = re.compile(r'@sbmlfunction{(\w+)(,\s*[^}]*?)?}', re.IGNORECASE)
    body = p.sub(r'\1()', body)

    # Handle @image as best as we can.  We ignore @image latex, and for
    # @image html, we will try to substitute a .txt file later on.

    body = re.sub(r'@image\s+latex.+?\n', '', body, re.IGNORECASE)

    # Miscellaneous other adjustments.

    body = re.sub(r"\\'", "'", body)      # Don't need quoted single quotes.
    body = re.sub(r'@~', '', body)        # We use this as a Doxygen hack.
    body = re.sub(r'@par ?', '', body)    # We use this as a Doxygen hack too.

    # Convert HTML tables to text.  This is another case of where we don't
    # want to wrap the results.  To handle this, the table translator outputs
    # special characters before and after the results, and we match these to
    # store the results using the same place holders we use for verbatim.

    p = re.compile(r'<table[^>]*?>(.*?)</table>', re.DOTALL|re.IGNORECASE)
    body = p.sub(lambda match: rewrite_htmltable_guarded(match), body)
    p = re.compile(r"%%%%{(.+?)}%%%%", re.DOTALL|re.IGNORECASE)
    body = p.sub(lambda match: store_text(match, 1, placeholders), body)

    # Wrap paragraphs, so that the text is more readable.

    p = re.compile(r'(.+?)(\n *\n|\Z)', re.DOTALL)
    body = p.sub(lambda match: rewrite_fill_paragraph(match, line_width), body)

    # Handle "@image html".  Do this after wrapping, or else the contents of
    # what we insert will end up wrapped.

    p = re.compile(r'@image\s+html\s+(\S+).*?(\n *\n)', re.DOTALL)
    body = p.sub(lambda match: rewrite_image(match, graphics_dir, quietly), body)

    # Handle @section and other headings, adding underlining to them.  Also
    # handle <hr> tags.  This all needs to be done last, after wrapping
    # paragraphs.

    p = re.compile(r'^ *<hr> ?', re.MULTILINE)
    body = p.sub('_'*line_width + '\n', body)
    p = re.compile(r'@(sub)?section\s+\S+\s+(.+?)(\n *\n)', re.DOTALL|re.IGNORECASE)
    body = p.sub(lambda match: rewrite_section_heading(match, line_width), body)
    p = re.compile(r'(<h3>)\s*(.+?)</h3>(\n *\n)', re.DOTALL|re.IGNORECASE)
    body = p.sub(lambda match: rewrite_section_heading(match, line_width), body)

    # Now replace verbatim block placeholders.

    p = re.compile(r'{{{{(\d+)}}}}')
    body = p.sub(lambda match: replace_stored_text(match, placeholders), body)

    # Remove excess inter-paragraph spacing one more time, to normalize
    # spacing above and below verbatim's.

    body = re.sub(r'\n *\n *\n *\n', '\n\n', body)
    body = re.sub(r'\n *\n *\n',     '\n\n', body)

    # And we're done.

    return body.strip() + '\n'


def rewrite_if_else(match):
    # Our possible conditional elements and their meanings are:
    #
    #   a language name: java, python, csharp, perl, cpp, conly
    #   special terms: clike (= C or C++)
    #
    # The special variants are because Doxygen doesn't have a way to indicate a
    # conjunction like "if not C or C++".  We have to have special smarts here
    # for notclike.

    ifnot = match.group(1) == '@ifnot'
    cond  = match.group(2)
    if ((not ifnot) and (cond == 'python')) \
       or (ifnot and (cond != 'python' or cond == 'clike')):
      text = match.group(3)
    elif match.group(5) == '@else':
      text = match.group(6)
    else:
      text = ''
    return text


def store_text(match, group_number, placeholder_list, padding=""):
    text = match.group(group_number)
    placeholder_list.append(padding + text + padding)
    index = len(placeholder_list) - 1
    return '\n\n{{{{' + str(index) + '}}}}\n\n'


def replace_stored_text(match, placeholder_list):
    index = int(match.group(1))
    text = placeholder_list[index]
    text = re.sub(r'\n', '\n  ', text)
    body = '  ' + text.rstrip() + '\n'
    return body


def rewrite_see(text):
    matches = []
    words = []
    for m in re.finditer(r'(@see\s+([^\n]+\n))', text):
        matches.append(m)
        words.append(m.group(2).strip())

    if len(matches) == 0: return text

    pre_text         = text[:matches[0].start(0)]
    replacement_text = 'See also ' + ', '.join(words) + '.\n'
    post_text        = text[matches[-1].end(0):]

    return pre_text + replacement_text + post_text


def rewrite_ref(match):
    name = match.group(1)
    for key, value in known_refs.items():
        if name == key:
            return value


def rewrite_section_heading(match, line_width):
    is_subsection   = (match.group(1) != None)
    heading_text    = match.group(2)
    tail_whitespace = match.group(3)
    if is_subsection:
        underline_char = '.'
    else:
        underline_char = '='
    heading_text = wrap_paragraph(heading_text, line_width).strip()
    return heading_text + "\n" + underline_char*70 + tail_whitespace


# When expanding @htmlinclude directives, it first checks to see if a
# version of the named file, but with a .txt extension, exists in the same
# location where it finds the .html file.  If the .txt eversion exists, it
# includes that instead of the .html file.  (This allows hand-formatted
# text files to be used, which is useful for files containing tables,
# because the Python HTML parser doesn't handle tables.)

def rewrite_htmlinclude(match, include_dir, quietly):
    file_path = os.path.join(include_dir, match.group(1))
    trailing_char = match.group(2)

    if not valid_file(file_path):
        if not quietly:
            print("Warning: unable to expand @htmlinclude '" + match.group(1) + "'")
        return ''

    # First, try to see if there's a .txt version.  If so, use that.

    txt_file = re.sub(r'html', 'txt', file_path, re.IGNORECASE)
    if valid_file(txt_file):
        contents = read_file_contents(txt_file)
        return rewrite_included_contents(contents) + trailing_char
    else:                               # No txt file; proceed with .html file.
        file = open(file_path, 'r')

        writer = RewritePydocStringWriter()
        parser = RewritePydocHTMLParser(AbstractFormatter(writer))
        parser.feed(file.read())
        parser.close()
        file.close()

        return rewrite_included_contents(writer.get_text()) + trailing_char


# When expanding @image directives, it looks for a file with the extension
# .txt in the same directory where it finds the .jpg file.  If the .txt
# version exists, it includes that; if it doesn't exist, it does not
# include anything.  (Since the docstrings are plain-text, no other action
# seems sensible in this context.)

def rewrite_image(match, graphics_dir, quietly):
    file_name      = match.group(1)
    txt_file       = re.sub(r'.(png|jpg)', '.txt', file_name, re.IGNORECASE)
    file_path      = os.path.join(graphics_dir, txt_file)
    trailing_space = match.group(2)

    if not valid_file(file_path):
        if not quietly:
            print("Warning: unable to open '" + txt_file
                  + "' to replace '" + file_name + "'")
        return ''

    contents = read_file_contents(file_path)
    return rewrite_included_contents(contents) + trailing_space


def rewrite_htmltable_guarded(match):
    headings    = []
    body        = []
    num_columns = 0

    row_pattern = re.compile(r'<tr[^>]*?>(.*?)</tr>', re.DOTALL|re.IGNORECASE)
    th_pattern  = re.compile(r'<th[^>]*?>(.*?)</th>', re.DOTALL|re.IGNORECASE)
    td_pattern  = re.compile(r'<td[^>]*?>(.*?)</td>', re.DOTALL|re.IGNORECASE)
    for row in re.finditer(row_pattern, match.group(1)):
        heads = [c.group(1).replace('\n', ' ').strip() for c in re.finditer(th_pattern, row.group(1))]
        if not empty_list(heads):
            headings.append(heads)
        data = [c.group(1).replace('\n', ' ').strip() for c in re.finditer(td_pattern, row.group(1))]
        if not empty_list(data):
            body.append(data)
        num_columns = max(num_columns, len(heads), len(data))

    # Pad rows that don't have the same number of columns, or else PrettyTable
    # chokes on the input.

    for row in headings:
        for x in range(0, num_columns - len(row)):
            row.append("")

    for row in body:
        for x in range(0, num_columns - len(row)):
            row.append("")

    # Now generate the table structure and return it.

    if not empty_list(headings):
        table = PrettyTable(headings[0])
    else:
        table = PrettyTable()
        table.header = False

    for row in body:
        table.add_row(row)

    # For the table borders, we only insert borders if the table has a heading.
    # This more often matches the way we use tables in libSBML.

    table.border = not empty_list(headings)
    table.align = "l"
    table.right_padding_width = 2
    table.left_padding_width = 0

    return "%%%%{" + "\n" + table.get_string() + "\n" + "}%%%%"


def rewrite_included_contents(contents):
    contents = re.sub(r'"', '\\"', contents) # Quote all double quotes.
    return contents


def rewrite_fill_paragraph(match, line_width):
    text = match.group(1)
    return wrap_paragraph(text, line_width)


def wrap_paragraph(text, line_width):
    return textwrap.fill(text, width = line_width).strip() + '\n\n'


def expanded_path(path):
    if path: return os.path.expanduser(os.path.expandvars(path))
    else:    return ''


def read_file_contents(file):
    file_stream  = open(file, 'r')
    contents = file_stream.read()
    file_stream.close()
    return contents


def write_output_file(file, contents):
    output = open(file, 'w')
    output.write(contents)
    output.close()


def valid_file(file, quiet=False):
    if not os.path.exists(file):
        return False
    elif not os.path.isfile(file):
        return False
    else:
        return True


def valid_directory(dir, quiet=False):
    if not os.path.exists(dir):
        return False
    elif not os.path.isdir(dir):
        return False
    else:
        return True
    

# The following is based on http://stackoverflow.com/a/1605679/743730
# specifically the one-line version by user "Stephan202".

def empty_list(data):
    return all(map(empty_list, data)) if isinstance(data, list) else False


# The following came from a StackOverflow posting by "Soldier.moth" in 2011:
# http://stackoverflow.com/questions/930303/python-string-cleanup-manipulation-accented-characters
# I added 0xa0, which is unbreakable space, because the Python HTML parser was
# producing that character.

def latin1_to_ascii (unicrap):
    """This replaces UNICODE Latin-1 characters with
    something equivalent in 7-bit ASCII. All characters in the standard
    7-bit ASCII range are preserved. In the 8th bit range all the Latin-1
    accented letters are stripped of their accents. Most symbol characters
    are converted to something meaningful. Anything not converted is deleted.
    """
    xlate = {
        0xc0:'A', 0xc1:'A', 0xc2:'A', 0xc3:'A', 0xc4:'A', 0xc5:'A',
        0xc6:'Ae', 0xc7:'C', 0xc8:'E', 0xc9:'E', 0xca:'E', 0xcb:'E',
        0xcc:'I', 0xcd:'I', 0xce:'I', 0xcf:'I', 0xd0:'Th', 0xd1:'N',
        0xd2:'O', 0xd3:'O', 0xd4:'O', 0xd5:'O', 0xd6:'O', 0xd8:'O',
        0xd9:'U', 0xda:'U', 0xdb:'U', 0xdc:'U', 0xdd:'Y', 0xde:'th',
        0xdf:'ss', 0xe0:'a', 0xe1:'a', 0xe2:'a', 0xe3:'a', 0xe4:'a',
        0xe5:'a', 0xe6:'ae', 0xe7:'c', 0xe8:'e', 0xe9:'e', 0xea:'e',
        0xeb:'e', 0xec:'i', 0xed:'i', 0xee:'i', 0xef:'i', 0xf0:'th',
        0xf1:'n', 0xf2:'o', 0xf3:'o', 0xf4:'o', 0xf5:'o', 0xf6:'o',
        0xf8:'o', 0xf9:'u', 0xfa:'u', 0xfb:'u', 0xfc:'u', 0xfd:'y',
        0xfe:'th', 0xff:'y', 0xa0: ' ', 0xa1:'!', 0xa2:'{cent}',
        0xa3:'{pound}', 0xa4:'{currency}', 0xa5:'{yen}', 0xa6:'|',
        0xa7:'{section}', 0xa8:'{umlaut}', 0xa9:'{C}', 0xaa:'{^a}',
        0xab:'<<', 0xac:'{not}', 0xad:'-', 0xae:'{R}', 0xaf:'_',
        0xb0:'{degrees}', 0xb1:'{+/-}', 0xb2:'{^2}', 0xb3:'{^3}', 0xb4:"'",
        0xb5:'{micro}', 0xb6:'{paragraph}', 0xb7:'*', 0xb8:'{cedilla}',
        0xb9:'{^1}', 0xba:'{^o}', 0xbb:'>>', 0xbc:'{1/4}', 0xbd:'{1/2}',
        0xbe:'{3/4}', 0xbf:'?', 0xd7:'*', 0xf7:'/'
        }

    r = ''
    for i in unicrap:
        if xlate.has_key(ord(i)):
            r += xlate[ord(i)]
        elif ord(i) >= 0x80:
            pass
        else:
            r += i
    return r


def main():
    args         = parse_cmdline()
    input_file   = get_input_file_name(args)
    output_file  = get_output_file_name(args)
    include_dir  = get_include_dir(args)
    graphics_dir = get_graphics_dir(args)
    quietly      = get_quiet_flag(args)

    # Sanity-check the arguments.

    if not valid_file(input_file, quietly):
        if not quietly: print("Error: cannot read file '" + input_file + "'")
        sys.exit(1)
    elif include_dir and not valid_directory(include_dir, quietly):
        if not quietly: print("Error: cannot access directory '" + include_dir + "'")
        sys.exit(1)
    elif graphics_dir and not valid_directory(graphics_dir, quietly):
        if not quietly: print("Error: cannot access directory '" + graphics_dir + "'")
        sys.exit(1)

    # Let's do this thing.

    results = rewrite(read_file_contents(input_file), include_dir,
                      graphics_dir, quietly)
    write_output_file(output_file, results)


if __name__ == '__main__':
  main()

