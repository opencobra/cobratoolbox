/*
 * Odefy - Copyright (c) CMB, IBIS, Helmholtz Zentrum Muenchen
 * Free for non-commerical use, for more information: see LICENSE.txt
 * http://cmb.helmholtz-muenchen.de/odefy
 */

package odefy.ui;

import java.awt.BorderLayout;
import java.awt.Container;
import java.awt.Dimension;
import java.awt.Window;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.awt.event.KeyEvent;

import javax.swing.BorderFactory;
import javax.swing.Box;
import javax.swing.BoxLayout;
import javax.swing.JButton;
import javax.swing.JDialog;
import javax.swing.JPanel;

/**
 * Base class for dialogs
 */
public class OdefyDialog extends JDialog implements ActionListener {

	/**
	 * 
	 */
	private static final long serialVersionUID = 1093010854036669416L;
	
	private JButton btnOK;
	private JButton btnCancel;

	public OdefyDialog(Window parent, String title, ModalityType type) {
		super(parent, title, type);

		btnCancel = new JButton("Cancel");
		btnCancel.setMnemonic(KeyEvent.VK_C);
		btnCancel.addActionListener(this);
		btnOK = new JButton("OK");
		btnOK.setMnemonic(KeyEvent.VK_O);

		// Lay out the buttons from left to right.
		JPanel buttonPane = new JPanel();
		buttonPane.setLayout(new BoxLayout(buttonPane, BoxLayout.LINE_AXIS));
		buttonPane.setBorder(BorderFactory.createEmptyBorder(0, 10, 10, 10));
		buttonPane.add(Box.createHorizontalGlue());
		buttonPane.add(btnCancel);
		buttonPane.add(Box.createRigidArea(new Dimension(10, 0)));
		buttonPane.add(btnOK);

		Container contentPane = this.getContentPane();
		contentPane.add(buttonPane, BorderLayout.PAGE_END);
	}

	public JButton getOKButton() {
		return this.btnOK;
	}
	
	public JButton getCancelButton() {
		return this.btnCancel;
	}

	public void actionPerformed(ActionEvent e) {
		this.dispose();
	}

}
