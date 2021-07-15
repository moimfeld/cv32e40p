/*
 * Copyright 2020 ETH Zurich
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 * Author: Moritz Imfeld <moimfeld@student.ethz.ch>
 */

#include <stdio.h>
#include <stdlib.h>

int main(int argc, char *argv[])
{

    // TEST 1: MULTICYCLE AND SINGLECYCLE FPU USE AND FP WRITEBACK (ALSO SOME CORE INTERNAL INSTRUCTIONS)
    __asm__ volatile("fmul.s  ft5, ft5, ft7");
    __asm__ volatile("fdiv.s  ft6, ft5, ft5");
    __asm__ volatile("fmul.s  ft5, ft5, ft7");
    __asm__ volatile("fmul.s  ft5, ft5, ft7");
    __asm__ volatile("fdiv.s  ft6, ft5, ft5");
    __asm__ volatile("fmul.s  ft5, ft5, ft7");
    __asm__ volatile("addi  t2, t2, 128");
    __asm__ volatile("addi  t2, t2, 128");
    __asm__ volatile("addi  t2, t2, 128");
    __asm__ volatile("addi  t2, t2, 128");
    __asm__ volatile("addi  t2, t2, 128");
    __asm__ volatile("addi  t2, t2, 128");
    __asm__ volatile("addi  t2, t2, 128");
    __asm__ volatile("addi  t2, t2, 128");
    __asm__ volatile("addi  t2, t2, 128");
    __asm__ volatile("addi  t2, t2, 128");
    __asm__ volatile("addi  t2, t2, 128");
    __asm__ volatile("addi  t2, t2, 128");
    __asm__ volatile("fmul.s  ft5, ft5, ft7");
    __asm__ volatile("fdiv.s  ft6, ft5, ft5");
    __asm__ volatile("fdiv.s  ft6, ft5, ft5");

    // TEST 2: SINGLECYCLE FPU USE WITH INT WRITEBACK
    __asm__ volatile("feq.s t1, ft5, ft6");
    __asm__ volatile("feq.s t2, ft5, ft6");
    __asm__ volatile("feq.s t3, ft5, ft6");
    __asm__ volatile("addi  t2, t2, 128");
    __asm__ volatile("addi  t2, t2, 128");
    __asm__ volatile("addi  t2, t2, 128");
    __asm__ volatile("addi  t2, t2, 128");
    __asm__ volatile("addi  t2, t2, 128");
    __asm__ volatile("addi  t2, t2, 128");
    __asm__ volatile("addi  t2, t2, 128");
    __asm__ volatile("addi  t2, t2, 128");
    __asm__ volatile("addi  t2, t2, 128");
    __asm__ volatile("addi  t2, t2, 128");
    __asm__ volatile("addi  t2, t2, 128");
    __asm__ volatile("feq.s t4, ft5, ft6");
    __asm__ volatile("fcvt.s.w ft5, t5");


    // TEST 3: COMBINATION OF TEST 1 AND 2
    __asm__ volatile("feq.s t1, ft5, ft6");
    __asm__ volatile("feq.s t2, ft5, ft6");
    __asm__ volatile("fmul.s  ft5, ft5, ft7");
    __asm__ volatile("fdiv.s  ft6, ft5, ft5");
    __asm__ volatile("fmul.s  ft5, ft5, ft7");
    __asm__ volatile("fmul.s  ft5, ft5, ft7");
    __asm__ volatile("fdiv.s  ft6, ft5, ft5");
    __asm__ volatile("fmul.s  ft5, ft5, ft7");
    __asm__ volatile("addi  t2, t2, 128");
    __asm__ volatile("addi  t2, t2, 128");
    __asm__ volatile("addi  t2, t2, 128");
    __asm__ volatile("addi  t2, t2, 128");
    __asm__ volatile("addi  t2, t2, 128");
    __asm__ volatile("addi  t2, t2, 128");
    __asm__ volatile("addi  t2, t2, 128");
    __asm__ volatile("addi  t2, t2, 128");
    __asm__ volatile("addi  t2, t2, 128");
    __asm__ volatile("addi  t2, t2, 128");
    __asm__ volatile("addi  t2, t2, 128");
    __asm__ volatile("addi  t2, t2, 128");
    __asm__ volatile("fmul.s  ft5, ft5, ft7");
    __asm__ volatile("fdiv.s  ft6, ft5, ft5");
    __asm__ volatile("fdiv.s  ft6, ft5, ft5");
    __asm__ volatile("feq.s t3, ft5, ft6");
    __asm__ volatile("addi  t2, t2, 128");
    __asm__ volatile("addi  t2, t2, 128");
    __asm__ volatile("addi  t2, t2, 128");
    __asm__ volatile("addi  t2, t2, 128");
    __asm__ volatile("addi  t2, t2, 128");
    __asm__ volatile("addi  t2, t2, 128");
    __asm__ volatile("addi  t2, t2, 128");
    __asm__ volatile("addi  t2, t2, 128");
    __asm__ volatile("addi  t2, t2, 128");
    __asm__ volatile("addi  t2, t2, 128");
    __asm__ volatile("addi  t2, t2, 128");
    __asm__ volatile("feq.s t4, ft5, ft6");


    // Test 4: LOAD AND STORE
    __asm__ volatile("flw  ft6, 4(t2)");
    __asm__ volatile("flw  ft6, 4(t2)");
    __asm__ volatile("flw  ft6, 4(t2)");
    __asm__ volatile("flw  ft6, 4(t2)");
    __asm__ volatile("fsw  ft6, 4(t2)");
    __asm__ volatile("flw  ft6, 4(t2)");
    __asm__ volatile("fsw  ft6, 4(t2)");
    __asm__ volatile("fsw  ft6, 4(t2)");
    __asm__ volatile("fsw  ft6, 4(t2)");


    // TEST 5: CSR INSTRUCTIONS
    __asm__ volatile("frrm a5");
    __asm__ volatile("frrm a5");
    __asm__ volatile("frrm a5");
    __asm__ volatile("frrm a5");
    __asm__ volatile("frrm a5");
    __asm__ volatile("frrm a5");
    __asm__ volatile("frrm a5");


    // TEST 6: EVERY TEST
    __asm__ volatile("flw  ft6, 4(t2)");
    __asm__ volatile("flw  ft6, 4(t2)");
    __asm__ volatile("feq.s t1, ft5, ft6");
    __asm__ volatile("feq.s t3, ft5, ft6");
    __asm__ volatile("fmul.s  ft5, ft5, ft7");
    __asm__ volatile("fdiv.s  ft6, ft5, ft5");
    __asm__ volatile("fmul.s  ft5, ft5, ft7");
    __asm__ volatile("fmul.s  ft5, ft5, ft7");
    __asm__ volatile("frrm a5");
    __asm__ volatile("frrm a5");
    __asm__ volatile("fdiv.s  ft6, ft5, ft5");
    __asm__ volatile("fmul.s  ft5, ft5, ft7");
    __asm__ volatile("addi  t2, t2, 128");
    __asm__ volatile("addi  t2, t2, 128");
    __asm__ volatile("addi  t2, t2, 128");
    __asm__ volatile("addi  t2, t2, 128");
    __asm__ volatile("frrm a5");
    __asm__ volatile("frrm a5");
    __asm__ volatile("addi  t2, t2, 128");
    __asm__ volatile("addi  t2, t2, 128");
    __asm__ volatile("addi  t2, t2, 128");
    __asm__ volatile("addi  t2, t2, 128");
    __asm__ volatile("addi  t2, t2, 128");
    __asm__ volatile("fsw  ft6, 4(t2)");
    __asm__ volatile("addi  t2, t2, 128");
    __asm__ volatile("addi  t2, t2, 128");
    __asm__ volatile("addi  t2, t2, 128");
    __asm__ volatile("fmul.s  ft5, ft5, ft7");
    __asm__ volatile("fdiv.s  ft6, ft5, ft5");
    __asm__ volatile("fdiv.s  ft6, ft5, ft5");
    __asm__ volatile("feq.s t3, ft5, ft6");
    __asm__ volatile("addi  t2, t2, 128");
    __asm__ volatile("addi  t2, t2, 128");
    __asm__ volatile("addi  t2, t2, 128");
    __asm__ volatile("addi  t2, t2, 128");
    __asm__ volatile("frrm a5");
    __asm__ volatile("frrm a5");
    __asm__ volatile("addi  t2, t2, 128");
    __asm__ volatile("addi  t2, t2, 128");
    __asm__ volatile("addi  t2, t2, 128");
    __asm__ volatile("addi  t2, t2, 128");
    __asm__ volatile("addi  t2, t2, 128");
    __asm__ volatile("addi  t2, t2, 128");
    __asm__ volatile("addi  t2, t2, 128");
    __asm__ volatile("feq.s t4, ft5, ft6");
    __asm__ volatile("frrm a5");
    __asm__ volatile("frrm a5");
    __asm__ volatile("flw  ft6, 4(t2)");
    __asm__ volatile("flw  ft6, 4(t2)");
    __asm__ volatile("flw  ft6, 4(t2)");
    __asm__ volatile("feq.s t1, ft5, ft6");
    __asm__ volatile("feq.s t2, ft5, ft6");
    __asm__ volatile("fmul.s  ft5, ft5, ft7");
    __asm__ volatile("fdiv.s  ft6, ft5, ft5");
    __asm__ volatile("fmul.s  ft5, ft5, ft7");
    __asm__ volatile("fmul.s  ft5, ft5, ft7");
    __asm__ volatile("fdiv.s  ft6, ft5, ft5");
    __asm__ volatile("fmul.s  ft5, ft5, ft7");
    __asm__ volatile("addi  t2, t2, 128");
    __asm__ volatile("addi  t2, t2, 128");
    __asm__ volatile("addi  t2, t2, 128");
    __asm__ volatile("addi  t2, t2, 128");
    __asm__ volatile("frrm a5");
    __asm__ volatile("frrm a5");
    __asm__ volatile("addi  t2, t2, 128");
    __asm__ volatile("addi  t2, t2, 128");
    __asm__ volatile("addi  t2, t2, 128");
    __asm__ volatile("addi  t2, t2, 128");
    __asm__ volatile("addi  t2, t2, 128");
    __asm__ volatile("addi  t2, t2, 128");
    __asm__ volatile("addi  t2, t2, 128");
    __asm__ volatile("addi  t2, t2, 128");
    __asm__ volatile("fmul.s  ft5, ft5, ft7");
    __asm__ volatile("fdiv.s  ft6, ft5, ft5");
    __asm__ volatile("fsw  ft6, 4(t2)");
    __asm__ volatile("fsw  ft6, 4(t2)");
    __asm__ volatile("fsw  ft6, 4(t2)");
    __asm__ volatile("fdiv.s  ft6, ft5, ft5");
    __asm__ volatile("frrm a5");
    __asm__ volatile("frrm a5");
    __asm__ volatile("feq.s t3, ft5, ft6");
    __asm__ volatile("addi  t2, t2, 128");
    __asm__ volatile("addi  t2, t2, 128");
    __asm__ volatile("addi  t2, t2, 128");
    __asm__ volatile("addi  t2, t2, 128");
    __asm__ volatile("frrm a5");
    __asm__ volatile("frrm a5");
    __asm__ volatile("addi  t2, t2, 128");
    __asm__ volatile("addi  t2, t2, 128");
    __asm__ volatile("addi  t2, t2, 128");
    __asm__ volatile("addi  t2, t2, 128");
    __asm__ volatile("addi  t2, t2, 128");
    __asm__ volatile("addi  t2, t2, 128");
    __asm__ volatile("addi  t2, t2, 128");
}
