/*
 * Odefy - Copyright (c) CMB, IBIS, Helmholtz Zentrum Muenchen
 * Free for non-commerical use, for more information: see LICENSE.txt
 * http://cmb.helmholtz-muenchen.de/odefy
 */

package odefy.ui.externalsignals;

import java.awt.Toolkit;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import javax.swing.text.AttributeSet;
import javax.swing.text.BadLocationException;
import javax.swing.text.DocumentFilter;

/**
 * Does not allow other characters to be entered than the ones specified in the pattern
 */
public class ExternalSignalFilter extends DocumentFilter {

	private static final Pattern pattern = Pattern.compile("[ t\\.<>|&=~0-9*/+-]+");
	
	public void insertString(DocumentFilter.FilterBypass fb, int offset,
			String string, AttributeSet attr) throws BadLocationException {
		Matcher matcher = pattern.matcher(string);
		if (matcher.matches()) {
			super.insertString(fb, offset, string, attr);
		} else {
			Toolkit.getDefaultToolkit().beep();
		}
	}
	
	public void replace(DocumentFilter.FilterBypass fb, int offset,
			int length, String text, AttributeSet attrs) throws BadLocationException {
		Matcher matcher = pattern.matcher(text);
		if (matcher.matches()) {
			super.replace(fb, offset, length, text, attrs);
		} else {
			Toolkit.getDefaultToolkit().beep();
		}
	}
	
}
