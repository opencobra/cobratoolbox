/*
 * Odefy - Copyright (c) CMB, IBIS, Helmholtz Zentrum Muenchen
 * Free for non-commerical use, for more information: see LICENSE.txt
 * http://cmb.helmholtz-muenchen.de/odefy
 */

package odefy.ui.speciesvalues;

import javax.swing.JTable;
import javax.swing.ListSelectionModel;

import odefy.ui.TableEditorStopper;

public class ValueTable extends JTable {
	
	/**
	 * 
	 */
	private static final long serialVersionUID = 9132555705823869215L;

	public ValueTable(ValueTableModel valueTableModel) {
		super(valueTableModel);
		this.setSelectionMode(ListSelectionModel.SINGLE_SELECTION);
		TableEditorStopper.ensureEditingStopWhenTableLosesFocus(this);
		
	}
		
}
