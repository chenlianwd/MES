#!c:\python27\python.exe

import re
import sys
import os

validext = { '.cs', '.c', '.cpp', '.h' }
skipdir = { '.git', '.bzr', 'zlib', 'obj', 'bin', 'MySql.EMTrace', 'Samples', 'v4.x' }
skipfile = { '.Designer.cs' }
num_to_skip = 2
error = False

def process_file(file, banner):
  global error
  with open(file) as f:
    file_content = f.readlines()
    
  if len(file_content) < len(banner):
    print file + " is not large enough"
    return;
        
  # remove the # of lines the user told us to skip
  for x in range(0, num_to_skip):
    file_content.pop(0)
    
  for line in range(0, len(banner)):
    if not banner[line].strip() == file_content[line].strip():
      print filename + ' does not match'
      error = True
      return

def should_skip_dir(dir):
  lower_dir = dir.lower()
  for dir_to_skip in skipdir:
    if lower_dir.find(dir_to_skip.lower()) > -1:
      return True
  return False

def should_skip_file(file):
  lower_file = file.lower()
  for file_to_skip in skipfile:
    if file_to_skip.lower() in lower_file:
      return True
  for ext in validext:
      if file.endswith(ext):
        return False
  return True

      
############################################################
# main prog
############################################################      
if len(sys.argv) < 2:
  print "Not enough arguments"
  sys.exit(1)
license_file = sys.argv[1]  
if not os.path.isfile(license_file):
  print "License file does not exist"
  sys.exit(1)

if len(sys.argv) == 3:
  num_to_skip = int(sys.argv[2])

with open(sys.argv[1]) as f:
  banner_content = f.readlines()

for root, dirs, files in os.walk('.'):
  if should_skip_dir(root):
    continue
  for file in files:
    if should_skip_file(file):
      continue;
    filename = os.path.join(root, file)
    process_file(filename, banner_content)

if error:
  sys.exit(1)

sys.exit(0)

    
    
