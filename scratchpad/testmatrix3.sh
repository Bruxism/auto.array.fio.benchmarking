matrix_bandwidth() {
local blocksizes=(8kb 16kb 1MB)
local numjobs=(1 64 128 256)
local iodepth=1
local ioengines=(libaio io_uring)
local test_types=(read write)
local direct

for blocksize in "${blocksizes[@]}"; do
for direct in 0 1; do
for numjob in "${numjobs}"; do
for ioengine in "${ioengines[@]}"; do
for test_type in "${test_types[@]}"; do
for size in "${SIZES[@]}"; do
for runtime in "${RUNTIMES[@]}"; do
for use_pareto in 0 1; do
matrix_fs_case
fio_function
done
done
done
done
done
done
done
done
}

matrix_IOPS() {
local blocksizes=(4kb 8kb 16kb)
local numjobs=(1 64 128 256)
local iodepth=1
local ioengines=(libaio io_uring)
local test_types=(read write randread randrw)
local direct

for blocksize in "${blocksizes[@]}"; do
for direct in 0 1; do
for numjob in "${numjobs}"; do
for ioengine in "${ioengines[@]}"; do
for test_type in "${test_types[@]}"; do
for size in "${SIZES[@]}"; do
for runtime in "${RUNTIMES[@]}"; do
for use_pareto in 0 1; do
matrix_fs_case
fio_function
done
done
done
done
done
done
done
done
}

matrix_IOPS() {
local blocksize=4kb
local numjob=1
local iodepth=1
local ioengine=psync
local test_types=(randread randrw)
local direct=1
local use_pareto=0

for test_type in "${test_types[@]}"; do
for size in "${SIZES[@]}"; do
for runtime in "${RUNTIMES[@]}"; do
matrix_fs_case
fio_function
done
done
done
}