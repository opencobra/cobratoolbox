/*
 * From MediaWiki 1.11's common/Common.js
 *
 * Test if an element has a certain class
 *
 * Description: Uses regular expressions and caching for better performance.
 * Maintainers: [[User:Mike Dillon]], [[User:R. Koot]], [[User:SG]]
 */
 
var hasClass = (
  function () {
    var reCache = {};
    return function (element, className) {
      return (reCache[className]
	      ? reCache[className]
	      : (reCache[className]
		 = new RegExp("(?:\\s|^)"
			      + className
			      + "(?:\\s|$)"))).test(element.className);
    };
  }
)();


/*
 * From MediaWiki 1.11's wikibits.js
 */
function hookEvent(hookName, hookFunct) {
  if (window.addEventListener) {
    window.addEventListener(hookName, hookFunct, false);
  } else if (window.attachEvent) {
    window.attachEvent("on" + hookName, hookFunct);
  }
}


/*
 * From www.surfmind.com/musings/2003/09/15
 * Copied 2007-12-12 and modified slightly.
 */

function alternateRowColors()
{
  var className = 'alt-row-colors';
  var rowcolor = '#f3f3f3';
  var rows, arow;
  var tables = document.getElementsByTagName("table");
  var rowCount = 0;
  for (var i = 0; i < tables.length; i++) {
    if (hasClass(tables.item(i), className)) {
      atable = tables.item(i);
      rows = atable.getElementsByTagName("tr");
      for (var j = 0; j < rows.length; j++) {
        arow = rows.item(j);
        if (arow.nodeName == "TR") {
          if (rowCount % 2) {
            // default case
          } else {
            arow.style.backgroundColor = rowcolor;
          }
          rowCount++;
        }
      }
      rowCount = 0;
    }
  }
}


hookEvent("load", alternateRowColors);


/*
 * The next horrendous hack is because Javadoc has a ridiculous implementation
 * of custom tags, with the following behavior: if you have two custom tags
 * like our @note in a row, in the output it produces 
 *
 *    <p>, The text of the note....
 *
 * In other words, it puts a comma followed by a space for the second and
 * subsequent @note entries, but it does nothing to distinguish them.  The
 * output then has this leading comma in the text.  Without any classes or
 * other distinguishing features, we can't format the result or do something
 * smart to fix the situation.  Custom taglets are no use: it turns out that
 * custom taglets suffer from a different limitation, which is that their
 * content is not processed -- so any Javadoc tags in the content are left
 * unprocessed in the output.  Thus, we can't use a custom taglet to implement
 * our @note and other tags, and we can't fix the leading comma introduced
 * by Javadoc short of implementing our *own* version of Javadoc.  
 * 
 * In desperation, I wrote the following Javascript code to search for the
 * places where the leading comma is (usually) introduced, and remove it
 * by manipulating the HTML in the browser.
 *
 * 2013-10-28 <mhucka@caltech.edu>
 */

function fixCommas()
{
    // All the cases we're looking for are inside <dl><dd> elements inside
    // method descriptions.
    var dd_elements = document.getElementsByTagName("dd");
    var dd_elements_len = dd_elements.length;

    // Look for paragraphs that start with ", " and manipulate them.
    for (var i = 0; i < dd_elements_len; i++)
    {
        var this_dl = dd_elements[i];
        var p_elements = this_dl.getElementsByTagName("p");
        var p_elements_len = p_elements.length;
        for (var j = 0; j < p_elements_len; j++)
        {
            var text = p_elements[j].innerHTML;
            if (text.substring(0, 2) == ", ") {
                var len = text.length;
                p_elements[j].innerHTML = text.substring(2, len - 2);
                // And let's make it possible to use some CSS with this:
                p_elements[j].setAttribute('class', 'note');
            }
        }
    }
}


hookEvent("load", fixCommas);
