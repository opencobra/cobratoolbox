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


public class Window3 {

    private static final Logger log = Logger.getLogger(Main.class.getName());
    private static Options options = new Options();
    //private String[] args = null;
    static boolean PLOT_GRAPHICS = true;
    static int  LABEL_FEEDBACK = 1;
    static String logFile_name = "output.output";
    static String setFile_name = "input.ini";
    
	public Window3() {
		// TODO Auto-generated constructor stub
	}


    public static void execute() {
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
        if (PLOT_GRAPHICS) {
            runGui(e1);
        } else {
            runConsole(e1);
        }

    }


    public static void help() {
        //this prints out some help
        HelpFormatter formatter = new HelpFormatter();
        formatter.printHelp( "ACBM framework", options);
        System.exit(0);
    }

    public static void parseCMD(String[] args){
        CommandLineParser parser = new DefaultParser();

        try{
            CommandLine line = parser.parse( options, args);

            if (line.hasOption("h")){
                help();
            }


            if (line.hasOption("o")) {
                //File logFile = new File(line.getOptionValue("logfile"));
                logFile_name = line.getOptionValue("o");
            } else {
                log.log(Level.SEVERE, "Missing output file");
                help();
            }

            if (line.hasOption("v")){
                PLOT_GRAPHICS = true;
            }
            if (line.hasOption("i")) {
                setFile_name = line.getOptionValue("i");
                try{
                    Environment.props.load(new FileInputStream(setFile_name));}
                catch (IOException e) {
                    e.printStackTrace();
                }
            }else{
                log.log(Level.SEVERE, "Missing input file");
                help();
            }


        } catch( ParseException exp){
            System.err.println("Parsing failed. Reason: " + exp.getMessage());
            help();

        }
    }

    //visual version
    private static void runGui(Environment environment){
        // Create jframe
		Dimension screenSize = Toolkit.getDefaultToolkit().getScreenSize();
		int width = (int) screenSize.getWidth();
		int height = (int) screenSize.getHeight();
		
        JFrame app = new JFrame("Environment");
        app.setBounds(width/2 - (environment.getDimX() + 250)/2, 100, environment.getDimX() + 280 , environment.getDimY()+150);
        app.setIgnoreRepaint( true );
        app.setDefaultCloseOperation( WindowConstants.EXIT_ON_CLOSE );
        app.setForeground(SystemColor.control);
		app.setIconImage(Toolkit.getDefaultToolkit().getImage(RunWindow.class.getResource("/icon/acbm.png")));
		app.setResizable(false);
		app.setTitle("ACBM");


		
        // Create canvas for painting...
        Canvas canvas = new Canvas();
        canvas.setIgnoreRepaint( true );
        canvas.setBounds(0, 0, app.getWidth(), environment.getDimY());        
        
		JButton stopButton = new JButton("STOP");
		stopButton.addActionListener(new ActionListener() {
			public void actionPerformed(ActionEvent arg0) {
				System.exit(0);
			}
		});
		stopButton.setBounds(app.getWidth()-150, app.getHeight()-70, 100, 23);
		stopButton.setVisible(true);
		app.add(stopButton);

        // Add canvas to jframe
        app.add( canvas );
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

        Thread t = new Thread(new Runnable() {
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


    //console version
    private static void runConsole(Environment environment) {

        while( true ) {
        	environment.actionCore();
            Thread.yield();
       }
    }


}
