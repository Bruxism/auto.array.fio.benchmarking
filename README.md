# About

___

To automate the setup and teardown of customizable OpenZFS and HWRAID+ext4 arrays to run [fio](https://github.com/axboe/fio) benchmarks using customizable profiles of variables such as `blocksize` and `numjobs` to exhaustively and iteratively test every combination of on a bare system that was live-booted such as with [TinyLive](https://github.com/Bruxism/TinyLive).

> [!CAUTION]
> HIGHLY DESTRUCTIVE TO ALL DATA IN ALL CONNECTED DRIVES REGARDLESS OF SETUP

# **Warning: HIGHLY DESTRUCTIVE TO ALL DATA IN ALL CONNECTED DRIVES REGARDLESS OF SETUP**

> [!CAUTION]
> HIGHLY DESTRUCTIVE TO ALL DATA IN ALL CONNECTED DRIVES REGARDLESS OF SETUP

These scripts write over all disks and wipe their partition tables several times over throughout testing. Your data will be deleted. I'm not responsible for lost data. Only use this on systems with which you are okay to lose all data on all drives including those not included in testing.

___

### Requirements

Linux, bash, fio, Dell's PERCCLI, OpenZFS, util-linux, coreutils, e2fsprogs

## How to use

There are two main files needing configuration before running tests: those under `config/`, and the main script file itself, `fio.ZFS.Ext4.hwRAID.TestSuite.sh`. Test profiles in `profiles/` may also be created and customized.

Simply put: look at the examples in `config/`, make a another subdirectory there for your own system, and model it likewise for your own system. Then, go to the main script, and uncomment the tests that you'll be running. Finally, run the script appended with two arguments in order: the name of the subdirectory modeled for your system in `config/` and then the name of a test profile in `profiles/`.

> [!TIP]
> 
> If you booted from TinyLive, then run tmux, press ctrl-b followed by ctrl-r to restore an included session of several panes of monitors including those for seeing [drive / ARC / zpool] use and an htop. Those monitors go to a second window, and you'll be left at a single pane window with waiting console. ctrl-b then ctrl-w opens a menu to switch between windows.

`config/` 

This is where you'll write out your own system's drive configurations to be tested in a directory that you create and name. That name will be used as the first argument for the main script.

Examples are included, and it's necessary to use the included variable names for their given tests. For example: `ZFS_DEVICES` and `ZFS_ZPOOL_LAYOUTS` in `zfs.config.sh`. 

The name of the config files themselves does not matter because every file in this directory is executed via `source`. What's important is that the names of the associative array variables for the tests to be run are included and unchanged, and that you include the device locations, ideally using absolute paths and by-id, e.g. `/dev/disk/by-id/wwn-0x{aBunchOfDigits}`.

`profiles/`

This is where the rough equivalent of job files are saved. A couple are included, but you may make your own. Every combination of the available variables will be tested, so be wary about adding more as the amount of tests grows exponentially. To create your own profile, either change the settings in the included files, or copy one and name the copy as `fio.benchmark.profile.{CHANGEME}.sh`. The main script's second argument runs `source` on the file with matching text in the `{CHANGEME}` section.

Note that `iodepth` and `numjobs` are run as pairs with commas within a pair. Each pair is delimited by a space. For example: `iodepths_numjobs=(1,256 256,1 4,64 64,4)`; in that example, the first pair has `iodepth` as `1` and `numjobs` as `256`; the second pair has `iodepth` as `256` and `numjobs` as `1`; the third pair has `iodepth` as `4` and `numjobs` as `64`; and final and fourth pair has `iodepth` as `64`, and `numjobs` as `4`.

`fio.ZFS.Ext4.hwRAID.TestSuite.sh`

The bottom of this script has a list of commented functions--one for each type of test:

- `raw_disk_matrix` -- 'raw' disks individually

- `zfs_disk_matrix` -- ZFS vdevs

- `hwraid_disk_matrix` -- `HWRAID+ext4 arrays

- `ext4_disk_matrix` -- individual disks with ext4

Remove the `#` preceding the text of the tests to be run, and then run the script with the name of your personally created directory under `config/` as the first argument and the name of the profile in `profiles/` as the second argument. For example: `./fio.ZFS.Ext4.hwRAID.TestSuite.sh PowerEdgeR730xd default`

At the top of the script are some configurable variables that shouldn't *need* changing, but optionally may be:

- `ZPOOL_NAME` - The name of the zpool used during testing; by default: `testdrive`

- `RESULTS_DIR` - The root directory of test results--by default: `/root/Results`. To clarify: I say 'root directory' not because it's in `/root/`, but because each time the script runs, it creates a child directory here that is named as the timestamp from whence it was run.

- `SIZES` - The size(s) of the test file(s). I included and tested only one size by default (`50G`), and while untested, it should work as a customizable list of sizes. To clarify: it should work fine with any single size--obviously, given that it can fit in all of the configurations.

- `RUNTIMES` - Similarly to `SIZES`, a(n) (untested) customizable list of runtimes--by default and tested, just as one item, and in this case: `180` seconds per test.

- `TIMEZONE` - Time zone in region/city format. Default: `America/Chicago`

### Results

By default, results are stored in `/root/Results`. There, a filename-timestamped `txt` of the output of `lsblk` is saved, and a set of subdirectories according to the tests that were run (e.g. `zfs`, `HWRAID`, and so on) contain the `txt` files of their results, respectively.

Each test result file is timestamped and named by the options used to run it.

> [!WARNING]
> 
> The names of the test files are long. In Windows, for example, they may not be able to be opened if they reside deep enough in a drive's path. You may have to enable long filenames and/or place them in the root of the drive.

Such a naming scheme was used to be able to use conventional file search applications to filter for particular sets of results in order to open them with conventional text file applications and compare.

Should you prefer to make a database or graphics of the results, the output of each of the test results are also saved as JSON data. Human-readable data is included at the end of those same result files.

___

## Background

One of the first challenges of setting up a server is designing storage configurations. It's a critical first step that may be laborious to change if not impossible to preserve data of without access to an alternative and sufficient size of complimenting storage. It's important to get it right from the outset as it's foundational to the data which is built on it.

For me, I wanted help to decide between hardware RAID (HWRAID) or OpenZFS. Glossing over online opinion, the consensus appeared to lean strongly towards OpenZFS, but there were comments about how HWRAID had better metrics--it simply lacked so many features such as snapshotting.

Available information was limited such as how RAID1 read rates are linearly related as a factor of number identical disks while their write rates remain tied to the single slowest disk. However, things get complicated and information scarce when there's filesystem, blocksize, iodepth, numjobs, whether data is continuous, and so much more--combined. I wanted to see so much more of it--at least rough and relative differences.

Therefore, I sought to comprehensively test so many combinations to look at the results, and then use that to decide which filesystem to use. Truth be told, I had come in strongly leaning towards OpenZFS, but if HWRAID was strong enough, then I'd consider otherwise.

### The Journey: the treasure is the knowledge we find along the way

For a moment, let's set aside any particular configuration, and consider *how* to compare *what* differences in performance and the *why* those differences matter.

The prominent method of benchmarking storage is via `fio`, a software made by an illustrious maintainer of the Linux Kernel and creator of an I/O API, `io_uring`, Jens Axboe.

This software has a lot of options which we'll get to some of, but basically three measures of significance: *bandwidth*, input/output operations per second (*IOPS*), and *latency*.

Those measures matter differently between different services such as those suited for graphic designers, financial institutions, or online gaming--for examples.

I set out to understand how each of the options for configuring arrays and disks actually performed while sharpening my bash programming and system administration skills.

#### The *what*: A *very* brief glossing of bandwidth, IOPS, latency, and redundancy

- Bandwidth is the speed of a transfer--the 'how much' of data being moved over time
  
  - Important for systems that are moving a lot of data such as for total system backups or video editing

- IOPS is--not *exactly*, but practically--the amount of simultaneous requests that can be handled
  
  - Important for systems that are handling lots of different users--game servers, databases--or even a single user loading a lot of small files

- Latency is the time between the initiation of a request and the completion of the data being supplied
  
  - Important for databases and transaction systems where data has to be confirmed as completed before processes can continue
    
    - Redundant databases--in particular--are affected by even small differences in measures of latency as there are cumulative and compounding functions that result in such differences

- Redundancy is the quality of having simultaneous copies of data such that a system can continue to function despite disk failure
  
  - Important for critical systems that must remain operational--which, in extremes, may be measured in people's lives lost or millions of dollars lost per minute

#### The *why*: performance goals, cost efficiency, and minimizing risk

There's a saying: "**Any idiot can build a bridge that stands, but it takes an engineer to build a bridge that barely stands**". One way to interpret that is that it takes an engineer to most *efficiently* make use of resources to design a solution that performs *sufficiently* even if narrowly skirting *risk*.

Given a budget and a goal, we hope to design or construct a system such that it can achieve its intended design goals as inexpensively as possible; that could be a baseline requirement of 99.999% availability with sub 15-ms response time and a minimum capacity of 100 with a stretch goal of as many users as possible--budget allowing.

In extreme cases, especially in military or high value business, the momentary loss of a service may be a catastrophe measured in lives or millions of dollars per minute.

Therefore, it would behoove to asses and prioritize requirements, evaluate options, and build accordingly.

#### The *how*: education, experimentation, and assessment

Storage engineers are expected to know *[what](https://arstechnica.com/gadgets/2020/02/how-fast-are-your-disks-find-out-the-open-source-way-with-fio/)* to test for and then specifically design a benchmark test, such as with fio, for those demands.

The inspiration of this project was to learn about actual variations in performance by creating something to exhaustively try every combination and see actual differences between those. I needed to see how each change actually affected performance, and in  the process, learn to design tests and avoid flawed testing.

fio, as great as it was, does not also automate the buildup and teardown of arrays, and though it uses 'job files' to help do some automation, it doesn't conveniently set itself up for exhaustively trying every combination of a list of variables. It's way out of scope for that project as it appears (to me) that storage engineers are expected to know *what* to test for and then design specifically the fio job for those demands. Trying every combination of a set of variables isn't part of its intended function.

*<u>Therefore, this project is more educational in nature for the development of introductory experience of how storage configuration variables result in actual performance results.</u>* Being able to apply them to actual goals means evaluating an operating environment to fashion tests tailored to that environment.

In other words, this project facilitates running comprehensive testing in a '*pure*' science approach as opposed to '*applied science*'. It's outside of its scope to assess how applicable the results are to any particular environment. Despite that, it's possible to gather so many variation of results that reflect a given target. In many real life situations, however, combinations of services with different usage patterns may simultaneously operate--the combinations of which are practically infinite.

> [!CAUTION]
> 
> Every additional argument in a test profile multiplies the number of tests.

---

### Additional notes

To roughly make equivalent testing between OpenZFS and HWRAID, some liberties were taken in how they were configured.

#### HWRAID

Direct = 1 -- See: `lib/lib.fio.benchmark.MegaRAID.perccli.sh`

```
        pdcache=on
        writeback=wt
        readahead=nora
        cachedirect=direct
```

Direct = 0

```
        pdcache=off
        writeback=wb
        readahead=ra
        cachedirect=cached
```

#### OpenZFS

Direct = 1 -- See: `lib.fio.benchmark.zfs_functions.sh`

```
        checksum=off
        primarycache=metadata
```

Direct = 0

```
        checksum=on
        primarycache=all
```

---

I had understood the pros and cons of different RAID levels, but now, besides software and hardware RAID was OpenZFS.

There's a Dell PowerEdge R730xd with 13 SAS drives and PERC H730 HWRAID--8 identical HDD, 4 identical SSD, and 1 unique HDD--that I own that I got to study enterprise storage with.

One of the challenges of designing a computer system is deciding between what storage configurations to choose from which set me on a journey to learn about performance metrics and benchmarking--that's when I discovered fio.

Reading the fio documents showed me how many different variables there were for testing, and there are a lot! It begs the question: how does each of those affect performance.

A problem is that while fio has some automation for testing, it doesn't automate exhaustively from a list of arguments to variables--for example: listing blocksizes, iodepth, numjobs, and direct, and then iterating over every possible combination of those--and it also doesn't set up and tear down different combinations of drive arrays on which to run these tests.

## The Challenge: Automating

fio has some automation for testing, but

To help decide between 

I had a server that I was gong to install Proxmox on, and I wanted to decide which RAID array system to use. IT waws between OpenZFS and HWRAID.

I meant to run benchmarks over fio which has a an overwhelming amount of options.

I studied about drive performance, and came across things like bandwidth which I already knew of, but also things like IOPS and latency. I didn't know how they interacted.

Looking further into options became overwhelming, and looking for other people's results left me wondering why they chose the options that they chose when running fio. I had to see what did what, and to get a really good idea, I had to run tests by changing one variable at a time among apool of duifferent variables.

Each test would take a few minutes to level out and get consistent results. Standing by for each one was inconvenient--to say the least.

To learn about how different options of filesystems and testing affect performance, exhaustively comprehensive testing needs to be observed. There are so many options besides blocksize--a major one, certainly--that needed to be iterated and analyzed.

I looked into using job files that fio supports, but I found it to be a bit constricting in the sense that it didn't automatically let setting of an array of options to iterate combinations over--let alone the creation/destruction of arrays/drives/formats. Of course, it's a remarkable piece of software by an illustrious developer, and those functions are well out of scope.

To learn about how 

I created these scripts to go over every combination of a customized list which--a function of which is exponential--but for which the results are very insightful.

Here, there are several different formats tested: raw, OpenZFS, and HWRAID+Ext4 (PERCCLI). 

I had a Dell PowerEdge 730xd and a Lenovo ThinkCentre, and I wanted to figure out if I should use ZFS or stick to Ext4 with or without hardware RAID.

I understood what bandwidth was, but when looking into this, I learned about IOPS and latency. I also learned about `fio` and about how it could be used to benchmark.

The problem was that it was chocked full of options, and I didn't quite understand what  mattered and how. I also noticed that while `fio` had a method to automate testing via a 'job file', it didn't include options for iterating though 

hwraid_resolve_direct() {
case "${direct}" in
    1)
        pdcache=on
        writeback=wt
        readahead=nora
        cachedirect=direct
    ;;
    0)
        pdcache=off
        writeback=wb
        readahead=ra
        cachedirect=cached
    ;;
esac
}

I was going to install ProxMox on a system that has HWRAID and a lot of drives.

I sought out to learn about storage performance metrics. I knew about bandwidth already, but I learned also learned about IOPS and latency (in the context of storage).

Advice online says that you have to just test to see actual results. That sent me to look up benchmarking software, so I found fio.
