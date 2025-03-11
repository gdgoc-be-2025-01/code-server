# Use LinuxServer.io code-server as the base image
FROM lscr.io/linuxserver/code-server:latest

# Set environment variables
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1

# Add cloudflare repository
RUN mkdir -p --mode=0755 /usr/share/keyrings
RUN curl -fsSL https://pkg.cloudflare.com/cloudflare-main.gpg | tee /usr/share/keyrings/cloudflare-main.gpg >/dev/null
RUN echo 'deb [signed-by=/usr/share/keyrings/cloudflare-main.gpg] https://pkg.cloudflare.com/cloudflared any main' | sudo tee /etc/apt/sources.list.d/cloudflared.list

# Install system packages required for Django development
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3-dev \
    python3-pip \
    python3-venv \
    postgresql-client \
    default-libmysqlclient-dev \
    pkg-config \
    gcc \
    gettext \
    sqlite3 \
    libsqlite3-dev \
    libjpeg-dev \
    libpng-dev \
    zlib1g-dev \
    cloudflared \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Create and activate a Python virtual environment
RUN python3 -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Install Django and common packages
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir \
    django \
    djangorestframework \
    django-crispy-forms \
    django-debug-toolbar \
    psycopg2-binary \
    mysqlclient \
    pillow \
    pytest \
    pytest-django \
    coverage \
    black \
    flake8 \
    isort \
    python-dotenv \
    gunicorn

# Install VS Code extensions for Django development
RUN /app/code-server/bin/code-server --extensions-dir /config/extensions --install-extension ms-python.python \
    && /app/code-server/bin/code-server --extensions-dir /config/extensions --install-extension tonybaloney.vscode-pets

# Recover .bashrc
RUN cp /etc/skel/.bashrc /config

# # Set up workspace settings for Django
# RUN mkdir -p /config/workspace/.vscode
# COPY settings.json /config/workspace/.vscode/

# chown all the files to the app user
RUN chown -R abc:abc /config

# Set the working directory
WORKDIR /config/workspace
