//
//  MobileClientKernel.cpp
//  PA_Client
//
//  Created by LI on 2019/6/4.
//
#define MB_KERNEL_ENGINE_DLL
#include "MobileClientKernel.h"
#include "MCKernel.h"

MC_KERNEL_ENGINE IMCKernel *GetMCKernel()
{
    return CMCKernel::GetInstance();
}
