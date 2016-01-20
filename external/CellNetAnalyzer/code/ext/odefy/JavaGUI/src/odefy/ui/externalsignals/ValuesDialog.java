/*
 * Odefy - Copyright (c) CMB, IBIS, Helmholtz Zentrum Muenchen
 * Free for non-commerical use, for more information: see LICENSE.txt
 * http://cmb.helmholtz-muenchen.de/odefy
 */

package odefy.ui.externalsignals;

import java.awt.BorderLayout;
import java.awt.Container;
import java.awt.Dimension;
import java.awt.Window;

import javax.swing.BorderFactory;
import javax.swing.JScrollPane;
import javax.swing.JTable;
import javax.swing.ListSelectionModel;

import odefy.ui.OdefyDialog;
import odefy.ui.TableEditorStopper;
import odefy.ui.speciesvalues.ValueTableModel;

public class ValuesDialog extends OdefyDialog {
	
	/**
	 * 
	 */
	private static final long serialVersionUID = -2125321703772671765L;
	
	private ValueTableModel model;

	public ValuesDialog(Window parent, String title, String[][] data) {
		super(parent, title, ModalityType.APPLICATION_MODAL);

		model = new ValueTableModel(data);
		JTable table = new JTable(model);
		table.setSelectionMode(ListSelectionModel.SINGLE_SELECTION);
		TableEditorStopper.ensureEditingStopWhenTableLosesFocus(table);
		table.setPreferredScrollableViewportSize(new Dimension(300, 200));
		table.setFillsViewportHeight(true);
		
		JScrollPane scrollPane = new JScrollPane(table);
		scrollPane.setBorder(BorderFactory.createEmptyBorder(5, 5, 10, 5));

		// Use custom editor for 2nd column
		table.getColumnModel().getColumn(1).setCellEditor(
				new ExternalSignalEditor());

		Container contentPane = this.getContentPane();
		contentPane.add(scrollPane, BorderLayout.CENTER);
		
		this.pack();
		this.setLocationRelativeTo(parent);
	}
	
	public String[] getStringValues() {
		Object[][] data = this.model.getData();
		String[] ret = new String[data.length];
		for (int i=0; i<data.length; i++) {
			ret[i] = (String)data[i][1];
		}
		return ret;
	}
	
}
