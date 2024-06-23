.RECIPEPREFIX := >
.DEFAULT_GOAL := help
.PHONY: help help/simple help/all install develop venv venv/clean python/venv conda/venv conda/install run run/cli run/web systemd systemd/install systemd/uninstall lint test debugpy debugpy/cli debugpy/web version version/patch version/minor version/major push clean clean/build clean/pyc clean/test

USE_MIRROR ?= False

ifeq ($(USE_MIRROR), True)
    CONDA_URL := "https://mirrors.tuna.tsinghua.edu.cn/anaconda/miniconda/Miniconda3-latest-Linux-$$(uname -i).sh"
    PYPI_URL := "https://pypi.tuna.tsinghua.edu.cn/simple"
else
    CONDA_URL := "https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-$$(uname -i).sh"
    PYPI_URL := "https://pypi.org/simple"
endif

PYTHON ?= python
PYTHON_COMPATIBLE := $(shell "$(PYTHON)" -c "import sys; print(sys.version_info >= (3, 8))" 2>/dev/null || echo False)
CONDA_ROOT ?= conda
VENV := venv

help: help/simple

help/simple:
>   @echo "Welcome to websole!"
>   @echo "\nUsage: make <subcommand>"
>   @echo "  install - create a venv and install websole in it."
>   @echo "  develop - install websole and also dev-related tools."
>   @echo "  run - run websole with config.toml."
>   @echo "  lint - check style with black and pre-commit."
>   @echo "  test - run pytest using current python."
>   @echo "  help/all - show all subcommands."
>   @echo "\nFor using websole, you can run:"
>   @echo "  make install && make run"

help/all:
>   @echo "Welcome to websole!"
>   @echo "Usage: make <subcommand>"
>   @echo "  install - create a venv and install websole in it."
>   @echo "  develop - install websole and also dev-related tools."
>   @echo "  venv - create a venv (if python compatible) or conda (if not)."
>   @echo "  venv/clean - remove all created venv."
>   @echo '  python/venv - create a venv using current python in "<CWD>/venv".'
>   @echo '  conda/venv - create a conda venv in "<CWD>/venv".'
>   @echo '  conda/install - install conda in "<CWD>/conda".'
>   @echo "  run - run websole with config.toml."
>   @echo "  lint - fix code style with black and pre-commit."
>   @echo "  test - run pytest using current python."
>   @echo "  debugpy - start websole with debugpy (vscode debug module) for remote connection at localhost:5678."
>   @echo "  version - same as version/patch."
>   @echo "  version/patch - run bump2version patch and push."
>   @echo "  version/minor - run bump2version minor and push."
>   @echo "  version/major - run bump2version major and push."
>   @echo "  push - git push both commits and tags."
>   @echo "  clean - remove build and test caches."
>   @echo "  clean/build - remove build caches."
>   @echo "  clean/pyc - remove python caches."
>   @echo "  clean/test - remove test caches."

install: venv
>   @"$(VENV)/bin/python" -m pip install -i "$(PYPI_URL)" -U pip && \
>   "$(VENV)/bin/python" -m pip install -i "$(PYPI_URL)" -e . \
>   && echo "Info: websole has been installed successfully." \
>   && echo 'Info: Run "make run" to run websole.' \
>   && echo 'Info: Run "make systemd" to enable autostart.' \
>   || echo "Error: Fail to install websole."

develop: install
>   "$(VENV)/bin/python" -m pip install -i "$(PYPI_URL)" -r requirements_dev.txt

ifeq ($(PYTHON_COMPATIBLE), True)
    venv: python/venv
else
    venv: conda/venv
endif

venv/clean:
>   rm -R -f venv conda &>/dev/null

python/venv:
>   @[ -d "$(VENV)" ] || "$(PYTHON)" -m venv "$(VENV)"

conda/venv: conda/install
>   @[ -d "$(VENV)" ] || "$(CONDA_ROOT)/condabin/conda" create -y --prefix venv python~=3.8.0

conda/install:
>   @if [ ! -d "$(CONDA_ROOT)" ]; then \
>       echo "Warning: Your python / python version does not meet the requirements, installing using miniconda..."; \
>       curl -L -o conda.sh "$(CONDA_URL)" && chmod +x conda.sh && bash conda.sh -b -f -p "$(CONDA_ROOT)"; \
>       rm conda.sh 2>/dev/null; \
>   fi

run: run/cli

run/cli: venv
>   @"$(VENV)/bin/python" -m websole

lint:
>   "$(VENV)/bin/python" -m black .
>   "$(VENV)/bin/python" -m pre_commit run -a || "$(VENV)/bin/python" -m pre_commit run -a

test:
>   "$(VENV)/bin/python" -m pytest

debugpy: debugpy/cli

debugpy/cli:
>   "$(VENV)/bin/python" -m debugpy --listen localhost:5678 --wait-for-client cli.py

version: version/patch

version/patch:
>   bump2version patch
>   git push && git push --tags

version/minor:
>   bump2version minor
>   git push && git push --tags

version/major:
>   bump2version major
>   git push && git push --tags

push:
>   git push && git push --tags

clean: clean/build clean/pyc clean/test
>   @echo "Info: Cleaned python build and test caches."

clean/build:
>   rm -fr build/
>   rm -fr dist/
>   rm -fr .eggs/
>   find . -name '*.egg-info' -exec rm -fr {} +
>   find . -name '*.egg' -exec rm -f {} +

clean/pyc:
>   find . -name '*.pyc' -exec rm -f {} +
>   find . -name '*.pyo' -exec rm -f {} +
>   find . -name '*~' -exec rm -f {} +
>   find . -name '__pycache__' -exec rm -fr {} +

clean/test:
>   rm -fr .tox/
>   rm -f .coverage
>   rm -fr htmlcov/
