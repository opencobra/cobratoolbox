/*
 * rBioNet database connector.
 * Author: Stefan Gretar Thorleifsson  
 * Contact: stefangretar@gmail.com
 * 25.04.2012
 */
package rbionet;

import java.sql.*;
import java.util.Properties;
/**
 *
 * @author Stefan Thorleifsson
 */
public class Rbionet {

    /**
     * @param args the command line arguments
     */

    // The JDBC Connector Class.
    private static final String dbClassName = "com.mysql.jdbc.Driver";
    
    // Server information  (completed in innitiate function)
    private static  String SERVER;
    private static  String DATABASE;
    private static  String CONNECTION; 
    
    // Specify connection information (completed in innitiate function)
    public static String user;// = "root";
    private static String password;// = "";
    
    //Table names (completed in innitiate function)
    public static final String rxn_table = "Reactions";
    public static final String met_table = "Metabolites";
    public static final String matrix = "Smatrix";
    public static final String recon_table = "recon";
    public static final String reconstruction_table = "Reconstructions";
    
    
    // Setup tables (completed in innitiate function) 
    private static String create_rxn_table;
    private static String create_met_table;
    private static String create_matrix_table;
    private static String create_recon_table; // Reactions & Reconstruction connections
    private static String create_reconstructions_table; // Reconstructions information
    
    // Matrix columns
    public static final String matrix_columns =
            " ( rxn_id, "
            + "met_id, "
            + "value, "
            + "comp ) ";          
    
    
    // Metabolite columns
    public static final String met_columns = 
            " ( Abbreviation, " 
            + "Description, "
            + "NeutralFormula, "
            + "ChargedFormula, "
            + "Charge, "
            + "KeggID, "
            + "PubChemID, "
            + "CheBlID, "
            + "InchiString, "            
            + "Smile, "
            + "HMDB, "
            + "LastModified, "
            + "AddedBy "
            + " ) ";
    
    // Reaction columns
    public static final String rxn_columns = 
            " ( Abbreviation, " 
            + "Description, "
            + "Formula, "
            + "Reversible, "
            + "MCS, "
            + "Notes, "
            + "Ref, "
            + "ECNumber, "
            + "KeggID, "            
            + "LastModified, "
            + "AddedBy"
            + ") ";
    
    // recon_table_columns
    public static final String recon_table_columns = 
            " (rxn_id, "
            + "model_id, "
            + "LB, "
            + "UB, "
            + "CS, "    
            + "GPR, "   
            + "Subsystem, "
            + "Ref, "
            + "Notes, "
            + "LastModified, "
            + "AddedBy "    
            + ") ";
    
    // recon_table_columns
    public static final String recon_table_columns_upd = 
             " LB = ?, "
            + "UB = ?, "
            + "CS = ?, "    
            + "GPR = ?, "   
            + "Subsystem = ?, "
            + "Ref = ?, "
            + "Notes = ?, "
            + "LastModified = NOW(), "
            + "AddedBy = ? ";

    // reconstruction_table columns
    public static final String reconstruction_model_columns = 
            " ( "
            + "Name, "
            + "Organism, " 
            + "Author, "  
            + "Notes, "
            + "GeneIndexInfo "
            + ") ";
    // Update query uses other syntax. 
    public static final String reconstruction_model_columns_upd = 
            " Name = ?, "
            + "Organism = ?, " 
            + "Author = ?, "  
            + "Notes = ?, "
            + "GeneIndexInfo = ? " ;
            
    
    
    //private static String[][] query_failure = {{rbionet_false,""},{"",""}};
    public static String[][] query_success = {{"true","Ok"},{"",""}};
    public static String[][] last_result; 
    public static String last_error; //logs last error of c_query
    
    // Metabolites insert status
    public static String mets_inserted;
    public static String mets_not_inserted;
    public static String missing_mets;
    public static String mets_already_exists;
    
    // Reaction insert status 
    public static String rxns_inserted; //true
    public static String rxns_already_exists; // false but okey
    public static String rxns_not_inserted; //false
    public static String rxn_insert_error; // String, specifies if smatrix or reaction insert failed.
    
    //Connection that is kept open for a period of time
    private static Connection rbionet_connection;
    
    // Stores last inserted id from prepared statements. 
    private static int lastInsertedID;
    
    // Reconstruction object
    public static Reconstruction recon = new Reconstruction();
    
    
    
    public static void main(String[] args) throws
            ClassNotFoundException, SQLException {
//            
//        Innitiate("localhost","rbionet","","");
//        recon.setModelId(1);
//            
//            if (saveReconRxn("10FTHF5GLUtl", "1", "2",
//            "5", "gpr", "subsystem", "ref", "notes")) {
//                System.out.println("jajaja");
//            }
//            else {
//                System.out.println(last_error);
//                System.out.println("neineienei");
//            }
            
    }
    // Create database connection,neccessary strings and test connection. 
    // INPUT - server, database, user and password
    // OUTPUT - ??
    public static void Innitiate(String server,String database,String usr, String pwd) throws ClassNotFoundException, SQLException {
        SERVER = "jdbc:mysql://" + server;
        DATABASE = database;
        CONNECTION =  SERVER + "/" + DATABASE;   
        user = usr;
        password = pwd;
        
        create_rxn_table = 
            "CREATE TABLE " + DATABASE + "." + rxn_table + " ("
            + "rxn_id INT PRIMARY KEY AUTO_INCREMENT, "
            + "Abbreviation VARCHAR( 300 ) CHARACTER SET latin1 COLLATE latin1_general_cs NOT NULL UNIQUE, "
            + "Description TEXT, "
            + "Formula TEXT, "
            + "Reversible int NOT NULL, "
            + "MCS INT, "
            + "Notes TEXT, "
            + "Ref TEXT, "
            + "ECNumber VARCHAR(100), "
            + "KeggID VARCHAR (100), "
            + "LastModified DATETIME, "
            + "AddedBy VARCHAR(20)"
            + ");";
    
        create_met_table = 
            "CREATE TABLE " + DATABASE + "." + met_table + " ("
            + "met_id INT PRIMARY KEY AUTO_INCREMENT, "
            + "Abbreviation VARCHAR( 300 ) CHARACTER SET latin1 COLLATE latin1_general_cs NOT NULL UNIQUE, "
            + "Description text, "
            + "NeutralFormula VARCHAR(300), "
            + "ChargedFormula VARCHAR(300) NOT NULL, "
            + "Charge INT NOT NULL, "
            + "KeggID VARCHAR (100), "
            + "PubChemID VARCHAR (100), "
            + "CheBlID VARCHAR (100), "
            + "InchiString TEXT, "            
            + "Smile TEXT, "
            + "HMDB VARCHAR(100), "
            + "LastModified DATETIME, "
            + "AddedBy VARCHAR(20)"
            + ");";
    
    
    
        create_matrix_table = 
            "CREATE TABLE " + DATABASE + "." + matrix + " ("
            + "id INT PRIMARY KEY AUTO_INCREMENT, "
            + "rxn_id INT, "
            + "met_id INT, "
            + "value INT, "
            + "comp CHAR(3), "
            + "FOREIGN KEY (rxn_id) REFERENCES Reactions (rxn_id), "
            + "FOREIGN KEY (met_id) REFERENCES Metabolites (met_id)"
            + ");";
        
        
        create_recon_table = 
            "CREATE TABLE " + DATABASE + "." + recon_table + " ("
            + "rxn_id INT NOT NULL, "
            + "model_id INT NOT NULL, "
            + "LB INT, "
            + "UB INT, "
            + "CS INT, "    
            + "GPR TEXT, "   
            + "Subsystem TEXT, "
            + "Ref TEXT, "
            + "Notes TEXT, "
            + "LastModified DATETIME, "
            + "AddedBy VARCHAR(20), "
            + "PRIMARY KEY (rxn_id, model_id), "
            + "FOREIGN KEY (rxn_id) REFERENCES Reactions (rxn_id), "
            + "FOREIGN KEY (model_id) REFERENCES Reconstructions (model_id)"
            + ");";
        
        
        create_reconstructions_table = 
            "CREATE TABLE " + DATABASE + "." + reconstruction_table + " ("
            + "model_id INT PRIMARY KEY AUTO_INCREMENT, "
            + "Name VARCHAR(100) NOT NULL UNIQUE, "
            + "Organism VARCHAR(300), " 
            + "Author VARCHAR(100), "  
            + "Notes TEXT, "
            + "GeneIndexInfo TEXT "
            + ");";
    }
 
    
    // Check if connection is valid
    // OUTPUT - true if rbionet is able to connect to server
    public static boolean isConnected() throws ClassNotFoundException, SQLException {
                // Test connection
        try {
            getConnection(false);
            return true;
        }
        catch(SQLException e){
            last_error = e.getLocalizedMessage();
            return false;     
        }
        finally {
            closeConnection();
        }
    }
    
    // Check if database exists (and connection is valid)
    // OUTPUT - true if database exists else false
    public static boolean dbExists() throws ClassNotFoundException, SQLException {
                // Test connection
        try {
            getConnection();
            return true;
        }
        catch(SQLException e){
            last_error = e.getLocalizedMessage();
            return false;     
        }
        finally {
            closeConnection();
        }
    }
    private static void getConnection() throws ClassNotFoundException, SQLException{
        getConnection(true);
    }
    private static void getConnection(boolean db) throws ClassNotFoundException, SQLException {
        //Use: c = getConnection(db)
        //Before: db is boolean true to connect with database, otherwise false
        //After: rbionet_connection is open    
        Class.forName(dbClassName);
        Properties p = new Properties();
        p.put("user", user);
        p.put("password", password);
        if(db){
            rbionet_connection = DriverManager.getConnection(CONNECTION,p);
        }
        else {
            rbionet_connection =  DriverManager.getConnection(SERVER,p);
        }
    }
    private static void closeConnection() throws ClassNotFoundException, SQLException {
       if(rbionet_connection != null) {
            rbionet_connection.close();
        }
        rbionet_connection  = null;   
    }
    public static boolean RemoveDB() throws ClassNotFoundException, SQLException {
        // Drop rbionet mysql project
        try {
            getConnection(false);
            boolean drop = c_query("DROP DATABASE " + DATABASE);
            return drop;
        }
        catch(SQLException e){
            last_error = e.getLocalizedMessage();
            return false;     
        }
        finally {
            closeConnection();
        }
    }
    public static boolean SetupDB() throws ClassNotFoundException, SQLException {
        // Create rbionet database and adds the required tables
        String[][] result = new String[1][1];
        try {
            getConnection(false);
            boolean database = c_query("CREATE DATABASE " + DATABASE + ";");
         
            if(database){
                result[0][0] = "Database: " + DATABASE + " succesfully created\n";
            }
            
            String[][] tables = {
                {rxn_table, create_rxn_table},
                {met_table, create_met_table},
                {matrix, create_matrix_table},
                {reconstruction_table, create_reconstructions_table},
                {recon_table, create_recon_table}
            };
            
            for (int i = 0 ;  i < tables.length ; i++ ){
                boolean table_created = c_query(tables[i][1]);
                if (table_created) {
                    result[0][0] += "Table: " + tables[i][0] + " successfully created\n";
                }
            }
            
            last_result = result;
            return true;
            
        }
        catch(SQLException e){
            last_error = e.getLocalizedMessage();
            return false;     
        }
        finally {
            closeConnection();
        }

    }
    public static boolean c_query(String query) throws SQLException {
    // Executes  any requested sql query from an open connection
    // NOTE: c_query and query are the same except c_query requires
    //       rbionet_connection to be open.
        return c_query(query,false);
    }
    public static boolean c_query(String query, boolean column_names) throws SQLException {
        
        Statement s = null;
        try {
            s = rbionet_connection.createStatement();
            s.execute(query);// Get ResultSet
            ResultSet r = s.getResultSet();
            return handle_results(r, column_names);
        } 
        catch (SQLException e) {
            //failure[0][0] = rbionet_false;
            last_error = e.getLocalizedMessage();
            System.out.println(last_error); // Use this for debugging and perhaps a good practice
            return false;
        }
        finally {
            if(s != null) {
                s.close(); 
            }
        }
        
    }
    public static boolean query(String query) throws ClassNotFoundException, SQLException{
        // Executes any query
        // Returns boolean
        // Results are in last_result: First row contains column name
        // NOTE: c_query and query are the same except c_query requires rbionet_connection to be open.
        
        try {
            //Get connection and execute query
            getConnection();
            return c_query(query);
        } 
        catch (SQLException e) {
            last_error = e.getLocalizedMessage();
            return false;   
        }
        finally {
            closeConnection();
        }
    }
    public static boolean prepared(String sql,String[] values) throws ClassNotFoundException, SQLException {
        // Use prepared query without having an open connection. 
        try {
            getConnection();
            return c_prepared( sql, values);
        }
        catch(SQLException e) {
            last_error = e.getLocalizedMessage();
            return false;
        }
        finally {
            closeConnection();
        }
    }
    public static boolean c_prepared(String sql,String[] values) throws SQLException {
        return c_prepared(sql,values,false);
    }
    public static boolean c_prepared(String sql,String[] values, boolean column_names) throws SQLException {
        // Create prepared statement and execute
        // INPUT: SQL string (statement), String[] inputs
        // Resultset is always last inserted ID. 
        // NOTE: when using prepared statement set method it should be specified
        // what type of value is being set int, string etc. I only use String here. 
        // Checking for ints and other types needs to be done elsewhere. 
        // I did this because some values have been containing escape characters ('). 
        // 03.10.2012 Stefan Thorleifsson (this is crap).
                
        PreparedStatement s = null;
        try {
            s = rbionet_connection.prepareStatement(sql);
            for(int i=0; i < values.length; i++) {
                s.setString(i+1,values[i]);
            }
            s.executeUpdate();// Get ResultSet
            ResultSet r = s.getGeneratedKeys(); // Last inserted id. 
            if (r.next()) {
                lastInsertedID = r.getInt(1);
            }
            return handle_results(r, column_names);
        } 
        catch (SQLException e) {
            last_error = "prepared: " +e.getLocalizedMessage();
            return false;
        }
        finally {
            if(s != null) {
                s.close(); 
            }
        }
        
    }
    public static boolean handle_results(ResultSet r, boolean column_names ) throws SQLException {
        //ResultSet is null if command is update/drop/insert and etc with no errors
            
        if(r == null){
                last_result = query_success;
                return true;
            }
        
        // Get number of columns -> through MetaData    
        ResultSetMetaData rsmd = r.getMetaData();   //information on resultset
        int columns = rsmd.getColumnCount();            //number of columns
            
            
        r.last();               //Move curser to end
        int rows = r.getRow();  //Get number of the row
        r.beforeFirst();        //Move cursor back to the front.
            
        // Size Results depends on if we have column names or not
        int i;
        if(column_names)
            i = 1;
        else
            i = 0; 

        // Create result array for select queries, +1 for column names
        String[][] Results = new String[rows+i][columns];
        if(column_names) {
            //Get column names
            for(int k=1; i <= columns; i++){
                Results[0][k-1] = rsmd.getColumnName(k);
            }
        }

        //Fill in results
        while(r.next()){
            for(int k=1; k <= columns; k++) {
                Results[i][k-1] = r.getString(k);
            }
            i++;
        }

        last_result = Results;
        return true;
    }

    public static boolean Search(String table, String input, String field, Boolean select) throws
            ClassNotFoundException, SQLException {
        // Search database
        // INPUT: 
        //  table - name of table to search
        //  input - search for this string
        //  field - in this field. 
        // OUTPUT:
        //  true/false
        // Note: TODO input and field are arrays but only the first values are used.
        // This will be fixed when prepare statement is introduced. 
        /*
        * public static boolean Search(String table, String input, String field, boolean select)
        */
        String conditions = "";
            if (table.equals("met"))
                table = met_table;
            else if (table.equals("rxn"))
                table = rxn_table;
                
            if (input.length() != 0) {    
                if (select) {
                    conditions = " Where " + field + " = '" + input + "'";
                }
                else { 
                     conditions = " WHERE " + field + " LIKE '%" + input + "%'";
                }
            }
           
            
            return query("SELECT * FROM " + table + conditions + " ORDER BY Abbreviation");
    }
    public static boolean insert_rxns(Reaction[] rxns) throws
            ClassNotFoundException, SQLException {
        // Use: x = Rbionet.insert_rxns(Array)
        // Input: Array - String[][] with reaction information
        // Output: x - boolean, true if all reactions where inserted 
        try {
            getConnection(true);
            boolean res = true;
            //Clear out relavant status variables
            rxns_inserted = "";
            rxns_already_exists = "";
            rxns_not_inserted = "";
            missing_mets = "";
            
            // Metabolites are checked all at once
            // Reaction.met_ids properties are added in the process
            
            
            //Always Check_Metabolites before Check_Reaction
            
            //Reactions checked and added one at a time
            for(int i = 0; i< rxns.length; i++){
                if(!Check_Reaction_Metabolites(rxns[i])) {
                    res = false;
                    rxns_not_inserted += "Reaction "+ rxns[i].Abbreviation + " not inserted."
                               +" Formula : "+rxns[i].Formula+". Check Metabolites failed. \n"; 
                    continue;
                }
                    
                if(rxns[i] == null)
                    continue;
                if(Check_Reaction(rxns[i])) {
                    //insert reaction
                    if(insert_rxn(rxns[i]))
                        rxns_inserted += "Reaction "+ rxns[i].Abbreviation + " inserted successfully.\n";
                    else {
                        res = false;
                        rxns_not_inserted += "Reaction "+ rxns[i].Abbreviation + " not inserted."
                               +" Formula : "+rxns[i].Formula+". " + rxn_insert_error + ".\n"; 
                    }
                       
                }
                else {
                    res = false;
                }
            }
            return res;
        }
        catch (SQLException e){
            last_error = e.getLocalizedMessage();
            return false;    
        }
        finally {
            closeConnection();
        }
        
    }
    private static boolean insert_rxn(Reaction rxn) 
        throws ClassNotFoundException, SQLException { 
        //  USE: foo = insert_rxn(rxn)
        //  Inserts reaction object into databse, that is Reactions and Smatrix
        //  INPUT: rxn - a reaction object
        //  OUTPUT: true if query was executed without errors
        //  Note:   Reaction must first run through Check_Metabolites and Check_Reactions
        //          Use insert_rxns and it will be done automatically. Connection needs to
        //          be open. 
        //Reaction is added to Reactions table,
        //Get Reactions id and use it to add to Smatrix
        if (!c_prepared(rxn.preparedSQL(),rxn.preparedValues())) {
            rxn_insert_error = "Reaction insert failed";
            return false;
        }
        else { // reaction added.
            rxn.setID(lastInsertedID); // last InsertedID
            c_query(rxn.insert_sparsity()); // Insert into sparisty matrix
            return true;   
        }
    }
    public static boolean remove_rxn_id(String rxn_id)
        throws ClassNotFoundException, SQLException{
        // USE: bool = remove_rxn(rxn_id)
        // INPUT: Reaction id 
        // OUTPUT: boolean true if reaction was removed successfully, else false.  
        //TODO: We don't know if reaction was deleted or not. 
        String rxn = "DELETE FROM " + rxn_table + " WHERE rxn_id=" + rxn_id;
        String rxn_matrix = "DELETE FROM " + matrix + " WHERE rxn_id=" + rxn_id;
        if(rbionet_connection != null) {
           return (c_query(rxn) && c_query(rxn_matrix));
        }
        else {
           return (query(rxn) && query(rxn_matrix));
        }
        
        
    }
    public static boolean remove_rxn(String abbreviation) 
        throws ClassNotFoundException, SQLException{
        // USE: bool = remove_rxn(rxn_abbreviation)
        // INPUT: Reaction Abbreviation 
        // OUTPUT: boolean true if reaction was removed successfully, else false. 
        //Find reaction id,
        //Remove reaction from Reactions and Smatrix
        try {
            getConnection(true);
            if(c_query("SELECT rxn_id FROM " + rxn_table + " WHERE Abbreviation='" +abbreviation+"'"))
                if(last_result.length != 0)
                    return remove_rxn_id(last_result[0][0]);
                else {
                    last_error = "Reaction abbreviation " + abbreviation + "is not in database";
                    return false;
                }
            else
                return true;   
        }
        catch (SQLException e){
            last_error = e.getLocalizedMessage();
            return false;    
        }
        finally {
            closeConnection();
        }
    }
    private static boolean Check_Metabolites_c(String[] mets)
            throws ClassNotFoundException, SQLException{
        // USE:     bool = Check_Metabolites_c(mets)
        // INPUT:   list of metabolites in String[] array
        // OUTPUT:  true if all mets are in database, else false.
        //          requires an open connection. 
        boolean res = true;
        for(int i=0; i<mets.length;i++){
            c_query("SELECT met_id FROM " + met_table + " WHERE Abbreviation="
                    + "'" + mets[i] + "'");
            if(last_result.length == 0) {
               missing_mets += "Metabolite " +mets[i] + " is not in database.\n";
               res = false;
            }
        }
        return res;
    }
    public static boolean Check_Metabolites(String[] mets)
        throws ClassNotFoundException, SQLException{
        // USE:     bool = Check_Metabolites(mets)
        // INPUT:   list of metabolites in String[] array
        // OUTPUT:  true if all mets are in database, else false.
        //          missing metabolites can bee seen in missing_mets. 
        try{
            //Clear status variables.
            missing_mets = "";
            getConnection();
            return Check_Metabolites_c(mets);
        }
        catch (SQLException e){
            last_error = e.getLocalizedMessage();
            return false;    
        }
        finally {
            closeConnection();
        }
    }
    private static boolean Check_Reaction_Metabolites(Reaction rxns) 
        throws ClassNotFoundException, SQLException {
       //Use: foo = Check_Reaction_Metabolites(Reaction[] rxns)
        //Before: 
        //      Reaction[]  - Array of Reaction objects
        //      Needs an open connections
        //After: 
        //      foo - boolean true if reactions have no missing metabolites, else false
        try {
            boolean res = true;
            //Sql syntax to check for 
            if(rxns == null)
                return false;
            String[] sql_mets = rxns.sql_met_ids();
            for(int k=0; k<sql_mets.length;k++){
                c_query(sql_mets[k]);
                if(last_result.length == 0) {//Id was not found
                    missing_mets += "Metabolite " +rxns.get_mets()[k][0] + " is not in database"
                            + " (Reaction: " + rxns.Abbreviation +").\n";
                    last_error = missing_mets;
                    res = false;
                }
                else {
                    //Add Metabolite ids to reactions
                    rxns.met_ids[k] = last_result[0][0];
                }
            }
            return res;
        }
        catch (SQLException e){
            last_error = e.getLocalizedMessage();
            return false;    
        }
    } 

    public static boolean metSimilarities(Metabolite met)
            throws ClassNotFoundException, SQLException {
        // USE: r.metSimilarities(met)
        // INPUT: Metabolite object
        // OUTPUT: true/false if query is successfull. 
        // data is fetched from r.last_result
        return query(met.Similarities());
    }
    private static boolean Check_Reaction(Reaction rxn) 
        throws ClassNotFoundException, SQLException {
        // Use: foo = Check_Reaction(Connection c, Reaction rxns)
        // Checks if reaction formula and abbrevation exists in database
        //
        // INPUT: Reaction object
        //
        // OUTPUT: true if reaction can be inserted into database, else false
        //
        // NOTE: function writes a new line to the reaction status variables
        //       They need to be cleared out before every new session.
        //       Example: as in insert_rxns.
        //       Always Check_Metabolites before Check_Reaction
        try {
            boolean res;
            //Check Abbreviation
            String abb_check = "SELECT rxn_id FROM " + rxn_table + " WHERE Abbreviation='" + rxn.Abbreviation +"'";
            // Primary key is never zero. 
            int abb_rxn_id = 0;
            int form_rxn_id = 0;
            int form_rxn_reversible;
            String form_abbreviation = "";
            res = c_query(abb_check);
            if(res){//query executed successfully
                
                if(last_result.length != 0) {// Is empty if Reaction Abbreviation doesn't exist.
                    abb_rxn_id = Integer.parseInt(last_result[0][0]);
                    res = false;
                }
                //Check Reaction formula
                res = c_query(rxn.search_rxn());
                if(res) {//query executed successfully
                    if(last_result.length != 0) {
                        form_rxn_id = Integer.parseInt(last_result[0][0]);
                        form_abbreviation = last_result[0][1];
                        form_rxn_reversible = Integer.parseInt(last_result[0][2]);
                        // Reaction formula can be the same if Reversibility is different.
                        if(Integer.parseInt(rxn.Reversible) == form_rxn_reversible)
                            res = false;
                    }
                }
            }
            
            
            // Reaction will not be added
            if(!res) {
                if(abb_rxn_id == form_rxn_id) //Reaction already exists in database
                    rxns_already_exists += "Reaction: " + rxn.Abbreviation + " already in database.\n";
                else{// If abbreviation and formula were found but are not the same both messages are posted.
                    if(abb_rxn_id != 0) 
                        rxns_not_inserted += "Abbreviation: " + rxn.Abbreviation + " is already used in databse.\n"; 
                    if(form_rxn_id != 0){
                        rxns_not_inserted += "Reaction: "+ rxn.Abbreviation + " exists under the abbreviation "
                                + form_abbreviation +".\n";
                    }
                }
                        
            } 
            return res;
        }
        catch (SQLException e){
            last_error = e.getLocalizedMessage();
            return false;    
        }

    }

    public static boolean insert_mets(Metabolite[] mets) throws 
            ClassNotFoundException, SQLException {
        // Use: x = Rbionet.insert_mets(Array)
        // Input: Array - String[][] with metabolite information
        // Output: String[][] - shows query output
        /*  Array
            0. Abbreviation
            1. Description 
            2. NeutralFormula 
            3. ChargedFormula
            4. Charge 
            5. KeggID
            6. PubChemID
            7. CheBlID
            8. InchiString
            9. Smile
            10. HMDB
            LasteModified is added automatically.
        */
        
        boolean res = true; //result
        
        try {
            // Clear out status variables. 
            mets_not_inserted = "";
            mets_inserted = "";
            mets_already_exists = "";
            getConnection();
            for(int i=0; i<mets.length; i++){
                if(c_query(mets[i].exists())){
                    if("2".equals(last_result[0][0]))
                        mets_already_exists += "Metabolite "+mets[i].Abbreviation+" exists in database.\n";
                    else if("1".equals(last_result[0][0])) {
                        mets_not_inserted += "Metabolite abbreviation "+mets[i].Abbreviation
                                +" is already used in database. Charge Formula and Charge do not match.\n";
                        res = false;
                    }
                    else {//We try insert
                        if(!c_query(mets[i].insert())) {
                            mets_not_inserted += "Metabolite: " + mets[i].Abbreviation
                                + " was not inserted into database.\n";
                            res = false;
                        }
                        else
                            mets_inserted += "Metabolite: "+mets[i].Abbreviation
                                + " was inserted into database successfully.\n";    
                    }
                }   
            }
            return res;
        }
        catch (SQLException e){
            last_error = e.getLocalizedMessage();
            return false;    
        }
        finally {
            closeConnection();
        }
    }
    
    public static Metabolite new_met(String[] met) {
        return new Metabolite(met);
    }
    
    public static Reaction new_rxn(String[] rxn, String[][] mets) {
        return new Reaction(rxn,mets);
    }
    

    
    /* --------------------------------------------------------------
     Reconsructions 
     * --------------------------------------------------------------
     */
    
    
    public static boolean newRecon(String[] info) throws 
            ClassNotFoundException, SQLException {
       // Create mew Recon object. 
       Reconstruction res = new Reconstruction();
       res.addInfo(info);
       try {
            getConnection();
            if (c_prepared(res.saveModelSQL(),res.saveModelValues())) {
                res.setModelId(lastInsertedID);
                recon = res; 
                return true;
            }
            else {
                return false; 
            }
                
       }
       catch(Exception e) {
           last_error = e.getLocalizedMessage();
           return false;
       }
       finally {
           closeConnection();
       }
       
       
           
     
    }
    public static boolean saveReconRxn(String abbr, String lb, String ub,
            String cs, String gpr, String subsystem, String ref, String notes) throws
            ClassNotFoundException, SQLException {
        try {
            
            if (recon.Model_id.equals("")) {
                last_error = "No model specified to save reactions.";
                return false;
            }
            
            if (prepared(recon.saveRxnSQL(),
                    recon.saveRxnValues(abbr, lb, ub, cs, gpr, subsystem, ref, notes))) {
                return true;
            }
            else {
                return false;
            }
               
        }
        catch(SQLException e) {
           last_error = "saveReconrxn " + e.getLocalizedMessage();
           return false;
       }
       finally {
           closeConnection();
       }
    }
   
        
    // print 2 dimensional arrays
    public static void print_r2(String[][] a){
        
        for(int i=0; i<a.length; i++){
            for(int k=0; k< a[0].length; k++){
                System.out.print(a[i][k] + " ");
            }
            System.out.println();
        }
    }
    // print a vector
    public static void print_r(String[] a){
        for(int i=0;i<a.length;i++){
            System.out.print(a[i] + " ");
        }
        System.out.println();
    }
   
}
