import sys

from PyQt5 import QtWidgets
from FlexibleRobot import FlexibleRobot


# Main function
def main():
    app = QtWidgets.QApplication(sys.argv)

    robot = FlexibleRobot()

    sys.exit(app.exec_())
    

# Application startup
if __name__ == '__main__':
  
    main()