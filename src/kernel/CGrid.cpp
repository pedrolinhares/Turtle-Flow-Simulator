//** @file CGrid.cpp */

#include "CGrid.h" // class's header file

using namespace std;

// class constructor
CGrid::CGrid(CDataControl *_dcontrol) : dcontrol(_dcontrol)
{
    betac = 1.127; ///< Conversion units factor.
    
}

// class destructor
CGrid::~CGrid()
{
	delete [] block;
	block = NULL;
	delete fluid;
	fluid = NULL;
}
