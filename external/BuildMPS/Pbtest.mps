NAME          Pbtest                                         
ROWS                                                         
 N  COST                                                     
 E  Equality                                                 
 L  LE1                                                      
 L  LE2                                                      
COLUMNS                                                      
    x         COST      1              LE1       1           
    x         LE2       -1                                   
    y         COST      4              Equality  -1          
    y         LE1       1                                    
    z         COST      9              Equality  1           
    z         LE2       -1                                   
RHS                                                          
    RHS       Equality  7              LE1       5           
    RHS       LE2       -10                                  
BOUNDS                                                       
 UI BND1      x         4                                    
 LO BND1      y         -1                                   
 UP BND1      y         1                                    
ENDATA                                                       
