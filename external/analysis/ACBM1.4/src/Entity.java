/*
* this class describes same functions to all other subclasses
* */

import java.awt.*;
import java.io.IOException;
import java.util.Random;
import java.util.List;


public abstract class Entity {


    //Constructor
    public Entity (int x, int y,int z) {
        this.x = x; this.y = y; this.z = z;
        this.StepX = x;
        this.StepY = y;
        this.StepZ = z;

}
    //coordinate[mkm]
    private int x, y, z;
    //direction vectors [mkm]
    protected double dx, dy, dz;
    //helpful coordinate [mkm]]
    private double StepX, StepY, StepZ;
    //speed [mkm/hour]
    private int Speed;
    //size : SizeX = SizeY = SizeZ
    private int SizeX;
    //mass
    protected double mass;


	//color variable; visual version
    int color_r, color_g, color_b;
    // live`s label
    private boolean live = true;
    //create panel for painting for visual version

    //voids to get/set value of variable
    protected void setX (int x){
        this.x = x ;
    }
    protected int getX (){
        return this.x;
    }
    protected void setY (int y){
        this.y = y ;
    }
    protected int getY(){
        return this.y ;
    }

    protected void setZ (int z){
        this.z = z ;
    }
    protected int getZ() {
		return this.z;
	}

    protected void setDx (double dx){
        this.dx = dx ;
    }
    protected double getDx(){
        return this.dx ;
    }

    protected void setDy (double dy){
        this.dy = dy ;
    }
    protected double getDy(){
        return this.dy ;
    }
    
    protected void setDz (double dz){
        this.dz = dz ;
    }
    protected double getDz(){
        return this.dz ;
    }
    
    public double getMass() {
		return mass;
	}
	public void setMass(double mass) {
		this.mass = mass;
	}

    protected void setColor (int r, int g, int b){
        this.color_r = r;
        this.color_g = g;
        this.color_b = b;
    }

    protected int getColor_r (){ return  this.color_r;}
    protected int getColor_g () {return  this.color_g; }
    protected int getColor_b () { return this.color_b; }

    protected void setLive (boolean live){
        this.live = live;
    }
    protected boolean getLive(){
        return this.live;
    }

    protected void setSpeed(double s){
        this.Speed = (int) s;
    }
    protected double getSpeed(){
        return  Speed;
    }

    public int getSizeX(){
        return  SizeX;
    }
    public void setSizeX(int s) {
        this.SizeX = s;
    }

    protected void setStepX(double x){
        this.StepX = x;
    }
    protected double getStepX(){
        return StepX;
    }

    protected double getStepY(){
        return StepY;
    }
    protected void setStepY(double y){
        this.StepY = y;
    }
    
    protected double getStepZ(){
        return StepZ;
    }
    protected void setStepZ(double z){
        this.StepZ = z;
    }

    //action for each program step
    public abstract void tick(List<Entity> PS, List<Entity> ANT, List<Entity> B, Environment g)
            throws IOException ;
    //draw object; visual version
    public abstract void draw(Graphics g);// {  }

    public void SetProperty (int x, int y, int z){
        setStepX(x);
        setStepY(y);
        setStepZ(z);
    }

    public void SetNewCoordinate(){
        setX((int)Math.round(getStepX()));
        setY((int)Math.round(getStepY()));
        setZ((int)Math.round(getStepZ()));
        
    }


    //fluctuation moving (random)
    public void RandomMove(){
    	int phi = new Random().nextInt(360);
    	int teta = new Random().nextInt(360);
        setDz(Math.sin(phi));
        setDy(Math.cos(phi) * Math.sin(teta));
        setDx(Math.cos(phi) * Math.cos(teta));

        setStepX(getStepX() - getSpeed()/Environment.getNorm() * getDx());
        setStepY(getStepY() - getSpeed()/Environment.getNorm() * getDy());
        setStepZ(getStepZ() - getSpeed()/Environment.getNorm() * getDz());
    }
    
    //for closed system, boundary of reactor    
    public void wall() {
    	
    	while (this.getStepX() < 0 || this.getStepX() > Environment.getL() || this.getStepY() < 0 || this.getStepY() > Environment.getW() || this.getStepZ() < 0 || this.getStepZ() > Environment.getD()) {
    		if (this.getStepX() < 0)
    			setStepX(-this.getStepX());
    		if (this.getStepX() > Environment.getL())
    			setStepX(Environment.getL() - (this.getStepX() - Environment.getL()));
    		if (this.getStepY() < 0)
    			setStepY(-this.getStepY());
    		if (this.getStepY() > Environment.getW())
    			setStepY(Environment.getW() - (this.getStepY() - Environment.getW()));
    		if (this.getStepZ() < 0)
    			setStepZ(-this.getStepZ());
    		if (this.getStepZ() > Environment.getD())
    			setStepZ(Environment.getD() - (this.getStepZ() - Environment.getD()));
    	}

    		
	}
    


}

