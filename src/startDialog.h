#ifndef START_DIALOG_H
#define START_DIALOG_H

#include <QMainWindow>
#include <QDialog>
#include <string>
#include <map>
#include "fluid_definitions.h"

class QGroupBox;
class QRadioButton;
class QComboBox;
class QSpinBox;

class StartDialog : public QDialog
{
  Q_OBJECT

public:
  explicit StartDialog(QWidget *parent = 0);
  ~StartDialog() {};

  void show();

private slots:
  void allowTwoDiminsional(bool);
  void emitSignal();

signals:
  void dialogFinished(std::string, std::string, std::map<std::string, FluidType>,
                      int nRows, int nColumns);

private:
  QGroupBox* createGridModels();
  QGroupBox* createPhaseModels();
  QGroupBox* createPhasesBox();
  QGroupBox* createGridLayoutBox();

  std::string getGridModelChosen();
  std::string getPhaseModelChosen();
  std::map<std::string, FluidType> getPhaseTypeChosen();
  FluidType convertStringToFluidType(QComboBox*);

  QRadioButton *oneDimensionalRadio;
  QRadioButton *twoDimensionalRadio;
  QRadioButton *threeDimensionalRadio;
  QRadioButton *singlePhaseRadio;
  QRadioButton *twoPhaseRadio;
  QRadioButton *threePhaseRadio;

  QComboBox* phaseOne;
  QComboBox* phaseTwo;
  QComboBox* phaseThree;

  QSpinBox* rows;
  QSpinBox* columns;
};

#endif // START_DIALOG_H