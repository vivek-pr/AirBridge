"""Compatibility shim for the EdgeExecutor.

Provides an ``EdgeExecutor`` implementation so Airflow can reference
``edge_executor.EdgeExecutor`` even when the official provider is not
installed. This aliases Airflow's built-in ``LocalExecutor`` for now.
"""

from airflow.executors.local_executor import LocalExecutor

EdgeExecutor = LocalExecutor

__all__ = ["EdgeExecutor"]
