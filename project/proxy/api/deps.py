import shlex
import random
import logging
from subprocess import Popen, PIPE, STDOUT
from typing import Iterator
from fastapi import Header, HTTPException

import pymysql
from pymysql.cursors import DictCursor, Cursor
from sshtunnel import SSHTunnelForwarder

from proxy.settings import CONFIG

logger = logging.getLogger("api")

def get_cmd_output(cmd: str, stderr: int = STDOUT) -> str:
    """
    Execute external command and get output
    """
    args = shlex.split(cmd)
    return Popen(args, stdout=PIPE, stderr=stderr).communicate()[0].decode(encoding='utf-8')


def get_ping_time(host: str) -> int:
    host = host.split(":")[0]
    cmd = f"fping {host} -C 1 -q"
    res = [
        float(x) for x in get_cmd_output(cmd).strip().split(":")[-1].split() if x != '-'
    ]
    if len(res) > 0:
        return sum(res) / len(res)
    else:
        return 999999

"""
FastAPI dependencies
"""

async def check_header(x_cluster_mode: str = Header(None)):
    """
    Check the X-Cluster-Mode header and set the chosen host
    """
    if not x_cluster_mode:
        raise HTTPException(
            status_code=400,
            detail="Invalid X-Cluster-Mode header"
        )
    all_instances = [CONFIG.MASTER_NODE_IP] + CONFIG.SLAVE_NODE_IPS
    if x_cluster_mode.lower() == 'direct-hit':
        CONFIG.CHOSEN_HOST = CONFIG.MASTER_NODE_IP
    if x_cluster_mode.lower() == 'random':
        CONFIG.CHOSEN_HOST = random.choice(all_instances)
    if x_cluster_mode.lower() == 'ping':
        instance_pings = { name: get_ping_time(name) for name in all_instances }
        # Get the instance with the lowest ping time
        lowest_ping = min(instance_pings, key=instance_pings.get)
        logger.info(f"Chosen host: {lowest_ping}")
        CONFIG.CHOSEN_HOST = lowest_ping


async def get_db() -> Iterator[Cursor]:
    with SSHTunnelForwarder(
        CONFIG.CHOSEN_HOST,
        ssh_username="ubuntu",
        ssh_pkey=CONFIG.RSA_PRIVATE_KEY,
        remote_bind_address=(CONFIG.MASTER_NODE_IP, 3306)
    ):
        connection = pymysql.connect(
            host=CONFIG.MASTER_NODE_IP,
            user=CONFIG.DB_USER,
            password=CONFIG.DB_PASSWORD,
            database=CONFIG.DB_NAME,
            cursorclass=DictCursor,
        )
        cursor = connection.cursor()
        try:
            yield cursor
            connection.commit()
        except Exception:
            connection.rollback()
        finally:
            connection.close()