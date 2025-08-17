from __future__ import annotations

"""Minimal EdgeExecutor implementation.

This executor currently delegates all work to Airflow's ``LocalExecutor``.
It exists to allow the control plane to reference ``edge_executor.EdgeExecutor``
without failing to import the executor class. Future iterations may extend
this class with edge specific behavior.
"""

from airflow.executors.local_executor import LocalExecutor


class EdgeExecutor(LocalExecutor):
    """Placeholder executor for edge execution.

    This executor subclasses :class:`~airflow.executors.local_executor.LocalExecutor`
    and does not add any custom behavior. It enables AirBridge to configure a
    custom executor path while the real implementation is developed.
    """

    pass
