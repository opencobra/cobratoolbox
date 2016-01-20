/*
 * Odefy - Copyright (c) CMB, IBIS, Helmholtz Zentrum Muenchen
 * Free for non-commerical use, for more information: see LICENSE.txt
 * http://cmb.helmholtz-muenchen.de/odefy
 */

package odefy.ui;

import java.awt.Component;
import java.awt.event.MouseEvent;
import java.util.EventObject;

import javax.swing.AbstractCellEditor;
import javax.swing.JSpinner;
import javax.swing.JTable;
import javax.swing.SpinnerNumberModel;
import javax.swing.table.TableCellEditor;

public class SpinnerEditor extends AbstractCellEditor implements
		TableCellEditor {

	/**
	 * 
	 */
	private static final long serialVersionUID = 532492693489795068L;
	
	final JSpinner spinner = new JSpinner();

	// Initializes the spinner.
	public SpinnerEditor() {
		spinner.setModel(new SpinnerNumberModel(1, 0, Double.POSITIVE_INFINITY, 0.1));
	}

	// Prepares the spinner component and returns it.
	public Component getTableCellEditorComponent(JTable table, Object value,
			boolean isSelected, int row, int column) {
		spinner.setValue(value);
		return spinner;
	}

	// Enables the editor only for double-clicks.
	public boolean isCellEditable(EventObject evt) {
		if (evt instanceof MouseEvent) {
			return ((MouseEvent) evt).getClickCount() >= 2;
		}
		return true;
	}

	// Returns the spinners current value.
	public Object getCellEditorValue() {
		return spinner.getValue();
	}
}
