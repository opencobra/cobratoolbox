
import java.awt.EventQueue;

import javax.swing.JFrame;
import javax.swing.JPanel;
import javax.swing.border.TitledBorder;
import javax.swing.JLabel;
import javax.swing.JTextField;
import javax.swing.DefaultListModel;
import javax.swing.JButton;
import javax.swing.SwingConstants;
import javax.swing.JList;
import javax.swing.JOptionPane;

import java.awt.Canvas;
import java.awt.Color;
import java.awt.Dimension;
import java.awt.event.ActionListener;
import java.awt.image.BufferStrategy;
import java.awt.image.BufferedImage;
import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Random;
import java.awt.event.ActionEvent;
import java.awt.SystemColor;
import java.awt.Toolkit;

import javax.swing.UIManager;
import javax.swing.WindowConstants;

import java.awt.Font;
import java.awt.Graphics;
import java.awt.Graphics2D;
import java.awt.GraphicsConfiguration;
import java.awt.GraphicsDevice;
import java.awt.GraphicsEnvironment;

import javax.swing.JScrollPane;
import javax.swing.JTable;
import javax.swing.table.DefaultTableModel;

import com.sun.javafx.font.Disposer;

import matlabcontrol.extensions.MatlabNumericArray;

import javax.swing.JSpinner;
import javax.swing.SpinnerNumberModel;
import javax.swing.ListModel;
import javax.swing.JComboBox;
import javax.swing.DefaultComboBoxModel;
import javax.swing.DropMode;
import javax.swing.JRadioButton;
import java.awt.event.FocusAdapter;
import java.awt.event.FocusEvent;
import javax.swing.JCheckBox;
import javax.swing.JColorChooser;

public class InputWindow {

	JFrame frmAcbm;
	private JFrame frame2;
	private JFrame app;
	private JTextField countField;
	private JTextField scaleField;
	private JTextField radiusField;
	private JTextField lengthField;
	private JTextField massField;
	private JTextField eatRadiusField;
	private JTextField matFileField;
	private JTextField speedField;
	private JTextField metCountField;
	private JList bacList;
	private JList metaboliteList;
	private JList<String> feedlist;
    private JTextField searchRadiusField;
    private JTextField surviveTimeField;
    private JTextField timeLimitField;
    private JComboBox bacNameComboBox;
	
    //bacteria and metabolite properties:    
    static ArrayList<String> bacteria_name = new ArrayList<String>();
    static ArrayList<Integer> bacteria_count = new ArrayList<Integer>();
    static ArrayList<Double> bacteria_conc = new ArrayList<Double>();
    static ArrayList<Integer> doubling_time = new ArrayList<Integer>();
    static ArrayList<Integer> bacteria_scale = new ArrayList<Integer>();
    static ArrayList<Double> r_bac = new ArrayList<Double>();
    static ArrayList<Double> l_bac = new ArrayList<Double>();
    static ArrayList<Double> v_bac = new ArrayList<Double>();
    static ArrayList<Double> m_bac = new ArrayList<Double>();
    static ArrayList<String> mFile = new ArrayList<String>();
    static ArrayList<Integer> bacteria_speed = new ArrayList<Integer>();
    static ArrayList<Integer> t_survive = new ArrayList<Integer>();
    static ArrayList<Integer> r_search = new ArrayList<Integer>();
    
    static ArrayList<String> metabolite_name = new ArrayList<String>();
    static ArrayList<Integer> metabolite_count = new ArrayList<Integer>();
    static ArrayList<Double> metabolite_conc = new ArrayList<Double>();
    static ArrayList<Double> metabolite_mw = new ArrayList<Double>();    
    static ArrayList<Integer> metabolite_index = new ArrayList<Integer>();
    static ArrayList<Integer> metabolite_speed = new ArrayList<Integer>();
    static ArrayList<Double> metabolite_uub = new ArrayList<Double>();    
    static ArrayList<ArrayList<String>> ex_rxns_name = new ArrayList<ArrayList<String>>();
    static ArrayList<ArrayList<Integer>> ex_rxns_direction = new ArrayList<ArrayList<Integer>>();
    static ArrayList<ArrayList<Integer>> substrate = new ArrayList<ArrayList<Integer>>();
    static ArrayList<Double> eat_radius = new ArrayList<Double>();
    static ArrayList<Color> bacteria_color = new ArrayList<Color>();
    static ArrayList<Color> metabolite_color = new ArrayList<Color>();
    static ArrayList<Integer[]> feeding_points = new ArrayList<Integer[]>();

    
    static int tickslimit;
    static int tickTime;
    static int L;
    static int D;
    static int W;
    static double V;
    static boolean stirredFeed;
    public static double n_real;
    private JTable table;
    
    private static boolean out = false;
    private JTextField envLField;
    private JTextField envWField;
    private JTextField metSpeedField;
    private JTextField xFeedField;
    private JTextField yFeedField;
    private JTextField zFeedField;
    private JTextField molarMassField;
    private JTextField tickTimeField;
    private JTextField metScaleField1;
    private JTextField metScaleField2;
    private JTextField uptakeUBField;
    private JTextField envDField;


	/**
	 * Launch the application.
	 */
	public static void main(String[] args) {
		EventQueue.invokeLater(new Runnable() {
			public void run() {
				try {
					InputWindow window = new InputWindow();
					window.frmAcbm.setVisible(true);
				} catch (Exception e) {
					e.printStackTrace();
				}
			}
		});
	}

	/**
	 * Create the application.
	 */
	public InputWindow() {
		initialize();
		getFrame().setVisible(true);
		
	}

	/**
	 * Initialize the contents of the frame.
	 */
	private void initialize() {
		setFrame(new JFrame());
		Dimension screenSize = Toolkit.getDefaultToolkit().getScreenSize();
		int screenWidth = (int) screenSize.getWidth();
		int screenHeight = (int) screenSize.getHeight();
		getFrame().setBounds(screenWidth/2 - 493, screenHeight/2 - 290, 973, 595);
		//getFrame().setBounds(100, 100, 986, 498);
		getFrame().setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
		getFrame().getContentPane().setLayout(null);
		
		JPanel panel = new JPanel();
		panel.setBorder(new TitledBorder(UIManager.getBorder("TitledBorder.border"), "Cell", TitledBorder.LEADING, TitledBorder.TOP, null, new Color(0, 0, 0)));
		panel.setBounds(26, 11, 299, 407);
		getFrame().getContentPane().add(panel);
		panel.setLayout(null);
		
		JLabel lblName = new JLabel("Name");
		lblName.setHorizontalAlignment(SwingConstants.LEFT);
		lblName.setBounds(14, 24, 56, 14);
		panel.add(lblName);
		
		JLabel lblCount = new JLabel("Amount");
		lblCount.setHorizontalAlignment(SwingConstants.LEFT);
		lblCount.setBounds(14, 49, 56, 14);
		panel.add(lblCount);
		
		countField = new JTextField();
		countField.setText("0.1");
		countField.setBounds(203, 46, 42, 20);
		panel.add(countField);
		countField.setColumns(10);
		
		JLabel lblScale = new JLabel("Scale");
		lblScale.setBounds(14, 74, 55, 14);
		panel.add(lblScale);
		
		scaleField = new JTextField();
		scaleField.setText("500");
		scaleField.setBounds(203, 71, 86, 20);
		panel.add(scaleField);
		scaleField.setColumns(10);
		
		JLabel lblRadius = new JLabel("Radius (\u00B5m)");
		lblRadius.setBounds(14, 123, 113, 14);
		panel.add(lblRadius);
		
		radiusField = new JTextField();
		radiusField.setText("0.6");
		radiusField.setBounds(203, 120, 86, 20);
		panel.add(radiusField);
		radiusField.setColumns(10);
		
		JLabel lblLength = new JLabel("Length (\u00B5m)");
		lblLength.setBounds(14, 148, 114, 14);
		panel.add(lblLength);
		
		lengthField = new JTextField();
		lengthField.setText("1");
		lengthField.setBounds(203, 145, 86, 20);
		panel.add(lengthField);
		lengthField.setColumns(10);
		
		JLabel lblMass = new JLabel("Mass (pg)");
		lblMass.setBounds(14, 177, 129, 14);
		panel.add(lblMass);
		
		massField = new JTextField();
		massField.setText("1.29");
		massField.setBounds(203, 174, 86, 20);
		panel.add(massField);
		massField.setColumns(10);
		
		JLabel lblEatR = new JLabel("Eat Radius (...*Radius)");
		lblEatR.setBounds(14, 202, 166, 14);
		panel.add(lblEatR);
		
		eatRadiusField = new JTextField();
		eatRadiusField.setText("4");
		eatRadiusField.setBounds(203, 199, 86, 20);
		panel.add(eatRadiusField);
		eatRadiusField.setColumns(10);
		
		JLabel lblMatF = new JLabel("Mat File Name");
		lblMatF.setBounds(14, 227, 166, 14);
		panel.add(lblMatF);
		
		matFileField = new JTextField();
		matFileField.setText("iJO1366.mat");
		matFileField.setBounds(203, 224, 86, 20);
		panel.add(matFileField);
		matFileField.setColumns(10);
		
		JLabel lblSpeed = new JLabel("Speed (\u00B5m/hr)");
		lblSpeed.setBounds(14, 252, 110, 14);
		panel.add(lblSpeed);
		
		speedField = new JTextField();
		speedField.setText("8000");
		speedField.setBounds(203, 249, 86, 20);
		panel.add(speedField);
		speedField.setColumns(10);	
		
		JPanel panel_3 = new JPanel();
		panel_3.setBorder(new TitledBorder(null, "Object List", TitledBorder.LEADING, TitledBorder.TOP, null, null));
		panel_3.setBounds(641, 11, 299, 303);
		getFrame().getContentPane().add(panel_3);
		panel_3.setLayout(null);
		
		DefaultListModel<String> dlm = new DefaultListModel<String>();
		bacList = new JList<>(dlm);
		bacList.addFocusListener(new FocusAdapter() {
			@Override
			public void focusGained(FocusEvent arg0) {
				metaboliteList.clearSelection();
			}
		});
		bacList.setBounds(10, 25, 131, 233);
		panel_3.add(bacList);
		bacList.setBackground(SystemColor.control);
		bacList.setBorder(new TitledBorder(UIManager.getBorder("TitledBorder.border"), "Bacteria List", TitledBorder.LEADING, TitledBorder.TOP, null, new Color(0, 0, 0)));
		
		JComboBox bacUnitComboBox = new JComboBox();
		bacUnitComboBox.setModel(new DefaultComboBoxModel(new String[] {"g/L", "count"}));
		bacUnitComboBox.setSelectedIndex(0);
		bacUnitComboBox.setBounds(247, 46, 42, 20);
		panel.add(bacUnitComboBox);
		
		JRadioButton rdbtnCocci = new JRadioButton("Cocci");
		JRadioButton rdbtnBacilli = new JRadioButton("Bacilli");
		
		JButton btnChooseColor = new JButton("Choose Color");
		btnChooseColor.setFont(new Font("Tahoma", Font.PLAIN, 11));
		btnChooseColor.addActionListener(new ActionListener() {
			public void actionPerformed(ActionEvent arg0) {
				 Color newColor = JColorChooser.showDialog(panel, "Choose Bacteria Color", null);
	                if(newColor != null){
	                	btnChooseColor.setBackground(newColor);
	                }
			}
		});
		btnChooseColor.setForeground(Color.WHITE);
		btnChooseColor.setBackground(Color.BLUE);
		btnChooseColor.setBounds(187, 326, 102, 20);
		panel.add(btnChooseColor);
		
		JButton btnAddBacteria = new JButton("ADD CELL");
		btnAddBacteria.addActionListener(new ActionListener() {
			public void actionPerformed(ActionEvent arg0) {
				int size = bacteria_name.size();
				try {
					bacteria_name.add((String) bacNameComboBox.getSelectedItem());
					if (bacUnitComboBox.getSelectedIndex() == 0) {
						bacteria_conc.add(Double.parseDouble(countField.getText()));
						bacteria_count.add(-1);
					} else {
						bacteria_count.add(Integer.parseInt(countField.getText()));
						bacteria_conc.add(-1.0);
					}
					bacteria_scale.add(Integer.parseInt(scaleField.getText()));
//					doubling_time.add(Integer.parseInt(dtField.getText()));
					if (radiusField.isEnabled()) {
						r_bac.add( Double.parseDouble(radiusField.getText()) * (Math.cbrt(bacteria_scale.get(bacteria_scale.size()-1))) );
					} else {
						r_bac.add(0.0);
					}
					if (rdbtnCocci.isSelected()) {
						l_bac.add(0.0);
					} else {
						l_bac.add(Double.parseDouble(lengthField.getText()) * (Math.cbrt(bacteria_scale.get(bacteria_scale.size()-1))));
					}
		        		if ( l_bac.get(l_bac.size()-1) == 0.0 ) {
		            		v_bac.add( (4/3)*Math.PI*Math.pow(r_bac.get(r_bac.size()-1), 3)*Math.pow(10, -18) );
		        		}
		        		else {
		            		v_bac.add( Math.PI*Math.pow(r_bac.get(r_bac.size()-1), 2)*l_bac.get(l_bac.size()-1)*Math.pow(10, -18) );
		        		}
					if (massField.getText() == "") {
		        		m_bac.add( 1.1*v_bac.get(v_bac.size()-1)*Math.pow(10, 6) );
					} else {
						m_bac.add(Double.parseDouble(massField.getText())*Math.pow(10, -12)*bacteria_scale.get(bacteria_scale.size()-1));
					}
					eat_radius.add(Double.parseDouble(eatRadiusField.getText()));
					mFile.add(matFileField.getText());
					bacteria_speed.add(Integer.parseInt(speedField.getText()));
					r_search.add(Integer.parseInt(searchRadiusField.getText()));
					t_survive.add(Integer.parseInt(surviveTimeField.getText()));
					bacteria_color.add(btnChooseColor.getBackground());
					
					dlm.addElement((String) bacNameComboBox.getSelectedItem());
					
					int r = new Random().nextInt(255);
					int g = new Random().nextInt(255);
					int b = new Random().nextInt(255);
					Color randomColor = new Color(r, g, b);
			        btnChooseColor.setBackground(randomColor);
			        
				} catch (Exception e) {
					JOptionPane.showMessageDialog(getFrame(), "Invalid Input. Try Again", "Error", JOptionPane.ERROR_MESSAGE);
					if (bacteria_name.size() > size) {
						bacteria_name.remove(bacteria_name.size()-1);
					}
					if (bacteria_conc.size() > size) {
						bacteria_conc.remove(bacteria_conc.size()-1);
					}
					if (bacteria_count.size() > size) {
						bacteria_count.remove(bacteria_count.size()-1);
					}
					if (bacteria_scale.size() > size) {
						bacteria_scale.remove(bacteria_scale.size()-1);
					}
					if (bacteria_speed.size() > size) {
						bacteria_speed.remove(bacteria_speed.size()-1);
					}
//					if (doubling_time.size() > size) {
//						doubling_time.remove(doubling_time.size()-1);
//					}
					if (r_bac.size() > size) {
						r_bac.remove(r_bac.size()-1);
					}
					if (l_bac.size() > size) {
						l_bac.remove(l_bac.size()-1);
					}
					if (v_bac.size() > size) {
						v_bac.remove(v_bac.size()-1);
					}
					if (m_bac.size() > size) {
						m_bac.remove(m_bac.size()-1);
					}
					if (eat_radius.size() > size) {
						eat_radius.remove(eat_radius.size()-1);
					}
					if (t_survive.size() > size) {
						t_survive.remove(t_survive.size()-1);
					}
					if (mFile.size() > size) {
						mFile.remove(mFile.size()-1);
					}
					if (r_search.size() > size) {
						r_search.remove(r_search.size()-1);
					}
					if (bacteria_color.size() > size) {
						bacteria_color.remove(bacteria_color.size()-1);
					}
				}
			}
		});
		btnAddBacteria.setBounds(66, 373, 160, 23);
		panel.add(btnAddBacteria);
		
		JLabel lblSearch = new JLabel("Search Radius (\u00B5m)");
		lblSearch.setBounds(14, 277, 166, 14);
		panel.add(lblSearch);
		
		searchRadiusField = new JTextField();
		searchRadiusField.setText("3500");
		searchRadiusField.setColumns(10);
		searchRadiusField.setBounds(203, 274, 86, 20);
		panel.add(searchRadiusField);
		
		JLabel lblSurvive = new JLabel("Survive Time (min)");
		lblSurvive.setBounds(14, 302, 166, 14);
		panel.add(lblSurvive);
		
		surviveTimeField = new JTextField();
		surviveTimeField.setText("360");
		surviveTimeField.setColumns(10);
		surviveTimeField.setBounds(203, 299, 86, 20);
		panel.add(surviveTimeField);
		
//		JButton btnColor = new JButton("Choose Color");
//		btnColor.addActionListener(new ActionListener() {
//			public void actionPerformed(ActionEvent arg0) {
//			}
//		});
//		
//		btnColor.setBounds(14, 349, 129, 23);
//		panel.add(btnColor);
		
		JLabel label = new JLabel("*");
		label.setForeground(Color.RED);
		label.setBounds(187, 24, 6, 14);
		panel.add(label);
		
		JLabel label_1 = new JLabel("*");
		label_1.setForeground(Color.RED);
		label_1.setBounds(187, 49, 6, 14);
		panel.add(label_1);
		
		JLabel label_2 = new JLabel("*");
		label_2.setForeground(Color.RED);
		label_2.setBounds(187, 74, 6, 14);
		panel.add(label_2);
		
		JLabel label_4 = new JLabel("*");
		label_4.setForeground(Color.RED);
		label_4.setBounds(187, 123, 6, 14);
		panel.add(label_4);
		
		JLabel label_5 = new JLabel("*");
		label_5.setForeground(Color.RED);
		label_5.setBounds(187, 202, 6, 14);
		panel.add(label_5);
		
		JLabel label_6 = new JLabel("*");
		label_6.setForeground(Color.RED);
		label_6.setBounds(187, 227, 6, 14);
		panel.add(label_6);
		
		JLabel label_7 = new JLabel("*");
		label_7.setForeground(Color.RED);
		label_7.setBounds(187, 252, 6, 14);
		panel.add(label_7);
		
		JLabel label_8 = new JLabel("*");
		label_8.setForeground(Color.RED);
		label_8.setBounds(187, 277, 6, 14);
		panel.add(label_8);
		
		JLabel label_9 = new JLabel("*");
		label_9.setForeground(Color.RED);
		label_9.setBounds(187, 302, 6, 14);
		panel.add(label_9);
		
		JLabel label_23 = new JLabel("*");
		label_23.setForeground(Color.RED);
		label_23.setBounds(187, 148, 6, 14);
		panel.add(label_23);
		
		JLabel lblShape = new JLabel("Shape");
		lblShape.setBounds(14, 99, 55, 14);
		panel.add(lblShape);


		rdbtnCocci.addActionListener(new ActionListener() {
			public void actionPerformed(ActionEvent e) {
				if (rdbtnCocci.isSelected()) {
					rdbtnBacilli.setSelected(false);
					lengthField.setText("");
					lengthField.setEnabled(false);
					label_23.setEnabled(false);
				} else {
					rdbtnBacilli.setSelected(true);
					lengthField.setText("1");
					lengthField.setEnabled(true);
					label_23.setEnabled(true);
				}

			}
		});
		rdbtnCocci.setBounds(235, 94, 58, 23);
		panel.add(rdbtnCocci);
		
		rdbtnBacilli.addActionListener(new ActionListener() {
			public void actionPerformed(ActionEvent e) {
				if (rdbtnBacilli.isSelected()) {
					rdbtnCocci.setSelected(false);
					lengthField.setEnabled(true);
					lengthField.setText("1");
					label_23.setEnabled(true);
				} else {
					rdbtnCocci.setSelected(true);
					lengthField.setText("");
					lengthField.setEnabled(false);
					label_23.setEnabled(false);
				}

			}
		});
		rdbtnBacilli.setSelected(true);
		rdbtnBacilli.setBounds(178, 93, 59, 23);
		panel.add(rdbtnBacilli);
		
		bacNameComboBox = new JComboBox();
		bacNameComboBox.addActionListener(new ActionListener() {
			public void actionPerformed(ActionEvent arg0) {
				switch (bacNameComboBox.getSelectedIndex()) {
				case 0:
					rdbtnBacilli.setSelected(true);
					rdbtnCocci.setSelected(false);
					label_23.setEnabled(true);
					lengthField.setEnabled(true);
					radiusField.setText("0.61");
					lengthField.setText("1");
					massField.setText("1.29");
					matFileField.setText("iJO1366TRFBA");
					break;
				case 1:
					rdbtnBacilli.setSelected(true);
					rdbtnCocci.setSelected(false);
					label_23.setEnabled(true);
					lengthField.setEnabled(true);
					radiusField.setText("0.76");
					lengthField.setText("1.25");
					massField.setText("2.5");
					matFileField.setText("iYO844");
					break;
				case 2:
					rdbtnBacilli.setSelected(true);
					rdbtnCocci.setSelected(false);
					label_23.setEnabled(true);
					lengthField.setEnabled(true);
					radiusField.setText("2.92");
					lengthField.setText("3.1");
					massField.setText("93");
					matFileField.setText("iMM904");
					break;
				case 3:
					rdbtnBacilli.setSelected(true);
					rdbtnCocci.setSelected(false);
					label_23.setEnabled(true);
					lengthField.setEnabled(true);
					radiusField.setText("2.4");
					lengthField.setText("2.4");
					massField.setText("48.4");
					matFileField.setText("iBB814");
					break;
				case 4:
					rdbtnBacilli.setSelected(true);
					rdbtnCocci.setSelected(false);
					label_23.setEnabled(true);
					lengthField.setEnabled(true);
					radiusField.setText("0.9");
					lengthField.setText("4.75");
					massField.setText("13.3");
					matFileField.setText("iBif452");
					break;
				case 5:
					rdbtnBacilli.setSelected(true);
					rdbtnCocci.setSelected(false);
					label_23.setEnabled(true);
					lengthField.setEnabled(true);
					radiusField.setText("0.65");
					lengthField.setText("5.5");
					massField.setText("8");
					matFileField.setText("iFap484");
					break;
				case 6:
					rdbtnBacilli.setSelected(true);
					rdbtnCocci.setSelected(false);
					label_23.setEnabled(true);
					lengthField.setEnabled(true);
					radiusField.setText("0.75");
					lengthField.setText("1.7");
					massField.setText("3.4");
					matFileField.setText("iJL432");
					break;
				default:
					radiusField.setText("");
					lengthField.setText("");
					massField.setText("");
					matFileField.setText("");
					break;
				}
			}
		});
		bacNameComboBox.setModel(new DefaultComboBoxModel(new String[] {"E. coli", "B. subtilis", "S. cervisiae", "S. stipitis", "B. adolescentis", "F. prausnitzii", "C. beijerinckii", "Custom..."}));
		bacNameComboBox.setSelectedIndex(0);
		bacNameComboBox.setEditable(true);
		bacNameComboBox.setBounds(203, 21, 86, 20);
		panel.add(bacNameComboBox);


		
		JPanel panel_1 = new JPanel();
		panel_1.setBorder(new TitledBorder(null, "Metabolite", TitledBorder.LEADING, TitledBorder.TOP, null, null));
		panel_1.setBounds(335, 11, 296, 218);
		getFrame().getContentPane().add(panel_1);
		panel_1.setLayout(null);
		
		JLabel lblMetName = new JLabel("Name");
		lblMetName.setBounds(10, 24, 86, 14);
		panel_1.add(lblMetName);
		
		molarMassField = new JTextField();
		molarMassField.setText("180");
		molarMassField.setColumns(10);
		molarMassField.setBounds(194, 71, 92, 20);
		panel_1.add(molarMassField);
		
		JComboBox metNamecomboBox = new JComboBox();
		metNamecomboBox.addActionListener(new ActionListener() {
			public void actionPerformed(ActionEvent arg0) {
				switch (metNamecomboBox.getSelectedIndex()) {
				case 0:
					molarMassField.setText("180");
					break;
				case 1:
					molarMassField.setText("60");
					break;
				case 2:
					molarMassField.setText("88");
					break;
				case 3:
					molarMassField.setText("46");
					break;
				case 4:
					molarMassField.setText("46");
					break;
				case 5:
					molarMassField.setText("92");
					break;
				default:
					molarMassField.setText("");
						
				}
			}
		});
		
		metNamecomboBox.setEditable(true);
		metNamecomboBox.setModel(new DefaultComboBoxModel(new String[] {"Glucose", "Acetate", "Butyrate", "Formate", "Ethanol", "Glycerol", "Custom..."}));
		metNamecomboBox.setSelectedIndex(0);
		metNamecomboBox.setBounds(194, 21, 92, 20);
		panel_1.add(metNamecomboBox);
		
		JLabel lblMetCount = new JLabel("Amount");
		lblMetCount.setBounds(10, 49, 86, 14);
		panel_1.add(lblMetCount);
		
		metCountField = new JTextField();
		metCountField.setText("10");
		metCountField.setBounds(194, 46, 48, 20);
		panel_1.add(metCountField);
		metCountField.setColumns(10);
		
		JComboBox metUnitComboBox = new JComboBox();
		metUnitComboBox.setModel(new DefaultComboBoxModel(new String[] {"g/L", "count"}));
		metUnitComboBox.setSelectedIndex(0);
		metUnitComboBox.setBounds(244, 46, 42, 20);
		panel_1.add(metUnitComboBox);
		
		DefaultListModel<String> dlm2 = new DefaultListModel<String>();
		metaboliteList = new JList<>(dlm2);
		metaboliteList.addFocusListener(new FocusAdapter() {
			@Override
			public void focusGained(FocusEvent e) {
				bacList.clearSelection();
			}
		});
		metaboliteList.setBounds(151, 25, 131, 233);
		panel_3.add(metaboliteList);
		metaboliteList.setSelectedIndex(0);
		metaboliteList.setBorder(new TitledBorder(UIManager.getBorder("TitledBorder.border"), "Metabolite List", TitledBorder.LEADING, TitledBorder.TOP, null, new Color(0, 0, 0)));
		metaboliteList.setBackground(SystemColor.menu);
		
		JButton btnRemove = new JButton("REMOVE OBJECT");
		btnRemove.addActionListener(new ActionListener() {
			public void actionPerformed(ActionEvent arg0) {
				int index = bacList.getSelectedIndex();
				int removeIndex;
				if (index == -1) {
					index = metaboliteList.getSelectedIndex();
					if (index == -1) {
						return;
					}
					removeIndex = metabolite_name.indexOf(dlm2.getElementAt(index));
					metabolite_name.remove(removeIndex);
					metabolite_count.remove(removeIndex);
					metabolite_conc.remove(removeIndex);
					metabolite_mw.remove(removeIndex);
					metabolite_speed.remove(removeIndex);
					metabolite_index.remove(removeIndex);
					dlm2.removeElementAt(index);
					return;
				}
				removeIndex = bacteria_name.indexOf(dlm.getElementAt(index));
				bacteria_name.remove(removeIndex);
				bacteria_count.remove(removeIndex);
				bacteria_conc.remove(removeIndex);
				bacteria_scale.remove(removeIndex);
//				doubling_time.remove(removeIndex);
				r_bac.remove(removeIndex);
				l_bac.remove(removeIndex);
				v_bac.remove(removeIndex);
				m_bac.remove(removeIndex);
				eat_radius.remove(removeIndex);
				mFile.remove(removeIndex);
				bacteria_speed.remove(removeIndex);
				r_search.remove(removeIndex);
				t_survive.remove(removeIndex);
				bacteria_color.remove(removeIndex);
				dlm.removeElementAt(index);

			}
		});
		btnRemove.setBounds(73, 269, 160, 23);
		panel_3.add(btnRemove);
		
		
		JButton btnMetChooseColor = new JButton("Choose Color");
		btnMetChooseColor.addActionListener(new ActionListener() {
			public void actionPerformed(ActionEvent arg0) {
				 Color newColor = JColorChooser.showDialog(panel, "Choose Metabolite Color", null);
	                if(newColor != null){
	                	btnMetChooseColor.setBackground(newColor);
	                }
			}
		});
		btnMetChooseColor.setForeground(Color.WHITE);
		btnMetChooseColor.setFont(new Font("Tahoma", Font.PLAIN, 11));
		btnMetChooseColor.setBackground(Color.ORANGE);
		btnMetChooseColor.setBounds(184, 145, 102, 20);
		panel_1.add(btnMetChooseColor);
		
		JButton btnAddMetabolite = new JButton("ADD METABOLITE");
		btnAddMetabolite.addActionListener(new ActionListener() {
			public void actionPerformed(ActionEvent e) {
				int size = metabolite_name.size();
				try {
					metabolite_name.add((String) metNamecomboBox.getSelectedItem());
					if (metUnitComboBox.getSelectedIndex() == 0) {
						metabolite_conc.add(Double.parseDouble(metCountField.getText()));
						metabolite_count.add(-1);
					} else {
						metabolite_count.add(Integer.parseInt(metCountField.getText()));
						metabolite_conc.add(-1.0);
					}
					metabolite_mw.add(Double.parseDouble(molarMassField.getText()));
					metabolite_color.add(btnMetChooseColor.getBackground());
					
					metabolite_index.add(0);
					metabolite_speed.add(Integer.parseInt(metSpeedField.getText()));
					metabolite_uub.add(Double.parseDouble(uptakeUBField.getText()));
					
					dlm2.addElement((String) metNamecomboBox.getSelectedItem());
					
					int r = new Random().nextInt(255);
					int g = new Random().nextInt(255);
					int b = new Random().nextInt(255);
					Color randomColor = new Color(r, g, b);
			        btnMetChooseColor.setBackground(randomColor);
					
				} catch (Exception e2) {
					JOptionPane.showMessageDialog(getFrame(), "Invalid Input. Try Again", "Error", JOptionPane.ERROR_MESSAGE);
					if (metabolite_name.size() > size) {
						metabolite_name.remove(metabolite_name.size()-1);
					}
					if (metabolite_count.size() > size) {
						metabolite_count.remove(metabolite_count.size()-1);
					}
					if (metabolite_conc.size() > size) {
						metabolite_conc.remove(metabolite_conc.size()-1);
					}
					if (metabolite_mw.size() > size) {
						metabolite_mw.remove(metabolite_mw.size()-1);
					}
					if (metabolite_color.size() > size) {
						metabolite_color.remove(metabolite_color.size()-1);
					}
					if (metabolite_index.size() > size) {
						metabolite_index.remove(metabolite_index.size()-1);
					}
					if (metabolite_speed.size() > size) {
						metabolite_speed.remove(metabolite_speed.size()-1);
					}
					if (metabolite_uub.size() > size) {
						metabolite_uub.remove(metabolite_uub.size()-1);
					}
				}
				
			}
		});
		btnAddMetabolite.setBounds(62, 185, 173, 23);
		panel_1.add(btnAddMetabolite);
		
		JLabel label_10 = new JLabel("*");
		label_10.setForeground(Color.RED);
		label_10.setBounds(184, 24, 6, 14);
		panel_1.add(label_10);
		
		JLabel label_11 = new JLabel("*");
		label_11.setForeground(Color.RED);
		label_11.setBounds(184, 49, 6, 14);
		panel_1.add(label_11);
		
		JLabel lblSpeed_1 = new JLabel("Speed (\u00B5m/hr)");
		lblSpeed_1.setBounds(10, 98, 86, 14);
		panel_1.add(lblSpeed_1);
		
		metSpeedField = new JTextField();
		metSpeedField.setText("8000");
		metSpeedField.setColumns(10);
		metSpeedField.setBounds(194, 95, 92, 20);
		panel_1.add(metSpeedField);
		
		JLabel label_17 = new JLabel("*");
		label_17.setForeground(Color.RED);
		label_17.setBounds(184, 74, 6, 14);
		panel_1.add(label_17);
		
		JLabel lblMolarMass = new JLabel("Molar Mass (g/mol)");
		lblMolarMass.setBounds(10, 74, 106, 14);
		panel_1.add(lblMolarMass);
		
		JLabel label_21 = new JLabel("*");
		label_21.setForeground(Color.RED);
		label_21.setBounds(184, 98, 6, 14);
		panel_1.add(label_21);
		
		JLabel lblUptakeUpperBound = new JLabel("Uptake Upper Bound (mmol/g.hr)");
		lblUptakeUpperBound.setBounds(10, 123, 173, 14);
		panel_1.add(lblUptakeUpperBound);
		
		uptakeUBField = new JTextField();
		uptakeUBField.setText("1000");
		uptakeUBField.setColumns(10);
		uptakeUBField.setBounds(194, 120, 92, 20);
		panel_1.add(uptakeUBField);
		
		JLabel label_3 = new JLabel("*");
		label_3.setForeground(Color.RED);
		label_3.setBounds(184, 123, 6, 14);
		panel_1.add(label_3);

		
		JPanel panel_2 = new JPanel();
		panel_2.setBorder(new TitledBorder(null, "General Parameters", TitledBorder.LEADING, TitledBorder.TOP, null, null));
		panel_2.setBounds(335, 240, 296, 178);
		getFrame().getContentPane().add(panel_2);
		panel_2.setLayout(null);
		
		JLabel lblTimeLimit = new JLabel("Time Limit (min)");
		lblTimeLimit.setBounds(10, 24, 164, 14);
		panel_2.add(lblTimeLimit);
		
		timeLimitField = new JTextField();
		timeLimitField.setText("1200");
		timeLimitField.setBounds(200, 21, 86, 20);
		panel_2.add(timeLimitField);
		timeLimitField.setColumns(10);
		
		JLabel label_12 = new JLabel("*");
		label_12.setForeground(Color.RED);
		label_12.setBounds(184, 24, 6, 14);
		panel_2.add(label_12);
		
		JLabel lblEnvironemntLength = new JLabel("Environemnt Length (\u00B5m)");
		lblEnvironemntLength.setBounds(10, 74, 164, 14);
		panel_2.add(lblEnvironemntLength);
		
		JLabel lblEnvironemntWidthm = new JLabel("Environemnt Width (\u00B5m)");
		lblEnvironemntWidthm.setBounds(10, 99, 164, 14);
		panel_2.add(lblEnvironemntWidthm);
		
		envLField = new JTextField();
		envLField.setText("1000");
		envLField.setColumns(10);
		envLField.setBounds(200, 71, 86, 20);
		panel_2.add(envLField);
		
		envWField = new JTextField();
		envWField.setText("400");
		envWField.setColumns(10);
		envWField.setBounds(200, 96, 86, 20);
		panel_2.add(envWField);
		
		JLabel label_13 = new JLabel("*");
		label_13.setForeground(Color.RED);
		label_13.setBounds(184, 49, 6, 14);
		panel_2.add(label_13);
		
		JLabel label_14 = new JLabel("*");
		label_14.setForeground(Color.RED);
		label_14.setBounds(184, 74, 6, 14);
		panel_2.add(label_14);
		
		JLabel lblTimeStepmin = new JLabel("Time Step (min)");
		lblTimeStepmin.setBounds(10, 49, 164, 14);
		panel_2.add(lblTimeStepmin);
		
		tickTimeField = new JTextField();
		tickTimeField.setText("1");
		tickTimeField.setColumns(10);
		tickTimeField.setBounds(200, 46, 86, 20);
		panel_2.add(tickTimeField);
		
		JLabel label_20 = new JLabel("*");
		label_20.setForeground(Color.RED);
		label_20.setBounds(184, 99, 6, 14);
		panel_2.add(label_20);
		
		JLabel label_16 = new JLabel("*");
		label_16.setForeground(Color.RED);
		label_16.setBounds(184, 148, 6, 14);
		panel_2.add(label_16);
		
		metScaleField1 = new JTextField();
		metScaleField1.setText("5");
		metScaleField1.setColumns(10);
		metScaleField1.setBounds(200, 146, 24, 20);
		panel_2.add(metScaleField1);
		
		JLabel label_22 = new JLabel("x 10 ^");
		label_22.setBounds(226, 148, 40, 14);
		panel_2.add(label_22);
		
		metScaleField2 = new JTextField();
		metScaleField2.setText("10");
		metScaleField2.setColumns(10);
		metScaleField2.setBounds(262, 146, 24, 20);
		panel_2.add(metScaleField2);
		
		JLabel lblMetaboliteScale = new JLabel("Metabolite Scale");
		lblMetaboliteScale.setBounds(10, 149, 164, 14);
		panel_2.add(lblMetaboliteScale);
		
		JLabel lblEnvironemntDepthm = new JLabel("Environemnt Depth (\u00B5m)");
		lblEnvironemntDepthm.setBounds(10, 124, 164, 14);
		panel_2.add(lblEnvironemntDepthm);
		
		envDField = new JTextField();
		envDField.setText("400");
		envDField.setColumns(10);
		envDField.setBounds(200, 121, 86, 20);
		panel_2.add(envDField);
		
		JLabel label_25 = new JLabel("*");
		label_25.setForeground(Color.RED);
		label_25.setBounds(184, 124, 6, 14);
		panel_2.add(label_25);
		
		
		JPanel panel_4 = new JPanel();
		panel_4.setLayout(null);
		panel_4.setBorder(new TitledBorder(UIManager.getBorder("TitledBorder.border"), "Feeding Strategy", TitledBorder.LEADING, TitledBorder.TOP, null, new Color(0, 0, 0)));
		panel_4.setBounds(26, 423, 427, 132);
		frmAcbm.getContentPane().add(panel_4);
		
		JLabel lblX = new JLabel("X");
		lblX.setBounds(10, 59, 16, 14);
		panel_4.add(lblX);
		
		xFeedField = new JTextField();
		xFeedField.setEnabled(false);
		xFeedField.setText("0");
		xFeedField.setBounds(28, 56, 43, 20);
		panel_4.add(xFeedField);
		xFeedField.setColumns(10);
		
		JLabel label_15 = new JLabel("*");
		label_15.setForeground(Color.RED);
		label_15.setBounds(20, 56, 6, 14);
		panel_4.add(label_15);
		
		JLabel lblY = new JLabel("Y");
		lblY.setBounds(100, 59, 16, 14);
		panel_4.add(lblY);
		
		yFeedField = new JTextField();
		yFeedField.setEnabled(false);
		yFeedField.setText("0");
		yFeedField.setColumns(10);
		yFeedField.setBounds(118, 56, 43, 20);
		panel_4.add(yFeedField);
		
		JLabel label_18 = new JLabel("*");
		label_18.setForeground(Color.RED);
		label_18.setBounds(110, 56, 6, 14);
		panel_4.add(label_18);
		
		JLabel lblZ = new JLabel("Z");
		lblZ.setBounds(191, 59, 16, 14);
		panel_4.add(lblZ);
		
		zFeedField = new JTextField();
		zFeedField.setEnabled(false);
		zFeedField.setText("0");
		zFeedField.setColumns(10);
		zFeedField.setBounds(210, 56, 43, 20);
		panel_4.add(zFeedField);
		
		JLabel label_19 = new JLabel("*");
		label_19.setForeground(Color.RED);
		label_19.setBounds(201, 56, 6, 14);
		panel_4.add(label_19);
		
		
		DefaultListModel<String> dlm3 = new DefaultListModel<String>();
		feedlist = new JList<>(dlm3);
		feedlist.setBounds(289, 11, 131, 110);
		panel_4.add(feedlist);
		feedlist.setBorder(new TitledBorder(UIManager.getBorder("TitledBorder.border"), "Feeding Points List", TitledBorder.LEADING, TitledBorder.TOP, null, new Color(0, 0, 0)));
		feedlist.setBackground(SystemColor.menu);
		
		JButton feedButton = new JButton("ADD FEEDING POINT");
		feedButton.setEnabled(false);
		feedButton.addActionListener(new ActionListener() {
			public void actionPerformed(ActionEvent arg0) {
				try {
					Integer[] coord = new Integer[3];
					coord[0] = Integer.parseInt(xFeedField.getText());
					coord[1] = Integer.parseInt(yFeedField.getText());
					coord[2] = Integer.parseInt(zFeedField.getText());
					if (coord[0] <= Integer.parseInt(envLField.getText()) && coord[1] <= Integer.parseInt(envWField.getText()) && coord[2] <= Integer.parseInt(envWField.getText()) ) {
						feeding_points.add(coord);
						dlm3.addElement(xFeedField.getText() + ", " + yFeedField.getText() + ", " + zFeedField.getText());
					} else {
						JOptionPane.showMessageDialog(getFrame(), "input must be within environment size. Try Again", "Error", JOptionPane.ERROR_MESSAGE);
					}


				} catch (Exception e) {
					JOptionPane.showMessageDialog(getFrame(), "Invalid Input. Try Again", "Error", JOptionPane.ERROR_MESSAGE);

				}
				
			}
		});
		feedButton.setBounds(68, 98, 160, 23);
		panel_4.add(feedButton);
		
		JRadioButton rdbtnStirredFeed = new JRadioButton("Stirred Feed");
		JRadioButton rdbtnLocalFeed = new JRadioButton("Local Feed");

		rdbtnStirredFeed.addActionListener(new ActionListener() {
			public void actionPerformed(ActionEvent arg0) {
				rdbtnLocalFeed.setSelected(false);
				xFeedField.setEnabled(false);
				yFeedField.setEnabled(false);
				zFeedField.setEnabled(false);
				feedButton.setEnabled(false);
			}
		});
		rdbtnStirredFeed.setSelected(true);
		rdbtnStirredFeed.setBounds(10, 24, 109, 23);
		panel_4.add(rdbtnStirredFeed);
		
		rdbtnLocalFeed.addActionListener(new ActionListener() {
			public void actionPerformed(ActionEvent arg0) {
				rdbtnStirredFeed.setSelected(false);
				xFeedField.setEnabled(true);
				yFeedField.setEnabled(true);
				zFeedField.setEnabled(true);
				feedButton.setEnabled(true);
			}
		});
		rdbtnLocalFeed.setBounds(144, 24, 109, 23);
		panel_4.add(rdbtnLocalFeed);

		
		JButton btnNext = new JButton("NEXT >>");
		btnNext.addActionListener(new ActionListener() {
			public void actionPerformed(ActionEvent e) {
				
				if (bacteria_name.isEmpty()) {
					JOptionPane.showMessageDialog(getFrame(), "No bacteria! Please add some.", "Error", JOptionPane.ERROR_MESSAGE);
					return;
				}
				
				try {
					tickslimit = Integer.parseInt(timeLimitField.getText());
					tickTime = Integer.parseInt(tickTimeField.getText());
					L = Integer.parseInt(envLField.getText());
					D = Integer.parseInt(envDField.getText());
					W = Integer.parseInt(envWField.getText());
					n_real = Double.parseDouble(metScaleField1.getText()) * Math.pow(10, Integer.parseInt(metScaleField2.getText()));
					
				} catch (Exception e2) {
					JOptionPane.showMessageDialog(getFrame(), "Invalid Input. Try Again", "Error", JOptionPane.ERROR_MESSAGE);
					return;
				}
				if (rdbtnStirredFeed.isSelected()) {
					stirredFeed = true;
				} else {
					stirredFeed = false;
				}
				cToN();
				getFrame().setVisible(false);
				getFrame().dispose();
				openFrame2();
			}
		});
		btnNext.setFont(new Font("Tahoma", Font.BOLD, 13));
		btnNext.setBounds(801, 508, 139, 32);
		getFrame().getContentPane().add(btnNext);

		
	}
	
	public void cToN() {
		V = L*W*D*Math.pow(10, -18);
		for (int i = 0; i < bacteria_conc.size(); i++) {
			if (bacteria_conc.get(i) != -1 ) {
//				System.out.println(bacteria_conc.get(i)+ ","+m_bac.get(i)+","+bacteria_scale.get(i));
				int n = (int) ( (bacteria_conc.get(i)* 1000 * V) /( m_bac.get(i) ) );
				bacteria_count.set(i, n);
			}
		}
		
		for (int i = 0; i < metabolite_conc.size(); i++) {
			if (metabolite_conc.get(i) != -1 ) {
				int n = (int) ( ((metabolite_conc.get(i)*1000 * V) / ( metabolite_mw.get(i))) * (Bacteria.n_a/n_real)  );
				metabolite_count.set(i, n);
			}
		}
	}
	
	public boolean isOut() {
		return out;
	}

	public void setOut(boolean out) {
		this.out = out;
	}

	public void openFrame2 () {
		frame2 = new JFrame();
		//frame2.setBounds(100, 100, 1200, 498);
		Dimension screenSize = Toolkit.getDefaultToolkit().getScreenSize();
		int screenWidth = (int) screenSize.getWidth();
		int screenHeight = (int) screenSize.getHeight();
		frame2.setBounds(screenWidth/2 - 600, screenHeight/2 - 249, 1200, 498);
		frame2.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
		frame2.getContentPane().setLayout(null);
		frame2.setVisible(true);
		frame2.setIconImage(Toolkit.getDefaultToolkit().getImage(InputWindow.class.getResource("/icon/acbm.png")));
		frame2.setResizable(false);
		frame2.setTitle("ACBM");
		
		
		JScrollPane scrollPane = new JScrollPane();
		scrollPane.setBounds(10, 11, 1165, 380);
		frame2.getContentPane().add(scrollPane);
		
		DefaultTableModel tmodel = new DefaultTableModel();
		table = new JTable(tmodel);
		
	    
		tmodel.addColumn("\u2193 Cell / Metabolite \u2192");
		for (int i = 0; i < metabolite_name.size(); i++) {
			tmodel.addColumn("<html>" + metabolite_name.get(i) + " Rxn" + "<br>" + "Name");
			tmodel.addColumn("<html>" + metabolite_name.get(i) + " Rxn" + "<br>" + "Direction");

		}
		
		for (int i = 0; i < bacteria_name.size(); i++) {
			tmodel.addRow(new Object[] { bacteria_name.get(i) });
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
			        	ex_rxns_name.add(al);
			        	ArrayList<Integer> al2 = new ArrayList<Integer>();
			        	for (int j = 2; j < table.getColumnCount(); j+=2) {
							al2.add(Integer.parseInt((String) table.getModel().getValueAt(i, j)));
						}
			        	ex_rxns_direction.add(al2);
					}
					
				} catch (Exception e2) {
					JOptionPane.showMessageDialog(getFrame(), "Invalid Input. Try Again", "Error", JOptionPane.ERROR_MESSAGE);
					return;
				}
				frame2.setVisible(false);
				frame2.dispose();
				frmAcbm.dispose();
				Environment.setParameters();
				RunWindow w = new RunWindow();
				w.execute();
			}
		});
		btnNext.setFont(new Font("Tahoma", Font.BOLD, 13));
		btnNext.setBounds(1000, 400, 139, 32);
		frame2.getContentPane().add(btnNext);
		
	}

	public JFrame getFrame() {
		return frmAcbm;
	}

	public void setFrame(JFrame frame) {
		this.frmAcbm = frame;
		frmAcbm.setIconImage(Toolkit.getDefaultToolkit().getImage(InputWindow.class.getResource("/icon/acbm.png")));
		frmAcbm.setResizable(false);
		frmAcbm.setTitle("ACBM");
	}
	
	private static class __Tmp {
		private static void __tmp() {
			  javax.swing.JPanel __wbp_panel = new javax.swing.JPanel();
		}
	}
}
