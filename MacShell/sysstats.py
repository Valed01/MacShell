#!/usr/bin/env python3
"""Данные для виджета «Система»: одна JSON-строка в секунду в stdout.

cpu, ram, gpu, disk — проценты; net — байт/с; temps — °C; bat — батарея.
"""
import json, os, shutil, sys, time


def read(path, default=""):
    try:
        with open(path) as f:
            return f.read().strip()
    except OSError:
        return default


def hwmon(name):
    base = "/sys/class/hwmon"
    for d in sorted(os.listdir(base)):
        if read(f"{base}/{d}/name") == name:
            return f"{base}/{d}"
    return None


def gpu_dev():
    base = "/sys/class/drm"
    for d in sorted(os.listdir(base)):
        p = f"{base}/{d}/device"
        if os.path.exists(f"{p}/gpu_busy_percent"):
            return p
    return None


def default_iface():
    for line in read("/proc/net/route").splitlines()[1:]:
        p = line.split()
        if len(p) > 1 and p[1] == "00000000":
            return p[0]
    return None


def battery():
    base = "/sys/class/power_supply"
    for d in os.listdir(base):
        if read(f"{base}/{d}/type") == "Battery":
            return f"{base}/{d}"
    return None


CPU_T, GPU_T, NVME_T = hwmon("k10temp") or hwmon("coretemp"), hwmon("amdgpu"), hwmon("nvme")
GPU = gpu_dev()
BAT = battery()


def temp(h):
    return round(int(read(f"{h}/temp1_input", "0")) / 1000) if h else 0


prev_cpu = prev_net = None
while True:
    f = list(map(int, read("/proc/stat").splitlines()[0].split()[1:]))
    idle, total = f[3] + f[4], sum(f)
    cpu = 0.0
    if prev_cpu and total > prev_cpu[1]:
        cpu = 100 * (1 - (idle - prev_cpu[0]) / (total - prev_cpu[1]))
    prev_cpu = (idle, total)

    m = {}
    for line in read("/proc/meminfo").splitlines():
        k, v = line.split(":")
        m[k] = int(v.split()[0]) * 1024
    ram_used = m["MemTotal"] - m["MemAvailable"]

    du = shutil.disk_usage("/")

    ifc = default_iface()
    rx = tx = 0
    down = up = 0
    if ifc:
        rx = int(read(f"/sys/class/net/{ifc}/statistics/rx_bytes", "0"))
        tx = int(read(f"/sys/class/net/{ifc}/statistics/tx_bytes", "0"))
        if prev_net and prev_net[0] == ifc:
            down, up = max(0, rx - prev_net[1]), max(0, tx - prev_net[2])
    prev_net = (ifc, rx, tx)

    mhz = [float(l.split(":")[1]) for l in read("/proc/cpuinfo").splitlines() if l.startswith("cpu MHz")]

    out = {
        "cpu": round(cpu, 1),
        "ghz": round(sum(mhz) / len(mhz) / 1000, 1) if mhz else 0,
        "load": read("/proc/loadavg").split()[0],
        "ram": round(100 * ram_used / m["MemTotal"], 1),
        "ramUsed": ram_used, "ramTotal": m["MemTotal"],
        "swap": m["SwapTotal"] - m["SwapFree"],
        "gpu": int(read(f"{GPU}/gpu_busy_percent", "0")) if GPU else -1,
        "vramUsed": int(read(f"{GPU}/mem_info_vram_used", "0")) if GPU else 0,
        "vramTotal": int(read(f"{GPU}/mem_info_vram_total", "0")) if GPU else 0,
        "disk": round(100 * du.used / du.total, 1),
        "diskFree": du.free, "diskTotal": du.total,
        "iface": ifc or "", "down": down, "up": up,
        "tCpu": temp(CPU_T), "tGpu": temp(GPU_T), "tSsd": temp(NVME_T),
        "uptime": int(float(read("/proc/uptime", "0").split()[0])),
    }
    if BAT:
        out["bat"] = int(read(f"{BAT}/capacity", "0"))
        out["batStatus"] = read(f"{BAT}/status")
        out["batW"] = round(int(read(f"{BAT}/power_now", "0")) / 1e6, 1)
    try:
        print(json.dumps(out), flush=True)
    except BrokenPipeError:
        sys.exit(0)
    time.sleep(1)
