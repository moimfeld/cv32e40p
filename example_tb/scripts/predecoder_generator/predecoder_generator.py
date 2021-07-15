#
#   Copyright 2020 ETH Zurich
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
#   Description: This script can create a raw predecoder file for the CV-XIF
#                !!!!!!! The p_writeback, p_is_mem_op, p_use_rs parameters have to be set manually !!!!!!!
#
#                1) To create the predecoder file from an instruction file the instructions have to be of this exact form:
#
#                   	<Instr. Name>     "= 32'b"<instruction data with 0, 1 and ?>   // The number of white spaces can be arbitrary
#
#                  		Example:
#                   	VFADD_S            = 32'b1000001??????????000?????0110011
#
#			 	 2) Put the file containting all instructions into the raw_instructions folder
#
#				 3) Set the parameter below
#
#
#   Contributer: Moritz Imfeld moimfeld@student.ethz.ch
#

import functions.predecoder_generator_helper_functions as pre

if __name__ == '__main__':

    INSTR_FILE_NAME = "xfvec_instr.sv"                   # Put the name of the file that contains all the instructions in a "raw" format here
    CONTRIBUTOR = "Moritz Imfeld"                        # Put your name here
    EMAIL_ADDRESS = "moimfeld@student.ethz.ch"           # Put your email address here
    EXTENSION_NAME = "xfvec"                             # Put the name of the extension of the instructions here


    instr_file_path = 'raw_instructions/'
    instr_file_path += INSTR_FILE_NAME
    pkg_name = 'acc_'
    pkg_name += EXTENSION_NAME
    pkg_name += '_pkg'
    output_file_name = pkg_name
    output_file_name += '.sv'
    f = open(output_file_name, "w")
    pre.header(f, CONTRIBUTOR, EMAIL_ADDRESS, EXTENSION_NAME)
    pre.build_predecoder(f, pkg_name, instr_file_path)
    f.close()