/*
 * Odefy - Copyright (c) CMB, IBIS, Helmholtz Zentrum Muenchen
 * Free for non-commerical use, for more information: see LICENSE.txt
 * http://cmb.helmholtz-muenchen.de/odefy
 */

package odefy.ui;

import java.io.File;

import javax.swing.JFileChooser;
import javax.swing.JOptionPane;


public class JFileChooserAskOverwrite extends JFileChooser {

	/**
	 * 
	 */
	private static final long serialVersionUID = -1908195348612085861L;


	public JFileChooserAskOverwrite() {
		super();
	}
	
	public JFileChooserAskOverwrite(String currentDirectory) {
		super(currentDirectory);
	}
	
	
	public void approveSelection() {
		File f = getSelectedFile();
		if (f.exists() && getDialogType() == SAVE_DIALOG) {
			int result = JOptionPane.showConfirmDialog(getTopLevelAncestor(),
					"The selected file already exists. "
							+ "Do you want to overwrite it?",
					"The file already exists",
					JOptionPane.YES_NO_CANCEL_OPTION,
					JOptionPane.QUESTION_MESSAGE);
			switch (result) {
			case JOptionPane.YES_OPTION:
				super.approveSelection();
				return;
			case JOptionPane.NO_OPTION:
				return;
			case JOptionPane.CANCEL_OPTION:
				cancelSelection();
				return;
			}
		}
		super.approveSelection();
	}

}
