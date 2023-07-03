

import java.awt.EventQueue;
import java.awt.Font;
import java.awt.Graphics;
import java.awt.Graphics2D;
import java.awt.GraphicsConfiguration;
import java.awt.GraphicsDevice;
import java.awt.GraphicsEnvironment;
import java.awt.SystemColor;
import java.awt.Toolkit;

import javax.swing.JFrame;
import java.awt.Canvas;
import javax.swing.JButton;
import java.awt.event.ActionListener;
import java.awt.image.BufferStrategy;
import java.awt.image.BufferedImage;
import java.awt.event.ActionEvent;
import javax.swing.JPanel;
import javax.swing.border.TitledBorder;
import javax.swing.JScrollPane;
import javax.swing.ScrollPaneConstants;
import javax.swing.UIManager;
import javax.swing.WindowConstants;

import java.awt.Color;
import java.awt.Dimension;

public class SimulationWindow {

	private JFrame frame;
	private JPanel panel;
	private Canvas canvas;
	Environment environment;

	/**
	 * Launch the application.
	 */
	public static void main(String[] args) {
		EventQueue.invokeLater(new Runnable() {
			public void run() {
				try {
					Environment e1 = new Environment();
					SimulationWindow window = new SimulationWindow(e1);
					window.frame.setVisible(true);
				} catch (Exception e) {
					e.printStackTrace();
				}
			}
		});
	}

	/**
	 * Create the application.
	 */
	public SimulationWindow(Environment env) {
		initialize();
		setEnvironment(env);
	}

	public Environment getEnvironment() {
		return environment;
	}

	public void setEnvironment(Environment environment) {
		this.environment = environment;
	}

	public JFrame getFrame() {
		return frame;
	}

	public void setFrame(JFrame frame) {
		this.frame = frame;
	}

	/**
	 * Initialize the contents of the frame.
	 */
	private void initialize() {
		setFrame(new JFrame());
		getFrame().setBounds(100, 100, 1250, 530);
		getFrame().setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
		getFrame().getContentPane().setLayout(null);
		
		panel = new JPanel();
		panel.setBorder(new TitledBorder(UIManager.getBorder("TitledBorder.border"), "Simulated Environment", TitledBorder.LEADING, TitledBorder.TOP, null, new Color(0, 0, 0)));
		panel.setBounds(16, 11, 1011, 423);
		getFrame().getContentPane().add(panel);
		panel.setLayout(null);
		
//		canvas = new Canvas();
//		canvas.setBounds(6, 16, 999, 400);
//		canvas.setVisible(true);
//		panel.add(canvas);
		panel.setVisible(true);
		
		JButton btnTerminate = new JButton("Terminate");
		btnTerminate.addActionListener(new ActionListener() {
			public void actionPerformed(ActionEvent arg0) {
				System.exit(0);
			}
		});
		btnTerminate.setBounds(461, 457, 118, 23);
		getFrame().getContentPane().add(btnTerminate);
		
		JScrollPane scrollPane = new JScrollPane();
		scrollPane.setToolTipText("Objects");
		scrollPane.setVerticalScrollBarPolicy(ScrollPaneConstants.VERTICAL_SCROLLBAR_ALWAYS);
		scrollPane.setBounds(1033, 17, 191, 413);
		getFrame().getContentPane().add(scrollPane);
		
		
//		Canvas canvas_1 = new Canvas();
//		scrollPane.setViewportView(canvas_1);
		
//		new Runnable() {
//			public void run() {
//				try {
//					runGui();
//				} catch (Exception e) {
//					e.printStackTrace();
//				}
//			}
//		}.run();
		
		
	}
	
	   public void runGui(){
			Dimension screenSize = Toolkit.getDefaultToolkit().getScreenSize();
			int width = (int) screenSize.getWidth();
			int height = (int) screenSize.getHeight();
			
			canvas = new Canvas();
//			canvas.setBounds(6, 16, 999, 400);
//			canvas.setSize(1000, 400);
	        canvas.setIgnoreRepaint( true );
			canvas.setVisible(true);
			panel.add(canvas);
			canvas.setSize(1000, 400);

			//frame.pack();
	        // Create BackBuffer
	        canvas.createBufferStrategy( 2 );
	        BufferStrategy buffer = canvas.getBufferStrategy();

	        // Get graphics configuration
	        GraphicsEnvironment ge = GraphicsEnvironment.getLocalGraphicsEnvironment();
	        GraphicsDevice gd = ge.getDefaultScreenDevice();
	        GraphicsConfiguration gc = gd.getDefaultConfiguration();

	        // Create off-screen drawing surface
	        BufferedImage bi = gc.createCompatibleImage( width , height);

	        // Objects needed for rendering
	        Graphics graphics = null;
	        Graphics2D g2d = null;
	        
	        while( true ) {

	            try {

	                if( Environment.ticks != Environment.tickslimit ) {

	                    // clear back buffer...
	                    g2d = bi.createGraphics();
	                    Color c1 = new Color(235, 245, 255);
	                    g2d.setColor(SystemColor.control);
	                    g2d.fillRect( 0, 0, getFrame().getWidth() , getFrame().getHeight());
	                    g2d.setColor(Color.WHITE);
	                    g2d.fillRect( 0, 0, environment.getDimX() , environment.getDimY());
	                    Color st = new Color(0, 78, 152);
	                    g2d.setColor(st);
	                    g2d.drawLine(environment.getDimX(), 0, environment.getDimX(), environment.getDimY());


	                    // move and draw object
	                    environment.draw(g2d);
	                    environment.actionCore();
	                    
	                    
//	                    Font f = new Font("Calibri", Font.BOLD, 15);
//	                    g2d.setFont(f);
//	                    
//	                    g2d.setColor(st);
//	                    g2d.drawString("time:  " + environment.ticks*environment.getTickTime() + " min", environment.getDimX() + 25, 25);
//	                    
//	                    for (int i = 0; i < environment.bacteria_name.size(); i++) {
//							Color c = new Color(environment.bacteria_color.get(i)[0], environment.bacteria_color.get(i)[1], environment.bacteria_color.get(i)[2]);
//							g2d.setColor(c);
//							g2d.fillOval(environment.getDimX() + 25, 25*(i+2), 10, 10);
//							g2d.drawString(environment.bacteria_name.get(i), environment.getDimX() + 50, 8+25*(i+2));
//							g2d.drawString(environment.bacteria_count.get(i).toString(), environment.getDimX() + 200, 8+25*(i+2));
//						}
//	                    
//	                    int offset = (environment.bacteria_name.size()+2)*25+8;
//	                    
//	                    for (int i = 0; i < environment.metabolite_name.size(); i++) {
//							Color c = new Color(environment.metabolite_color.get(i)[0], environment.metabolite_color.get(i)[1], environment.metabolite_color.get(i)[2]);
//							g2d.setColor(c);
//							g2d.fillRect(environment.getDimX() + 29, offset + 25*(i+1), 2, 2);
//							g2d.drawString(environment.metabolite_name.get(i), environment.getDimX() + 50, offset + 3 + 25*(i+1));
//							g2d.drawString(environment.metabolite_count.get(i).toString(), environment.getDimX() + 200, offset + 3 + 25*(i+1));
//						}
	                    

	                    // Blit image and flip
	                    graphics = buffer.getDrawGraphics();
	                    graphics.drawImage( bi, 0, 0, null );
	                    if( !buffer.contentsLost() )
	                        buffer.show();
	                }

	                Thread.yield();

	            } finally {
	                // release resources
	                if( graphics != null )
	                    graphics.dispose();
	                if( g2d != null )
	                    g2d.dispose();
	            }

	        } //throw ()
	    }

}
