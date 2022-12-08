import functools
import logging
import shlex
from subprocess import Popen, PIPE, STDOUT

from fastapi import Header, HTTPException
import pymysql
from pymysql.connections import Connection
from pymysql.cursors import DictCursor, Cursor
from typing import Iterator

from api.settings import CONFIG

logger = logging.getLogger(__name__)

@functools.lru_cache
def build_connection(host: str, bind_address: str)-> Connection:
    return pymysql.connect(
        host=host,
        user=CONFIG.DB_USER,
        password=CONFIG.DB_PASSWORD,
        database=CONFIG.DB_NAME,
        cursorclass=DictCursor,
        bind_address=bind_address
    )



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


async def check_header(x_cluster_mode: str = Header(None)) -> None:
    if not x_cluster_mode:
        raise HTTPException(
            status_code=400,
            detail="Invalid X-Cluster-Mode header"
        )
    if x_cluster_mode.lower() == 'direct-hit':
        CONFIG.PYMYSQL_HOST = CONFIG.MASTER_NODE_IP
        CONFIG.PYMYSQL_BIND_ADDRESS = CONFIG.BIND_ADDRESSES[0]
        return
    # if x_cluster_mode.lower() == 'random':
    #     random_ip = random.choice([CONFIG.MASTER_NODE_IP] + CONFIG.SLAVE_NODE_IPS)
    #     CONFIG.SQLALCHEMY_DATABASE_URI = build_uri(random_ip)
    #     return
    # if x_cluster_mode.lower() == 'ping':
    #     all_instances = [CONFIG.MASTER_NODE_IP] + CONFIG.SLAVE_NODE_IPS
    #     instance_pings = {name: get_ping_time(name) for name in all_instances}
    #     CONFIG.SQLALCHEMY_DATABASE_URI = build_uri(max(instance_pings, key=instance_pings.get))
    #     return
   
        
def get_db() -> Iterator[Cursor]:
    connection = build_connection(CONFIG.PYMYSQL_HOST, CONFIG.PYMYSQL_BIND_ADDRESS)
    cursor = connection.cursor()
    try:
        yield cursor
        connection.commit()
    except Exception:
        connection.rollback()
    finally:
        connection.close()