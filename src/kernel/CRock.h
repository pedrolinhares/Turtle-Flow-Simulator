//** @file CRock.h */

#ifndef CRock_h
#define CRock_h

#include <cmath>
#include <iostream>  

/**
 * This Class is used to store the Rock parameters, and its object will be created inside the Blocks.
 */
 
class CRock
{
	
    private:
    	
        double rockcomp; // Rock Compressibility
        double permeability; //Rock Permeability
        double por0; //Inicial Rock Porosity
		double refpressure; //Reference Pressure        
	public:
		
		CRock();	             
		~CRock();
		
		inline void Rockcomp(double _rockcomp) {rockcomp = _rockcomp;}; ///< Sets the Rock Compressibility;
		inline double Rockcomp() {return rockcomp;}; ///< Returns Rock Compressibility;
		
		inline void Permeability(double _permeability) {permeability = _permeability;}; ///< Sets the Rock Permeability;
		inline double Permeability() {return permeability;}; ///< Returns Rock Permeability;
		
		inline void Por0(double _porosity) {por0 = _porosity;}; ///< Sets the initial Rock Porosity;
		
		inline double Porosity() { return por0; }; ///< Returns initial Rock Porosity;
		double Porosity(double pressure); ///< Returns atual Rock Porosity;
		
		inline void RefPressure( double _refpressure) { refpressure = _refpressure; }; ///< Sets the reference pressure of porosity.
};

#endif // CRock_h
