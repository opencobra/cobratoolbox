/**
 * main program class, which run simulation
 */

import java.awt.*;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.awt.event.WindowAdapter;
import java.awt.event.WindowEvent;
import java.awt.image.BufferStrategy;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import javax.swing.*;
import java.awt.image.BufferedImage;
import org.apache.commons.cli.*;

import com.sun.java.swing.plaf.windows.resources.windows;

import java.util.logging.Level;
import java.util.logging.Logger;


public class Main {

    private static final Logger log = Logger.getLogger(Main.class.getName());
    static String logFile_name = "output.ouput";
    static String setFile_name = "input.ini";
    public static JFrame runFrame;


    public static void main(String[] args) {
    	
    	new Runnable() {
    		public void run() {
   				try {
   					InputWindow window = new InputWindow();
//   					window.getFrame().setVisible(true);
   				} catch (Exception e) {
    				e.printStackTrace();
    			}
    		}
    	}.run();
    }

}