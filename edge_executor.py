"""Compatibility shim for the EdgeExecutor.

This module exposes the EdgeExecutor from the official provider so that
Airflow can load it using the short import path ``edge_executor.EdgeExecutor``.
"""

from airflow.providers.edge3.executors.edge_executor import EdgeExecutor

__all__ = ["EdgeExecutor"]
