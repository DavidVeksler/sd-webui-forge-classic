@echo off
setlocal EnableDelayedExpansion

cd /d "%~dp0"

set PYTHON=C:\Python313\python.exe
:: set GIT=

:: ---------------------------------------------------------------------------
:: AMD Radeon AI PRO R9700 (32 GB, RDNA4 / gfx1201) via ROCm on Windows.
:: Uses its own venv (venv-rocm) holding AMD's ROCm PyTorch nightly wheels
:: (https://rocm.nightlies.amd.com/v2/gfx120X-all/). The ROCm torch build only
:: sees the Radeon, so the leftover RTX 3060 is ignored. The old CUDA setup
:: (venv + dual-3060 split) lives in webui-custom-nvidia.bat.
::
:: To rebuild the venv from scratch:
::   C:\Python313\python.exe -m venv venv-rocm
::   venv-rocm\Scripts\python.exe -m pip install --index-url https://rocm.nightlies.amd.com/v2/gfx120X-all/ torch torchvision
:: (launch.py installs the rest of requirements.txt and skips torch when present)
::
:: 32 GB holds the text encoder and diffusion model together, so no
:: --text-enc-device split is needed. No --xformers (CUDA-only wheel) and no
:: --cuda-malloc (cudaMallocAsync is NVIDIA-only).
:: ---------------------------------------------------------------------------
set "VENV_DIR=%~dp0venv-rocm"
set "HIP_VISIBLE_DEVICES=0"

set COMMANDLINE_ARGS=--enable-insecure-extension-access %* --listen --port 8888 --api --skip-torch-cuda-test --skip-version-check --reserve-vram 1 --fp8_e4m3fn-unet --fast-fp8

:: Tested on the Radeon AI PRO R9700: FP8 storage plus fast FP8 computation.
:: PyTorch SDPA is enabled automatically by this ROCm build.

call "%~dp0webui.bat"
