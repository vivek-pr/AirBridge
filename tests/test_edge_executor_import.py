import os
import subprocess
import sys
from pathlib import Path


PROJECT_ROOT = Path(__file__).resolve().parents[1]


def test_edge_executor_importable(tmp_path):
    """EdgeExecutor should be importable via Airflow's ExecutorLoader.

    The test installs the project package and then imports the executor from a
    separate working directory to ensure the module is available on the
    ``PYTHONPATH``. This mimics Airflow's runtime environment where the current
    working directory is unrelated to the project source tree.
    """

    subprocess.run(
        [sys.executable, "-m", "pip", "install", PROJECT_ROOT.as_posix()],
        check=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
    )

    env = os.environ.copy()
    env.pop("PYTHONPATH", None)

    subprocess.run(
        [
            sys.executable,
            "-c",
            "from airflow.executors.executor_loader import ExecutorLoader, ExecutorName;"
            "ExecutorLoader.import_executor_cls(ExecutorName('edge_executor.EdgeExecutor'))",
        ],
        check=True,
        cwd=tmp_path,
        env=env,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
    )
