#ifndef KERNEL_CONFIGURATOR_H
#define KERNEL_CONFIGURATOR_H

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
};

#endif // KERNEL_CONFIGURATOR_H