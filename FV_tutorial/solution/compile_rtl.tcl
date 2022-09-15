# Clear environment
clear -all

# Compile HDL files
analyze -sv elevator_top.v +define+DOOR_CONTROLLER_IS_BBOXED
elaborate -top elevator_top -bbox_m door_controller

