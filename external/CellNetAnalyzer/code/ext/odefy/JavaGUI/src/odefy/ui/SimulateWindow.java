/*
 * Odefy - Copyright (c) CMB, IBIS, Helmholtz Zentrum Muenchen
 * Free for non-commerical use, for more information: see LICENSE.txt
 * http://cmb.helmholtz-muenchen.de/odefy
 */

package odefy.ui;

import java.awt.Component;
import java.awt.Cursor;
import java.awt.Dimension;
import java.awt.GridBagConstraints;
import java.awt.GridBagLayout;
import java.awt.Insets;
import java.awt.Rectangle;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.awt.event.InputEvent;
import java.awt.event.KeyEvent;

import javax.swing.Box;
import javax.swing.BoxLayout;
import javax.swing.ImageIcon;
import javax.swing.JButton;
import javax.swing.JCheckBox;
import javax.swing.JComboBox;
import javax.swing.JFrame;
import javax.swing.JLabel;
import javax.swing.JMenu;
import javax.swing.JMenuBar;
import javax.swing.JMenuItem;
import javax.swing.JPanel;
import javax.swing.JSeparator;
import javax.swing.JSpinner;
import javax.swing.KeyStroke;
import javax.swing.UIManager;
import javax.swing.UnsupportedLookAndFeelException;


public class SimulateWindow extends JFrame {

	/**
	 * 
	 */
	private static final long serialVersionUID = -2406950187485056530L;
	
	private JPanel pnlLayout;
	private GridBagLayout layout;
	private JButton btnEditParams;
	private JButton btnEditInit;
	private JButton btnSim;
	private JComboBox cmbSim;
	private JSpinner spinTime;
	private JCheckBox chkSave;
	private TitledPanel pnlSettings;
	
	public static final int SPECIES_ORDER_ASYNC = 0;
	public static final int SPECIES_ORDER_SEQUENTIAL = 1;
	public static final int SPECIES_ORDER_RANDOM = 2;
	private JComboBox cmbVariables;
	private JMenuItem mnuLoadSim;
	private JMenuItem mnuLoadParams;
	private JMenuItem mnuLoadInit;
	private JMenuItem mnuSaveSim;
	private JMenuItem mnuSaveParams;
	private JMenuItem mnuSaveInit;
	private JMenuItem mnuAbout;
	private JMenuItem mnuOpen;
	private JMenuItem mnuReload;

	private TitledPanel pnlType;

	private JComboBox cmbPlotType;

	private JLabel lblOrder;

	private JMenuItem mnuReloadCNA;	

	public SimulateWindow(String title) {
		super(title);
		
		this.layout = new GridBagLayout();
		this.pnlLayout = new JPanel();
		this.pnlLayout.setLayout(this.layout);
		this.setContentPane(this.pnlLayout);
		
		this.addMenu();
		this.addSettingsPanel();
		this.addTypePanel();
		this.addPlotTypePanel();
		
		chkSave = new JCheckBox("Save results into workspace");
		this.addComponent(chkSave, 0, 2);
		
		this.addButtons();
		
		this.pack();
		
	}
	
	private void addMenu() {
		JMenuBar menubar = new JMenuBar();

	    final ImageIcon open_icon = Utils.createImageIcon("images/general/Open16.gif");
	    final ImageIcon save_icon = Utils.createImageIcon("images/general/Save16.gif");
		
		JMenu filemenu = new JMenu("File");
		filemenu.setMnemonic(KeyEvent.VK_F);
		menubar.add(filemenu);
		
		mnuOpen = new JMenuItem("Open Model ...");
		mnuOpen.setMnemonic(KeyEvent.VK_O);
		mnuOpen.setAccelerator(KeyStroke.getKeyStroke(KeyEvent.VK_O, InputEvent.CTRL_MASK));
		filemenu.add(mnuOpen);
		
		mnuReload = new JMenuItem("Reload yED model ...");
		mnuReload.setMnemonic(KeyEvent.VK_R);
		mnuReload.setToolTipText("Reload the GraphML file and preserve parameters");
		mnuReload.setAccelerator(KeyStroke.getKeyStroke(KeyEvent.VK_F5, 0));
		filemenu.add(mnuReload);
		
		mnuReloadCNA = new JMenuItem("Reload CNA settings...");
		mnuReloadCNA.setMnemonic(KeyEvent.VK_C);
		mnuReloadCNA.setToolTipText("Reload initial values and activated reactions from CNA");
		mnuReloadCNA.setAccelerator(KeyStroke.getKeyStroke(KeyEvent.VK_F5, 0));
		filemenu.add(mnuReloadCNA);
		
		JMenu load_menu = new JMenu("Load from workspace");
		load_menu.setIcon(open_icon);
		load_menu.setMnemonic(KeyEvent.VK_L);
		filemenu.add(load_menu);
		
		mnuLoadSim = new JMenuItem("Simulation ...");
		load_menu.add(mnuLoadSim);
		
		mnuLoadParams = new JMenuItem("Parameters ...");
		load_menu.add(mnuLoadParams);
		
		mnuLoadInit = new JMenuItem("Initial values ...");
		load_menu.add(mnuLoadInit);
		
		JMenu save_menu = new JMenu("Save to workspace");
		save_menu.setIcon(save_icon);
		save_menu.setMnemonic(KeyEvent.VK_S);
		filemenu.add(save_menu);

		mnuSaveSim = new JMenuItem("Simulation ...");
		save_menu.add(mnuSaveSim);
		
		mnuSaveParams = new JMenuItem("Parameters ...");
		save_menu.add(mnuSaveParams);
		
		mnuSaveInit = new JMenuItem("Initial values ...");
		save_menu.add(mnuSaveInit);
		
		filemenu.add(new JSeparator());
		
		JMenuItem quit = new JMenuItem("Quit", KeyEvent.VK_Q);
		quit.setAccelerator(KeyStroke.getKeyStroke(KeyEvent.VK_Q, InputEvent.CTRL_MASK));
		quit.addActionListener(new ActionListener() {
			public void actionPerformed(ActionEvent e) {
				dispose();
			}
		});
		filemenu.add(quit);
		
		JMenu helpmenu = new JMenu("Help");
		helpmenu.setMnemonic(KeyEvent.VK_H);
		menubar.add(helpmenu);
		
		final ImageIcon about_icon = Utils.createImageIcon("images/general/About16.gif");
		mnuAbout = new JMenuItem("About", about_icon);
		mnuAbout.setMnemonic(KeyEvent.VK_A);
		helpmenu.add(mnuAbout);
		
		this.setJMenuBar(menubar);
	}
	
	private void addSettingsPanel() {
        pnlSettings = new TitledPanel("Settings");
        this.addComponent(pnlSettings, 0, 0, 1,  2, 0.5, 1);
        
        JLabel time_label = new JLabel("Time units to simulate:", JLabel.LEFT);
        pnlSettings.addComponent(time_label, 0, 0, 1, 1, 1, 0);
        
        spinTime = new NumberSpinner(100, 0, 999999, 1, 5);
        time_label.setLabelFor(spinTime);
        pnlSettings.addComponent(spinTime, 1, 0, 1, 1);

        this.btnEditParams = new JButton("Edit parameters");
        pnlSettings.addComponent(btnEditParams, 0, 1, 2, 1, 0.5, 0);
        
        this.btnEditInit = new JButton("Edit initial values");
        pnlSettings.addComponent(this.btnEditInit, 0, 2, 2, 1, 1, 0);

//        settings_panel.addComponent(new JPanel(), 0, 5, 2, 1, 1, 1);
	}
	
	private void addTypePanel() {
        pnlType = new TitledPanel("Simulation type");
        
        String[] sim_types = new String[] {
        		"BooleCube", "HillCube", "HillCube (normalized)",
        		"Boolean simulation (synchronous)",
        		"Boolean simulation (asynchronous)",
				"Boolean simulation (random async.)"};
		cmbSim = new JComboBox(sim_types);
        pnlType.addComponent(cmbSim, 0, 4, 2, 1, 1, 0);
        
        this.addComponent(pnlType, 1, 0, 1, 1, 0.5, 0.5);
	}
	
	
	public JComboBox getTypeCombo() {
		return cmbSim;
	}
	
	private void addPlotTypePanel() {
        TitledPanel plot_panel = new TitledPanel("Plot type");
        this.addComponent(plot_panel, 1, 1, 1, 1, 0.5, 0.5);
        
        cmbPlotType = new JComboBox();
        cmbPlotType.addItem("Regular line diagram");
        cmbPlotType.addItem("Heatmap style");
        plot_panel.addComponent(cmbPlotType, 0, 0, 1, 1, 1, 0);
        cmbPlotType.addActionListener(new ActionListener() {
			public void actionPerformed(ActionEvent e) {
				lblOrder.setVisible(cmbPlotType.getSelectedIndex()==1);
				cmbVariables.setVisible(cmbPlotType.getSelectedIndex()==1);
				pack();
			}
        });
        
        lblOrder = new JLabel("Order of species on y-axis:");
        lblOrder.setVisible(false);
        plot_panel.addComponent(lblOrder, 0, 1, 1, 1, 1, 0);
        cmbVariables = new JComboBox();
        cmbVariables.setVisible(false);
        cmbVariables.addItem("Default ordering");
        plot_panel.addComponent(cmbVariables, 0, 2, 1, 1, 1, 0);
	}

	private void addButtons() {
		//GridLayout gridLayout = new GridLayout(1, 2);
		//gridLayout.setHgap(3);
		JPanel buttons_panel = new JPanel();
		this.addComponent(buttons_panel, 1, 2);
		
		BoxLayout boxLayout = new BoxLayout(buttons_panel, BoxLayout.LINE_AXIS);
		buttons_panel.setLayout(boxLayout);
		
		buttons_panel.add(Box.createHorizontalGlue());
		
		this.btnSim = new JButton("Simulate");
		this.btnSim.setMnemonic(KeyEvent.VK_S);
		
		this.getRootPane().setDefaultButton(this.btnSim);
		buttons_panel.add(this.btnSim);
	}
	
	public void addComponent(Component comp, int x, int y) {
		this.addComponent(comp, x, y, 1, 1);
	}
	
	public void addComponent(Component comp, int x, int y, int width, int height) {
		this.addComponent(comp, x, y, width, height, 0, 0);
	}

	public GridBagConstraints addComponent(Component comp, int x, int y, int width, int height,
			double weightx, double weighty) {
		return this.addComponent(comp, x, y, width, height, weightx, weighty, new Insets(3, 3, 3, 3));
	}
	
	public GridBagConstraints addComponent(Component comp, int x, int y, int width, int height,
			double weightx, double weighty, Insets insets) {
		GridBagConstraints gbc = new GridBagConstraints();
		gbc.fill = GridBagConstraints.BOTH;
		gbc.anchor = GridBagConstraints.NORTH;
		gbc.gridx = x;
		gbc.gridy = y;
		gbc.gridwidth = width;
		gbc.gridheight = height;
		gbc.weightx = weightx;
		gbc.weighty = weighty;
		gbc.insets = insets;
		
		this.layout.setConstraints(comp, gbc);
		this.add(comp);
		
		return gbc;
	}
	
	public JButton getEditParamsButton() {
		return btnEditParams;
	}

	public JButton getEditInitButton() {
		return btnEditInit;
	}

	public void setVariablesInWorkspace(String[] vars) {
		for (int i=0; i<vars.length; i++) {
			this.cmbVariables.addItem(
					String.format("Load from variable '%s'", new Object[] { vars[i] })
			);
		}
	}
	
	public String getSelectedVariable() {
		String text = this.cmbVariables.getSelectedItem().toString();
		if (this.cmbVariables.getSelectedIndex()==0) return "";
		else {
			String[] split_text = text.split("'");
			return split_text[1];
		}
	}

	public JButton getSimButton() {
		return btnSim;
	}
	
	public JMenuItem getOpenButton() {
		return this.mnuOpen;
	}
	
	public JMenuItem getReloadButton() {
		return this.mnuReload;
	}
	
	public JMenuItem getReloadCNAButton() {
		return this.mnuReloadCNA;
	}
	
	public JMenuItem getLoadSimulationButton() {
		return this.mnuLoadSim;
	}
	
	public JMenuItem getLoadParametersButton() {
		return this.mnuLoadParams;
	}

	public JMenuItem getLoadInitialValuesButton() {
		return this.mnuLoadInit;
	}
	

	public JMenuItem getSaveSimulationButton() {
		return this.mnuSaveSim;
	}
	
	public JMenuItem getSaveParametersButton() {
		return this.mnuSaveParams;
	}

	public JMenuItem getSaveInitialValuesButton() {
		return this.mnuSaveInit;
	}
	
	public JMenuItem getAboutButton() {
		return this.mnuAbout;
	}
	
	public int getSelectedSimulationIndex() {
		return this.cmbSim.getSelectedIndex();
	}
	
	public boolean getStoreInWorkspace() {
		return this.chkSave.isSelected();
	}
	
	public void markBusy(boolean busy) {
		Cursor cursor;
		if (busy) {
			cursor = Cursor.getPredefinedCursor(Cursor.WAIT_CURSOR);
		} else {
			cursor = Cursor.getDefaultCursor();
		}
		this.setCursor(cursor);
		this.btnSim.setEnabled(!busy);
	}
	
	public int getTime() {
		return ((Double)this.spinTime.getValue()).intValue();
	}
	
	public void setTime(double val) {
		this.spinTime.setValue(new Double(val));
	}
	
	public static void main(String[] args) {
		try {
	        UIManager.setLookAndFeel(
	            UIManager.getSystemLookAndFeelClassName());
	    } 
	    catch (UnsupportedLookAndFeelException e) {
	       // handle exception
	    }
	    catch (ClassNotFoundException e) {
	       // handle exception
	    }
	    catch (InstantiationException e) {
	       // handle exception
	    }
	    catch (IllegalAccessException e) {
	       // handle exception
	    }
		
		
		JFrame frame = new SimulateWindow("Odefy");
		frame.setSize(580, 320);
		frame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
		
		frame.setVisible(true);
		frame.pack();
	}

	public void centerScreen() {
		Dimension dim = getToolkit().getScreenSize();
		Rectangle abounds = getBounds();
		setLocation((dim.width - abounds.width) / 2,
				(dim.height - abounds.height) / 2);
		super.setVisible(true);
		requestFocus();
	}
	
	public int getPlotType() {
		return cmbPlotType.getSelectedIndex();
	}
	
}
