/*
 * Odefy - Copyright (c) CMB, IBIS, Helmholtz Zentrum Muenchen
 * Free for non-commerical use, for more information: see LICENSE.txt
 * http://cmb.helmholtz-muenchen.de/odefy
 */

package odefy.ui;

import java.io.File;

import javax.swing.JFileChooser;
import javax.swing.filechooser.FileFilter;

public class ModelFileChooser extends JFileChooser {
	
	/**
	 * 
	 */
	private static final long serialVersionUID = -1157392574617987213L;

	private class GraphMLFileFilter extends FileFilter {

		public boolean accept(File f) {
			return f.isDirectory() || f.getAbsolutePath().toLowerCase().endsWith(".graphml");
		}

		public String getDescription() {
			return "GraphML files";
		}
		
	}
	
	public ModelFileChooser() {
		
		this.addChoosableFileFilter(new GraphMLFileFilter());
	}

}
