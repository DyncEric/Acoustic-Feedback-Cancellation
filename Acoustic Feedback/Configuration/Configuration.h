//
//  Configuration.h
//  Binaural
//
//  Created by Kashyap Patel on 9/24/19.
//  Copyright © 2019 Kashyap Patel. All rights reserved.
//

#ifndef Configuration_h
#define Configuration_h
#include <MacTypes.h>
#include <iostream>
using std::cout;
using std::cin;
using std::endl;

class Configuration{
    
    static Configuration* _instance;
   
    
    bool _isAFCOn;

    Configuration(){
        _isAFCOn = true;
    }
    
public:
    static Configuration* getInstance(){
        if(_instance == NULL)
            _instance = new Configuration();
        return _instance;
    }

    void setAFC(bool ans){_isAFCOn = ans;}
 
   
    bool getIsAFCOn(){return _isAFCOn;}
  
    
    void displaySetting(){
     
        cout << "AFC is : " << _isAFCOn << endl;
       
      
    }
    
};


#endif /* Configuration_h */
