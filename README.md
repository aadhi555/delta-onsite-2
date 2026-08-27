# delta-onsite-2 — Consistent Hash Load Balancing with nginx

A live demonstration of **consistent hashing** for load balancer scaling, built at a Delta Force onsite challenge: it shows quantitatively how few users get remapped to a different backend when a new server is added, compared to naive modulo-based load balancing.

## Setup

nginx is configured to route requests across Flask backends using **consistent hashing on a custom header**, not round-robin:

```nginx
upstream backend {
    hash $http_x_user_id consistent;
    server backend1:5000;
    server backend2:5000;
    server backend3:5000;
    server backend4:5000;
}
```

Each backend (`backend1`–`backend4`, identical Flask apps) tracks the set of unique `X-User-ID` values it has ever seen and reports its identity + running user count on every request:

```python
@app.route("/")
def info():
    user = request.headers.get("X-User-ID", "anonymous")
    unique_users.add(user)
    return f"Server: backend1 | Total Users: {len(unique_users)} | Current User: {user}\n"
```

## The experiment (`test.sh`)

1. Start with **3 backends** live (`backend4` commented out of both `nginx.conf` and `docker-compose.yaml`)
2. Fire 100 requests with `X-User-ID: 1..100`, log which backend served each user → `before.txt`
3. Pause (`read -r`) while `backend4` is brought online and nginx is hot-reloaded:
   ```bash
   docker compose up -d --build backend4 && docker compose exec nginx nginx -s reload
   ```
4. Re-fire the same 100 requests → `after.txt`
5. Diff `before.txt` vs `after.txt` (matching on server name per user) to count how many users got remapped to a **different** backend purely from adding one more server

```bash
./test.sh
```

## Result

With consistent hashing, only a small minority of the 100 users move to `backend4`; the rest stay pinned to their original backend (visible by comparing `before.txt`/`after.txt` — `backend4`'s user count climbs from a handful up to its fair share while backend1–3's assignments stay untouched). A naive `hash % N` scheme would have remapped the majority of users on every scaling event.

## Files

- `nginx.conf` — the consistent-hash upstream config
- `docker-compose.yaml` — nginx + 4 Flask backend services
- `backend1..4/` — identical Flask apps, each its own Dockerfile
- `test.sh` — the before/after scaling experiment
- `before.txt` / `after.txt` — captured request logs from the actual onsite run
- `manual.txt` — research notes/links used while building this (consistent hashing theory, nginx hash load balancing docs)
- `POC_screenshot.png`, `POC.mp4` — proof-of-concept evidence from the onsite submission

## What it demonstrates

- Practical, measured understanding of **why** consistent hashing matters for horizontal scaling (minimal key remapping) rather than just citing the theory
- nginx `upstream` hash-based load balancing configuration
- Docker Compose service scaling with a live `nginx -s reload` instead of full stack restart
- Designing a repeatable experiment (identical before/after methodology) to quantify a distributed-systems concept
