NAME          Pbtest                                         
ROWS                                                         
 N  COST                                                     
 E  Equality                                                 
 L  LE1                                                      
 L  LE2                                                      
 L  QLE1                                                     
 L  COST                                                     
COLUMNS                                                      
    x         COST      1              LE1       1           
    x         LE2       -1                                   
    y         COST      4              Equality  -1          
    y         LE1       1                                    
    z         COST      9              Equality  1           
    z         LE2       -1             QLE1      -3          
RHS                                                          
    RHS       Equality  7              LE1       5           
    RHS       LE2       -10            QLE1      100         
BOUNDS                                                       
 UI BND1      x         4                                    
 LO BND1      y         -1                                   
 UP BND1      y         1                                    
QSECTION      QLE1                                           
    x         x         2                                    
    x         y         1                                    
    y         y         2                                    
    z         z         1                                    
QSECTION      COST                                           
    x         x         1                                    
    y         y         1                                    
    z         z         1                                    
ENDATA                                                       
