//** @file CDataControl.h */
/******************************************************************************
 *  This file is part of TFS (Turtle Flow Simulator), a Qt based reservoir
 *  simulator.
 *  Copyright (C) 2013-2014 Pedro Henrique Linhares, Wagner Queiroz.
 *
 *  TFS is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  TFS is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with TFS.  If not, see <http://www.gnu.org/licenses/>.
 *****************************************************************************/

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
class CDataControl {
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

