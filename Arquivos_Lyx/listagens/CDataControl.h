//** @file CDataControl.h */

#ifndef CDataControl_h
#define CDataControl_h

#include <string>
#include <vector>
#include <fstream>
#include <iostream>

#include "CBlock.h"
/**
 * This Class is responsible to control the information flow between the classes.
 * If the function receive strings, they will return data from the disk, using .dat archives.
 * These functions will be overloaded to comunicate the interface with the numerical kernel.
 */
class CDataControl
{
	public:
		
		CDataControl();
		~CDataControl();
		
		double * DataCGrid1d(std::string flname); ///< Gets information about the Grid 1d;
		double * DataCBlock(std::string flname, int blknum); ///< Gets information about Blocks;
	    double * DataCell1d(std::string flname, int cellnum); ///< Gets information about Cells 1d;
	    double * DataCFluid(std::string flname); ///< Gets information about Fluid data;
	    double * DataCWell1d(std::string flname); ///< Gets information about Wells 1d;
	    double * DataInitiate1d(std::string flname); ///< Gets information about the program initialization;
	    double * DataNumeric(std::string flname); ///< Gets information about numerical parameters;
	    double * DataBoundCond1d(std::string flname); ///< Gets information about boundary condition parameters.
};

#endif // CDataControl_h

