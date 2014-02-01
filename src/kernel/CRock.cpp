//** @file CRock.cpp */

#include "CRock.h" 


CRock::CRock() : rockcomp(0), permeability(0), por0(0), refpressure(0) 
{
	/// Class constructor
	
}


CRock::~CRock()
{
	/// Class destructor
	
}

double CRock::Porosity(double pressure) {
	/// This function returns the porosity in function of the pressure variation. The rock porosity is
	/// calculated based in an elastic compressibility.
	
	return  por0*exp(rockcomp*(pressure-refpressure));
	
}
