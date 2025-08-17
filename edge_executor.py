from __future__ import annotations

"""Minimal EdgeExecutor implementation for AirBridge.

This module is placed at the repository root so that ``edge_executor`` can
be imported without additional ``PYTHONPATH`` configuration. The
implementation currently delegates all work to Airflow's
:class:`~airflow.executors.local_executor.LocalExecutor` and acts as a
placeholder for future edge-specific behavior.
"""

from airflow.executors.local_executor import LocalExecutor


class EdgeExecutor(LocalExecutor):
    """Placeholder executor for edge execution.

    This executor subclasses
    :class:`~airflow.executors.local_executor.LocalExecutor` and does not
    add any custom behavior. It enables AirBridge to configure a custom
    executor path while the real implementation is developed.
    """

    pass
