#ifndef START_DIALOG_H
#define START_DIALOG_H

#include <QMainWindow>
#include <QDialog>
#include <string>
#include <map>

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
  void dialogFinished(std::string, std::string, std::map<std::string, std::string>, 
                      int nRows, int nColumns);

private:
  QGroupBox* createGridModels();
  QGroupBox* createPhaseModels();
  QGroupBox* createPhasesBox();
  QGroupBox* createGridLayoutBox();

  std::string getGridModelChosen();
  std::string getPhaseModelChosen();
  std::map<std::string, std::string> getPhaseTypeChosen();

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