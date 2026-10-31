import os
import statistics
import time
from fastapi.testclient import TestClient
from extractor import analyze_pdf
from main import app

client = TestClient(app)

FIXTURES_DIR = os.path.join(os.path.dirname(__file__), "..", "server", "test", "fixtures")
SAMPLE_PDF_PATH = os.path.join(FIXTURES_DIR, "cv-sample.pdf")

def format_stats(latencies_ms):
    return {
        "count": len(latencies_ms),
        "mean_ms": round(statistics.mean(latencies_ms), 2),
        "p50_ms": round(statistics.median(latencies_ms), 2),
        "p90_ms": round(statistics.quantiles(latencies_ms, n=10)[8], 2) if len(latencies_ms) >= 10 else 0,
        "p95_ms": round(statistics.quantiles(latencies_ms, n=20)[18], 2) if len(latencies_ms) >= 20 else 0,
        "p99_ms": round(statistics.quantiles(latencies_ms, n=100)[98], 2) if len(latencies_ms) >= 100 else 0,
        "min_ms": round(min(latencies_ms), 2),
        "max_ms": round(max(latencies_ms), 2),
    }

def benchmark_pdf_extraction(iterations=30):
    print(f"\n[1] Benchmarking PDF Extraction (pdfplumber) — {iterations} iterations...")
    with open(SAMPLE_PDF_PATH, "rb") as f:
        pdf_bytes = f.read()

    # Warmup
    _ = analyze_pdf(pdf_bytes)

    latencies = []
    start_total = time.perf_counter()
    for _ in range(iterations):
        t0 = time.perf_counter()
        _ = analyze_pdf(pdf_bytes)
        latencies.append((time.perf_counter() - t0) * 1000)
    total_time = time.perf_counter() - start_total

    stats = format_stats(latencies)
    throughput = iterations / total_time
    print(f"    Avg: {stats['mean_ms']}ms | p50: {stats['p50_ms']}ms | p95: {stats['p95_ms']}ms | Max: {stats['max_ms']}ms")
    print(f"    Throughput: {throughput:.1f} req/s")
    return stats, throughput

def benchmark_endpoint_analyze_cv(iterations=30):
    print(f"\n[2] Benchmarking FastAPI Endpoint POST /analyze-cv — {iterations} iterations...")
    with open(SAMPLE_PDF_PATH, "rb") as f:
        pdf_bytes = f.read()

    # Warmup
    _ = client.post("/analyze-cv", files={"file": ("cv.pdf", pdf_bytes, "application/pdf")})

    latencies = []
    start_total = time.perf_counter()
    for _ in range(iterations):
        t0 = time.perf_counter()
        res = client.post("/analyze-cv", files={"file": ("cv.pdf", pdf_bytes, "application/pdf")})
        assert res.status_code == 200
        latencies.append((time.perf_counter() - t0) * 1000)
    total_time = time.perf_counter() - start_total

    stats = format_stats(latencies)
    throughput = iterations / total_time
    print(f"    Avg: {stats['mean_ms']}ms | p50: {stats['p50_ms']}ms | p95: {stats['p95_ms']}ms | Max: {stats['max_ms']}ms")
    print(f"    Throughput: {throughput:.1f} req/s")
    return stats, throughput

def benchmark_endpoint_match(iterations=500):
    print(f"\n[3] Benchmarking FastAPI Endpoint POST /match — {iterations} iterations...")
    payload = {
        "cv_skills": ["flutter", "dart", "git", "rest api", "nodejs", "postgresql"],
        "job": {
            "title": "Flutter Developer",
            "required_skills": ["flutter", "dart", "rest api", "bloc"],
            "nice_to_have": ["docker", "ci/cd"],
            "description": "Full-time position"
        }
    }

    # Warmup
    _ = client.post("/match", json=payload)

    latencies = []
    start_total = time.perf_counter()
    for _ in range(iterations):
        t0 = time.perf_counter()
        res = client.post("/match", json=payload)
        assert res.status_code == 200
        latencies.append((time.perf_counter() - t0) * 1000)
    total_time = time.perf_counter() - start_total

    stats = format_stats(latencies)
    throughput = iterations / total_time
    print(f"    Avg: {stats['mean_ms']}ms | p50: {stats['p50_ms']}ms | p95: {stats['p95_ms']}ms | Max: {stats['max_ms']}ms")
    print(f"    Throughput: {throughput:.1f} req/s")
    return stats, throughput

if __name__ == "__main__":
    print("=" * 65)
    print("🚀 PYTHON AI SERVICE BENCHMARK SUITE")
    print("=" * 65)
    s1, r1 = benchmark_pdf_extraction(30)
    s2, r2 = benchmark_endpoint_analyze_cv(30)
    s3, r3 = benchmark_endpoint_match(500)
    print("\n" + "=" * 65)
    print("📊 BENCHMARK SUMMARY TABLE")
    print("=" * 65)
    print(f"{'Metric':<25} | {'PDF Extract':<10} | {'/analyze-cv':<12} | {'/match':<10}")
    print("-" * 65)
    print(f"{'Mean Latency':<25} | {s1['mean_ms']:<8}ms | {s2['mean_ms']:<10}ms | {s3['mean_ms']:<8}ms")
    print(f"{'p50 Latency (median)':<25} | {s1['p50_ms']:<8}ms | {s2['p50_ms']:<10}ms | {s3['p50_ms']:<8}ms")
    print(f"{'p95 Latency':<25} | {s1['p95_ms']:<8}ms | {s2['p95_ms']:<10}ms | {s3['p95_ms']:<8}ms")
    print(f"{'Throughput':<25} | {r1:<8.1f}/s | {r2:<10.1f}/s | {r3:<8.1f}/s")
    print("=" * 65)

