/** @file kernel_configurator.h */
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

#ifndef KERNEL_CONFIGURATOR_H
#define KERNEL_CONFIGURATOR_H

#include <thread>
#include "../kernel/CPlot.h"

class MainWindow;

/*!
 * Class that creates the configuration files needed by the kernel to
 * make the simulation. It knows what is needed and how to structure the
 * data files.
 */
class KernelConfigurator {
public:
  KernelConfigurator(MainWindow* _mainWindow);

  bool generateKernelConfigurationFiles();
  void runKernel();
  void plotWellPressure(std::string wellNumber);
  void plotWellProduction(std::string wellNumber);
  void plotCellPressure(std::string cellNumber);
  void plotGridPressure(std::string time, int nCells);

private:
  void createGeometryFile();
  void createBlockFile();
  void createFluidFile();
  void createWellsFile();
  void createSolutionFile();
  void createArqResFile();
  void createNumericPropertiesFile();
  void createBoundaryConditionFile();


  MainWindow* mainWindow;
  CPlot* plot; ///< CPlot object responsable to plot to the screen
  std::thread* t;
};

#endif // KERNEL_CONFIGURATOR_H