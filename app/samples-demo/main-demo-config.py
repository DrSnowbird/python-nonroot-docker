import importlib
import logging
import os
import re
import sys
import types

import requests
import json
import objectpath

sys.path.append('./lib/config/python3')

# -----------
# -- Tests --
# -----------
from ConfigAbstractClass import ConfigAbstractClass
from ConfigFromRemote import ConfigFromRemote
from ConfigInfo import ConfigInfo, ConfigInfoList
from ConfigManager import ConfigManager


def main():
    # logging.basicConfig(filename='example.log', filemode='w', level=logging.DEBUG)
    logging.basicConfig(level='DEBUG')

    # ------------------------------------------------------------------------------------------------------------
    # -- "priority" is used to determine which has the highest priority in overwriting other config sources:    --
    # -- priority=9 (if the rest is 1, 3, 5, 7, then this has the final control of the key's value if not None) --
    # ------------------------------------------------------------------------------------------------------------

    # ----------------
    # -- priority=9 --
    # ----------------
    config_env = ConfigInfo(config_type='ConfigFromEnv', priority=9)

    # ----------------
    # -- priority=7 --
    # ----------------
    config_yaml_remote = ConfigInfo(config_type='ConfigFromYamlRemote',
                                    remote_url='http://abdn-vm-166:18080/jetty_base/yaml',
                                    config_object_uid='recast_config_LOCAL_abdn-vm-166.mitre.org.yaml',
                                    priority=7)
    # ----------------
    # -- priority=5 --
    # ----------------
    config_json_remote = ConfigInfo(config_type='ConfigFromRemote',
                                    remote_url='http://abdn-vm-155.mitre.org:3000/',
                                    config_object_uid='recast_config_LOCAL_abdn-vm-166.mitre.org',
                                    priority=5)
    # ----------------
    # -- priority=3 --
    # ----------------
    config_yaml = ConfigInfo(config_type='ConfigFromYaml', file_path='data/yaml-test-data.yaml', priority=3)

    # ----------------
    # -- priority=1 (the lowest compared to the above sources).
    # ----------------
    config_json = ConfigInfo(config_type='ConfigFromJson', file_path='data/json-test-data.json', priority=1)

    # ---------------------------------------------------------------------------------------------
    # -- Now, register all the above Config sources into a list for Facade Controller to manage: --
    # -- To test all the above, uncomment the comment symbols below.                             --
    # ---------------------------------------------------------------------------------------------
    conf_list = ConfigInfoList()
    conf_list.append(config_env)
    conf_list.append(config_json)
    conf_list.append(config_yaml)
    conf_list.append(config_json_remote)
    conf_list.append(config_yaml_remote)

    # -----------------------------------------------------------------------------------------------------
    # -- Now, register all the above Config sources list into Facade Controller:                         --
    # -- Facade manager now control how to prioritize and access / evaluate the final value for a query: --
    # -----------------------------------------------------------------------------------------------------
    manager = ConfigManager.get_instance(conf_list)

    # ------------------------------------------------------------------------------------------------------------
    # -- Demo: read both JSON (priority=1) and YAML files and YAML files (priority=3) -- see above code lines:  --
    # -- Priority: YAML's value '10.128.9.166' will overwirte JSON's value 'abdn-vm-166.mitre.org'              --
    # -- Results: Key/value: /recastapp/kafka/host=10.128.9.166                                                 --
    # ------------------------------------------------------------------------------------------------------------
    path = "/recastapp/kafka/host"
    value = manager.query(path)
    print("Key/value: {0}={1}".format(path, value))

# -----------
# -- main --
# -----------
if __name__ == "__main__":
    # execute only if run as a script
    main()
