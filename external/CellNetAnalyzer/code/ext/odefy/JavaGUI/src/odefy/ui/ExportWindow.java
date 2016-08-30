/*
 * Odefy - Copyright (c) CMB, IBIS, Helmholtz Zentrum Muenchen
 * Free for non-commerical use, for more information: see LICENSE.txt
 * http://cmb.helmholtz-muenchen.de/odefy
 */

package odefy.ui;

import java.awt.Component;
import java.awt.Dimension;
import java.awt.GridBagConstraints;
import java.awt.GridBagLayout;
import java.awt.Insets;
import java.awt.Rectangle;
import java.awt.event.KeyEvent;

import javax.swing.Box;
import javax.swing.BoxLayout;
import javax.swing.ImageIcon;
import javax.swing.JButton;
import javax.swing.JComboBox;
import javax.swing.JFrame;
import javax.swing.JLabel;
import javax.swing.JMenu;
import javax.swing.JMenuBar;
import javax.swing.JMenuItem;
import javax.swing.JPanel;
import javax.swing.JTextField;

public class ExportWindow extends JFrame {

	/**
	 * 
	 */
	private static final long serialVersionUID = 8126753230069695207L;
	
	
	JMenuBar menubar = new JMenuBar();
	private JMenuItem mnuAbout;
	private TitledPanel pnlSettings;
	private GridBagLayout layout;
	private JPanel pnlLayout;
	private JButton btnExport;
	private JComboBox cmbTypes;
	private JTextField txtOut;

	public ExportWindow(String title) {
		super(title);

		// init GUI
		this.layout = new GridBagLayout();
		this.pnlLayout = new JPanel();
		this.pnlLayout.setLayout(this.layout);
		this.setContentPane(this.pnlLayout);		
		// generate GUI
		this.addMenu();
		this.addExportPanel();
		this.addButtons();

		this.pack();
		this.setDefaultCloseOperation(JFrame.DISPOSE_ON_CLOSE);
	}


	private void addMenu() {
		JMenu helpmenu = new JMenu("Help");
		helpmenu.setMnemonic(KeyEvent.VK_H);
		menubar.add(helpmenu);

		final ImageIcon about_icon = Utils.createImageIcon("images/general/About16.gif");
		mnuAbout = new JMenuItem("About", about_icon);
		mnuAbout.setMnemonic(KeyEvent.VK_A);
		helpmenu.add(mnuAbout);

		this.setJMenuBar(menubar);
	}

	private void addExportPanel() {
		pnlSettings = new TitledPanel("Settings");
		
		// Model type:
		pnlSettings.addComponent(new JLabel("Model type:"), 0, 0);
		pnlSettings.addComponent(cmbTypes = new JComboBox(), 1, 0);
		// File name
		pnlSettings.addComponent(new JLabel("Output file:"), 0, 1);
		pnlSettings.addComponent(txtOut = new JTextField("[click to select]"), 1, 1, 1, 1, 0.5, 0);
		
		txtOut.setEditable(false);
		this.addComponent(pnlSettings, 0, 0, 1, 2, 0.5, 1);
	}
	
	private void addButtons() {
		//GridLayout gridLayout = new GridLayout(1, 2);
		//gridLayout.setHgap(3);
		JPanel buttons_panel = new JPanel();
		this.addComponent(buttons_panel, 0, 2);
		
		BoxLayout boxLayout = new BoxLayout(buttons_panel, BoxLayout.LINE_AXIS);
		buttons_panel.setLayout(boxLayout);
		
		buttons_panel.add(Box.createHorizontalGlue());
		
		this.btnExport = new JButton("Export");
		this.btnExport.setMnemonic(KeyEvent.VK_E);
		this.getRootPane().setDefaultButton(this.btnExport);
		buttons_panel.add(this.btnExport);
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
	


	public static void main(String[] args) {
		// debugger
		new ExportWindow("ja");
	}

	
	public JMenuItem getAboutButton() {
		return this.mnuAbout;
	}
	
	public JComboBox getTypeList() {
		return cmbTypes;
	}
	
	public JTextField getTextOut() {
		return txtOut;
	}
	
	public JButton getExportButton() {
		return btnExport;
	}
	
	public void centerScreen() {
		Dimension dim = getToolkit().getScreenSize();
		Rectangle abounds = getBounds();
		setLocation((dim.width - abounds.width) / 2,
				(dim.height - abounds.height) / 2);
		super.setVisible(true);
		requestFocus();
	}

	
}
