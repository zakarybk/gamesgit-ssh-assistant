#!/usr/bin/python

from PyQt5.QtCore import Qt, QTimer
from PyQt5.QtWidgets import *
from PyQt5.QtGui import QPalette, QColor

from selenium import webdriver
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC

import getpass
import subprocess
import re

added_key = False

def games_git_add_ssh(user, ssh_pub, timeout):
    global added_key

    driver = webdriver.Firefox()
    driver.implicitly_wait(1)
    driver.get("https://gamesgit.falmouth.ac.uk/plugins/servlet/ssh/account/keys/add")
    elm_user = driver.find_element_by_name("j_username")
    elm_user.clear()
    elm_user.send_keys(user)

    try:
        wait = WebDriverWait(driver, timeout)
        wait.until(EC.title_contains("Add public key"))

        elm_key = driver.find_element_by_name("text")
        elm_key.send_keys(ssh_pub)

        elm_submit = driver.find_element_by_name("submit")
        elm_submit.click()

        added_key = True
    except:
        print("User took too long to login")
    finally:
        driver.close()

app = QApplication([])

# Dark theme
app.setStyle("Fusion")
dark_palette = QPalette()
dark_palette.setColor(QPalette.Window, QColor(53, 53, 53))
dark_palette.setColor(QPalette.WindowText, Qt.white)
dark_palette.setColor(QPalette.Base, QColor(25, 25, 25))
dark_palette.setColor(QPalette.AlternateBase, QColor(53, 53, 53))
dark_palette.setColor(QPalette.ToolTipBase, Qt.white)
dark_palette.setColor(QPalette.ToolTipText, Qt.white)
dark_palette.setColor(QPalette.Text, Qt.white)
dark_palette.setColor(QPalette.Button, QColor(53, 53, 53))
dark_palette.setColor(QPalette.ButtonText, Qt.white)
dark_palette.setColor(QPalette.BrightText, Qt.red)
dark_palette.setColor(QPalette.Link, QColor(42, 130, 218))
dark_palette.setColor(QPalette.Highlight, QColor(42, 130, 218))
dark_palette.setColor(QPalette.HighlightedText, Qt.black)

app.setPalette(dark_palette)
app.setStyleSheet("QToolTip { color: #ffffff; background-color: #2a82da; border: 1px solid white; }")

def ssh_key_setup():
    output = subprocess.check_output(["./setupssh.sh", getpass.getuser()])
    key = re.search(r'ssh-rsa.*', output.decode("utf-8")).group(0)
    games_git_add_ssh(getpass.getuser(), key, 300)

window = QWidget()
window.setWindowTitle("Falmouth Games Academy GamesGit SSH key setup")
layout = QVBoxLayout()
label = QLabel("Press the button below to setup SSH keys for GamesGit. \n"\
"A window will pop-up where you will need to login in order for the setup to complete!")
layout.addWidget(label)
button = QPushButton('Add SSH Key')
button.clicked.connect(ssh_key_setup)
layout.addWidget(button)
window.setLayout(layout)

def timer_event():
    global added_key
    if added_key:
        label.setText("Congratulations on adding your SSH key!")

window.timer = QTimer()
window.timer.setInterval(1000)
window.timer.timeout.connect(timer_event)
window.timer.start(100)

window.show()
app.exec_()

