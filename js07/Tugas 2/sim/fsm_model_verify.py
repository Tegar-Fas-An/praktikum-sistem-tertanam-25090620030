"""
Model perilaku Python yang meniru PERSIS logika traffic_light_fsm.vhd
versi TUGAS PRAKTIKUM NOMOR 2 (6-state dengan all-red dari Tugas 1,
DITAMBAH durasi hijau yang dibaca dari sw_green, bukan konstanta),
dipakai untuk verifikasi cepat sebelum diuji di papan (GHDL tidak
tersedia di sandbox ini).
"""
from enum import Enum, auto

class S(Enum):
    NS_HIJAU = auto()
    NS_KUNING = auto()
    ALLRED_1 = auto()
    EW_HIJAU = auto()
    EW_KUNING = auto()
    ALLRED_2 = auto()

DUR_KUNING = 3
DUR_ALLRED = 1

def green_duration_from_sw(sw4bit: int) -> int:
    assert 0 <= sw4bit <= 15
    return 5 + sw4bit   # <<< Tugas 2: replikasi "5 + to_integer(unsigned(sw_green))"

def run(sw4bit, n_ticks=90):
    green_duration = green_duration_from_sw(sw4bit)
    state = S.NS_HIJAU
    timer = green_duration - 1
    log = []
    for t in range(n_ticks):
        log.append((t, state, timer))
        if timer == 0:
            if state == S.NS_HIJAU:
                state, timer = S.NS_KUNING, DUR_KUNING - 1
            elif state == S.NS_KUNING:
                state, timer = S.ALLRED_1, DUR_ALLRED - 1
            elif state == S.ALLRED_1:
                state, timer = S.EW_HIJAU, green_duration - 1
            elif state == S.EW_HIJAU:
                state, timer = S.EW_KUNING, DUR_KUNING - 1
            elif state == S.EW_KUNING:
                state, timer = S.ALLRED_2, DUR_ALLRED - 1
            elif state == S.ALLRED_2:
                state, timer = S.NS_HIJAU, green_duration - 1
        else:
            timer -= 1
    return log, green_duration

def led_decode(state):
    table = {
        S.NS_HIJAU:  (0b100, 0b001),
        S.NS_KUNING: (0b100, 0b010),
        S.ALLRED_1:  (0b100, 0b100),
        S.EW_HIJAU:  (0b001, 0b100),
        S.EW_KUNING: (0b010, 0b100),
        S.ALLRED_2:  (0b100, 0b100),
    }
    ew, ns = table[state]
    return ew, ns

def check(log):
    errors = []
    for t, state, timer in log:
        ew, ns = led_decode(state)
        if bin(ew).count("1") != 1:
            errors.append(f"t={t}: EW tidak one-hot")
        if bin(ns).count("1") != 1:
            errors.append(f"t={t}: NS tidak one-hot")
        if ew == 0b001 and ns == 0b001:
            errors.append(f"t={t}: KEDUA ARAH HIJAU BERSAMAAN!")
    return errors

def phase_durations(log):
    phases, cur, cnt = [], None, 0
    for t, state, timer in log:
        if state != cur:
            if cur is not None:
                phases.append((cur, cnt))
            cur, cnt = state, 1
        else:
            cnt += 1
    phases.append((cur, cnt))
    return phases

if __name__ == "__main__":
    # sw_green = "0000" (0) -> 5s, "0101" (5) -> 10s, "1111" (15) -> 20s
    for sw_val in (0, 5, 15):
        log, gd = run(sw_val, n_ticks=90)
        errors = check(log)
        print(f"\n=== sw_green = {sw_val:#06b} -> green_duration = {gd} detik ===")
        print("Error:", errors if errors else "TIDAK ADA (LULUS)")
        expected = {S.NS_HIJAU: gd, S.NS_KUNING: DUR_KUNING, S.ALLRED_1: DUR_ALLRED,
                    S.EW_HIJAU: gd, S.EW_KUNING: DUR_KUNING, S.ALLRED_2: DUR_ALLRED}
        phases = phase_durations(log)
        for i, (state, count) in enumerate(phases[:12]):
            mark = "OK" if count == expected[state] else "(terpotong simulasi / beda)"
            print(f"  {i:2d}. {state.name:10s} durasi={count:3d} tick (harusnya {expected[state]:3d})  {mark}")
