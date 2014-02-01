//** @file CWell1d.cpp */

#include "CWell1d.h"

CWell1d::CWell1d() : rate(0) , id(0) , cumulative_phase1(0)
{
	/// Well constructor.
}

CWell1d::~CWell1d()
{
	/// Well destructor.
}

void CWell1d::Rate( double _rate, int _id) { 
	 ///< Sets the well flow rate, and the well Id.

	rate = _rate; 
	id = _id;
}
