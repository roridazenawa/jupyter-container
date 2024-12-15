# Jupyter Container

Deploy Jupyter Notebooks in this simple Docker container directly to Railway.

[![Deploy on Railway](https://railway.com/button.svg)](https://kirr.co/egdpam)

Environment variables:

- `JUPYTER_PASSWORD`: The password for to login to the Jupyter notebook server.
- `JUPYTER_IP`: The IP address for the Jupyter notebook (defaults to 0.0.0.0).
- `PORT`: The port for the Jupyter notebook (defaults to 8888).


## Jupyter Notebook Server for Railway
The goal of this [Railway template](https://kirr.co/egdpam) is two fold:

- Customizable Jupyter environment
- Shell-like interactivity with Railway resources (private and public)

The official JupyterLab Railway template is great but... it's overly complex for simple Jupyter tasks. That's what this template is for.

The code is open source so feel free to fork and customize as you see fit. In our case, we can use it to:

- Verify private Railway resource connections -- such as calling non-internet connected APIs
- Run various analytics with private databases
- Use numpy, pandas, scikit-learn, and many other Data Science tools
- Build and deploy as needed. Tear down at will.

Do you have ideas? Please share them with me https://x.com/justinmitchel or on the GitHub Repo attached to this template. 

All code is available at: https://github.com/codingforentrepreneurs/jupyter-container

Enjoy!

