/*
 * Odefy - Copyright (c) CMB, IBIS, Helmholtz Zentrum Muenchen
 * Free for non-commerical use, for more information: see LICENSE.txt
 * http://cmb.helmholtz-muenchen.de/odefy
 */

package odefy.ui.speciesvalues;

import javax.swing.table.AbstractTableModel;

public class ValueTableModel extends AbstractTableModel {
	
	/**
	 * 
	 */
	private static final long serialVersionUID = 5482404912460136713L;

	private static final String[] colNames = {"Name", "Value"};
	
	private Object[][] rowData;
	
	public ValueTableModel(Object[][] data) {
		this.rowData = data;
	}
	
	public String getColumnName(int col) {
		return colNames[col];
	}
	
	public boolean isCellEditable(int row, int column) {
		return (column == 1);
	}
	
	public int getColumnCount() {
		return colNames.length;
	}

	public int getRowCount() {
		return this.rowData.length;
	}

	public Object getValueAt(int rowIndex, int columnIndex) {
		return this.rowData[rowIndex][columnIndex];
	}

	public void setValueAt(Object value, int row, int col) {
		this.rowData[row][col] = value;
        fireTableCellUpdated(row, col);
    }

	public Class getColumnClass(int c) {
        return getValueAt(0, c).getClass();
    }
	
	public Object[][] getData() {
		return this.rowData;
	}
	
	public double[] getDoubleValues() {
		double[] ret = new double[this.rowData.length];
		for (int i=0; i<ret.length; i++) {
			ret[i] = ((Double)this.rowData[i][1]).doubleValue();
		}
		return ret;
	}

}
