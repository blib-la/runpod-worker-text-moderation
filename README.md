# runpod-worker-text-moderation

> 🚧 WIP 🚧

## Build the image

You can build the image locally: `docker build -t timpietruskyblibla/runpod-worker-text-moderation:dev --platform linux/amd64 .`

🚨 It's important to specify the `--platform linux/amd64`, otherwise you will get an error on RunPod!

### Setup

- Make sure you have Python >= 3.10
- Create a virtual environment: `python -m venv venv`
- Activate the virtual environment: `.\venv\Scripts\activate` (Windows) or `source ./venv/bin/activate` (Mac / Linux)
- Install the dependencies: `pip install -r requirements.txt`


You can also start the handler itself to have the local server running: `python src/rp_handler.py`