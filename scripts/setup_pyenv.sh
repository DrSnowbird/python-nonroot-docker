#!/bin/bash

env |sort

SETUP_PYENV=${SETUP_PYENV:-0}
if [[ ${SETUP_PYENV} -gt 0 ]]; then
    curl -k https://pyenv.run | bash && \
    echo "export PYENV_ROOT=\$HOME/.pyenv" >> ~/.bashrc && \
    echo "export PATH=\$PYENV_ROOT/bin:\$HOME/.local/bin:\$PATH" >> $HOME/.bashrc && \
    echo "eval \"\$(pyenv init --path)\" " >> $HOME/.bashrc && \
    echo "eval \"\$(pyenv init -)\" " >> $HOME/.bashrc && \
    echo "eval \"\$(pyenv virtualenv-init -)\" " >> $HOME/.bashrc && \
    echo "pyenv virtualenv myvenv" >> $HOME/.bashrc && \
    echo "pyenv activate myvenv" >> $HOME/.bashrc
   
    # -- alias setup: -- ## 
    echo "alias venv='pyenv virtualenv'" >> $HOME/.bashrc && \
    echo "alias activate='pyenv activate'" >> $HOME/.bashrc && \
    echo "alias deactivate='pyenv deactivate'" >> $HOME/.bashrc && \
    echo "alias venv-delete='pyenv virtualenv-delete'" >> $HOME/.bashrc
fi
