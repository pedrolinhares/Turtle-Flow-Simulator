#ifndef MAIN_WINDOW_H
#define MAIN_WINDOW_H

#include <QMainWindow>
#include "grid.h"
#include "startDialog.h"

class QMenu;
class QAction;
class QWidget;
class QSpinBox;
class QToolBox;
class QVBoxLayout;
class QStackedWidget;

class MainWindow : public QMainWindow {
  Q_OBJECT

public:
  explicit MainWindow(QWidget *parent = 0);
  ~MainWindow();

private slots:
  void newProject();
  void createGrid(std::string, std::string, std::map<std::string, std::string>, int, int);
  void toolTabChanged(int index);

private:
  void createActions();
  void createMenus();
  void setUpToolBox();

  int nToolboxItems = 0;
  QMenu* fileMenu;
  QAction* newProjectAct;
  QAction* closeAct;
  QStackedWidget* grids;
  QWidget *centralWidget;
  QSpinBox* rows;
  QSpinBox* columns;
  QToolBox* toolBox;
  QVBoxLayout *gridLayout;
  QVBoxLayout *toolBoxLayout;
  StartDialog *startDialog;
};

#endif // MAIN_WINDOW_H
