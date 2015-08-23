/*
 * Odefy - Copyright (c) CMB, IBIS, Helmholtz Zentrum Muenchen
 * Free for non-commerical use, for more information: see LICENSE.txt
 * http://cmb.helmholtz-muenchen.de/odefy
 */

package odefy.ui.externalsignals;

import java.awt.Component;
import java.awt.Toolkit;
import java.awt.event.ActionEvent;
import java.awt.event.KeyEvent;
import java.text.ParseException;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import javax.swing.AbstractAction;
import javax.swing.DefaultCellEditor;
import javax.swing.JFormattedTextField;
import javax.swing.JOptionPane;
import javax.swing.JTable;
import javax.swing.KeyStroke;
import javax.swing.SwingUtilities;
import javax.swing.text.DefaultFormatter;
import javax.swing.text.DefaultFormatterFactory;

public class ExternalSignalEditor extends DefaultCellEditor {

	/**
	 * 
	 */
	private static final long serialVersionUID = -5010872228487276640L;

	/**
	 * Validates value
	 */
	static public class ExternalSignalFormatter extends DefaultFormatter {
		
		/**
		 * 
		 */
		private static final long serialVersionUID = -4163221104957462508L;
		
		private static final Pattern pattern = Pattern.compile("[ t()\\.<>|&=~0-9*/+-]+");
		
		public Object stringToValue(String text) throws ParseException {
			Matcher matcher = pattern.matcher(text);
			if (matcher.matches()) {
				return super.stringToValue(text);
			} else {
				throw new ParseException("Invalid format", 0);
			}
		}
		
	}
	
	private JFormattedTextField ftf;

	public ExternalSignalEditor() {
		super(new JFormattedTextField());
		ftf = (JFormattedTextField) getComponent();

		// Use custom Formatter from above
		ftf.setFormatterFactory(new DefaultFormatterFactory(
				new ExternalSignalFormatter()));

		// React when the user presses Enter
		ftf.getInputMap().put(
				KeyStroke.getKeyStroke(KeyEvent.VK_ENTER, 0),
				"check");
		ftf.getActionMap().put("check", new AbstractAction() {
			private static final long serialVersionUID = 6736581560121004818L;
			public void actionPerformed(ActionEvent e) {
				if (!ftf.isEditValid()) { // The text is invalid.
					if (userSaysRevert()) { // reverted
						ftf.postActionEvent(); // inform the editor
					}
				} else
					try { // The text is valid,
						ftf.commitEdit(); // so use it.
						ftf.postActionEvent(); // stop editing
					} catch (java.text.ParseException exc) {
					}
			}
		});

	}

	// Override to invoke setValue on the formatted text field.
	public Component getTableCellEditorComponent(JTable table, Object value,
			boolean isSelected, int row, int column) {
		JFormattedTextField ftf = 
			(JFormattedTextField) super.getTableCellEditorComponent(
					table, value, isSelected, row, column);
		ftf.setValue(value);
		return ftf;
	}

	public Object getCellEditorValue() {
		return ftf.getValue();
	}

	// Override to check whether the edit is valid,
	// setting the value if it is and complaining if
	// it isn't. If it's OK for the editor to go
	// away, we need to invoke the superclass's version
	// of this method so that everything gets cleaned up.
	public boolean stopCellEditing() {
		JFormattedTextField ftf = (JFormattedTextField) getComponent();
		if (ftf.isEditValid()) {
			try {
				ftf.commitEdit();
			} catch (java.text.ParseException exc) {
			}

		} else { // text is invalid
			if (!userSaysRevert()) { // user wants to edit
				return false; // don't let the editor go away
			}
		}
		return super.stopCellEditing();
	}

	/**
	 * Lets the user know that the text they entered is bad. Returns true if the
	 * user elects to revert to the last good value. Otherwise, returns false,
	 * indicating that the user wants to continue editing.
	 */
	protected boolean userSaysRevert() {
		Toolkit.getDefaultToolkit().beep();
		ftf.selectAll();
		final Object[] options = { "Edit", "Revert" };
		int answer = JOptionPane.showOptionDialog(SwingUtilities
				.getWindowAncestor(ftf),
				"The value must be a valid Matlab expression that only may contain t as parameter.",
				"Invalid Text Entered", JOptionPane.YES_NO_OPTION,
				JOptionPane.ERROR_MESSAGE, null, options, options[1]);

		if (answer == 1) { // Revert!
			ftf.setValue(ftf.getValue());
			return true;
		}
		return false;
	}

}
