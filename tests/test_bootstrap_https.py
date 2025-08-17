import os
import subprocess
from pathlib import Path

PROJECT_ROOT = Path(__file__).resolve().parents[1]
SCRIPT = PROJECT_ROOT / "bootstrap-edge.sh"


def test_bootstrap_rejects_non_https():
    env = os.environ.copy()
    env["CONTROL_PLANE_URL"] = "http://example.com"
    result = subprocess.run(
        ["bash", str(SCRIPT), "--queue", "q"],
        env=env,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True,
    )
    assert result.returncode != 0
    assert "must use https" in result.stderr.lower()
