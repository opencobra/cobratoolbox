/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package rbionet;

/**
 *
 * @author Stefan Thorleifsson
 */
public class Metabolite {
    
    // Metabolite properties
    public final String Abbreviation;
    private final String Description;
    private final String NeutralFormula;
    private final String ChargedFormula;
    private final String Charge;
    private final String KeggID;
    private final String PubChemID;
    private final String CheBlID;
    private final String InchiString;
    private final String Smile;
    private final String HMDB;
    
    
            
                

    public Metabolite(String[] met){
        for(int i = 0; i < met.length; i++){
            if(met[i] == null)
                continue;
            
            met[i] = met[i].replaceAll( "\'", "" );
        }
        Abbreviation    = met[0];
        Description     = met[1];
        NeutralFormula  = met[2];
        ChargedFormula  = met[3];
        Charge          = met[4];
        KeggID          = met[5];
        PubChemID       = met[6];
        CheBlID         = met[7];
        InchiString     = met[8];
        Smile           = met[9];
        HMDB            = met[10];
    }
    
    public String sql_values(){
        return "('" + Abbreviation + "', "
                + "'" + Description + "', "
                + "'" + NeutralFormula + "', "
                + "'" + ChargedFormula + "', "
                + "'" + Charge + "', "
                + "'" + KeggID + "', "
                + "'" + PubChemID + "', "
                + "'" + CheBlID + "', "
                + "'" + InchiString + "', "
                + "'" + Smile + "', "
                + "'" + HMDB + "', "
                + "NOW(), "
                + "'" + Rbionet.user + "' )\n ";
    }
    //Use: m.sql_insert()
    //Output: Returns sql insert statement 
    //Note: to get the full query use m.sql_insert() + m.sql_values();
    public String sql_insert(){
        return  "INSERT INTO " + Rbionet.met_table 
                + Rbionet.met_columns 
                + "VALUES \n";
    }
    //Use: m.insert()
    //Output: Returns sql insert statement with values 
    
    public String insert(){
        return  sql_insert() + sql_values();
    }
    
    // USE m.exists()
    // OUTPUT:  returns sql statement that lets you know if Metabolite
    //          exists or not. 
    //          0. Abbreviation does not exist
    //          1. Abbreviation exists but charge formula and charge are not the same
    //          2. Abbreviation, charge formula and charge match. 
    public String exists(){
         return "SELECT count(*) from "
                 +" (Select Abbreviation, ChargedFormula from "+Rbionet.met_table 
                 +" WHERE Abbreviation = '"+Abbreviation+"' "
                 +" UNION "
                 +" SELECT Abbreviation, Charge From "+Rbionet.met_table 
                 +" WHERE Abbreviation = '"+Abbreviation+"' AND Charge="+Charge+" AND ChargedFormula='"+ChargedFormula+"')"
                 +" as t1";
         
    }
    
    //USE: m.Similarities()
    // INPUT: none
    // OUTPUT: sql statement that return a list of metabolites that has the same charge formula and charge
    public String Similarities() {
        return "SELECT * FROM " + Rbionet.met_table 
                +" WHERE ChargedFormula='" + ChargedFormula + "'"
                + " AND Charge='"+ Charge +"'";
    }
    
           
}
