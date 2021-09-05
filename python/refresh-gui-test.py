#!/usr/bin/env python3

import sys
import time
import threading

TTK = False

try:
  from tkinter import *
  try:
    from tkinter.ttk import *
    TTK = True
  except ModuleNotFoundError:
    pass
except ModuleNotFoundError:
  exit(1)

APP_NAME = 'Random Program Name'

paddingX = 5
paddingY = 5


class WrapWriter(object):
  def __init__(self, writer):
    self.writer = writer

  def write(self, string):
    self.writer.insert('end', string)
    self.writer.see('end')

  def flush(self):
    pass


class RefreshGUI(object):
  def __init__(self, parent):
    self.parent = parent
    self.colIdx = 0
    self.rowIdx = 0
    self.acceptInput = True
    self.create_widgets()

  def getCol(self, add):
    self.colIdx += add
    return self.colIdx

  def getRow(self, add):
    self.rowIdx += add
    return self.rowIdx

  def create_widgets(self):
    label1 = Label(self.parent, text = APP_NAME)
    label1.grid(
      column = self.getCol(0), row = self.getRow(0),
      columnspan = 2, sticky = 'w',
      padx = paddingX)

    labelFrame1 = LabelFrame(self.parent, text = 'stdout')
    labelFrame1.grid(
      column = self.getCol(0), row = self.getRow(1),
      columnspan = 2, sticky = 'nsew',
      padx = paddingX, pady = paddingY)
    labelFrame1.columnconfigure(0, weight = 1)
    labelFrame1.rowconfigure(0, weight = 1)

    self.output = Text(
      labelFrame1,
      relief = 'solid', wrap = 'word',
      height = 20, width = 100)
    self.output.grid(column = 0, row = 0, sticky = 'nsew')

    # set stdout to our new writer.
    sys.stdout = WrapWriter(self.output)

    labelFrame2 = LabelFrame(self.parent, text = 'Password (not saved)')
    labelFrame2.grid(
      column = self.getCol(0), row = self.getRow(1),
      sticky = 'nsew',
      padx = paddingX, pady = paddingY)
    labelFrame2.columnconfigure(0, weight = 1)

    self.entry = Entry(labelFrame2, state = 'disabled', show = '**')
    self.entry.grid(column = 0, row = 0, sticky = 'nsew')

    self.button = Button(
      labelFrame2,
      text = 'Submit',
      state = 'disabled',
      command = self.submit)
    self.button.grid(column = 1, row = 0, sticky = 'w')

    self.parent.columnconfigure(0, weight = 1)
    self.parent.rowconfigure(1, weight = 1)

  def submit(self):
    # atomicsssssssss no
    self.waitOnInput = False

  def getInput(self):
    # enable our entry box and submit button
    self.entry.config(state = 'normal')
    self.button.config(state = 'normal')

    # get focus next time window is active
    self.entry.focus_set()

    # i am not aware of python's thread rules.
    # how do you atomic on python?
    self.waitOnInput = True
    while self.waitOnInput:
      if not self.acceptInput:
        return None
      # sleep 100ms between loops
      time.sleep(0.1)

    # get the text entry of
    text = self.entry.get()

    # delete the text from the buffer
    self.entry.delete(0, 'end')

    # disable our entry box and button
    self.entry.config(state = 'disabled')
    self.button.config(state = 'disabled')

    return text


class App(threading.Thread):
  def __init__(self, gui):
    threading.Thread.__init__(self)
    self.gui = gui

  def run(self):
    passwd = self.gui.getInput()
    if passwd != None:
      print(passwd)


root = Tk()
root.title(APP_NAME)
root.protocol('WM_DELETE_WINDOW', root.quit)

gui = RefreshGUI(root)

a = App(gui)

root.after(500, a.start)
root.mainloop()
gui.acceptInput = False
