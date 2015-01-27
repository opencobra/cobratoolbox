/*
 * Odefy - Copyright (c) CMB, IBIS, Helmholtz Zentrum Muenchen
 * Free for non-commerical use, for more information: see LICENSE.txt
 * http://cmb.helmholtz-muenchen.de/odefy
 */

package odefy.ui;

import java.awt.Component;
import java.awt.GridBagConstraints;
import java.awt.GridBagLayout;
import java.awt.Insets;

import javax.swing.BorderFactory;
import javax.swing.JPanel;
import javax.swing.border.Border;

public class TitledPanel extends JPanel {
	
	/**
	 * 
	 */
	private static final long serialVersionUID = -5910689913116250947L;
	
	private GridBagLayout layout;

	public TitledPanel(String title) {
		this(null, title, null);
	}
	
	public TitledPanel(String title, Component child) {
		this(null, title, child);
	}
	
	public TitledPanel (Border border, String title) {
		this(border, title, null);
	}
	
	public TitledPanel(Border border, String title, Component child) {
		this.layout = new GridBagLayout();
		this.setLayout(layout);
		this.setDoubleBuffered(false);
		
		if (border == null)
			this.setBorder(BorderFactory.createTitledBorder(title));
		else
			this.setBorder(BorderFactory.createTitledBorder(border, title));
		
		if (child != null) this.add(child);
	}

	public GridBagConstraints addComponent(Component comp, int x, int y) {
		return this.addComponent(comp, x, y, 1, 1);
	}
	
	public GridBagConstraints addComponent(Component comp, int x, int y, int width, int height) {
		return this.addComponent(comp, x, y, width, height, 0, 0);
	}
	
	public GridBagConstraints addComponent(Component comp, int x, int y, int width, int height,
			double weightx, double weighty) {
		return this.addComponent(comp, x, y, width, height, weightx, weighty, new Insets(6, 6, 6, 6));
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
	
}

