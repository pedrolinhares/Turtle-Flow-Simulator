/** \file main_window.h */
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

#ifndef MAIN_WINDOW_H
#define MAIN_WINDOW_H

#include <QMainWindow>
#include <map>
#include "grid.h"
#include "start_dialog.h"
#include "fluid_dialog.h"

class QMenu;
class QAction;
class QWidget;
class QSpinBox;
class QToolBox;
class QVBoxLayout;
class QHBoxLayout;
class QStackedWidget;
class KernelConfigurator;

using namespace fluid_definitions;

/*! \class MainWindow
 *  \brief Class that represents the interface's main window.
 *
 *  It handles all visual elements and calls the kernel subroutines to
 *  run the simulation.
 */
class MainWindow : public QMainWindow {
  Q_OBJECT

public:
  /// A constructor that takes the parent pointer.
  explicit MainWindow(QWidget *parent = 0);
  ///Destroys all children widgets when destroyed.
  ~MainWindow() {};

private slots:
  void newProject();
  void createGrid(std::string, std::string, std::map<std::string, FluidType>, int, int);
  void createRockInnerDialog();
  void createWellInnerDialog();
  void run();
  void plot();
  void createPlotDialog();
  void generateConfigurationFiles();
  void showAboutDialog();
  void changeLeftBoundaryValue(const QString&);
  void changeRightBoundaryValue(const QString&);

private:
  void createActions();
  void createMenus();
  void setUpToolBox();
  bool canRunSimulation();
  QGroupBox* createBlockProperties();
  QGroupBox* createWellProperties();
  QHBoxLayout* createGeometryLayout();
  QVBoxLayout* createRockLayout();
  QVBoxLayout* createFluidLayout();
  QVBoxLayout* createWellLayout();
  QVBoxLayout* createNumericPropertiesLayout();
  QVBoxLayout* createSolutionInitializationLayout();
  QVBoxLayout* createBoundaryConditionLayout();

  int nToolboxItems = 0;
  QMenu* fileMenu;
  QMenu* actionsMenu;
  QMenu* helpMenu;
  QAction* newProjectAct;
  QAction* closeAct;
  QAction* runAction;
  QAction* plotAction;
  QAction* aboutAction;
  QStackedWidget* tabedContent;
  QTabWidget* geometryTab;
  QTabWidget* rockTab;
  QTabWidget* fluidTab;
  QTabWidget* wellTab;
  QWidget *centralWidget;
  QWidget* geometryWidget;
  QWidget *rockWidget;
  QWidget *propertiesWidget;
  QWidget *solutionInitializationWidget;
  QWidget *boundaryConditionWidget;
  QSpinBox* rows;
  QSpinBox* columns;
  QSpinBox* pvtSpinBox;
  QToolBox* toolBox;
  QVBoxLayout *gridLayout;
  QVBoxLayout *toolBoxLayout;
  QVBoxLayout *rockInnerLayout;
  QVBoxLayout *wellInnerLayout;
  QLineEdit *numberOfBlocksEdit;
  QLineEdit *numberOfWellsEdit;
  QLineEdit *leftBoudaryValueEdit;
  QLineEdit *rightBoudaryValueEdit;
  QLineEdit *wellNumberEdit;
  QLineEdit *cellNumberEdit;
  QLineEdit *timeEdit;
  QRadioButton *wellPressureRadio;
  QRadioButton *wellProductionRadio;
  QRadioButton *gridPressureRadio;
  QRadioButton *cellPressureRadio;
  StartDialog *startDialog;
  FluidDialog *fluidDialog;
  KernelConfigurator *kernelConfigurator;

  QStackedWidget *blockPropertiesStackedWidget = nullptr;
  QStackedWidget *wellPropertiesStackedWidget = nullptr;
  std::map<std::string, FluidType> typeOfphases;

  friend class KernelConfigurator;
};

#endif // MAIN_WINDOW_H
