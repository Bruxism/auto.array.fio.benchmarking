# About

___

To automate the setup and teardown of customizable OpenZFS and HWRAID+ext4 arrays to run [fio](https://github.com/axboe/fio) benchmarks using customizable profiles of variables such as `blocksize` and `numjobs` to exhaustively and iteratively test every combination of on a bare system that was live-booted such as with [TinyLive](https://github.com/Bruxism/TinyLive).

> [!WARNING]
> HIGHLY DESTRUCTIVE TO ALL CONNECTED DRIVES REGARDLESS OF SETUP

# **Warning: HIGHLY DESTRUCTIVE TO ALL CONNECTED DRIVES REGARDLESS OF SETUP**

> [!WARNING]
> HIGHLY DESTRUCTIVE TO ALL CONNECTED DRIVES REGARDLESS OF SETUP

These scripts write over all disks and wipe their partition tables several times over throughout testing. Your data will be deleted. I'm not responsible for lost data. Only use this on systems with which you are okay to lose all data on all drives possibly including those not included in testing.

___

## Background

One of the first challenges of setting up a server is designing configurations of arrays of disks. It's a critical first step that may be laborious to change if not impossible to preserve data of without access to an alternative and sufficient size of complimenting storage. It's important to get it right from the outset as it is foundational to the data which is built on it.

For a moment, let's set aside any particular configuration, and consider *how* to compare *what* differences in performance and the *why* those differences matter.

The prominent method of testing is via `fio`, a benchmarking software made by an illustrious maintainer of the Linux Kernel and creator of an I/O API, `io_uring`, Jens Axboe.

This software has a lot of options which we'll get to some of, but basically three measures of significance: bandwidth, input/output operations per second (IOPS), and latency.

Those measures matter differently between different services such as those suited for graphic designers, financial institutions, or online gaming--for examples.

#### The *what*: A *very* brief glossing of bandwidth, IOPS, latency, and redundancy

- Bandwidth is the speed of a transfer--the 'how much' of data being moved over time
  
  - Important for systems that are moving a lot of data such as for total system backups or video editing

- IOPS is--not *really*, but practically--the amount of simultaneous requests that can be handled
  
  - Important for systems that are handling lots of different users--game servers, databases--or even a single user loading a lot of small files

- Latency is the time between the initiation of a request and the completion of the data being supplied
  
  - Important for databases and transaction systems where data has to be confirmed as completed before processes can continue
    
    - Redundant databases--in particular--are affected by even small differences in measures of latency as there are cumulative and compounding functions as a result of such differences

These are just the fundamental performance metrics for storage units. Consider that multiple services may share devices. Flash-based storage is less affected versus hard-disk storage which is greatly affected.

- Redundancy is the quality of having simultaneous copies of data such that a system can continue to function despite, in this context, disk failure
  
  - Important for critical systems that must remain operational which, for example, can be measured in people's lives lost or millions of dollars per minute

#### The *why*: performance, cost efficiency, and minimizing risk

There's a saying: "**Any idiot can build a bridge that stands, but it takes an engineer to build a bridge that barely stands**". One way to interpret that is that it takes an engineer to most *efficiently* make use of resources to design a solution that performs *sufficiently* even if narrowly skirting *risk*.

For some demands, especially in business or military, the momentary loss of a service may be a catastrophe measured in lives or millions of dollars per minute.

In '*what*' we also glossed over parts of the *why*. Basically, different tasks value different metrics differently, but there's another factor entirely: **redundancy**--a huge part of making sure data remains **available**; this means being able to survive and operate continuously despite drive failures.

~~This is the intersection between business demands and technical application. Understanding and balancing business challenges with the design and application of technical resources means having to value different metrics differently.~~

We asses and prioritize requirements, evaluate options, and build accordingly.

#### The *how*: education, experimentation, and assessment

It appears (to me) that storage engineers are expected to know *what* to test for and then design specifically the fio job for those demands.

The inspiration of this project was to learn about actual variations in performance by creating something to exhaustively try every combination and see actual differences between those. I needed to see how each change actually affected performance.

fio, as great as it was, does not also automate the buildup and teardown of arrays, and though it uses 'jobfiles' to help do some automation, it doesn't conveniently set itself up for exhaustively trying every combination of a list of variables. It's way out of scope for that project as it appears (to me) that storage engineers are expected to know *what* to test for and then design specifically the fio job for those demands.

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
