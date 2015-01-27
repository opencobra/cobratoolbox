/*
 * Odefy - Copyright (c) CMB, IBIS, Helmholtz Zentrum Muenchen
 * Free for non-commerical use, for more information: see LICENSE.txt
 * http://cmb.helmholtz-muenchen.de/odefy
 */

package odefy.ui.speciesvalues;

import java.awt.BorderLayout;
import java.awt.Container;
import java.awt.Dimension;
import java.awt.Window;

import javax.swing.BorderFactory;
import javax.swing.JScrollPane;
import javax.swing.JTable;

import odefy.ui.OdefyDialog;

public class SpeciesValuesDialog extends OdefyDialog {

	/**
	 * 
	 */
	private static final long serialVersionUID = -5260145922312491149L;
	
	private ValueTableModel tableModel;

	public SpeciesValuesDialog(Window parent, String title, Object[][] data) {
		super(parent, title, ModalityType.APPLICATION_MODAL);

		this.tableModel = new ValueTableModel(data);
		JTable table = new ValueTable(tableModel);
		table.setPreferredScrollableViewportSize(new Dimension(300, 200));

		JScrollPane scrollPane = new JScrollPane(table);
		scrollPane.setBorder(BorderFactory.createEmptyBorder(5, 5, 10, 5));

		// Put everything together, using the content pane's BorderLayout.
		Container contentPane = this.getContentPane();
		contentPane.add(scrollPane, BorderLayout.CENTER);

		this.pack();
		this.setLocationRelativeTo(parent);
	}

	public double[] getValues() {
		return this.tableModel.getDoubleValues();
	}

}
