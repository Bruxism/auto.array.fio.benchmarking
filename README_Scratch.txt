Proxmox HWRAID v ZFS

Metrics studied

Benchmarking required

fio found, but didn't include array construction/destruction or comprehensive iteration of testing

Online benchmarks didn't really help me understand
	such as why some options were chosen































This started because I had HWRAID and honestly wanted to use ZFS because of the snapshot features, but I had heard that ZFS didn't perform as well.

I understood some things such as bandwidth and latency, and I had a rough understanding of IOPS; but I didn't really know how performance would vary between different array configurations or how different HWRAID and ZFS were.

I mean, I knew some basics about arrays--the theory--but really see the numbers for myself, I hadn't.

Then there's HWRAID vs ZFS, right, and online discourse pretty much was all about how ZFS is superior and made HWRAID obsolete.

To educate myself with real results, I needed to test so much--so many variations of so many variables. Finding `fio` was trivial, but it didn't automate very much and certainly not building up and tearing down arrays.

There were other confounding variables too--namely how ZFS strongly relies on its own caching or Adaptive Replacement Cache (ARC). Most all cache just keeps data based on how recently it was used, but ARC keeps track of how frequently it is used as well--it's more intelligent in that way. ARC also basically fills out all available RAM and releases or captures more as apps pull and release. Disabling this is, for most applications, unrealistic and obliterates much of the advantage ZFS has in terms of bandwidth/latency/IOPS.

Another advantage of ZFS was that within such configured array, many settings that HWRAID set immutable for the entire array, ZFS can make easily on a per folder level--and with finesse, even a per file (however impractical that may be with all sorts of mountings).

Anyway, I needed to see for myself--with my own setup. 

The data I intended to keep wasn't critical. I'd set aside a couple of disks for mirroring, and the rest would be striped. I could automate backups to the mirror as desired.

Regardless, I wanted to collect so many thousands results of so many variations. I needed to automate it, and I didn't find anything that quite suited what I sought.











































