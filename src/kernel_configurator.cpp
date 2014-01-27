#include <QtWidgets>
#include <fstream>
#include "kernel_configurator.h"
#include "main_window.h"
#include "kernel_definitions.h"

using namespace kernel_definitions;

/**************************************************************************//**
** Constructor that takes a MainWindow pointer.
**
******************************************************************************/
KernelConfigurator::KernelConfigurator(MainWindow* _mainWindow):mainWindow(_mainWindow) {
  plot = new CPlot;
}

/**************************************************************************//**
** Calls the private methods to create the files.
**
******************************************************************************/
bool KernelConfigurator::generateKernelConfigurationFiles() {
  if (mainWindow != nullptr && mainWindow->canRunSimulation()) {
    createGeometryFile();
    createBlockFile();
    createFluidFile();
    createWellsFile();
    createSolutionFile();
    createArqResFile();
    createNumericPropertiesFile();
    createBoundaryConditionFile();

    return true;
  }

  return false;
}

/**************************************************************************//**
** Runs the kernel.
**
******************************************************************************/
void KernelConfigurator::runKernel() {
  system(KERNEL_COMMAND);
}

/**************************************************************************//**
** Create the File responsable for the grid geometry.
**
******************************************************************************/
void KernelConfigurator::createGeometryFile() {
  std::ofstream file;
  file.open(GEOMETRY_FILENAME);

  //get the lenght Tab
  Grid* lenghtGrid = (Grid*)mainWindow->geometryTab->widget(0);
  Grid* thicknessGrid = (Grid*)mainWindow->geometryTab->widget(1);
  Grid* depthGrid = (Grid*)mainWindow->geometryTab->widget(2);
  Grid* cellsGrid = (Grid*)mainWindow->rockTab->widget(0);

  int numberOfCells = lenghtGrid->columnCount();

  //TODO: Refactor to treat grid with several rows
  QTableWidgetItem *cell;
  for(int i = 0; i < numberOfCells; i++) {
    file << i + 1 << std::endl; //cell Id

    cell = thicknessGrid->item(0, i);
    if (cell != 0)
      file << cell->text().toStdString();
    else
      file << 0;
    file << "\n";

    cell = depthGrid->item(0, i);

    if (cell != 0)
      file << cell->text().toStdString();
    else
      file << 0;
    file << "\n"; //cell Depth

    cell = cellsGrid->item(0, i);
    if (cell != 0)
      file << cell->text().toStdString();
    else
      file << 0;
    file << "\n"; //block connected
    file << std::endl;
  }

  file.close();
}

/**************************************************************************//**
** Creates the File with the blocks properties.
**
******************************************************************************/
void KernelConfigurator::createBlockFile() {
  std::ofstream file;
  file.open(BLOCK_FILENAME);

  QList<QLineEdit *> SolutionInitFields = mainWindow->solutionInitializationWidget->
                                          findChildren<QLineEdit *>();

  int numberOfBlocks = mainWindow->blockPropertiesStackedWidget->count();
  for (int i = 0; i < numberOfBlocks; i++) {
     file << i + 1 << "\n";

     QGroupBox* gBox = (QGroupBox*)mainWindow->blockPropertiesStackedWidget->widget(i);
      QList<QLineEdit *> allFields = gBox->findChildren<QLineEdit *>();


     for (int j = 0; j < allFields.count(); ++j) {
        file << allFields.at(j)->text().toStdString() << "\n";
     }
     //Reference Pressure
     file << SolutionInitFields[0]->text().toStdString() << "\n";
     file << std::endl;
  }

  file.close();
}

/**************************************************************************//**
** Create the File with the Fluid properties.
**
******************************************************************************/
void KernelConfigurator::createFluidFile() {
  std::ofstream file;
  file.open(FLUID_FILENAME);

  int numberOPoints = mainWindow->pvtSpinBox->value();

  QTableWidget* grid = mainWindow->fluidDialog->getTable();

  if (file.good() && grid != nullptr) {
    file << numberOPoints << "\n" << std::endl;
    QTableWidgetItem *cell = nullptr;

    for (int i = 0; i < numberOPoints; ++i) {
      for(int j = 0; j < 4; j++)  {
        cell = grid->item(i, j);
        if (cell != 0)
          file << cell->text().toStdString();
        else
          file << 0;
        file << " ";
      }
      file << std::endl;
    }

    file.close();
  }
}

/**************************************************************************//**
** Create the File with the Wells properties.
**
******************************************************************************/
void KernelConfigurator::createWellsFile() {
  int numberOfWells = mainWindow->wellPropertiesStackedWidget->count();

  if (mainWindow->canRunSimulation()) {
    std::ofstream file(WELLS_FILENAME);

    file << numberOfWells << "\n\n";

    for (int i = 0; i < numberOfWells; i++) {
     QGroupBox* gBox = (QGroupBox*)mainWindow->wellPropertiesStackedWidget->widget(i);
     QList<QLineEdit *> editFields = gBox->findChildren<QLineEdit *>();
     QList<QComboBox *> comboFields = gBox->findChildren<QComboBox *>();

     //Cell Id Field
     file << editFields[0]->text().toStdString() << "\n";

     //Well Id
     file << i + 1 << "\n";

     if (comboFields[0]->currentText() == "Water") {
      file << "1" << "\n";
      }

      file << editFields[1]->text().toStdString() << "\n";
      file << std::endl;
    }
  }
}

/**************************************************************************//**
** Create the File with the Solution Initialization properties.
**
******************************************************************************/
void KernelConfigurator::createSolutionFile() {
  QList<QLineEdit *> allFields = mainWindow->solutionInitializationWidget->
                                 findChildren<QLineEdit *>();

  if (allFields.count() > 0) {
    std::ofstream file(SOLUTION_FILENAME);

    for (auto field : allFields)
      file << field->text().toStdString() << std::endl;

    file.close();
  }
}

/**************************************************************************//**
** Create the File with the Reservoir properties.
**
******************************************************************************/
void KernelConfigurator::createArqResFile() {
  std::ofstream file(RESERVOIR_FILENAME);
  int numberOfBlocks = mainWindow->blockPropertiesStackedWidget->count();

  Grid* lenghtGrid = (Grid*)mainWindow->geometryTab->widget(0);
  int numberOfCells = lenghtGrid->columnCount();

  QList<QLineEdit *> allFields = mainWindow->geometryWidget->findChildren<QLineEdit *>();


  if (allFields.count() > 0 && file.good()) {
    file << numberOfBlocks << "\n";
    file << numberOfCells << "\n";
    file << allFields[0]->text().toStdString() << "\n"; //width

    std::map<std::string, FluidType>::const_iterator iter = mainWindow->typeOfphases.begin();
    file << getFluidCorrespondingInt(iter->second) << "\n\n";

    QTableWidgetItem *cell;
    //TODO: Generalizar para varias linhas
    for(int i = 0; i < numberOfCells; i++) {
      cell = lenghtGrid->item(0, i);
      if (cell != 0)
        file << cell->text().toStdString();
      else
        file << 0;
      file << "\n";
    }
  }

  file.close();
}

/**************************************************************************//**
** Create the File with the Numeric properties.
**
******************************************************************************/
void KernelConfigurator::createNumericPropertiesFile() {
  QList<QComboBox *> solversList = mainWindow->propertiesWidget->findChildren<QComboBox *>();
  QList<QSpinBox *> numberOfIteractionsList = mainWindow->propertiesWidget->findChildren<QSpinBox *>();
  QList<QLineEdit *> otherFieldsList = mainWindow->propertiesWidget->findChildren<QLineEdit *>();

  if (solversList.count() > 0 && numberOfIteractionsList.count() > 0 &&
      otherFieldsList.count() > 0) {

    std::ofstream file(NUMERIC_PROPERTIES_FILENAME);

    if (solversList[0]->currentText() == "Gauss-Seidel") {
      file << "1" << "\n";
    }

    //Number of iteractions
    file << numberOfIteractionsList[0]->value() << "\n";

    //precision
    file << otherFieldsList[1]->text().toStdString() << "\n";
    file << std::endl;

    for (int i = 2; i < otherFieldsList.count(); ++i)
      file << otherFieldsList[i]->text().toStdString() << "\n";

    file.close();
  }
}

/**************************************************************************//**
** Create the File with the boundary conditions properties.
**
******************************************************************************/
void KernelConfigurator::createBoundaryConditionFile() {
  std::ofstream file(BOUNDARY_CONDITION_FILENAME);

  QList<QComboBox *> boundaryTypeList = mainWindow->boundaryConditionWidget->
                                        findChildren<QComboBox *>();

  QList<QLineEdit *> editsList = mainWindow->boundaryConditionWidget->
                                       findChildren<QLineEdit *>();

  for(int i = 0; i < boundaryTypeList.count(); i++) {
    if (boundaryTypeList[i]->currentText() == "Closed System") {
      file << 0 << "\n"; //type
      file << 0; //value should be zero when closed system is selected
    } else if (boundaryTypeList[i]->currentText() == "Specified Flow Rate") {
      file << 0 << "\n"; //type
      file << editsList[i]->text().toStdString();
    } else if (boundaryTypeList[i]->currentText() == "Specified Pressure") {
      file << 1 << "\n"; //type
      file << editsList[i]->text().toStdString();
    }
    file << "\n\n";
  }

  file.close();
}

/**************************************************************************//**
** makes a call to the CPlot object to plot the desired graph.
**
******************************************************************************/
void KernelConfigurator::plotWellPressure(std::string wellNumber) {
  plot->PlotWellPressure(std::stoi(wellNumber));
}

/**************************************************************************//**
** makes a call to the CPlot object to plot the desired graph.
**
******************************************************************************/
void KernelConfigurator::plotWellProduction(std::string wellNumber) {
  plot->PlotWellProduction(std::stoi(wellNumber));
}

/**************************************************************************//**
** makes a call to the CPlot object to plot the desired graph.
**
******************************************************************************/
void KernelConfigurator::plotCellPressure(std::string cellNumber) {
  plot->PlotCellPressure(std::stoi(cellNumber));
}

/**************************************************************************//**
** makes a call to the CPlot object to plot the desired graph.
**
******************************************************************************/
void KernelConfigurator::plotGridPressure(std::string timeStr, int nCells) {
plot->PlotGridPressure(std::stoi(timeStr), nCells);
}
