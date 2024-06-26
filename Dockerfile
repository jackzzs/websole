FROM python:3.8 AS builder

WORKDIR /src
COPY . .

RUN python -m venv /opt/venv \
    && . /opt/venv/bin/activate \
    && pip install --no-cache-dir -U pip setuptools wheel \
    && pip install --no-cache-dir .

FROM python:3.8-slim
COPY --from=builder /opt/venv /opt/venv

WORKDIR /app
ENV PATH="/opt/venv/bin:$PATH"
ENV _WEB_HOST 0.0.0.0
ENV _WEB_ISOLATED 1

ENTRYPOINT ["websole"]
