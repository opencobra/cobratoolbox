/*
 * Odefy - Copyright (c) CMB, IBIS, Helmholtz Zentrum Muenchen
 * Free for non-commerical use, for more information: see LICENSE.txt
 * http://cmb.helmholtz-muenchen.de/odefy
 */

package odefy.ui;

import javax.swing.JFormattedTextField;
import javax.swing.JSpinner;
import javax.swing.JTextField;
import javax.swing.SpinnerNumberModel;

public class NumberSpinner extends JSpinner {

	/**
	 * 
	 */
	private static final long serialVersionUID = -8664463267383321679L;

	public NumberSpinner(double value, double min, double max, double stepSize, int columns) {
		super(new SpinnerNumberModel(value, min, max, stepSize));
        JFormattedTextField textField = ((JSpinner.DefaultEditor)this.getEditor()).getTextField();
        textField.setColumns(columns);
        textField.setHorizontalAlignment(JTextField.RIGHT);
	}
	
}
