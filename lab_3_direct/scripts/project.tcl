# Open the direct decoder in its own Vivado project.
set decoder_top lab03_arif_direct
source [file join [file dirname [info script]] .. .. lab_3 scripts project.tcl]
unset decoder_top
