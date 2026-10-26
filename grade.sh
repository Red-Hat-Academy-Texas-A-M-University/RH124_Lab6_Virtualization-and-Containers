#!/bin/bash
# =========================================================
# Lab 6 - Virtualization & Containers : grader
#
# Usage:  ./grade.sh [port]
#   port = the host port you published in step 2a (-p <port>:80).
#   If omitted, you will be asked for it.
# =========================================================

GREEN="\033[0;32m"
RED="\033[0;31m"
RESET="\033[0m"

DOCKER_IP="10.2.0.103"
DOCKER_HOST_ADDR="tcp://${DOCKER_IP}:2375"
IMAGE="quay.io/krieg/rh124_lab6"
WEBAPP="RH124_Lab6_Web-App"

PASSED=0
FAILED=0
pass() { echo -e "${GREEN}[PASSED]${RESET} $1"; PASSED=$((PASSED + 1)); }
fail() { echo -e "${RED}[FAILED]${RESET} $1"; FAILED=$((FAILED + 1)); }

# =========================================================
# Section 1 - Bare metal (runs on the student's machine)
# =========================================================

if rpm -q httpd &>/dev/null; then
    pass "httpd is installed"
else
    fail "httpd is not installed"
fi

if systemctl is-active --quiet httpd 2>/dev/null; then
    pass "httpd service is running"
else
    fail "httpd service is not running"
fi

# Accept either 'git clone <url>' run inside /var/www/html (-> subfolder)
# or 'git clone <url> /var/www/html' (-> files directly in the web root)
if [ -f "/var/www/html/${WEBAPP}/api.txt" ]; then
    API_URL="http://localhost/${WEBAPP}/api.txt"
    pass "Web app cloned into /var/www/html/${WEBAPP}"
elif [ -f /var/www/html/api.txt ]; then
    API_URL="http://localhost/api.txt"
    pass "Web app cloned into /var/www/html"
else
    API_URL=""
    fail "api.txt not found - was ${WEBAPP} cloned into /var/www/html?"
fi

if [ -n "$API_URL" ] && curl -sf "$API_URL" | grep -q "Success"; then
    pass "api.txt is served over HTTP at $API_URL"
else
    fail "api.txt is not reachable over HTTP"
fi

# =========================================================
# Section 2 - Docker (checks the shared remote host)
# =========================================================

if ! command -v docker &>/dev/null; then
    fail "docker command not found (re-run setup.sh)"
elif docker -H "$DOCKER_HOST_ADDR" info &>/dev/null; then
    pass "Remote Docker daemon at $DOCKER_HOST_ADDR is reachable"

    PORT="${1:-}"
    if [ -z "$PORT" ] && [ -t 0 ]; then
        read -rp "Which port did you publish your container on in step 2a? " PORT
    fi

    if ! [[ "$PORT" =~ ^[0-9]+$ ]]; then
        fail "No valid port given - run: ./grade.sh <port>"
    else
        # The host is shared, so look for the container on *this student's* port
        IMG=$(docker -H "$DOCKER_HOST_ADDR" ps --filter "publish=${PORT}" \
                --format '{{.Image}}' 2>/dev/null | head -n1)
        if [ "$IMG" = "$IMAGE" ] || [ "$IMG" = "${IMAGE}:latest" ]; then
            pass "Container from $IMAGE is running on ${DOCKER_IP}:${PORT}"
        elif [ -n "$IMG" ]; then
            fail "Port $PORT is published by a container from '$IMG', not $IMAGE"
        else
            fail "No running container is published on port $PORT"
        fi

        if curl -sf "http://${DOCKER_IP}:${PORT}" &>/dev/null; then
            pass "Containerized web app responds at http://${DOCKER_IP}:${PORT}"
        else
            fail "Nothing responded at http://${DOCKER_IP}:${PORT}"
        fi
    fi
else
    fail "Cannot reach remote Docker daemon at $DOCKER_HOST_ADDR"
fi

echo
echo "Result: ${PASSED} passed, ${FAILED} failed"
