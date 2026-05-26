profile_bandwidth() {
blocksizes=(8kb 16kb 1MB)
numjobs=(1 64 128 256)
iodepths=(1 64 128 256)
ioengines=(libaio io_uring)
test_types=(read write)
directs=(0 1)
}

profile_iops() {
blocksizes=(4kb 8kb 16kb)
numjobs=(1 64 128 256)
iodepths=(1 64 128 256)
ioengines=(libaio io_uring)
test_types=(read write randread randrw)
directs=(0 1)
}

profile_latency() {
blocksizes=4kb
numjobs=1
iodepths=1
ioengines=psync
test_types=(randread randrw)
directs=1
}

collect_profiles() {
unset profiles
local profile
declare -ag profiles

echo "Profiles:"
for profile in $(compgen -A function profile_); do
	echo "${profile}"
	profiles+=("${profile}")
done
}

collect_blocksizes() {
unset combined_blocksizes
local blocksize
local profile
declare -Ag combined_blocksizes

collect_profiles
for profile in "${profiles[@]}"; do
	export -f "${profile}"
done

eval combined_blocksizes+=$(
	declare -A combined_blocksizes
	for profile in "${profiles[@]}"; do
		"${profile}"
		for blocksize in "${blocksizes[@]}"; do
			combined_blocksizes["${blocksize}"]=1
		done
	done
	echo "$(declare -p combined_blocksizes | cut -d= -f2-)"
	)
}

collect_blocksizes
declare -p combined_blocksizes