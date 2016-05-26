/*
 * Odefy - Copyright (c) CMB, IBIS, Helmholtz Zentrum Muenchen
 * Free for non-commerical use, for more information: see LICENSE.txt
 * http://cmb.helmholtz-muenchen.de/odefy
 */

package odefy.ui;

import java.awt.BorderLayout;
import java.awt.Color;
import java.awt.Container;
import java.awt.Window;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.awt.event.KeyEvent;

import javax.swing.BorderFactory;
import javax.swing.Box;
import javax.swing.BoxLayout;
import javax.swing.ImageIcon;
import javax.swing.JButton;
import javax.swing.JDialog;
import javax.swing.JLabel;
import javax.swing.JPanel;

public class AboutDialog extends JDialog {

	/**
	 * 
	 */
	private static final long serialVersionUID = 1765219352790428569L;
	
	private JLabel lblDescription;
	private JLabel lblURL;
	private JLabel lblVersion;
	private JLabel lblIcon;
	
	public AboutDialog(Window parent, String title) {
		super(parent, title);
		
		JPanel iconPane = new JPanel(new BorderLayout(), false);
		iconPane.setBorder(BorderFactory.createEmptyBorder(5, 5, 5, 5));
		
        this.lblIcon = new JLabel();
        this.lblIcon.setHorizontalTextPosition(JLabel.CENTER);
        this.lblIcon.setHorizontalAlignment(JLabel.CENTER);
        this.lblIcon.setAlignmentX(JLabel.CENTER_ALIGNMENT);
        iconPane.add(this.lblIcon);

		JPanel infoPane = new JPanel();
        infoPane.setLayout(new BoxLayout(infoPane, BoxLayout.PAGE_AXIS));
        infoPane.setBorder(BorderFactory.createEmptyBorder(10,10,0,10));

       
        this.lblDescription = new JLabel();
        this.lblDescription.setBorder(BorderFactory.createEmptyBorder(5, 0, 5, 0));
        infoPane.add(this.lblDescription);
        
        this.lblVersion = new JLabel();
        this.lblVersion.setBorder(BorderFactory.createEmptyBorder(5, 0, 5, 0));
        infoPane.add(this.lblVersion);
        
        this.lblURL = new JLabel();
        this.lblURL.setBorder(BorderFactory.createEmptyBorder(5, 0, 5, 0));
        infoPane.add(this.lblURL);
		
        JButton close_button = new JButton("Close");
        close_button.setMnemonic(KeyEvent.VK_C);
        close_button.addActionListener(new ActionListener() {
			public void actionPerformed(ActionEvent e) {
				dispose();
			}
        });
        this.getRootPane().setDefaultButton(close_button);
        
        JPanel buttonPane = new JPanel();
        buttonPane.setLayout(new BoxLayout(buttonPane, BoxLayout.LINE_AXIS));
        buttonPane.setBorder(BorderFactory.createEmptyBorder(6, 6, 6, 6));
        buttonPane.add(Box.createHorizontalGlue());
        buttonPane.add(close_button, BorderLayout.CENTER);
        buttonPane.add(Box.createHorizontalGlue());

        //Put everything together, using the content pane's BorderLayout.
        Container contentPane = getContentPane();
        contentPane.add(iconPane, BorderLayout.PAGE_START);
        contentPane.add(infoPane, BorderLayout.CENTER);
        contentPane.add(buttonPane, BorderLayout.PAGE_END);
        
        this.pack();
        this.setLocationRelativeTo(parent);
        contentPane.setBackground(Color.white);
        iconPane.setBackground(Color.white);
        infoPane.setBackground(Color.white);
        buttonPane.setBackground(Color.white);
        
	}
	
	public void setDescription(String text) {
		this.lblDescription.setText(text);
	}
	
	public void setUrl(String url) {
		this.lblURL.setText("Web: ".concat(url));
	}
	
	public void setVersion(String version) {
		this.lblVersion.setText("Version: ".concat(version));
	}
	
	public void setIcon(String path) {
		ImageIcon icon = Utils.createImageIcon(path);
		this.lblIcon.setIcon(icon);
	}
	
	public static void main(String[] args) {
		AboutDialog A = new AboutDialog(null,"a");
		A.setVisible(true);
	}
	
}
