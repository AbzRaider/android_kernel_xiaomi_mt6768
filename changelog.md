Changelog ( 7/10/2023) // V2-STABLE
====================================
* Fixed a bug where fast-charging doesnt work properly while screen on
* Fixed a bug where fast-charging speeds would often fluctuate when above 50%
* Improved UI Performance And Battery Backup
* XM6768: Enable Sched WALT
* XM6768: lava_defconfig : Build DTBO Projects for shiva too.
* XM6768: Disable a bunch of logging from mediatek kernel drivers
* XM6768: Enable ZRAM Dedup and ZRAM Writeback
* XM6768: mtk/ged : Set GRALLOC_EXTRA Config NUM to 10 
* XM6768: Use the stock configs from MIUI_12.5.6.0  for proc/config.gz
* mt6768 : mtk-gpu: Increase frequency of DVFS sampling
* drivers: misc: mtk-gpu : mali_bifrost :  r25p0: Affine GPU IRQs to big cluster
* defconfig: enable CLEANCACHE
* f2fs: Force strict fsync mod
* [CAF-PORT] mm: checkout some files from LA.UM.9.1.r1-08100-SMxxx0.0 
* cpumask: Add cpumasks for big and LITTLE CPU clusters
* UPSTREAM: zram: support page writeback 
* tcp_output: set initial TCP window size to 64K (speed improvement) 
* cpuidle: don't disable cpuidle when entering suspend 
* lz4: fix kernel decompression speed
