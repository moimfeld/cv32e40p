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
#   Description: Helper functions for the predecoder_generator script
#
#   Contributer: Moritz Imfeld moimfeld@student.ethz.ch
#

import datetime

def header(file, CONTRIBUTOR, EMAIL_ADDRESS, EXTENSION_NAME):
    file.write('// This file was created by the predecoder_generator script\n')
    file.write('// Date and Time of creation: ')
    file.write(str(datetime.datetime.now()))
    file.write('\n')
    file.write('//\n')
    file.write('// ')
    file.write(EXTENSION_NAME)
    file.write(' Predecoder')
    file.write('\n')
    file.write('// Contributor: ')
    file.write(CONTRIBUTOR)
    file.write(' <')
    file.write(EMAIL_ADDRESS)
    file.write('>\n')
    file.write('//\n')

def build_predecoder(file, package_name, instr_file_path):
    NumInstr = 0
    with open(instr_file_path, "r") as a_file:
        for line in a_file:
            NumInstr += 1

    NumInstr_string = 'parameter int unsigned NumInstr = {NumInstr};\n'.format(NumInstr=NumInstr)
    Offload_instr_string = 'parameter acc_pkg::offload_instr_t OffloadInstr[{NumInstr}'.format(NumInstr=NumInstr)
    Offload_instr_string += '] = \'{\n'
    file.write('\n')
    file.write('\n')
    file.write('package ')
    file.write(package_name)
    file.write(';\n')
    file.write('\n')
    file.write(NumInstr_string)
    file.write(Offload_instr_string)

    index = 0
    sanity_check = 0
    with open(instr_file_path, "r") as a_file:
        for line in a_file:
            index += 1
            if (len((line.split()[2])[4:]) == 32):
                sanity_check += 1
            stripped_line = line.strip()
            file.write('  \'{\n')
            data = instr_data(stripped_line)
            file.write(data)
            file.write('  \n')
            mask = instr_mask(stripped_line)
            file.write(mask)
            file.write('  \n')
            file.write('    prd_rsp : \'{\n')
            file.write('      p_accept : 1\'b1,\n')
            file.write('      p_writeback : 2\'b00,\n')
            file.write('      p_is_mem_op : 1\'b0,\n')
            file.write('      p_use_rs : 3\'b000\n')
            file.write('   }\n')
            if(index != NumInstr):
                file.write('  },\n')
            else:
                file.write('  }\n')
                file.write('};\n')
    file.write('\n')
    file.write('endpackage')
    file.write('\n')

    if (sanity_check != NumInstr):
        print('')
        print('')
        print('ERROR not all instructions are 32 bit wide')
        print('Only', sanity_check, 'out of', NumInstr, 'are 32 bit wide\n')
        print('--> Check if your raw_instructions file!')
        print('')
        print('')
    else:
        print('')
        print('')
        print('All sanity checks passed')
        print('Predecoder built successfully')
        print('')
        print('')

def instr_data(instr_data):
    instr_list = instr_data.split()
    name = instr_list[0]
    raw_data = (instr_list[2])[4:]
    new_data = '    instr_data: 32\'b '
    previous_letter = ''
    for index in range(len(raw_data)):
        if((raw_data[index] == '0' or raw_data[index] == '1') and previous_letter != '?'):
            new_data += raw_data[index]
        elif((previous_letter == '0' or previous_letter == '1') and raw_data[index] == '?'):
            new_data += '_'
            new_data += '0'
        elif ((previous_letter != '0' or previous_letter != '1') and raw_data[index] == '?'):
            new_data += '0'
        elif((raw_data[index] == '0' or raw_data[index] == '1') and previous_letter == '?'):
            new_data += '_'
            new_data += raw_data[index]
        previous_letter = raw_data[index]
    new_data += ', // '
    new_data += name
    return new_data

def instr_mask(instr_data):
    instr_list = instr_data.split()
    raw_data = (instr_list[2])[4:]
    mask = '    instr_mask: 32\'b '
    previous_letter = ''
    for index in range(len(raw_data)):
        if ((raw_data[index] == '0' or raw_data[index] == '1') and previous_letter != '?'):
            mask += '1'
        elif ((previous_letter == '0' or previous_letter == '1') and raw_data[index] == '?'):
            mask += '_'
            mask += '0'
        elif ((previous_letter != '0' or previous_letter != '1') and raw_data[index] == '?'):
            mask += '0'
        elif ((raw_data[index] == '0' or raw_data[index] == '1') and previous_letter == '?'):
            mask += '_'
            mask += '1'
        previous_letter = raw_data[index]
    mask += ','
    return mask