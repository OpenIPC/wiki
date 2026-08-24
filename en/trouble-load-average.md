# OpenIPC Wiki
[Table of Content](../README.md)

## Troubleshooting: load average looks impossibly high

### Symptom

The **Device Status** page of the Web UI shows a load average of 12, 13 or more,
while the CPU figure right above it sits at a comfortable 20-35%:

```
CPU
33 %
load 13.35
```

Monitoring systems (Zabbix, Prometheus, Grafana) that trigger on
`node_load1` start alerting the moment the camera is added, and never stop.
The camera itself streams normally, stays cool and does not reboot.

### Short answer

**Nothing is wrong with the camera.** On SigmaStar SoCs a load average of
roughly 12 (or 13 with audio enabled) is the *idle* value, and it will never go
lower. Load average on Linux is not a CPU-usage figure, and on these cameras it
cannot be used as an overload signal at all.

Remove any trigger you have on `node_load1` / `node_load5` / `node_load15` and
alert on CPU utilisation instead — see [What to monitor
instead](#what-to-monitor-instead) below.

### What load average actually measures

A common misreading is "load average = how busy the CPU is". It is not. The
Linux load average is an exponentially damped average of the number of tasks
that are either

* **R** — runnable (running, or waiting for a CPU), **or**
* **D** — in *uninterruptible sleep*.

That second category is the whole story here. A task in `D` state is asleep. It
consumes no CPU whatsoever. But it still counts as a full 1.0 towards the load
average for as long as it stays there.

This is deliberate — historically `D` meant "blocked on disk I/O", which is a
real form of contention worth surfacing. It stops being meaningful when kernel
threads use uninterruptible sleep simply as their idle state.

### Why it is high on SigmaStar

The SigmaStar vendor SDK ships closed-source kernel modules (`mi_sys`,
`mi_vif`, `mi_vpe`, `mi_venc`, `mi_ai`, `mhal` …). Each pipeline port these
modules create gets a kernel thread, and those threads wait for their next
frame in *uninterruptible* sleep rather than in interruptible or idle sleep.

They are not stuck and they are not busy — they simply spend the gap between
frames in the one sleep state that the load average counts.

On an SSC30KQ (Infinity6E) with one video channel and JPEG snapshots enabled,
these twelve threads are permanently in `D`:

| Thread | Waiting in |
| --- | --- |
| `vif0_P0_MAIN`, `vif1_P0_MAIN`, `vif2_P0_MAIN` | `mi_sys_internal_main_worker_thread` |
| `vpe0_P0_MAIN` … `vpe0_P3_MAIN` | `mi_sys_internal_main_worker_thread` |
| `venc0_P0_MAIN`, `venc1_P0_MAIN` | `mi_sys_internal_main_worker_thread` |
| `VEP_DumpTaskThr` | `msleep` |
| `mi_log` | `msleep` |
| `ehci_monitor` | `msleep` |

Twelve threads in `D` → a load average that settles at just over 12. Enabling
audio adds a thirteenth (`ai0_P0_MAIN`) and the load settles at just over 13.

Note that `msleep()` in the Linux kernel is uninterruptible by definition, so
any driver thread that polls in a `msleep()` loop contributes to the load
average forever, whatever it is polling for.

Two of the threads above (`mi_log` and `ehci_monitor`) are created when the
modules load and are present even with the streamer stopped. The rest appear
with the video pipeline and disappear with it.

Cameras on other vendor SoCs — HiSilicon, Ingenic and so on — typically show a
load average near zero, because their SDK threads do not idle in `D`. This is
why two healthy cameras sitting side by side can report 0.26 and 13.35.

### Checking it yourself

Read the raw value the Web UI is showing you — it comes straight from the
kernel, unmodified:

```
cat /proc/loadavg
```

```
12.49 12.35 12.29 1/78 2452
```

The fourth field is the giveaway: `1/78` means **1 runnable task out of 78**.
A genuinely overloaded single-core camera would show a large first number
there, not a 1.

Confirm the CPU is idle:

```
top -b -n1 | head -3
```

```
CPU: 18.1% usr  9.0% sys  0.0% nic 72.7% idle  0.0% io  0.0% irq  0.0% sirq
Load average: 12.38 12.33 12.29 1/79 2458
```

72% idle at "load 12.38". Now list the threads that are producing that number:

```
for t in /proc/[0-9]*/task/[0-9]*; do
    [ "$(awk '{print $3}' "$t/stat" 2>/dev/null)" = "D" ] && \
        echo "$(cat "$t/comm")  <-  $(cat "$t/wchan")"
done
```

```
vif0_P0_MAIN     <-  MI_SYS_IMPL_EnsureInputPortFifoEmpty
vpe0_P0_MAIN     <-  mi_sys_internal_main_worker_thread
venc0_P0_MAIN    <-  mi_sys_internal_main_worker_thread
...
```

Every entry is a kernel thread from the vendor SDK, and their count matches the
load average.

If you stop the streamer, the count drops to the two module-load threads and
the load average decays towards 2 over the next few minutes (the "1 minute"
average has a 60-second time constant, so give it time). Starting it again
brings both straight back. That is the whole mechanism.

### What to monitor instead

The camera exposes Prometheus-style metrics on `http://<camera>/metrics`. Use
CPU utilisation, which is honest on every platform:

```
node_cpu_seconds_total{cpu="0",mode="idle"}
node_cpu_seconds_total{cpu="0",mode="user"}
node_cpu_seconds_total{cpu="0",mode="system"}
```

These are counters of seconds spent in each mode, so alert on the *rate*. In
PromQL, busy percentage over five minutes:

```
100 * (1 - rate(node_cpu_seconds_total{mode="idle"}[5m])
           / ignoring(mode) sum without(mode)(rate(node_cpu_seconds_total[5m])))
```

In Zabbix, take the same two counters as `Numeric (float)` items with a **Change
per second** preprocessing step and build the ratio in a calculated item.

Other metrics from the same endpoint that mean what they appear to mean:

| Metric | Use |
| --- | --- |
| `node_cpu_seconds_total` | CPU utilisation — the overload signal |
| `node_procs_running_total` | Instantaneous run-queue length (`R` tasks only, no `D`) |
| `node_hwmon_temp_celsius` | SoC temperature — the overheat signal |
| `node_memory_MemAvailable_bytes` | Memory pressure, against `node_memory_MemTotal_bytes` |

The Web UI's own **CPU %** figure is computed from `node_cpu_seconds_total` and
is correct; only the small `load` line beneath it carries the inflated number.
Likewise the **All systems OK** badge is driven by temperature, memory and CPU,
never by the load average — so a camera showing "load 13.35" alongside a green
badge is not a contradiction.

### When is a high load average real?

On a SigmaStar camera, only *changes above the floor* are informative. If the
baseline is normally 12 and it climbs to 20, something has genuinely joined the
run queue. Read the raw value and check the other signals:

* `1/78` in `/proc/loadavg` stays at 1 → still no real contention.
* `top` shows idle collapsing towards 0% → real CPU saturation.
* `node_procs_running_total` consistently above 1 → real run-queue backlog.
* Rising temperature and dropping available memory → real work.

If CPU idle is healthy and the run queue is 1, the load average is measuring
sleeping driver threads, no matter how large it looks.

### Can it be fixed?

Not from the OpenIPC side. Since Linux 4.2 the kernel provides `TASK_IDLE`
(`TASK_UNINTERRUPTIBLE | TASK_NOLOAD`) precisely so that idle kernel threads
stop inflating the load average, and the correct fix is for the driver to wait
in that state instead. The SigmaStar MI modules are proprietary, out-of-tree
binaries, so the change has to come from the vendor.

Until then the number is cosmetic. It costs no CPU, no memory and no stability
— it only misleads dashboards.
