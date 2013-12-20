#include <QtWidgets>
#include <QTableWidget>
#include <iostream>
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

  setWindowTitle(tr("Interface"));
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

  QLineEdit* test = new QLineEdit;
  QLabel* testLabel = new QLabel(tr("teste"));
  testLabel->setBuddy(test);

  toolBox->insertItem(0, test, tr("Teste"));

  QLineEdit* test2 = new QLineEdit;
  QLabel* testLabel2 = new QLabel(tr("teste 2"));
  testLabel2->setBuddy(test2);

  toolBox->insertItem(1, test2, tr("Teste 2"));

  nToolboxItems = toolBox->count();
  toolBoxLayout->addWidget(toolBox);
}

//private slots

void MainWindow::toolTabChanged(int index) {}

void MainWindow::newProject() {
  startDialog->show();
 }

void MainWindow::createGrid(std::string dimension, std::string nPhases,
                            std::map<std::string, std::string> typeOfphases, int nRows, int nColumns) {
  setUpToolBox();

  if (!gridLayout->isEmpty()) {
    gridLayout->removeWidget(grids);
    delete grids;
  }

  grids = new QStackedWidget;

  //connects toolbox to the grid to change its content
  connect(toolBox, SIGNAL(currentChanged(int)), grids, SLOT(setCurrentIndex(int)));

  for (int i = 0; i < nToolboxItems; ++i) {
    if (dimension == "oneDimensional")
      grids->addWidget(new Grid(1, nColumns, this));
    else
      grids->addWidget(new Grid(nRows, nColumns, this));
  }

  gridLayout->addWidget(grids);
}
