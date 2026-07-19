# App stub — assumption note

The assignment states a stub is provided in /app, but it was not present in the
materials I received (only the assessment PDF). Proceeding with this assumption:

Each service (api-gateway, worker, document-service, dashboard, admin-console) is a
containerized process exposing:
- GET /health  — liveness check, returns 200 OK
- GET /ready   — readiness check (DB/queue connectivity), returns 200 OK
- Listens on port 8080

The Terraform ecs-service module is written generically against this contract
(port, health check path, image URI as variables), so if a real stub surfaces later,
it's a variable change, not a redesign.
