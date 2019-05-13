function plotcbmap()
import java.awt.*;
import java.awt.event.*;
import javax.swing.*;
import processing.core.*;
import MatlabPlot.*;
% create window in which applet will execute
applicationWindow = JFrame( 'Metabolic Network Plot' );
width = 1285;
height = 965;
% create one applet instance
global appletObject
appletObject = MatlabPlot;

% call applet's init and start methods
appletObject.init;
appletObject.start;

% attach applet to center of window
applicationWindow.getContentPane.add( appletObject );

% set the window's size
applicationWindow.setSize( width, height );

% showing the window causes all GUI components
% attached to the window to be painted
applicationWindow.show;
%setData(appletObject, 400+randn(1000,1)*130, 300+randn(1000,1)*90, rand(1000,1)*220, ones(1000,1)*80);