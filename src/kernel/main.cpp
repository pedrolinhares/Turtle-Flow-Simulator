//** @file main.cpp */
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

#include <cstdlib>
#include <iostream>
#include <ctime>

#include "CReservoir.h"

void onExit() {
  std::cout << "End of Execution" << std::endl;
  std::cout << "UENF - LENEP"  << std::endl;
  #ifdef _WIN32
  	std::cin.ignore();
  #endif
  
}

int main() {
  clock_t timer; ///< Timer used to calculate the processing time.
  timer = clock(); ///< Getting the current time.
  std::atexit(onExit);

  CReservoir reservoir; ///< Reservoir Constructor
  reservoir.Run(); ///< Running the simulation. This is the main code of the program.
  
  timer = clock() - timer; ///< Updating timer;
  std::cout << "Processing time in seconds: " <<((float) timer)/1000 << std::endl; ///< Display the processing time.
  return 0;
}
