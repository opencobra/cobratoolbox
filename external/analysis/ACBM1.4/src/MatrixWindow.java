import java.awt.Dimension;
import java.awt.Font;
import java.awt.Toolkit;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.io.IOException;
import java.util.ArrayList;

import javax.swing.JButton;
import javax.swing.JFrame;
import javax.swing.JOptionPane;
import javax.swing.JScrollPane;
import javax.swing.JTable;
import javax.swing.table.DefaultTableModel;

public class MatrixWindow {
	
	private JFrame frame;
	public JFrame getFrame() {
		return frame;
	}

	public void setFrame(JFrame frame) {
		this.frame = frame;
	}

	private JTable table;

	public MatrixWindow() {
		// TODO Auto-generated constructor stub
	}

	public static void main(String[] args) {
		// TODO Auto-generated method stub

	}
	
	public void initialize () {
		frame = new JFrame();
		//frame2.setBounds(100, 100, 1200, 498);
		Dimension screenSize = Toolkit.getDefaultToolkit().getScreenSize();
		int screenWidth = (int) screenSize.getWidth();
		int screenHeight = (int) screenSize.getHeight();
		frame.setBounds(screenWidth/2 - 600, screenHeight/2 - 249, 1200, 498);
		frame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
		frame.getContentPane().setLayout(null);
		frame.setVisible(true);
		
		JScrollPane scrollPane = new JScrollPane();
		scrollPane.setBounds(10, 11, 1165, 380);
		frame.getContentPane().add(scrollPane);
		
		DefaultTableModel tmodel = new DefaultTableModel();
		table = new JTable(tmodel);
		tmodel.addColumn("\u2193 Bacteria / Metabolite \u2192");
		for (int i = 0; i < RunWindow.metabolite_name.size(); i++) {
			tmodel.addColumn("<html>" + RunWindow.metabolite_name.get(i) + " Rxn" + "<br>" + "Name");
			tmodel.addColumn("<html>" + RunWindow.metabolite_name.get(i) + " Rxn" + "<br>" + "Direction");

		}
		
		for (int i = 0; i < RunWindow.bacteria_name.size(); i++) {
			tmodel.addRow(new Object[] { RunWindow.bacteria_name.get(i) });
		}
		table.getTableHeader().setPreferredSize(new Dimension(70, 40));
		table.getColumnModel().getColumn(0).setPreferredWidth(135);
		scrollPane.setViewportView(table);
		
		JButton btnNext = new JButton("RUN >>");
		btnNext.addActionListener(new ActionListener() {
			public void actionPerformed(ActionEvent e) {
				
				try {
					for (int i = 0; i < table.getRowCount(); i++) {
			        	ArrayList<String> al = new ArrayList<String>();
			        	for (int j = 1; j < table.getColumnCount(); j+=2) {
							al.add((String) table.getModel().getValueAt(i, j));
						}
			        	RunWindow.ex_rxns_name.add(al);
			        	ArrayList<Integer> al2 = new ArrayList<Integer>();
			        	for (int j = 2; j < table.getColumnCount(); j+=2) {
							al2.add(Integer.parseInt((String) table.getModel().getValueAt(i, j)));
						}
			        	RunWindow.ex_rxns_direction.add(al2);
					}
					
				} catch (Exception e2) {
					JOptionPane.showMessageDialog(getFrame(), "Invalid Input. Try Again", "Error", JOptionPane.ERROR_MESSAGE);
					return;
				}
				//frame2.setVisible(false);
			        Environment e1 = new Environment();       
					Environment.setParameters();
		            try {
		            	e1.initialize();
						e1.addEntity();
					} catch (IOException e2) {
						// TODO Auto-generated catch block
						e2.printStackTrace();
					}
		            frame.setVisible(false);
		            frame.dispose();
		    		new Runnable() {
		    			public void run() {
		    				try {
		    					SimulationWindow window = new SimulationWindow(e1);
		    					window.getFrame().setVisible(true);
		    					window.runGui();
		    				} catch (Exception e) {
		    					e.printStackTrace();
		    				}
		    			}
		    		}.run();
//		            runGui(e1);

			}
		});
		btnNext.setFont(new Font("Tahoma", Font.BOLD, 13));
		btnNext.setBounds(1000, 400, 139, 32);
		frame.getContentPane().add(btnNext);
		
	}

}
