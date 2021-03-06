/*****************************************************************************
* cc3200.lds
*
* GCC Linker script for the CC3200
*
* Copyright (C) 2014 Texas Instruments Incorporated - http://www.ti.com/ 
* 
* 
*  Redistribution and use in source and binary forms, with or without 
*  modification, are permitted provided that the following conditions 
*  are met:
*
*    Redistributions of source code must retain the above copyright 
*    notice, this list of conditions and the following disclaimer.
*
*    Redistributions in binary form must reproduce the above copyright
*    notice, this list of conditions and the following disclaimer in the 
*    documentation and/or other materials provided with the   
*    distribution.
*
*    Neither the name of Texas Instruments Incorporated nor the names of
*    its contributors may be used to endorse or promote products derived
*    from this software without specific prior written permission.
*
*  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS 
*  "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT 
*  LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
*  A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT 
*  OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, 
*  SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT 
*  LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
*  DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
*  THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT 
*  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE 
*  OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*
******************************************************************************/

/*
 * This file is part of the Micro Python project, http://micropython.org/
 *
 * The MIT License (MIT)
 *
 * Copyright (c) 2015 Daniel Campora
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

__stack_size__    = 1024;       /* interrupts are handled using this stack */
__min_heap_size__ = 4K;
__rtos_heap_size  = 16K;

MEMORY
{
    SRAMB (rwx) : ORIGIN = 0x20000000, LENGTH = 0x00004000
    SRAM  (rwx) : ORIGIN = 0x20004000, LENGTH = 0x0003C000
}

ENTRY(ResetISR)

SECTIONS
{  
    /* place the FreeRTOS heap (the micropython stack will live here) */
    .rtos_heap (NOLOAD) :
    {
        . = ALIGN(8);
        *(.rtos_heap*)
        . = ALIGN(8);
    } > SRAMB

    _ertos_heap = ORIGIN(SRAMB) + LENGTH(SRAMB);

    .text :
    {
        _text = .;
        KEEP(*(.intvecs))
        *(.text*)
        *(.rodata*)
        *(.ARM.extab* .gnu.linkonce.armextab.*)
        . = ALIGN(8);
    } > SRAM

    .ARM :
    {
        __exidx_start = .;
        *(.ARM.exidx*)
        __exidx_end = .;
        _etext = .;
    } > SRAM
    
    __init_data = .;
    
    /* used by the start-up to initialize data */
    _sidata = LOADADDR(.data);

    .data : AT(__init_data)
    {
        . = ALIGN(8);
        _data = .;
        *(.data*)
        . = ALIGN(8);
        _edata = .;
    } > SRAM

    .bss :
    {
        . = ALIGN(8);
        _bss = .;
        *(.bss*)
        *(COMMON)
        . = ALIGN(8);
        _ebss = .;
    } > SRAM
     
    /* allocate the micropython heap */
    .heap :
    {
        . = ALIGN(8);
        _heap = .;
        . = . + __min_heap_size__;
        . = . + (ORIGIN(SRAM) + LENGTH(SRAM) - __stack_size__ - ABSOLUTE(.));
        . = ALIGN(8);
        _eheap = .;
    } > SRAM

    /* allocate the main stack */
    .stack ORIGIN(SRAM) + LENGTH(SRAM) - __stack_size__ :
    {
        . = ALIGN(8);
        _stack = .;
        . = . + __stack_size__;
        . = ALIGN(8);
        _estack = .;
    } > SRAM
}
