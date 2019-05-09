# pip install sshtunnel
# pip install pymysql

from sshtunnel import SSHTunnelForwarder
import pymysql.cursors

with SSHTunnelForwarder(
    ("111.111.111.111", 2222),
    ssh_username="sshuser",
    ssh_password="sshpwd",
    remote_bind_address=("127.0.0.1", 3306)
    ) as ssh:

    conn = pymysql.connect(host='127.0.0.1',
        port=ssh.local_bind_port,
        user='dbuser',
        password='dbpass',
        db='targetdb',
        charset='utf8',
        cursorclass=pymysql.cursors.DictCursor)

    cursor = conn.cursor()
    sql = "show tables"
    cursor.execute(sql)

    rets = cursor.fetchall()
    for r in rets:
        print(r)

    conn.close()
