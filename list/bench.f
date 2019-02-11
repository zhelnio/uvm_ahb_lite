// +------------+ 
// | C  INCLUDE |
// +------------+
-I../src/c

// +--------------+
// | RTL FILELIST | 
// +--------------+

// +------------+ 
// | C FILELIST |
// +------------+ 

// +------------+ 
// |  SV DEFINE |
// +------------+ 

// +-----------------+ 
// | PACKET FILELIST |
// +-----------------+ 
../src/sv/tools/common_pkg.sv
../src/sv/tools/amba_pkg.sv
../src/sv/ahb_pkg/ahb_pkg.sv
../case/ahb_case_pkg.sv

// +---------------+ 
// | CASE FILELIST |
// +---------------+ 

// +----------+ 
// | TOP FILE |
// +----------+ 
../rtl/ahb_dummy.v
../top.sv

// +--------------+ 
// | FILE INCLUDE |
// +--------------+ 

// +-------------+ 
// | RTL INCLUDE |
// +-------------+ 

// +------------+ 
// | SV INCLUDE |
// +------------+ 
+incdir+../src/sv/tools
+incdir+../src/sv/ahb_pkg
+incdir+../case
