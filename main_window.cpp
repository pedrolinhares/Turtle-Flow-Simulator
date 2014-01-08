#include <QtWidgets>
#include <QTableWidget>
#include <QDoubleValidator>
#include <iostream>
#include <string>
#include "main_window.h"

MainWindow::MainWindow(QWidget *parent) : QMainWindow(parent) {
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
          SIGNAL(dialogFinished(std::string, std::string, std::map<std::string, std::string>, int, int)),
          this, SLOT(createGrid(std::string, std::string, std::map<std::string, std::string>, int, int)));

  setWindowTitle(tr("Simulator"));
  setMinimumSize(200, 200);
  resize(1200, 800);
}

MainWindow::~MainWindow() {
}

void MainWindow::createActions() {
  newProjectAct = new QAction(tr("&New simulation"), this);
  newProjectAct->setStatusTip(tr("Creates a new simulation"));
  connect(newProjectAct, SIGNAL(triggered()), this, SLOT(newProject()));

  //Close Action
    closeAct = new QAction(tr("&Quit"), this);
    closeAct->setShortcut(tr("Ctrl+Q"));
    closeAct->setStatusTip(tr("Quit the application"));

    connect(closeAct, SIGNAL(triggered()), qApp, SLOT(closeAllWindows()));
}

void MainWindow::createMenus() {
  fileMenu = menuBar()->addMenu(tr("&File"));
  fileMenu->addAction(newProjectAct);
  fileMenu->addSeparator();
  fileMenu->addAction(closeAct);
}

void MainWindow::setUpToolBox() {
  if(!toolBoxLayout->isEmpty()) {
    toolBoxLayout->removeWidget(toolBox);
    delete toolBox;
  }

  toolBox = new QToolBox;
  toolBox->setMaximumWidth(250);

  QWidget *test = new QWidget;

  toolBox->insertItem(0, test, tr("Geometria"));

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

  rockWidget = new QWidget(this);
  rockWidget->setLayout(rockLayout);


  toolBox->insertItem(1, rockWidget, tr("Rock"));

  QWidget *fluidTabContent = new QWidget;

  QHBoxLayout *pvtPointsLayout = new QHBoxLayout;

  pvtSpinBox = new QSpinBox;
  pvtSpinBox->setMinimum(1);

  QLabel *pvtLabel = new QLabel(tr("Number of PVT Points: "));
  pvtLabel->setBuddy(pvtSpinBox);

  pvtPointsLayout->addWidget(pvtLabel);
  pvtPointsLayout->addWidget(pvtSpinBox);
  pvtPointsLayout->setAlignment(Qt::AlignTop);

  fluidTabContent->setLayout(pvtPointsLayout);

  toolBox->insertItem(2, fluidTabContent, tr("Fluid"));

  QWidget *propertiesTab = new QWidget;

  toolBox->insertItem(3, propertiesTab, tr("Numeric Properties"));

  nToolboxItems = toolBox->count();
  toolBoxLayout->addWidget(toolBox);
}

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

  vbox->addLayout(layout1);
  vbox->addLayout(layout2);
  vbox->addLayout(layout3);

  vbox->setAlignment(Qt::AlignTop);
  groupBox->setLayout(vbox);

  return groupBox;
}

//private slots

void MainWindow::toolTabChanged(int index) {}

void MainWindow::newProject() {
  startDialog->show();
 }

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

void MainWindow::createGrid(std::string dimension, std::string nPhases,
                            std::map<std::string, std::string> typeOfphases, 
                            int nRows, int nColumns) {
  setUpToolBox();

  if (!gridLayout->isEmpty()) {
    gridLayout->removeWidget(tabedContent);
    delete tabedContent;
  }

  if (dimension == "oneDimensional")
    nRows = 1;

  tabedContent = new QStackedWidget;

  //connects toolbox to the grid to change its content
  connect(toolBox, SIGNAL(currentChanged(int)), tabedContent, SLOT(setCurrentIndex(int)));

  //create the tabed content for each item from the left toolbox
  //for the geometry tab
  geometryTab = new QTabWidget;

  geometryTab->addTab(new Grid(nRows, nColumns), "Width");
  geometryTab->addTab(new Grid(nRows, nColumns), "Thickness");
  geometryTab->addTab(new Grid(nRows, nColumns), "Depth");

  tabedContent->addWidget(geometryTab);


  //For the rock tab
  rockTab = new QTabWidget;
  rockTab->addTab(new Grid(nRows, nColumns), "Cells");

  tabedContent->addWidget(rockTab);

  //for the fluid tab
  fluidTab = new QTabWidget;

  QDialog *fluidDialog = new FluidDialog(fluidTab);

  connect(pvtSpinBox, SIGNAL(valueChanged(int)), fluidDialog, SLOT(insertRows(int)));

  fluidTab->addTab(fluidDialog, "Fluid Properties");

  tabedContent->addWidget(fluidTab);
  gridLayout->addWidget(tabedContent);
}
