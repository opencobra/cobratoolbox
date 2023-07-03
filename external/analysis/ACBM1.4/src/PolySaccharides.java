import java.awt.*;
import java.io.IOException;
import java.util.Random;


public class PolySaccharides extends Entity {
	
	private String name;
	private int type;

    // /Speed variable
    //OY - to environment boundary
    double Speed_flux;
    //OX - out from environment
    double Speed_out;
    //mass parameter

	//Constructor
    public PolySaccharides (int x, int y, int z, int type) {
        super(x, y, z);
        this.type = type;
        this.name = Environment.metabolite_name.get(type);
        setProperty();
    }
    
    public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}

	public int getType() {
		return type;
	}

	public void setType(int type) {
		this.type = type;
	}

	public void setProperty() {
        setSizeX(2);
        setColor(Environment.metabolite_color.get(type).getRed(), Environment.metabolite_color.get(type).getGreen(), Environment.metabolite_color.get(type).getBlue());
        setMass(new Random().nextGaussian()*(Bacteria.n_real/7)+(Bacteria.n_real));
//        setMass(Bacteria.n_real);

	}

    //chose direction of oy speed
    public void MoveFlux (double Speed_out,double Speed_trans){

//        setStepX(getStepX() + Speed_out);
        if (getStepY() > Environment.getW()/2){
            setStepY(getStepY() + Speed_trans);
        }
        else {
            setStepY(getStepY() - Speed_trans);
        }
    }

    //draw PS in the environment
    public void draw(Graphics g){

        GradientPaint gp = new GradientPaint((int)(getX()/Environment.getTickX()), (int) (getZ()/Environment.getTickY()), new Color(getColor_r(),getColor_g(),getColor_b(), 180),
                (int)(getX()/Environment.getTickX()), (int) (getY()/Environment.getTickY()) + getSizeX(), new Color(getColor_r() ,getColor_g(), getColor_b(), 180));
        Graphics2D g2d = (Graphics2D) g;
        g2d.setPaint(gp);
//        int x = (int) (getX() / Environment.getTickX());
//        int y = (int) (getY() / Environment.getTickY());
//        System.out.println("X "+getX() + " tickx"+ Environment.getTickX());
//        System.out.println("x: "+x+", y: "+y);
        g2d.fillRect((int) (getX()/Environment.getTickX()), (int) (getY()/Environment.getTickY()), getSizeX(), getSizeX());
    }


    //action for each program tick
    public void tick(java.util.List<Entity> PS, java.util.List<Entity> A,
                     java.util.List<Entity> B, Environment g)
            throws IOException {
    	RandomMove();
    	wall();
        SetNewCoordinate();
        
    }


}

