# AirBridge
Build a control-plane/data-plane Airflow on 3.0.4 using Edge Executor. Control plane hosts web/API, scheduler, triggerer, DB; data planes run lightweight edge workers with outbound-only HTTPS. DAGs and logs are centralized in S3.
