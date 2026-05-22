A full-stack, production-grade **incident management and real-time observability platform** built for engineering operations teams. OpsAlert surfaces live service health, aggregates alerts, tracks incidents from detection to resolution, and delivers deep operational analytics — all in a single command center.

> Built as part of a microservices architecture with a **Kotlin/Spring Boot backend**, **React/TypeScript frontend**, **PostgreSQL** persistence, and **gRPC** as the inter-service communication layer.

---

## ✨ Features

- **Incident Command Center** — real-time dashboard surfacing active incidents, on-call status, resolution rates, and system uptime across services
- **Live Monitoring** — per-service health grid with latency (p50/p95/p99), error rate, uptime, and event feed; auto-refreshes without page reload
- **Alert Feed** — streaming alert ticker with severity classification (critical / warning / info / resolved), filtering by service and time
- **Incident Lifecycle Management** — create, track, and resolve incidents with severity levels (P1–P4), status transitions, and assignee tracking
- **Operational Analytics** — MTTR/MTTA trends, alert noise analysis (noisy vs actionable vs suppressed), responder leaderboards, and per-service SLA tracking
- **Microservices Architecture** — decoupled services communicate over **gRPC**, enabling typed contracts, low-latency RPCs, and independent deployability
- **Email Alerting** — Spring Mail integration for on-call notifications and escalation emails
- **Database Migrations** — Flyway-managed schema evolution on PostgreSQL
- **JWT Auth** — Bearer token authentication across all API calls via Axios interceptors

---

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                        React Frontend                           │
│   Dashboard · Incidents · Monitoring · Alerts · Analytics       │
│              (TypeScript · Tailwind · Recharts · shadcn/ui)     │
└────────────────────────┬────────────────────────────────────────┘
                         │ REST / HTTP (Axios)
                         ▼
┌─────────────────────────────────────────────────────────────────┐
│              Spring Boot API Gateway  (Kotlin · JVM 21)         │
│   /incidents · /alerts · /monitoring · /analytics · /auth       │
│         Spring Web · Spring Security · Spring Actuator          │
└──────┬────────────────────────────────┬───────────────────────┘
       │ gRPC                           │ gRPC
       ▼                                ▼
┌─────────────┐                 ┌──────────────────┐
│  Alert Svc  │                 │  Notification Svc │
│  (Kotlin)   │                 │  (Spring Mail)    │
└──────┬──────┘                 └──────────────────┘
       │
       ▼
┌─────────────────────────────────────────────────────────────────┐
│                     PostgreSQL (Flyway migrations)               │
│     incidents · alerts · services · call_logs · users           │
└─────────────────────────────────────────────────────────────────┘
```

Services communicate internally over **gRPC** (Protocol Buffers), keeping inter-service contracts strongly typed and versioned. The API gateway exposes a REST interface to the frontend.

---

## 🛠️ Tech Stack

| Layer | Technology |
|---|---|
| Frontend | React 18 · TypeScript · Tailwind CSS · shadcn/ui |
| Charts & Visualization | Recharts (area, line, bar, pie) |
| Animation | Framer Motion |
| HTTP Client | Axios (with JWT interceptor) |
| Backend | Kotlin · Spring Boot 3.5 · JVM 21 |
| Inter-service Communication | **gRPC** (Protocol Buffers) |
| Database | PostgreSQL · Spring Data JPA · Hibernate |
| Migrations | Flyway |
| Email / Alerting | Spring Boot Mail |
| Auth | LDAP · JWT Bearer tokens |
| Build | Gradle (Kotlin DSL) |
| Observability | Spring Boot Actuator |

---

## 📐 Project Structure

```
OpsAlert/
├── backend/                          # Kotlin/Spring Boot microservice
│   ├── src/main/kotlin/com/opsalert/
│   │   └── backend/
│   │       ├── BackendApplication.kt # Spring Boot entry point
│   │       ├── incidents/            # Incident domain (entity, repo, service, controller)
│   │       ├── alerts/               # Alert processing & routing
│   │       ├── monitoring/           # Health check aggregation
│   │       └── grpc/                 # gRPC service definitions & stubs
│   ├── src/main/resources/
│   │   ├── application.properties
│   │   └── db/migration/             # Flyway SQL migrations
│   └── build.gradle.kts
│
└── src/                              # React/TypeScript frontend
    ├── App.tsx                       # Root router & layout
    ├── api/                          # Axios client + typed API calls
    │   ├── axiosClient.ts            # Base client with JWT interceptor
    │   ├── incidentApi.ts            # Incident CRUD
    │   ├── alertApi.ts               # Alert endpoints
    │   └── analyticsApi.ts           # Analytics endpoints
    ├── dto/                          # TypeScript DTOs mirroring backend contracts
    ├── incidents/                    # Incident dashboard & detail views
    ├── monitoring/                   # Live monitoring page
    │   └── components/               # Service table, alert feed, charts, events
    ├── analytics/                    # Operational analytics (MTTR, noise, SLA)
    ├── components/                   # Shared UI (Sidebar, MetricCard, etc.)
    └── ui/                           # shadcn/ui component library
```

---

## 📊 Dashboard Pages

### Incident Command Center (`/`)
Top-level overview: active incident count, mean response time, incidents resolved today, on-call engineers, system load, and 30-day uptime. Includes a scrolling live alert ticker and a recent incidents feed.

### Incidents (`/incidents`)
Full incident list fetched from the backend API, displaying title, severity badge (P1–P4), and status. Metric cards summarise total, critical, and resolved counts.

### Monitoring (`/monitoring`)
Production-grade observability view with:
- **System health cards** — Services Up, Active Alerts, Avg Response, Error Rate, CPU, Memory
- **Service status table** — per-service uptime, latency, region, last check
- **Live alert feed** — streaming alerts with severity colouring
- **Latency charts** — p50/p95/p99 time-series (Recharts)
- **Error rate chart** — rate % and raw count over time
- **Incident distribution** — severity breakdown pie chart
- **Event log** — restarts, deploys, scale events, recoveries

### Analytics (`/analytics`)
Engineering metrics for post-incident review and SRE reporting:
- **Incident trend** — 24h breakdown by severity
- **MTTR/MTTA** — 7-day mean time to respond and resolve
- **Alert noise** — noisy vs actionable vs suppressed per service
- **Responder table** — per-engineer incident count, P1 count, avg MTTR, on-call hours
- **Service reliability table** — uptime, p50/p99, incident count per service

### Alerts (`/alerts`) · On-Call (`/on-call`) · Settings (`/settings`)
In progress — scaffolded routes with placeholder pages.

---

## ⚙️ Setup

### Prerequisites
- JDK 21+
- Node.js 18+ / npm
- PostgreSQL 14+
- [gRPC / protoc](https://grpc.io/docs/protoc-installation/) (for compiling `.proto` files)

### 1. Clone

```bash
git clone https://github.com/AyushTyagi2/OpsAlert
cd OpsAlert
```

### 2. Configure the backend

Create `backend/src/main/resources/application.properties`:

```properties
spring.application.name=backend

# Database
spring.datasource.url=jdbc:postgresql://localhost:5432/opsalert
spring.datasource.username=<your_user>
spring.datasource.password=<your_password>
spring.jpa.hibernate.ddl-auto=validate

# Flyway
spring.flyway.enabled=true

# Mail (for alert notifications)
spring.mail.host=smtp.gmail.com
spring.mail.port=587
spring.mail.username=<your_email>
spring.mail.password=<your_app_password>

# gRPC
grpc.server.port=9090
```

### 3. Run the backend

```bash
cd backend
./gradlew bootRun
```

API available at `http://localhost:8080`. Actuator health at `http://localhost:8080/actuator/health`.

### 4. Install frontend dependencies

```bash
cd src   # or the frontend root
npm install
```

### 5. Configure frontend environment

Create a `.env` file in the frontend root:

```env
REACT_APP_API_URL=http://localhost:8080
```

### 6. Run the frontend

```bash
npm start
```

App available at `http://localhost:3000`.

---

## 🔌 API Reference

| Method | Endpoint | Description |
|---|---|---|
| `GET` | `/incidents` | List all incidents |
| `POST` | `/incidents` | Create a new incident |
| `GET` | `/incidents/{id}` | Get incident detail |
| `PATCH` | `/incidents/{id}` | Update incident status/assignee |
| `GET` | `/alerts` | List alerts (filterable by service, severity) |
| `GET` | `/monitoring/services` | Get per-service health snapshot |
| `GET` | `/analytics/mttr` | MTTR/MTTA time-series |
| `GET` | `/analytics/noise` | Alert noise breakdown |
| `GET` | `/actuator/health` | Spring Boot health check |

---

## 🔧 gRPC Services

Inter-service communication is handled over gRPC. Proto definitions live in `backend/src/main/proto/`:

```protobuf
// Example: Alert service contract
service AlertService {
  rpc TriggerAlert (AlertRequest) returns (AlertResponse);
  rpc GetActiveAlerts (Empty) returns (AlertListResponse);
  rpc EscalateAlert (EscalationRequest) returns (EscalationResponse);
}
```

The notification service is invoked via gRPC when an alert crosses an escalation threshold, triggering an email to the on-call engineer via Spring Mail.

---

## 🗺️ Roadmap

- [ ] Complete auth flow (login, register, session management)
- [ ] On-call schedule management with rotation support
- [ ] Alert rule builder UI (currently hardcoded in monitoring header)
- [ ] WebSocket / SSE for true real-time alert streaming (replacing polling)
- [ ] Kubernetes deployment manifests + Helm chart
- [ ] Prometheus metrics endpoint + Grafana dashboard
- [ ] Mobile push notifications via Android app (Kotlin)
- [ ] Multi-tenant / multi-team support

---


