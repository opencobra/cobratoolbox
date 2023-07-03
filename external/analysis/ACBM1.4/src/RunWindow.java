//
//public class Window3 {
//
//	public Window3() {
//		// TODO Auto-generated constructor stub
//	}
//
//}

/**
 * main program class, which run simulation
 */

import java.awt.*;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.awt.image.BufferStrategy;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import javax.swing.*;
import java.awt.image.BufferedImage;
import org.apache.commons.cli.*;

import java.util.logging.Level;
import java.util.logging.Logger;


public class RunWindow {
	
	Thread t;
    
	public RunWindow() {
		// TODO Auto-generated constructor stub
	}


    /**
     * @wbp.parser.entryPoint
     */
    public void execute() {
        // create simple Environment object
        Environment e1 = new Environment();
    	e1.initialize();
		try {
			e1.addEntity();
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
        // run GUI or Console
        runGui(e1);

    }

    //visual version
    private void runGui(Environment environment){
        // Create jframe
		Dimension screenSize = Toolkit.getDefaultToolkit().getScreenSize();
		int width = (int) screenSize.getWidth();
		int height = (int) screenSize.getHeight();
		
        JFrame app = new JFrame("Environment");
        app.setBounds(width/2 - (environment.getDimX() + 250)/2, 100, environment.getDimX() + 280 , environment.getDimY()+150);
        app.setIgnoreRepaint( true );
        app.setDefaultCloseOperation( WindowConstants.EXIT_ON_CLOSE );
        app.setForeground(SystemColor.control);
		app.setIconImage(Toolkit.getDefaultToolkit().getImage(InputWindow.class.getResource("/icon/acbm.png")));
		app.setResizable(false);
		app.setTitle("ACBM");


		
        // Create canvas for painting...
        Canvas canvas = new Canvas();
        canvas.setIgnoreRepaint( true );
        canvas.setBounds(0, 0, app.getWidth(), environment.getDimY());        
        
		JButton stopButton = new JButton("STOP");
		stopButton.addActionListener(new ActionListener() {
			public void actionPerformed(ActionEvent arg0) {
//				app.dispose();
//				t.stop();
//				try {
//					this.finalize();
//				} catch (Throwable e1) {
//					// TODO Auto-generated catch block
//					e1.printStackTrace();
//				}
//				EventQueue.invokeLater(new Runnable() {
//					public void run() {
//						try {
//							InputWindow window = new InputWindow();
//							window.frmAcbm.setVisible(true);
//						} catch (Exception e) {
//							e.printStackTrace();
//						}
//					}
//				});
				System.exit(0);
			}
		});
		stopButton.setBounds(app.getWidth()-180, app.getHeight()-190, 100, 23);
		stopButton.setVisible(true);
		app.getContentPane().add(stopButton);

        // Add canvas to jframe
        app.getContentPane().add( canvas );
        app.pack();
        app.setVisible( true );

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
        
        // Variables for counting time

        t = new Thread(new Runnable() {
        	Graphics graphics = null;
            Graphics2D g2d = null;
	
			@Override
			public void run() {
				// TODO Auto-generated method stub
				while( true ) {

		            try {

		            //    if( Environment.ticks != Environment.tickslimit ) {
		            		
		                    // clear back buffer...
		                    g2d = bi.createGraphics();
		                    Color c1 = new Color(235, 245, 255);
		                    g2d.setColor(SystemColor.control);
		                    g2d.fillRect( 0, 0, app.getWidth() , app.getHeight());
		                    g2d.setColor(Color.WHITE);
		                    g2d.fillRect( 0, 0, environment.getDimX() , environment.getDimY());
		                    Color st = new Color(0, 78, 152);
		                    g2d.setColor(st);
		                    g2d.drawLine(environment.getDimX(), 0, environment.getDimX(), environment.getDimY());


		                    // move and draw object
		                    environment.draw(g2d);
		                    environment.actionCore();
		                    
		                    
		                    Font f = new Font("Calibri", Font.BOLD, 15);
		                    g2d.setFont(f);
		                    
		                    g2d.setColor(st);
		                    g2d.drawString("time:  " + environment.ticks*environment.getTickTime() + " min", environment.getDimX() + 25, 25);
		                    
		                    for (int i = 0; i < environment.bacteria_name.size(); i++) {
								Color c = new Color(environment.bacteria_color.get(i).getRed(), environment.bacteria_color.get(i).getGreen(), environment.bacteria_color.get(i).getBlue());
								g2d.setColor(c);
								if (environment.l_bac.get(i) == 0) {
									g2d.fillOval(environment.getDimX() + 25, 25*(i+2), 10, 10);
								} else {
							        g2d.fillRoundRect(environment.getDimX() + 25, 25*(i+2), 12, 6, 80, 100);
								}
								g2d.drawString(environment.bacteria_name.get(i), environment.getDimX() + 50, 8+25*(i+2));
								g2d.drawString(environment.bacteria_conc.get(i).toString() + " (g/L)", environment.getDimX() + 200, 8+25*(i+2));
							}
		                    
		                    int offset = (environment.bacteria_name.size()+2)*25+8;
		                    
		                    for (int i = 0; i < environment.metabolite_name.size(); i++) {
								Color c = new Color(environment.metabolite_color.get(i).getRed(), environment.metabolite_color.get(i).getGreen(), environment.metabolite_color.get(i).getBlue());
								g2d.setColor(c);
								g2d.fillRect(environment.getDimX() + 29, offset + 25*(i+1), 2, 2);
								g2d.drawString(environment.metabolite_name.get(i), environment.getDimX() + 50, offset + 3 + 25*(i+1));
								g2d.drawString(environment.metabolite_conc.get(i).toString() + " (g/L)", environment.getDimX() + 200, offset + 3 + 25*(i+1));
							}

		                    // Blit image and flip
		                    graphics = buffer.getDrawGraphics();
		                    graphics.drawImage( bi, 0, 0, null );
		                    if( !buffer.contentsLost() )
		                        buffer.show();
		            //    }
		                    

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
		});
        t.start();
            }


}
