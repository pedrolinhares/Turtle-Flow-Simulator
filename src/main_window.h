/** \file main_window.h */

#ifndef MAIN_WINDOW_H
#define MAIN_WINDOW_H

#include <QMainWindow>
#include <map>
#include "grid.h"
#include "startDialog.h"
#include "fluid_dialog.h"

class QMenu;
class QAction;
class QWidget;
class QSpinBox;
class QToolBox;
class QVBoxLayout;
class QHBoxLayout;
class QStackedWidget;

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
  void generateConfigurationFiles();

private:
  void createActions();
  void createMenus();
  void setUpToolBox();
  void createGeometryFile();
  void createBlockFile();
  void createFluidFile();
  void createWellsFile();
  void createSolutionFile();
  void createArqResFile();
  void createNumericPropertiesFile();
  bool canRunSimulation();
  QGroupBox* createBlockProperties();
  QGroupBox* createWellProperties();
  QHBoxLayout* createGeometryLayout();
  QVBoxLayout* createRockLayout();
  QVBoxLayout* createFluidLayout();
  QVBoxLayout* createWellLayout();
  QVBoxLayout* createNumericPropertiesLayout();
  QVBoxLayout* createSolutionInitializationLayout();

  int nToolboxItems = 0;
  QMenu* fileMenu;
  QMenu* actionsMenu;
  QAction* newProjectAct;
  QAction* closeAct;
  QAction* runAction;
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
  StartDialog *startDialog;
  FluidDialog *fluidDialog;

  QStackedWidget *blockPropertiesStackedWidget = nullptr;
  QStackedWidget *wellPropertiesStackedWidget = nullptr;
  std::map<std::string, FluidType> typeOfphases;
};

#endif // MAIN_WINDOW_H
