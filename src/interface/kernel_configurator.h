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