set dir [file dirname [info script]]
source "$dir/base-hsi.tcl"

set option {
	{hdf.arg	""			"hardware Definition file"}
	{processor.arg	""			"target processor"}
	{rp.arg		""			"repo path"}
	{app.arg	"empty_application"	"Application project fsbl, empty.."}
	{lib.arg	""			"Add library"}
	{pname.arg	""			"Project Name"}
	{bspname.arg	""			"standalone bsp name"}
	{ws.arg		""			"Work Space Path"}
	{hwpname.arg	""			"hardware project name"}
	{arch.arg	"32"			"32/64 bit architecture"}
	{do_compile.arg	"0"			"Build the project"}
	{forceconf.arg	"0"			"Apply the yaml configs on existing project"}
	{yamlconf.arg	""			"Path to Config File"}
}
set usage "A script to generate and compile device-tree and fs-boot sources"
array set params [::cmdline::getoptions argv $option $usage]
set project "$params(ws)/$params(pname)"


set_hw_design $project $params(hdf) 
if { [catch {hsi set_repo_path $params(rp)} res] } {
	error "Failed to set repo path $params(rp)"
}
if { [catch {hsi generate_app -app $params(app) \
	-os standalone -proc $params(processor) -dir $project} res] } {
	error "Failed to generate app $params(app)"
}
if { [catch {hsi open_sw_design \
		$project/${params(app)}_bsp/system.mss} res] } {
	error "Failed to open sw design \
		$project/{$params(app)}_bsp/system.mss "
}
set_properties $params(yamlconf)
file delete -force "$project/${params(app)}_bsp"
if {[catch {hsi generate_bsp -dir "$project/${params(app)}_bsp"} res]} {
        error "failed to regenerate bsp while updating mss "
}
if {[catch {hsi close_sw_design [hsi current_sw_design]} res]} {
	error "failed to close sw_design"
}
if { [catch {hsi close_hw_design [hsi current_hw_design]} res] } {
	error "Failed to close hw design [hsi current_hw_design]"
}
