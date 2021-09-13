from PyQt5 import QtCore, QtWidgets, QtGui
import numpy as np
from ctypes import Structure, sizeof
import pyads
import time
from enum import Enum

import pyqtgraph as pg


from RealTimePlot import RealTimePlot

from Ui_MainWindow import Ui_MainWindow

PLC_IP_ADDRESS = "192.168.0.10" #"127.0.0.1"
PLC_NETID = "5.72.215.242.1.1" #"127.0.0.1.1.1"

class E_RobotMode(Enum):
  ESTOP = 0
  STOP = 1
  POSITION = 2
  VELOCITY = 3
  TORQUE = 4



class FlexibleRobot(QtWidgets.QMainWindow, Ui_MainWindow):
  
  enableModeChangeFromHmi = False;

  signal_bEStopOK = QtCore.pyqtSignal(bool)
  signal_bEStopError = QtCore.pyqtSignal(bool)
  signal_bRobotStatus = QtCore.pyqtSignal(bool)
  signal_fAxis_Joint1 = QtCore.pyqtSignal(float)
  signal_fAxis_Joint2 = QtCore.pyqtSignal(float)
  signal_fAxis_Joint3 = QtCore.pyqtSignal(float)


  signal_bPositionMode = QtCore.pyqtSignal(bool)
  signal_bVelocityMode = QtCore.pyqtSignal(bool)
  signal_bTorqueMode = QtCore.pyqtSignal(bool)


  def __init__(self):
    super().__init__()
    self.gui = Ui_MainWindow()
    self.gui.setupUi(self)
    self.show()
    self.plcActive = False
 
    # Setup plot area
    self.setupPlot()
    # Plot timer
    self.t0 = time.time()
    self.timer_plot = QtCore.QTimer()
    self.timer_plot.timeout.connect(self.update)
    self.timer_plot.start(50)

    

    #Connect only when connect gui button is pressed
    self.plc = self.plcOpen()
    try:
      self.plcActive = self.plc.is_open

    except pyads.ADSError:
      self.plcActive = False

    if self.plcActive:
      print("GUI connected")
    else:
      print("GUI not connected")



    # Set the joint values to current joint values
    self.gui.doubleSpinBox_SetJoint1Velocity.setValue(self.plc.read_by_name('HmiToPlc.fVelInput[0]',pyads.PLCTYPE_LREAL))
    self.gui.doubleSpinBox_SetJoint2Velocity.setValue(self.plc.read_by_name('HmiToPlc.fVelInput[1]',pyads.PLCTYPE_LREAL))
    self.gui.doubleSpinBox_SetJoint3Velocity.setValue(self.plc.read_by_name('HmiToPlc.fVelInput[2]',pyads.PLCTYPE_LREAL))


    # Set the joint values to current joint values
    self.gui.doubleSpinBox_SetJoint1Position.setValue(self.plc.read_by_name('HmiToPlc.fPosInput[0]',pyads.PLCTYPE_LREAL))
    self.gui.doubleSpinBox_SetJoint2Position.setValue(self.plc.read_by_name('HmiToPlc.fPosInput[1]',pyads.PLCTYPE_LREAL))
    self.gui.doubleSpinBox_SetJoint3Position.setValue(self.plc.read_by_name('HmiToPlc.fPosInput[2]',pyads.PLCTYPE_LREAL))


    # Connect to slot
    self.gui.doubleSpinBox_SetJoint1Velocity.valueChanged.connect(self.slot_SetJoint1Velocity)
    self.gui.doubleSpinBox_SetJoint2Velocity.valueChanged.connect(self.slot_SetJoint2Velocity)
    self.gui.doubleSpinBox_SetJoint3Velocity.valueChanged.connect(self.slot_SetJoint3Velocity)


    # Connect to slot
    self.gui.doubleSpinBox_SetJoint1Position.valueChanged.connect(self.slot_SetJoint1Position)
    self.gui.doubleSpinBox_SetJoint2Position.valueChanged.connect(self.slot_SetJoint2Position)
    self.gui.doubleSpinBox_SetJoint3Position.valueChanged.connect(self.slot_SetJoint3Position)



    self.gui.pushButton_ResetEStop.pressed.connect(self.slot_pressed_bEStopRestart)
    self.gui.pushButton_AckSafetyGroup.pressed.connect(self.slot_pressed_bGroupPort_ErrAck)
    self.gui.pushButton_SafetyDriveAxisReset.pressed.connect(self.slot_pressed_bDrive_Axis_ErrReset)

    # self.gui.pushButton_ResetEStop.released.connect(self.slot_released_bEStopRestart)
    # self.gui.pushButton_AckSafetyGroup.released.connect(self.slot_released_bGroupPort_ErrAck)
    # self.gui.pushButton_SafetyDriveAxisReset.released.connect(self.slot_released_bDrive_Axis_ErrReset)


    self.gui.pushButton_PositionMode.pressed.connect(self.slot_bPositionModeCmd)
    self.gui.pushButton_VelocityMode.pressed.connect(self.slot_bVelocityModeCmd) #send command on statechange
    self.gui.pushButton_TorqueMode.pressed.connect(self.slot_bTorqueModeCmd)

    self.gui.pushButton_PowerOnRobot.setText("")
    self.gui.pushButton_PowerOnRobot.setIcon(QtGui.QIcon(QtGui.QPixmap('led-images/power-green.png')))
    self.gui.pushButton_PowerOnRobot.setIconSize(QtCore.QSize(150, 150))
    self.gui.pushButton_PowerOnRobot.pressed.connect(self.slot_pressed_bPowerOnRobot)



    self.gui.pushButton_ResetRobot.setText("")
    self.gui.pushButton_ResetRobot.setIcon(QtGui.QIcon(QtGui.QPixmap('led-images/reset-orange.png')))
    self.gui.pushButton_ResetRobot.setIconSize(QtCore.QSize(80, 80))
    self.gui.pushButton_ResetRobot.pressed.connect(self.slot_pressed_bResetRobot)
#    self.gui.pushButton_ResetRobot.released.connect(self.slot_released_bResetRobot)



    self.gui.pushButton_Stop.setText("")
    self.gui.pushButton_Stop.setIcon(QtGui.QIcon(QtGui.QPixmap('led-images/power-red.png')))
    self.gui.pushButton_Stop.setIconSize(QtCore.QSize(150, 150))
    self.gui.pushButton_Stop.pressed.connect(self.slot_pressed_bStop) 
    # self.gui.pushButton_Stop.released.connect(self.slot_released_bStop)


    self.gui.pushButton_PositionModeExecute.pressed.connect(self.slot_pressed_bPositionModeExecute) 
    # self.gui.pushButton_PositionModeExecute.released.connect(self.slot_released_bPositionModeExecute)

    # PLC -> SIGNAL
    self.plcNotification('PlcToHmi.bAnyJointActive', pyads.PLCTYPE_BOOL, self.signal_bRobotStatus)
    self.plcNotification('PlcToHmi.bSafety_EStopOK', pyads.PLCTYPE_BOOL, self.signal_bEStopOK)
    self.plcNotification('PlcToHmi.bSafety_EStopError', pyads.PLCTYPE_BOOL, self.signal_bEStopError)

    self.plcNotification('PlcToHmi.fPosFb[0]', pyads.PLCTYPE_LREAL, self.signal_fAxis_Joint1)
    self.plcNotification('PlcToHmi.fPosFb[1]', pyads.PLCTYPE_LREAL, self.signal_fAxis_Joint2)
    self.plcNotification('PlcToHmi.fPosFb[2]', pyads.PLCTYPE_LREAL, self.signal_fAxis_Joint3)


    self.plcNotification('PlcToHmi.bPositionMode', pyads.PLCTYPE_BOOL, self.signal_bPositionMode) ##plc to hmi signal
    self.plcNotification('PlcToHmi.bVelocityMode', pyads.PLCTYPE_BOOL, self.signal_bVelocityMode)
    self.plcNotification('PlcToHmi.bTorqueMode', pyads.PLCTYPE_BOOL, self.signal_bTorqueMode)





    # SIGNAL -> SLOT
    self.signal_bRobotStatus.connect(self.slot_bRobotStatus)
    self.signal_bEStopOK.connect(self.slot_bEStopOK)
    self.signal_bEStopError.connect(self.slot_bEStopError)
    self.signal_fAxis_Joint1.connect(self.slot_fAxis_Joint1)
    self.signal_fAxis_Joint2.connect(self.slot_fAxis_Joint2)
    self.signal_fAxis_Joint3.connect(self.slot_fAxis_Joint3)




    self.signal_bPositionMode.connect(self.slot_bPositionMode) #hmi signal to slot
    self.signal_bVelocityMode.connect(self.slot_bVelocityMode)
    self.signal_bTorqueMode.connect(self.slot_bTorqueMode)


    #Check the status of e-stop
    status = (self.plc.read_by_name('PlcToHmi.bSafety_EStopOK', pyads.PLCTYPE_BOOL)) and not(self.plc.read_by_name('PlcToHmi.bSafety_EStopError', pyads.PLCTYPE_BOOL))
    if status:
        self.gui.label_EStopPressed.setPixmap(QtGui.QPixmap('led-images/led-green.png').scaled(50, 50, QtCore.Qt.KeepAspectRatio, QtCore.Qt.FastTransformation))
        self.gui.label_EStopPressed.adjustSize()
    else: 
        self.gui.label_EStopPressed.setPixmap(QtGui.QPixmap('led-images/led-red.png').scaled(50, 50, QtCore.Qt.KeepAspectRatio, QtCore.Qt.FastTransformation))
        self.gui.label_EStopPressed.adjustSize() 
    

    #Check the status of Robot
    status = (self.plc.read_by_name('PlcToHmi.bAnyJointActive', pyads.PLCTYPE_BOOL))
    if status:
        self.gui.label_RobotStatus.setPixmap(QtGui.QPixmap('led-images/led-green.png').scaled(50, 50, QtCore.Qt.KeepAspectRatio, QtCore.Qt.FastTransformation))
        self.gui.label_RobotStatus.adjustSize()
        self.enableModeChangeFromHmi = False;
    else: 
        self.gui.label_RobotStatus.setPixmap(QtGui.QPixmap('led-images/led-red.png').scaled(50, 50, QtCore.Qt.KeepAspectRatio, QtCore.Qt.FastTransformation))
        self.gui.label_RobotStatus.adjustSize()
        self.enableModeChangeFromHmi = True; 
    


  @QtCore.pyqtSlot(bool)
  def slot_bRobotStatus(self, value):
    if value:
        self.gui.label_RobotStatus.setPixmap(QtGui.QPixmap('led-images/led-green.png').scaled(50, 50, QtCore.Qt.KeepAspectRatio, QtCore.Qt.FastTransformation))
        self.gui.label_RobotStatus.adjustSize()
        self.enableModeChangeFromHmi = False
    else: 
        self.gui.label_RobotStatus.setPixmap(QtGui.QPixmap('led-images/led-red.png').scaled(50, 50, QtCore.Qt.KeepAspectRatio, QtCore.Qt.FastTransformation))
        self.gui.label_RobotStatus.adjustSize() 
        self.enableModeChangeFromHmi = True





  @QtCore.pyqtSlot(bool)
  def slot_bEStopOK(self, value):
    if value:
        self.gui.label_EStopPressed.setPixmap(QtGui.QPixmap('led-images/led-green.png').scaled(50, 50, QtCore.Qt.KeepAspectRatio, QtCore.Qt.FastTransformation))
        self.gui.label_EStopPressed.adjustSize() 

    else:
        self.gui.label_EStopPressed.setPixmap(QtGui.QPixmap('led-images/led-red.png').scaled(50,50, QtCore.Qt.KeepAspectRatio, QtCore.Qt.FastTransformation))
        self.gui.label_EStopPressed.adjustSize()



  @QtCore.pyqtSlot(bool)
  def slot_bEStopError(self, value):
    if value:
        self.gui.label_EStopPressed.setPixmap(QtGui.QPixmap('led-images/led-red.png').scaled(50,50, QtCore.Qt.KeepAspectRatio, QtCore.Qt.FastTransformation))
        self.gui.label_EStopPressed.adjustSize() 

  @QtCore.pyqtSlot()
  def slot_pressed_bEStopRestart(self): 
    self.plc.write_by_name('HmiToPlc.bSafety_EStopRestart', True, pyads.PLCTYPE_BOOL)

  # @QtCore.pyqtSlot()
  # def slot_released_bEStopRestart(self):
  #   self.plc.write_by_name('HmiToPlc.bSafety_EStopRestart', False, pyads.PLCTYPE_BOOL)


  @QtCore.pyqtSlot()
  def slot_pressed_bPowerOnRobot(self):
    self.plc.write_by_name('HmiToPlc.bEnable', True, pyads.PLCTYPE_BOOL)



  @QtCore.pyqtSlot()
  def slot_pressed_bStop(self): 
    self.plc.write_by_name('HmiToPlc.bSoftStop', True, pyads.PLCTYPE_BOOL)



  # @QtCore.pyqtSlot()
  # def slot_released_bStop(self):
  #   self.plc.write_by_name('HmiToPlc.bSoftStop', False, pyads.PLCTYPE_BOOL)

  @QtCore.pyqtSlot()
  def slot_pressed_bPositionModeExecute(self): 
    self.plc.write_by_name('HmiToPlc.bPositionModeExecute', True, pyads.PLCTYPE_BOOL)

    

  # @QtCore.pyqtSlot()
  # def slot_released_bPositionModeExecute(self):
  #   self.plc.write_by_name('HmiToPlc.bPositionModeExecute', False, pyads.PLCTYPE_BOOL)

  @QtCore.pyqtSlot()
  def slot_pressed_bGroupPort_ErrAck(self):  
    self.plc.write_by_name('HmiToPlc.bSafety_GroupPort_ErrAck', True, pyads.PLCTYPE_BOOL)

  # @QtCore.pyqtSlot()
  # def slot_released_bGroupPort_ErrAck(self):
  #   self.plc.write_by_name('HmiToPlc.bSafety_GroupPort_ErrAck', False, pyads.PLCTYPE_BOOL)


  @QtCore.pyqtSlot()
  def slot_pressed_bDrive_Axis_ErrReset(self): 
    self.plc.write_by_name('HmiToPlc.bSafety_Drive_Axis_ErrReset', True, pyads.PLCTYPE_BOOL)

  # @QtCore.pyqtSlot()
  # def slot_released_bDrive_Axis_ErrReset(self):
  #   self.plc.write_by_name('HmiToPlc.bSafety_Drive_Axis_ErrReset', False, pyads.PLCTYPE_BOOL)

  @QtCore.pyqtSlot()
  def slot_pressed_bResetRobot(self): 
    self.plc.write_by_name('HmiToPlc.bReset', True, pyads.PLCTYPE_BOOL)

  # @QtCore.pyqtSlot()
  # def slot_released_bResetRobot(self): 
  #   self.plc.write_by_name('HmiToPlc.bReset', False, pyads.PLCTYPE_BOOL)



  @QtCore.pyqtSlot(float)
  def slot_fAxis_Joint1(self,value):
    self.gui.lcdNumber_CurrentJoint1.display(value)


  @QtCore.pyqtSlot(float)
  def slot_fAxis_Joint2(self,value):
    self.gui.lcdNumber_CurrentJoint2.display(value)

  @QtCore.pyqtSlot(float)
  def slot_fAxis_Joint3(self,value):
    self.gui.lcdNumber_CurrentJoint3.display(value)










  @QtCore.pyqtSlot()
  def slot_bPositionModeCmd(self):
    if self.enableModeChangeFromHmi:
      self.plc.write_by_name('HmiToPlc.bPositionMode', True, pyads.PLCTYPE_BOOL)

  @QtCore.pyqtSlot()
  def slot_bVelocityModeCmd(self):
    if self.enableModeChangeFromHmi:
      self.plc.write_by_name('HmiToPlc.bVelocityMode', True, pyads.PLCTYPE_BOOL)

  @QtCore.pyqtSlot()
  def slot_bTorqueModeCmd(self):
    if self.enableModeChangeFromHmi:
      self.plc.write_by_name('HmiToPlc.bTorqueMode', True, pyads.PLCTYPE_BOOL)


  @QtCore.pyqtSlot(bool)
  def slot_bVelocityMode(self,value):      
      self.gui.checkBox_VelocityMode.setChecked(value)


  @QtCore.pyqtSlot(bool)
  def slot_bPositionMode(self,value):
      self.gui.checkBox_PositionMode.setChecked(value)


  @QtCore.pyqtSlot(bool)
  def slot_bTorqueMode(self,value):      
      self.gui.checkBox_TorqueMode.setChecked(value)


  @QtCore.pyqtSlot(float)
  def slot_SetJoint1Velocity(self,value):
    self.plc.write_by_name('HmiToPlc.fVelInput[0]', value, pyads.PLCTYPE_LREAL)

  @QtCore.pyqtSlot(float)
  def slot_SetJoint2Velocity(self,value):
    self.plc.write_by_name('HmiToPlc.fVelInput[1]', value, pyads.PLCTYPE_LREAL)

  @QtCore.pyqtSlot(float)
  def slot_SetJoint3Velocity(self,value):
    self.plc.write_by_name('HmiToPlc.fVelInput[2]', value, pyads.PLCTYPE_LREAL)




  @QtCore.pyqtSlot(float)
  def slot_SetJoint1Position(self,value):
    self.plc.write_by_name('HmiToPlc.fPosInput[0]', value, pyads.PLCTYPE_LREAL)

  @QtCore.pyqtSlot(float)
  def slot_SetJoint2Position(self,value):
    self.plc.write_by_name('HmiToPlc.fPosInput[1]', value, pyads.PLCTYPE_LREAL)

  @QtCore.pyqtSlot(float)
  def slot_SetJoint3Position(self,value):
    self.plc.write_by_name('HmiToPlc.fPosInput[2]', value, pyads.PLCTYPE_LREAL)


  def plcOpen(self):
    ip_address = PLC_IP_ADDRESS
    netId = PLC_NETID
    port = 851
    plc = pyads.Connection(netId,port)
    plc.ip_address = ip_address
    plc.open()
    
    return plc



      
  def setupPlot(self):
    self.plotAngles = RealTimePlot(self.gui.graphicsLayoutWidget_JointAnglePlot.addPlot())
    self.plotAngles.plot.setLabel('left', 'Angles', 'deg')
    self.plotAngles.plot.setYRange(-180, 180)
    self.plotAngles.add_curves(
        ['r', 'g', 'b'],
        ['q1', 'q2', 'q3']
    )

  def update(self):
    if self.plcActive:
      q = np.array([self.plc.read_by_name('PlcToHmi.fPosFb[0]',pyads.PLCTYPE_LREAL),
        self.plc.read_by_name('PlcToHmi.fPosFb[1]',pyads.PLCTYPE_LREAL),
        self.plc.read_by_name('PlcToHmi.fPosFb[2]',pyads.PLCTYPE_LREAL)
      ])

      # Plot
      t = time.time() - self.t0
      self.plotAngles.update(t, q)


  # def ReadMV(self):
  #   x = self.plc.read_by_name('GVL.Axis1.NcToPlc.ActPos', pyads.PLCTYPE_LREAL)

  #   @self.plc.notification(pyads.PLCTYPE_LREAL)
  #   def callback1(handle, name, timestamp, value):
  #     dt = 0.010
  #     self.t1.append(self.i1*dt)
  #     self.pos.append(value)
  #     self.i1 = self.i1 + 1
  #   handle1 = plc.add_device_notification(ads_var1,pyads.NotificationAttrib(sizeof(ads_type1)),callback1)

  def plcNotification(self, adsName, plcType, pyqtSignal):
    # General callback function
    @self.plc.notification(plcType)
    def callback(handle, name, timestamp, value):
      pyqtSignal.emit(value)
      pass    

    attrib = pyads.NotificationAttrib(sizeof(plcType),pyads.ADSTRANS_SERVERONCHA, 
      max_delay=10, # Max delay in ms
      cycle_time=100 # Cycle time in ms
    )

    # Add notification to ads
    self.plc.add_device_notification(
        adsName,
        attrib,
        callback
    )
    