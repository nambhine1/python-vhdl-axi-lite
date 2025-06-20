source lib/OsvvmLibraries/Scripts/StartUp.tcl
variable OMIT_XILINX_FILES 0

build lib/OsvvmLibraries/OsvvmLibraries.pro
      
if {$::osvvm::ToolName eq "GHDL"} {
    set OMIT_XILINX_FILES 1
    SetExtendedAnalyzeOptions {-frelaxed -Wno-specs}
    SetExtendedSimulateOptions {-frelaxed -Wno-specs -Wno-binding}
    SetExtendedRunOptions {--ieee-asserts=disable-at-0}
}

if {$::osvvm::ToolName eq "RivieraPRO"} {
    set OMIT_XILINX_FILES 1
    puts "Simulator = $::osvvm::ToolName, OMIT_XILINX_FILES = $OMIT_XILINX_FILES"
    LinkLibraryDirectory {temp/VHDL_LIBS}
}

# add the pre compiled library path below replacing $PrecompiledVivadoIPCores 
if {$::osvvm::ToolName eq "QuestaSim"} {
    set OMIT_XILINX_FILES 0
    SetVHDLVersion 2008
    vmap unisim "$PrecompiledVivadoIPCores/unisim"
    vmap xpm "$PrecompiledVivadoIPCores/xpm"
}


build src/src.pro
build tb/Axi4Lite.pro