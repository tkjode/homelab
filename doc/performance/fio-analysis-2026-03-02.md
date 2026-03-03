# File IO Tests & Analysis

> - __Date:__ March 2nd, 2026
> - __Environment:__ [`HomeLab | Regulus | HomeTheatre`](/base/builds/regulus)

## Introduction

As the build-out of the HomeTheatre App Project in the Regulus kubernetes cluster, I've observed some interesting performance benefits and penalties across the various volume types available in the environment.  

Let's round up some combinations that are in use:

| Host | Performance Test |
| --- | :----- |
| `proxmox` | USB3.2 DAS Volume Performance |
| `proxmox` | RAID-0 8TB SSD Volume Performance |
| `tandy` | Paravirtualized USB3.2 Device Passthru DAS Volume Performance on VM |
| `iscsi` | Virtualized 1TB SSD export from Proxmox Block Performance |
| `gateway` | NFS Volume mounted on `tandy` with net traffic on same bridge `vmbr0` |
| `regulus` | NFS Volume mounted on `tandy` with net traffic traversing through `gateway` (`vmbr1` to `vmbr0`) |


### Results

#### NFS Performance from `gateway`

```text
root@gateway:/etc/letsencrypt/fiotest# fio --name=nfs-test --directory=/etc/letsencrypt/fiotest/ --direct=1 --rw=read \
--bs=4m --size=1G --numjobs=4 --group_reporting --time_based --runtime=30
nfs-test: (g=0): rw=read, bs=(R) 4096KiB-4096KiB, (W) 4096KiB-4096KiB, (T) 4096KiB-4096KiB, ioengine=psync, iodepth=1
...
fio-3.39
Starting 4 processes
nfs-test: Laying out IO file (1 file / 1024MiB)
nfs-test: Laying out IO file (1 file / 1024MiB)
nfs-test: Laying out IO file (1 file / 1024MiB)
nfs-test: Laying out IO file (1 file / 1024MiB)
Jobs: 4 (f=4): [R(4)][100.0%][r=1477MiB/s][r=369 IOPS][eta 00m:00s]
nfs-test: (groupid=0, jobs=4): err= 0: pid=14602: Mon Mar  2 11:21:27 2026
  read: IOPS=370, BW=1482MiB/s (1554MB/s)(43.4GiB/30010msec)
    clat (usec): min=3907, max=49923, avg=10786.22, stdev=2655.23
     lat (usec): min=3907, max=49924, avg=10787.01, stdev=2655.46
    clat percentiles (usec):
     |  1.00th=[ 5866],  5.00th=[ 7111], 10.00th=[ 7832], 20.00th=[ 8717],
     | 30.00th=[ 9372], 40.00th=[ 9896], 50.00th=[10421], 60.00th=[11076],
     | 70.00th=[11731], 80.00th=[12518], 90.00th=[14091], 95.00th=[15401],
     | 99.00th=[18744], 99.50th=[20317], 99.90th=[26870], 99.95th=[30802],
     | 99.99th=[42206]
   bw (  MiB/s): min= 1024, max= 1920, per=100.00%, avg=1483.08, stdev=52.23, samples=236
   iops        : min=  256, max=  480, avg=370.71, stdev=13.08, samples=236
  lat (msec)   : 4=0.01%, 10=41.39%, 20=58.07%, 50=0.53%
  cpu          : usr=0.13%, sys=6.69%, ctx=13956, majf=0, minf=4133
  IO depths    : 1=100.0%, 2=0.0%, 4=0.0%, 8=0.0%, 16=0.0%, 32=0.0%, >=64=0.0%
     submit    : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
     complete  : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
     issued rwts: total=11120,0,0,0 short=0,0,0,0 dropped=0,0,0,0
     latency   : target=0, window=0, percentile=100.00%, depth=1

Run status group 0 (all jobs):
   READ: bw=1482MiB/s (1554MB/s), 1482MiB/s-1482MiB/s (1554MB/s-1554MB/s), io=43.4GiB (46.6GB), run=30010-30010msec
```

