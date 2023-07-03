

import java.awt.*;
import java.io.File;
import java.io.IOException;
import java.io.PrintWriter;
import java.text.DecimalFormat;
import java.util.*;
import java.util.List;

import matlabcontrol.MatlabConnectionException;
import matlabcontrol.MatlabInvocationException;


public class Environment {

    //Constructor
    public Environment() {
        super();
    	mesh = new int[L][D][W];
    }
    
    //environment mesh
    private int[][][] mesh;

    //create lists of objects
    private List<Entity> bacterias = new ArrayList<Entity>();
    private List<Entity> PS = new ArrayList<Entity>();
    private List<Entity> ANT = new ArrayList<Entity>();
    private List<Number> ProdAmount = new ArrayList<Number>();

    //bacteria and metabolite properties:    
    static ArrayList<String> bacteria_name = new ArrayList<String>();
    static ArrayList<Integer> bacteria_count = new ArrayList<Integer>();
    static ArrayList<Integer> bacteria_died = new ArrayList<Integer>();
    static ArrayList<Double> bacteria_conc = new ArrayList<Double>();
//    static ArrayList<Integer> doubling_time = new ArrayList<Integer>();
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
    static ArrayList<Integer> metabolite_index = new ArrayList<Integer>();
    static ArrayList<Double> metabolite_mw = new ArrayList<Double>();    
    static ArrayList<Integer> metabolite_speed = new ArrayList<Integer>();
    static ArrayList<Double> metabolite_uub = new ArrayList<Double>();    
    static ArrayList<ArrayList<String>> ex_rxns_name = new ArrayList<ArrayList<String>>();
    static ArrayList<ArrayList<Integer>> ex_rxns_direction = new ArrayList<ArrayList<Integer>>();
    static ArrayList<ArrayList<Integer>> substrate = new ArrayList<ArrayList<Integer>>();
    static ArrayList<Double> eat_radius = new ArrayList<Double>();
    static ArrayList<Color> bacteria_color = new ArrayList<Color>();
    static ArrayList<Color> metabolite_color = new ArrayList<Color>();
    static ArrayList<Integer[]> feeding_points = new ArrayList<Integer[]>();
    static boolean stirredFeed;


    //Variable for counting time
    static int ticks;
    //Variable for stop program at this time
    static int tickslimit;
    static int death;
    static int notEat = 0;
    static ArrayList<Integer> notEat1 = new ArrayList<Integer>();

    
    
    //dimension
    //length of the artificial reactor [px]
    private static int dimX = 1000;
    //length of the artificial reactor [mkm]
    private static int L ;
    //width of the artificial reactor [px]
    private static int dimY = 400;
    //width of the artificial reactor [mkm]
    private static int W;
    //depth of artificial reactor [mkm]
    private static int D;
    //volume of the reactor [l]
    private static double V = L*D*W*Math.pow(10, -15);
    //number of mkm in 1 px [mkm/px]
    private static double tickX;
    private static double tickY;
    //number of minuets in 1 program's tick [min]
    private static int TickTime;
    //number of tick in 1 hour [ticks]
    private static double norm;

    //Variable for eating
    //period of eating [hours]
//    static int TickEat = (int) (1*norm);
    //time of last eating
    static int ticksEatTime = 1;
    //period of antibiotic getting
    static int AntibioticPeriod;
    static int ticksAntTime;
    //amount of days in which get antibiotic
    static int AntibioticsDay;
    //helpful counter: count antibiotics days
    static int t;

    public int[][][] getMesh() {
		return mesh;
	}

	public void setMesh(int[][][] mesh) {
		this.mesh = mesh;
	}

	public static int getTickTime() {
		return TickTime;
	}

	public static void setTickTime(int tickTime) {
		TickTime = tickTime;
	}

	//Voids for get/set value of variable
    public static double getNorm(){
        return norm;
    }

    public static double getV(){
        return V;
    }

    public static double getTickX(){
        return tickX;
    }

    public static double getTickY(){
        return tickY;
    }

    public static int getDimX(){
        return dimX;
    }

    public static int getDimY(){
        return dimY;
    }

    public static int getW(){
        return W;
    }

    public static int getD() {
		return D;
	}

	public static int getL(){
        return L;
    }

    //Variable for reading value of variable from external file
    static Properties props = new Properties() ;

    //Variable for writing output in a file
    File logFile;
    PrintWriter writeFile = null;
    
    public void initialize () {    
    	ticks = -1;
        for (int i = 0; i < metabolite_count.size(); i++) {
			metabolite_index.add(0);
		}

        //create new output file
        logFile =  new File("output.txt");
    }
    
    public static void setParameters () {
    	Environment.bacteria_name = InputWindow.bacteria_name;
    	Environment.bacteria_count = InputWindow.bacteria_count;
    	Environment.bacteria_conc = InputWindow.bacteria_conc;
    	Environment.bacteria_scale = InputWindow.bacteria_scale;
//    	Environment.doubling_time = RunWindow.doubling_time;
    	Environment.r_bac = InputWindow.r_bac;
    	Environment.l_bac = InputWindow.l_bac;
    	Environment.v_bac = InputWindow.v_bac;
    	Environment.m_bac = InputWindow.m_bac;
    	Environment.eat_radius = InputWindow.eat_radius;
    	Environment.mFile = InputWindow.mFile;
    	Environment.bacteria_speed = InputWindow.bacteria_speed;
    	Environment.t_survive = InputWindow.t_survive;
    	Environment.r_search = InputWindow.r_search;
    	Environment.metabolite_name = InputWindow.metabolite_name;
    	Environment.metabolite_count = InputWindow.metabolite_count;
    	Environment.metabolite_conc = InputWindow.metabolite_conc;
    	Environment.metabolite_mw = InputWindow.metabolite_mw;
    	Environment.metabolite_speed = InputWindow.metabolite_speed;
    	Environment.metabolite_uub = InputWindow.metabolite_uub;
    	Environment.ex_rxns_name = InputWindow.ex_rxns_name;
    	Environment.ex_rxns_direction = InputWindow.ex_rxns_direction;
    	Environment.tickslimit = InputWindow.tickslimit;
    	Environment.TickTime = InputWindow.tickTime;
    	Environment.L = InputWindow.L;
    	Environment.D = InputWindow.D;
    	Environment.W = InputWindow.W;
    	Environment.bacteria_color = InputWindow.bacteria_color;
    	Environment.metabolite_color = InputWindow.metabolite_color;
    	Environment.feeding_points = InputWindow.feeding_points;
    	Environment.stirredFeed = InputWindow.stirredFeed;
    	Bacteria.n_real = InputWindow.n_real;
    	
    	for (int i = 0; i < bacteria_name.size(); i++) {
			bacteria_died.add(0);
		}

    	norm = 60/TickTime;
    	tickX = (double) L / dimX;
    	tickY = (double) W / dimY;

    	V = W*D*L*Math.pow(10, -15);
    	
    	for (int i = 0; i < bacteria_name.size(); i++) {
			try {
				Environment.substrate.add(Bacteria.substrateFinder(ex_rxns_name.get(i), ex_rxns_direction.get(i), mFile.get(i)));
			} catch (MatlabConnectionException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			} catch (MatlabInvocationException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}
    	
    }

    //add objects to the environment
    public void addEntity()  throws IOException {
    	
    	//add bacteria
    	for (int i = 0; i < bacteria_count.size(); i++) {
			for (int j = 0; j < bacteria_count.get(i); j++) {
				Bacteria b = new Bacteria(new Random().nextInt(L), new Random().nextInt(W), new Random().nextInt(D), i);
				b.setTimeEat(0);
				bacterias.add(b);
			}
//			for (int j = 0; j < bacteria_count.get(i)/2; j++) {
//				Bacteria b = new Bacteria(new Random().nextInt(L), new Random().nextInt(W), new Random().nextInt(D), i);
//				b.setTimeEat(+ new Random().nextInt(b.getT_d()));
//				bacterias.add(b);
//			}
		}


        //add metabolites
    	if (stirredFeed) {
        	for (int i = 0; i < metabolite_count.size(); i++) {
    			for (int j = 0; j < metabolite_count.get(i); j++) {
    				PolySaccharides p = new PolySaccharides(new Random().nextInt(L), new Random().nextInt(W), new Random().nextInt(D), i);
    				p.setSpeed(metabolite_speed.get(i));
    				PS.add(p);
    			}
    		}
		} else {
	    	for (int k = 0; k < feeding_points.size(); k++) {
	    		for (int i = 0; i < metabolite_count.size(); i++) {
	    			for (int j = 0; j < metabolite_count.get(i)/feeding_points.size(); j++) {
	    				PolySaccharides p = new PolySaccharides((int) (feeding_points.get(k)[0] + new Random().nextGaussian()*10), (int) (feeding_points.get(k)[1] + new Random().nextGaussian()*10), (int) (feeding_points.get(k)[1] + new Random().nextGaussian()*10), i);
	    				p.setSpeed(metabolite_speed.get(i));
	    				PS.add(p);
	    				
	    			}
	    		}
	    	}
		}


    }
    
    public void sumupMass() {
    	
	    ArrayList<Double> bacteria_mass = new ArrayList<Double>();
	    for (int i = 0; i < bacteria_name.size(); i++) {
			bacteria_mass.add(0.0);
		}
		for (int i = 0; i < bacterias.size(); i++) {
			Bacteria b = (Bacteria) bacterias.get(i);
			bacteria_mass.set(b.getType(), bacteria_mass.get(b.getType()) + b.mass);
		}
		for (int i = 0; i < bacteria_mass.size(); i++) {
			int count = (int) (bacteria_mass.get(i) / m_bac.get(i));
			if (count > bacteria_count.get(i)) {
		    	double m_dummy = bacteria_mass.get(i) / count;
		    	for (int j = 0; j < bacterias.size(); j++) {
		    		Bacteria b = (Bacteria) bacterias.get(j);
		    		if (b.getType() == i) {
						bacterias.get(j).setMass(m_dummy);
					}
				}
		    	for (int j = 0; j < count-bacteria_count.get(i); j++) {
		    		Bacteria b = new Bacteria(new Random().nextInt(L), new Random().nextInt(W), new Random().nextInt(D), i );
		    		b.setMass(m_dummy);
		    		b.setTimeEat(Environment.ticks + 1);
		    	    bacterias.add(b);
		    	    Environment.bacteria_count.set(i, Environment.bacteria_count.get(i) +1 );
		    	}
			}
		}
	}
    
	public void nToC() {
//		for (int i = 0; i < bacteria_count.size(); i++) {
//			double c = (bacteria_count.get(i) * m_bac.get(i)) / V  ;
//			c = Double.parseDouble(new DecimalFormat("####.##").format(c));
//			bacteria_conc.set(i, c);
//		}
		
	    ArrayList<Double> bacteria_mass = new ArrayList<Double>();
	    for (int i = 0; i < bacteria_count.size(); i++) {
			bacteria_mass.add(0.0);
		}
		for (int i = 0; i < bacterias.size(); i++) {
			Bacteria b = (Bacteria) bacterias.get(i);
			bacteria_mass.set(b.getType(), bacteria_mass.get(b.getType()) + b.mass);
		}
		for (int i = 0; i < bacteria_mass.size(); i++) {
			double c = bacteria_mass.get(i)/V;
			c = Double.parseDouble(new DecimalFormat("####.##").format(c));
			bacteria_conc.set(i, c);
		}
		
	    ArrayList<Double> metabolite_mass = new ArrayList<Double>();
	    for (int i = 0; i < metabolite_count.size(); i++) {
			metabolite_mass.add(0.0);
		}
		for (int i = 0; i < PS.size(); i++) {
			PolySaccharides p = (PolySaccharides) PS.get(i);
			metabolite_mass.set(p.getType(), metabolite_mass.get(p.getType()) + p.mass);
		}
		for (int i = 0; i < metabolite_mass.size(); i++) {
			double c = (metabolite_mass.get(i)/Bacteria.n_a) * metabolite_mw.get(i) / V;
			c = Double.parseDouble(new DecimalFormat("####.##").format(c));
			metabolite_conc.set(i, c);
		}

	}



    //write output data in a file
    public void createFile(List<Number> l, PrintWriter writeFile){
        String st = "";
        for (Number n: l) { st += n + " "; }
        writeFile.println(st.trim());
        writeFile.flush();
    }


    //draw objects and environment
    public void draw(Graphics g){
//        //environment
//    	g.setColor(Color.WHITE);
//        g.drawRect(0,0,dimX,dimY);

        //bacteria and metabolites
        List<Entity> newList = new ArrayList<Entity>() { { addAll(bacterias);
            addAll(PS); addAll(ANT);} };
        for(Entity ent : newList) {
            ent.draw(g);
        }

    }
    
    public void fillMesh(ArrayList<Coordinates> element) {
		for (int i = 0; i < element.size(); i++) {
			Coordinates c = element.get(i);
			if (c.getX() >= 0 && c.getX() < L && c.getY() >= 0 && c.getY() < W && c.getZ() >= 0 && c.getZ() < D) {
				mesh[c.getX()][c.getY()][c.getZ()] = 1;
			}
		}
	}
    
    public void freeUpMesh(ArrayList<Coordinates> element) {
		for (int i = 0; i < element.size(); i++) {
			Coordinates c = element.get(i);
			if (c.getX() >= 0 && c.getX() < L && c.getY() >= 0 && c.getY() < W && c.getZ() >= 0 && c.getZ() < D) {
				mesh[c.getX()][c.getY()][c.getZ()] = 0;
			}
		}
	}


    //action for each component in a list
    public void Action(List<Entity> Ent) {
       for (int i = Ent.size()-1; i >= 0; i--){
           Entity entity = Ent.get(i);
            try{
               entity.tick(PS, ANT,bacterias,this);
            }catch(IOException e){
                e.printStackTrace();
            }
            if (! entity.getLive()){
                Ent.remove(i);
            }
        }

    }

    public void actionCore(){
        //create LogFile and 1 string
        if (ticks == -1){
            try {
                writeFile = new PrintWriter(logFile);
                String st = "Time";
                for (int i = 0; i < bacteria_name.size(); i++) {
					st += (" " + bacteria_name.get(i) + "_Count" + " " + bacteria_name.get(i) + "_Conc");
				}
                for (int i = 0; i < metabolite_name.size(); i++) {
					st += (" " + metabolite_name.get(i) + "_Count" + " " + metabolite_name.get(i) + "_Conc");
				}
                for (int i = 0; i < bacteria_name.size(); i++) {
					st += (" " + bacteria_name.get(i) + "_Died");
				}
                st += " bacteria_couldn't_eat";
                writeFile.println(st);
            } catch (IOException i) {
                i.printStackTrace();
            }
        }

        //change current time
        ticks += 1;
        System.out.println("time_tick " + ticks);
        nToC();

        //create a list with output data
        ProdAmount = new ArrayList<Number> ();
        ProdAmount.add(ticks*TickTime);
        for (int i = 0; i < bacteria_count.size(); i++) {
            ProdAmount.add(bacteria_count.get(i));
            ProdAmount.add(bacteria_conc.get(i));

		}
        for (int i = 0; i < metabolite_count.size(); i++) {
            ProdAmount.add(metabolite_count.get(i));
            ProdAmount.add(metabolite_conc.get(i));

		}
        for (int i = 0; i < bacteria_died.size(); i++) {
			ProdAmount.add(bacteria_died.get(i));
		}
        ProdAmount.add(notEat);
//        ProdAmount.add(ANT.size());


        //write these output data in a file
        createFile(ProdAmount, writeFile);

      notEat = 0;

        //action for each objects list
        Action(bacterias);
        Action(PS);
        Action(ANT);

        //set least eating time
//        if (ticks % eatPeriod1 == 0){
//            ticksEatTime = ticks;
//        }

        if (ticks == tickslimit || bacterias.isEmpty()){
            System.exit(0);
            writeFile.close();
        }
    }

    
  
}
