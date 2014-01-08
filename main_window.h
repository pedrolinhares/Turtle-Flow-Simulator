#ifndef MAIN_WINDOW_H
#define MAIN_WINDOW_H

#include <QMainWindow>
#include "grid.h"
#include "startDialog.h"
#include "fluid_dialog.h"

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
  void createRockInnerDialog();

private:
  void createActions();
  void createMenus();
  void setUpToolBox();
  QGroupBox* createBlockProperties();

  int nToolboxItems = 0;
  QMenu* fileMenu;
  QAction* newProjectAct;
  QAction* closeAct;
  QStackedWidget* tabedContent;
  QTabWidget* geometryTab;
  QTabWidget* rockTab;
  QTabWidget* fluidTab;
  QWidget *centralWidget;
  QWidget *rockWidget;
  QSpinBox* rows;
  QSpinBox* columns;
  QSpinBox* pvtSpinBox;
  QToolBox* toolBox;
  QVBoxLayout *gridLayout;
  QVBoxLayout *toolBoxLayout;
  QVBoxLayout *rockInnerLayout;
  QLineEdit *numberOfBlocksEdit;
  StartDialog *startDialog;
  FluidDialog *fluidDialog;

  QStackedWidget *blockPropertiesStackedWidget;
};

#endif // MAIN_WINDOW_H
