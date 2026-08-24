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

**Nothing is wrong with the camera.** Load average on Linux is not a CPU-usage
figure, and on these cameras most of what it reports comes from driver threads
that are fast asleep.

Every SigmaStar camera has a *floor* — a load average it shows when completely
idle and never drops below. On the SSC30KQ measured for this article the floor
is about 12, or 13 with audio enabled. **The exact value is a property of the
SoC, the firmware and the enabled pipeline, not a constant**, so establish the
floor for your own camera rather than assuming these numbers;
[Checking it yourself](#checking-it-yourself) shows how.

Remove any trigger you have on `node_load1` / `node_load5` / `node_load15` at
these levels and alert on CPU utilisation instead — see [What to monitor
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

Because the count follows the ports the SDK actually creates, another SoC in the
family, another firmware build or another set of loaded modules will have its
own floor — higher or lower than twelve. Take the numbers above as one worked
example rather than a specification.

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

The fourth field is the first clue: `1/78` means **1 runnable task out of 78**.
A camera whose CPU is genuinely oversubscribed would show a large first number
there, not a 1.

Be precise about what that does and does not establish. It rules out a
*runnable* backlog. It says nothing at all about tasks in `D` — which are what
the load average is counting here, and which never appear in that numerator.

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

Save that list. It is your camera's baseline, and comparing against it is the
only dependable way to tell a newly stuck task from the vendor's permanent
ones:

```
for t in /proc/[0-9]*/task/[0-9]*; do
    [ "$(awk '{print $3}' "$t/stat" 2>/dev/null)" = "D" ] && cat "$t/comm"
done | sort > /tmp/loadavg-baseline
```

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

These are counters of seconds spent in each mode, so alert on the *rate*. The
busy fraction is idle time divided by **the sum of every mode** — that total is
what makes the result a percentage of wall-clock time. In PromQL, over five
minutes:

```
100 * (1 - sum by (instance) (rate(node_cpu_seconds_total{mode="idle"}[5m]))
         / sum by (instance) (rate(node_cpu_seconds_total[5m])))
```

In Zabbix, collect `/metrics` with a single **HTTP agent** master item of type
*Text*, then add two dependent items, each with a **Prometheus pattern**
preprocessing step followed by **Change per second**:

| Dependent item | Prometheus pattern | Result |
| --- | --- | --- |
| `cpu.idle.rate` | `node_cpu_seconds_total{mode="idle"}` | value |
| `cpu.total.rate` | `node_cpu_seconds_total` | aggregate: `sum` |

Zabbix 5.2 and later provide the `sum` function in the Prometheus pattern step.
On older versions, create one dependent item per mode and add them together in
the calculated item — do not substitute a couple of hand-picked modes for the
total. A calculated item then yields the busy percentage:

```
100 * (1 - last(//cpu.idle.rate) / last(//cpu.total.rate))
```

Other metrics from the same endpoint that mean what they appear to mean:

| Metric | Use |
| --- | --- |
| `node_cpu_seconds_total` | CPU utilisation — the overload signal |
| `node_procs_running_total` | Instantaneous run-queue length (`R` tasks only, no `D`) |
| `node_procs_blocked_total` | Tasks blocked in kernel I/O waits — reads 0 on a healthy camera however high the load average is |
| `node_hwmon_temp_celsius` | SoC temperature — the overheat signal |
| `node_memory_MemAvailable_bytes` | Memory pressure, against `node_memory_MemTotal_bytes` |

The Web UI's own **CPU %** figure is computed from `node_cpu_seconds_total` and
is correct; only the small `load` line beneath it carries the inflated number.
Likewise the **All systems OK** badge is driven by temperature, memory and CPU,
never by the load average — so a camera showing "load 13.35" alongside a green
badge is not a contradiction.

### When is a high load average real?

Only movement away from your camera's floor carries information — and that
movement needs reading carefully, because load rises for two quite different
reasons and only one of them shows up as CPU usage.

**Something joined the run queue.** Genuine CPU contention: `top` shows idle
collapsing towards 0%, `node_procs_running_total` sits above 1, and the first
number in the fourth field of `/proc/loadavg` climbs. Temperature usually
follows.

**Something new went into uninterruptible sleep.** A process wedged on a failing
SD card, a stalled USB or network filesystem, a driver that has deadlocked. This
raises the load average while using **no** CPU and **without** changing the
runnable count, so from every angle except one it looks identical to the
vendor's idle threads.

That one angle is the thread list. A high load average with an idle CPU is
therefore *not* self-evidently harmless — diff the `D` tasks against the
baseline you saved earlier:

```
for t in /proc/[0-9]*/task/[0-9]*; do
    [ "$(awk '{print $3}' "$t/stat" 2>/dev/null)" = "D" ] && cat "$t/comm"
done | sort | diff /tmp/loadavg-baseline -
```

No output means the load is the vendor's sleeping threads and nothing else. Any
added line is a task worth investigating, whatever the CPU happens to be doing.

`node_procs_blocked_total` is a useful second opinion, because it counts only
tasks blocked in kernel I/O waits — a strict subset of `D`. The SigmaStar worker
threads are not among them, which is why it reads 0 on a healthy camera even
with the load average sitting at 12. Sustained values above 0 indicate a real
I/O stall and are worth alerting on.

### Can it be fixed?

Not from the OpenIPC side. Since Linux 4.2 the kernel provides `TASK_IDLE`
(`TASK_UNINTERRUPTIBLE | TASK_NOLOAD`) precisely so that idle kernel threads
stop inflating the load average, and the correct fix is for the driver to wait
in that state instead. The SigmaStar MI modules are proprietary, out-of-tree
binaries, so the change has to come from the vendor.

Until then, the *vendor threads' contribution* is cosmetic: it costs no CPU, no
memory and no stability, and misleads nothing but dashboards. What sits above
that floor is still worth reading — see [When is a high load average
real?](#when-is-a-high-load-average-real).
