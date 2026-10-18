"""
Model perilaku Python yang meniru PERSIS logika traffic_light_fsm.vhd
versi TUGAS PRAKTIKUM NOMOR 1 (6-state dengan fase all-red, durasi
hijau/kuning masih konstanta tetap -- belum switch), dipakai untuk
verifikasi cepat sebelum diuji di papan (GHDL tidak tersedia di
sandbox ini).
"""
from enum import Enum, auto

class S(Enum):
    NS_HIJAU = auto()
    NS_KUNING = auto()
    ALLRED_1 = auto()
    EW_HIJAU = auto()
    EW_KUNING = auto()
    ALLRED_2 = auto()

DUR_HIJAU = 10
DUR_KUNING = 3
DUR_ALLRED = 1

def run(n_ticks=70):
    state = S.NS_HIJAU
    timer = DUR_HIJAU - 1
    log = []
    for t in range(n_ticks):
        log.append((t, state, timer))
        if timer == 0:
            if state == S.NS_HIJAU:
                state, timer = S.NS_KUNING, DUR_KUNING - 1
            elif state == S.NS_KUNING:
                state, timer = S.ALLRED_1, DUR_ALLRED - 1
            elif state == S.ALLRED_1:
                state, timer = S.EW_HIJAU, DUR_HIJAU - 1
            elif state == S.EW_HIJAU:
                state, timer = S.EW_KUNING, DUR_KUNING - 1
            elif state == S.EW_KUNING:
                state, timer = S.ALLRED_2, DUR_ALLRED - 1
            elif state == S.ALLRED_2:
                state, timer = S.NS_HIJAU, DUR_HIJAU - 1
        else:
            timer -= 1
    return log

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
    log = run(70)
    errors = check(log)
    print("Error ditemukan:", errors if errors else "TIDAK ADA (LULUS)")
    expected = {S.NS_HIJAU: DUR_HIJAU, S.NS_KUNING: DUR_KUNING, S.ALLRED_1: DUR_ALLRED,
                S.EW_HIJAU: DUR_HIJAU, S.EW_KUNING: DUR_KUNING, S.ALLRED_2: DUR_ALLRED}
    for i, (state, count) in enumerate(phase_durations(log)):
        mark = "OK" if count == expected[state] else "BEDA! (kemungkinan hanya terpotong simulasi)"
        print(f"{i:2d}. {state.name:10s} durasi={count:3d} tick (harusnya {expected[state]:3d})  {mark}")
