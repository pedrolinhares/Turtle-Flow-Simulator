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

  setWindowTitle(tr("Interface"));
  setMinimumSize(200, 200);
  resize(1200, 800);
}

MainWindow::~MainWindow() {
}

void MainWindow::newProject() {
  QDialog *dialog = new QDialog(this);
  QLabel *rowns_label = new QLabel(tr("Linhas: "));
  QLabel *columns_label = new QLabel(tr("colunas: "));

  rows = new QSpinBox;
  columns = new QSpinBox;

  rows->setRange(0, 50);
  rows->setValue(25);
  columns->setRange(0, 50);
  columns->setValue(25);

  rowns_label->setBuddy(rows);
  columns_label->setBuddy(columns);

  QPushButton *ok_button = new QPushButton(tr("Ok"));
  QPushButton *close_button = new QPushButton(tr("Cancelar"));

  ok_button->setDefault(true);

  QHBoxLayout *buttons_layout = new QHBoxLayout;
  buttons_layout->addWidget(ok_button);
  buttons_layout->addWidget(close_button);

  connect(close_button, SIGNAL(clicked()), dialog, SLOT(close()));
  connect(ok_button, SIGNAL(clicked()), this, SLOT(createGrid()));
  connect(ok_button, SIGNAL(clicked()), dialog, SLOT(close()));

  QVBoxLayout* mainLayout = new QVBoxLayout;
  mainLayout->addWidget(rowns_label);
  mainLayout->addWidget(rows);
  mainLayout->addWidget(columns_label);
  mainLayout->addWidget(columns);
  mainLayout->addLayout(buttons_layout);

  dialog->setLayout(mainLayout);

  dialog->show();
}

void MainWindow::createActions() {
  newProjectAct = new QAction(tr("&Novo projeto"), this);
  newProjectAct->setStatusTip(tr("Criar novo projeto"));
  connect(newProjectAct, SIGNAL(triggered()), this, SLOT(newProject()));

  //Close Action
    closeAct = new QAction(tr("&Sair"), this);
    closeAct->setShortcut(tr("Ctrl+Q"));
    closeAct->setStatusTip(tr("Sair da aplicação"));

    connect(closeAct, SIGNAL(triggered()), qApp, SLOT(closeAllWindows()));
}

void MainWindow::createMenus() {
  fileMenu = menuBar()->addMenu(tr("&Arquivo"));
  fileMenu->addAction(newProjectAct);
  fileMenu->addSeparator();
  fileMenu->addAction(closeAct);
}

//private slot
void MainWindow::toolTabChanged(int index) {
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

void MainWindow::createGrid() {
  setUpToolBox();

  if (!gridLayout->isEmpty()) {
    gridLayout->removeWidget(grids);
    delete grids;
  }

  grids = new QStackedWidget;

  //connects toolbox to the grid to change its content
  connect(toolBox, SIGNAL(currentChanged(int)), grids, SLOT(setCurrentIndex(int)));

  for (int i = 0; i < nToolboxItems; ++i) {
    grids->addWidget(new Grid(rows->value(), columns->value(), this));
  }

  gridLayout->addWidget(grids);
}
