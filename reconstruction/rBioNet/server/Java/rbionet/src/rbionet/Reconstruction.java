/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package rbionet;

/**
 *
 * @author Stefan Thorleifsson
 * 
 */
public class Reconstruction {
    // Reconstruction Properties
    public String Model_id = "";
    public String Name;
    public String Organism;
    public String Author;
    public String Notes;
    public String GeneIndexInfo;
//    public String GeneIndexFile;
//    public String GeneIndexData;
//    public String GeneIndexSource;
    
    
    // Workflow
    /*     
     * New model:
     * - addModel (add info)
     * - save model using saveModelValues() and saveModelSQL()
     * - add new model id with setModelId()
     * 
     * 
     * Use existing model
     * - search for model
     * - set model id (rest of the information is not used for modifying rxns)
     * 
     * Changing model description
     * - model id must be set
     * - add model info
     * - save update using saveModelValues() and updModelSQL()
     * 
     */
    
    public Reconstruction () {
        
    }
    
    
    // Get model from server
    // OUTPUT - return sql string for prepared statement
    // Use c_prepared(Reconstruction.getModelSQL,String[] one dimension)
    public String getModelSQL() {
        // verd ad nota like i thessa skipun+
        return "SELECT * FROM " +Rbionet.reconstruction_table + " WHERE Name like %?% ";
    }
    

    // Ready preparedStatement for insert
    // OUTPUT:  String prepared statement query
    
    public String saveModelSQL() {
        return "INSERT INTO " + Rbionet.reconstruction_table + " "
                + Rbionet.reconstruction_model_columns
                + " VALUES (?, ?, ?, ?, ?) ";
    }
    
    public String updModelSQL() {
        return "UPDATE " + Rbionet.reconstruction_table + " "
                + " SET " + Rbionet.reconstruction_model_columns_upd
                + " WHERE model_id = " + Model_id + " ";
    }
    
    // PreparedStatement values
    // OUTPUT:  String[] - array of inserts 
    public String[] saveModelValues() {
        String[] r = {Name, Organism, Author, Notes, GeneIndexInfo};
        return r;
    }
    
    // Add model information. 
    // 
    public void addInfo(String[] info) {
        Name = info[0];
        Organism = info[1];
        Author = info[2];
        Notes = info[3];
        GeneIndexInfo = info[4];
    }
    
    // When model has recieved id it should be added to the object before adding reactions. 
    public void setModelId(int id) {
        Model_id = Integer.toString(id);
    }
    
    
    // ----------------------------------------------------
    // Working with reactions -----------------------------
    // ----------------------------------------------------
    
    // Adding reaction
    public String saveRxnSQL() {
        // AAbbreviation is used to insert reaction to recon table, reaction id is found in query. 
        return " INSERT INTO " + Rbionet.recon_table + " "
                + Rbionet.recon_table_columns 
                + " VALUES ((SELECT rxn_id FROM "+ Rbionet.rxn_table +" WHERE Abbreviation = ?),?,?,?,?,?,?,?,?,NOW(),?) ";
    }
    public String[] saveRxnValues( String abbr,
            String lb, String ub, String cs, String gpr,
            String subsystem, String ref, String notes ) {
        String [] r = {abbr, Model_id, lb, ub, cs, gpr, subsystem, ref, notes, Rbionet.user};
        return r;
    }
    
    
    // Editing reaction
    
    public String updRxnSQL() {
        return " UPDATE " + Rbionet.recon_table + " "
                + " SET " + Rbionet.recon_table_columns_upd
                + " WHERE rxn_id = ? AND model_id = ? ";
    }
    // Difference between
    public String[] updRxnValues( String rxn,
            String lb, String ub, String cs, String gpr,
            String subsystem, String ref, String notes ) {
        String [] r = { lb, ub, cs, gpr, subsystem, ref, notes, Rbionet.user, rxn, Model_id};
        return r;
    }
    // Removing reaction
    
    public String rmRxnSQL() {
        return " DELETE FROM " + Rbionet.recon_table 
                + " WHERE rxn_id = ? AND model_id = ? ";
    }
    public String[] rmRxnValues(String rxn) {
        String[] r = {rxn, Model_id};
        return r;
    }
    
}


