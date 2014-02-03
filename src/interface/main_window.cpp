/** @file main_window.cpp */

#include <QtWidgets>
#include <string>
#include <fstream>
#include <sstream>
#include <cstdlib>
#include "main_window.h"
#include "kernel_configurator.h"

MainWindow::MainWindow(QWidget *parent) : QMainWindow(parent) {
  kernelConfigurator = new KernelConfigurator(this);
  QHBoxLayout* layout = new QHBoxLayout;

  gridLayout = new QVBoxLayout;
  toolBoxLayout = new QVBoxLayout;

  layout->addLayout(toolBoxLayout);
  layout->addLayout(gridLayout);

  centralWidget = new QWidget;
  centralWidget->setLayout(layout);

  setCentralWidget(centralWidget);
  createActions();
  createMenus();

  startDialog = new StartDialog(this);
  connect(startDialog,
          SIGNAL(dialogFinished(std::string, std::string,
                                std::map<std::string, FluidType>, int, int)),
          this, SLOT(createGrid(std::string, std::string,
                                std::map<std::string, FluidType>, int, int)));

  setWindowTitle(tr("Turtle Flow Simulator"));
  setMinimumSize(200, 200);
  resize(1200, 800);
}

/**************************************************************************//**
** \brief Creates the actions to be used in the menu's options.
**
** Creates the actions to be used in the menu's options.
******************************************************************************/
void MainWindow::createActions() {
  newProjectAct = new QAction(tr("&New simulation"), this);
  newProjectAct->setStatusTip(tr("Creates a new simulation"));
  connect(newProjectAct, SIGNAL(triggered()), this, SLOT(newProject()));

  //Close Action
  closeAct = new QAction(tr("&Quit"), this);
  closeAct->setShortcut(tr("Ctrl+Q"));
  closeAct->setStatusTip(tr("Quit the application"));

  connect(closeAct, SIGNAL(triggered()), qApp, SLOT(closeAllWindows()));

  // run Action
  runAction = new QAction(tr("Run Simulation"), this);
  runAction->setStatusTip(tr("Runs the simulation"));
  runAction->setEnabled(false);
  connect(runAction, SIGNAL(triggered()), this, SLOT(run()));

  //plot action
  plotAction = new QAction(tr("Plot results"), this);
  plotAction->setStatusTip(tr("Plot resulto of the simulation"));
  plotAction->setEnabled(false);
  connect(plotAction, SIGNAL(triggered()), this, SLOT(createPlotDialog()));
}

/**************************************************************************//**
** Creates the application Menus.
******************************************************************************/
void MainWindow::createMenus() {
  fileMenu = menuBar()->addMenu(tr("&File"));
  fileMenu->addAction(newProjectAct);
  fileMenu->addSeparator();
  fileMenu->addAction(closeAct);

  actionsMenu = menuBar()->addMenu(tr("&Actions"));
  actionsMenu->addAction(runAction);
  actionsMenu->addAction(plotAction);
}

/**************************************************************************//**
** \brief Creates the ToolBox located to the left side of the window.
**
** The ToolBox contains the tabs that identify which simulator configuration
** part. Each part comes from a method that returns a layout widget that
** holds its configuration parts.
******************************************************************************/
void MainWindow::setUpToolBox() {
  if(!toolBoxLayout->isEmpty()) {
    toolBoxLayout->removeWidget(toolBox);
    delete toolBox;
  }

  toolBox = new QToolBox;
  toolBox->setMaximumWidth(250);

  //Geometry Tab
  geometryWidget = new QWidget;
  geometryWidget->setLayout(createGeometryLayout());

  toolBox->insertItem(0, geometryWidget, tr("Geometry"));

  //Rock Tab
  rockWidget = new QWidget(this);
  rockWidget->setLayout(createRockLayout());

  toolBox->insertItem(1, rockWidget, tr("Rock"));

  //Fluid Tab
  QWidget *fluidTabContent = new QWidget;
  fluidTabContent->setLayout(createFluidLayout());

  toolBox->insertItem(2, fluidTabContent, tr("Fluid"));

  //Well Tab
  QWidget* wellWidget = new QWidget;
  wellWidget->setLayout(createWellLayout());
  toolBox->insertItem(3, wellWidget, tr("Wells"));

  //Properties Tab
  propertiesWidget = new QWidget;
  propertiesWidget->setLayout(createNumericPropertiesLayout());

  toolBox->insertItem(4, propertiesWidget, tr("Numeric Properties"));

  //Solution Initialization Tab
  solutionInitializationWidget = new QWidget;
  solutionInitializationWidget->setLayout(createSolutionInitializationLayout());

  toolBox->insertItem(5, solutionInitializationWidget, tr("Initialize Solution"));

  //Boundary Conditions tab
  boundaryConditionWidget = new QWidget;
  boundaryConditionWidget->setLayout(createBoundaryConditionLayout());

  toolBox->insertItem(6, boundaryConditionWidget, tr("Boundary Condition"));

  nToolboxItems = toolBox->count();
  toolBoxLayout->addWidget(toolBox);
}

/**************************************************************************//**
** Creates the Geometry tab options.
** \return a Layout object
******************************************************************************/
QHBoxLayout* MainWindow::createGeometryLayout() {
  QLineEdit* widthEdit = new QLineEdit;
  QLabel* widthEditLabel = new QLabel(tr("Width: "));

  QHBoxLayout* hBox = new QHBoxLayout;
  hBox->addWidget(widthEditLabel);
  hBox->addWidget(widthEdit);
  hBox->setAlignment(Qt::AlignTop);

  return hBox;
}

/**************************************************************************//**
** Creates the Rock tab options.
** \return a Layout object
******************************************************************************/
QVBoxLayout* MainWindow::createRockLayout() {
  QVBoxLayout *rockLayout = new QVBoxLayout;
  rockInnerLayout = new QVBoxLayout;

  QValidator *intValidator = new QIntValidator(1, 99,this);
  numberOfBlocksEdit = new QLineEdit;
  numberOfBlocksEdit->setValidator(intValidator);

  QPushButton *ok_button = new QPushButton(tr("Ok"));

  QHBoxLayout *numberOfBlocksLayout = new QHBoxLayout;
  numberOfBlocksLayout->addWidget(numberOfBlocksEdit);
  numberOfBlocksLayout->addWidget(ok_button);

  connect(ok_button, SIGNAL(clicked()), this, SLOT(createRockInnerDialog()));


  QLabel* numberofBlocksLabel = new QLabel(tr("Enter the number of Blocks:"));
  numberofBlocksLabel->setBuddy(numberOfBlocksEdit);

  rockLayout->addWidget(numberofBlocksLabel);
  rockLayout->addLayout(numberOfBlocksLayout);
  rockLayout->addLayout(rockInnerLayout);

  rockLayout->setAlignment(Qt::AlignTop);

  return rockLayout;
}

/**************************************************************************//**
** Creates the Fluid tab options.
** \return a Layout object
******************************************************************************/
QVBoxLayout* MainWindow::createFluidLayout() {
  QHBoxLayout *pvtPointsLayout = new QHBoxLayout;

  pvtSpinBox = new QSpinBox;
  pvtSpinBox->setMinimum(2);

  QComboBox* chooseOil = new QComboBox;

  std::map<std::string, FluidType>::const_iterator iter;

  int count = 0;
  for (iter = typeOfphases.begin(); iter != typeOfphases.end(); iter++) {
    chooseOil->insertItem(count, getFluidCorrespondingStdString(iter->second).c_str());
    count++;
  }

  QLabel *chooseOilLabel = new QLabel(tr("Choose Oil type: "));
  chooseOilLabel->setBuddy(chooseOil);

  QLabel *pvtLabel = new QLabel(tr("Number of PVT Points: "));
  pvtLabel->setBuddy(pvtSpinBox);

  pvtPointsLayout->addWidget(pvtLabel);
  pvtPointsLayout->addWidget(pvtSpinBox);
  pvtPointsLayout->setAlignment(Qt::AlignTop);

  QVBoxLayout* vLayout = new QVBoxLayout;
  vLayout->addWidget(chooseOilLabel);
  vLayout->addWidget(chooseOil);
  vLayout->addLayout(pvtPointsLayout);
  vLayout->setAlignment(Qt::AlignTop);

  return vLayout;
}

/**************************************************************************//**
** Creates the Wells tab options.
** \return a Layout object
******************************************************************************/
QVBoxLayout* MainWindow::createWellLayout() {
  QVBoxLayout* wellLayout = new QVBoxLayout;
  wellInnerLayout = new QVBoxLayout;

  QIntValidator *intValidator = new QIntValidator;

  numberOfWellsEdit = new QLineEdit;
  numberOfWellsEdit->setValidator(intValidator);

  QPushButton *WellOk_button = new QPushButton(tr("Ok"));

  QHBoxLayout *numberOfWellsLayout = new QHBoxLayout;
  numberOfWellsLayout->addWidget(numberOfWellsEdit);
  numberOfWellsLayout->addWidget(WellOk_button);

  connect(WellOk_button, SIGNAL(clicked()), this, SLOT(createWellInnerDialog()));

  QLabel* numberofWellsLabel = new QLabel(tr("Enter the number of Wells:"));
  numberofWellsLabel->setBuddy(numberOfWellsEdit);

  wellLayout->addWidget(numberofWellsLabel);
  wellLayout->addLayout(numberOfWellsLayout);
  wellLayout->addLayout(wellInnerLayout);

  wellLayout->setAlignment(Qt::AlignTop);

  return wellLayout;
}

/**************************************************************************//**
** Creates the Numeric Properties tab options.
** \return a Layout object
******************************************************************************/
QVBoxLayout* MainWindow::createNumericPropertiesLayout() {
  QVBoxLayout* vbox = new QVBoxLayout;

  QHBoxLayout* hbox1 = new QHBoxLayout;

  QComboBox* solverComboBox = new QComboBox;
  solverComboBox->insertItem(0, "Gauss-Seidel");
  QLabel* solverLabel = new QLabel(tr("Solver: "));
  solverLabel->setBuddy(solverComboBox);

  hbox1->addWidget(solverLabel);
  hbox1->addWidget(solverComboBox);

  QSpinBox* numberOfIteractionsSpinBox = new QSpinBox;
  numberOfIteractionsSpinBox->setRange(0, 1000000);
  numberOfIteractionsSpinBox->setValue(150);
  QLabel* numberOfIteractionsLabel = new QLabel(tr("Iteractions: "));
  numberOfIteractionsLabel->setBuddy(numberOfIteractionsSpinBox);

  QHBoxLayout* hbox2 = new QHBoxLayout;
  hbox2->addWidget(numberOfIteractionsLabel);
  hbox2->addWidget(numberOfIteractionsSpinBox);

  QDoubleValidator *doubleValidator = new QDoubleValidator;
  QIntValidator *intValidator = new QIntValidator;

  QLineEdit* precisionSolverEdit = new QLineEdit;
  precisionSolverEdit->setValidator(doubleValidator);
  precisionSolverEdit->setText("0.001");
  QLabel* precisionSolverLabel = new QLabel(tr("Solver Precision: "));
  precisionSolverLabel->setBuddy(precisionSolverEdit);

  QHBoxLayout* hbox3 = new QHBoxLayout;
  hbox3->addWidget(precisionSolverLabel);
  hbox3->addWidget(precisionSolverEdit);

  QLineEdit* deltaTEdit = new QLineEdit;
  deltaTEdit->setValidator(doubleValidator);
  deltaTEdit->setText("1");
  QLabel* deltaTLabel = new QLabel(tr("Δt: "));
  deltaTLabel->setBuddy(deltaTEdit);

  QHBoxLayout* hbox4 = new QHBoxLayout;
  hbox4->addWidget(deltaTLabel);
  hbox4->addWidget(deltaTEdit);


  QLineEdit* endTimeEdit = new QLineEdit;
  endTimeEdit->setValidator(intValidator);
  QLabel* endTimeLabel = new QLabel(tr("Final simulation time: "));
  endTimeLabel->setBuddy(endTimeEdit);

  QHBoxLayout* hbox5 = new QHBoxLayout;
  hbox5->addWidget(endTimeLabel);
  hbox5->addWidget(endTimeEdit);

  QLineEdit* thresholdMaxIterationsEdit = new QLineEdit;
  thresholdMaxIterationsEdit->setValidator(intValidator);
  thresholdMaxIterationsEdit->setText("100");
  QLabel* thresholdMaxIterationsLabel = new QLabel(tr("Thresholding Max Iteractions: "));
  thresholdMaxIterationsLabel->setBuddy(thresholdMaxIterationsEdit);

  QVBoxLayout* vbox6 = new QVBoxLayout;
  vbox6->addWidget(thresholdMaxIterationsLabel);
  vbox6->addWidget(thresholdMaxIterationsEdit);

  QLineEdit* thresholdRelativePrecisionEdit = new QLineEdit;
  thresholdRelativePrecisionEdit->setValidator(doubleValidator);
  thresholdRelativePrecisionEdit->setText("0.001");
  QLabel* thresholdRelativePrecisionLabel = new QLabel(tr("Thresholding Relative Precision: "));
  thresholdRelativePrecisionLabel->setBuddy(thresholdRelativePrecisionEdit);

  QVBoxLayout* vbox7 = new QVBoxLayout;
  vbox7->addWidget(thresholdRelativePrecisionLabel);
  vbox7->addWidget(thresholdRelativePrecisionEdit);

  vbox->addLayout(hbox1);
  vbox->addLayout(hbox2);
  vbox->addLayout(hbox3);
  vbox->addLayout(hbox4);
  vbox->addLayout(hbox5);
  vbox->addLayout(vbox6);
  vbox->addLayout(vbox7);

  vbox->setAlignment(Qt::AlignTop);

  return vbox;
}

/**************************************************************************//**
** Creates the Solution Initialization tab options.
** \return a Layout object
******************************************************************************/
QVBoxLayout* MainWindow::createSolutionInitializationLayout() {
  QLineEdit* refPressureEdit = new QLineEdit;
  QLabel* refPressureEditLabel = new QLabel(tr("Reference Pressure: "));

  QHBoxLayout* hBox2 = new QHBoxLayout;
  hBox2->addWidget(refPressureEditLabel);
  hBox2->addWidget(refPressureEdit);
  hBox2->setAlignment(Qt::AlignTop);

  QLineEdit* refDeepthEdit = new QLineEdit;
  QLabel* refDeepthEditLabel = new QLabel(tr("Reference Deepth: "));

  QHBoxLayout* hBox3 = new QHBoxLayout;
  hBox3->addWidget(refDeepthEditLabel);
  hBox3->addWidget(refDeepthEdit);
  hBox3->setAlignment(Qt::AlignTop);

  QVBoxLayout* vBox = new QVBoxLayout;
  vBox->addLayout(hBox2);
  vBox->addLayout(hBox3);
  vBox->setAlignment(Qt::AlignTop);

  return vBox;
}

/**************************************************************************//**
** Creates the boundary conditions tab options.
** \return a Layout object
******************************************************************************/
QVBoxLayout* MainWindow::createBoundaryConditionLayout() {
  QDoubleValidator *doubleValidator = new QDoubleValidator;

  QVBoxLayout* vBox = new QVBoxLayout;
  vBox->addWidget(new QLabel(tr("Left Boundary")));

  QComboBox* boundaryTypeComboBox = new QComboBox;
  boundaryTypeComboBox->insertItem(0, tr("Closed System"));
  boundaryTypeComboBox->insertItem(1, tr("Specified Flow Rate"));
  boundaryTypeComboBox->insertItem(2, tr("Specified Pressure"));
  boundaryTypeComboBox->setCurrentIndex(2);

  leftBoudaryValueEdit = new QLineEdit;
  leftBoudaryValueEdit->setValidator(doubleValidator);

  connect(boundaryTypeComboBox, SIGNAL(currentIndexChanged(const QString&)),
          this, SLOT(changeLeftBoundaryValue(const QString&)));

  QHBoxLayout* hBox1 = new QHBoxLayout;
  hBox1->addWidget(new QLabel(tr("Boundary Type")));
  hBox1->addWidget(boundaryTypeComboBox);

  QHBoxLayout* hBox2 = new QHBoxLayout;
  hBox2->addWidget(new QLabel(tr("Value: ")));
  hBox2->addWidget(leftBoudaryValueEdit);

  vBox->addLayout(hBox1);
  vBox->addLayout(hBox2);
  vBox->addWidget(new QLabel(tr("Right Boundary")));

  QComboBox* boundaryTypeComboBox2 = new QComboBox;
  boundaryTypeComboBox2->insertItem(0, tr("Closed System"));
  boundaryTypeComboBox2->insertItem(1, tr("Specified Flow Rate"));
  boundaryTypeComboBox2->insertItem(2, tr("Specified Pressure"));
  boundaryTypeComboBox2->setCurrentIndex(2);

  rightBoudaryValueEdit = new QLineEdit;
  rightBoudaryValueEdit->setValidator(doubleValidator);

  connect(boundaryTypeComboBox2, SIGNAL(currentIndexChanged(const QString&)),
          this, SLOT(changeRightBoundaryValue(const QString&)));

  QHBoxLayout* hBox3 = new QHBoxLayout;
  hBox3->addWidget(new QLabel(tr("Boundary Type")));
  hBox3->addWidget(boundaryTypeComboBox2);

  QHBoxLayout* hBox4 = new QHBoxLayout;
  hBox4->addWidget(new QLabel(tr("Value: ")));
  hBox4->addWidget(rightBoudaryValueEdit);

  QPushButton* generateFilesButton = new QPushButton(tr("Create Files"));
  connect(generateFilesButton, SIGNAL(clicked()),
          this, SLOT(generateConfigurationFiles()));

  vBox->addLayout(hBox3);
  vBox->addLayout(hBox4);
  vBox->addStretch();
  vBox->addWidget(generateFilesButton);
  vBox->addStretch();
  vBox->setAlignment(Qt::AlignTop);

  return vBox;
}

/**************************************************************************//**
** Creates the Well's layout object that holds the wells tab properties.
** \return a QGroupBox that contains the QLineEdit fields.
******************************************************************************/
QGroupBox* MainWindow::createWellProperties() {
  QGroupBox *groupBox = new QGroupBox(tr("Well properties"));
  QVBoxLayout *vbox = new QVBoxLayout;

  QIntValidator *intValidator = new QIntValidator;

  QLineEdit* cellIdEdit = new QLineEdit;
  cellIdEdit->setValidator(intValidator);
  QLabel* cellIdLabel = new QLabel(tr("Cell Id: "));
  cellIdLabel->setBuddy(cellIdEdit);

  QHBoxLayout *layout1 = new QHBoxLayout;
  layout1->addWidget(cellIdLabel);
  layout1->addWidget(cellIdEdit);

  QComboBox* fluidTypeComboBox = new QComboBox;
  fluidTypeComboBox->insertItem(0, tr("Water"));
  fluidTypeComboBox->insertItem(1, tr("Oil"));
  fluidTypeComboBox->insertItem(0, tr("Gas"));
  fluidTypeComboBox->setEnabled(false);

  QLabel* fluidTypeLabel = new QLabel(tr("Fluid Type: "));
  fluidTypeLabel->setBuddy(fluidTypeComboBox);

  QHBoxLayout *layout2 = new QHBoxLayout;
  layout2->addWidget(fluidTypeLabel);
  layout2->addWidget(fluidTypeComboBox);

  QLineEdit* wellRateEdit = new QLineEdit;
  wellRateEdit->setValidator(intValidator);
  QLabel* wellRateLabel = new QLabel(tr("Well Rate \n(Negative - productor \n Positive - injector): "));
  wellRateLabel->setBuddy(wellRateEdit);

  QVBoxLayout *layout3 = new QVBoxLayout;
  layout3->addWidget(wellRateLabel);
  layout3->addWidget(wellRateEdit);

  vbox->addLayout(layout1);
  vbox->addLayout(layout2);
  vbox->addLayout(layout3);

  vbox->setAlignment(Qt::AlignTop);
  groupBox->setLayout(vbox);

  return groupBox;
}

/**************************************************************************//**
** Creates the Well's layout object that holds the Block's tab properties.
** \return a QGroupBox that contains the QLineEdit fields.
******************************************************************************/
QGroupBox* MainWindow::createBlockProperties() {
   //Block properties
  QGroupBox *groupBox = new QGroupBox(tr("Block properties"));
  QVBoxLayout *vbox = new QVBoxLayout;

  QDoubleValidator *doubleValidator = new QDoubleValidator;

  QLineEdit* edit1 = new QLineEdit;
  edit1->setValidator(doubleValidator);
  QLabel* edit1Label = new QLabel(tr("Porosity:"));
  edit1Label->setBuddy(edit1);

  QHBoxLayout *layout1 = new QHBoxLayout;
  layout1->addWidget(edit1Label);
  layout1->addWidget(edit1);

  QLineEdit* edit2 = new QLineEdit;
  edit2->setValidator(doubleValidator);
  QLabel* edit2Label = new QLabel(tr("Permeability:"));
  edit2Label->setBuddy(edit2);

  QHBoxLayout *layout2 = new QHBoxLayout;
  layout2->addWidget(edit2Label);
  layout2->addWidget(edit2);

  QLineEdit* edit3 = new QLineEdit;
  edit3->setValidator(doubleValidator);
  QLabel* edit3Label = new QLabel(tr("Compressibility:"));
  edit3Label->setBuddy(edit3);

  QHBoxLayout *layout3 = new QHBoxLayout;
  layout3->addWidget(edit3Label);
  layout3->addWidget(edit3);

  vbox->addLayout(layout3);
  vbox->addLayout(layout2);
  vbox->addLayout(layout1);

  vbox->setAlignment(Qt::AlignTop);
  groupBox->setLayout(vbox);

  return groupBox;
}

//private slots

/**************************************************************************//**
** Creates a new project dialog.
**
** \note private slot
******************************************************************************/
void MainWindow::newProject() {
  startDialog->show();
 }

/**************************************************************************//**
** Creates the content of the Rock tab.
**
** \note private slot
******************************************************************************/
void MainWindow::createRockInnerDialog() {
  if (!rockInnerLayout->isEmpty()) {
    QLayoutItem* item;
    while ((item = rockInnerLayout->takeAt(0)) != NULL ) {
      delete item->widget();
      delete item;
    }
  }

  int numberOfBlocks = std::stoi(numberOfBlocksEdit->text().toStdString());

  QComboBox *numberOfBlocksComboBox = new QComboBox;

  QLabel *numberOfBlocksLabel = new QLabel(tr("Choose block to configure:"));
  numberOfBlocksLabel->setBuddy(numberOfBlocksComboBox);

  blockPropertiesStackedWidget = new QStackedWidget;

  for(int i = 0; i < numberOfBlocks; i++) {
    numberOfBlocksComboBox->insertItem(i, std::to_string(i + 1).c_str());
    blockPropertiesStackedWidget->addWidget(createBlockProperties());
  }

  connect(numberOfBlocksComboBox, SIGNAL(currentIndexChanged(int)),
          blockPropertiesStackedWidget, SLOT(setCurrentIndex(int)));

  rockInnerLayout->addWidget(numberOfBlocksLabel);
  rockInnerLayout->addWidget(numberOfBlocksComboBox);
  rockInnerLayout->addWidget(blockPropertiesStackedWidget);

 }

/**************************************************************************//**
** Creates the content of the Well tab.
**
** \note private slot
******************************************************************************/
 void MainWindow::createWellInnerDialog() {
  if (!wellInnerLayout->isEmpty()) {
    QLayoutItem* item;
    while ((item = wellInnerLayout->takeAt(0)) != NULL ) {
      delete item->widget();
      delete item;
    }
  }

  int numberOfWells = std::stoi(numberOfWellsEdit->text().toStdString());

  QComboBox *numberOfWellsComboBox = new QComboBox;

  QLabel *numberOfWellsLabel = new QLabel(tr("Choose a Well to configure:"));
  numberOfWellsLabel->setBuddy(numberOfWellsComboBox);

  wellPropertiesStackedWidget = new QStackedWidget;

  for(int i = 0; i < numberOfWells; i++) {
    numberOfWellsComboBox->insertItem(i, std::to_string(i + 1).c_str());
    wellPropertiesStackedWidget->addWidget(createWellProperties());
  }

  connect(numberOfWellsComboBox, SIGNAL(currentIndexChanged(int)),
          wellPropertiesStackedWidget, SLOT(setCurrentIndex(int)));

  wellInnerLayout->addWidget(numberOfWellsLabel);
  wellInnerLayout->addWidget(numberOfWellsComboBox);
  wellInnerLayout->addWidget(wellPropertiesStackedWidget);
 }

/**************************************************************************//**
** Creates the grids placed in the interface's rightmost side.
** \param dimension One dimensional, Two dimensional or Three dimensional
** \param nPhases Number of phases
** \param _typeOfPhases map containing the phase and its type (Water, Oil, Gas)
** \param nRows Number of the Grid Rows
** \param nColumns Number of the Grid Columns
** \note private slot
******************************************************************************/
void MainWindow::createGrid(std::string dimension, std::string nPhases,
                            std::map<std::string, FluidType> _typeOfphases,
                            int nRows, int nColumns) {

  typeOfphases = _typeOfphases;
  setUpToolBox();

  if (!gridLayout->isEmpty()) {
    gridLayout->removeWidget(tabedContent);
    delete tabedContent;
  }

  if (dimension == "oneDimensional")
    nRows = 1;

  tabedContent = new QStackedWidget;

  //connects toolbox to the grid to change its content
  connect(toolBox, SIGNAL(currentChanged(int)),
          tabedContent, SLOT(setCurrentIndex(int)));

  //create the tabed content for each item from the left toolbox
  //for the geometry tab
  geometryTab = new QTabWidget;

  geometryTab->addTab(new Grid(nRows, nColumns), "Lenght");
  geometryTab->addTab(new Grid(nRows, nColumns), "Thickness");
  geometryTab->addTab(new Grid(nRows, nColumns), "Depth");

  tabedContent->addWidget(geometryTab);


  //For the rock tab
  rockTab = new QTabWidget;
  rockTab->addTab(new Grid(nRows, nColumns), "Cells");

  tabedContent->addWidget(rockTab);

  //for the fluid tab
  fluidTab = new QTabWidget;

  fluidDialog = new FluidDialog(fluidTab);

  connect(pvtSpinBox, SIGNAL(valueChanged(int)),
          fluidDialog, SLOT(insertOrRemoveRows(int)));

  fluidTab->addTab(fluidDialog, "Fluid Properties");

  tabedContent->addWidget(fluidTab);
  gridLayout->addWidget(tabedContent);

  //Well Tab
  // wellTab = new QTabWidget;
  // wellTab->addTab(new Grid(nRows, nColumns), "Wells");

  // tabedContent->addWidget(wellTab);

  QWidget* wellWidget = new QWidget;
  tabedContent->addWidget(wellWidget);

  //Numeric Properties Tab
  QWidget* numericPropertiesTabContent = new QWidget;

  tabedContent->addWidget(numericPropertiesTabContent);

  //Init Solution Tab
  QWidget* initSolutionTabContent = new QWidget;

  tabedContent->addWidget(initSolutionTabContent);

  //Boundary Condition Tab
  QWidget* boundaryConditionTabContent = new QWidget;

  tabedContent->addWidget(boundaryConditionTabContent);

  //enable the run simulation action
  runAction->setEnabled(true);
}

/**************************************************************************//**
** creates dialog that asks information needed to plot graphic results.
**
** \note private slot
******************************************************************************/
void MainWindow::createPlotDialog() {
  QDialog *dialog = new QDialog(this);

  QValidator *intValidator = new QIntValidator(1, 99,this);

  QGroupBox *typeBox = new QGroupBox(tr("Type"));

  wellPressureRadio = new QRadioButton(tr("Well Pressure"));
  wellProductionRadio = new QRadioButton(tr("Well Production"));
  gridPressureRadio = new QRadioButton(tr("Grid Pressure"));
  cellPressureRadio = new QRadioButton(tr("Cell Pressure"));
  wellPressureRadio->setChecked(true);

  QVBoxLayout *vBox = new QVBoxLayout;
  vBox->addWidget(wellPressureRadio);
  vBox->addWidget(wellProductionRadio);
  vBox->addWidget(gridPressureRadio);
  vBox->addWidget(cellPressureRadio);

  typeBox->setLayout(vBox);

  QGroupBox *dataBox = new QGroupBox(tr("Data"));

  wellNumberEdit = new QLineEdit;
  wellNumberEdit->setValidator(intValidator);
  wellNumberEdit->setDisabled(false);
  QLabel *wellNumberLabel = new QLabel(tr("Well Number: "));

  QHBoxLayout *hBox1 = new QHBoxLayout;
  hBox1->addWidget(wellNumberLabel);
  hBox1->addWidget(wellNumberEdit);

  cellNumberEdit = new QLineEdit;
  cellNumberEdit->setValidator(intValidator);
  cellNumberEdit->setDisabled(true);
  QLabel *cellNumberLabel = new QLabel(tr("Cell Number: "));

  QHBoxLayout *hBox2 = new QHBoxLayout;
  hBox2->addWidget(cellNumberLabel);
  hBox2->addWidget(cellNumberEdit);

  timeEdit = new QLineEdit;
  timeEdit->setDisabled(true);
  QLabel *timeLabel = new QLabel(tr("Time: "));

  QHBoxLayout *hBox3 = new QHBoxLayout;
  hBox3->addWidget(timeLabel);
  hBox3->addWidget(timeEdit);

  QVBoxLayout *vBox2 = new QVBoxLayout;
  vBox2->addLayout(hBox1);
  vBox2->addLayout(hBox2);
  vBox2->addLayout(hBox3);

  dataBox->setLayout(vBox2);

  //connections
  connect(wellPressureRadio, &QRadioButton::toggled, [=](bool toggled) {
    if (toggled == true) {
      wellNumberEdit->setEnabled(true);
      timeEdit->setEnabled(false);
      cellNumberEdit->setEnabled(false);
    }});

  connect(wellProductionRadio, &QRadioButton::toggled, [=](bool toggled) {
    if (toggled == true) {
      wellNumberEdit->setEnabled(true);
      timeEdit->setEnabled(false);
      cellNumberEdit->setEnabled(false);
    }});

  connect(gridPressureRadio, &QRadioButton::toggled, [=](bool toggled) {
    if (toggled == true) {
      wellNumberEdit->setEnabled(false);
      timeEdit->setEnabled(true);
      cellNumberEdit->setEnabled(false);
    }});

  connect(cellPressureRadio, &QRadioButton::toggled, [=](bool toggled) {
    if (toggled == true) {
      wellNumberEdit->setEnabled(false);
      timeEdit->setEnabled(false);
      cellNumberEdit->setEnabled(true);
    }});


  //Buttons
  QPushButton *ok_button = new QPushButton(tr("Ok"));
  QPushButton *close_button = new QPushButton(tr("Cancel"));

  ok_button->setDefault(true);

  QHBoxLayout *buttonsLayout = new QHBoxLayout;
  buttonsLayout->addStretch(1);
  buttonsLayout->addWidget(close_button);
  buttonsLayout->addWidget(ok_button);

  connect(close_button, SIGNAL(clicked()), dialog, SLOT(close()));
  connect(ok_button, SIGNAL(clicked()), this, SLOT(plot()));
  connect(ok_button, SIGNAL(clicked()), dialog, SLOT(close()));

  QHBoxLayout *hBox4 = new QHBoxLayout;
  hBox4->addWidget(typeBox);
  hBox4->addWidget(dataBox);

  QVBoxLayout *vBox3 = new QVBoxLayout;
  vBox3->addLayout(hBox4);
  vBox3->addLayout(buttonsLayout);

  dialog->setLayout(vBox3);

  dialog->show();
}

/**************************************************************************//**
** Calls the plot object.
**
** \note private slot
******************************************************************************/
void MainWindow::plot() {
  if (wellPressureRadio->isChecked()) {
    std::string nWell = wellNumberEdit->text().toStdString();
    kernelConfigurator->plotWellPressure(nWell);

  } else if (wellProductionRadio->isChecked()) {
    std::string nWell = wellNumberEdit->text().toStdString();
    kernelConfigurator->plotWellProduction(nWell);

  } else if (gridPressureRadio->isChecked()) {
    Grid* lenghtGrid = (Grid*)geometryTab->widget(0);
    int numberOfCells = lenghtGrid->columnCount();
    std::string timeValue = timeEdit->text().toStdString();
    kernelConfigurator->plotGridPressure(timeValue, numberOfCells);

  } else if (cellPressureRadio->isChecked()) {
    std::string nCell = cellNumberEdit->text().toStdString();

    kernelConfigurator->plotCellPressure(nCell);
  }
}

/**************************************************************************//**
** Run the simulation by executing the kernel's run.
**
** \note private slot
******************************************************************************/
void MainWindow::run() {
  if (canRunSimulation()) {
    QMessageBox msgBox;
    msgBox.setText("The simulation will run now.");
    msgBox.setIcon(QMessageBox::Information);
    msgBox.exec();

    kernelConfigurator->runKernel();

    //make plot available
    plotAction->setDisabled(false);
  }
}

/**************************************************************************//**
** Generates the configuration Files that are going to be used by the kernel.
**
** \note private slot
******************************************************************************/
void MainWindow::generateConfigurationFiles() {
  if (canRunSimulation()) {
    kernelConfigurator->generateKernelConfigurationFiles();

    QPushButton* runKernelButton = new QPushButton(tr("run Simulation"));

    QMessageBox msgBox;
    msgBox.setText("Configuration files have been generated.");
    msgBox.setIcon(QMessageBox::Information);
    msgBox.addButton(runKernelButton, QMessageBox::AcceptRole);
    msgBox.setStandardButtons(QMessageBox::Ok);
    int res = msgBox.exec();

    if (res == QMessageBox::AcceptRole)
      run();
  }
}

/**************************************************************************//**
** Set the value of left boundary if condition is met.
**
** \note private slot
******************************************************************************/
void MainWindow::changeLeftBoundaryValue(const QString& text) {
  if (text == "Closed System") {
    leftBoudaryValueEdit->setText("0");
    leftBoudaryValueEdit->setDisabled(true);
  } else {
    leftBoudaryValueEdit->setText("");
    leftBoudaryValueEdit->setDisabled(false);
  }
}

/**************************************************************************//**
** Set the value of right boundary if condition is met.
**
** \note private slot
******************************************************************************/
void MainWindow::changeRightBoundaryValue(const QString& text) {
  if (text == "Closed System") {
    rightBoudaryValueEdit->setText("0");
    rightBoudaryValueEdit->setDisabled(true);
  } else {
    rightBoudaryValueEdit->setText("");
    rightBoudaryValueEdit->setDisabled(false);
  }
}

/**************************************************************************//**
** Verify if simulation can run.
** \return true whether it can run or not.
******************************************************************************/
bool MainWindow::canRunSimulation() {
  bool blocksNotCreated = (blockPropertiesStackedWidget == nullptr);
  bool wellsNotCreated =  (wellPropertiesStackedWidget == nullptr);

  if (blocksNotCreated && wellsNotCreated) {
    QMessageBox msgBox;
    msgBox.setText("Must create blocks and wells first.");
    msgBox.setIcon(QMessageBox::Critical);
    msgBox.exec();

    return false;
  } else if (blocksNotCreated) {
    QMessageBox msgBox;
    msgBox.setText("Must create blocks first.");
    msgBox.setIcon(QMessageBox::Critical);
    msgBox.exec();

    return false;
  } else if (wellsNotCreated) {
    QMessageBox msgBox;
    msgBox.setText("Must create wells first.");
    msgBox.setIcon(QMessageBox::Critical);
    msgBox.exec();

    return false;
  }

  return true;
}