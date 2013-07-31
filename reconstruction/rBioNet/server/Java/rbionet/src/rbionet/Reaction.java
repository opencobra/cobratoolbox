/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package rbionet;

/**
 *
 * @author Stefan Thorleifsson
 */
public class Reaction {
    // Reaction properties
    public final String Abbreviation;
    public final String Description;
    public final String Formula;
    public final String Reversible;
    public final String MCS;
    public final String Notes;
    public final String References;
    public final String ECNumber;
    public final String KeggID;
    public final String[][] Metabolites;
    public String[] met_ids;
    public String rxn_id;
    
    public Reaction(String[] rxn, String[][] mets) {
        /*
         * 1. Abbreviation
         * 2. Description
         * 3. Formula
         * 4. Reversible
         * 5. MSC
         * 6. Notes
         * 7. References
         * 8. EC Number
         * 9. KeggiD
         */
        Abbreviation = rxn[0];
        Description = rxn[1];
        Formula = rxn[2];
        Reversible = rxn[3];
        MCS = rxn[4];
        Notes = rxn[5];
        References = rxn[6];
        ECNumber = rxn[7];
        KeggID = rxn[8];
        
        
        //  Columns
        //  1. Abbreviation
        //  2. Values
        //  3. Compartment
        Metabolites = mets;
        met_ids = new String[mets.length];
    }
    public String sql_values(){
        return "('" + Abbreviation + "', "
                + "'" + Description + "', "
                + "'" + Formula + "', "
                + "'" + Reversible + "', "
                + "'" + MCS + "', "
                + "'" + Notes + "', "
                + "'" + References + "', "
                + "'" + ECNumber + "', "
                + "'" + KeggID + "', "
                + "NOW(), "
                + "'" + Rbionet.user + "' )\n ";
    }
    
    //Use: r.sql_insert()
    //Output: Returns sql insert statement 
    //Note: to get the full query use m.sql_insert() + m.sql_values();
    public String sql_insert(){
        return  "INSERT INTO " + Rbionet.rxn_table 
                +  Rbionet.rxn_columns 
                + "VALUES \n";
    }
    //Use: r.insert()
    //Output: Returns sql insert statement with values for Reactions table
    public String insert(){
        return  sql_insert() + sql_values();
    }
    
    
    // Set reaction id. 
    public void setID(int id) {
        rxn_id = Integer.toString(id); 
    }
    
    // USE: str = r.insert_sparsity()
    // OUTPUT:  str - str containing sql query to insert Reaction into sparsity
    //          table (Smatrix).
    public String insert_sparsity() {
        String str = "INSERT INTO " + Rbionet.matrix + " "
                + Rbionet.matrix_columns 
                + "Values ";
        for(int i=0; i<met_ids.length; i++) {
            str += "("+rxn_id+", "+met_ids[i]+","+Metabolites[i][1]+",'"+Metabolites[i][2]+"')";
            if(i != met_ids.length-1) 
                str+=",\n ";
        }
        
        return str;
    }
    
    // USE:      r.search_rxn()
    // INPUT:   
    // OUTPUT:  string with sql queru that selects "this" reaction in smatrix
    //          If this query returns empty if reaction does not exist in database. 
    public String search_rxn() {
        //Search for some cool shit..
        String str = "SELECT t1.rxn_id, t3.Abbreviation, t3.Reversible FROM ";
        str += "(SELECT rxn_id, count(rxn_id) as mets FROM " + Rbionet.matrix + " WHERE ";
        //For each metabolite
        for(int i=0; i < met_ids.length ; i++) {
            if( i != 0) {
                str += " OR ";
            }
            
            str += "(met_id=" + met_ids[i] +" AND " 
                    + "value=" +Metabolites[i][1] + " AND "
                    + "comp='" + Metabolites[i][2] + "'"
                    +") " ;    
        }
        
        str += " GROUP BY rxn_id HAVING mets="+ met_ids.length +") as t1 "
                + ", "
                + "(SELECT rxn_id, count(rxn_id) as mets FROM "+ Rbionet.matrix +" "
                + "GROUP BY rxn_id) as t2, "
                + Rbionet.rxn_table + " as t3 "
                + "WHERE t1.rxn_id = t2.rxn_id AND t1.mets=t2.mets AND "
                + "t1.rxn_id=t3.rxn_id ";
        
        return str;
    }

    //Use: mets = r.get_mets()
    //Output: mets String[][] 
    //  1. Abbreviation
    //  2. Values
    //  3. Compartment
    public String[][] get_mets() {
       return Metabolites;
    }
    
   
    public String[] sql_met_ids() {
        String[] str = new String[Metabolites.length];
        for(int i=0; i<Metabolites.length; i++){
                str[i] = "SELECT met_id FROM " + Rbionet.met_table 
                    + " WHERE Abbreviation ='" + Metabolites[i][0] + "'";
        }
        return str;
    }
    
    public String preparedSQL() {
        return "INSERT INTO " + Rbionet.rxn_table 
                +  Rbionet.rxn_columns 
                + "VALUES \n"
                + "("
                + " ?," 
                + " ?," 
                + " ?,"
                + " ?,"
                + " ?,"
                + " ?,"
                + " ?,"
                + " ?,"
                + " ?,"
                + " NOW(),"
                + " ?"
                + ")\n ";
    }
    
    public String[] preparedValues() {
        String[] r = {
                Abbreviation,
                Description,
                Formula,
                Reversible,
                MCS,
                Notes,
                References,
                ECNumber,
                KeggID,
                Rbionet.user
        };
        return r;
    }
}
