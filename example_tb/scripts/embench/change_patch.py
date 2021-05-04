#
#   Copyright 2022 ETH Zurich
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
#
#
#
#   Description: This script is used by the makefile to adapt the original.patch file
#                with the correct paths. The generated tmp.patch file is
#                then applied to the embench-iot repository. (patch ensures that
#                programs can be built successfully)
#
#
#   Contributer: Moritz Imfeld moimfeld@student.ethz.ch
#


import os


# Read in the file
with open('../../scripts/embench/original.patch', 'r') as file :
  filedata = file.read()

# Replace the target string
filedata = filedata.replace('RTL_BASE', os.environ['RTLSRC_HOME'])
filedata = filedata.replace('DEF_MARCH', os.environ['MARCH'])
filedata = filedata.replace('DEF_MABI', os.environ['MABI'])
filedata = filedata.replace('COMPILER', os.environ['RISCV_EXE_PREFIX']+'gcc')
filedata = filedata.replace('INCLUDE_DIR', os.environ['RISCV_EXE_PREFIX'][:-1]+'/include')
# Write the file out again
with open('../../scripts/embench/tmp.patch', 'w') as file:
  file.write(filedata)