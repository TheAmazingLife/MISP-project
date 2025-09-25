import subprocess
import csv
import os
import statistics

BIN = "./Entrega_1/testing/greedyDet"   # ejecutable compilado
OUTPUT = "Entrega_1/testing/greedyDetResults/results2000.csv"

densities = ["0.1","0.2","0.3","0.4","0.5","0.6","0.7","0.8","0.9"]
instances = [str(i) for i in range(1, 31)]

rows = []

for d in densities:
    values = []
    times = []
    for j in instances:
        fname = f"./dataset_grafos_no_dirigidos/new_2000_dataset/erdos_n2000_p0c{d}_{j}.graph"
        if not os.path.exists(fname):
            print(f"⚠️  {fname} no encontrado, se omite.")
            continue

        try:
            # Ejecutar el binario
            result = subprocess.run([BIN, "-i", fname], capture_output=True, text=True, check=True)
            out = result.stdout.splitlines()

            # Extraer valor y tiempo desde la salida
            valor = None
            tiempo = None
            for line in out:
                if len(out) >= 2:
                    valor = int(out[0])
                    tiempo = float(out[1])

            if valor is not None and tiempo is not None:
                values.append(valor)
                times.append(tiempo)
                rows.append([d, j, valor, tiempo])
        except subprocess.CalledProcessError as e:
            print(f"❌ Error ejecutando {fname}: {e}")

# Guardar resultados individuales
with open(OUTPUT, "w", newline="") as f:
    writer = csv.writer(f)
    writer.writerow(["DENSITY", "INSTANCE", "VALOR", "TIEMPO(ms)"])
    writer.writerows(rows)

print(f"✅ Resultados individuales guardados en {OUTPUT}")

# Calcular y mostrar promedios por densidad
print("\n📊 Promedios por densidad:")
print("DENSITY, MEDIA_VALOR, MEDIA_TIEMPO(ms)")
for d in densities:
    vals = [r[2] for r in rows if r[0] == d]
    ts = [r[3] for r in rows if r[0] == d]
    if vals and ts:
        media_val = statistics.mean(vals)
        media_t = statistics.mean(ts)
        print(f"{d}, {media_val:.2f}, {media_t:.2f}")
