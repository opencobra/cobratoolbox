/*
 * Odefy - Copyright (c) CMB, IBIS, Helmholtz Zentrum Muenchen
 * Free for non-commerical use, for more information: see LICENSE.txt
 * http://cmb.helmholtz-muenchen.de/odefy
 */

package odefy.ui.hillparameters;

import java.awt.Component;
import java.awt.GridBagConstraints;
import java.awt.GridBagLayout;
import java.awt.Insets;
import java.awt.Window;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.awt.event.KeyEvent;
import java.util.ArrayList;

import javax.swing.JButton;
import javax.swing.JComboBox;
import javax.swing.JDialog;
import javax.swing.JFrame;
import javax.swing.JLabel;
import javax.swing.JOptionPane;
import javax.swing.JScrollPane;
import javax.swing.JSpinner;
import javax.swing.JTable;
import javax.swing.UIManager;
import javax.swing.UnsupportedLookAndFeelException;
import javax.swing.event.ChangeEvent;
import javax.swing.event.ChangeListener;
import javax.swing.table.AbstractTableModel;
import javax.swing.table.TableModel;

import odefy.ui.NumberSpinner;
import odefy.ui.TitledPanel;

public class Dialog extends JDialog implements ActionListener, ChangeListener {

	/**
	 * 
	 */
	private static final long serialVersionUID = 6372325536191081289L;
	
	private GridBagLayout layout;
	private JSpinner spinK;
	private JSpinner spinN;
	private JSpinner spinTau;
	private Integer[][] inspecies;
	private String[] species;
	private Double[][] hillmatrix;
	private JComboBox cmbInput;
	private JComboBox cmbSpecies;

	private static final String SELECT_SPECIES = "[select species]";
	private JButton btnSetAll;
	private JSpinner spinAllTau;
	private JSpinner spinAllN;
	private JSpinner spinAllK;
	private JButton btnOK;
	private JButton btnCancel;

	private ArrayList paramNames;

	private ArrayList paramVals;

	private JTable table;
	
	/**
	 * 
	 * @param tau Default value for tau
	 * @param n Default value for n
	 * @param k Default value for k
	 * @param species Name of species
	 * @param tables Represents <tt>model.tables(i).inspecies</tt> in Matlab.
	 * Where <tt>i</tt> specifies the 1st dimension
	 * @param hillmatrix Represents <tt>simstruct.hillmatrix</tt> in Matlab 
	 */
	public Dialog(Window parent, Double tau, Double n, Double k,
			String[] species, Integer[][] tables, Double[][] hillmatrix) {
		super(parent, "Parameters", ModalityType.APPLICATION_MODAL);
		
		layout = new GridBagLayout();
		this.setLayout(layout);
		
		this.species = species;
		this.inspecies = tables;
		this.hillmatrix = hillmatrix;
		
		this.addReactionsPanel(tau.doubleValue(), n.doubleValue(), k.doubleValue());
		this.addTablePanel();
//		this.addSpecificPanel();
		//this.setSpecificSpinnersEnabled(false);

		btnCancel = new JButton("Cancel");
		btnCancel.setMnemonic(KeyEvent.VK_C);
		this.addComponent(btnCancel, 0, 2, 1, 1, 0.5, 0);
		
		btnOK = new JButton("OK");
		btnOK.setMnemonic(KeyEvent.VK_O);
		this.addComponent(btnOK, 1, 2, 1, 1, 0.5, 0);
		

		
		this.pack();
		this.setLocationRelativeTo(parent);
	}

	public double[][] getHillmatrix() {
		
		// generate data table
		int index=0;
		for (int i=0; i<inspecies.length; i++) {
			// tau
			hillmatrix[i][0] = new Double(Double.parseDouble(paramVals.get(index++).toString()));
			// rest
			for (int j=0; j<inspecies[i].length; j++) {
				hillmatrix[i][1+j*2] =  new Double(Double.parseDouble(paramVals.get(index++).toString()));
				hillmatrix[i][1+j*2+1] =  new Double(Double.parseDouble(paramVals.get(index++).toString()));
			}
		}
		
		// We have to convert to built-in double
		// otherwise Matlab can't convert it automatically
		double[][] ret = new double[this.hillmatrix.length][this.hillmatrix[0].length];
		for (int i=0; i<this.hillmatrix.length; i++) {
			for (int j=0; j<this.hillmatrix[i].length; j++) {
				ret[i][j] = this.hillmatrix[i][j].doubleValue();
			}
		}
		return ret;
	}
	
	public JButton getOKButton() {
		return this.btnOK;
	}
	
	public JButton getCancelButton() {
		return this.btnCancel;
	}

	private void addReactionsPanel(double tau, double n, double k) {
		TitledPanel reactions_panel = new TitledPanel("Set for all reactions");
		this.addComponent(reactions_panel, 0, 0, 2, 1, 1, 0);
		
		JLabel tau_label = new JLabel("tau");
		spinAllTau = new NumberSpinner(tau, 0.01, 100, 0.1, 5);
		tau_label.setLabelFor(spinAllTau);

		reactions_panel.addComponent(tau_label, 0, 0);
		reactions_panel.addComponent(spinAllTau, 1, 0);
		
		JLabel n_label = new JLabel("n");
		spinAllN = new NumberSpinner(n, 1, 25, 1, 5);
		n_label.setLabelFor(spinAllN);
		
		reactions_panel.addComponent(n_label, 0, 1);
		reactions_panel.addComponent(spinAllN, 1, 1);
		
		JLabel k_label = new JLabel("k");
		spinAllK = new NumberSpinner(k, 0, 1, 0.05, 5);
		k_label.setLabelFor(spinAllK);
		
		reactions_panel.addComponent(k_label, 0, 2);
		reactions_panel.addComponent(spinAllK, 1, 2);
		
		btnSetAll = new JButton("Set all");
		btnSetAll.addActionListener(this);
		reactions_panel.addComponent(btnSetAll, 0, 3, 2, 1);
	}
	
	private void addTablePanel() {
		TitledPanel panel = new TitledPanel("Edit parameter values");
		this.addComponent(panel, 0, 1, 2, 1, 1, 3);
		
		generateDataTable();
		
		TableModel dataModel = new AbstractTableModel() {
			/**
			 * 
			 */
			private static final long serialVersionUID = -7974579394608872851L;
			
			public int getColumnCount() { return 2; }
			public int getRowCount() { return paramNames.size();}
			public Object getValueAt(int row, int col) { 
				if (col==0)
					return paramNames.get(row);
				else
					return paramVals.get(row);				
			}
			public void setValueAt(Object aValue, int rowIndex, int columnIndex) {
				// verify values
				boolean ok=true;
				String pname = (String)paramNames.get(rowIndex);
				if (pname.contains("_tau")) {
					// a tau
					try {
						double val = Double.parseDouble((String) aValue);
						if (Double.isNaN(val) || val <= 0) {
							ok = false;
						}
					} catch (Exception e) {
						ok = false;
					}
					if (!ok)
						error("Tau must have a positive value.");
				} else if (pname.contains("_n_")) {
					// a tau
					try {
						int val = Integer.parseInt((String) aValue);
						if (val < 1) {
							ok = false;
						}
					} catch (Exception e) {
						ok=false;
					}
					if (!ok)
						error("n must be a positive integer.");
				} else if (pname.contains("_k_")) {
					// a tau
					try {
						double val = Double.parseDouble((String) aValue);
						if (Double.isNaN(val) || !(val>0 && val<1)) {
							ok = false;
						}
					} catch (Exception e) {
						ok = false;
					}
					if (!ok)
						error("k must be between 0 and 1, exclusively");
				}
				
				if (ok)
					paramVals.set(rowIndex, aValue.toString());
				
				getHillmatrix();
			}
			public boolean isCellEditable(int rowIndex, int columnIndex) {
				return columnIndex==1;
			}
		};
		table = new JTable(dataModel);
		table.putClientProperty("terminateEditOnFocusLost", Boolean.TRUE); 
		//table.setBorder(BorderFactory.createBevelBorder(javax.swing.border.BevelBorder.RAISED));
		table.setBorder(spinAllN.getBorder());
		JScrollPane scrollpane = new JScrollPane(table);
		
		panel.addComponent(scrollpane, 0, 0, 1, 1, 1, 1);
	}
	
	private void generateDataTable() {
		// generate data table
		paramNames = new ArrayList();
		paramVals = new ArrayList();
		for (int i=0; i<inspecies.length; i++) {
			// tau
			paramNames.add(species[i] + "_tau");
			paramVals.add(hillmatrix[i][0]);
			// rest
			for (int j=0; j<inspecies[i].length; j++) {
				paramNames.add(species[i] + "_n_" + species[inspecies[i][j].intValue()-1]);
				paramNames.add(species[i] + "_k_" + species[inspecies[i][j].intValue()-1]);
				paramVals.add(hillmatrix[i][1+j*2]);	
				paramVals.add(hillmatrix[i][1+j*2+1]);	
			}
		}
	}

	private void error(String msg) {
		JOptionPane.showMessageDialog(this, msg, "Error", JOptionPane.ERROR_MESSAGE);
	}
	

	public void actionPerformed(ActionEvent e) {
		if (e.getSource() == this.cmbSpecies) {
			boolean val = !this.cmbSpecies.getModel().getSelectedItem().equals(SELECT_SPECIES);
			this.setSpecificSpinnersEnabled(val);
			if (val)
				this.setInputSpeciesComboItems();
		} else if (e.getSource() == this.cmbInput) {
			this.setInputSpeciesValues();
		} else if (e.getSource() == this.btnSetAll) {
			Double tau = (Double)this.spinAllTau.getValue();
			Double n = (Double)this.spinAllN.getValue();
			Double k = (Double)this.spinAllK.getValue();
			this.setAll(tau.doubleValue(), n.doubleValue(), k.doubleValue());
		}
	}

	public void stateChanged(ChangeEvent e) {
		int species_index = this.getSelectedSpeciesIndex();
		if (e.getSource() == this.spinTau) {
			this.hillmatrix[species_index][0] = (Double)this.spinTau.getValue();
		} else if (e.getSource() == this.spinN) {
			int input_species_index = this.cmbInput.getSelectedIndex();
			this.hillmatrix[species_index][(input_species_index+1)*2 - 1] = (Double)this.spinN.getValue();
		} else if (e.getSource() == this.spinK) {
			int input_species_index = this.cmbInput.getSelectedIndex();
			this.hillmatrix[species_index][(input_species_index+1)*2] = (Double)this.spinK.getValue();
		}
	}

	public void setSpecificSpinnersEnabled(boolean val) {
		this.spinTau.setEnabled(val);
		this.spinN.setEnabled(val);
		this.spinK.setEnabled(val);
		this.cmbInput.setEnabled(val);
	}

	private int getSelectedSpeciesIndex() {
		int species_index = this.cmbSpecies.getSelectedIndex() - 1;
		return species_index;
	}
	
	public void setAll(double tau, double n, double k) {
		// iterate over species index
		for (int i=0; i<this.species.length; i++) {
			this.hillmatrix[i] = new Double[this.hillmatrix[i].length];
			// set tau
			this.hillmatrix[i][0] = new Double(tau);
			// initialize with zeros
			for (int j=1; j<this.hillmatrix[i].length; j++) {
				this.hillmatrix[i][j] = new Double(0);
			}
			// set n and k
			if (inspecies[i].length > 1) {
				for (int j=0; j<inspecies[i].length; j++) {
					this.hillmatrix[i][(j+1)*2-1] = new Double(n);
					this.hillmatrix[i][(j+1)*2] = new Double(k);
				}
			} else {
				// input species
				this.hillmatrix[i][1] = new Double(n);
				this.hillmatrix[i][2] = new Double(k);
			}
		}
		
		generateDataTable();
		table.updateUI();
		
	}
	
	/**
	 * Set values of input_combo and sp_tau_spinner
	 * depending on selected item of species_combo
	 */
	private void setInputSpeciesComboItems() {
		int species_index = this.getSelectedSpeciesIndex();
		
		// display tau
		Double tau = this.hillmatrix[species_index][0];
		this.spinTau.setValue(tau);
		
		// display input species in second combo box
		Integer[] inspecies = this.inspecies[species_index];
		this.cmbInput.removeAllItems();
		if (inspecies.length > 0) {
			for (int i=0; i<inspecies.length; i++) {
				int input_species_index = inspecies[i].intValue() - 1;
				String input_species_name = this.species[input_species_index];
				this.cmbInput.addItem(input_species_name);
			}
		}
	}

	/**
	 * Set values of sp_n_spinner and sp_k_spinner
	 * depending on selection of input_combo
	 */
	private void setInputSpeciesValues() {
		int species_index = this.getSelectedSpeciesIndex();
		int input_species_index = this.cmbInput.getSelectedIndex();
		
		if (input_species_index >= 0) {
			Double n = this.hillmatrix[species_index][(input_species_index+1)*2 - 1];
			Double k = this.hillmatrix[species_index][(input_species_index+1)*2];
			
			this.spinN.setValue(n);
			this.spinK.setValue(k);
		}
	}

	public GridBagConstraints addComponent(Component comp, int x, int y) {
		return this.addComponent(comp, x, y, 1, 1);
	}
	
	public GridBagConstraints addComponent(Component comp, int x, int y, int width, int height) {
		return this.addComponent(comp, x, y, width, height, 0, 0);
	}
	
	public GridBagConstraints addComponent(Component comp, int x, int y, int width, int height, double weightx, double weighty) {
		GridBagConstraints gbc = new GridBagConstraints();
		gbc.fill = GridBagConstraints.BOTH;
		gbc.gridx = x;
		gbc.gridy = y;
		gbc.gridwidth = width;
		gbc.gridheight = height;
		gbc.weightx = weightx;
		gbc.weighty = weighty;
		gbc.insets = new Insets(6, 6, 6, 6);
		
		this.layout.setConstraints(comp, gbc);
		this.add(comp);
		
		return gbc;
	}
	
	public static void main(String[] args) {
		try {
			UIManager.setLookAndFeel(UIManager.getSystemLookAndFeelClassName());
		} catch (UnsupportedLookAndFeelException e) {
			// handle exception
		} catch (ClassNotFoundException e) {
			// handle exception
		} catch (InstantiationException e) {
			// handle exception
		} catch (IllegalAccessException e) {
			// handle exception
		}

		String[] species = new String[] { "a", "b" };

		Integer[][] tables = new Integer[][] {
			new Integer[] { new Integer(1), new Integer(2) },
			new Integer[] { new Integer(2), new Integer(1) }
		};

		Double[][] hillmatrix = new Double[][] {
				{ new Double(1), new Double(3), new Double(0.5), new Double(3),
						new Double(0.5) },
				{ new Double(1), new Double(3), new Double(0.5), new Double(3),
						new Double(0.5) }, };

		JDialog dialog = new Dialog(null, new Double(1), new Double(3), new Double(
				0.5), species, tables, hillmatrix);
		dialog.setSize(250, 500);
		dialog.setDefaultCloseOperation(JFrame.DISPOSE_ON_CLOSE);
		dialog.setVisible(true);
		dialog.pack();
	}

}
